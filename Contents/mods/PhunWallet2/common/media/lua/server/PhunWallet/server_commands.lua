if isClient() then
    return
end
local Core = PhunWallet
local Commands = {}

Commands[Core.commands.addToWallet] = function(_, args)
    for k, v in pairs(args.wallet) do
        for kk, vv in pairs(v) do
            Core:adjust(k, kk, vv)
        end
    end
end

Commands[Core.commands.resetWallet] = function(playerObj, args)
    print("Resetting wallet for ", playerObj:getUsername())
    Core:reset(playerObj)
end

Commands[Core.commands.playerSetup] = function(playerObj, args)
    local wallet = Core:get(playerObj)
    sendServerCommand(playerObj, Core.name, Core.commands.getWallet, {
        username = playerObj:getUsername(),
        wallet = wallet
    })
end

Commands[Core.commands.getPlayerList] = function(player, args)
    local players = {}
    for k, v in pairs(Core.data) do
        table.insert(players, tostring(k))
    end
    sendServerCommand(player, Core.name, Core.commands.getPlayersList, {
        players = players
    })
end

Commands[Core.commands.getPlayersWallet] = function(player, args)
    sendServerCommand(player, Core.name, Core.commands.getPlayersWallet, {
        wallet = Core:get(args.playername)
    })
end

return Commands
