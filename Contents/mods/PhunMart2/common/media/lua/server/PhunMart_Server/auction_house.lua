if isClient() then
    return
end

require "PhunMart/auction_house"
local Core = PhunMart
local AH = Core.auctionHouse

-- ─────────────────────────────────────────────────────────────────────────────
-- Server-side Auction House storage, CRUD, and expiry (Phase 1: buy-now only)
-- ─────────────────────────────────────────────────────────────────────────────

local STORE_FILE = "PhunMart_AuctionHouse.lua"
local STORE_MODDATA = "PhunMart_AuctionHouse"
local LOG_FILE = "auction_house.log"

-- ─────────────────────────────────────────────────────────────────────────────
-- Data store
-- ─────────────────────────────────────────────────────────────────────────────

AH.listings = {}       -- id → listing
AH.collections = {}    -- username → { items={}, credits={} }
AH.nextId = 1
AH._dirty = false

-- Index tables (rebuilt on load)
AH._activeIds = {}     -- set: id → true
AH._bySeller = {}      -- username → { id → true }

-- ─────────────────────────────────────────────────────────────────────────────
-- Persistence (dual: file + ModData, same pattern as wallet)
-- ─────────────────────────────────────────────────────────────────────────────

function AH:rebuildIndices()
    self._activeIds = {}
    self._bySeller = {}
    for id, listing in pairs(self.listings) do
        if listing.status == AH.STATUS.ACTIVE then
            self._activeIds[id] = true
        end
        local seller = listing.seller
        if seller then
            if not self._bySeller[seller] then
                self._bySeller[seller] = {}
            end
            self._bySeller[seller][id] = true
        end
    end
end

function AH:load()
    -- Try file first (authoritative), fall back to ModData
    local data = Core.fileUtils.loadTable(STORE_FILE)
    if not data then
        data = ModData.getOrCreate(STORE_MODDATA)
    end
    self.listings = data and data.listings or {}
    self.collections = data and data.collections or {}
    self.nextId = data and data.nextId or 1
    self:rebuildIndices()
    Core.debugLn("AuctionHouse: loaded " .. self:countActive() .. " active listings")
end

function AH:save()
    local data = {
        listings = self.listings,
        collections = self.collections,
        nextId = self.nextId
    }
    Core.fileUtils.saveTable(STORE_FILE, data)
    local md = ModData.getOrCreate(STORE_MODDATA)
    md.listings = self.listings
    md.collections = self.collections
    md.nextId = self.nextId
    self._dirty = false
end

function AH:markDirty()
    self._dirty = true
end

function AH:countActive()
    local n = 0
    for _ in pairs(self._activeIds) do
        n = n + 1
    end
    return n
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Collection box helpers
-- ─────────────────────────────────────────────────────────────────────────────

function AH:getCollection(username)
    if not self.collections[username] then
        self.collections[username] = { items = {}, credits = {} }
    end
    local c = self.collections[username]
    if not c.items then c.items = {} end
    if not c.credits then c.credits = {} end
    return c
end

function AH:addItemToCollection(username, itemType, listingId, reason)
    local c = self:getCollection(username)
    table.insert(c.items, {
        item = itemType,
        listingId = listingId,
        reason = reason
    })
    self:markDirty()
end

function AH:addCreditToCollection(username, pool, amount, listingId, reason)
    local c = self:getCollection(username)
    table.insert(c.credits, {
        pool = pool,
        amount = amount,
        listingId = listingId,
        reason = reason
    })
    self:markDirty()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Player key helper (SP uses playerNum 0, MP uses username)
-- ─────────────────────────────────────────────────────────────────────────────

local function playerKey(playerObj)
    if Core.isLocal then
        return "0"
    end
    return playerObj:getUsername()
end

local function playerCharName(playerObj)
    local desc = playerObj:getDescriptor()
    if desc then
        local forename = desc:getForename() or ""
        local surname = desc:getSurname() or ""
        if forename ~= "" or surname ~= "" then
            return (forename .. " " .. surname):match("^%s*(.-)%s*$")
        end
    end
    return playerObj:getUsername()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Seller active listing count
-- ─────────────────────────────────────────────────────────────────────────────

function AH:countSellerActive(username)
    local sellerIds = self._bySeller[username]
    if not sellerIds then return 0 end
    local n = 0
    for id in pairs(sellerIds) do
        if self._activeIds[id] then
            n = n + 1
        end
    end
    return n
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Core operations
-- ─────────────────────────────────────────────────────────────────────────────

function AH:createListing(playerObj, args)
    if not AH.isEnabled() then
        return nil, "AuctionHouseDisabled"
    end

    local itemType = args.item
    if not AH.isListableItem(itemType) then
        return nil, "ItemNotListable"
    end

    -- Validate price
    local priceOk, priceErr = AH.validatePrice(args.price)
    if not priceOk then
        return nil, priceErr
    end

    local username = playerKey(playerObj)

    -- Check max active listings
    if self:countSellerActive(username) >= AH.getMaxListings() then
        return nil, "MaxListingsReached"
    end

    -- Find and remove item from inventory (escrow)
    local inv = playerObj:getInventory()
    local item = inv:getFirstTypeRecurse(itemType)
    if not item then
        return nil, "ItemNotInInventory"
    end

    -- Bake display name before removing
    local itemName = item:getDisplayName() or itemType:match("%.(.+)$") or itemType

    -- Remove from inventory (escrow)
    item:getContainer():DoRemoveItem(item)

    -- Create listing record
    local id = AH.makeId(self.nextId)
    self.nextId = self.nextId + 1

    local worldAge = GameTime:getInstance():getWorldAgeHours()
    local listing = {
        id = id,
        seller = username,
        sellerChar = playerCharName(playerObj),
        item = itemType,
        itemName = itemName,
        price = {
            kind = args.price.kind,
            pool = args.price.pool,
            amount = args.price.amount
        },
        status = AH.STATUS.ACTIVE,
        createdAge = worldAge,
        expiresAge = worldAge + AH.getExpiryHours()
    }

    self.listings[id] = listing

    -- Update indices
    self._activeIds[id] = true
    if not self._bySeller[username] then
        self._bySeller[username] = {}
    end
    self._bySeller[username][id] = true

    self:markDirty()
    Core.fileUtils.logTo(LOG_FILE, "CREATE", username, id, itemType, tostring(args.price.amount))

    return listing
end

function AH:buyNow(playerObj, listingId)
    if not AH.isEnabled() then
        return nil, "AuctionHouseDisabled"
    end

    local listing = self.listings[listingId]
    if not listing then
        return nil, "ListingNotFound"
    end
    if listing.status ~= AH.STATUS.ACTIVE then
        return nil, "ListingNotActive"
    end

    local buyerName = playerKey(playerObj)
    if buyerName == listing.seller then
        return nil, "CannotBuyOwnListing"
    end

    -- Check affordability and deduct
    local price = listing.price
    if not Core:canAfford(playerObj, price) then
        return nil, "InsufficientFunds"
    end
    Core:deduct(playerObj, price)

    -- Give item to buyer
    local inv = playerObj:getInventory()
    local newItem = inv:AddItem(listing.item)
    if newItem then
        sendAddItemToContainer(inv, newItem)
    end

    -- Credit seller (minus fee)
    local fee = AH.calcFee(price.amount)
    local sellerAmount = price.amount - fee
    if sellerAmount > 0 then
        self:addCreditToCollection(listing.seller, price.pool, sellerAmount, listingId, AH.REASON.SALE)
    end

    -- Mark sold
    listing.status = AH.STATUS.SOLD
    listing.buyer = buyerName
    listing.soldAge = GameTime:getInstance():getWorldAgeHours()
    self._activeIds[listingId] = nil

    self:markDirty()
    Core.fileUtils.logTo(LOG_FILE, "BUY", buyerName, listingId, listing.item, tostring(price.amount), "fee=" .. tostring(fee))

    -- Notify seller if online
    self:notifySeller(listing)

    return listing
end

function AH:cancelListing(playerObj, listingId)
    local listing = self.listings[listingId]
    if not listing then
        return nil, "ListingNotFound"
    end

    local username = playerKey(playerObj)
    if listing.seller ~= username then
        return nil, "NotYourListing"
    end
    if listing.status ~= AH.STATUS.ACTIVE then
        return nil, "ListingNotActive"
    end

    -- Return item to seller collection
    self:addItemToCollection(username, listing.item, listingId, AH.REASON.CANCELLED)

    listing.status = AH.STATUS.CANCELLED
    self._activeIds[listingId] = nil

    self:markDirty()
    Core.fileUtils.logTo(LOG_FILE, "CANCEL", username, listingId, listing.item)

    return listing
end

function AH:collectAll(playerObj)
    local username = playerKey(playerObj)
    local c = self:getCollection(username)
    local granted = { items = {}, credits = {} }

    -- Grant items
    local inv = playerObj:getInventory()
    local remainingItems = {}
    for _, entry in ipairs(c.items) do
        local item = inv:AddItem(entry.item)
        if item then
            sendAddItemToContainer(inv, item)
            table.insert(granted.items, entry)
        else
            -- Inventory full — keep in collection
            table.insert(remainingItems, entry)
        end
    end

    -- Grant credits
    local remainingCredits = {}
    for _, entry in ipairs(c.credits) do
        Core.wallet:adjustByPool(playerObj, "current", entry.pool, entry.amount)
        table.insert(granted.credits, entry)
    end

    c.items = remainingItems
    c.credits = remainingCredits
    Core.wallet:save()
    self:markDirty()

    return granted, c
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Browse (server-side filtering + pagination)
-- ─────────────────────────────────────────────────────────────────────────────

function AH:browse(filters)
    filters = filters or {}
    local results = {}
    local search = filters.search and filters.search:lower() or nil
    local pool = filters.pool
    local sellerFilter = filters.seller -- "mine" username filter

    for id in pairs(self._activeIds) do
        local listing = self.listings[id]
        if listing then
            local pass = true
            if search and not listing.itemName:lower():find(search, 1, true) then
                pass = false
            end
            if pass and pool and listing.price.pool ~= pool then
                pass = false
            end
            if pass and sellerFilter and listing.seller ~= sellerFilter then
                pass = false
            end
            if pass then
                table.insert(results, listing)
            end
        end
    end

    -- Sort by creation time descending (newest first)
    table.sort(results, function(a, b)
        return (a.createdAge or 0) > (b.createdAge or 0)
    end)

    -- Paginate
    local page = filters.page or 1
    local pageSize = filters.pageSize or 50
    local startIdx = (page - 1) * pageSize + 1
    local endIdx = startIdx + pageSize - 1
    local paged = {}
    for i = startIdx, math.min(endIdx, #results) do
        table.insert(paged, results[i])
    end

    return {
        listings = paged,
        total = #results,
        page = page,
        pageSize = pageSize
    }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- My Listings (seller's own listings, all statuses)
-- ─────────────────────────────────────────────────────────────────────────────

function AH:myListings(username)
    local results = {}
    local sellerIds = self._bySeller[username]
    if not sellerIds then
        return results
    end
    for id in pairs(sellerIds) do
        local listing = self.listings[id]
        if listing then
            table.insert(results, listing)
        end
    end
    table.sort(results, function(a, b)
        return (a.createdAge or 0) > (b.createdAge or 0)
    end)
    return results
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Expiry tick (called from EveryTenMinutes)
-- ─────────────────────────────────────────────────────────────────────────────

function AH:expireTick()
    local worldAge = GameTime:getInstance():getWorldAgeHours()
    local expired = {}
    for id in pairs(self._activeIds) do
        local listing = self.listings[id]
        if listing and worldAge >= listing.expiresAge then
            table.insert(expired, listing)
        end
    end

    for _, listing in ipairs(expired) do
        listing.status = AH.STATUS.EXPIRED
        self._activeIds[listing.id] = nil
        -- Return item to seller collection
        self:addItemToCollection(listing.seller, listing.item, listing.id, AH.REASON.EXPIRED)
        Core.fileUtils.logTo(LOG_FILE, "EXPIRE", listing.seller, listing.id, listing.item)
        self:notifySeller(listing)
    end

    if #expired > 0 then
        self:markDirty()
        Core.debugLn("AuctionHouse: expired " .. #expired .. " listings")
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Purge old completed listings to prevent unbounded growth.
-- Removes SOLD/EXPIRED/CANCELLED listings older than 168 world-hours (~1 week).
-- Called alongside expireTick.
-- ─────────────────────────────────────────────────────────────────────────────

function AH:purgeOldListings()
    local worldAge = GameTime:getInstance():getWorldAgeHours()
    local cutoff = worldAge - 168
    local removed = 0
    for id, listing in pairs(self.listings) do
        if listing.status ~= AH.STATUS.ACTIVE then
            local age = listing.soldAge or listing.createdAge or 0
            if age < cutoff then
                self.listings[id] = nil
                if self._bySeller[listing.seller] then
                    self._bySeller[listing.seller][id] = nil
                end
                removed = removed + 1
            end
        end
    end
    if removed > 0 then
        self:markDirty()
        Core.debugLn("AuctionHouse: purged " .. removed .. " old listings")
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Notify seller (online) about sale/expiry
-- ─────────────────────────────────────────────────────────────────────────────

function AH:notifySeller(listing)
    if Core.isLocal then
        triggerEvent(Core.events.OnAHListingUpdate, listing)
    else
        local sellerPlayer = Core.utils.getPlayerByUsername(listing.seller)
        if sellerPlayer then
            sendServerCommand(sellerPlayer, Core.name, Core.commands.ahListingUpdate, {
                listing = listing,
                collection = self:getCollection(listing.seller)
            })
        end
    end
end
