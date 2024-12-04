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

Events.OnInitGlobalModData.Add(function()
    PhunMart:loadAll()
end)

Events.OnFillContainer.Add(function(roomtype, containertype, container)

    if containertype and (containertype == "vendingpop" or containertype == "vendingsnack") then
        local parent = container:getParent()
        if parent and parent.getModData then
            local data = parent:getModData()
            local key = SandboxVars.PhunMart.PhunMartVanillaTestKey or "PhunMartTested"
            if not data or not data[key] then
                print("PhunMart: Testing for conversion=false ", key)
                -- do we convert to machines?
                data[key] = true

                local rng = ZombRand(1, 100)
                -- print(tostring(rng), " vs ", tostring(SandboxVars.PhunMart.PhunMartVanillaChance))
                if rng < (SandboxVars.PhunMart.PhunMartVanillaChance or 80) then
                    -- print("PhunMart: Converting to machine")
                    local spriteName = parent:getSprite():getName()
                    local direction = PhunMart.spriteMap[spriteName] or nil

                    if direction ~= nil then
                        local square = parent:getSquare()
                        local isoObject = SPhunMartSystem.instance:generateRandomShopOnSquare(square, direction, parent)
                    end
                    -- else
                    --     print("PhunMart: Not converting to machine")
                end
            else
                print("PhunMart: Testing for conversion=true ", key)
            end
        end
    end
end)
