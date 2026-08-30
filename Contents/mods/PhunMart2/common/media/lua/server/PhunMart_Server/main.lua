if isClient() then
    return
end
local Core = PhunMart
Core.fileUtils = require "PhunMart_Server/utils_file"
local Migrations = require "PhunMart_Server/migrations"
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
    -- Bring the override files up to date before reading them. Does its work at
    -- most once per session, so the recompile on every save costs nothing.
    Migrations.run()

    -- Read server override files and store the patch tables.
    -- These are sent to clients via requestShopDefs so they can recompile locally
    -- using their own shared defaults + these overrides (no FS access on clients).
    local overrides = {}
    for kind, filenames in pairs(Core.overridePaths) do
        overrides[kind] = overridePatch(filenames)
    end
    Core._lastOverrides = overrides
    return Core.compileWith(overrides)
end

-- Dispatch a single reward action onto a player. Called once per action after deduction.
function Core:grantReward(player, action, qty, context)
    qty = qty or 1
    local t = action.type

    if t == "giveItem" then
        -- action.amount = items granted per purchase (defaults to 1); multiplied by
        -- the purchase quantity. Lets a single action hand out a stack (e.g. physical
        -- currency payouts) without repeating the entry N times.
        local per = tonumber(action.amount) or 1
        if per < 1 then
            per = 1
        end
        local total = math.floor(per) * qty
        local inv = player:getInventory()
        for i = 1, total do
            local item = inv:AddItem(action.item)
            if item then
                sendAddItemToContainer(inv, item)
            else
                Core.debugLn("grantReward: AddItem failed for '" .. tostring(action.item) .. "'")
            end
        end

    elseif t == "addTrait" or t == "removeTrait" then
        local Traits = require "PhunMart/traits"
        local entry = Traits.get(action.trait)
        if entry and entry.def then
            local traitType = entry.def:getType()
            local add = (t == "addTrait")
            if add then
                player:getCharacterTraits():add(traitType)
                player:modifyTraitXPBoost(traitType, false)
            else
                player:getCharacterTraits():remove(traitType)
                player:modifyTraitXPBoost(traitType, true)
            end
            SyncXp(player)
        else
            Core.debugLn("grantReward: no trait def for '" .. tostring(action.trait) .. "'")
        end

    elseif t == "giveXP" then
        local perk = Perks[action.skill]
        if perk then
            addXp(player, perk, (action.amount or 0) * qty)
        else
            Core.debugLn("grantReward: unknown perk '" .. tostring(action.skill) .. "'")
        end

    elseif t == "spawnVehicle" then
        -- Filter scripts to those confirmed in the vehicle database at grant time.
        -- Guards against mods removed after the last compile (post-restock window).
        local scripts = action.scripts or (action.script and {action.script}) or {}
        local validScripts = {}
        for _, s in ipairs(scripts) do
            if Core.vehicleScriptExists(s) then
                table.insert(validScripts, s)
            else
                Core.debugLn("grantReward: vehicle script '" .. s .. "' not found at grant time -- skipped")
            end
        end

        -- Prefer the player's selected script (context.offerItem); validate it too.
        -- Falls back to a random valid script if the selected one is no longer loaded.
        local selected = context and context.offerItem
        local scriptName
        if selected and Core.vehicleScriptExists(selected) then
            scriptName = selected
        elseif #validScripts > 0 then
            scriptName = validScripts[ZombRand(#validScripts) + 1]
        end
        if scriptName then
            local item = player:getInventory():AddItem("PhunMart.VehicleKeySpawner")
            if item then
                sendAddItemToContainer(player:getInventory(), item)
                -- Both ranges travel on the key as ranges, not as rolled numbers.
                -- The roll happens when the key is used, so two keys bought
                -- together are not identical cars.
                local condition = action.args and action.args.condition or nil
                local fuel = action.args and action.args.fuel or nil
                local vehicleLabel = Core.getVehicleLabel(scriptName) or scriptName
                item:setName("Vehicle Claim Key: " .. vehicleLabel)
                item:getModData()["vehicleScript"] = scriptName
                item:getModData()["condition"] = condition
                item:getModData()["fuel"] = fuel
                sendAddItemToContainer(player:getInventory(), item)
                sendServerCommand(player, Core.name, Core.commands.spawnVehicle, {
                    itemId = tostring(item:getID()),
                    vehicleScript = scriptName,
                    condition = condition
                })
            else
                Core.debugLn("grantReward: failed to add VehicleKeySpawner for '" .. scriptName .. "'")
            end
        end

    elseif t == "spawnAnimal" then
        -- Build candidate list from animals[] and/or singular animal+breed.
        local entries = {}
        if type(action.animals) == "table" then
            for _, e in ipairs(action.animals) do
                table.insert(entries, e)
            end
        elseif action.animal or action.typeAnimal then
            table.insert(entries, {
                animal = action.animal or action.typeAnimal,
                breed = action.breed,
                size = action.size
            })
        end
        local valid = {}
        for _, e in ipairs(entries) do
            local aType = e.animal or e.type
            local aBreed = e.breed
            if aType and aBreed and Core.animalTypeExists(aType) and Core.animalBreedExists(aType, aBreed) then
                table.insert(valid, {
                    animal = aType,
                    breed = aBreed,
                    size = e.size or action.size or "medium"
                })
            else
                Core.debugLn("grantReward: animal '" .. tostring(aType) .. "/" .. tostring(aBreed) ..
                                 "' not found at grant time -- skipped")
            end
        end

        local selected = nil
        -- Prefer offer.item when it encodes "type:breed" and is still valid.
        local offerItem = context and context.offerItem
        if type(offerItem) == "string" and offerItem:find(":") then
            local oType, oBreed = offerItem:match("^([^:]+):(.+)$")
            if oType and oBreed and Core.animalTypeExists(oType) and Core.animalBreedExists(oType, oBreed) then
                selected = {
                    animal = oType,
                    breed = oBreed,
                    size = action.size or "medium"
                }
            end
        end
        if not selected and #valid > 0 then
            selected = valid[ZombRand(#valid) + 1]
        end

        if selected then
            local item = player:getInventory():AddItem("PhunMart.AnimalClaimToken")
            if item then
                sendAddItemToContainer(player:getInventory(), item)
                local size = selected.size or "medium"
                local weight = (Core.animalClaimWeights and Core.animalClaimWeights[size]) or 5.0
                item:setWeight(weight)
                if item.setActualWeight then
                    item:setActualWeight(weight)
                end
                local label = Core.getAnimalLabel(selected.animal, selected.breed)
                item:setName("Livestock Claim: " .. label)
                item:getModData()["animalType"] = selected.animal
                item:getModData()["animalBreed"] = selected.breed
                item:getModData()["animalSize"] = size
                sendAddItemToContainer(player:getInventory(), item)
                sendServerCommand(player, Core.name, Core.commands.spawnAnimal, {
                    itemId = tostring(item:getID()),
                    animalType = selected.animal,
                    animalBreed = selected.breed,
                    animalSize = size
                })
            else
                Core.debugLn("grantReward: failed to add AnimalClaimToken for '" .. selected.animal .. "/" ..
                                 selected.breed .. "'")
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

--- How far the nearest machine of each shop type is, and of each category.
---
--- Two results because spacing wants both questions answered. Type keeps two
--- of the same machine apart. Category keeps two of a kind apart: WrentAWreck
--- and CarAParts are both Vehicle, and putting them on the same street is the
--- thing minDistance was meant to prevent but never could, because it only
--- ever compared a shop against others of its own type.
---
--- `ignore` is one instance table to leave out, for a machine asking what it
--- could become: it stands exactly where the answer would go, so counted in it
--- rules out its own type at distance zero and everything sharing its category
--- along with it.
---
--- Matched by identity or by position, and it needs both. Usually the caller
--- holds the very table that was registered, but relocateShop registers a fresh
--- literal rather than the object's modData, so after a move the identity test
--- alone would quietly stop matching. Position is the thing actually being
--- asked about, and identity covers the case where two entries somehow share a
--- tile.
local function isIgnored(v, ignore)
    if not ignore then
        return false
    end
    if v == ignore then
        return true
    end
    return v.x == ignore.x and v.y == ignore.y and (v.z or 0) == (ignore.z or 0)
end

function Core:getInstanceDistancesFrom(x, y, ignore)
    local byType, byCategory = {}, {}
    for k, v in pairs(self.shops) do
        if v.enabled ~= false then
            byType[k] = 9999999
            if v.category then
                byCategory[v.category] = 9999999
            end
        end
    end

    for k, v in pairs(self.instances) do
        -- Skipped before the type check rather than folded into it, so the
        -- deliberate omission does not reach the warning below and read as a
        -- machine with a broken type.
        if not isIgnored(v, ignore) then
            local shopType = Core.isShopInstance(v) and v.type or nil
            if shopType and byType[shopType] then
                local dx = x - v.x
                local dy = y - v.y
                local distance = math.sqrt(dx * dx + dy * dy)
                if distance < byType[shopType] then
                    byType[shopType] = distance
                end
                local cat = self.shops[shopType] and self.shops[shopType].category
                if cat and byCategory[cat] and distance < byCategory[cat] then
                    byCategory[cat] = distance
                end
            else
                Core.debugLn("No shop with type " .. tostring(shopType) .. " (instance " .. k .. ")")
            end
        end
    end

    return byType, byCategory
end

local restockStamps = nil

--- Admin-forced restock stamps, in a ModData table of their own.
---
--- These were two keys on the "PhunMart" table, which is also the shop instance
--- table: Core.instances is that same object, and four places walk it expecting
--- every value to be a machine. forceRestockTypeAt is a map of shop type to
--- timestamp, so the locations list drew it as a machine with no coordinates,
--- getInstanceDistancesFrom subtracted from a nil x, and removeInvalidInstanceData
--- deleted both stamps on every boot for not matching a loaded object. That last
--- one means a forced restock has never survived a restart, which is the one job
--- the stamps exist to do.
---
--- Moved rather than guarded at each walk, because the next thing stored beside
--- the instances would break them again the same way.
function Core.restockStamps()
    if restockStamps then
        return restockStamps
    end
    restockStamps = ModData.getOrCreate("PhunMart_Restock")
    -- One-time move of whatever the old layout left behind. Cheap, and the
    -- alternative is every existing save losing a pending forced restock.
    local old = ModData.getOrCreate("PhunMart")
    if old.forceRestockAt ~= nil then
        restockStamps.forceRestockAt = old.forceRestockAt
        old.forceRestockAt = nil
    end
    if old.forceRestockTypeAt ~= nil then
        restockStamps.forceRestockTypeAt = old.forceRestockTypeAt
        old.forceRestockTypeAt = nil
    end
    return restockStamps
end

--- Roll every affected machine once, when the shipped definitions have changed
--- since this save last started.
---
--- The marker lives in the per-save restock ModData rather than in State, which
--- is per install: one machine shared by two saves has to see this once for each
--- of them, not once in total.
---
--- Nothing restocks here directly. Stamping is enough and is what an admin's
--- Restock All does too: a loaded machine services the stamp the next time it is
--- asked, and one in an unloaded chunk services it when that chunk loads.
function Core.restockForChangedDefinitions()
    local stamps = Core.restockStamps()
    if stamps.defsRevision == Core.defsRevision then
        return
    end
    stamps.defsRevision = Core.defsRevision

    -- Same rounding as restockAll, so a machine that services this stamp cannot
    -- come back with a rounded-down lastRestock that still looks older than it.
    local now = tonumber(string.format("%.1f", GameTime:getInstance():getWorldAgeHours()))

    local types = Core.defsRevisionShops
    if types == nil then
        stamps.forceRestockAt = now
        Core.debugLn("definitions revision " .. tostring(Core.defsRevision) ..
                         ": every shop will restock, stamped at " .. tostring(now))
        return
    end

    stamps.forceRestockTypeAt = stamps.forceRestockTypeAt or {}
    local named = {}
    for _, t in ipairs(types) do
        stamps.forceRestockTypeAt[t] = now
        table.insert(named, t)
    end
    Core.debugLn("definitions revision " .. tostring(Core.defsRevision) .. ": " ..
                     table.concat(named, ", ") .. " will restock, stamped at " .. tostring(now))
end

function Core:ini()
    self.inied = true
    self.instances = ModData.getOrCreate(self.name)
    -- Before removeInvalidInstanceData, which would otherwise delete the old
    -- stamp keys as unrecognised instances before they could be moved.
    Core.restockStamps()
    self.lastStart = getTimestamp()
    Core.ServerSystem.instance:removeInvalidInstanceData()
    Core.compile()

    -- After compile: the stamp is only worth setting once the definitions it
    -- refers to have actually loaded.
    Core.restockForChangedDefinitions()

    -- Load token rewards config: try server override file first, then built-in defaults.
    local ok, tokenDefaults = pcall(require, "PhunMart/defaults/token_rewards")
    Core.tokenRewardsCfg = Core.fileUtils.loadTable(Core.configFiles.tokenRewards) or (ok and tokenDefaults) or {}

    -- Wire playtime and kill-tracking modules.
    require "PhunMart_Server/rewards_playtime"
    require "PhunMart_Server/rewards_kill"

    require "PhunMart_Server/player_data"

    -- All four bind to their ModData table, so they belong to this save. The
    -- import that follows is a one-off for anyone upgrading from the version
    -- that kept them in files, and needs the tables to exist first.
    Core.playtimeRewards:load()
    Core.killRewards:load()
    Core.purchases:load()
    Core.wallet:load()
    Core.playerData.importLegacy()
    Core.debug("Server System initialized")
    triggerEvent(self.events.OnReady, self)
end

