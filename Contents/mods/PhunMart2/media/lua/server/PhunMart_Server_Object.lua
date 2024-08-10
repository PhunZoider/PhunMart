if not isServer() then
    return
end

require "Map/SGlobalObject"

SPhunMartObject = SGlobalObject:derive("SPhunMartObject")
local PM = PhunMart

local fields = {
    id = {
        type = "string",
        default = "0_0_0"
    },
    key = {
        type = "string",
        default = "default"
    },
    label = {
        type = "string",
        default = "PhunMart"
    },
    direction = {
        type = "string",
        default = "south"
    },
    lockedBy = {
        type = "string",
        default = nil
    },
    lastRestock = {
        type = "number",
        default = 0
    },
    backgroundImage = {
        type = "string",
        default = "machine-none.png"
    },
    layout = {
        type = "string",
        default = "default"
    },
    requiresPower = {
        type = "boolean",
        default = false
    },
    currency = {
        type = "string",
        default = "Base.Money"
    },
    basePrice = {
        type = "number",
        default = 0
    },
    type = {
        type = "string",
        default = ""
    },
    location = {
        type = "table",
        default = {
            x = 0,
            y = 0,
            z = 0
        }
    },
    tabs = {
        type = "table",
        default = {}
    },
    items = {
        type = "table",
        default = {}
    },
    sprites = {
        type = "table",
        default = {
            sheet = 1,
            row = 1
        }
    }
}

function SPhunMartObject:new(luaSystem, globalObject)
    local o = SGlobalObject.new(self, luaSystem, globalObject)
    return o
end

function SPhunMartObject:initNew()
    for k, v in pairs(fields) do
        self[k] = v.default
    end
end

function SPhunMartObject.initModData(modData)
    for k, v in pairs(fields) do
        if modData[k] == nil and self[k] == nil then
            modData[k] = v.default
        end
    end
end

function SPhunMartObject:stateFromIsoObject(isoObject)
    self:initNew()
    self:fromModData(isoObject:getModData())

    local square = isoObject:getSquare()

    self:changeSprite()

    self:toModData(isoObject:getModData())
    isoObject:transmitModData()
end

function SPhunMartObject:getObject()
    return self:getIsoObject()
end

function SPhunMartObject:stateToIsoObject(isoObject)
    self:toModData(isoObject:getModData())
    self:changeSprite()
    isoObject:transmitModData()
end

function SPhunMartObject:unlock()
    self.lockedBy = false
    self:saveData()
    SPhunMartSystem.instance:removeShopIdLockData(self)
end

function SPhunMartObject:lock(player)
    self.lockedBy = player:getUsername()
    self:saveData()
end

function SPhunMartObject:render(x, y, z, square)
    SGlobalObject:render(self, x, y, z, square)
end

function SPhunMartObject:changeSprite()

    local isoObject = self:getIsoObject()
    if not isoObject then
        return
    end

    local def = PM.defs.shops[self.key]
    local hasPower = true
    if self.requiresPower then
        hasPower = self:getSquare():haveElectricity()
        if not hasPower then
            hasPower = SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() <
                           SandboxVars.ElecShutModifier
        end
    end
    local spriteName = PM:resolveSprite(def.sprites.sheet, def.sprites.row, self.direction, hasPower == false)

    if spriteName and (not isoObject:getSprite() or spriteName ~= isoObject:getSprite():getName()) then
        print("SPhunMartObject:changeSprite ", tostring(self.key), tostring(self.direction), " has power=",
            tostring(hasPower), " sprite=", tostring(spriteName))

        self:noise('sprite changed to ' .. spriteName .. ' at ' .. self.x .. ',' .. self.y .. ',' .. self.z)
        isoObject:setSprite(spriteName)
        isoObject:transmitUpdatedSpriteToClients()
    end
end

function SPhunMartObject:saveData()
    local isoObject = self:getIsoObject()
    if isoObject then
        self:toModData(isoObject:getModData())
        isoObject:transmitModData()
    end
end

function SPhunMartObject:fromModData(modData)
    for k, v in pairs(modData) do
        if fields[k] then
            self[k] = fields[k].type == "number" and tonumber(v) or v
        end
    end
end

function SPhunMartObject:toModData(modData)
    for k, v in pairs(fields) do
        modData[k] = self[k]
    end
end

