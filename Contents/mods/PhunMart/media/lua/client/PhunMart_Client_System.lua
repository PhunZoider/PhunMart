local PM = PhunMart
CPhunMartSystem = CGlobalObjectSystem:derive("CPhunMartSystem")

function CPhunMartSystem:new()
    print("CPhunMartSystem:new ---->")
    local o = CGlobalObjectSystem.new(self, "phunmart")
    return o
end

function CPhunMartSystem:isValidIsoObject(isoObject)
    return instanceof(isoObject, "IsoThumpable") and isoObject:getName() == "PhunMartShop"
end

function CPhunMartSystem:newLuaObject(globalObject)
    print("CPhunMartSystem:newLuaObject")
    local o = CPhunMartObject:new(self, globalObject)
    return o
end

function CPhunMartSystem:requestLock(obj, playerObj)
    print("CPhunMartSystem:requestLock")
    obj:updateFromIsoObject()
    self:sendCommand(playerObj or getSpecificPlayer(0), PM.commands.requestLock, {
        id = obj.id,
        location = obj.location
    })
end

function CPhunMartSystem:requestPurchase(obj, itemId, playerObj)
    print("CPhunMartSystem:requestPurchase")
    self:sendCommand(playerObj, PM.commands.buy, {
        shopId = obj.id,
        itemId = itemId,
        location = obj.location
    })
end

function CPhunMartSystem:restock(shop, playerObj)
    print("CPhunMartSystem:restock")
    self:sendCommand(playerObj or getSpecificPlayer(0), PM.commands.restock, {
        shopId = shop.id,
        location = shop.location
    })
end

function CPhunMartSystem:reroll(shop, target, playerObj)
    print("CPhunMartSystem:reroll")
    self:sendCommand(playerObj or getSpecificPlayer(0), PM.commands.requestShopGenerate, {
        shopId = shop.id,
        target = target,
        location = shop.location
    })
end

function CPhunMartSystem:close(shop, playerObj)
    self:sendCommand(playerObj or getSpecificPlayer(0), PM.commands.closeShop, {
        shopId = shop.id,
        location = shop.location
    })
end

function CPhunMartSystem:updateShop(location)
    print("CPhunMartSystem:updateShop")
    local obj = self:getLuaObjectAt(location.x, location.y, location.z)
    obj:updateFromIsoObject()
end

function CPhunMartSystem:OnServerCommand(command, args)
    print("CPhunMartSystem:OnServerCommand")
    if CPhunMartCommands[command] then
        CPhunMartCommands[command](args)
    end
end

CGlobalObjectSystem.RegisterSystemClass(CPhunMartSystem)

local function DoSpecialTooltip1(tooltip, square)

    local playerObj = getSpecificPlayer(0)
    local layout = tooltip:beginLayout()
    tooltip:DrawTextCentre(tooltip:getFont(), "Frank", tooltip:getWidth() / 2, 5, 1, 1, 1, 1)
    tooltip:adjustWidth(5, "Frank")
    local y = layout:render(5, 5 + getTextManager():getFontHeight(tooltip:getFont()), tooltip)
    tooltip:setHeight(y + 5)
    tooltip:endLayout(layout)
end

local function DoSpecialTooltip(tooltip, square)
    tooltip:setWidth(100)
    tooltip:setMeasureOnly(true)
    DoSpecialTooltip1(tooltip, square)
    tooltip:setMeasureOnly(false)
    DoSpecialTooltip1(tooltip, square)
end

Events.DoSpecialTooltip.Add(DoSpecialTooltip)

local _lastHighlighted = nil

Events.OnObjectLeftMouseButtonUp.Add(function(object, x, y)
    if _lastHighlighted then
        _lastHighlighted:setHighlighted(false, false);
    end
    print(tostring(object), " ", object:getName())
    if object and CPhunMartSystem:isValidIsoObject(object) then
        object:setHighlighted(true, false);
        _lastHighlighted = object
        local hasModData = object:getModData()
    end
end)

Events.OnObjectRightMouseButtonUp.Add(function(object, x, y)
    if _lastHighlighted then
        _lastHighlighted:setHighlighted(false, false);
    end
    if object and CPhunMartSystem:isValidIsoObject(object) then
        object:setHighlighted(true, false);
        _lastHighlighted = object
    end
end)
