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

Events.OnObjectAdded.Add(function(object)
    Core.ClientSystem.instance:checkObjectAdded(object)
end)

-- A machine arriving without its sprite leaves a square nothing has folded a
-- solid flag into. The sprite follows in its own packet, which updates the
-- sprite and raises no event, so the system watches the square for a few
-- seconds and finishes the job when it lands. Costs a table lookup on a tick
-- with nothing waiting, which is every tick but those few.
Events.OnTick.Add(function()
    if Core.ClientSystem.instance then
        Core.ClientSystem.instance:pollPendingSolids()
    end
end)

-- Recovery for machines already standing in a save with a walk-through square:
-- their sprite is back, but the flags were folded in while it was missing.
Events.LoadGridsquare.Add(function(square)
    if Core.ClientSystem.instance then
        Core.ClientSystem.instance:checkSquareLoaded(square)
    end
end)

Events.OnPreFillWorldObjectContextMenu.Add(function(playerObj, context, worldobjects, test)
    Core.contexts.open(playerObj, context, worldobjects, test)
    Core:reloadShopDefinitions()
end)

Events.OnFillWorldObjectContextMenu.Add(function(playerObj, context, worldobjects, test)
    if Core.utils.isAdmin(playerObj) then
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

-- Events.EveryOneMinute.Add(ConfigTiles)

-- Repairs characters carrying leftovers from a trait removal that happened
-- before PhunMart cleaned up after itself. A player who bought "Remove: Smoker"
-- mid-withdrawal kept a stress moodle nothing on the character could spend, and
-- there is no reason to make them go and buy the trait back to shake it off.
Events.OnCreatePlayer.Add(function(playerNum, player)
    local Traits = require "PhunMart/traits"
    for _, stat in ipairs(Traits.repairOrphanedStats(player)) do
        if isClient() and sendPlayerStat then
            sendPlayerStat(player, stat)
        end
    end
end)

local function setup()
    Events.OnTick.Remove(setup)
    Core:ini()
    sendClientCommand(Core.name, Core.commands.playerSetup, {})

end

Events.OnTick.Add(setup)

-- Open admin panels used to be refreshed from here on recompile. ListPanel now
-- keeps its own weak registry of live panels and does that itself, which also
-- covers the lists this hand-written list never knew about.

