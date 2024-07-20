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
