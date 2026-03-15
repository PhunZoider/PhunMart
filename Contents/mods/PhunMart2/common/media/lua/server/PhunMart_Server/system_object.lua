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
    if price.kind == "self" then
        local amt = price.amount
        local bakedAmt
        if type(amt) == "table" and amt.min and amt.max then
            bakedAmt = amt.min + ZombRand(0, amt.max - amt.min + 1)
        else
            bakedAmt = amt or 1
        end
        return {
            kind = "items",
            items = {{
                item = selfItem,
                amount = bakedAmt
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
            itemAny = line.itemAny
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

-- Default roll used when neither poolSet nor shop defines one.
local DEFAULT_ROLL = { mode = "weighted", count = { min = 5, max = 8 } }

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
        local roll = poolSet.roll or shopDef.roll or DEFAULT_ROLL
        local mode = roll.mode or "weighted"

        -- Merge candidates from ALL eligible pools in this poolSet.
        -- Pool weight scales offer weights (acts as rarity multiplier between pools).
        local candidates = {}
        local seenItems = {} -- dedup: first occurrence by item key wins (highest scaled weight)

        for _, poolRef in ipairs(poolSet.keys or {}) do
            local poolKey = type(poolRef) == "table" and poolRef.key or poolRef
            local poolWeight = type(poolRef) == "table" and poolRef.weight or 1.0
            local pool = Core.runtime.pools and Core.runtime.pools[poolKey]
            if not pool then
                Core.debugLn("buildOffers: pool '" .. tostring(poolKey) .. "' not in runtime")
            elseif not poolPassesZoneFilter(pool, self.x, self.y) then
                -- pool excluded by zone difficulty at this location; skip silently
            else
                for offerId, offer in pairs(pool.offers or {}) do
                    if not excluded[offer.item] then
                        local offerWeight = (offer.offer and offer.offer.weight or 1.0) * poolWeight
                        local itemKey = offer.item
                        if not seenItems[itemKey] then
                            seenItems[itemKey] = true
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

        -- select which offers appear this restock cycle
        local selected
        if mode == "all" then
            selected = candidates
        else -- "weighted" (default): pick N via weighted random without replacement
            local count = resolveCount(roll.count, 5)
            count = math.min(count, #candidates)
            selected = weightedPickN(candidates, count)
        end

        -- bake each selected offer: resolve price ranges and stock quantities
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
                price = bakePrice(offerDef.price, offerDef.item), -- price amounts resolved from ranges
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
        local hasPower = self:getSquare():haveElectricity() or SandboxVars.ElecShutModifier > -1 and
                             GameTime:getInstance():getNightsSurvived() < SandboxVars.ElecShutModifier
        -- skip if power state unchanged — avoids redundant setSprite + network transmit on every tick
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

function ServerObject:requiresRestock()
    local shop = Core.runtime.shops and Core.runtime.shops[self.type]
    local frequency = (shop and shop.restockFrequency) or 24
    local now = GameTime:getInstance():getWorldAgeHours()
    return now >= (self.lastRestock or 0) + frequency
end

-- regenerate inventory and persist
function ServerObject:restock()
    local shop = Core.runtime.shops and Core.runtime.shops[self.type]
    local frequency = (shop and shop.restockFrequency) or 24
    local now = GameTime:getInstance():getWorldAgeHours()
    local lastRestock = self.lastRestock or 0
    local times = math.floor((now - lastRestock) / frequency)
    self.lastRestock = lastRestock + (times * frequency)
    self:buildOffers()
    self:saveData() -- toModData + transmitModData → engine syncs offers to all clients
end

function ServerObject:requiresPower()
    local def = Core.runtime and Core.runtime.shops and Core.runtime.shops[self.type]
    if def and def.powered == true then
        return not self:getSquare():haveElectricity() and SandboxVars.ElecShutModifier > -1 and
                   GameTime:getInstance():getNightsSurvived() > SandboxVars.ElecShutModifier
    end
    return false
end

