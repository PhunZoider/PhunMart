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
        self:debug(shop)
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

    for _, v in ipairs(preKeys) do
        if not self.defs.items[v] then
            print(self.name .. ":Error Item " .. v .. " in shop " .. shop.key .. " is not found in defs")
        elseif not self.defs.items[v].enabled or self.defs.items[v].abstract then
            print("Skipping " .. v .. " because it is abstract or not enabled")
        else
            print("Adding " .. v .. " to lookup (" .. (self.defs.items[v].probability or defaultProbaility or 1) .. ")")
            totalProbability = totalProbability + (self.defs.items[v].probability or defaultProbaility or 1)
            haslookup[v] = self.defs.items[v].probability or defaultProbaility or 1

        end
    end

    local fill = pool.fill or shop.pools.fill or shop.fill
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
    print("Rolling " .. rolls .. " with total probability of " .. totalProbability)

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

    return results
end

function PhunMart:itemGenerationChanceModel(shop, poolIndex)

    -- roll against each item individually in pool up to the max
    -- 100 chance probability item is guaranteed to appear unless there are more 100% items than max

    local pool = shop.pools.items[poolIndex]
    if not pool or not pool.keys or #pool.keys == 0 then
        -- HOUSTON WE HAVE A PROBLEM
        print("No pool or keys for " .. shop.key .. ", pi=" .. poolIndex)
        self:debug(shop)
        return {}
    end
    local preKeys = PhunTools:shuffleTable(pool.keys)

    local itemsKeys = {}
    local results = {}
    local hash = {}

    local defaultProbaility = pool.probability or shop.pools.probability or shop.probability or
                                  sandbox.DefaultItemProbability or 1

    for _, v in ipairs(preKeys) do
        if not self.defs.items[v] then
            print(self.name .. ":Error Item " .. v .. " in shop " .. shop.key .. " is not found in defs")
        elseif self.defs.items[v].abstract then
            print("Skipping " .. v .. " because it is abstract")
        elseif not self.defs.items[v].enabled then
            print("Skipping " .. v .. " because it is not enabled")
        else
            print("Adding " .. v .. " to lookup (" .. (self.defs.items[v].probability or defaultProbaility or 1) .. ")")
            if (self.defs.items[v].probability or defaultProbaility or 1) >= 100 then
                -- guarantee to be added
                table.insert(results, v)
                hash[v] = true
            else
                table.insert(itemsKeys, v)
            end
        end
    end

    local fill = pool.fill or shop.pools.fill or shop.fill
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

    print("Rolling " .. rolls .. " against " .. #itemsKeys .. " items")

    for sanity = 1, 10 do
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
function PhunMart:generateShopItems(machineOrKey, cumulativeModel)

    local shopInstance = self:getShop(machineOrKey)
    if not shopInstance then
        print("No shop instance found for " .. machineOrKey)
        return
    end

    local shop = self.defs.shops[shopInstance.key]
    if not shop then
        print("No shop found for " .. shopInstance.key)
        return
    end

    -- self:debug(shop.key, shop.items)

    -- different models for generating items
    local itemKeys = nil
    if cumulativeModel then
        print("Using cumulative model")
        itemKeys = self:itemGenerationCumulativeModel(shop, self:getNextPoolKey(shop))
    else
        print("Using chance model")
        itemKeys = self:itemGenerationChanceModel(shop, self:getNextPoolKey(shop))
    end

    local items = {}
    -- self:debug("keys", itemKeys)
    for _, v in ipairs(itemKeys) do

        local item = self.defs.items[v]
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
                print("Condition " .. i .. " type of v is " .. type(v))

                if v.price then
                    print("Price exists and its type is " .. type(v.price))
                    local p = {}
                    for kk, vv in pairs(v.price) do
                        print("Price key " .. kk .. " value " .. tostring(vv))
                        local priceKey = kk
                        if kk == "currency" then
                            priceKey = shop.currency or "Base.Money"
                            print("Subsituting currency placeholder for " .. priceKey)
                        end
                        if type(vv) == "table" then
                            -- assert this is a range of min/max
                            local newValue = (vv.base or 0) + ZombRand(vv.min or 1, vv.max or 10)
                            print("newValue = " .. newValue)
                            -- vv = newValue
                            p[priceKey] = newValue
                            -- instance.conditions[i].price[priceKey] = newValue
                        else
                            p[priceKey] = vv
                            -- instance.conditions[i].price[priceKey] = vv
                        end
                    end
                    print("Price table is now")
                    instance.conditions[i].price = p
                end
            end

            -- self:debug("Instance", instance)
            items[item.key] = instance
        end
    end
    return items
end

function PhunMart:getShopListFromKey(key)

    local zoneInfo = self:getZoneInfo(key)
    local shops = {}
    local totalProbability = 0

    for k, v in pairs(self.defs.shops) do
        if v.enabled then
            if v.zones then
                if zoneInfo ~= nil then
                    if (v.difficulty and v.difficulty == zoneInfo.difficulty) or
                        (PhunTools:inArray(zoneInfo.name, v.zones)) then
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
        end
    end

    if #shops > 0 then
        return {
            list = shops,
            totalProbability = totalProbability
        }
    else
        print("No shops found for " .. key)
    end

end

function PhunMart:generateShop(vendingMachineOrKey)

    local key = self:getKey(vendingMachineOrKey)
    print("Generating shop for " .. key)
    local shopCandidates = self:getShopListFromKey(key)
    -- self:debug("Shop candidates", shopCandidates)
    local chosenShopDef = nil
    local rand = ZombRand(shopCandidates.totalProbability or 100) + 1
    local cumulative = 0

    for _, entry in ipairs(shopCandidates.list) do
        cumulative = cumulative + entry.probability
        if rand <= cumulative then
            chosenShopDef = self.defs.shops[entry.key]
            break
        end
    end

    local shopInstance = {
        key = chosenShopDef.key or chosenShopDef.name,
        name = chosenShopDef.name,
        vendor = chosenShopDef.name, -- deprecated
        nextRestock = GameTime:getInstance():getWorldAgeHours() + (chosenShopDef.restock or 24),
        backgroundImage = chosenShopDef.backgroundImage or nil,
        requiresPower = chosenShopDef.requiresPower or false,
        layout = chosenShopDef.layout or nil,
        items = {}
    }

    self.shops[key] = shopInstance
    if not self.shoplist[key] or self.shoplist[key].key ~= shopInstance.key then
        self.shoplist[key] = shopInstance.name
        ModData.transmit(self.consts.shoplist)
    end
    shopInstance.items = self:generateShopItems(key, sandbox.CumulativeItemGeneration == true)

    self:debug("Generated shop for " .. key, shopInstance)

    return shopInstance
end

function PhunMart:purchase(playerObj, shopKey, item)
    local shop = PhunMart:getShop(shopKey)
    if shop.items[item.key].inventory ~= false then
        if shop.items[item.key].inventory < 1 then
            sendServerCommand(playerObj, self.name, self.commands.serverPurchaseFailed, {
                playerIndex = playerObj:getPlayerNum(),
                message = "OOS"
            })
            return false
        end
        shop.items[item.key].inventory = shop.items[item.key].inventory - 1
    end
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

local Commands = {}

Commands[PhunMart.commands.rebuildExportItems] = function(playerObj, args)
    local results = PhunMart:exportItems()
    PhunMart:debug("Rebuilding results", args)
    sendServerCommand(playerObj, PhunMart.name, "rebuildExportItems", {
        type = "ITEMS",
        value = args
    })
end

Commands[PhunMart.commands.rebuildPerks] = function(playerObj, args)
    local results = PhunMart:exportPerksBuild()
    PhunMart:debug("Rebuilding perks", arguments)
    sendServerCommand(playerObj, PhunMart.name, "RebuildResults", {
        type = "PERKS",
        value = args
    })
end

Commands[PhunMart.commands.rebuildVehicles] = function(playerObj, args)
    local results = PhunMart:exportVehicleBuild()
    PhunMart:debug("Rebuilding results", arguments)
    sendServerCommand(playerObj, PhunMart.name, "RebuildResults", {
        type = "VEHICLES",
        value = args
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
    local location = PhunMart:xyzFromKey(args.key)
    local machine = PhunMart:getMachineByLocation(playerObj, location.x, location.y, location.z)
    if not machine then
        return
    end
    local shop = PhunMart:getShop(args.key)
    shop.items = PhunMart:generateShopItems(args.key, sandbox.CumulativeItemGeneration == true)
    if not PhunMart.shoplist[args.key] or PhunMart.shoplist[args.key] ~= shop.name then
        PhunMart.shoplist[args.key] = shop.name
        ModData.transmit(PhunMart.consts.shoplist)
    end
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
    print("Generating shop for " .. args.key .. " because we received command requestShopGenerate from client (" ..
              playerObj:getUsername() .. ")")
    local shop = PhunMart:generateShop(machine)
    local wallet = PhunMart:getPlayerData(playerObj:getUsername()).wallet or {}
    sendServerCommand(playerObj, PhunMart.name, PhunMart.commands.requestShop, {
        key = PhunMart:getKey(machine),
        shop = shop,
        wallet = wallet
    })
end

Commands[PhunMart.commands.requestShop] = function(playerObj, args)
    local shop = PhunMart:getShop(args.key)
    if not shop then
        print("Generating shop for " .. args.key ..
                  " because one does not exist and we received command requestShop from client (" ..
                  playerObj:getUsername() .. ")")
        shop = PhunMart:generateShop(args.key)
    end
    if shop then
        local wallet = PhunMart:getPlayerData(playerObj:getUsername()).wallet or {}
        sendServerCommand(playerObj, PhunMart.name, PhunMart.commands.requestShop, {
            key = args.key,
            shop = shop,
            wallet = wallet
        })
    end
end

Commands[PhunMart.commands.buy] = function(playerObj, args)
    local success = PhunMart:purchase(playerObj, args.shopKey, args.item)
    local shop = PhunMart:getShop(args.shopKey)
    if not shop then
        print("Generating shop for " .. args.key .. " because we received buy command from client (" ..
                  playerObj:getUsername() .. ")???")
        shop = PhunMart:generateShop(args.shopKey)
    end
    if shop then
        -- local wallet = PhunMart:getPlayerData(playerObj:getUsername()).wallet or {}
        sendServerCommand(playerObj, PhunMart.name, PhunMart.commands.buy, {
            playerIndex = playerObj:getPlayerNum(),
            success = success,
            key = args.shopKey,
            item = args.item,
            shop = shop
            -- wallet = wallet
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

function PhunMart:checkForRestocking()
    local now = GameTime:getInstance():getWorldAgeHours()
    for k, v in pairs(PhunMart.shops or {}) do
        if (v.nextRestock or 0) < now then
            local shop = PhunMart:getShop(k)
            shop.items = PhunMart:generateShopItems(k, sandbox.CumulativeItemGeneration == true)
            if not PhunMart.defs.shops[shop.key] then
                print("PhunMart: ERROR! Shop " .. shop.key .. " no longer exists in defs")
                shop = self:generateShop(k)
                return
            end
            print(" next restock: " .. (PhunMart.defs.shops[shop.key].restock or 24))
            shop.nextRestock = now + (PhunMart.defs.shops[shop.key].restock or 24)
            if not self.shoplist[k] or self.shoplist[k] ~= shop.name then
                self.shoplist[k] = shop.name
                ModData.transmit(self.consts.shoplist)
            end
            sendServerCommand(PhunMart.name, PhunMart.commands.requestShop, {
                key = k,
                shop = shop
            })
        end
    end
end

function PhunMart:loadAllItems()

    print("---------------------")
    print("-")
    print("- PhunMart: LOADING ITEMDEFS")
    print("-")
    print("---------------------")

    PhunMart:loadFilesForItemQueue()
    PhunMart:processFilesToItemQueue()
    local results = PhunMart:processItemTransformQueue()
    local total = 0

    for k, v in pairs(results.all) do
        total = total + v
    end

    print("Added " .. results.all.success .. " items from:")

    for k, v in pairs(results.files) do
        print(" - Lua/" .. k .. " loaded " .. v.success .. " items")
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
    PhunMart:loadFilesForShopQueue()
    PhunMart:processFilesToShopQueue()
    local results = PhunMart:processShopTransformQueue()
    local total = 0
    for k, v in pairs(results.all) do
        total = total + v
    end

    print("Added " .. results.all.success .. " shops from:")

    for k, v in pairs(results.files) do
        print(" - Lua/" .. k .. " loaded " .. v.success .. " items")
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

end

function PhunMart:loadAll()
    local startTime = getTimestampMs()
    PhunMart:loadAllItems()
    PhunMart:loadAllShops()
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
end)
