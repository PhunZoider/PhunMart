local PM = PhunMart
CPhunMartSystem = CGlobalObjectSystem:derive("CPhunMartSystem")

function CPhunMartSystem:new()
    local o = CGlobalObjectSystem.new(self, "phunmart")
    return o
end

function CPhunMartSystem:isValidIsoObject(isoObject)
    return instanceof(isoObject, "IsoThumpable") and isoObject:getName() == "PhunMartShop"
end

function CPhunMartSystem:newLuaObject(globalObject)
    local o = CPhunMartObject:new(self, globalObject)
    return o
end

function CPhunMartSystem:requestLock(obj, playerObj)
    obj:updateFromIsoObject()
    self:sendCommand(playerObj or getSpecificPlayer(0), PM.commands.requestLock, {
        id = obj.id,
        location = obj.location
    })
end

function CPhunMartSystem:requestPurchase(obj, itemId, playerObj)

    local item = obj.items[itemId]
    if not item then
        return
    end

    -- recheck that player can buy
    local canBuy = PM:canBuy(playerObj, item)

    if canBuy.passed == true then
        -- assert condition 1 is the one Condition that passeed
        -- iterate through each condition and adjust any prices
        for _, v in ipairs(canBuy.conditions[1]) do

            if v.type == "price" then
                local allocations = v.allocation or {}
                for _, a in ipairs(allocations) do
                    if a.type == "trait" then
                        playerObj:getTraits():remove(a.currency)
                    elseif a.type == "item" and a.value > 0 then
                        local item = getScriptManager():getItem(a.currency)
                        if item then
                            local remaining = a.value
                            -- asserting we have enough to consume or canBuy wouldn't have passed?
                            for i = 1, remaining do
                                local invItem = playerObj:getInventory():getItemFromTypeRecurse(a.currency)
                                if invItem then
                                    invItem:getContainer():DoRemoveItem(invItem)
                                end
                            end
                        end
                    else
                        -- assert its a hook
                        local hooks = PM.hooks.prePurchase
                        for _, v in ipairs(hooks) do
                            if v then
                                -- should mutate val if handled in hook
                                v(playerObj, a.type, a.currency, a.value)
                            end
                        end
                    end
                end
            end
        end
        self:sendCommand(playerObj, PM.commands.buy, {
            shopId = obj.id,
            itemId = itemId,
            location = obj.location
        })
    end

end

function CPhunMartSystem:restock(shop, playerObj)
    self:sendCommand(playerObj or getSpecificPlayer(0), PM.commands.restock, {
        shopId = shop.id,
        location = shop.location
    })
end

function CPhunMartSystem:reroll(shop, target, playerObj)
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
    local obj = self:getLuaObjectAt(location.x, location.y, location.z)
    obj:updateFromIsoObject()
end

function CPhunMartSystem:OnServerCommand(command, args)
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
