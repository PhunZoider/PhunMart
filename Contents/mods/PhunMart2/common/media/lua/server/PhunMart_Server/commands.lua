if isClient() then
    return
end

local Core = PhunMart
local Commands = {}

Commands[Core.commands.compile] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    Core.ServerSystem.instance:recompileShops()
end

Commands[Core.commands.setBlacklist] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    Core.setBlacklist(args)
end

Commands[Core.commands.openShop] = function(playerObj, args)
    Core.ServerSystem.instance:openShop(playerObj, args)
end

Commands[Core.commands.relocateShop] = function(playerObj, args)
    Core.ServerSystem.instance:relocateShop(args.oldX, args.oldY, args.oldZ, args.newX, args.newY, args.newZ)
end

Commands[Core.commands.restock] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
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
    if not Core.utils.isAdmin(playerObj) then
        return
    end
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
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    Core.ServerSystem.instance:upsertShopDefinition(args)
end

Commands[Core.commands.upsertGroupDef] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    Core.ServerSystem.instance:upsertDefinition("PhunMart_Groups.txt", "groups", args.key, args.def)
end

Commands[Core.commands.upsertItemDef] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    Core.ServerSystem.instance:upsertDefinition("PhunMart_Items.txt", "items", args.key, args.def)
end

Commands[Core.commands.upsertPriceDef] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    Core.ServerSystem.instance:upsertDefinition("PhunMart_Prices.txt", "prices", args.key, args.def)
end

Commands[Core.commands.upsertSpecialDef] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    Core.ServerSystem.instance:upsertDefinition("PhunMart_Specials.txt", "specials", args.key, args.def)
end

Commands[Core.commands.upsertPoolDef] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    Core.ServerSystem.instance:upsertDefinition("PhunMart_Pools.txt", "pools", args.key, args.def)
end

-- Override file backing each definition category the editors can delete from.
-- Shops are deliberately absent: a shop definition backs machines already placed
-- in the world, so it can be disabled but never removed.
local DEF_OVERRIDE_FILES = {
    pools = "PhunMart_Pools.txt",
    groups = "PhunMart_Groups.txt",
    items = "PhunMart_Items.txt",
    prices = "PhunMart_Prices.txt",
    specials = "PhunMart_Specials.txt"
}

Commands[Core.commands.deleteDefinition] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    local kind = args and args.kind
    local key = args and args.key
    local filename = kind and DEF_OVERRIDE_FILES[kind]
    if not (filename and key) then
        return
    end
    -- Refuse anything the mod itself ships; the client checks too, but the
    -- server owns the files and shouldn't trust the caller.
    if Core.isShippedKey(kind, key) then
        Core.debugLn("deleteDefinition refused for shipped key " .. kind .. "/" .. tostring(key))
        return
    end
    Core.ServerSystem.instance:deleteDefinition(filename, key)
end

--- Drop the override for a shipped key, restoring what the mod ships.
---
--- The mirror of deleteDefinition, and the opposite guard. Deleting a shipped
--- key is refused because the default would come straight back and look like
--- the delete failed. Reverting wants exactly that outcome, so it is only
--- allowed for shipped keys: for anything an admin created there is no default
--- underneath to return to, and delete is the right verb.
---
--- Removing the override rather than writing the shipped values back on top of
--- it, so a later change to those values is picked up instead of being masked
--- by a copy of what they used to be.
Commands[Core.commands.revertDefinition] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    local kind = args and args.kind
    local key = args and args.key
    local filename = kind and DEF_OVERRIDE_FILES[kind]
    if not (filename and key) then
        return
    end
    if not Core.isShippedKey(kind, key) then
        Core.debugLn("revertDefinition refused for non-shipped key " .. kind .. "/" .. tostring(key))
        return
    end
    Core.ServerSystem.instance:deleteDefinition(filename, key)
end

Commands[Core.commands.getTokenRewards] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    sendServerCommand(playerObj, Core.name, Core.commands.getTokenRewards, {
        cfg = Core.tokenRewardsCfg or {}
    })
end

Commands[Core.commands.saveTokenRewards] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    Core.tokenRewardsCfg = args.cfg or {}
    Core.fileUtils.saveTable("PhunMart_TokenRewards.txt", Core.tokenRewardsCfg)
    -- Reload the reward modules so they pick up the new config.
    if Core.playtimeRewards then
        Core.playtimeRewards:load()
    end
    if Core.killRewards then
        Core.killRewards:load()
    end
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
        local ok = Core:deductAll(playerObj, {price}, qty)
        if not ok then
            return fail("InsufficientFunds")
        end
        -- For item-based prices the server must remove items authoritatively;
        -- client-side removal is optimistic only and does not survive a relog.
        if price.kind == "items" then
            local inv = playerObj:getInventory()
            for _, entry in ipairs(price.items or {}) do
                local remaining = entry.amount * qty
                local sources = {entry.item}
                if entry.substitutes then
                    for _, sub in ipairs(entry.substitutes) do
                        table.insert(sources, sub)
                    end
                end
                for _, itemType in ipairs(sources) do
                    while remaining > 0 do
                        local item = inv:getFirstTypeRecurse(itemType)
                        if not item then
                            break
                        end
                        local container = item:getContainer()
                        container:Remove(item)
                        sendRemoveItemFromContainer(container, item)
                        remaining = remaining - 1
                    end
                    if remaining <= 0 then
                        break
                    end
                end
            end
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

    -- Send confirmation to client (include price so client can remove inventory items)
    local wallet = Core.wallet:get(playerObj)
    local result = {
        offerId = offerId,
        stockQty = newStockQty,
        wallet = wallet,
        price = price
    }
    if Core.isLocal then
        triggerEvent(Core.events.OnPurchaseComplete, result)
    else
        sendServerCommand(playerObj, Core.name, Core.commands.buy, result)
    end
end

Commands[Core.commands.requestItemDefs] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
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
    if not Core.utils.isAdmin(playerObj) then
        return
    end
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
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    Core.ServerSystem.instance:rerollAll()
end

Commands[Core.commands.restockAllShops] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    Core.ServerSystem.instance:restockAll()
end

Commands[Core.commands.restockShopTypes] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    Core.ServerSystem.instance:restockTypes(args and args.types)
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
    if not Core.utils.isAdmin(playerObj) then
        return
    end
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
        local keyContainer = keyItem:getContainer()
        keyContainer:Remove(keyItem)
        sendRemoveItemFromContainer(keyContainer, keyItem)
    end
end

-- Player uses an AnimalClaimToken to spawn livestock at their square.
Commands[Core.commands.claimAnimal] = function(playerObj, args)
    local animalType = args.animalType
    local animalBreed = args.animalBreed
    if not animalType or not animalBreed then
        return
    end

    local inv = playerObj:getInventory()
    local allItems = inv.getAllItemsRecurse and inv:getAllItemsRecurse() or inv:getItems()
    local tokenItem = nil
    for i = 0, allItems:size() - 1 do
        local item = allItems:get(i)
        if item:getFullType() == "PhunMart.AnimalClaimToken" then
            local md = item:getModData()
            if md and md.animalType == animalType and md.animalBreed == animalBreed then
                tokenItem = item
                break
            end
        end
    end

    if not tokenItem then
        Core.debugLn("claimAnimal: no matching token for '" .. animalType .. "/" .. animalBreed .. "' in inventory")
        return
    end

    if not Core.animalTypeExists(animalType) or not Core.animalBreedExists(animalType, animalBreed) then
        Core.debugLn("claimAnimal: invalid animal '" .. animalType .. "/" .. animalBreed .. "'")
        return
    end

    local square = playerObj:getSquare()
    if not square then
        return
    end

    local breedObj = animalBreed
    local ok, def = pcall(function()
        return AnimalDefinitions.getDef and AnimalDefinitions.getDef(animalType)
    end)
    if ok and def and def.getBreedByName then
        local resolved = def:getBreedByName(animalBreed)
        if resolved then
            breedObj = resolved
        end
    end

    local animal = addAnimal(getCell(), square:getX(), square:getY(), square:getZ(), animalType, breedObj, false)
    if animal then
        animal:addToWorld()
        local tokenContainer = tokenItem:getContainer()
        tokenContainer:Remove(tokenItem)
        sendRemoveItemFromContainer(tokenContainer, tokenItem)
    else
        Core.debugLn("claimAnimal: addAnimal failed for '" .. animalType .. "/" .. animalBreed .. "'")
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
        if Core.isShopInstance(v) then
            table.insert(list, {
                key = k,
                type = v.type,
                x = v.x,
                y = v.y,
                z = v.z
            })
        end
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

-- Player picked up a coin in MP: adjust wallet, remove coin, and sync back.
Commands[Core.commands.consumeCoin] = function(playerObj, args)
    local itemType = args and args.itemType
    if not itemType or not Core.wallet:isCurrency(itemType) then
        return
    end

    local adjusted = Core.wallet:adjust(playerObj, itemType, 1)
    if not adjusted then
        return
    end

    -- Remove one coin of this type from player inventory
    local inv = playerObj:getInventory()
    local coin = inv:getFirstTypeRecurse(itemType)
    if coin then
        local container = coin:getContainer()
        container:Remove(coin)
        sendRemoveItemFromContainer(container, coin)
    end

    sendServerCommand(playerObj, Core.name, Core.commands.getWallet, {
        username = playerObj:getUsername(),
        wallet = Core.wallet:get(playerObj)
    })
end

-- Player picked up a DroppedWallet in MP: merge balances, remove the specific
-- item by its ID, and sync back. B42 is server-authoritative so removal MUST
-- happen server-side. Using getFirstTypeRecurse picks an arbitrary wallet and
-- leaves ghosts on repeat pickups; getItemById matches the exact one.
Commands[Core.commands.consumeDroppedWallet] = function(playerObj, args)
    local walletData = args and args.walletData
    if not walletData then
        return
    end

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

    -- Race condition: the client fires onComplete when the client-side transfer
    -- animation ends, but the server may not have processed the transfer packet
    -- yet. Search inventory first, then the floor at the player's square (where
    -- the wallet was just picked up from), then fall back to type search.
    local inv = playerObj:getInventory()
    local walletItem = args.itemId and inv:getItemById(args.itemId)
    if not walletItem and args.itemId then
        local sq = playerObj:getSquare()
        local floorContainer = sq and sq:getItemContainer()
        if floorContainer then
            local items = floorContainer:getItems()
            for i = 0, items:size() - 1 do
                local it = items:get(i)
                if tostring(it:getID()) == tostring(args.itemId) then
                    walletItem = it
                    break
                end
            end
        end
    end
    if not walletItem then
        walletItem = inv:getFirstTypeRecurse("PhunMart.DroppedWallet")
    end
    if walletItem then
        local container = walletItem:getContainer()
        container:Remove(walletItem)
        sendRemoveItemFromContainer(container, walletItem)
    end

    sendServerCommand(playerObj, Core.name, Core.commands.getWallet, {
        username = playerObj:getUsername(),
        wallet = Core.wallet:get(playerObj)
    })
end

-- Player-initiated wallet drop. Deducts from the player's wallet, spawns a
-- DroppedWallet item at their square tagged so any player can pick it up.
Commands[Core.commands.dropWallet] = function(playerObj, args)
    if Core.getOption("AllowWalletDrop", true) == false then
        return
    end

    local pool = args and args.pool
    local amount = args and tonumber(args.amount)
    if not pool or not amount or amount <= 0 then
        return
    end

    local poolDef = Core.wallet.pools[pool]
    if not poolDef or poolDef.bound then
        return
    end

    local balance = Core.wallet:getBalance(playerObj, pool)
    if amount > balance then
        amount = balance
    end
    if amount <= 0 then
        return
    end

    local square = playerObj:getSquare()
    if not square then
        return
    end

    Core.wallet:adjustByPool(playerObj, "current", pool, -amount)
    Core.wallet:spawnDroppedItem(playerObj, square, {{
        pool = pool,
        amount = amount
    }}, {
        anyone = true
    })

    if not Core.isLocal then
        sendServerCommand(playerObj, Core.name, Core.commands.getWallet, {
            username = playerObj:getUsername(),
            wallet = Core.wallet:get(playerObj)
        })
    end
end

Commands[Core.commands.addToWallet] = function(_, args)
    for k, v in pairs(args.wallet) do
        for kk, vv in pairs(v) do
            Core.wallet:adjust(k, kk, vv)
        end
    end
end

--- Every player's balances, keyed the way the wallet table is keyed.
---
--- Balances only. A wallet record also carries `purchases`, which is an
--- unbounded per-player history, and shipping all of them to draw a table of
--- numbers would put the biggest payload in the mod behind a button nobody
--- thinks of as expensive.
---
--- Declared here rather than beside getAllWallets because the reset handler
--- below closes over it, and a local declared later would resolve to a nil
--- global at call time.
local function allWallets()
    local wallets = {}
    for name, w in pairs(Core.wallet.data or {}) do
        wallets[tostring(name)] = {
            current = w.current or {},
            bound = w.bound or {}
        }
    end
    return wallets
end

Commands[Core.commands.resetWallet] = function(playerObj, args)
    -- Singleplayer runs the server files in the same Lua state as the client,
    -- so the wallet panel's own handler would reset a second time. Same split
    -- as adjustPlayerWallet below, and for the same reason.
    if Core.isLocal then
        return
    end

    -- The target was always being sent (Core.wallet:reset passes it) and always
    -- being ignored, so an admin asking to clear someone else's wallet cleared
    -- their own instead. Resetting your own needs no permission; resetting
    -- anybody else's is an admin action.
    local target = args and args.username
    if not target or target == playerObj:getUsername() then
        target = playerObj:getUsername()
    elseif not Core.utils.isAdmin(playerObj) then
        return
    end

    Core.debugLn("Resetting wallet for " .. tostring(target))
    Core.wallet:reset(target)

    local wallet = Core.wallet:get(target)
    -- The admin who asked, so their grid catches up.
    if Core.utils.isAdmin(playerObj) then
        sendServerCommand(playerObj, Core.name, Core.commands.getAllWallets, {
            wallets = allWallets()
        })
    end
    -- And the player it happened to, whose balance display is now wrong.
    local targetPlayer = Core.utils.getPlayerByUsername(target)
    if targetPlayer then
        sendServerCommand(targetPlayer, Core.name, Core.commands.getWallet, {
            username = target,
            wallet = wallet
        })
    end
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

-- getPlayerList and getPlayersWallet used to serve the wallet editor, which
-- asked for the names and then for one wallet at a time. The editor is a grid
-- now and takes the lot in one reply, so both are gone rather than left
-- answering nobody.
Commands[Core.commands.getAllWallets] = function(player, args)
    if not Core.utils.isAdmin(player) then
        return
    end
    sendServerCommand(player, Core.name, Core.commands.getAllWallets, {
        wallets = allWallets()
    })
end

---------------------------------------------------------------------------
-- Player data
---------------------------------------------------------------------------

local function playerDataStatus()
    return {
        counts = Core.playerData and Core.playerData.counts() or {}
    }
end

-- Both of these bail out in singleplayer, where the tool reads Core.playerData
-- directly from the shared Lua state. Same split as the wallet commands.
Commands[Core.commands.getPlayerDataStatus] = function(player, args)
    if Core.isLocal or not Core.utils.isAdmin(player) then
        return
    end
    sendServerCommand(player, Core.name, Core.commands.getPlayerDataStatus, playerDataStatus())
end

Commands[Core.commands.resetPlayerData] = function(player, args)
    if Core.isLocal or not Core.utils.isAdmin(player) then
        return
    end
    if not Core.playerData then
        return
    end
    Core.playerData.clear(args or {})
    sendServerCommand(player, Core.name, Core.commands.getPlayerDataStatus, playerDataStatus())
    -- Balances almost certainly moved, so the wallet grid is now wrong.
    sendServerCommand(player, Core.name, Core.commands.getAllWallets, {
        wallets = allWallets()
    })
end

Commands[Core.commands.adjustPlayerWallet] = function(player, args)
    if not Core.utils.isAdmin(player) then
        return
    end
    -- Singleplayer runs the server files in the same Lua state as the client, so
    -- this handler and the wallet panel's own local handler both receive the
    -- one OnClientCommand. adjustByPool increments rather than assigns, so
    -- letting both run credits the amount twice. The panel owns the SP path
    -- (admin_wallet.lua) because it also refreshes the UI afterwards.
    if Core.isLocal then
        return
    end
    Core.wallet:adjustByPool(args.playername, args.walletType, args.pool, tonumber(args.value or 0))
    local wallet = Core.wallet:get(args.playername)
    -- Update the admin editor. The whole set rather than the one wallet, so the
    -- grid takes the reply through the same path as a plain refresh and there
    -- is no second shape for it to handle.
    sendServerCommand(player, Core.name, Core.commands.getAllWallets, {
        wallets = allWallets()
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
    if not Core.utils.isAdmin(playerObj) then
        return
    end
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
    if not Core.utils.isAdmin(playerObj) then
        return
    end
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

-- The effective global blacklist as a sorted array of keys. Entries explicitly
-- set to false are un-blacklisted and omitted (see setGlobalBlacklistEntry).
local function collectGlobalBlacklist()
    local excluded = (Core.getBlacklist().items or {}).exclude or {}
    local keys = {}
    for k, v in pairs(excluded) do
        if v then
            table.insert(keys, k)
        end
    end
    table.sort(keys)
    return keys
end

Commands[Core.commands.getGlobalBlacklist] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    sendServerCommand(playerObj, Core.name, Core.commands.getGlobalBlacklist, {
        items = collectGlobalBlacklist()
    })
end

Commands[Core.commands.setGlobalBlacklistEntry] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    local itemKey = args and args.itemKey
    if not itemKey then
        return
    end
    local list = Core.getBlacklist() or {}
    list.items = list.items or {}
    list.items.exclude = list.items.exclude or {}
    -- Store an explicit false rather than removing the key: the built-in
    -- defaults are unioned back in on every load, so a key that is merely
    -- absent from the override reappears. Consumers test `if excluded[key]`,
    -- so false correctly reads as "allowed".
    list.items.exclude[itemKey] = args.excluded == true
    Core.setBlacklist(list)
    -- Takes effect at the next restock; the global list is read when a shop
    -- rolls its stock, not at compile time.
    sendServerCommand(playerObj, Core.name, Core.commands.getGlobalBlacklist, {
        items = collectGlobalBlacklist()
    })
end

Commands[Core.commands.blacklistInPool] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
    local poolKey = args and args.poolKey
    local itemKey = args and args.itemKey
    if not (poolKey and itemKey) then
        return
    end
    local override = Core.fileUtils.loadTable("PhunMart_Pools.txt") or {}
    override[poolKey] = override[poolKey] or {}
    override[poolKey].blacklist = override[poolKey].blacklist or {}
    -- avoid duplicates
    for _, v in ipairs(override[poolKey].blacklist) do
        if v == itemKey then
            return
        end
    end
    table.insert(override[poolKey].blacklist, itemKey)
    Core.fileUtils.saveTable("PhunMart_Pools.txt", override)
    Core.ServerSystem.instance:recompileShops()
end

Commands[Core.commands.updateOfferWeight] = function(playerObj, args)
    if not Core.utils.isAdmin(playerObj) then
        return
    end
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
    if not Core.utils.isAdmin(playerObj) then
        return
    end
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
