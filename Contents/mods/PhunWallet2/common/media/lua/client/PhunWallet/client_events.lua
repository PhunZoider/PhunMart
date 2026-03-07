if isServer() then
    return
end
local Core = PhunWallet
local Commands = require("PhunWallet/client_commands")

Events.OnCharacterDeath.Add(function(playerObj)
    if instanceof(playerObj, "IsoPlayer") and playerObj:isLocalPlayer() then
        Core:drop(playerObj)
        Core:reset(playerObj)
    end
end)

local function setup()
    Events.OnTick.Remove(setup)
    Core:ini()
    sendClientCommand(Core.name, Core.commands.playerSetup, {})
end

Events.OnTick.Add(setup)

Events.OnServerCommand.Add(function(module, command, arguments)
    if module == Core.name then
        local c = Commands
        if c[command] then
            Commands[command](arguments)
        end
    end
end)

Events.OnPreFillWorldObjectContextMenu.Add(function(playerObj, context, worldobjects)
    Core.contexts.open(playerObj, context, worldobjects)
end);
