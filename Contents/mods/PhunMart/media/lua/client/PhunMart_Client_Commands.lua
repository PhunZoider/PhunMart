if isServer() then
    return
end
local PhunMart = PhunMart
local Commands = {}

Commands[PhunMart.commands.serverPurchaseFailed] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    local name = player:getUsername()
    local w = 300
    local h = 150
    local message = getTextOrNull("IGUI_PhunMart.Error." .. arguments.message) or arguments.message
    local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - w / 2, getCore():getScreenHeight() / 2 - h / 2, w,
        h, message, false, nil, nil, nil);
    modal:initialise()
    modal:addToUIManager()

end

Commands[PhunMart.commands.requestLock] = function(arguments)
    local shop = CPhunMartSystem.instance:getLuaObjectAt(arguments.location.x, arguments.location.y,
        arguments.location.z)
    shop:updateFromIsoObject()
end

Commands[PhunMart.commands.updateHistory] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    PhunMart.players[player:getUsername()] = arguments.history
end

Commands[PhunMart.commands.buy] = function(arguments)
    PhunMart:completeTransaction(arguments)
end

Commands[PhunMart.commands.payWithInventory] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    for _, v in ipairs(arguments.items) do
        local item = getScriptManager():getItem(v.name)
        for i = 1, v.value do
            local inv = player:getInventory()
            local target = inv:getItemFromTypeRecurse(v.name)
            target:getContainer():DoRemoveItem(target)
        end
    end
end

Commands[PhunMart.commands.closeAllShops] = function()
    for _, v in pairs(PhunMartShopWindow.instances) do
        v:close()
    end
end

Commands[PhunMart.commands.closeShop] = function(arguments)
    for _, v in pairs(PhunMartShopWindow.instances) do
        if v.shopObj.id == arguments.shopId then
            v:close()
        end
    end
end

Commands[PhunMart.commands.updateShop] = function(arguments)
    CPhunMartSystem.instance:updateShop(arguments.location)
end

Commands[PhunMart.commands.modifyTraits] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    for _, v in ipairs(arguments.items) do
        local item = getScriptManager():getItem(v.name)
        for i = 1, v.value do
            local inv = player:getInventory()
            local target = inv:getItemFromTypeRecurse(v.name)
            target:getContainer():DoRemoveItem(target)
        end
    end
end

Commands[PhunMart.commands.requestShopDefs] = function(arguments)
    PhunMart.defs.shops = arguments.shops
    triggerEvent(PhunMart.events.OnShopDefsReloaded, arguments.shops)
end

Commands[PhunMart.commands.requestItemDefs] = function(arguments)

    print("Receiving ", arguments.row, " of ", arguments.totalRows)

    if arguments.firstSend then
        PhunMart.defs.items = arguments.items
    else
        for k, v in pairs(arguments.items) do
            PhunMart.defs.items[k] = v
        end
    end

    if arguments.completed then
        triggerEvent(PhunMart.events.OnShopItemDefsReloaded, PhunMart.defs.items)
        print("Received all item defs")
    end
end

Commands[PhunMart.commands.requestLocations] = function(args)
    triggerEvent(PhunMart.events.OnShopLocationsReceived, args.locations)
end

CPhunMartCommands = Commands

-- Listen for commands from the server
Events.OnServerCommand.Add(function(module, command, arguments)
    if module == PhunMart.name and Commands[command] then
        Commands[command](arguments)
    end
end)
