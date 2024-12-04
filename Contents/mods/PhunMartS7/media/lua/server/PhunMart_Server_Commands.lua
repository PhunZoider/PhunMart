if isClient() then
    return
end
require "PhunMart_Server_System"

local PM = PhunMart
local sandbox = SandboxVars.PhunMart
local Commands = {}

-- Commands[PM.commands.requestShop] = function(playerObj, args)
--     SPhunMartSystem.instance:requestShop(args.location, playerObj)
-- end

Commands[PM.commands.requestLock] = function(playerObj, args)
    SPhunMartSystem.instance:requestLock(args.location, playerObj)
end

Commands[PM.commands.buy] = function(playerObj, args)
    SPhunMartSystem.instance:purchase(args.location, args.itemId, playerObj)
end

Commands[PM.commands.restock] = function(playerObj, args)
    -- use the request stock feature with forceRestock=true 
    SPhunMartSystem.instance:requestShop(args.location, playerObj, true)
end

Commands[PM.commands.closeShop] = function(playerObj, args)
    SPhunMartSystem.instance:getLuaObjectAt(args.location.x, args.location.y, args.location.z):unlock()
end

Commands[PM.commands.requestShopDefs] = function(playerObj, args)
    sendServerCommand(playerObj, PM.name, PM.commands.requestShopDefs, {
        playerIndex = playerObj:getPlayerNum(),
        shops = PM.defs.shops
    })
end

Commands[PM.commands.addFromSprite] = function(playerObj, args)
    print("Orphaned vending machine found at " .. args.location.x .. ", " .. args.location.y .. " sprite: " ..
              args.sprite)
    SPhunMartSystem.instance:addFromSprite(args.location.x, args.location.y, args.location.z, args.sprite)
end

Commands[PM.commands.requestItemDefs] = function(playerObj, args)
    -- because this can be so massive, we will need to chunk it down
    local row = 0
    local chunkIteration = 0
    local chunk = 100
    local totalRows = 0
    local firstSend = true
    for k, v in pairs(PM.defs.items) do
        totalRows = totalRows + 1
    end

    local data = {}
    for k, v in pairs(PM.defs.items) do
        row = row + 1
        chunkIteration = chunkIteration + 1
        data[k] = v
        if row % chunk == 0 then
            sendServerCommand(playerObj, PM.name, PM.commands.requestItemDefs, {
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
    sendServerCommand(playerObj, PM.name, PM.commands.requestItemDefs, {
        playerIndex = playerObj:getPlayerNum(),
        items = data,
        row = row,
        totalRows = totalRows,
        firstSend = firstSend,
        completed = true
    })
    print("Sent " .. totalRows .. " item defs")
end

Commands[PM.commands.updateShop] = function(playerObj, args)

    local resend = false
    if args.shop then
        local shop = PM:generateShop(args.key, args.shop)
        if shop == nil then
            return
        end
        resend = true
    end
    if resend then
        sendServerCommand(playerObj, PM.name, PM.commands.requestShop, {
            key = args.key,
            shop = PM:getShop(args.key)
        })
    end
end

Commands[PM.commands.rerollAllShops] = function(playerObj, args)
    SPhunMartSystem.instance:rerollAll()
end

Commands[PM.commands.restockAllShops] = function(playerObj, args)
    print("Restocking all shops")
    SPhunMartSystem.instance:restockAll()
end

Commands[PM.commands.reloadAll] = function(playerObj, args)
    print("Reloading all")
    sendServerCommand(PM.name, PM.commands.closeAllShops, {})
    PM:loadAll()
end

Commands[PM.commands.reloadItems] = function(playerObj, args)
    sendServerCommand(PM.name, PM.commands.closeAllShops, {})
    PM:loadAllItems()
end

Commands[PM.commands.reloadShops] = function(playerObj, args)
    PM:loadAllShops()
end

Commands[PM.commands.rebuildExportItems] = function(playerObj, args)
    local results = PM:exportItems()
    sendServerCommand(playerObj, PM.name, "rebuildExportItems", {
        type = "ITEMS",
        value = args
    })
end

Commands[PM.commands.rebuildPerks] = function(playerObj, args)
    local results = PM:exportPerksBuild()
    sendServerCommand(playerObj, PM.name, "RebuildResults", {
        type = "PERKS",
        value = args
    })
end

Commands[PM.commands.rebuildTraits] = function(playerObj, args)
    local results = PM:getAllTrait()
    PhunTools:saveTable(args.filename or "PhunMart_TraitItems_DUMP.lua", results)
    sendServerCommand(playerObj, PM.name, "RebuildResults", {
        type = "TRAITS",
        value = args
    })
end

Commands[PM.commands.dump] = function(playerObj, args)
    local results = {}
    local items = {
        Food = true
    }

    if items[args.category] then
        results = PM:getItemsByCategory(args.category)
    elseif args.category == "TRAITS" then
        results = PM:getAllTrait()
    end
    PhunTools:saveTable(args.filename or "PhunMart_DUMP.lua", results)
    sendServerCommand(playerObj, PM.name, PM.commands.dump, {
        category = args.category,
        filename = args.filename,
        value = args
    })
end

Commands[PM.commands.itemDump] = function(playerObj, args)

    local results = PM:getItemsGrouped(args.category ~= "ALL")
    for k, v in pairs(results) do
        PhunTools:saveTable(args.filenamePrefix .. k .. "-DUMP.lua", v)
    end

    sendServerCommand(playerObj, PM.name, PM.commands.itemDump, {
        category = args.category,
        filename = args.filenamePrefix,
        value = results
    })
end

Commands[PM.commands.rebuildVehicles] = function(playerObj, args)
    local results = PM:getAllVehicles()
    PhunTools:saveTable(args.filename or "PhunMart_VehicleItems_DUMP.lua", results)
    sendServerCommand(playerObj, PM.name, "RebuildResults", {
        type = "VEHICLES",
        value = results
    })
end

Commands[PM.commands.updateHistory] = function(playerObj, args)
    local history = PM:getPlayerData(playerObj)
    sendServerCommand(playerObj, PM.name, PM.commands.updateHistory, {
        playerIndex = playerObj:getPlayerNum(),
        history = history
    })
end

-- generates or re-generates shop and inventory
Commands[PM.commands.requestShopGenerate] = function(playerObj, args)
    SPhunMartSystem.instance:reroll(args.location, args.target, args.ignoreDistance == true)
end

Commands[PM.commands.spawnVehicle] = function(playerObj, args)
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

SPhunMartServerCommands = Commands
