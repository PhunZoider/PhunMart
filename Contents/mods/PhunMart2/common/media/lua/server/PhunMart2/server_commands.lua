if isClient() then
    return
end

local Core = PhunMart
local Commands = {}

Commands[Core.commands.compile] = function(playerObj, args)

    Core.ServerSystem.instance:recompileShops()

end

Commands[Core.commands.getBlacklist] = function(playerObj, args)
    local list = Core.getBlacklist()
    sendServerCommand(Core.name, Core.commands.getBlackList, {
        username = playerObj:getUsername(),
        data = list
    })
end

Commands[Core.commands.setBlacklist] = function(playerObj, args)
    Core.setBlacklistData(args)
end

Commands[Core.commands.openShop] = function(playerObj, args)
    Core.ServerSystem.instance:openShop(playerObj, args)
end

Commands[Core.commands.requestShop] = function(playerObj, args)
    Core.ServerSystem.instance:requestShop(playerObj, args.location)
end

Commands[Core.commands.buy] = function(playerObj, args)
    Core.ServerSystem.instance:purchase(playerObj, args.location, args.itemId, args.qty or 1)
end

Commands[Core.commands.restock] = function(playerObj, args)
    Core.ServerSystem.instance:requestShop(playerObj, args.location, true)
end

Commands[Core.commands.closeShop] = function(playerObj, args)
    Core.ServerSystem.instance:getLuaObjectAt(args.location.x, args.location.y, args.location.z):unlock()
end

Commands[Core.commands.upsertShopDefinition] = function(playerObj, args)
    Core.ServerSystem.instance:upsertShopDefinition(args)
end

Commands[Core.commands.requestItemDefs] = function(playerObj, args)
    -- because this can be so massive, we will need to chunk it down
    local row = 0
    local chunkIteration = 0
    local chunk = 100
    local totalRows = 0
    local firstSend = true
    for k, v in pairs(Core.defs.items) do
        totalRows = totalRows + 1
    end

    local data = {}
    for k, v in pairs(Core.defs.items) do
        row = row + 1
        chunkIteration = chunkIteration + 1
        data[k] = v
        if row % chunk == 0 then
            sendServerCommand(playerObj, Core.name, Core.commands.requestItemDefs, {
                playerIndex = playerObj:getPlayerNum(),
                items = data,
                row = row,
                totalRows = totalRows,
                firstSend = firstSend,
                completed = false
            })
            firstSend = false
            data = {}
            print("Sent " .. chunkIteration .. " item defs")
        end

    end
    -- send remaining
    sendServerCommand(playerObj, Core.name, Core.commands.requestItemDefs, {
        playerIndex = playerObj:getPlayerNum(),
        items = data,
        row = row,
        totalRows = totalRows,
        firstSend = firstSend,
        completed = true
    })
    print("Sent " .. totalRows .. " item defs")
end

Commands[Core.commands.reroll] = function(playerObj, args)
    Core.ServerSystem.instance:reroll(args.location, args.ignoreDistance == true)
end

Commands[Core.commands.rerollAllShops] = function(playerObj, args)
    Core.ServerSystem.instance:rerollAll()
end

Commands[Core.commands.restockAllShops] = function(playerObj, args)
    Core.ServerSystem.instance:restockAll()
end

Commands[Core.commands.updateHistory] = function(playerObj, args)
    local history = Core:getPlayerData(playerObj)
    sendServerCommand(playerObj, Core.name, Core.commands.updateHistory, {
        name = playerObj:getUsername(),
        history = history
    })
end

-- generates or re-generates shop and inventory
Commands[Core.commands.requestShopGenerate] = function(playerObj, args)
    SPhunMartSystem.instance:reroll(args.location, args.target, args.ignoreDistance == true)
end

Commands[Core.commands.spawnVehicle] = function(playerObj, args)
    local vehicle = addVehicleDebug(args.name, IsoDirections.S, nil, playerObj:getSquare())
    for i = 0, vehicle:getPartCount() - 1 do
        local container = vehicle:getPartByIndex(i):getItemContainer()
        if container then
            container:removeAllItems()
        end
    end
    vehicle:repair()
    playerObj:sendObjectChange("addItem", {
        item = vehicle:createVehicleKey()
    })
end

Commands[Core.commands.requestLocations] = function(playerObj, args)
    local locations = SPhunMartSystem.instance:getShopLocations(args.key)
    sendServerCommand(playerObj, Core.name, Core.commands.requestLocations, {
        playerIndex = playerObj:getPlayerNum(),
        locations = locations
    })
end

Commands[Core.commands.getShopList] = function(playerObj, args)
    local list = Core.ServerSystem.instance:getShopList()

    if Core.isLocal then
        Core.ClientSystem.instance:openShopList(playerObj, list)
    else
        local data = {
            username = playerObj:getUsername(),
            data = list
        }
        sendServerCommand(playerObj, Core.name, Core.commands.getShopList, data)
    end

end

Commands[Core.commands.getShopDefinition] = function(playerObj, args)
    local shop = Core.ServerSystem.instance:getShopDefinition(args.type)
    if shop then
        if Core.isLocal then
            Core.ClientSystem.instance:openShopConfig(playerObj, shop)
        else
            local data = {
                username = playerObj:getUsername(),
                data = shop
            }
            sendServerCommand(playerObj, Core.name, Core.commands.getShopList, data)
        end
    end
end

Commands[Core.commands.getShopData] = function(playerObj, args)
    local data = SPhunMartSystem.instance:getShopData(args.location)
    if data then
        sendServerCommand(playerObj, Core.name, Core.commands.getShopData, data)
    end
end

return Commands
