require "ui/PhunMart_ShopWindow"
require "TimedActions/PM_OpenAction"

local PhunMart = PhunMart
local PM_OpenAction = PM_OpenAction

function PhunMartCloseOnWanderAway(playerObj)
    for _, v in pairs(PhunMartShopWindow.instances) do
        if v.pIndex == playerObj:getPlayerNum() then
            local location = v.data.location
            if location then
                local x = playerObj:getX()
                local y = playerObj:getY()
                if x < location.x - 3 or x > location.x + 3 or y < location.y - 3 or y > location.y + 3 then
                    v:close()
                end
            elseif not v:isVisble() then
                v:close()
            end
        end
    end
end

function PhunMartCloseAll()
    for _, v in pairs(PhunMartShopWindow.instances) do
        v:close()
    end
end

-- function PhunMartShowUI(playerObj, machine)
--     local key = PhunMart:getKey(machine)
--     local instance = PhunMartShopWindow.instances[playerObj:getPlayerNum()]
--     if instance and instance.data and instance.data.key and instance.data.key ~= key then
--         instance:close()
--     end
--     PhunMartShopWindow.OnOpenPanel(playerObj, key)
--     local open = PM_OpenAction:new(playerObj, machine, 75)
--     ISTimedActionQueue.add(open)
-- end

function PhunMartShowinstance(playerObj)
    local instance = PhunMartShopWindow.instances[playerObj:getPlayerNum()]
    if instance then
        instance:setVisible(true)
    end
end

function PhunMartUpdateShop(key, shop)
    for _, v in pairs(PhunMartShopWindow.instances) do
        if v.data and v.data.key == key then
            v:setData({
                key = key,
                shop = shop
            })
        end
    end
end

