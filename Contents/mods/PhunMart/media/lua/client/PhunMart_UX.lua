require "ui/PhunMart_ShopWindow"
local PhunMart = PhunMart

local teathers = {}

local function closeOnWanderAway(playerObj)
    for _, v in pairs(PhunMartShopWindow.instances) do
        if v.pIndex == playerObj:getPlayerNum() then
            local location = PhunMart:xyzFromKey(v.data.key)
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

function PhunMartShowUI(playerObj, machine)
    local key = PhunMart:getKey(machine)
    local instance = PhunMartShopWindow.instances[playerObj:getPlayerNum()]
    if instance and instance.data and instance.data.key and instance.data.key ~= key then
        instance:close()
    end
    PhunMartShopWindow.OnOpenPanel(playerObj, key)
    local open = ISPhunMartOpenShop:new(playerObj, machine, 55)
    ISTimedActionQueue.add(open)
end

function PhunMartShowinstance(playerObj)
    local instance = PhunMartShopWindow.instances[playerObj:getPlayerNum()]
    if instance then
        instance:setVisible(true)
    end
end

function PhunMartUpdateShop(key, shop, wallet)
    for _, v in pairs(PhunMartShopWindow.instances) do
        if v.data and v.data.key == key then
            v:setData({
                key = key,
                shop = shop
            })
        end
    end
end

Events[PhunMart.events.OnWindowClosed].Add(function(playerObj)
    local pIndex = playerObj:getPlayerNum()
    if teathers[pIndex] then
        Events.OnPlayerMove.Remove(closeOnWanderAway)
        teathers[pIndex] = nil
    end
end)

Events[PhunMart.events.OnWindowOpened].Add(function(playerObj)
    local pIndex = playerObj:getPlayerNum()
    if not teathers[pIndex] then
        Events.OnPlayerMove.Add(closeOnWanderAway)
        teathers[pIndex] = true
    end
end)

