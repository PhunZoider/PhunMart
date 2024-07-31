if isClient() then
    return
end

require "Map/SGlobalObject"

SPhunMartObject = SGlobalObject:derive("SPhunMartObject")
local PM = PhunMart
local fields = {
    power_required = {
        type = "boolean",
        default = false
    },
    base = {
        type = "string",
        default = "default"
    },
    direction = {
        type = "string",
        default = "south"
    }
}

function SPhunMartObject:new(luaSystem, globalObject)
    print("=======SPhunMartObject:new ", tostring(self))
    local o = SGlobalObject.new(self, luaSystem, globalObject)
    return o
end

function SPhunMartObject:initNew()
    print("SPhunMartObject:initNew")
    for k, v in pairs(fields) do
        self[k] = v.default
    end
end

function SPhunMartObject.initModData(modData)
    PM:debug('SPhunMartObject:stateFromIsoObject', modData)
    for k, v in pairs(fields) do
        if modData[k] == nil and self[k] == nil then
            modData[k] = v.default
        end
    end
end

function SPhunMartObject:stateFromIsoObject(isoObject)
    PM:debug('SPhunMartObject:stateFromIsoObject', isoObject)
    self:initNew()
    self:fromModData(isoObject:getModData())

    local square = isoObject:getSquare()

    self:changeSprite()

    self:toModData(isoObject:getModData())
    isoObject:transmitModData()
end

function SPhunMartObject:getObject()
    print("SPhunMartObject:getObject")
    return self:getIsoObject()
end

function SPhunMartObject:stateToIsoObject(isoObject)
    print("SPhunMartObject:stateToIsoObject")
    self:toModData(isoObject:getModData())
    self:changeSprite()
    isoObject:transmitModData()
end

function SPhunMartObject:changeSprite()
    print("SPhunMartObject:changeSprite")
    local isoObject = self:getIsoObject()
    if not isoObject then
        return
    end

    local spriteName = PhunMart.defs.shops[self.shop.key].sprites[self.shopDirection]

    if spriteName and (not isoObject:getSprite() or spriteName ~= isoObject:getSprite():getName()) then
        self:noise('sprite changed to ' .. spriteName .. ' at ' .. self.x .. ',' .. self.y .. ',' .. self.z)
        isoObject:setSprite(spriteName)
        isoObject:transmitUpdatedSpriteToClients()
    end
end

function SPhunMartObject:saveData()
    print("SPhunMartObject:saveData")
    local isoObject = self:getIsoObject()
    if isoObject then
        self:toModData(isoObject:getModData())
        isoObject:transmitModData()
    end
end

function SPhunMartObject:fromModData(modData)
    print("SPhunMartObject:fromModData")
    for k, v in pairs(modData) do
        if fields[k] then
            self[k] = fields[k].type == "number" and tonumber(v) or v
        end
    end
end

function SPhunMartObject:toModData(modData)
    print("SPhunMartObject:toModData")
    for k, v in pairs(fields) do
        modData[k] = self[k]
    end
end

