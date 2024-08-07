if not isServer() then
    return
end
local sandbox = SandboxVars.PhunMart
local PhunMart = PhunMart
local PhunTools = PhunTools

PhunMart.defs = {
    shops = {},
    items = {},
    currencies = {}
}

function PhunMart:itemGenerationCumulativeModel(shop, poolIndex)

    -- add all item probabilities together and then roll against that
    -- this makes the chance relative to other items probability

    local pool = shop.pools.items[poolIndex]
    if not pool or not pool.keys or #pool.keys == 0 then
        -- HOUSTON WE HAVE A PROBLEM
        print("No pool or keys for " .. shop.key .. ", pi=" .. poolIndex)
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
    shopInstance.items = items
    self:setShopInstanceItems(shopInstance)
    return items
end

function PhunMart:getShopListFromKey(location)

    local distances = SPhunMartSystem.instance:closestShopTypesTo(location)

    print("Distances")
    print("----------")
    PhunTools:printTable(distances)
    print("----------")

    local zoneInfo = self:getZoneInfo(location)

    local shops = {}
    local totalProbability = 0

    for k, v in pairs(self.defs.shops) do
        if v.enabled and (v.reservations == nil or v.reservations == false) and not v.abstract then

            local minDistance = (v.minDistance or 0)
            local distanceKey = v.type or v.key
            local distance = distances[distanceKey] and distances[distanceKey].distance or 0

            print("Min distance for " .. tostring(v.key) .. " is " .. tostring(minDistance) .. " and distance is " ..
                      tostring(distance) .. " using distanceKey " .. tostring(distanceKey))

            if minDistance == 0 or not distances[distanceKey] or (minDistance < distances[distanceKey].distance) then
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
                        print(" - Difficulty range " .. tostring(difficultyMin) .. " to " .. tostring(difficultyMax))
                    end

                    local names = v.zones.keys or {}

                    if zoneInfo ~= nil then

                        local difficultyOk = (zoneInfo.difficulty and
                                                 (zoneInfo.difficulty >= difficultyMin and zoneInfo.difficulty <=
                                                     difficultyMax))
                        local nameOk = names[zoneInfo.key] ~= false

                        if difficultyOk and nameOk then

                            table.insert(shops, {
                                key = k,
                                probability = v.probability or sandbox.DefaultItemProbability or 1
                            })
                            totalProbability = totalProbability + (v.probability or sandbox.DefaultItemProbability or 1)
                        else
                            if not difficultyOk then
                                print(" - Skipping " .. v.key .. " because difficulty is out of range")
                            end
                            if not nameOk then
                                print(" - Skipping " .. v.key .. " because zone " .. zoneInfo.key .. " is not allowed")
                            end
                        end
                    else
                        print(" - Skipping " .. v.key .. " because no zone info")
                    end
                else
                    table.insert(shops, {
                        key = k,
                        probability = v.probability or sandbox.DefaultItemProbability or 1
                    })
                    totalProbability = totalProbability + (v.probability or sandbox.DefaultItemProbability or 1)
                end
            else
                print(" - Skipping " .. v.key .. " because there is another too close")
            end
        end
    end

    if #shops > 0 then
        return {
            list = shops,
            totalProbability = totalProbability
        }

    else
        self:debug("No shop candidates found for", location)
    end

end

function PhunMart:generateShop(vendingMachineOrKey, forceKey)

    local key = self:getKey(vendingMachineOrKey)
    local location = self:xyzFromKey(key)
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
            local shopCandidates = self:getShopListFromKey(location)
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
        id = key,
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

    shopInstance.items = self:generateShopItems(shopInstance, sandbox.CumulativeItemGeneration == true)
    self.shops[key] = shopInstance
    return shopInstance
end

function PhunMart:setShopInstanceItems(shopInstance)

    local checked = {};
    shopInstance.tabs = {}
    for i, item in pairs(shopInstance.items) do
        if not item.tab then
            item.tab = "Misc"
        end
        if checked[item.tab] == nil then
            checked[item.tab] = true
            table.insert(shopInstance.tabs, item.tab)
        end
    end

    table.sort(shopInstance.tabs, function(a, b)
        return a < b
    end)

    shopInstance.restockDeferred = false
    shopInstance.lastRestock = GameTime:getInstance():getWorldAgeHours()

end

function PhunMart:addToPurchaseHistory(playerObj, item)

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

end

local spritesSheets = {"01", "02", "03"}
local spritePos = {
    east = 0,
    south = 1,
    west = 2,
    north = 3
}

function PhunMart:resolveSprite(sheet, row, direction, nopower)

    -- print("resolveSprite ", tostring(sheet), " ", tostring(row), " ", tostring(direction), " ", tostring(nopower))

    local actualRow = (row - 1) * 8

    local rowbit = actualRow + spritePos[direction]
    if nopower then
        -- is powered down
        rowbit = rowbit + 4
    end

    local spite = "phunmart_" .. spritesSheets[sheet] .. "_" .. rowbit
    -- print("resolveSprite ", tostring(spite), " sheet=", tostring(sheet), " row=", tostring(row), " dir=",
    --     tostring(direction), " noPower=", tostring(nopower), " actualRow=", tostring(actualRow), " rowbit=",
    --     tostring(rowbit))
    return spite
end

