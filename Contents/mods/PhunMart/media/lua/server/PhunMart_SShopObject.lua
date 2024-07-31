if isClient() then
    return
end

require "Map/SGlobalObject"

SPhunMartObject = SGlobalObject:derive("SPhunMartObject")

function SPhunMartObject:new(luaSystem, globalObject)
    print("=======SPhunMartObject:new ", tostring(self))
    local o = SGlobalObject.new(self, luaSystem, globalObject)
    return o
end

function SPhunMartObject:initNew()
    print("SPhunMartObject:initNew")
end

function SPhunMartObject.initModData(modData)
    print("SPhunMartObject.initModData")
    self.doRestock = false
    modData.doRestock = false
end

function SPhunMartObject:stateFromIsoObject(isoObject)
    print("SPhunMartObject:stateFromIsoObject")
    print("Do we determine the shop type from here?")
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
    self.shop = modData.shop
    self.direction = modData.direction
    self.created = modData.created
    self.stocked = modData.stocked
    self.doRestock = modData.doRestock
end

function SPhunMartObject:toModData(modData)
    print("SPhunMartObject:toModData")
    modData.shop = self.shop
    modData.direction = self.direction
    modData.created = self.created
    modData.stocked = self.stocked
    modData.doRestock = self.doRestock
end

function SPhunMartObject:adjustInventory(itemKey, count)

    print("SPhunMartObject:toModData")
    modData.shop = self.shop
    modData.direction = self.direction
    modData.created = self.created
    modData.stocked = self.stocked
    modData.doRestock = self.doRestock
end

