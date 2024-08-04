if not isServer() then
    return
end
local PhunMart = PhunMart

Events.EveryHours.Add(function()
    PhunMart:checkForRestocking()
end)

-- Events.OnClientCommand.Add(function(module, command, playerObj, arguments)
--     if module == PhunMart.name and Commands[command] then
--         Commands[command](playerObj, arguments)
--     end
-- end)
PhunTools:RunOnceWhenServerEmpties(PhunMart.name, function()
    SPhunMartSystem.instance:checkLocks()
end)

Events.EveryOneMinute.Add(function()

    SPhunMartSystem.instance:checkLocks()

end)

-- Events.OnInitGlobalModData.Add(loadDefs)
Events.OnInitGlobalModData.Add(function()
    PhunMart:loadAll()

    for k, _ in pairs(Events) do
        print(k)
    end
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
