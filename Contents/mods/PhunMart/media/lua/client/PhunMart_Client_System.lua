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

function CPhunMartSystem:newLuaObjectAt(x, y, z)
    print("CPhunMartSystem:newLuaObjectAt", tostring(x), tostring(y), tostring(z))
    self:noise("adding luaObject " .. x .. ',' .. y .. ',' .. z)
    local globalObject = self.system:newObject(x, y, z)
    -- local nl = self.processNewLua
    -- nl:addItem(x, y, z)
    return self:newLuaObject(globalObject)
end

function CPhunMartSystem:refreshShop(obj, playerObj)
    print("CPhunMartSystem:refreshShop")
    self:sendCommand(playerObj or getSpecificPlayer(0), PM.commands.requestShop, {
        id = obj.id
    })
end

function CPhunMartSystem:requestPurchase(obj, itemId, playerObj)
    print("CPhunMartSystem:requestPurchase")
    self:sendCommand(playerObj, PM.commands.buy, {
        shopId = obj.id,
        itemId = itemId
    })
end

function CPhunMartSystem:restock(shop, playerObj)
    print("CPhunMartSystem:restock")
    self:sendCommand(playerObj or getSpecificPlayer(0), PM.commands.restock, {
        shopId = shop.id
    })
end

function CPhunMartSystem:updateShop(shop)
    print("CPhunMartSystem:updateShop")
    local obj = self:getLuaObjectAt(shop.location.x, shop.location.y, shop.location.z)

    obj.id = shop.location.x .. "_" .. shop.location.y .. "_" .. shop.location.z
    local tabChangeKey = ","
    for k, v in pairs(shop) do
        if k == "tabKeys" then
            obj.tabs = {}
            for _, tabKey in ipairs(v) do
                table.insert(obj.tabs, tabKey)
                tabChangeKey = tabChangeKey .. tabKey .. ","
            end
        elseif k == "items" then
            obj.items = v
            for kk, vv in pairs(obj.items) do
                PM:setDisplayValues(vv)
            end
        else
            obj[k] = v
        end
    end
    obj.tabChangeKey = tabChangeKey
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
        print("hasModData: ", tostring(hasModData))
        if not hasModData then
            PhunTools:printTable(hasModData)
        end
    end
end)

Events.OnObjectRightMouseButtonUp.Add(function(object, x, y)
    if _lastHighlighted then
        _lastHighlighted:setHighlighted(false, false);
    end
    print(tostring(object), " ", object:getName())
    if object and CPhunMartSystem:isValidIsoObject(object) then
        object:setHighlighted(true, false);
        _lastHighlighted = object
    end
end)
