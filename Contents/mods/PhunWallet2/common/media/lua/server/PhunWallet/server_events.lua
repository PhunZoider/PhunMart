if isClient() then
    return
end
local Core = PhunWallet
local Commands = require "PhunWallet/server_commands"
Events.OnClientCommand.Add(function(module, command, playerObj, arguments)
    if module == Core.name then
        if Commands[command] then
            Commands[command](playerObj, arguments)
        end
    end
end)
