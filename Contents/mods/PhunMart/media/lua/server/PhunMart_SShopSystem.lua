-- ***********************************************************
-- **                    THE INDIE STONE                    **
-- ***********************************************************
if isClient() then
    return
end

require "Map/SGlobalObjectSystem"
local sprites = {
    goodPhoods = {
        east = "phunmart_01_0",
        south = "phunmart_01_1"
    }
}

SPhunMartSystem = SGlobalObjectSystem:derive("SPhunMartSystem")

function SPhunMartSystem:new()
    print("----> SPhunMartSystem:new")
    local o = SGlobalObjectSystem.new(self, "phunmart")
    return o
end

function SPhunMartSystem.addToWorld(square, shop, direction)

    print("SPhunMartSystem.addToWorld ", tostring(square), " t= ", tostring(shop.key), " d=", tostring(direction))
    direction = direction or "south"

    local isoObject

    -- PhunTools:printTable(shop)

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
    -- Specify GlobalObjectSystem fields that should be saved.
    self.system:setModDataKeys({})
    -- Specify GlobalObject fields that should be saved.
    self.system:setObjectModDataKeys({'shop', 'created', 'stocked'})

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

    local shop = PhunMart:getFormattedShop(square)
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

function SPhunMartSystem:convertOldModData()
    -- If the gos_xxx.bin file existed, don't touch GameTime modData in case mods are using it.
    print("SPhunMartSystem:convertOldModData")
    -- Global rainbarrel data was never saved anywhere.
    -- Rainbarrels wouldn't update unless they had been loaded in a session.
    --	local modData = GameTime:getInstance():getModData()
end

function SPhunMartSystem:receiveCommand(playerObj, command, args)
    print("SPhunMartSystem:receiveCommand ", tostring(playerObj), " c= ", tostring(command), " a=", tostring(args))
    SPhunMartServerCommands[command](playerObj, args)
end

function SPhunMartSystem:flagForRestocks()

    local refs = {}
    local defs = PhunMart.defs.shops
    for k, v in ipairs(defs) do
        refs[v.key] = v.restock
    end

    local now = getGameTime():getWorldAgeHours()

    for i = 1, self:getLuaObjectCount() do
        local luaObject = self:getLuaObjectByIndex(i)
        if not luaObject.doRestock then
            if (luaObject.stocked or 0) + (refs[luaObject.shop.key] or 0) < now then
                luaObject.doRestock = true
                luaObject:saveData()
            end
        end
    end
end

function SPhunMartSystem:EveryTenMinutes()
    local sec = math.floor(getGameTime():getTimeOfDay() * 3600)
    local currentHour = math.floor(sec / 3600)
    local day = getGameTime():getDay()
end

SGlobalObjectSystem.RegisterSystemClass(SPhunMartSystem)

-- -- -- -- --

local noise = function(msg)
    print("PhunMar noise: " .. msg)
    SPhunMartSystem.instance:noise(msg)
end

-- every 10 minutes we check if it's raining, to fill our water barrel
local function EveryTenMinutes()
    SPhunMartSystem.instance:flagForRestocks()
end

-- every 10 minutes we check if it's raining, to fill our water barrel
Events.EveryTenMinutes.Add(EveryTenMinutes)

