if isClient() then
    return
end

require "Map/SGlobalObject"
require "PhunMart_Server/system"
local Core = PhunMart
local ServerSystem = Core.ServerSystem
Core.ServerObject = SGlobalObject:derive("SPhunMartObject")
local ServerObject = Core.ServerObject
local GameTime = GameTime
local SandboxVars = SandboxVars

-- -----------------------------
-- buildOffers helpers
-- -----------------------------

-- Return a copy of a compiled price with any {min,max} amounts resolved to concrete numbers.
-- selfItem: the offer's item type, used to resolve price.kind="self"
local function bakePrice(price, selfItem)
    if not price then
        return nil
    end
    if price.kind == "free" then
        return {
            kind = "free"
        }
    end
    -- "self" price: player pays by handing over N of the offer item itself (collector offers).
    -- Bake into a standard items price so canAfford/deduct need no special-casing.
    -- Carries substitutes through so purchasing counts variant items toward the total.
    if price.kind == "self" then
        local amt = price.amount
        local bakedAmt
        if type(amt) == "table" and amt.min and amt.max then
            bakedAmt = amt.min + ZombRand(0, amt.max - amt.min + 1)
        else
            bakedAmt = amt or 1
        end
        local subs = type(price.substitutes) == "table" and price.substitutes or nil
        return {
            kind = "items",
            items = {{
                item = selfItem,
                amount = bakedAmt,
                substitutes = subs
            }},
            selfPay = true -- flag: the price IS the displayed item (collector offer)
        }
    end
    if price.kind == "currency" then
        local amt = price.amount
        local bakedAmt
        if type(amt) == "table" and amt.min and amt.max then
            -- resolve range to a concrete nickel-aligned value at restock time
            local steps = math.floor((amt.max - amt.min) / 5)
            bakedAmt = amt.min + ZombRand(0, steps + 1) * 5
        else
            bakedAmt = amt
        end
        return {
            kind = "currency",
            pool = price.pool,
            amount = bakedAmt
        }
    end
    -- kind = "items"
    local baked = {
        kind = price.kind,
        items = {}
    }
    for _, line in ipairs(price.items or {}) do
        local bl = {
            item = line.item,
            itemAny = line.itemAny,
            substitutes = line.substitutes
        }
        local amt = line.amount
        if type(amt) == "table" then
            bl.amount = ZombRand(amt.min or 1, amt.max or amt.min or 1)
        else
            bl.amount = amt or 1
        end
        table.insert(baked.items, bl)
    end
    return baked
end

-- Roll used when neither the pool set nor the shop names one. Among the shipped
-- shops only PrawnStars relies on it; otherwise it is what an admin-built shop
-- falls back to when they never set a count.
--
-- DefaultNumOfItemsWhenRestocking sets the low end rather than a fixed count.
-- This was hardcoded to a 5 to 8 spread, and a shop stocking exactly N items
-- every single restock reads as broken rather than as configured. At the shipped
-- default of 5 the range comes out 5 to 8, which is what it has always been, so
-- no existing world changes behaviour.
local DEFAULT_ROLL_SPREAD = 3

local function defaultRoll()
    local min = tonumber(Core.getOption("DefaultNumOfItemsWhenRestocking", 5)) or 5
    if min < 1 then
        min = 1
    end
    return {
        mode = "weighted",
        count = {
            min = min,
            max = min + DEFAULT_ROLL_SPREAD
        }
    }
end

-- Weighted random pick without replacement. Returns array of {id, offer, scaledWeight} entries.
-- candidates: array of {id, offer, scaledWeight}
local function weightedPickN(candidates, count)
    local pool = {}
    for _, c in ipairs(candidates) do
        table.insert(pool, { id = c.id, offer = c.offer, scaledWeight = c.scaledWeight })
    end
    local picked = {}
    count = math.min(count, #pool)
    for _ = 1, count do
        if #pool == 0 then
            break
        end
        local total = 0
        for _, entry in ipairs(pool) do
            total = total + entry.scaledWeight
        end
        local r = total > 0 and (ZombRand(math.max(1, math.floor(total * 10000))) / 10000.0) or 0
        local chosenIdx = #pool -- fallback to last
        local cumulative = 0
        for idx, entry in ipairs(pool) do
            cumulative = cumulative + entry.scaledWeight
            if r < cumulative then
                chosenIdx = idx
                break
            end
        end
        table.insert(picked, pool[chosenIdx])
        table.remove(pool, chosenIdx)
    end
    return picked
end

-- all valid property and default values
local fields = {
    type = {
        -- a unique key to identify this shop type (eg shop-good-phoods)
        type = "string",
        default = "default"
    },
    created = {
        -- what hour this shop was created
        type = "numberToTens",
        default = 0
    },
    facing = {
        -- which way the shop is facing
        type = "string",
        default = "E"
    },
    lastRestock = {
        -- what hour this shop was last restocked
        type = "numberToTens",
        default = 0
    },
    lastReroll = {
        -- what hour this machine last considered becoming a different shop.
        -- Stamped even when it stayed as it was, so a machine with no other
        -- option at its location does not re-run the search every tick.
        -- Absent on machines placed before rerolling existed; treated as the
        -- creation hour, which starts them on a full cycle rather than firing
        -- the moment the setting is switched on.
        type = "numberToTens",
        default = 0
    },
    powered = {
        -- whether this shop currently has power (if required)
        type = "bool",
        default = false
    },
    x = {
        -- x position of the shop
        type = "number",
        default = 0
    },
    y = {
        -- y position of the shop
        type = "number",
        default = 0
    },
    z = {
        -- z position of the shop
        type = "number",
        default = 0
    },
    offers = {
        -- compiled offer table for this instance, built from Core.runtime on restock
        type = "array",
        default = {}
    }

}

-- Returns false if the pool's zone.difficulty restriction excludes the given location.
-- Permissive: no zones config, no PhunZones mod, or unzoned location all pass.
-- Exposed on Core so system.lua can use it at placement time.
local PZ = nil

local function poolPassesZoneFilter(pool, x, y)
    local zones = pool.zones
    if not zones or not zones.difficulty then
        return true
    end
    if PZ == nil then
        PZ = PhunZones or false
    end
    if not PZ then
        return true
    end
    -- Dot, not colon. PhunZones 2 declares this as "function Core.getLocation"
    -- and closes over Core itself rather than taking self. PhunZones 1 used a
    -- colon, so a copy of that version on disk will suggest otherwise; the mod
    -- this integrates with is phunzones2, which pool_restock.lua checks by name.
    local loc = PZ.getLocation(x, y)
    local difficulty = loc and loc.difficulty
    if difficulty == nil then
        return true
    end
    for _, d in ipairs(zones.difficulty) do
        if d == difficulty then
            return true
        end
    end
    return false
end
Core.poolPassesZoneFilter = poolPassesZoneFilter

-- Returns false if the pool is gated to certain months and the in-game calendar
-- is not in one of them, so a seasonal pool follows the world's clock rather
-- than the machine's. The parts worth getting right (the 1-12 space, and
-- GameTime counting months from zero) live in utils, where the tests can reach
-- them; this is only the join.
--
-- Note this is consulted while building offers and nowhere else. A shop that
-- restocks monthly will carry December's stock a little way into January, until
-- its next restock clears it out. That granularity is the restock interval.
local function poolPassesMonthFilter(pool)
    return Core.utils.poolInSeason(pool, Core.utils.currentGameMonth())
end
Core.poolPassesMonthFilter = poolPassesMonthFilter

-- Build self.offers from Core.runtime for this shop's type.
-- Called on first load (if offers absent) and on every restock.
-- Each restock bakes concrete price amounts and stock quantities from their configured ranges.
function ServerObject:buildOffers()
    local offers = {}
    if not Core.runtime then
        Core.debugLn("buildOffers: no compiled runtime, call Core.compile() first")
        self.offers = offers
        return
    end
    local c = Core
    local shopDef = Core.runtime.shops and Core.runtime.shops[self.type]
    if not shopDef then
        Core.debugLn("buildOffers: no runtime shop def for type '" .. tostring(self.type) .. "'")
        self.offers = offers
        return
    end

    -- resolve count: number | {min,max} | nil → default 5
    local function resolveCount(countCfg, fallback)
        if type(countCfg) == "table" and countCfg.min then
            return ZombRand(countCfg.min, countCfg.max or countCfg.min)
        elseif type(countCfg) == "number" then
            return countCfg
        end
        return fallback
    end

    local excluded = (Core.getBlacklist().items or {}).exclude or {}

    for _, poolSet in ipairs(shopDef.poolSets or {}) do
        -- Resolve roll: poolSet > shop > global default
        local roll = poolSet.roll or shopDef.roll or defaultRoll()
        local mode = roll.mode or "weighted"

        -- Merge candidates from ALL eligible pools in this poolSet.
        -- Pool weight scales offer weights (acts as rarity multiplier between pools).
        -- Sticky pools have all offers included unconditionally; non-sticky pools are rolled.
        local candidates = {}
        local stickyOffers = {}
        local seenItems = {} -- dedup: first occurrence by item key wins

        -- Two passes: sticky pools first so their items always win the dedup,
        -- then non-sticky pools collect rollable candidates from the remainder.
        for pass = 1, 2 do
            local wantSticky = (pass == 1)
            for _, poolRef in ipairs(poolSet.keys or {}) do
                local poolKey = type(poolRef) == "table" and poolRef.key or poolRef
                local poolWeight = type(poolRef) == "table" and poolRef.weight or 1.0
                local pool = Core.runtime.pools and Core.runtime.pools[poolKey]
                if not pool then
                    if pass == 1 then
                        Core.debugLn("buildOffers: pool '" .. tostring(poolKey) .. "' not in runtime")
                    end
                elseif (pool.sticky == true) ~= wantSticky then
                    -- wrong pass; skip
                elseif not poolPassesZoneFilter(pool, self.x, self.y) then
                    -- pool excluded by zone difficulty at this location; skip silently
                elseif not poolPassesMonthFilter(pool) then
                    -- pool out of season this month; skip silently
                else
                    for offerId, offer in pairs(pool.offers or {}) do
                        if not excluded[offer.item] then
                            local itemKey = offer.item
                            if not seenItems[itemKey] then
                                seenItems[itemKey] = true
                                if pool.sticky then
                                    table.insert(stickyOffers, {
                                        id = offerId,
                                        offer = offer
                                    })
                                else
                                    local offerWeight = (offer.offer and offer.offer.weight or 1.0) * poolWeight
                                    table.insert(candidates, {
                                        id = offerId,
                                        offer = offer,
                                        scaledWeight = offerWeight
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Bake sticky offers: always included, unlimited stock
        for _, sel in ipairs(stickyOffers) do
            local offerDef = sel.offer
            local srcOffer = offerDef.offer or {}
            offers[sel.id] = {
                id = offerDef.id,
                item = offerDef.item,
                price = bakePrice(offerDef.price or poolSet.price, offerDef.item),
                reward = offerDef.reward,
                offer = {
                    qty = srcOffer.qty or 1,
                    weight = srcOffer.weight or 1.0,
                    stockQty = -1,
                    restockHours = nil
                },
                conditions = offerDef.conditions,
                meta = offerDef.meta,
                sticky = true
            }
        end

        -- Select which non-sticky offers appear this restock cycle
        local selected
        if mode == "all" then
            selected = candidates
        else -- "weighted" (default): pick N via weighted random without replacement
            local count = resolveCount(roll.count, 5)
            count = math.min(count, #candidates)
            selected = weightedPickN(candidates, count)
        end

        -- Bake each selected offer: resolve price ranges and stock quantities
        for _, sel in ipairs(selected) do
            local offerId = sel.id
            local offerDef = sel.offer
            local srcOffer = offerDef.offer or {}

            -- resolve stock: {min,max} -> concrete qty; absent = unlimited (-1)
            local stockQty, restockHours
            local stock = srcOffer.stock
            if stock then
                local sMin = stock.min or 1
                local sMax = stock.max or sMin
                stockQty = sMin + ZombRand(sMax - sMin + 1) -- inclusive [sMin, sMax]
                restockHours = stock.restockHours
            else
                stockQty = -1
            end

            offers[offerId] = {
                id = offerDef.id,
                item = offerDef.item,
                price = bakePrice(offerDef.price or poolSet.price, offerDef.item), -- poolSet price as fallback
                reward = offerDef.reward,
                offer = {
                    qty = srcOffer.qty or 1, -- items given per purchase
                    weight = srcOffer.weight or 1.0,
                    stockQty = stockQty, -- purchase slots this cycle (-1 = unlimited)
                    restockHours = restockHours
                },
                conditions = offerDef.conditions,
                meta = offerDef.meta
            }
        end
    end
    self.offers = offers
end

function ServerObject:new(luaSystem, globalObject)
    local o = SGlobalObject.new(self, luaSystem, globalObject)
    return o
end

function ServerObject:initNew()
    for k, v in pairs(fields) do
        self[k] = v.default
    end
    self.created = GameTime:getInstance():getWorldAgeHours()
end

function ServerObject:fromModData(modData)
    for k, v in pairs(modData) do
        if fields[k] then
            self[k] = fields[k].type == "number" and tonumber(v) or v
        end
    end
end

function ServerObject:stateFromIsoObject(isoObject)

    self:initNew() -- initialize with default values
    local data = isoObject:getModData()
    -- specify props derived from sprite

    data.type = isoObject:getSprite():getProperties():get("CustomName")
    data.facing = tostring(isoObject:getFacing())
    data.created = data.created or GameTime:getInstance():getWorldAgeHours()
    data.x = isoObject:getX()
    data.y = isoObject:getY()
    data.z = isoObject:getZ()
    self:fromModData(data) -- populate with this objects modData

    -- build offers if not persisted (new machine or first load after upgrade)
    local hasOffers = false
    if type(self.offers) == "table" then
        for _ in pairs(self.offers) do
            hasOffers = true;
            break
        end
    end
    if not hasOffers then
        self:buildOffers()
        self:toModData(data) -- write offers back into modData before transmit
    end

    Core:addInstance(data)

    -- update sprite, forcing re-evaluation so power state and self.powered are synced on load
    self:updateSprite(true)

    -- send data to clients (includes offers)
    isoObject:transmitModData()
end

function ServerObject:stateToIsoObject(isoObject)
    Core.debugLn("stateToIsoObject: self.type=" .. tostring(self.type)
        .. " isoObject=" .. tostring(isoObject ~= nil)
        .. " pos=" .. tostring(self.x) .. "," .. tostring(self.y) .. "," .. tostring(self.z))
    -- For newly created objects the iso object holds the authoritative data
    -- (set by initializeShopObject / the moveable system).  Read it first
    -- so we don't overwrite good data with initNew defaults.
    if not self.type or self.type == "default" then
        self:stateFromIsoObject(isoObject)
        return
    end
    self:toModData(isoObject:getModData())
    self:updateSprite(true)
    isoObject:transmitModData()
end

function ServerObject:getSpriteIndex()
    if self.facing == "E" or self.facing == IsoDirections.E then
        return 1
    elseif self.facing == "S" or self.facing == IsoDirections.S then
        return 2
    elseif self.facing == "W" or self.facing == IsoDirections.W then
        return 3
    else
        return 4
    end
end

--- Whether this machine's square is currently lit.
function ServerObject:hasElectricity()
    return self:getSquare():haveElectricity() or SandboxVars.ElecShutModifier > -1 and
               GameTime:getInstance():getNightsSurvived() < SandboxVars.ElecShutModifier
end

--- Put the machine's face in step with its type, whatever that type now is.
---
--- updateSprite cannot do this job, because neither of its branches is about
--- the type changing. For a shop declaring powered = true it swaps sprites only
--- when the power state moved; for every other shop, which is all sixteen of
--- the shipped ones, it only rescues a machine stuck on an unpowered sprite, by
--- testing the current sprite against the new type's unpowered list. After a
--- reroll the sprite on the machine belongs to the type it just stopped being
--- and appears in nobody's list, so that test finds nothing and the machine
--- keeps the wrong face while selling the new shop's stock.
function ServerObject:applyTypeSprite()
    local isoObject = self:getIsoObject()
    local def = Core.runtime and Core.runtime.shops and Core.runtime.shops[self.type]
    if not isoObject or not def or not def.sprites then
        return false
    end

    local idx = self:getSpriteIndex()
    local sprite = def.sprites[idx]
    if def.powered == true then
        local hasPower = self:hasElectricity()
        self.powered = hasPower
        if not hasPower then
            sprite = (def.unpoweredSprites or {})[idx] or sprite
        end
    end
    if not sprite then
        return false
    end

    isoObject:setSprite(sprite)
    isoObject:transmitUpdatedSpriteToClients()
    return true
end

function ServerObject:updateSprite(force)
    local isoObject = self:getIsoObject()
    if not isoObject then
        return
    end
    local def = Core.runtime and Core.runtime.shops and Core.runtime.shops[self.type]
    if not def then
        return
    end

    if def.powered == true then
        local hasPower = self:hasElectricity()
        -- skip if power state unchanged: avoids redundant setSprite + network transmit on every tick
        if not force and hasPower == self.powered then
            return
        end
        local idx = self:getSpriteIndex()
        if hasPower then
            isoObject:setSprite(def.sprites[idx])
        else
            isoObject:setSprite((def.unpoweredSprites or {})[idx] or def.sprites[idx])
        end
        isoObject:transmitUpdatedSpriteToClients()
        self.powered = hasPower
        self:saveData()
    else
        -- non-powered shop: ensure powered sprite is showing (recovery from bad state)
        local sprite = isoObject:getSprite():getName()
        local unpoweredSet = {}
        for _, s in ipairs(def.unpoweredSprites or {}) do
            unpoweredSet[s] = true
        end
        if unpoweredSet[sprite] then
            isoObject:setSprite(def.sprites[self:getSpriteIndex()])
            isoObject:transmitUpdatedSpriteToClients()
        end
    end
end

function ServerObject:getKey()
    return tostring(self.type) .. "-" .. self.x .. "-" .. self.y .. "-" .. self.z
end

function ServerObject:saveData()
    local isoObject = self:getIsoObject()
    if isoObject then
        self:toModData(isoObject:getModData())
        isoObject:transmitModData()
    end
end

function ServerObject:toModData(modData)
    for k, v in pairs(fields) do
        if self[k] ~= nil then
            if v.type == "number" then
                modData[k] = tonumber(self[k])
            elseif v.type == "numberToTens" then
                modData[k] = tonumber(string.format("%.1f", self[k] or 0))
            elseif v.type == "string" then
                modData[k] = tostring(self[k])
            elseif v.type == "bool" then
                modData[k] = self[k] and true or false
            elseif v.type == "boolOrString" then
                if not self[k] then
                    modData[k] = false
                else
                    modData[k] = self[k]
                end
            elseif v.type == "array" then
                modData[k] = self[k]
            end
        end
    end
end

-- Newest admin-forced restock stamp that applies to this machine: the global
-- one left by Restock All, or a per-type one left by a targeted restock after a
-- definition edit. Returns nil when neither applies.
function ServerObject:forcedRestockStamp()
    local stamps = Core.restockStamps()
    local stamp = stamps.forceRestockAt or 0
    local byType = stamps.forceRestockTypeAt and stamps.forceRestockTypeAt[self.type]
    if byType and byType > stamp then
        stamp = byType
    end
    if stamp > 0 then
        return stamp
    end
    return nil
end

function ServerObject:requiresRestock()
    local shop = Core.runtime.shops and Core.runtime.shops[self.type]
    local frequency = (shop and shop.restockFrequency) or 24
    local now = GameTime:getInstance():getWorldAgeHours()
    if now >= (self.lastRestock or 0) + frequency then
        return true
    end
    -- Check if an admin forced a restock while this chunk was unloaded
    local forced = self:forcedRestockStamp()
    if forced and forced > (self.lastRestock or 0) then
        return true
    end
    return false
end

-- regenerate inventory and persist
function ServerObject:restock()
    local shop = Core.runtime.shops and Core.runtime.shops[self.type]
    local frequency = (shop and shop.restockFrequency) or 24
    local now = GameTime:getInstance():getWorldAgeHours()
    local lastRestock = self.lastRestock or 0
    local times = math.floor((now - lastRestock) / frequency)
    self.lastRestock = lastRestock + (times * frequency)

    -- Admin-forced restock: the grid-aligned lastRestock above can still land
    -- before the forceRestockAt stamp (a shop only 10h into a 24h cycle keeps
    -- lastRestock unchanged), so requiresRestock() would keep firing on every
    -- open. Snap to now so this shop's forced restock counts as serviced. The
    -- global stamp itself must stay set for shops still in unloaded chunks.
    local forced = self:forcedRestockStamp()
    if forced and forced > self.lastRestock then
        self.lastRestock = now
    end

    self:buildOffers()
    self:saveData() -- toModData + transmitModData → engine syncs offers to all clients
end

-- -----------------------------
-- Rerolling: a machine becoming a different shop
--
-- Restocking changes what is on the shelves. Rerolling changes whose shelves
-- they are: the machine picks a new shop type from the ones eligible where it
-- stands, and swaps its sprite and stock to match. Off by default, because a
-- world where the hardware store might be a pharmacy tomorrow is a choice
-- rather than the obvious behaviour.
-- -----------------------------

--- Hours between rerolls, or nil when this machine should never reroll.
--- A shop may set its own `rerollFrequency`, including 0 to opt out of a server
--- default, so a machine meant to be a landmark can stay one.
function ServerObject:rerollFrequency()
    local shop = Core.runtime and Core.runtime.shops and Core.runtime.shops[self.type]
    local hours = shop and shop.rerollFrequency
    if hours == nil then
        hours = Core.getOption("DefaultNumOfHoursToReRoll", 0)
    end
    hours = tonumber(hours) or 0
    if hours > 0 then
        return hours
    end
    return nil
end

--- When the current reroll cycle started. Machines predating this feature have
--- no stamp, so they start from when they were created rather than from hour
--- zero, which would reroll every one of them the moment an admin enables it.
--- Spelled out rather than `self.lastReroll or self.created`: lastReroll is 0
--- rather than nil on those machines, and 0 is truthy.
function ServerObject:rerollClockStart()
    local stamp = tonumber(self.lastReroll) or 0
    if stamp > 0 then
        return stamp
    end
    return tonumber(self.created) or 0
end

function ServerObject:requiresReroll()
    local frequency = self:rerollFrequency()
    if not frequency then
        return false
    end
    local now = GameTime:getInstance():getWorldAgeHours()
    return now >= self:rerollClockStart() + frequency
end

--- Become a different shop, if there is one this location will take.
--- Returns true only when the type actually changed.
function ServerObject:reroll()
    -- Before the stamp, not after. These mean the attempt could not be made at
    -- all rather than that it was made and came to nothing, so stamping here
    -- would push the machine a whole cycle away for a transient failure.
    local system = Core.ServerSystem and Core.ServerSystem.instance
    local isoObject = self:getIsoObject()
    if not system or not isoObject then
        return false
    end

    local now = GameTime:getInstance():getWorldAgeHours()
    -- Stamped whatever happens below. The commonest outcome by far is that no
    -- other shop suits this spot, which will still be true a second from now,
    -- and without a stamp that machine re-runs the whole search every tick for
    -- the rest of the world's life.
    self.lastReroll = now

    -- Out of the running for the pick. This machine stands exactly where the
    -- new shop would go, so counted in the spacing it rules out its own type at
    -- distance zero and everything sharing its category with it. The tile is
    -- being vacated, so it should not be spacing anything out.
    local data = isoObject:getModData()
    local previous = self.type
    local picked = system:getRandomShop(self.x, self.y, data)

    -- Nothing else suits this spot, or the lottery landed on what it already
    -- is. Nothing changes, but the stamp still has to reach modData or it is
    -- lost when the chunk unloads and the search runs again on next load.
    if not picked or picked == previous then
        self:saveData()
        return false
    end

    self.type = picked
    -- The old stock belonged to a shop that is no longer here, so it goes
    -- before anyone can buy from it. The restock clock resets with it: the new
    -- shop deserves a full cycle rather than inheriting a timer about to expire.
    self.lastRestock = now
    self:buildOffers()

    -- applyTypeSprite rather than updateSprite: the thing that changed is the
    -- type, and updateSprite only ever reacts to power. See its comment.
    self:applyTypeSprite()
    self:saveData()

    Core.debugLn("reroll: " .. tostring(previous) .. " -> " .. tostring(picked) .. " at " .. tostring(self.x) .. "," ..
                     tostring(self.y))
    return true
end

function ServerObject:requiresPower()
    local def = Core.runtime and Core.runtime.shops and Core.runtime.shops[self.type]
    if def and def.powered == true then
        return not self:getSquare():haveElectricity() and SandboxVars.ElecShutModifier > -1 and
                   GameTime:getInstance():getNightsSurvived() > SandboxVars.ElecShutModifier
    end
    return false
end

