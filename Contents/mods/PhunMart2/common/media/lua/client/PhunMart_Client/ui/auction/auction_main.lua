if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
require "ISUI/ISTabPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISTextEntryBox"
require "ISUI/ISComboBox"
require "PhunMart/auction_house"

local Core = PhunMart
local AH = Core.auctionHouse
local tools = require "PhunMart_Client/ui/ui_utils"

-- ─────────────────────────────────────────────────────────────────────────────
-- SP/MP command routing
-- In SP, sendClientCommand is a no-op; we must call the server command handler
-- directly since server and client share the same Lua state.
-- ─────────────────────────────────────────────────────────────────────────────
local _serverCommands = nil

local function sendAHCommand(command, args, player)
    if Core.isLocal then
        -- Lazy-load server commands table (shared Lua state in SP)
        if not _serverCommands then
            _serverCommands = require "PhunMart_Server/commands"
        end
        local playerObj = player or getSpecificPlayer(0)
        if _serverCommands[command] then
            _serverCommands[command](playerObj, args or {})
        end
    else
        sendClientCommand(Core.name, command, args or {})
    end
end

local FONT_SM = tools.FONT_HGT_SMALL
local FONT_MD = tools.FONT_HGT_MEDIUM
local FS = tools.FONT_SCALE
local PAD = math.max(10, math.floor(10 * FS))
local ROW_H = FONT_SM + math.floor(6 * FS)
local BTN_H = tools.BUTTON_HGT

-- ─────────────────────────────────────────────────────────────────────────────
-- Auction House main window
-- ─────────────────────────────────────────────────────────────────────────────

Core.ui.client.auctionHouse = {}
local M = Core.ui.client.auctionHouse
M.instance = nil

local AuctionUI = ISCollapsableWindowJoypad:derive("PhunMartAuctionHouse")

-- ─────────────────────────────────────────────────────────────────────────────
-- open / close
-- ─────────────────────────────────────────────────────────────────────────────

function M.open(player, data)
    local inst = M.instance
    if inst and inst.player ~= player then
        inst:removeFromUIManager()
        inst = nil
        M.instance = nil
    end

    if not inst then
        local w = math.floor(620 * FS)
        local h = math.floor(500 * FS)
        local sx = math.floor((getCore():getScreenWidth() - w) / 2)
        local sy = math.floor((getCore():getScreenHeight() - h) / 2)
        inst = AuctionUI:new(sx, sy, w, h, player)
        inst:initialise()
        inst:addToUIManager()
        M.instance = inst
    end

    inst:setVisible(true)
    inst:bringToTop()

    if data then
        inst:setData(data)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- constructor
-- ─────────────────────────────────────────────────────────────────────────────

function AuctionUI:new(x, y, w, h, player)
    local o = ISCollapsableWindowJoypad:new(x, y, w, h, player)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.title = "Auction House"
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 0.85}
    o.moveWithMouse = true
    o.anchorRight = true
    o.anchorBottom = true
    o.resizable = true
    o:setWantKeyEvents(true)
    -- data
    o._browseListings = {}
    o._myListings = {}
    o._collection = { items = {}, credits = {} }
    o._browseTotal = 0
    o._browsePage = 1
    return o
end

-- ─────────────────────────────────────────────────────────────────────────────
-- createChildren
-- ─────────────────────────────────────────────────────────────────────────────

function AuctionUI:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local th = self:titleBarHeight()
    local w = self.width
    local h = self.height - th

    -- Tab panel
    self.tabs = ISTabPanel:new(0, th, w, h)
    self.tabs:initialise()
    self.tabs:setAnchorRight(true)
    self.tabs:setAnchorBottom(true)
    self.tabs.tabFont = UIFont.Small
    self.tabs.equalTabWidth = 0
    self:addChild(self.tabs)

    -- Create tab panels
    self.browsePanel = self:createBrowseTab(w, h - self.tabs.tabHeight)
    self.sellPanel = self:createSellTab(w, h - self.tabs.tabHeight)
    self.collectPanel = self:createCollectTab(w, h - self.tabs.tabHeight)

    self.tabs:addView("Browse", self.browsePanel)
    self.tabs:addView("Sell", self.sellPanel)
    self.tabs:addView("Collection", self.collectPanel)
    self.tabs:activateView("Browse")
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Price display helper
-- ─────────────────────────────────────────────────────────────────────────────

local function formatPrice(price)
    if not price then return "?" end
    if price.kind == "free" then return "Free" end
    if price.kind == "currency" then
        local amt = price.amount or 0
        if price.pool == "tokens" then
            return tostring(amt) .. "T"
        else
            if amt % 100 == 0 then
                return "$" .. tostring(amt / 100)
            else
                return string.format("$%.2f", amt / 100)
            end
        end
    end
    return "?"
end

local function formatTimeRemaining(expiresAge)
    if not expiresAge then return "?" end
    local worldAge = GameTime:getInstance():getWorldAgeHours()
    local remaining = expiresAge - worldAge
    if remaining <= 0 then return "Expired" end
    if remaining < 1 then
        return tostring(math.ceil(remaining * 60)) .. "m"
    end
    return tostring(math.floor(remaining)) .. "h"
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Browse tab
-- ─────────────────────────────────────────────────────────────────────────────

function AuctionUI:createBrowseTab(w, h)
    local panel = ISPanel:new(0, 0, w, h)
    panel:initialise()
    panel:instantiate()

    local y = PAD

    -- Search bar
    local searchLbl = ISLabel:new(PAD, y, BTN_H, "Search:", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    searchLbl:initialise()
    panel:addChild(searchLbl)

    local searchW = math.floor(200 * FS)
    self._browseSearch = ISTextEntryBox:new("", PAD + math.floor(60 * FS), y, searchW, BTN_H)
    self._browseSearch:initialise()
    self._browseSearch:instantiate()
    self._browseSearch:setClearButton(true)
    panel:addChild(self._browseSearch)

    -- Pool filter
    local poolX = PAD + math.floor(60 * FS) + searchW + PAD
    local poolLbl = ISLabel:new(poolX, y, BTN_H, "Pool:", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    poolLbl:initialise()
    panel:addChild(poolLbl)

    self._browsePool = ISComboBox:new(poolX + math.floor(45 * FS), y, math.floor(100 * FS), BTN_H, self, nil)
    self._browsePool:initialise()
    self._browsePool:addOptionWithData("All", nil)
    self._browsePool:addOptionWithData("Change", "change")
    self._browsePool:addOptionWithData("Tokens", "tokens")
    panel:addChild(self._browsePool)

    -- Search button
    local searchBtn = ISButton:new(w - PAD - math.floor(80 * FS), y, math.floor(80 * FS), BTN_H, "Search", self, self.onBrowseSearch)
    searchBtn:initialise()
    searchBtn:instantiate()
    panel:addChild(searchBtn)

    y = y + BTN_H + PAD

    -- Listings list
    self._browseList = ISScrollingListBox:new(PAD, y, w - PAD * 2, h - y - BTN_H - PAD * 3)
    self._browseList:initialise()
    self._browseList:instantiate()
    self._browseList.itemheight = ROW_H + math.floor(4 * FS)
    self._browseList.selected = 0
    self._browseList.font = UIFont.NewSmall
    self._browseList.drawBorder = true
    self._browseList.doDrawItem = self.drawBrowseItem
    self._browseList.drawItem = self.drawBrowseItem
    panel:addChild(self._browseList)

    -- Buy Now button
    local btnW = math.floor(120 * FS)
    self._buyBtn = ISButton:new(w - PAD - btnW, h - BTN_H - PAD, btnW, BTN_H, "Buy Now", self, self.onBuyNow)
    self._buyBtn:initialise()
    self._buyBtn:instantiate()
    self._buyBtn:setEnable(false)
    panel:addChild(self._buyBtn)

    -- Status label
    self._browseStatus = ISLabel:new(PAD, h - BTN_H - PAD, BTN_H, "", 0.7, 0.7, 0.7, 1, UIFont.Small, true)
    self._browseStatus:initialise()
    panel:addChild(self._browseStatus)

    return panel
end

function AuctionUI.drawBrowseItem(self, y, item, alt)
    local listing = item.item
    if not listing then return y + self.itemheight end

    local x = 4
    local w = self.width - 8

    -- Zebra
    if alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.08, 1, 1, 1)
    end

    -- Selected highlight
    if item.index == self.selected then
        self:drawRect(0, y, self.width, self.itemheight, 0.2, 0.4, 0.6, 1)
    end

    local textY = y + math.floor((self.itemheight - FONT_SM) / 2)

    -- Item name
    self:drawText(listing.itemName or "?", x, textY, 1, 1, 1, 1, UIFont.NewSmall)

    -- Price (right-aligned)
    local priceStr = formatPrice(listing.price)
    local priceW = getTextManager():MeasureStringX(UIFont.NewSmall, priceStr)
    self:drawText(priceStr, w - priceW - math.floor(80 * FS), textY, 0.8, 1, 0.6, 1, UIFont.NewSmall)

    -- Time remaining
    local timeStr = formatTimeRemaining(listing.expiresAge)
    local timeW = getTextManager():MeasureStringX(UIFont.NewSmall, timeStr)
    self:drawText(timeStr, w - timeW, textY, 0.6, 0.6, 0.6, 1, UIFont.NewSmall)

    -- Seller (mid-area)
    local sellerStr = listing.sellerChar or listing.seller or ""
    local nameW = getTextManager():MeasureStringX(UIFont.NewSmall, listing.itemName or "?")
    local sellerX = x + nameW + math.floor(20 * FS)
    self:drawText(sellerStr, sellerX, textY, 0.5, 0.5, 0.5, 1, UIFont.NewSmall)

    return y + self.itemheight
end

function AuctionUI:onBrowseSearch()
    local search = self._browseSearch:getText()
    local poolIdx = self._browsePool.selected
    local poolData = self._browsePool.options and self._browsePool.options[poolIdx]
    local pool = poolData and poolData.data or nil

    local filters = {}
    if search and search ~= "" then
        filters.search = search
    end
    if pool then
        filters.pool = pool
    end
    sendAHCommand(Core.commands.ahBrowse, filters, self.player)
end

function AuctionUI:onBuyNow()
    local sel = self._browseList.selected
    if sel < 1 then return end
    local item = self._browseList.items[sel]
    if not item or not item.item then return end
    local listing = item.item

    sendAHCommand(Core.commands.ahBuyNow, { listingId = listing.id }, self.player)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Sell tab
-- ─────────────────────────────────────────────────────────────────────────────

function AuctionUI:createSellTab(w, h)
    local panel = ISPanel:new(0, 0, w, h)
    panel:initialise()
    panel:instantiate()

    local y = PAD
    local labelW = math.floor(80 * FS)

    -- Item selection (text entry for item type — will be enhanced later)
    local itemLbl = ISLabel:new(PAD, y, BTN_H, "Item:", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    itemLbl:initialise()
    panel:addChild(itemLbl)

    self._sellItemEntry = ISTextEntryBox:new("", PAD + labelW, y, math.floor(250 * FS), BTN_H)
    self._sellItemEntry:initialise()
    self._sellItemEntry:instantiate()
    self._sellItemEntry.tooltip = "Full item type (e.g. Base.Axe)"
    panel:addChild(self._sellItemEntry)

    -- Pick from inventory button
    local pickBtn = ISButton:new(PAD + labelW + math.floor(260 * FS), y, math.floor(100 * FS), BTN_H, "Inventory...", self, self.onPickFromInventory)
    pickBtn:initialise()
    pickBtn:instantiate()
    panel:addChild(pickBtn)

    y = y + BTN_H + PAD

    -- Pool selector
    local poolLbl = ISLabel:new(PAD, y, BTN_H, "Pool:", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    poolLbl:initialise()
    panel:addChild(poolLbl)

    self._sellPool = ISComboBox:new(PAD + labelW, y, math.floor(120 * FS), BTN_H, self, nil)
    self._sellPool:initialise()
    self._sellPool:addOptionWithData("Change", "change")
    self._sellPool:addOptionWithData("Tokens", "tokens")
    panel:addChild(self._sellPool)

    -- Amount
    local amtLbl = ISLabel:new(PAD + labelW + math.floor(140 * FS), y, BTN_H, "Price:", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    amtLbl:initialise()
    panel:addChild(amtLbl)

    self._sellAmount = ISTextEntryBox:new("", PAD + labelW + math.floor(200 * FS), y, math.floor(80 * FS), BTN_H)
    self._sellAmount:initialise()
    self._sellAmount:instantiate()
    self._sellAmount:setOnlyNumbers(true)
    panel:addChild(self._sellAmount)

    y = y + BTN_H + PAD

    -- Fee display
    self._sellFeeLabel = ISLabel:new(PAD, y, BTN_H, "Fee: " .. AH.getFeePercent() .. "% of sale", 0.6, 0.6, 0.6, 1, UIFont.Small, true)
    self._sellFeeLabel:initialise()
    panel:addChild(self._sellFeeLabel)

    -- List Item button
    local listBtn = ISButton:new(w - PAD - math.floor(120 * FS), y, math.floor(120 * FS), BTN_H, "List Item", self, self.onCreateListing)
    listBtn:initialise()
    listBtn:instantiate()
    panel:addChild(listBtn)

    y = y + BTN_H + PAD * 2

    -- My Listings header
    local myLbl = ISLabel:new(PAD, y, FONT_MD, "My Listings", 1, 1, 1, 1, UIFont.Medium, true)
    myLbl:initialise()
    panel:addChild(myLbl)

    y = y + FONT_MD + PAD

    -- My listings list
    self._myListingsList = ISScrollingListBox:new(PAD, y, w - PAD * 2, h - y - BTN_H - PAD * 2)
    self._myListingsList:initialise()
    self._myListingsList:instantiate()
    self._myListingsList.itemheight = ROW_H + math.floor(4 * FS)
    self._myListingsList.selected = 0
    self._myListingsList.font = UIFont.NewSmall
    self._myListingsList.drawBorder = true
    self._myListingsList.doDrawItem = self.drawMyListingItem
    self._myListingsList.drawItem = self.drawMyListingItem
    panel:addChild(self._myListingsList)

    -- Cancel button
    local cancelBtn = ISButton:new(w - PAD - math.floor(100 * FS), h - BTN_H - PAD, math.floor(100 * FS), BTN_H, "Cancel", self, self.onCancelListing)
    cancelBtn:initialise()
    cancelBtn:instantiate()
    panel:addChild(cancelBtn)

    return panel
end

function AuctionUI.drawMyListingItem(self, y, item, alt)
    local listing = item.item
    if not listing then return y + self.itemheight end

    local x = 4
    local w = self.width - 8

    if alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.08, 1, 1, 1)
    end
    if item.index == self.selected then
        self:drawRect(0, y, self.width, self.itemheight, 0.2, 0.4, 0.6, 1)
    end

    local textY = y + math.floor((self.itemheight - FONT_SM) / 2)

    -- Status color
    local sr, sg, sb = 0.6, 0.6, 0.6
    if listing.status == "ACTIVE" then sr, sg, sb = 0.4, 1, 0.4
    elseif listing.status == "SOLD" then sr, sg, sb = 1, 0.8, 0.2
    elseif listing.status == "EXPIRED" then sr, sg, sb = 1, 0.4, 0.4
    end

    -- Item name
    self:drawText(listing.itemName or "?", x, textY, 1, 1, 1, 1, UIFont.NewSmall)

    -- Price
    local priceStr = formatPrice(listing.price)
    local nameW = getTextManager():MeasureStringX(UIFont.NewSmall, listing.itemName or "?")
    self:drawText(priceStr, x + nameW + math.floor(20 * FS), textY, 0.8, 1, 0.6, 1, UIFont.NewSmall)

    -- Status
    local statusStr = listing.status or "?"
    local statusW = getTextManager():MeasureStringX(UIFont.NewSmall, statusStr)
    self:drawText(statusStr, w - statusW, textY, sr, sg, sb, 1, UIFont.NewSmall)

    return y + self.itemheight
end

function AuctionUI:onPickFromInventory()
    -- Build a list of listable items from the player's inventory
    local inv = self.player:getInventory()
    local items = inv:getItems()
    local seen = {}
    local options = {}
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local ft = item:getFullType()
        if AH.isListableItem(ft) and not seen[ft] then
            seen[ft] = true
            table.insert(options, { fullType = ft, name = item:getDisplayName() })
        end
    end
    table.sort(options, function(a, b) return a.name < b.name end)

    -- Simple approach: open a context menu with the items
    local ctx = ISContextMenu.get(self.player:getPlayerNum(), getMouseX(), getMouseY())
    for _, opt in ipairs(options) do
        ctx:addOption(opt.name, self, function(target)
            target._sellItemEntry:setText(opt.fullType)
        end)
    end
end

function AuctionUI:onCreateListing()
    local itemType = self._sellItemEntry:getText()
    if not itemType or itemType == "" then return end

    local poolIdx = self._sellPool.selected
    local poolData = self._sellPool.options and self._sellPool.options[poolIdx]
    local pool = poolData and poolData.data or "change"

    local amountStr = self._sellAmount:getText()
    local amount = tonumber(amountStr)
    if not amount or amount < 1 then return end

    sendAHCommand(Core.commands.ahCreateListing, {
        item = itemType,
        price = {
            kind = "currency",
            pool = pool,
            amount = math.floor(amount)
        }
    }, self.player)

    -- Clear fields
    self._sellItemEntry:setText("")
    self._sellAmount:setText("")
end

function AuctionUI:onCancelListing()
    local sel = self._myListingsList.selected
    if sel < 1 then return end
    local item = self._myListingsList.items[sel]
    if not item or not item.item then return end
    local listing = item.item
    if listing.status ~= "ACTIVE" then return end

    sendAHCommand(Core.commands.ahCancel, { listingId = listing.id }, self.player)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Collection tab
-- ─────────────────────────────────────────────────────────────────────────────

function AuctionUI:createCollectTab(w, h)
    local panel = ISPanel:new(0, 0, w, h)
    panel:initialise()
    panel:instantiate()

    local y = PAD

    -- Items list
    local itemsLbl = ISLabel:new(PAD, y, FONT_MD, "Pending Items & Credits", 1, 1, 1, 1, UIFont.Medium, true)
    itemsLbl:initialise()
    panel:addChild(itemsLbl)

    y = y + FONT_MD + PAD

    self._collectList = ISScrollingListBox:new(PAD, y, w - PAD * 2, h - y - BTN_H - PAD * 3)
    self._collectList:initialise()
    self._collectList:instantiate()
    self._collectList.itemheight = ROW_H + math.floor(4 * FS)
    self._collectList.selected = 0
    self._collectList.font = UIFont.NewSmall
    self._collectList.drawBorder = true
    self._collectList.doDrawItem = self.drawCollectItem
    self._collectList.drawItem = self.drawCollectItem
    panel:addChild(self._collectList)

    -- Collect All button
    local btnW = math.floor(120 * FS)
    self._collectAllBtn = ISButton:new(w - PAD - btnW, h - BTN_H - PAD, btnW, BTN_H, "Collect All", self, self.onCollectAll)
    self._collectAllBtn:initialise()
    self._collectAllBtn:instantiate()
    panel:addChild(self._collectAllBtn)

    -- Refresh button
    local refreshBtn = ISButton:new(w - PAD - btnW - PAD - math.floor(80 * FS), h - BTN_H - PAD, math.floor(80 * FS), BTN_H, "Refresh", self, self.onRefreshCollection)
    refreshBtn:initialise()
    refreshBtn:instantiate()
    panel:addChild(refreshBtn)

    return panel
end

function AuctionUI.drawCollectItem(self, y, item, alt)
    local entry = item.item
    if not entry then return y + self.itemheight end

    local x = 4
    if alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.08, 1, 1, 1)
    end

    local textY = y + math.floor((self.itemheight - FONT_SM) / 2)

    if entry.entryType == "item" then
        local name = entry.item or "?"
        -- Try to get display name from script manager
        local script = getScriptManager():getItem(entry.item)
        if script then
            name = script:getDisplayName() or name
        end
        self:drawText(name, x, textY, 1, 1, 1, 1, UIFont.NewSmall)
        local reasonStr = "(" .. (entry.reason or "?") .. ")"
        local nameW = getTextManager():MeasureStringX(UIFont.NewSmall, name)
        self:drawText(reasonStr, x + nameW + 10, textY, 0.5, 0.5, 0.5, 1, UIFont.NewSmall)
    elseif entry.entryType == "credit" then
        local amt = entry.amount or 0
        local pool = entry.pool or "?"
        local text
        if pool == "change" then
            if amt % 100 == 0 then
                text = "$" .. tostring(amt / 100)
            else
                text = string.format("$%.2f", amt / 100)
            end
        else
            text = tostring(amt) .. " " .. pool
        end
        self:drawText(text, x, textY, 0.8, 1, 0.6, 1, UIFont.NewSmall)
        local reasonStr = "(" .. (entry.reason or "?") .. ")"
        local textW = getTextManager():MeasureStringX(UIFont.NewSmall, text)
        self:drawText(reasonStr, x + textW + 10, textY, 0.5, 0.5, 0.5, 1, UIFont.NewSmall)
    end

    return y + self.itemheight
end

function AuctionUI:onCollectAll()
    sendAHCommand(Core.commands.ahCollect, {}, self.player)
end

function AuctionUI:onRefreshCollection()
    sendAHCommand(Core.commands.ahGetCollection, {}, self.player)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Data update methods (called by event handlers)
-- ─────────────────────────────────────────────────────────────────────────────

function AuctionUI:setData(data)
    if data.listings then
        self._browseListings = data.listings
        self._browseTotal = data.total or #data.listings
        self._browsePage = data.page or 1
    end
    if data.myListings then
        self._myListings = data.myListings
    end
    if data.collection then
        self._collection = data.collection
    end
    self:populateBrowseList()
    self:populateMyListings()
    self:populateCollectionList()
end

function AuctionUI:refreshData(args)
    -- Triggered by OnAHListingUpdate
    if args.listing then
        -- Re-fetch browse data
        self:onBrowseSearch()
    end
    if args.myListings then
        self._myListings = args.myListings
        self:populateMyListings()
    end
    if args.collection then
        self._collection = args.collection
        self:populateCollectionList()
    end
end

function AuctionUI:refreshCollection(args)
    if args.collection then
        self._collection = args.collection
        self:populateCollectionList()
    end
end

function AuctionUI:populateBrowseList()
    self._browseList:clear()
    for _, listing in ipairs(self._browseListings) do
        self._browseList:addItem(listing.itemName or listing.item or "?", listing)
    end
    -- Update status
    self._browseStatus:setName(tostring(self._browseTotal) .. " listings")
    -- Update buy button
    self._buyBtn:setEnable(self._browseList.selected > 0)
end

function AuctionUI:populateMyListings()
    self._myListingsList:clear()
    for _, listing in ipairs(self._myListings) do
        self._myListingsList:addItem(listing.itemName or listing.item or "?", listing)
    end
end

function AuctionUI:populateCollectionList()
    self._collectList:clear()
    local c = self._collection
    if c.items then
        for _, entry in ipairs(c.items) do
            entry.entryType = "item"
            self._collectList:addItem(entry.item or "?", entry)
        end
    end
    if c.credits then
        for _, entry in ipairs(c.credits) do
            entry.entryType = "credit"
            local label = tostring(entry.amount or 0) .. " " .. (entry.pool or "?")
            self._collectList:addItem(label, entry)
        end
    end
    -- Enable/disable collect button
    local hasItems = c.items and #c.items > 0
    local hasCredits = c.credits and #c.credits > 0
    self._collectAllBtn:setEnable(hasItems or hasCredits)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Update: handle selection changes for Buy button
-- ─────────────────────────────────────────────────────────────────────────────

function AuctionUI:update()
    ISCollapsableWindowJoypad.update(self)
    if self._browseList then
        self._buyBtn:setEnable(self._browseList.selected > 0)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Key handling
-- ─────────────────────────────────────────────────────────────────────────────

function AuctionUI:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:setVisible(false)
        return true
    end
    return ISCollapsableWindowJoypad.onKeyRelease(self, key)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Close handler
-- ─────────────────────────────────────────────────────────────────────────────

function AuctionUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    M.instance = nil
end
