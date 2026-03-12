if isClient() then
    return
end
local Core = PhunMart
Core.instances = {}

-- Deep merge: maps are merged recursively; arrays and primitives are replaced by patch.
local function deepMerge(base, patch)
    if type(patch) ~= "table" then
        return patch
    end
    if type(base) ~= "table" then
        return patch
    end
    if patch[1] ~= nil then
        return patch
    end -- array: replace entirely
    local result = {}
    for k, v in pairs(base) do
        result[k] = v
    end
    for k, v in pairs(patch) do
        if type(v) == "table" and type(result[k]) == "table" and v[1] == nil then
            result[k] = deepMerge(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

-- Load a baked-in default file from the mod via require.
-- Defaults only change when the mod is updated (restart required), so caching is fine.
local function loadDefaults(path)
    local ok, result = pcall(require, path)
    if not ok then
        print("PhunMart: Warning: could not load defaults '" .. path .. "': " .. tostring(result))
        return {}
    end
    return result or {}
end

-- Load an optional server-side override file. Returns {} if not present.
local function loadOverride(filename)
    return Core.tools.loadTable(filename) or {}
end

-- Merge multiple default files (key union, no conflicts expected), then apply
-- multiple override files on top via deep merge.
local function buildCtx(defaultPaths, overrideNames)
    local base = {}
    for _, path in ipairs(defaultPaths) do
        for k, v in pairs(loadDefaults(path)) do
            base[k] = v
        end
    end
    local patch = {}
    for _, name in ipairs(overrideNames) do
        for k, v in pairs(loadOverride(name)) do
            patch[k] = v
        end
    end
    return deepMerge(base, patch)
end

function Core.compile()

    local ctx = {
        prices = buildCtx({"PhunMart2/defaults/prices"}, {"PhunMart2_Prices.lua"}),
        rewards = buildCtx({"PhunMart2/defaults/rewards", "PhunMart2/defaults/xp_rewards"},
            {"PhunMart2_Rewards.lua", "PhunMart2_XP_Rewards.lua"}),
        conditionsDefs = buildCtx({"PhunMart2/defaults/conditions", "PhunMart2/defaults/xp_conditions"},
            {"PhunMart2_Conditions.lua", "PhunMart2_XP_Conditions.lua"}),
        items = buildCtx({"PhunMart2/defaults/items", "PhunMart2/defaults/xp_items"},
            {"PhunMart2_Items.lua", "PhunMart2_XP_Items.lua"}),
        groups = buildCtx({"PhunMart2/defaults/groups"}, {"PhunMart2_Groups.lua"}),
        pools = buildCtx({"PhunMart2/defaults/pools"}, {"PhunMart2_Pools.lua"}),
        shops = buildCtx({"PhunMart2/defaults/shops"}, {"PhunMart2_Shops.lua"})
    }

    local runtime, log = Core.compiler.compileAll(ctx)
    Core.runtime = runtime
    Core.shops = runtime.shops -- alias: all Core.shops readers now use compiled data
    Core:reloadShopDefinitions() -- rebuild spriteToShop from compiled sprites
    Core.tools.debug("Warn", log.warnings, "Errors", log.errors)
    return runtime, log

end

-- Dispatch a single reward action onto a player. Called once per action after deduction.
function Core:grantReward(player, action, qty)
    qty = qty or 1
    local t = action.type

    if t == "giveItem" then
        for i = 1, qty do
            local item = player:getInventory():AddItem(action.item)
            if not item then
                print("[PhunMart2] grantReward: AddItem failed for '" .. tostring(action.item) .. "'")
            end
        end

    elseif t == "addTrait" or t == "removeTrait" then
        -- CharacterTraitDefinition is client-side only. Delegate to the client
        -- which has the full definition cache and can apply the trait correctly.
        if Core.isLocal then
            triggerEvent(Core.events.OnApplyTraitReward, {
                trait = action.trait,
                add = (t == "addTrait"),
                player = player
            })
        else
            sendServerCommand(player, Core.name, Core.commands.applyTraitReward, {
                playerIndex = player:getPlayerNum(),
                trait = action.trait,
                add = (t == "addTrait")
            })
        end

    elseif t == "giveXP" then
        local perk = Perks[action.skill]
        if perk then
            addXp(player, perk, (action.amount or 0) * qty)
        else
            print("[PhunMart2] grantReward: unknown perk '" .. tostring(action.skill) .. "'")
        end

    elseif t == "spawnVehicle" then
        local scripts = action.scripts or (action.script and {action.script}) or {}
        if #scripts > 0 then
            local scriptName = scripts[ZombRand(#scripts) + 1]
            local vehicle = addVehicleDebug(scriptName, IsoDirections.S, nil, player:getSquare())
            if vehicle then
                local args = action.args or {}
                -- Apply condition range
                local cond = args.condition
                if cond then
                    local v = type(cond) == "table" and ZombRand(cond.min or 40, (cond.max or 80) + 1) or cond
                    for i = 0, vehicle:getPartCount() - 1 do
                        pcall(function()
                            vehicle:getPartByIndex(i):setCondition(v)
                        end)
                    end
                end
                -- Give key to player
                pcall(function()
                    player:sendObjectChange("addItem", {
                        item = vehicle:createVehicleKey()
                    })
                end)
            end
        end

    elseif t == "applyBoost" then
        local ok, err = pcall(function()
            local perk = Perks[action.skill]
            if not perk then
                error("unknown perk: " .. tostring(action.skill))
            end
            local level = math.min(3, math.max(1, math.floor(action.multiplier or 1)))
            player:getXp():setPerkBoost(perk, level)
            SyncXp(player)
        end)
        if not ok then
            print("[PhunMart2] grantReward: applyBoost failed for '" .. tostring(action.skill) .. "': " .. tostring(err))
        end

    else
        print("[PhunMart2] grantReward: unknown action type '" .. tostring(t) .. "'")
    end
end

-- Grant a reward from token reward config (playtime/kill).
-- reward: { item="PhunMart.Token", amount=1 }
-- For bound currency items, credits both current and bound wallet pools.
-- For regular items, spawns into player inventory.
-- reason: display string included in the notification message.
function Core:grantConfigReward(player, reward, reason)
    local item = reward.item
    local amount = reward.amount or 1
    local currency = Core.wallet.currencies[item]

    if currency then
        local totalValue = currency.value * amount
        Core.wallet:adjustByPool(player, "current", currency.pool, totalValue)
        if currency.bound then
            Core.wallet:adjustByPool(player, "bound", currency.pool, totalValue)
        end
    else
        for i = 1, amount do
            player:getInventory():AddItem(item)
        end
    end

    local label = currency and (amount .. " " .. currency.pool) or (amount .. "x " .. item)
    local msg = "+" .. label .. " (" .. reason .. ")"
    local wallet = Core.wallet:get(player)

    if Core.isLocal then
        triggerEvent(Core.events.OnRewardGranted, {
            message = msg,
            wallet = wallet,
            username = player:getUsername()
        })
    else
        sendServerCommand(player, Core.name, Core.commands.grantReward, {
            playerIndex = player:getPlayerNum(),
            username = player:getUsername(),
            message = msg,
            wallet = wallet
        })
    end
end

function Core:addInstance(instance)
    self.instances[instance.key] = instance
end
function Core:removeInstance(instance)
    self.instances[instance.key] = nil
end

function Core:getInstanceDistancesFrom(x, y)
    local results = {}
    for k, v in pairs(self.shops) do
        if v.enabled ~= false then
            results[k] = 9999999
        end
    end

    for k, v in pairs(self.instances) do
        if results[v.key] then

            local dx = x - v.x
            local dy = y - v.y
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance < results[v.key] then
                results[v.key] = distance
            end
        else
            print("PhunMart Error: No shop with key " .. k)
        end
    end

    return results
end

function Core:getPoolItems(pool)
    local items = {}
    local filters = pool.filters or {}

    if filters.items then
        local allItems = Core.tools.getAllItems()
        for _, v in ipairs(allItems) do
            if not filters.items.exclude[v.type] then
                if filters.items.include[v.type] or filters.items.categories[v.category] then
                    table.insert(items, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        texture = v.texture,
                        source = "items"
                    })
                end
            end
        end
    end

    if filters.vehicles then
        local allCars = Core.getAllVehicles()
        for _, v in ipairs(allCars) do
            if not filters.vehicles.exclude[v.type] then
                if filters.vehicles.include[v.type] or filters.vehicles.categories[v.category] then
                    table.insert(items, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        source = "vehicles"
                    })
                end
            end
        end
    end

    if filters.traits then
        local allTraits = Core.getAllTraits()
        for _, v in ipairs(allTraits) do
            if not filters.traits.exclude[v.type] then
                if filters.traits.include[v.type] or filters.traits.categories[v.category] then
                    table.insert(items, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        texture = v.texture,
                        source = "traits"
                    })
                end
            end
        end
    end

    if filters.xp then
        local allXp = Core.getAllXp()
        for _, v in ipairs(allXp) do
            if not filters.xp.exclude[v.type] then
                if filters.xp.include[v.type] or filters.xp.categories[v.category] then
                    table.insert(items, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        texture = v.texture,
                        source = "xp"
                    })
                end
            end
        end
    end

    if filters.boosts then
        local allBoosts = Core.getAllBoosts()
        for _, v in ipairs(allBoosts) do
            if not filters.boosts.exclude[v.type] then
                if filters.boosts.include[v.type] or filters.boosts.categories[v.category] then
                    table.insert(items, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        texture = v.texture,
                        source = "boosts"
                    })
                end
            end
        end
    end

    table.sort(items, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    return items
end

function Core:ini()
    self.inied = true
    self.instances = ModData.getOrCreate(self.name)
    self.lastStart = getTimestamp()
    Core.ServerSystem.instance:removeInvalidInstanceData()
    Core.compile()

    -- Load token rewards config: try server override file first, then built-in defaults.
    local ok, tokenDefaults = pcall(require, "PhunMart2/defaults/token_rewards")
    Core.tokenRewardsCfg = Core.tools.loadTable("PhunMart2_TokenRewards.lua") or (ok and tokenDefaults) or {}

    -- Wire playtime and kill-tracking modules.
    require "PhunMart2/playtime_rewards"
    require "PhunMart2/kill_rewards"
    Core.playtimeRewards:load()
    Core.killRewards:load()
    Core.debug("Server System initialized", self:getShops())
    triggerEvent(self.events.OnReady, self)
end

