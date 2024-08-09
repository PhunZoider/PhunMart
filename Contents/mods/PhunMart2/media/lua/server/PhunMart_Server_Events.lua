if not isServer() then
    return
end
require "PhunMart_Server_Commands"
require "PhunMart_Server_System"

local PhunMart = PhunMart
local SPhunMartServerCommands = SPhunMartServerCommands
local SPhunMartSystem = SPhunMartSystem

Events.OnClientCommand.Add(function(module, command, playerObj, arguments)
    if module == PhunMart.name and SPhunMartServerCommands[command] then
        SPhunMartServerCommands[command](playerObj, arguments)
    end
end)
PhunTools:RunOnceWhenServerEmpties(PhunMart.name, function()
    SPhunMartSystem.instance:checkLocks()
end)

Events.EveryOneMinute.Add(function()

    SPhunMartSystem.instance:checkLocks()

end)

Events.EveryTenMinutes.Add(function()
    SPhunMartSystem.instance:updatePoweredSprites()
end)

-- Events.OnInitGlobalModData.Add(loadDefs)
Events.OnInitGlobalModData.Add(function()
    PhunMart:loadAll()

    -- local p = {}
    -- for k, _ in pairs(Events) do
    --     table.insert(p, k)
    -- end
    -- table.sort(p)
    -- print("--- EVENTS ---")
    -- PhunTools:printTable(p)
    -- print("--- END EVENTS ---")

end)

-- South
-- 01_19
-- 01_17

-- EAST
-- 01_16
-- 01_18

Events.OnFillContainer.Add(function(roomtype, containertype, container)
    -- print("OnFillContainer: " .. tostring(roomtype) .. " " .. tostring(containertype))
    if containertype and (containertype == "vendingpop" or containertype == "vendingsnack") then
        local parent = container:getParent()
        if parent and parent.getModData then
            local data = parent:getModData()
            if not data or not data.PhunMart then
                -- do we convert to machines?

                local rng = ZombRand(1, 10)

                if rng < 3 then
                    data = {
                        tested = true
                    }
                else
                    -- if containertype == "vendingpop" then
                    local spriteName = parent:getSprite():getName()
                    local direction = nil

                    if spriteName == "location_shop_accessories_01_17" then
                        -- south facing machine
                        direction = "south"
                    elseif spriteName == "location_shop_accessories_01_19" then
                        -- south facing machine
                        direction = "south"
                    elseif spriteName == "location_shop_accessories_01_16" then
                        -- east facing
                        direction = "east"
                    elseif spriteName == "location_shop_accessories_01_18" then
                        -- east facing
                        direction = "east"
                    end

                    if direction ~= nil then
                        local square = parent:getSquare()
                        local isoObject = SPhunMartSystem.instance:generateRandomShopOnSquare(square, direction, parent)
                    else
                        data = {
                            -- PhunMart = {
                            --     tested = true
                            -- }
                        }
                    end

                end
            end
        end
    end
end)
