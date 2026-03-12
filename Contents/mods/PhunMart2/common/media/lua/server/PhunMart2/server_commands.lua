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

Commands[Core.commands.restock] = function(playerObj, args)
    local obj = Core.ServerSystem.instance:getLuaObjectAt(args.x, args.y, args.z)
    if not obj then
        return
    end
    obj:restock()
    local shopDef = Core.runtime and Core.runtime.shops and Core.runtime.shops[obj.type]
    local shopCfg = Core.shops and Core.shops[obj.type]
    local payload = {
        key = obj:getKey(),
        shopType = obj.type,
        location = {
            x = obj.x,
            y = obj.y,
            z = obj.z
        },
        offers = obj.offers or {},
        conditionsDefs = Core.runtime and Core.runtime.conditionsDefs,
        background = shopDef and shopDef.background,
        defaultView = shopDef and shopDef.defaultView,
        poolSets = shopDef and shopDef.poolSets,
        lastRestock = obj.lastRestock,
        restockFrequency = (shopCfg and shopCfg.restock) or 24
    }
    if Core.isLocal then
        triggerEvent(Core.events.OnShopChange, payload.key, payload, false)
    else
        sendServerCommand(Core.name, Core.commands.onShopChange, {
            key = payload.key,
            data = payload
        })
    end
end

Commands[Core.commands.changeTo] = function(playerObj, args)
    local loc = args.location
    local oldObj = Core.ServerSystem.instance:getLuaObjectAt(loc.x, loc.y, loc.z)
    local oldKey = oldObj and oldObj:getKey()
    Core.ServerSystem.instance:changeTo(args.to, loc)
    -- Send back new shop data under the OLD key so the open window can update itself.
    local newObj = Core.ServerSystem.instance:getLuaObjectAt(loc.x, loc.y, loc.z)
    local shopDef = newObj and Core.runtime and Core.runtime.shops and Core.runtime.shops[newObj.type]
    local shopCfg = newObj and Core.shops and Core.shops[newObj.type]
    local payload = newObj and oldKey and {
        key = newObj:getKey(),
        shopType = newObj.type,
        location = loc,
        offers = newObj.offers or {},
        conditionsDefs = Core.runtime and Core.runtime.conditionsDefs,
        background = shopDef and shopDef.background,
        defaultView = shopDef and shopDef.defaultView,
        poolSets = shopDef and shopDef.poolSets,
        lastRestock = newObj.lastRestock,
        restockFrequency = (shopCfg and shopCfg.restock) or 24
    }
    if payload then
        if Core.isLocal then
            triggerEvent(Core.events.OnShopChange, oldKey, payload, true)
        else
            sendServerCommand(playerObj, Core.name, Core.commands.onShopChange, {
                key = oldKey,
                data = payload,
                replaced = true
            })
        end
    end
end

Commands[Core.commands.closeShop] = function(playerObj, args)
    Core.ServerSystem.instance:getLuaObjectAt(args.location.x, args.location.y, args.location.z):unlock()
end

Commands[Core.commands.upsertShopDefinition] = function(playerObj, args)
    Core.ServerSystem.instance:upsertShopDefinition(args)
end

Commands[Core.commands.buy] = function(playerObj, args)
    local loc = args.location
    local offerId = args.offerId
    local qty = args.qty or 1

    local function fail(msg)
        if Core.isLocal then
            triggerEvent(Core.events.OnPurchaseComplete, {
                failed = true,
                message = msg
            })
        else
            sendServerCommand(playerObj, Core.name, Core.commands.serverPurchaseFailed, {
                playerIndex = playerObj:getPlayerNum(),
                message = msg
            })
        end
    end

    local shopObj = Core.ServerSystem.instance:getLuaObjectAt(loc.x, loc.y, loc.z)
    if not shopObj then
        return fail("ShopNotFound")
    end

    local offer = shopObj.offers and shopObj.offers[offerId]
    if not offer then
        return fail("OfferNotFound")
    end

    -- Stock check
    local stockQty = offer.offer and offer.offer.stockQty
    if stockQty and stockQty ~= -1 and stockQty < qty then
        return fail("OutOfStock")
    end

    -- Conditions check
    local adapter = Core.getPlayerAdapter(playerObj)
    local condDefs = Core.runtime and Core.runtime.conditionsDefs
    if offer.conditions and condDefs and adapter then
        local result = Core.conditionsRuntime.evaluate(offer.conditions, condDefs, adapter, Core.purchases, {
            offerId = offerId
        })
        if not result.ok then
            return fail("ConditionsFailed")
        end
    end

    -- Affordability + deduct
    local price = offer.price
    if price and price.kind ~= "free" then
        local ok = Core:deductAll(playerObj, {price})
        if not ok then
            return fail("InsufficientFunds")
        end
    end

    -- Grant all reward actions
    if offer.reward and offer.reward.actions then
        for _, action in ipairs(offer.reward.actions) do
            Core:grantReward(playerObj, action, qty)
        end
    end

    -- Decrement stock and persist
    local newStockQty = -1
    if stockQty and stockQty ~= -1 then
        newStockQty = stockQty - qty
        offer.offer.stockQty = newStockQty
        shopObj:saveData()
    end

    -- Record purchase history
    Core.purchases:add(playerObj, offerId, qty)
    Core.purchases:save()

    -- Send confirmation to client
    local wallet = Core.wallet:get(playerObj)
    local result = {
        offerId = offerId,
        stockQty = newStockQty,
        wallet = wallet
    }
    if Core.isLocal then
        triggerEvent(Core.events.OnPurchaseComplete, result)
    else
        sendServerCommand(playerObj, Core.name, Core.commands.buy, result)
    end
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
    local loc = args.location
    local oldObj = Core.ServerSystem.instance:getLuaObjectAt(loc.x, loc.y, loc.z)
    local oldKey = oldObj and oldObj:getKey()
    Core.ServerSystem.instance:reroll(loc, args.ignoreDistance == true)
    if oldKey then
        local newObj = Core.ServerSystem.instance:getLuaObjectAt(loc.x, loc.y, loc.z)
        local shopDef = newObj and Core.runtime and Core.runtime.shops and Core.runtime.shops[newObj.type]
        local shopCfg = newObj and Core.shops and Core.shops[newObj.type]
        local payload = newObj and {
            key = newObj:getKey(),
            shopType = newObj.type,
            location = {
                x = newObj.x,
                y = newObj.y,
                z = newObj.z
            },
            offers = newObj.offers or {},
            conditionsDefs = Core.runtime and Core.runtime.conditionsDefs,
            background = shopDef and shopDef.background,
            defaultView = shopDef and shopDef.defaultView,
            poolSets = shopDef and shopDef.poolSets,
            lastRestock = newObj.lastRestock,
            restockFrequency = (shopCfg and shopCfg.restock) or 24
        }
        if Core.isLocal then
            triggerEvent(Core.events.OnShopChange, oldKey, payload, true)
        else
            sendServerCommand(playerObj, Core.name, Core.commands.onShopChange, {
                key = oldKey,
                data = payload,
                replaced = true
            })
        end
    end
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
    Core.ServerSystem.instance:reroll(args.location, args.target, args.ignoreDistance == true)
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
    local locations = Core.ServerSystem.instance:getShopLocations(args.key)
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
            sendServerCommand(playerObj, Core.name, Core.commands.getShopDefinition, data)
        end
    end
end

Commands[Core.commands.getShopData] = function(playerObj, args)
    local data = Core.ServerSystem.instance:getShopData(args.location)
    if data then
        sendServerCommand(playerObj, Core.name, Core.commands.getShopData, data)
    end
end

Commands[Core.commands.addToWallet] = function(_, args)
    for k, v in pairs(args.wallet) do
        for kk, vv in pairs(v) do
            Core.wallet:adjust(k, kk, vv)
        end
    end
end

Commands[Core.commands.resetWallet] = function(playerObj, args)
    print("Resetting wallet for ", playerObj:getUsername())
    Core.wallet:reset(playerObj)
end

Commands[Core.commands.playerSetup] = function(playerObj, args)

    local wallet = Core.wallet:get(playerObj)
    sendServerCommand(playerObj, Core.name, Core.commands.getWallet, {
        username = playerObj:getUsername(),
        wallet = wallet
    })
    -- Send compiled shop defs so the client has them for admin menus from the start.
    if Core.runtime and Core.runtime.shops then
        sendServerCommand(playerObj, Core.name, Core.commands.requestShopDefs, {
            shops = Core.runtime.shops
        })
    end
end

Commands[Core.commands.reportKills] = function(playerObj, args)
    Core.killRewards:reportKills(playerObj, args.normal or 0, args.sprinter or 0)
end

Commands[Core.commands.getPlayerList] = function(player, args)
    local players = {}
    for k, v in pairs(Core.wallet.data) do
        table.insert(players, tostring(k))
    end
    sendServerCommand(player, Core.name, Core.commands.getPlayerList, {
        players = players
    })
end

Commands[Core.commands.getPlayersWallet] = function(player, args)
    sendServerCommand(player, Core.name, Core.commands.getPlayersWallet, {
        wallet = Core.wallet:get(args.playername)
    })
end

Commands[Core.commands.adjustPlayerWallet] = function(player, args)
    Core.wallet:adjustByPool(args.playername, args.walletType, args.pool, tonumber(args.value or 0))
    sendServerCommand(player, Core.name, Core.commands.getPlayersWallet, {
        wallet = Core.wallet:get(args.playername)
    })
end

return Commands
