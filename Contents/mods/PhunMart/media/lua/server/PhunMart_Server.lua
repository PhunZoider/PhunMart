if not isServer() then
    return
end
local sandbox = SandboxVars.PhunMart
require 'Items/AcceptItemFunction'
local PhunMart = PhunMart
local PhunTools = PhunTools

PhunMart.defs = {
    shops = {},
    items = {},
    currencies = {}
}

function AcceptItemFunction.PhunMart(container, item)
    return false
end

function PhunMart:itemGenerationCumulativeModel(shop, poolIndex)

    -- add all item probabilities together and then roll against that
    -- this makes the chance relative to other items probability

    local pool = shop.pools.items[poolIndex]
    if not pool or not pool.keys or #pool.keys == 0 then
        -- HOUSTON WE HAVE A PROBLEM
        print("No pool or keys for " .. shop.key .. ", pi=" .. poolIndex)
        PhunTools:printTable(shop)
        return {}
    end
    local preKeys = PhunTools:shuffleTable(pool.keys)

    local itemsKeys = {}
    local totalProbability = 0
    local haslookup = {}
    local results = {}
    local hash = {}

    local defaultProbaility = pool.probability or shop.pools.probability or shop.probability or
                                  sandbox.DefaultItemProbability or 1

    local poolItemCount = 0
    for _, v in ipairs(preKeys) do
        if not self.defs.items[v] then
            print(self.name .. ":Error Item " .. v .. " in shop " .. shop.key .. " is not found in defs")
        elseif not self.defs.items[v].enabled or self.defs.items[v].abstract then
            print("Skipping " .. v .. " because it is abstract or not enabled")
        else
            poolItemCount = poolItemCount + 1
            totalProbability = totalProbability + (self.defs.items[v].probability or defaultProbaility or 1)
            haslookup[v] = self.defs.items[v].probability or defaultProbaility or 1
        end
    end

    local fill = pool.fills or shop.pools.fills or shop.fills
    local rolls = #itemsKeys
    if type(fill) == "table" then
        rolls = ZombRand(fill.min or 1, fill.max or #itemsKeys) + 1
    elseif fill == nil then
        -- fill was not specified so use all items
        rolls = ZombRand(1, #itemsKeys) + 1
    else
        -- fill was a specific number so use specific amount
        rolls = fill
    end

    if rolls > poolItemCount then
        rolls = poolItemCount
    end
    print("Rolls: " .. rolls)

    for sanity = 1, 50 do
        for k, v in pairs(haslookup) do
            local rand = ZombRand(1, totalProbability or 100)
            if not hash[k] and rand <= v then
                hash[k] = true
                table.insert(results, k)
                if #results >= rolls then
                    break
                end
            end
        end
        if #results >= rolls then
            break
        else
            print("Results (" .. #results .. ") are less than rolls")
        end
    end
    return results
end

function PhunMart:itemGenerationChanceModel(shop, poolIndex)

    -- roll against each item individually in pool up to the max
    -- 100 chance probability item is guaranteed to appear unless there are more 100% items than max

    local pool = shop.pools.items[poolIndex]
    if not pool or not pool.keys or #pool.keys == 0 then
        -- HOUSTON WE HAVE A PROBLEM
        print("No pool or keys for " .. shop.key .. ", pi=" .. poolIndex)
        PhunTools:printTable(shop)
        return {}
    end
    local preKeys = PhunTools:shuffleTable(pool.keys)

    local itemsKeys = {}
    local results = {}
    local hash = {}

    local defaultProbaility = pool.probability or shop.pools.probability or shop.probability or
                                  sandbox.DefaultItemProbability or 1
    local poolItemCount = 0
    for _, v in ipairs(preKeys) do
        if not self.defs.items[v] then
            print(self.name .. ":Error Item " .. v .. " in shop " .. shop.key .. " is not found in defs")
        elseif self.defs.items[v].abstract then
            print("Skipping " .. v .. " because it is abstract")
        elseif not self.defs.items[v].enabled then
            print("Skipping " .. v .. " because it is not enabled")
        else
            poolItemCount = poolItemCount + 1
            if (self.defs.items[v].probability or defaultProbaility or 1) >= 100 then
                -- guarantee to be added
                table.insert(results, v)
                hash[v] = true
            else
                table.insert(itemsKeys, v)
            end
        end
    end

    local fill = pool.fills or shop.pools.fills or shop.fills
    local rolls = #itemsKeys
    if type(fill) == "table" then
        rolls = ZombRand(fill.min or 1, fill.max or #itemsKeys) + 1
    elseif fill == nil then
        -- fill was not specified so use all items
        rolls = ZombRand(1, #itemsKeys) + 1
    else
        -- fill was a specific number so use specific amount
        rolls = fill or 1
    end
    if rolls > poolItemCount then
        rolls = poolItemCount
    end

    print("Rolls: " .. rolls .. " for " .. shop.key .. " " .. poolIndex .. " containing " .. #itemsKeys .. " items")
    for sanity = 1, 50 do
        if sanity > 1 then
            print("Sanity check " .. sanity .. " for " .. shop.key .. " " .. poolIndex)
        end
        for _, v in ipairs(itemsKeys) do
            if ZombRand(100) <= (self.defs.items[v].probability or defaultProbaility) then
                table.insert(results, v)
                if #results >= rolls then
                    break
                end
            end
        end
        if #results >= rolls then
            break
        end
    end

    return results

end

function PhunMart:getNextPoolKey(shop)

    return ZombRand(#shop.pools.items) + 1

end

-- Fills the inventory of a shop
function PhunMart:generateShopItems(shopInstance, cumulativeModel)
    -- print("GENERATING ITEMS FOR " .. machineOrKey)
    -- local shopInstance = self:getShop(machineOrKey)
    -- if not shopInstance then
    --     print("No shop instance found for " .. machineOrKey)
    --     return
    -- end

    local shop = self.defs.shops[shopInstance.key]
    if not shop then
        print("No shop found for " .. shopInstance.key)
        return
    end

    local poolKey = self:getNextPoolKey(shop)
    local pool = shop.pools.items[poolKey]

    -- different models for generating items
    local itemKeys = nil
    if cumulativeModel then
        itemKeys = self:itemGenerationCumulativeModel(shop, poolKey)
    else
        itemKeys = self:itemGenerationChanceModel(shop, poolKey)
    end

    local items = {}
    for _, v in ipairs(itemKeys) do

        local item = PhunTools:deepCopyTable(self.defs.items[v])
        local qty = 0

        if type(item.inventory) == "table" then
            qty = ZombRand(item.inventory.min or 1, item.inventory.max or 1)
        elseif item.inventory ~= false then
            qty = item.inventory or 1
        end

        if items[item.key] then
            -- already have an instenace so just add the inventory
            if items[item.key].inventory ~= false then
                items[item.key].inventory = items[item.key].inventory + qty
            end
        else
            -- create a new instance by copying the item props
            local instance = {}
            for k, v in pairs(item) do
                instance[k] = v
            end
            if instance.inventory ~= false then
                instance.inventory = qty
            end

            for i, v in ipairs(item.conditions) do

                if v.price then

                    -- print("Price exists and its type is " .. type(v.price))

                    local p = {}
                    for kk, vv in pairs(v.price) do

                        local priceKey = kk
                        local value = vv

                        if kk == "currency" then
                            priceKey = shop.currency or "Base.Money"
                        end
                        -- local priced = vv
                        local basePrice = pool.basePrice or shop.basePrice or 0

                        if type(vv) == "table" then
                            value = (vv.base or 0) + ZombRand(vv.min or 1, vv.max or 10)
                        else
                            value = vv
                        end

                        p[priceKey] = basePrice + value
                    end

                    instance.conditions[i].price = p

                end
            end
            items[item.key] = instance
        end
    end

    return items
end

function PhunMart:getInstanceDistancesByType(locationKey)
    local results = {}

    local location = self:xyzFromKey(locationKey)

    if location then
        for k, v in pairs(self.shops or {}) do
            if v.location and v.location.x and (k ~= locationKey) then
                local dx = location.x - v.location.x
                local dy = location.y - v.location.y
                local distance = math.sqrt(dx * dx + dy * dy)
                print(tostring(v.type) .. " <-- " .. v.key)
                if not results[v.type] or results[v.type] < distance then
                    results[v.type] = distance
                end
            end
        end
    end
    return results
end

function PhunMart:getInstanceDistancesByType2(x, y)
    local results = {}
    print("Getting distances for " .. x .. "," .. y)
    for k, v in pairs(self.shops or {}) do
        local dx = x - v.location.x
        local dy = y - v.location.y
        table.insert(results, {
            shop = v,
            distance = math.sqrt(dx * dx + dy * dy)
        })
    end
    print("Distances")
    PhunTools:printTable(results)
    return results
end

function PhunMart:getShopListFromKey(key, reduceDistance)

    local distances = self:getInstanceDistancesByType(key)

    print("Distances")
    print("----------")
    PhunTools:printTable(distances)
    print("----------")

    local zoneInfo = self:getZoneInfo(key)
    local shops = {}
    local totalProbability = 0

    local distanceReduction = reduceDistance or 0

    for k, v in pairs(self.defs.shops) do
        if v.enabled and (v.reservations == nil or v.reservations == false) and not v.abstract then

            local minDistance = (v.minDistance or 0)
            local distanceKey = v.type or v.key

            print("Min distance for " .. tostring(v.key) .. " is " .. tostring(minDistance) .. " and reduce is " ..
                      tostring(distanceReduction) .. " and distance is " .. tostring(distances[distanceKey]) ..
                      " using distanceKey " .. tostring(distanceKey))
            if distanceReduction > 0 and minDistance > distanceReduction then
                minDistance = minDistance - distanceReduction
            end

            if minDistance == 0 or not distances[distanceKey] or (minDistance < distances[distanceKey]) then
                if v.zones and type(v.zones) == "table" then

                    local difficultyMin = 0
                    local difficultyMax = 100
                    if v.zones.difficulty then
                        if type(v.zones.difficulty) == "table" then
                            difficultyMin = v.zones.difficulty.min or 0
                            difficultyMax = v.zones.difficulty.max or 100
                        else
                            difficultyMin = v.zones.difficulty
                        end
                    end

                    local names = v.zones.names or {}

                    if zoneInfo ~= nil then
                        if (zoneInfo.difficulty and
                            (zoneInfo.difficulty >= difficultyMin and zoneInfo.difficulty <= difficultyMax)) or
                            (#names > 0 and PhunTools:inArray(zoneInfo.name, names)) then

                            table.insert(shops, {
                                key = k,
                                probability = v.probability or sandbox.DefaultItemProbability or 1
                            })
                            totalProbability = totalProbability + (v.probability or sandbox.DefaultItemProbability or 1)
                        end
                    end
                else
                    table.insert(shops, {
                        key = k,
                        probability = v.probability or sandbox.DefaultItemProbability or 1
                    })
                    totalProbability = totalProbability + (v.probability or sandbox.DefaultItemProbability or 1)
                end
            else
                print("Skipping " .. v.key .. " because there is another too close")
            end
        end
    end

    if #shops > 0 then
        return {
            list = shops,
            totalProbability = totalProbability
        }
    elseif distanceReduction < 100 then
        -- we should consider making this a broken shop
        return nil;
        -- return self:getShopListFromKey(key, distanceReduction + 10)
    else
        print("No shops found for " .. key)
        table.insert(shops, {
            key = "broken-shop",
            probability = 100
        })
        return {
            list = shops,
            totalProbability = 100
        }
    end

end

function PhunMart:generateShop(vendingMachineOrKey, forceKey)

    local key = self:getKey(vendingMachineOrKey)
    if not key then
        print("PhunMart:Error No key found for " .. tostring(vendingMachineOrKey))
        return
    end
    local chosenShopDef = nil
    if not forceKey then
        local resKey = nil
        if self.reservations[key] then
            resKey = self.reservations[key]
            print("Reservations found for " .. key .. " ( " .. resKey .. ")")
        end
        if resKey and self.defs.shops[resKey] and self.defs.shops[resKey].enabled then
            chosenShopDef = self.defs.shops[resKey]
        else
            local shopCandidates = self:getShopListFromKey(key)
            if shopCandidates == nil then
                print("No shop candidates found for " .. key)
                return nil
            end
            local rand = ZombRand(shopCandidates.totalProbability or 100) + 1
            local cumulative = 0

            for _, entry in ipairs(shopCandidates.list) do
                cumulative = cumulative + entry.probability
                if rand <= cumulative then
                    chosenShopDef = self.defs.shops[entry.key]
                    break
                end
            end
        end
    else
        chosenShopDef = self.defs.shops[forceKey]
    end

    local location = self:xyzFromKey(key)
    local shopInstance = {
        key = chosenShopDef.key or chosenShopDef.name,
        name = chosenShopDef.name,
        label = chosenShopDef.label or "Vending Machine",
        vendor = chosenShopDef.name, -- deprecated
        nextRestock = GameTime:getInstance():getWorldAgeHours() + (chosenShopDef.restock or 24),
        backgroundImage = chosenShopDef.backgroundImage or nil,
        requiresPower = chosenShopDef.requiresPower or false,
        currency = chosenShopDef.currency or "Base.Money",
        layout = chosenShopDef.layout or nil,
        maxRestock = chosenShopDef.maxRestock or 0,
        basePrice = chosenShopDef.basePrice or 0,
        type = chosenShopDef.type or chosenShopDef.key or chosenShopDef.name,
        restocks = 0,
        location = {
            x = location.x,
            y = location.y,
            z = location.z
        },
        tabs = {},
        isUnplugged = chosenShopDef.requiresPower == true and sandbox.PoweredMachinesEnabled == true
    }

    local items = self:generateShopItems(shopInstance, sandbox.CumulativeItemGeneration == true)
    print("Items")
    PhunTools:printTable(items)
    self:setShopInstanceItems(shopInstance, items)
    self.shops[key] = shopInstance
    return shopInstance
end

function PhunMart:setShopInstanceItems(shop, items)

    local tabKeys = {}
    for i, item in pairs(items) do
        if not item.tab then
            item.tab = "Misc"
        end
        if shop.tabs[item.tab] == nil then
            shop.tabs[item.tab] = {
                items = {}
            }
            table.insert(tabKeys, item.tab)
        end
        table.insert(shop.tabs[item.tab].items, item)
    end

    table.sort(tabKeys, function(a, b)
        return a < b
    end)
    shop.tabKeys = tabKeys
    shop.restockDeferred = false

end

function PhunMart:purchase(playerObj, shopKey, item)
    PhunTools:debug("PhunMart:purchase", shopKey)
    local s = PhunMart:getShop(shopKey)
    local obj = SPhunMartSystem.instance:getLuaObjectAt(s.location.x, s.location.y, s.location.z)
    local shop = obj.shop
    print("Purchasing " .. item.key .. " from " .. shopKey)
    PhunTools:printTable(shop)

    -- patching this lookup for now
    local shopItem = nil
    local tabName = nil
    local tabIndex = nil

    for k, v in pairs(shop.tabs) do
        print("Checking tab " .. k)
        for i, vv in ipairs(v.items) do
            if vv.key == item.key then
                shopItem = vv
                tabIndex = i
                tabName = k
                break
            end
        end
        if shopItem then
            break
        end
    end

    print("Shop item")
    PhunTools:printTable(shopItem)

    if shopItem then

        -- check there is sufficient inventory and adjust 
        if shopItem.inventory ~= false then
            if shopItem.inventory < 1 then
                sendServerCommand(playerObj, self.name, self.commands.serverPurchaseFailed, {
                    playerIndex = playerObj:getPlayerNum(),
                    message = "OOS"
                })
                return false
            end
            obj.shop.tabs[tabName].items[tabIndex].inventory = shopItem.inventory - 1
            obj:saveData()
        end

        -- add to players purchase history
        local pd = PhunMart:getPlayerData(playerObj)
        pd.purchases = pd.purchases or {}
        local historyKey = item.key or item.name
        if not pd.purchases[historyKey] then
            pd.purchases[historyKey] = {}
        end
        local history = pd.purchases[historyKey] or {}

        pd.purchases[historyKey] = {
            name = item.name,
            purchases = (history.purchases or 1) + 1,
            quantity = (history.quantity or 0) + (item.quantity or 1),
            modified = getTimestamp(),
            evo = getGameTime():getWorldAgeHours(),
            charEvo = playerObj:getHoursSurvived(),
            charPurchases = (pd.lives or 1) + 1
        }
        table.insert(PhunMart.history, {
            player = playerObj:getUsername(),
            item = item.name,
            quantity = item.quantity or 1,
            modified = getTimestamp(),
            evo = getGameTime():getWorldAgeHours()
        })

        sendServerCommand(playerObj, self.name, self.commands.updateHistory, {
            playerIndex = playerObj:getPlayerNum(),
            history = pd
        })
        return true
    end

    -- if shop.items[item.key].inventory ~= false then
    --     if shop.items[item.key].inventory < 1 then
    --         sendServerCommand(playerObj, self.name, self.commands.serverPurchaseFailed, {
    --             playerIndex = playerObj:getPlayerNum(),
    --             message = "OOS"
    --         })
    --         return false
    --     end
    --     shop.items[item.key].inventory = shop.items[item.key].inventory - 1
    -- end

end

local Commands = {}

Commands[PhunMart.commands.requestShopDefs] = function(playerObj, args)
    print("Requesting shop defs")
    sendServerCommand(playerObj, PhunMart.name, PhunMart.commands.requestShopDefs, {
        playerIndex = playerObj:getPlayerNum(),
        shops = PhunMart.defs.shops
    })
end

Commands[PhunMart.commands.requestItemDefs] = function(playerObj, args)
    print("Requesting item defs")

    -- because this can be so massive, we will need to chunk it down
    local row = 0
    local chunkIteration = 0
    local chunk = 100
    local totalRows = 0
    local firstSend = true
    for k, v in pairs(PhunMart.defs.items) do
        totalRows = totalRows + 1
    end

    local data = {}
    for k, v in pairs(PhunMart.defs.items) do
        row = row + 1
        chunkIteration = chunkIteration + 1
        data[k] = v
        if row % chunk == 0 then
            sendServerCommand(playerObj, PhunMart.name, PhunMart.commands.requestItemDefs, {
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
    sendServerCommand(playerObj, PhunMart.name, PhunMart.commands.requestItemDefs, {
        playerIndex = playerObj:getPlayerNum(),
        items = data,
        row = row,
        totalRows = totalRows,
        firstSend = firstSend,
        completed = true
    })
    print("Sent " .. totalRows .. " item defs")
end

Commands[PhunMart.commands.updateShop] = function(playerObj, args)

    print("updating shop")
    local resend = false
    if args.shop then
        local shop = PhunMart:generateShop(args.key, args.shop)
        resend = true
    end
    if resend then
        sendServerCommand(playerObj, PhunMart.name, PhunMart.commands.requestShop, {
            key = args.key,
            shop = PhunMart:getShop(args.key)
        })
    end
end

Commands[PhunMart.commands.rerollAllShops] = function(playerObj, args)
    PhunMart:resetShops()
end

Commands[PhunMart.commands.restockAllShops] = function(playerObj, args)
    print("Restocking all shops")
    PhunMart:checkForRestocking(true)
end

Commands[PhunMart.commands.reloadAll] = function(playerObj, args)
    print("Reloading all")
    sendServerCommand(PhunMart.name, PhunMart.commands.closeAllShops, {})
    PhunMart:loadAll()
end

Commands[PhunMart.commands.reloadItems] = function(playerObj, args)
    sendServerCommand(PhunMart.name, PhunMart.commands.closeAllShops, {})
    PhunMart:loadAllItems()
end

Commands[PhunMart.commands.reloadShops] = function(playerObj, args)
    PhunMart:loadAllShops()
end

Commands[PhunMart.commands.rebuildExportItems] = function(playerObj, args)
    local results = PhunMart:exportItems()
    sendServerCommand(playerObj, PhunMart.name, "rebuildExportItems", {
        type = "ITEMS",
        value = args
    })
end

Commands[PhunMart.commands.rebuildPerks] = function(playerObj, args)
    local results = PhunMart:exportPerksBuild()
    sendServerCommand(playerObj, PhunMart.name, "RebuildResults", {
        type = "PERKS",
        value = args
    })
end

Commands[PhunMart.commands.rebuildTraits] = function(playerObj, args)
    local results = PhunMart:getAllTrait()
    PhunTools:saveTable(args.filename or "PhunMart_TraitItems_DUMP.lua", results)
    sendServerCommand(playerObj, PhunMart.name, "RebuildResults", {
        type = "TRAITS",
        value = args
    })
end

Commands[PhunMart.commands.dump] = function(playerObj, args)
    local results = {}
    local items = {
        Food = true
    }

    if items[args.category] then
        results = PhunMart:getItemsByCategory(args.category)
    elseif args.category == "TRAITS" then
        results = PhunMart:getAllTrait()
    end
    PhunTools:saveTable(args.filename or "PhunMart_DUMP.lua", results)
    sendServerCommand(playerObj, PhunMart.name, PhunMart.commands.dump, {
        category = args.category,
        filename = args.filename,
        value = args
    })
end

Commands[PhunMart.commands.itemDump] = function(playerObj, args)

    local results = PhunMart:getItemsGrouped(args.category ~= "ALL")
    for k, v in pairs(results) do
        PhunTools:saveTable(args.filenamePrefix .. k .. "-DUMP.lua", v)
    end

    sendServerCommand(playerObj, PhunMart.name, PhunMart.commands.itemDump, {
        category = args.category,
        filename = args.filenamePrefix,
        value = results
    })
end

Commands[PhunMart.commands.rebuildVehicles] = function(playerObj, args)
    local results = PhunMart:getAllVehicles()
    PhunTools:saveTable(args.filename or "PhunMart_VehicleItems_DUMP.lua", results)
    sendServerCommand(playerObj, PhunMart.name, "RebuildResults", {
        type = "VEHICLES",
        value = results
    })
end

Commands[PhunMart.commands.updateHistory] = function(playerObj, args)
    local history = PhunMart:getPlayerData(playerObj)
    sendServerCommand(playerObj, PhunMart.name, PhunMart.commands.updateHistory, {
        playerIndex = playerObj:getPlayerNum(),
        history = history
    })
end

-- generates shop or regenerates inventory
Commands[PhunMart.commands.requestRestock] = function(playerObj, args)
    print("Requesting restock for " .. args.key)
    local location = PhunMart:xyzFromKey(args.key)
    local machine = PhunMart:getMachineByLocation(playerObj, location.x, location.y, location.z)
    if not machine then
        return
    end
    local shop = PhunMart:getShop(args.key)
    if shop and shop.maxRestock > 0 and shop.restocks >= shop.maxRestock then
        shop = PhunMart:generateShop(machine)
    else
        shop.restocks = (shop.restocks or 0) + 1
    end
    local items = PhunMart:generateShopItems(shop, sandbox.CumulativeItemGeneration == true)
    PhunMart:setShopInstanceItems(shop, items)
    shop.restockDeferred = false
    -- if not PhunMart.shoplist[args.key] or PhunMart.shoplist[args.key] ~= shop.name then
    --     PhunMart.shoplist[args.key] = shop.name
    --     ModData.transmit(PhunMart.consts.shoplist)
    -- end
    sendServerCommand(PhunMart.name, PhunMart.commands.requestShop, {
        key = args.key,
        shop = shop
    })
end

-- generates or re-generates shop and inventory
Commands[PhunMart.commands.requestShopGenerate] = function(playerObj, args)
    local location = PhunMart:xyzFromKey(args.key)
    local machine = PhunMart:getMachineByLocation(playerObj, location.x, location.y, location.z)
    if not machine then
        return
    end
    local shop = PhunMart:generateShop(machine)
    sendServerCommand(playerObj, PhunMart.name, PhunMart.commands.requestShop, {
        key = PhunMart:getKey(machine),
        shop = shop
    })
end

Commands[PhunMart.commands.requestShop] = function(playerObj, args)
    local shop = PhunMart:getShop(args.key)
    if not shop then
        shop = PhunMart:generateShop(args.key)
    end
    print("shop.restockDeferred ", tostring(shop.restockDeferred), " shop.nextRestock ", tostring(shop.nextRestock),
        " now is ", tostring(GameTime:getInstance():getWorldAgeHours()))
    if shop.restockDeferred == true then
        print("Restocking shop " .. args.key)
        local items = PhunMart:generateShopItems(shop, sandbox.CumulativeItemGeneration == true)
        self:setShopInstanceItems(shop, items)
        shop.restockDeferred = false
    end

    if shop then
        sendServerCommand(playerObj, PhunMart.name, PhunMart.commands.requestShop, {
            key = args.key,
            shop = shop
        })
    end
end

Commands[PhunMart.commands.buy] = function(playerObj, args)
    local success = PhunMart:purchase(playerObj, args.shopKey, args.item)
    local shop = PhunMart:getShop(args.shopKey)
    if not shop then
        shop = PhunMart:generateShop(args.shopKey)
    end
    if shop then
        sendServerCommand(playerObj, PhunMart.name, PhunMart.commands.buy, {
            playerIndex = playerObj:getPlayerNum(),
            success = success,
            key = args.shopKey,
            item = args.item,
            shop = shop
        })
    end
end

Commands[PhunMart.commands.spawnVehicle] = function(playerObj, args)
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

Events.OnCharacterDeath.Add(function(playerObj)
    if playerObj.getUsername then
        local data = PhunMart:getPlayerData(playerObj)
        data.lives = (data.lives or 1) + 1
    end
end)

function PhunMart:resetShops()
    -- close any open shops on clients
    sendServerCommand(PhunMart.name, PhunMart.commands.closeAllShops, {})
    self.shops = {}
    ModData.add(self.consts.shops, self.shops)

    self.shoplist = {}
    ModData.add(self.consts.shoplist, self.shoplist)
    ModData.transmit(self.consts.shoplist)
end

function PhunMart:checkForRestocking(forceRestock)
    local now = GameTime:getInstance():getWorldAgeHours()
    local toRemove = {}
    for k, v in pairs(PhunMart.shops or {}) do
        if forceRestock == true or ((v.nextRestock or 0) < now) then
            local shop = PhunMart:getShop(k)
            if shop and shop.tabs then
                if (shop.maxRestock or 0) > 0 and (shop.restocks or 0) >= (shop.maxRestock or 0) then
                    shop = PhunMart:generateShop(k)
                else
                    shop.restocks = (shop.restocks or 0) + 1
                end
                if shop then
                    shop.nextRestock = now + (PhunMart.defs.shops[shop.key].restock or 24)
                    if forceRestock then
                        local items = self:generateShopItems(self:getShop(k), sandbox.CumulativeItemGeneration == true)
                        self:setShopInstanceItems(shop, items)
                        shop.restockDeferred = false
                        if not PhunMart.defs.shops[shop.key] then
                            print("PhunMart: ERROR! Shop " .. shop.key .. " no longer exists in defs")
                            shop = self:generateShop(k)
                            return
                        end
                        if not self.shoplist[k] or self.shoplist[k] ~= shop.name then
                            self.shoplist[k] = shop.name
                            ModData.transmit(self.consts.shoplist)
                        end
                        sendServerCommand(PhunMart.name, PhunMart.commands.requestShop, {
                            key = k,
                            shop = shop
                        })
                    else
                        shop.restockDeferred = true
                        print("Deferring shop item gen")
                    end

                else
                    -- shop should have regenned, but it didn't?
                    print("PhunMart: ERROR! Shop " .. tostring(k) .. " no longer exists")
                    toRemove[k] = true
                end

            else
                print("PhunMart: ERROR! Shop " .. tostring(k) .. " no longer exists")
                toRemove[k] = true
            end
        end
    end

    for k, _ in pairs(toRemove) do
        PhunMart.shops[k] = nil
    end
end

function PhunMart:loadAllItems()

    print("---------------------")
    print("-")
    print("- PhunMart: LOADING ITEMDEFS")
    print("-")
    print("---------------------")
    self.defs.items = {}
    self:loadFilesForItemQueue()
    self:processFilesToItemQueue()
    local results = self:processItemTransformQueue()
    local total = 0

    for k, v in pairs(results.all) do
        total = total + v
    end

    print("Added " .. results.all.success .. " items from:")

    for k, v in pairs(results.files) do
        print(" - Lua/" .. tostring(k) .. " loaded " .. tostring(v.success) .. " items")
    end

    results = self:validateItems()

    print("Validated " .. results.total .. " items")
    print(" - Skipped " .. (results.abstract + results.disabled) .. " as they were marked as abstract or disabled")
    print(" - " .. results.valid .. " items passed, " .. results.invalid .. " item failed")
    local header = false
    for k, v in pairs(results.issues) do
        if not header then
            print(" - The following issues were found (and the item was disabled):")
            header = true
        end
        print("\t" .. k)
        for _, issue in pairs(v) do
            print("\t- " .. issue)
        end
    end
end

function PhunMart:loadAllShops()
    print("---------------------")
    print("-")
    print("- PhunMart: LOADING Shops")
    print("-")
    print("---------------------")
    self.defs.shops = {}
    self:loadFilesForShopQueue()
    self:processFilesToShopQueue()
    local results = PhunMart:processShopTransformQueue()
    local total = 0
    for k, v in pairs(results.all) do
        total = total + v
    end

    print("Added " .. results.all.success .. " shops from:")

    for k, v in pairs(results.files) do
        print(" - Lua/" .. k .. " loaded " .. (v and v.success or 0) .. " items")
    end

    results = self:validateShops()

    print("Validated " .. results.total .. " shops")
    print(" - Skipped " .. (results.abstract + results.disabled) .. " as they were marked as abstract or disabled")
    print(" - " .. results.valid .. " shops passed, " .. results.invalid .. " shops failed")
    local header = false
    for k, v in pairs(results.issues) do
        if not header then
            print(" - The following issues were found (and the shop was disabled):")
            header = true
        end
        print("\t" .. k)
        for _, issue in pairs(v) do
            print("\t- " .. issue)
        end
    end

    for k, v in pairs(self.defs.shops) do
        if v.enabled then
            print(" - " .. k .. " is enabled")
        else
            print(" - " .. k .. " is disabled")
        end
    end

end

function PhunMart:loadAll()
    local startTime = getTimestampMs()
    self:loadAllItems()
    self:loadAllShops()
    print("====================================")
    print(" PhunMart Data Loaded in " .. PhunTools:differenceInSeconds(startTime, getTimestampMs()) .. " seconds")
    print("====================================")
end

Events.EveryHours.Add(function()
    PhunMart:checkForRestocking()
end)

Events.OnClientCommand.Add(function(module, command, playerObj, arguments)
    if module == PhunMart.name and Commands[command] then
        Commands[command](playerObj, arguments)
    end
end)

-- Events.OnInitGlobalModData.Add(loadDefs)
Events.OnInitGlobalModData.Add(function()
    PhunMart:loadAll()

    for k, _ in pairs(Events) do
        print(k)
    end
end)

-- South
-- 01_19
-- 01_17

-- EAST
-- 01_16
-- 01_18

Events.OnFillContainer.Add(function(roomtype, containertype, container)
    -- print("OnFillContainer: " .. tostring(roomtype) .. " " .. tostring(containertype))
    if containertype and (containertype == "vendingpop" or containertype == "vendingsnack") then
        local parent = container:getParent()
        if parent and parent.getModData then
            local data = parent:getModData()
            if not data or not data.PhunMart then
                -- do we convert to machines?

                local rng = ZombRand(1, 10)

                if rng < 3 then
                    data = {
                        tested = true
                    }
                else
                    -- if containertype == "vendingpop" then
                    local spriteName = parent:getSprite():getName()
                    local direction = nil

                    if spriteName == "location_shop_accessories_01_17" then
                        -- south facing machine
                        direction = "south"
                    elseif spriteName == "location_shop_accessories_01_19" then
                        -- south facing machine
                        direction = "south"
                    elseif spriteName == "location_shop_accessories_01_16" then
                        -- east facing
                        direction = "east"
                    elseif spriteName == "location_shop_accessories_01_18" then
                        -- east facing
                        direction = "east"
                    end

                    if direction ~= nil then
                        local square = parent:getSquare()
                        local isoObject = SPhunMartSystem.instance:generateRandomShopOnSquare(square, direction, parent)
                    else
                        data = {
                            -- PhunMart = {
                            --     tested = true
                            -- }
                        }
                    end

                end
            end
        end
    end
end)

