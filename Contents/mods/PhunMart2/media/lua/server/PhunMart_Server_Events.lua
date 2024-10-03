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
                    local direction = PhunMart.spriteMap[spriteName] or nil

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
