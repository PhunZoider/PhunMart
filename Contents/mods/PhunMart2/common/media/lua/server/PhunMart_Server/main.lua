if isClient() then
    return
end
local Core = PhunMart
Core.fileUtils = require "PhunMart_Server/utils_file"
Core.instances = {}

-- Load an optional server-side override file from disk. Returns {} if absent.
-- Only called server-side; clients never read the filesystem.
local function loadOverride(filename)
    return Core.fileUtils.loadTable(filename) or {}
end

-- Merge multiple server override files for one category into a single patch table.
local function overridePatch(filenames)
    local patch = {}
    for _, name in ipairs(filenames) do
        for k, v in pairs(loadOverride(name)) do
            patch[k] = v
        end
    end
    return patch
end

function Core.compile()
    -- Read server override files and store the patch tables.
    -- These are sent to clients via requestShopDefs so they can recompile locally
    -- using their own shared defaults + these overrides (no FS access on clients).
    local overrides = {
        prices         = overridePatch({"PhunMart_Prices.lua"}),
        specials       = overridePatch({"PhunMart_Specials.lua", "PhunMart_XP_Rewards.lua"}),
        conditionsDefs = overridePatch({"PhunMart_Conditions.lua", "PhunMart_XP_Conditions.lua"}),
        items          = overridePatch({"PhunMart_Items.lua", "PhunMart_XP_Items.lua"}),
        groups         = overridePatch({"PhunMart_Groups.lua"}),
        pools          = overridePatch({"PhunMart_Pools.lua"}),
        shops          = overridePatch({"PhunMart_Shops.lua"}),
    }
    Core._lastOverrides = overrides
    return Core.compileWith(overrides)
end

-- Dispatch a single reward action onto a player. Called once per action after deduction.
function Core:grantReward(player, action, qty, context)
    qty = qty or 1
    local t = action.type

    if t == "giveItem" then
        local inv = player:getInventory()
        for i = 1, qty do
            local item = inv:AddItem(action.item)
            if item then
                sendAddItemToContainer(inv, item)
            else
                Core.debugLn("grantReward: AddItem failed for '" .. tostring(action.item) .. "'")
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
            Core.debugLn("grantReward: unknown perk '" .. tostring(action.skill) .. "'")
        end

    elseif t == "spawnVehicle" then
        -- Use the offer's specific vehicle (context.offerItem) so the player gets
        -- exactly the vehicle they selected, not a random pick from the reward pool.
        local scripts = action.scripts or (action.script and {action.script}) or {}
        local scriptName = (context and context.offerItem) or (#scripts > 0 and scripts[ZombRand(#scripts) + 1]) or nil
        if scriptName then
            local item = player:getInventory():AddItem("PhunMart.VehicleKeySpawner")
            if item then
                local condition = action.args and action.args.condition or nil
                local vehicleLabel = Core.getVehicleLabel(scriptName) or scriptName
                item:setName("Vehicle Claim Key: " .. vehicleLabel)
                item:getModData()["vehicleScript"] = scriptName
                item:getModData()["condition"] = condition
                -- transmitModData may not exist in B42; send a dedicated command instead
                sendServerCommand(player, Core.name, Core.commands.spawnVehicle, {
                    itemId = tostring(item:getID()),
                    vehicleScript = scriptName,
                    condition = condition
                })
            else
                Core.debugLn("grantReward: failed to add VehicleKeySpawner for '" .. scriptName .. "'")
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
            Core.debugLn("grantReward: applyBoost failed for '" .. tostring(action.skill) .. "': " .. tostring(err))
        end

    elseif t == "grantBoundTokens" then
        -- Grant bound tokens: credited to both current (spendable) and bound (death-restored) pools.
        local amt = (action.amount or 1) * qty
        Core.wallet:adjustByPool(player, "current", "tokens", amt)
        Core.wallet:adjustByPool(player, "bound", "tokens", amt)

    elseif t == "adjustBalance" then
        -- Credit a wallet pool (e.g. change from pawn shop sales).
        local amt = (action.amount or 0) * qty
        Core.wallet:adjustByPool(player, "current", action.pool or "change", amt)

    else
        Core.debugLn("grantReward: unknown action type '" .. tostring(t) .. "'")
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

local function instanceId(instance)
    return tostring(instance.x) .. "_" .. tostring(instance.y) .. "_" .. tostring(instance.z or 0)
end

function Core:addInstance(instance)
    self.instances[instanceId(instance)] = instance
end
function Core:removeInstance(instance)
    self.instances[instanceId(instance)] = nil
end

function Core:getInstanceDistancesFrom(x, y)
    local results = {}
    for k, v in pairs(self.shops) do
        if v.enabled ~= false then
            results[k] = 9999999
        end
    end

    for k, v in pairs(self.instances) do
        local shopType = v.type
        if results[shopType] then
            local dx = x - v.x
            local dy = y - v.y
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance < results[shopType] then
                results[shopType] = distance
            end
        else
            Core.debugLn("No shop with type " .. tostring(shopType) .. " (instance " .. k .. ")")
        end
    end

    return results
end


function Core:ini()
    self.inied = true
    self.instances = ModData.getOrCreate(self.name)
    self.lastStart = getTimestamp()
    Core.ServerSystem.instance:removeInvalidInstanceData()
    Core.compile()

    -- Load token rewards config: try server override file first, then built-in defaults.
    local ok, tokenDefaults = pcall(require, "PhunMart/defaults/token_rewards")
    Core.tokenRewardsCfg = Core.fileUtils.loadTable("PhunMart_TokenRewards.lua") or (ok and tokenDefaults) or {}

    -- Wire playtime and kill-tracking modules.
    require "PhunMart_Server/rewards_playtime"
    require "PhunMart_Server/rewards_kill"
    Core.playtimeRewards:load()
    Core.killRewards:load()
    Core.purchases:load()
    Core.wallet:load()
    Core.debug("Server System initialized")
    triggerEvent(self.events.OnReady, self)
end

