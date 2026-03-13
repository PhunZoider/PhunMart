if isServer() then
    return
end
local Core = PhunMart
local Commands = require("PhunMart_Client/commands")

local _lastHighlighted = nil

Events.OnServerCommand.Add(function(module, command, arguments)
    if module == Core.name then
        if Commands[command] then
            Commands[command](arguments)
        end
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
    if isAdmin() or isDebugEnabled() then
        return
    end
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

