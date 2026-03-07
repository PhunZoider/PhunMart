if isClient() then
    return
end

require "Map/SGlobalObject"
require "PhunMart2/server_system"
local Core = PhunMart
local ServerSystem = Core.ServerSystem
Core.ServerObject = SGlobalObject:derive("SPhunMartObject")
local ServerObject = Core.ServerObject
local GameTime = GameTime
local SandboxVars = SandboxVars

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
    }

}

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

    Core:addInstance(data)

    -- update sprite if needed
    self:updateSprite()

    -- send data to clients 
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
    local shops = Core.shops
    local def = shops[self.type]
    local sprite = isoObject:getSprite():getName()

    if def.powered == true then
        local hasPower = self:getSquare():haveElectricity() or SandboxVars.ElecShutModifier > -1 and
                             GameTime:getInstance():getNightsSurvived() < SandboxVars.ElecShutModifier
        if hasPower and def.unpoweredSprites[sprite] then
            -- sprite is powered and sprite is unpowered so changeSprite
            isoObject:setSprite(def.sprites[self:getSpriteIndex()])
            isoObject:transmitUpdatedSpriteToClients()
        elseif not hasPower and def.sprites[sprite] then
            -- sprite is unpowered and sprite is powered so changeSprite
            isoObject:setSprite(def.unpoweredSprites[self:getSpriteIndex()])
            isoObject:transmitUpdatedSpriteToClients()
        end
    elseif def.unpoweredSprites[sprite] then
        -- sprite is unpowered but def does not require power so changeSprite
        isoObject:setSprite(def.unpoweredSprites[self:getSpriteIndex()])
        isoObject:transmitUpdatedSpriteToClients()
    end
end

function ServerObject:getKey()
    return tostring(self.type) .. "-" .. self.x .. "-" .. self.y .. "-" .. self.z
end

function ServerObject:setType(type)
    -- generate from definitions
    self:changeSprite(true)
    self:saveData()

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
    local shop = Core.shops[self.type]

    local lastRestocked = self.lastRestock or 0
    local frequency = shop.restock or 24
    local now = GameTime:getInstance():getWorldAgeHours()
    local hoursSinceLastRestock = now - lastRestocked
    local times = math.floor(hoursSinceLastRestock / frequency)
    local newRestock = lastRestocked + (times * frequency)
    if now > (lastRestocked * frequency) then
        return false
    end
    return true
end

-- regenerate inventory
function ServerObject:restock()

    local lastRestocked = self.lastRestock or 0
    local frequency = self.restock or 24
    local now = GameTime:getInstance():getWorldAgeHours()
    local hoursSinceLastRestock = now - lastRestocked
    local times = math.floor(hoursSinceLastRestock / frequency)
    local newRestock = lastRestocked + (times * frequency)
    self.lastRestocked = newRestock
    self:saveData()
end

-- check to ensure we are setup correctly and restock if needed
function ServerObject:validate()

end

function ServerObject:requiresPower()
    local c = Core
    local shops = c.shops
    local def = shops[self.type]
    if def.powered == true then
        return not self:getSquare():haveElectricity() and SandboxVars.ElecShutModifier > -1 and
                   GameTime:getInstance():getNightsSurvived() > SandboxVars.ElecShutModifier
    end
    return false
end

function ServerObject:purchase(playerObj, item, qty)

    qty = qty or 1

    if self:requiresPower() then
        return false, "Shop is out of power"
    end

    if not self.items[item] then
        return false, "Shop does not have item"
    end

    if not self.items[item].inventory ~= false then
        if self.items[item].inventory < qty then
            return false, "Shop does not have enough inventory"
        end
    end

    self.items[item].inventory = self.items[item].inventory - qty
    self:saveData()
    return true, "Purchase successful"

end
