-- PhunMart2/conditions_runtime.lua
require("PhunMart2/core")
local Core = PhunMart

Core.conditionsRuntime = Core.conditionsRuntime or {}
local R = Core.conditionsRuntime

-- helper: add a localized failure entry
local function addFail(out, key, textKey, args)
    out.ok = false
    out.failures[#out.failures + 1] = {
        condKey = key,        -- e.g. "minHours"
        textKey = textKey,    -- e.g. "IGUI_PhunMart_Cond_WorldAgeBetween"
        args = args or {}
    }
end

-- Used when you want “any” failures to be grouped nicely
local function addGroupFail(out, groupTextKey, groupArgs, details)
    out.ok = false
    out.failures[#out.failures + 1] = {
        group = true,
        textKey = groupTextKey,
        args = groupArgs or {},
        details = details -- array of {condKey,textKey,args}
    }
end

-- =========================================================
-- Player adapter expectation (real or mocked)
-- =========================================================
-- adapter:getPerkLevel(perkName) -> number
-- adapter:getPerkBoost(perkName) -> number (0..3?) or nil
-- adapter:hasTrait(traitName) -> boolean
-- adapter:getProfession() -> string
-- adapter:countItem(fullType) -> number
-- adapter:getWorldAgeHours() -> number
-- adapter:getUsername() -> string
-- adapter:getCharacterName() -> string
-- adapter:nowSeconds() -> number

-- =========================================================
-- Purchase store expectation
-- =========================================================
-- purchases:getCount(scope, username, charId, condKeyOrItemKey, windowSeconds?) -> count
-- purchases:getCooldownRemainingSeconds(...) -> optional
-- (You can keep your existing table layout; wrap it with these functions.)

-- =========================================================
-- Trait definition cache (lazy, built on first use)
-- Keyed by trait type string e.g. "base:slowlearner"
-- =========================================================
local traitDefCache = nil

local function getTraitDefCache()
    if traitDefCache then return traitDefCache end
    traitDefCache = {}
    if not CharacterTraitDefinition then return traitDefCache end
    local ok, err = pcall(function()
        local traits = CharacterTraitDefinition.getTraits()
        for i = 0, traits:size() - 1 do
            local t = traits:get(i)
            if t then
                local key = tostring(t:getType())
                local mutex = {}
                local disabledMP = false
                pcall(function()
                    local mlist = t:getMutuallyExclusiveTraits()
                    if mlist then
                        for j = 0, mlist:size() - 1 do
                            local m = mlist:get(j)
                            if m then mutex[#mutex+1] = tostring(m) end
                        end
                    end
                    disabledMP = t:isRemoveInMP()
                end)
                traitDefCache[key] = { mutex = mutex, disabledMP = disabledMP }
            end
        end
    end)
    if not ok then
        print("[PhunMart2] traitDefCache build error: " .. tostring(err))
    end
    return traitDefCache
end

-- =========================================================
-- Test implementations
-- Each returns: ok:boolean, failTextKey:string|nil, failArgs:table|nil
-- =========================================================
R.tests = {}

R.tests.worldAgeHoursBetween = function(args, adapter)
    local wh = adapter:getWorldAgeHours() or 0
    if args.min and wh < args.min then
        return false, "IGUI_PhunMart_Cond_WorldAgeMin", { args.min, wh }
    end
    if args.max and wh > args.max then
        return false, "IGUI_PhunMart_Cond_WorldAgeMax", { args.max, wh }
    end
    return true
end

R.tests.perkLevelBetween = function(args, adapter)
    local perk = args.perk
    local lvl = adapter:getPerkLevel(perk) or 0
    if args.min and lvl < args.min then
        return false, "IGUI_PhunMart_Cond_PerkLevelMin", { perk, args.min, lvl }
    end
    if args.max and lvl > args.max then
        return false, "IGUI_PhunMart_Cond_PerkLevelMax", { perk, args.max, lvl }
    end
    return true
end

R.tests.perkBoostBetween = function(args, adapter)
    local perk = args.perk
    local b = adapter:getPerkBoost(perk) or 0
    if args.min and b < args.min then
        return false, "IGUI_PhunMart_Cond_PerkBoostMin", { perk, args.min, b }
    end
    if args.max and b > args.max then
        return false, "IGUI_PhunMart_Cond_PerkBoostMax", { perk, args.max, b }
    end
    return true
end

R.tests.professionIn = function(args, adapter)
    local prof = adapter:getProfession()
    local list = args.professions or {}
    for _, p in ipairs(list) do
        if prof == p then return true end
    end
    return false, "IGUI_PhunMart_Cond_ProfessionIn", { tostring(prof) }
end

R.tests.hasItems = function(args, adapter)
    local items = args.items or {}
    for _, req in ipairs(items) do
        local fullType = req.item
        local need = req.amount or 1
        local have = adapter:countItem(fullType) or 0
        if have < need then
            return false, "IGUI_PhunMart_Cond_HasItem", { fullType, need, have }
        end
    end
    return true
end

R.tests.purchaseCountMax = function(args, adapter, purchases, context)
    local max = args.max
    local scope = args.scope or "player_item_shop"
    local username = adapter:getUsername()
    local charId = adapter:getCharacterId()

    -- IMPORTANT: decide what key you count against.
    -- I recommend defaulting to the offerId or itemType from context (so each offer can have its own limit).
    local countKey = args.key or (context and (context.offerId or context.itemType)) or "unknown"

    local windowSeconds = args.windowSeconds -- optional future extension
    local used = purchases and purchases:getCount(scope, username, charId, countKey, windowSeconds) or 0

    if max and used >= max then
        -- optional “cooldown” message if windowSeconds is used
        if windowSeconds and purchases and purchases.getCooldownRemainingSeconds then
            local rem = purchases:getCooldownRemainingSeconds(scope, username, charId, countKey, windowSeconds)
            if rem and rem > 0 then
                return false, "IGUI_PhunMart_Cond_PurchaseCooldown", { countKey, rem }
            end
        end
        return false, "IGUI_PhunMart_Cond_PurchaseMax", { countKey, used, max }
    end

    return true
end


-- Auto-injected by compiler for grantTrait reward actions.
-- Checks: player doesn't already have the trait, no mutex conflict, not disabled in MP.
R.tests.canGrantTrait = function(args, adapter)
    local traitKey = args.trait
    if not traitKey then
        return false, "IGUI_PhunMart_Cond_TraitKeyMissing", {}
    end

    if adapter:hasTrait(traitKey) then
        return false, "IGUI_PhunMart_Cond_AlreadyHasTrait", { traitKey }
    end

    local cache = getTraitDefCache()
    local def = cache[traitKey]
    if def then
        if def.disabledMP and isClient and isClient() then
            return false, "IGUI_PhunMart_Cond_TraitDisabledMP", { traitKey }
        end
        for _, mutexKey in ipairs(def.mutex) do
            if adapter:hasTrait(mutexKey) then
                return false, "IGUI_PhunMart_Cond_TraitMutex", { traitKey, mutexKey }
            end
        end
    end

    return true
end

function R.evaluate(conditionsBlock, conditionsDefs, adapter, purchases, context)
    local out = { ok = true, failures = {} }
    if not conditionsBlock then return out end

    local function evalKey(condKey)
        local def = conditionsDefs and conditionsDefs[condKey]
        if type(def) ~= "table" then
            return false, "IGUI_PhunMart_Cond_UnknownKey", { tostring(condKey) }
        end

        local testName = def.test
        local fn = R.tests[testName]
        if not fn then
            return false, "IGUI_PhunMart_Cond_UnknownTest", { tostring(condKey), tostring(testName) }
        end

        local ok, textKey, args = fn(def.args or {}, adapter, purchases, context)
        if ok then return true end
        return false, textKey or "IGUI_PhunMart_Cond_Failed", args or { tostring(condKey) }
    end

    -- ALL
    if conditionsBlock.all then
        for _, k in ipairs(conditionsBlock.all) do
            local ok, textKey, args = evalKey(k)
            if not ok then
                addFail(out, k, textKey, args)
            end
        end
    end

    -- ANY (at least one must pass)
    if conditionsBlock.any and #conditionsBlock.any > 0 then
        local anyOk = false
        local anyFails = {}

        for _, k in ipairs(conditionsBlock.any) do
            local ok, textKey, args = evalKey(k)
            if ok then
                anyOk = true
            else
                anyFails[#anyFails + 1] = { condKey = k, textKey = textKey, args = args }
            end
        end

        if not anyOk then
            -- One “group” failure + details for tooltips / expanded list
            addGroupFail(out, "IGUI_PhunMart_Cond_AnyGroupFail", nil, anyFails)
        end
    end

    -- NOT ANY (none may pass)
    if conditionsBlock.notAny and #conditionsBlock.notAny > 0 then
        for _, k in ipairs(conditionsBlock.notAny) do
            local ok = evalKey(k)
            if ok then
                -- If it passed, it violates notAny
                addFail(out, k, "IGUI_PhunMart_Cond_NotAnyViolated", { tostring(k) })
            end
        end
    end

    return out
end
