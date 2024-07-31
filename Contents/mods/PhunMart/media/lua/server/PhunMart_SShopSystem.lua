-- ***********************************************************
-- **                    THE INDIE STONE                    **
-- ***********************************************************
if isClient() then
    return
end
local PM = PhunMart
require "Map/SGlobalObjectSystem"
SPhunMartSystem = SGlobalObjectSystem:derive("SPhunMartSystem")

function SPhunMartSystem:new()
    local o = SGlobalObjectSystem.new(self, "phunmart")
    return o
end

function SPhunMartSystem.addToWorld(square, shop, direction)

    print("SPhunMartSystem.addToWorld ", tostring(square), " t= ", tostring(shop.key), " d=", tostring(direction))
    direction = direction or "south"

    local isoObject

    local sprite = PhunMart.defs.shops[shop.key].sprites[direction]
    print("sprite: ", sprite)

    if not sprite then
        print("no sprite for ", shop.key, " ", direction)
        return
    end
    isoObject = IsoThumpable.new(square:getCell(), square, sprite, false, {})

    isoObject:setModData({
        shop = shop,
        direction = direction,
        created = getTimestamp(),
        stocked = getGameTime():getWorldAgeHours()
    })

    isoObject:setName("PhunMartShop")
    square:AddSpecialObject(isoObject, -1)
    triggerEvent("OnObjectAdded", isoObject)
    isoObject:transmitCompleteItemToClients()
end

function SPhunMartSystem:initSystem()

    SGlobalObjectSystem.initSystem(self)
    self.system:setModDataKeys({})
    self.system:setObjectModDataKeys({})

end

function SPhunMartSystem:isValidModData(modData)
    return modData and modData.restocked
end

function SPhunMartSystem:newLuaObject(globalObject)
    return SPhunMartObject:new(self, globalObject)
end

function SPhunMartSystem:generateRandomShopOnSquare(square, direction, removeOnSuccess)
    direction = direction or "south"
    print("===============> SPhunMartSystem:generateRandomShopOnSquare ", tostring(square), " d=", tostring(direction))

    local shop = PM:getFormattedShop(square)
    if shop ~= nil then
        square:transmitRemoveItemFromSquare(removeOnSuccess)
        self.addToWorld(square, shop, direction)
    end

end

function SPhunMartSystem:autoReplaceSquare(shopType, shopDirection, square)
    print("===============> SPhunMartSystem:autoReplaceSquare")
    local cell = getWorld():getCell()
    for i = 1, cell:getObjects():size() do
        local obj = cell:getObjects():get(i - 1)
        if instanceof(obj, "IsoThumpable") and obj:getName() == "VendingMachine" then
            local square = obj:getSquare()
            SPhunMartSystem.addToWorld(square, "goodPhoods", "south", i - 1)
            obj:removeFromSquare()
        end
    end
end

function SPhunMartSystem:newLuaObjectAt(x, y, z)
    print("===============> SPhunMartSystem:newLuaObjectAt", tostring(x), tostring(y), tostring(z))
    self:noise("adding luaObject " .. x .. ',' .. y .. ',' .. z)
    local globalObject = self.system:newObject(x, y, z)
    -- local nl = self.processNewLua
    -- nl:addItem(x, y, z)
    return self:newLuaObject(globalObject)
end

function SPhunMartSystem:isValidIsoObject(isoObject)
    return instanceof(isoObject, "IsoThumpable") and isoObject:getName() == "PhunMartShop"
end

function SPhunMartSystem:receiveCommand(playerObj, command, args)
    print("SPhunMartSystem:receiveCommand ", tostring(playerObj), " c= ", tostring(command), " a=", tostring(args))
    SPhunMartServerCommands[command](playerObj, args)
end

SGlobalObjectSystem.RegisterSystemClass(SPhunMartSystem)

