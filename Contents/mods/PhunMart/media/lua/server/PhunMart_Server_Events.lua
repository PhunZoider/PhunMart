if isClient() then
    return
end
require "PhunMart_Server_Commands"
require "PhunMart_Server_System"

local PM = PhunMart
local SPhunMartServerCommands = SPhunMartServerCommands
local SPhunMartSystem = SPhunMartSystem

Events.OnClientCommand.Add(function(module, command, playerObj, arguments)
    if module == PM.name and SPhunMartServerCommands[command] then
        SPhunMartServerCommands[command](playerObj, arguments)
    end
end)
PhunTools:RunOnceWhenServerEmpties(PM.name, function()
    SPhunMartSystem.instance:checkLocks()
end)

Events.EveryOneMinute.Add(function()

    SPhunMartSystem.instance:checkLocks()

end)

Events.EveryTenMinutes.Add(function()
    SPhunMartSystem.instance:updatePoweredSprites()
end)

Events.OnInitGlobalModData.Add(function()
    PM:loadAll()
end)

Events.OnFillContainer.Add(function(roomtype, containertype, container)

    if containertype and (containertype == "vendingpop" or containertype == "vendingsnack") then
        local parent = container:getParent()
        if parent and parent.getModData then
            local data = parent:getModData()
            local key = PM.settings.PhunMartVanillaTestKey or "PhunMartTested"
            if not data or not data[key] then

                data[key] = true

                local rng = ZombRand(1, 100)
                if rng < (PM.settings.PhunMartVanillaChance or 80) then
                    local spriteName = parent:getSprite():getName()
                    local _, direction = PM:isTargetSprite(parent)

                    if direction ~= nil then
                        local square = parent:getSquare()
                        local isoObject = SPhunMartSystem.instance:generateRandomShopOnSquare(square, direction, parent)
                    end
                end
            else
                print("PhunMart: Testing for conversion=true ", key)
            end
        end
    end
end)
