if isClient() then
    return
end

local Core = PhunMart
local Commands = {}

Commands[Core.commands.compile] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    Core.ServerSystem.instance:recompileShops()
end


Commands[Core.commands.setBlacklist] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    Core.setBlacklist(args)
end

Commands[Core.commands.openShop] = function(playerObj, args)
    Core.ServerSystem.instance:openShop(playerObj, args)
end

Commands[Core.commands.restock] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    local obj = Core.ServerSystem.instance:getLuaObjectAt(args.x, args.y, args.z)
    if not obj then
        return
    end
    obj:restock()
    local payload = Core.ServerSystem.buildShopPayload(obj)
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
    if not Core.utils.isAdmin(playerObj) then return end
    local loc = args.location
    local oldObj = Core.ServerSystem.instance:getLuaObjectAt(loc.x, loc.y, loc.z)
    local oldKey = oldObj and oldObj:getKey()
    Core.ServerSystem.instance:changeTo(args.to, loc)
    local newObj = Core.ServerSystem.instance:getLuaObjectAt(loc.x, loc.y, loc.z)
    if newObj and oldKey then
        local payload = Core.ServerSystem.buildShopPayload(newObj)
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
    if not Core.utils.isAdmin(playerObj) then return end
    Core.ServerSystem.instance:upsertShopDefinition(args)
end

Commands[Core.commands.upsertGroupDef] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    Core.ServerSystem.instance:upsertDefinition("PhunMart_Groups.lua", "groups", args.key, args.def)
end

Commands[Core.commands.upsertItemDef] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    Core.ServerSystem.instance:upsertDefinition("PhunMart_Items.lua", "items", args.key, args.def)
end

Commands[Core.commands.upsertPriceDef] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    Core.ServerSystem.instance:upsertDefinition("PhunMart_Prices.lua", "prices", args.key, args.def)
end

Commands[Core.commands.upsertSpecialDef] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    Core.ServerSystem.instance:upsertDefinition("PhunMart_Specials.lua", "specials", args.key, args.def)
end

Commands[Core.commands.upsertPoolDef] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    Core.ServerSystem.instance:upsertDefinition("PhunMart_Pools.lua", "pools", args.key, args.def)
end

Commands[Core.commands.getTokenRewards] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    sendServerCommand(playerObj, Core.name, Core.commands.getTokenRewards, {
        cfg = Core.tokenRewardsCfg or {}
    })
end

Commands[Core.commands.saveTokenRewards] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    Core.tokenRewardsCfg = args.cfg or {}
    Core.fileUtils.saveTable("PhunMart_TokenRewards.lua", Core.tokenRewardsCfg)
    -- Reload the reward modules so they pick up the new config.
    if Core.playtimeRewards then Core.playtimeRewards:load() end
    if Core.killRewards then Core.killRewards:load() end
    sendServerCommand(playerObj, Core.name, Core.commands.getTokenRewards, {
        cfg = Core.tokenRewardsCfg
    })
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

    -- Grant all reward actions. Pass offer.item as context so spawnVehicle
    -- gives exactly the vehicle the player selected, not a random pick.
    if offer.reward and offer.reward.actions then
        local ctx = {
            offerItem = offer.item
        }
        for _, action in ipairs(offer.reward.actions) do
            Core:grantReward(playerObj, action, qty, ctx)
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
    if not Core.utils.isAdmin(playerObj) then return end
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
            Core.debugLn("Sent chunk " .. chunkIteration .. " of item defs")
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
    Core.debugLn("Sent " .. totalRows .. " item defs total")
end

Commands[Core.commands.reroll] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    local loc = args.location
    local oldObj = Core.ServerSystem.instance:getLuaObjectAt(loc.x, loc.y, loc.z)
    local oldKey = oldObj and oldObj:getKey()
    Core.ServerSystem.instance:reroll(loc, args.ignoreDistance == true)
    if oldKey then
        local newObj = Core.ServerSystem.instance:getLuaObjectAt(loc.x, loc.y, loc.z)
        if newObj then
            local payload = Core.ServerSystem.buildShopPayload(newObj)
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
end

Commands[Core.commands.rerollAllShops] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    Core.ServerSystem.instance:rerollAll()
end

Commands[Core.commands.restockAllShops] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
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
    if not Core.utils.isAdmin(playerObj) then return end
    Core.ServerSystem.instance:reroll(args.location, args.target, args.ignoreDistance == true)
end

-- Player uses a VehicleKeySpawner item to claim their vehicle.
-- Finds the matching key in inventory, spawns the vehicle, then removes the key.
Commands[Core.commands.claimVehicle] = function(playerObj, args)
    local scriptName = args.vehicleScript
    if not scriptName then
        return
    end

    -- Find the claim key in the player's inventory.
    -- getAllItemsRecurse may not exist in B42; fall back to getItems() (top-level only).
    local inv = playerObj:getInventory()
    local allItems = inv.getAllItemsRecurse and inv:getAllItemsRecurse() or inv:getItems()
    local keyItem = nil
    for i = 0, allItems:size() - 1 do
        local item = allItems:get(i)
        if item:getFullType() == "PhunMart.VehicleKeySpawner" then
            local md = item:getModData()
            if md and md.vehicleScript == scriptName then
                keyItem = item
                break
            end
        end
    end

    if not keyItem then
        Core.debugLn("claimVehicle: no matching key for '" .. scriptName .. "' in inventory")
        return
    end

    local vehicle = addVehicleDebug(scriptName, IsoDirections.S, nil, playerObj:getSquare())
    if vehicle then
        -- Clear spawned loot from all parts
        for i = 0, vehicle:getPartCount() - 1 do
            pcall(function()
                local container = vehicle:getPartByIndex(i):getItemContainer()
                if container then
                    container:removeAllItems()
                end
            end)
        end
        -- Create a properly-bound vehicle key and give it to the player
        local carKey = vehicle:createVehicleKey()
        if carKey then
            playerObj:getInventory():AddItem(carKey)
            sendAddItemToContainer(playerObj:getInventory(), carKey)
        end
        -- Apply condition from key moddata if present
        local cond = keyItem:getModData().condition
        if cond then
            for i = 0, vehicle:getPartCount() - 1 do
                local v = type(cond) == "table" and ZombRand(cond.min or 80, (cond.max or 99) + 1) or cond
                pcall(function()
                    vehicle:getPartByIndex(i):setCondition(v)
                end)
            end
        end
        -- Consume the key (remove from whichever container holds it)
        keyItem:getContainer():DoRemoveItem(keyItem)
    end
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

Commands[Core.commands.getInstanceList] = function(playerObj, args)
    local list = {}
    for k, v in pairs(Core.instances or {}) do
        table.insert(list, {
            key = k,
            type = v.type,
            x = v.x,
            y = v.y,
            z = v.z
        })
    end
    if Core.isLocal then
        Core.ui.shop_instances.setData(playerObj, list)
    else
        sendServerCommand(playerObj, Core.name, Core.commands.getInstanceList, {
            username = playerObj:getUsername(),
            data = list
        })
    end
end




Commands[Core.commands.getShopData] = function(playerObj, args)
    local data = Core.ServerSystem.instance:getShopData(args.location)
    if data then
        sendServerCommand(playerObj, Core.name, Core.commands.getShopData, data)
    end
end

-- Player picked up a coin in MP — adjust wallet and sync back.
-- Item removal is handled client-side via sendRemoveItemFromContainer.
Commands[Core.commands.consumeCoin] = function(playerObj, args)
    local itemType = args and args.itemType
    if not itemType or not Core.wallet:isCurrency(itemType) then return end

    Core.wallet:adjust(playerObj, itemType, 1)
    Core.wallet:save()

    sendServerCommand(playerObj, Core.name, Core.commands.getWallet, {
        username = playerObj:getUsername(),
        wallet = Core.wallet:get(playerObj)
    })
end

-- Player picked up a DroppedWallet in MP — merge balances and sync back.
-- Item removal is handled client-side via sendRemoveItemFromContainer.
Commands[Core.commands.consumeDroppedWallet] = function(playerObj, args)
    local walletData = args and args.walletData
    if not walletData then return end

    for _, entry in ipairs(walletData) do
        if entry.pool and entry.amount and entry.amount > 0 then
            local cap = Core.wallet:getCap(entry.pool)
            local bal = Core.wallet:getBalance(playerObj, entry.pool)
            local toAdd = cap and math.min(entry.amount, cap - bal) or entry.amount
            if toAdd > 0 then
                Core.wallet:adjustByPool(playerObj, "current", entry.pool, toAdd)
            end
        end
    end

    Core.wallet:save()

    sendServerCommand(playerObj, Core.name, Core.commands.getWallet, {
        username = playerObj:getUsername(),
        wallet = Core.wallet:get(playerObj)
    })
end

Commands[Core.commands.addToWallet] = function(_, args)
    for k, v in pairs(args.wallet) do
        for kk, vv in pairs(v) do
            Core.wallet:adjust(k, kk, vv)
        end
    end
end

Commands[Core.commands.resetWallet] = function(playerObj, args)
    Core.debugLn("Resetting wallet for " .. playerObj:getUsername())
    Core.wallet:reset(playerObj)
end

Commands[Core.commands.playerSetup] = function(playerObj, args)

    local wallet = Core.wallet:get(playerObj)
    sendServerCommand(playerObj, Core.name, Core.commands.getWallet, {
        username = playerObj:getUsername(),
        wallet = wallet
    })
    -- Send server override tables so the client can compile locally against its
    -- own shared defaults. Client never reads the filesystem.
    if Core._lastOverrides then
        sendServerCommand(playerObj, Core.name, Core.commands.requestShopDefs, {
            overrides = Core._lastOverrides
        })
    end
    -- Send this player's purchase history so the client can evaluate
    -- purchaseCountMax conditions without a round-trip per shop open.
    local username = playerObj:getUsername()
    local history = Core.purchases.histories and Core.purchases.histories[username] or {}
    sendServerCommand(playerObj, Core.name, Core.commands.syncPurchases, {
        username = username,
        history = history
    })
end

Commands[Core.commands.reportKills] = function(playerObj, args)
    Core.killRewards:reportKills(playerObj, args.normal or 0, args.sprinter or 0)
end

Commands[Core.commands.getPlayerList] = function(player, args)
    if not Core.utils.isAdmin(player) then return end
    local players = {}
    for k, v in pairs(Core.wallet.data) do
        table.insert(players, tostring(k))
    end
    sendServerCommand(player, Core.name, Core.commands.getPlayerList, {
        players = players
    })
end

Commands[Core.commands.getPlayersWallet] = function(player, args)
    if not Core.utils.isAdmin(player) then return end
    sendServerCommand(player, Core.name, Core.commands.getPlayersWallet, {
        wallet = Core.wallet:get(args.playername)
    })
end

Commands[Core.commands.adjustPlayerWallet] = function(player, args)
    if not Core.utils.isAdmin(player) then return end
    Core.wallet:adjustByPool(args.playername, args.walletType, args.pool, tonumber(args.value or 0))
    local wallet = Core.wallet:get(args.playername)
    -- Update the admin editor
    sendServerCommand(player, Core.name, Core.commands.getPlayersWallet, {
        wallet = wallet
    })
    -- Notify the target player so their character tab refreshes.
    -- In SP the shared wallet data is already updated in-place.
    if not Core.isLocal then
        local targetPlayer = Core.utils.getPlayerByUsername(args.playername)
        if targetPlayer then
            sendServerCommand(targetPlayer, Core.name, Core.commands.getWallet, {
                username = args.playername,
                wallet = wallet
            })
        end
    end
end

Commands[Core.commands.requestPool] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    local poolKey = args and args.poolKey
    if not poolKey then
        return
    end
    local pool = Core.runtime and Core.runtime.pools and Core.runtime.pools[poolKey]
    local excluded = (Core.getBlacklist().items or {}).exclude or {}
    local data = {
        poolKey = poolKey,
        offers = pool and pool.offers or {},
        conditionsDefs = Core.runtime and Core.runtime.conditionsDefs,
        blacklisted = excluded
    }
    if Core.isLocal then
        Core.ui.client.poolViewer.open(playerObj, poolKey, data)
    else
        sendServerCommand(playerObj, Core.name, Core.commands.requestPool, {
            username = playerObj:getUsername(),
            poolKey = poolKey,
            data = data
        })
    end
end

Commands[Core.commands.quickBlacklist] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    local itemKey = args and args.itemKey
    if not itemKey then
        return
    end
    local list = Core.getBlacklist() or {}
    list.items = list.items or {}
    list.items.exclude = list.items.exclude or {}
    list.items.exclude[itemKey] = true
    Core.setBlacklist(list)
end

Commands[Core.commands.blacklistInPool] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    local poolKey = args and args.poolKey
    local itemKey = args and args.itemKey
    if not (poolKey and itemKey) then
        return
    end
    local override = Core.fileUtils.loadTable("PhunMart_Pools.lua") or {}
    override[poolKey] = override[poolKey] or {}
    override[poolKey].blacklist = override[poolKey].blacklist or {}
    -- avoid duplicates
    for _, v in ipairs(override[poolKey].blacklist) do
        if v == itemKey then return end
    end
    table.insert(override[poolKey].blacklist, itemKey)
    Core.fileUtils.saveTable("PhunMart_Pools.lua", override)
    Core.ServerSystem.instance:recompileShops()
end

Commands[Core.commands.updateOfferWeight] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    local poolKey = args and args.poolKey
    local offerId = args and args.offerId
    local weight = args and tonumber(args.weight)
    if not (poolKey and offerId and weight and weight >= 0) then
        return
    end
    local pool = Core.runtime and Core.runtime.pools and Core.runtime.pools[poolKey]
    if not pool then
        return
    end
    local offer = pool.offers and pool.offers[offerId]
    if not offer then
        return
    end
    -- weight lives inside offer.offer sub-table
    offer.offer = offer.offer or {}
    offer.offer.weight = weight
end

Commands[Core.commands.moveOffers] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then return end
    local fromPool = args and args.fromPool
    local toPool = args and args.toPool
    local offerIds = args and args.offerIds
    if not (fromPool and toPool and offerIds and fromPool ~= toPool) then
        return
    end
    local pools = Core.runtime and Core.runtime.pools
    if not pools then
        return
    end
    local src = pools[fromPool]
    local dst = pools[toPool]
    if not (src and src.offers and dst) then
        return
    end
    dst.offers = dst.offers or {}
    for _, offerId in ipairs(offerIds) do
        local offer = src.offers[offerId]
        if offer then
            dst.offers[offerId] = offer
            src.offers[offerId] = nil
        end
    end
end

return Commands
