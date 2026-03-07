if isServer() then
    return
end

local Core = PhunWallet
local Commands = {}

Commands[Core.commands.updateWallet] = function(args)
    local player = Core.tools.getPlayerByUsername(args.username)
    for k, v in pairs(args.wallet) do
        Core:adjust(player, k, v, true)
    end
end

Commands[Core.commands.getWallet] = function(args)
    Core:setPlayerData(args.username, args.wallet)
end

return Commands
