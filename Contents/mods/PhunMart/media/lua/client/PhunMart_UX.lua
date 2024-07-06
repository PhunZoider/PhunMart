require "ui/PhunMart_ShopWindow"
local PhunMart = PhunMart

local teathers = {}

function PhunMartCloseOnWanderAway(playerObj)
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

function PhunMartCloseAll()
    for _, v in pairs(PhunMartShopWindow.instances) do
        v:close()
    end
end

function PhunMartShowUI(playerObj, machine)
    local key = PhunMart:getKey(machine)
    local instance = PhunMartShopWindow.instances[playerObj:getPlayerNum()]
    if instance and instance.data and instance.data.key and instance.data.key ~= key then
        instance:close()
    end
    PhunMartShopWindow.OnOpenPanel(playerObj, key)
    local open = ISPhunMartOpenShop:new(playerObj, machine, 75)
    ISTimedActionQueue.add(open)
end

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

Events[PhunMart.events.OnWindowClosed].Add(function(playerObj, key)
    print("CLOSED " .. key)
    local pIndex = playerObj:getPlayerNum()
    if teathers[pIndex] then
        Events.OnPlayerMove.Remove(PhunMartCloseOnWanderAway)
        teathers[pIndex] = nil
    end
end)

Events[PhunMart.events.OnWindowOpened].Add(function(playerObj, key)
    print("OPENED " .. key)
    local pIndex = playerObj:getPlayerNum()
    if not teathers[pIndex] then
        Events.OnPlayerMove.Add(PhunMartCloseOnWanderAway)
        teathers[pIndex] = true
    end
end)

