if isServer() then
    return
end
local Core = PhunMart
local Commands = require("PhunMart2/client_commands")
-- Events.OnIsoThumpableLoad.Add(function()
--     print("PhunMart2: OnIsoThumpableLoad")
-- end)

-- Events.OnDoTileBuilding.Add(function()
--     print("PhunMart2: OnDoTileBuilding")
-- end)

-- Events.OnDoTileBuilding2.Add(function()
--     print("PhunMart2: OnDoTileBuilding2")
-- end)

-- Events.OnDoTileBuilding3.Add(function()
--     print("PhunMart2: OnDoTileBuilding3")
-- end)

-- Events.OnDestroyIsoThumpable.Add(function()
--     print("PhunMart2: OnDestroyIsoThumpable")
-- end)

-- Events.LoadGridsquare.Add(function(square)

-- end)

-- Events.OnTileRemoved.Add(function()
--     print("PhunMart2: OnTileRemoved")
-- end)

-- Events.OnRainStart.Add(function()
--     print("PhunMart2: OnRainStart")
-- end)

-- Events.OnRainStop.Add(function()
--     print("PhunMart2: OnRainStop")
-- end)

local _lastHighlighted = nil

Events.OnServerCommand.Add(function(module, command, arguments)
    if module == Core.name then
        if Commands[command] then
            Commands[command](arguments)
        end
        -- if command == Core.commands.requestShop then
        --     Core:updateInstanceInventory(arguments.key, arguments.data)
        -- end
    end
end)

Events.OnObjectLeftMouseButtonUp.Add(function(object, x, y)
    if _lastHighlighted then
        _lastHighlighted:setHighlighted(false, false);
    end
    if object and Core.ClientSystem:isValidIsoObject(object) then
        object:setHighlighted(true, false);
        _lastHighlighted = object
        local hasModData = object:getModData()
    end
end)

Events.OnObjectRightMouseButtonUp.Add(function(object, x, y)
    if _lastHighlighted then
        _lastHighlighted:setHighlighted(false, false);
    end
    if object and Core.ClientSystem:isValidIsoObject(object) then
        object:setHighlighted(true, false);
        _lastHighlighted = object
    end
end)

Events.OnPreFillWorldObjectContextMenu.Add(function(playerObj, context, worldobjects, test)
    Core.contexts.open(playerObj, context, worldobjects, test)
    Core:reloadShopDefinitions()
end)

Events.OnFillWorldObjectContextMenu.Add(function(playerObj, context, worldobjects, test)
    if isAdmin() or isDebugEnabled() then return end
    for _, obj in ipairs(worldobjects) do
        if Core.ClientSystem:isValidIsoObject(obj) then
            context:removeOptionByName("Pick Up")
            context:removeOptionByName("Dismantle")
            break
        end
    end
end)

local function setup()
    Events.OnTick.Remove(setup)
    Core:ini()
    sendClientCommand(Core.name, Core.commands.playerSetup, {})
end

Events.OnTick.Add(setup)

