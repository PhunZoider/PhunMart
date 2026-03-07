if isServer() then
    return
end
local Core = PhunWallet
Core.contexts = {}

Core.contexts.open = function(player, context, worldobjects, test)
    if isAdmin() or isDebugEnabled() then
        local adminOption = context:addOption("PhunWallet", worldobjects, nil)
        local adminSubMenu = ISContextMenu:getNew(context)

        adminSubMenu:addOption("Admin", player, function()
            local c = Core
            c.ui.admin.OnOpenPanel(getSpecificPlayer(player))

        end)

        context:addSubMenu(adminOption, adminSubMenu)
    end
end
