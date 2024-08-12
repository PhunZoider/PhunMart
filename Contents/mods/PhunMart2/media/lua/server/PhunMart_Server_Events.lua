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

local spriteMap = {
    ["location_shop_accessories_01_29"] = "north",
    ["location_shop_accessories_01_31"] = "north",
    ["location_shop_accessories_01_17"] = "south",
    ["location_shop_accessories_01_19"] = "south",
    ["location_shop_accessories_01_16"] = "east",
    ["location_shop_accessories_01_18"] = "east",
    ["location_shop_accessories_01_30"] = "west",
    ["location_shop_accessories_01_28"] = "west",
    ["DylansRandomFurniture02_23"] = "south",
    ["DylansRandomFurniture02_22"] = "east"
}

Events.OnFillContainer.Add(function(roomtype, containertype, container)
    -- print("OnFillContainer: " .. tostring(roomtype) .. " " .. tostring(containertype))
    if containertype and (containertype == "vendingpop" or containertype == "vendingsnack") then
        local parent = container:getParent()
        if parent and parent.getModData then
            local data = parent:getModData()
            if not data or not data.PhunMart then
                -- do we convert to machines?

                local rng = ZombRand(1, 100)

                if rng < 20 then
                    data = {
                        tested = true
                    }
                else
                    -- if containertype == "vendingpop" then
                    local spriteName = parent:getSprite():getName()
                    local direction = spriteMap[spriteName] or nil

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
