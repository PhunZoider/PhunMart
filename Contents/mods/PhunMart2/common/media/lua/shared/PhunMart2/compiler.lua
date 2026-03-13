-- =========================================================
-- PhunMart2 Config Compiler (Schema v1)
-- Supports:
--  - enabled/mods gating
--  - template entries for inheritance
--  - single-parent inheritance chains (parent can inherit)
--  - deep merge (arrays replace)
--  - conditions: list -> {all={...}} and supports all/any/notAny
--  - prices: amount optional default=1; amount can be {min,max}
--  - prices: item can be string OR list of strings (any-of)
--  - compile pools -> offers (resolved price/reward/offer/conditions)
-- =========================================================
require("PhunMart2/core")
local Core = PhunMart
local Compiler = {}
Core.compiler = Compiler

-- -----------------------------
-- Utility: logging
-- -----------------------------
local function newLogger()
    return {
        errors = {},
        warnings = {},
        infos = {},
        error = function(self, msg)
            table.insert(self.errors, msg)
        end,
        warn = function(self, msg)
            table.insert(self.warnings, msg)
        end,
        info = function(self, msg)
            table.insert(self.infos, msg)
        end
    }
end

-- -----------------------------
-- Utility: type helpers
-- -----------------------------
local function isArray(t)
    if type(t) ~= "table" then
        return false
    end

    local hasAnyKey = false
    for k, _ in pairs(t) do
        hasAnyKey = true
        if type(k) ~= "number" then
            return false
        end
    end

    -- empty table is NOT an array
    if not hasAnyKey then
        return false
    end

    return true
end

local function isSequence(t)
    if type(t) ~= "table" then
        return false
    end
    local n = #t
    if n == 0 then
        return false
    end -- empty not sequence
    for k, _ in pairs(t) do
        if type(k) ~= "number" then
            return false
        end
        if k < 1 or k > n or k % 1 ~= 0 then
            return false
        end
    end
    return true
end

local function shallowCopy(t)
    if type(t) ~= "table" then
        return t
    end
    local out = {}
    for k, v in pairs(t) do
        out[k] = v
    end
    return out
end

-- Deep merge where:
--  - scalars: child overrides parent
--  - tables: merge recursively
--  - arrays: child replaces parent (predictable)
local function deepMerge(parent, child)
    if child == nil then
        return shallowCopy(parent)
    end
    if parent == nil then
        return shallowCopy(child)
    end

    if type(parent) ~= "table" or type(child) ~= "table" then
        return shallowCopy(child)
    end

    -- sequences (arrays) replace
    if isSequence(parent) or isSequence(child) then
        return shallowCopy(child)
    end

    local out = shallowCopy(parent)
    for k, vChild in pairs(child) do
        local vParent = out[k]
        if type(vChild) == "table" and type(vParent) == "table" and (not isSequence(vChild)) and
            (not isSequence(vParent)) then
            out[k] = deepMerge(vParent, vChild)
        else
            out[k] = shallowCopy(vChild)
        end
    end
    return out
end

-- -----------------------------
-- Mods gating
-- -----------------------------
local function getActiveModsSet()
    -- Server-side in PZ: getActivatedMods() returns ActiveMods
    -- We'll normalize to a set for fast lookup.
    local set = {}
    if getActivatedMods then
        local mods = getActivatedMods()
        if mods then
            for i = 0, mods:size() - 1 do
                set[mods:get(i)] = true
            end
        end
    end
    return set
end

local function isAllowed(entry, activeModsSet)
    if entry == nil then
        return false
    end

    -- simple boolean
    if entry.enabled == false then
        return false
    end

    -- extended enabled table
    if type(entry.enabled) == "table" then
        if entry.enabled.requireMods then
            for _, modId in ipairs(entry.enabled.requireMods) do
                if not activeModsSet[modId] then
                    return false
                end
            end
        end
    end

    -- existing mods gating
    local mods = entry.mods
    if type(mods) ~= "table" then
        return true
    end

    local req = mods.require
    if type(req) == "table" then
        for _, modId in ipairs(req) do
            if not activeModsSet[modId] then
                return false
            end
        end
    end

    local forbid = mods.forbid
    if type(forbid) == "table" then
        for _, modId in ipairs(forbid) do
            if activeModsSet[modId] then
                return false
            end
        end
    end

    return true
end

-- -----------------------------
-- Inheritance resolver (single parent, chain allowed)
-- -----------------------------
-- defsTable: map[key] = entry
-- returns: mergedEntry, traceKeys (child->...->root)
local function resolveWithInheritance(defsTable, key, logger)
    local visited = {}
    local trace = {}

    local function resolve(k, depth)
        depth = depth or 0
        if depth > 20 then
            logger:error("Inheritance too deep for key: " .. tostring(key))
            return nil
        end
        if visited[k] then
            logger:error("Inheritance cycle detected at key: " .. tostring(k) .. " (starting from " .. tostring(key) ..
                             ")")
            return nil
        end
        visited[k] = true

        local entry = defsTable[k]
        if type(entry) ~= "table" then
            logger:error("Missing referenced key: " .. tostring(k) .. " (referenced from " .. tostring(key) .. ")")
            return nil
        end

        table.insert(trace, k)

        local parentKey = entry.inherit
        if type(parentKey) == "string" and parentKey ~= "" then
            local parentResolved = resolve(parentKey, depth + 1)
            if not parentResolved then
                return nil
            end
            -- parent first, then child overrides
            local merged = deepMerge(parentResolved, entry)

            -- template should NOT inherit; only explicit on the child
            merged.template = (entry.template == true)

            return merged

        end

        return shallowCopy(entry)
    end

    local resolved = resolve(key, 0)
    return resolved, trace
end

-- -----------------------------
-- Conditions normalization
-- -----------------------------
local function normalizeConditions(cond)
    if cond == nil then
        return nil
    end

    -- if it's an array like {"a","b"} => { all={"a","b"} }
    if type(cond) == "table" and isArray(cond) then
        return {
            all = shallowCopy(cond)
        }
    end

    -- if it's a string => { all={cond} }
    if type(cond) == "string" then
        return {
            all = {cond}
        }
    end

    -- if it's already {all/any/notAny}, just ensure arrays exist
    if type(cond) == "table" then
        local out = {}
        if cond.all then
            out.all = shallowCopy(cond.all)
        end
        if cond.any then
            out.any = shallowCopy(cond.any)
        end
        if cond.notAny then
            out.notAny = shallowCopy(cond.notAny)
        end
        return out
    end

    return nil
end

-- Merge conditions by ANDing them:
-- - combine all lists under .all
local function mergeConditions(a, b)
    local na = normalizeConditions(a)
    local nb = normalizeConditions(b)
    if not na then
        return nb
    end
    if not nb then
        return na
    end

    local out = {
        all = {},
        any = nil,
        notAny = nil
    }

    if na.all then
        for _, k in ipairs(na.all) do
            table.insert(out.all, k)
        end
    end
    if nb.all then
        for _, k in ipairs(nb.all) do
            table.insert(out.all, k)
        end
    end

    -- Any/notAny: simplest is to AND them too by concatenation within same bucket
    if na.any or nb.any then
        out.any = {}
        if na.any then
            for _, k in ipairs(na.any) do
                table.insert(out.any, k)
            end
        end
        if nb.any then
            for _, k in ipairs(nb.any) do
                table.insert(out.any, k)
            end
        end
    end

    if na.notAny or nb.notAny then
        out.notAny = {}
        if na.notAny then
            for _, k in ipairs(na.notAny) do
                table.insert(out.notAny, k)
            end
        end
        if nb.notAny then
            for _, k in ipairs(nb.notAny) do
                table.insert(out.notAny, k)
            end
        end
    end

    return out
end

-- -----------------------------
-- Price normalization / resolution
-- -----------------------------
local function snapNickelUp(n)
    return math.ceil(n / 5) * 5
end

local function snapNickelDown(n)
    return math.floor(n / 5) * 5
end

local function snapNickelNearest(n)
    return math.floor((n + 2) / 5) * 5
end

local function normalizeAmount(amount)
    if amount == nil then
        return 1
    end
    if type(amount) == "number" then
        return amount
    end
    if type(amount) == "table" and amount.min and amount.max then
        return {
            min = amount.min,
            max = amount.max
        }
    end
    return amount -- leave as-is, validator can warn
end

-- Normalize a single cost line: { item=string|{...}, amount=number|{min,max}|nil }
local function normalizeCostLine(line)
    if type(line) ~= "table" then
        return nil
    end
    local item = line.item
    local amount = normalizeAmount(line.amount)

    -- item can be string or array of strings (any-of)
    if type(item) == "string" then
        return {
            item = item,
            amount = amount
        }
    elseif type(item) == "table" and isArray(item) then
        return {
            itemAny = shallowCopy(item),
            amount = amount
        }
    end
    return {
        item = item,
        amount = amount
    } -- keep but likely invalid
end

local function resolvePrice(pricesTable, priceRefOrInline, logger)
    if priceRefOrInline == nil then
        return nil
    end

    local p
    if type(priceRefOrInline) == "string" then
        p = pricesTable[priceRefOrInline]
        if type(p) ~= "table" then
            logger:error("Unknown price key: " .. tostring(priceRefOrInline))
            return nil
        end
        p = shallowCopy(p)
    elseif type(priceRefOrInline) == "table" then
        p = shallowCopy(priceRefOrInline)
    else
        logger:error("Invalid price ref type: " .. tostring(type(priceRefOrInline)))
        return nil
    end

    -- FREE
    if p.kind == "free" then
        return {
            kind = "free"
        }
    end

    p.kind = p.kind or "items"

    if p.kind == "currency" then
        -- Nickel-align change amounts (pool="change" only; tokens use integer counts)
        if p.pool == "change" then
            local ref = type(priceRefOrInline) == "string" and priceRefOrInline or "(inline)"
            if type(p.amount) == "number" then
                local snapped = snapNickelNearest(p.amount)
                if snapped ~= p.amount then
                    logger:warn(
                        "Price '" .. ref .. "': amount " .. p.amount .. " is not a multiple of 5; snapped to " ..
                            snapped)
                end
                if snapped <= 0 then
                    logger:error("Price '" .. ref .. "': amount snapped to 0 or less; minimum is 5")
                    return nil
                end
                p.amount = snapped
            elseif type(p.amount) == "table" and p.amount.min and p.amount.max then
                local sMin = snapNickelUp(p.amount.min)
                local sMax = snapNickelDown(p.amount.max)
                if sMin ~= p.amount.min or sMax ~= p.amount.max then
                    logger:warn("Price '" .. ref .. "': range {min=" .. p.amount.min .. ", max=" .. p.amount.max ..
                                    "} snapped to {min=" .. sMin .. ", max=" .. sMax .. "}")
                end
                if sMin <= 0 then
                    logger:error("Price '" .. ref .. "': snapped min is 0 or less; minimum is 5")
                    return nil
                end
                if sMin > sMax then
                    logger:error("Price '" .. ref .. "': range {min=" .. p.amount.min .. ", max=" .. p.amount.max ..
                                     "} has no valid multiples of 5")
                    return nil
                end
                p.amount = {
                    min = sMin,
                    max = sMax
                }
            end
        end
        return p
    end

    -- "self" price: the offer's own item is the payment. Amount normalised here;
    -- the baked concrete item reference is resolved in bakePrice() at restock time.
    if p.kind == "self" then
        return {
            kind = "self",
            amount = normalizeAmount(p.amount or 1)
        }
    end

    if p.kind ~= "items" then
        -- keep future-proof; you can implement other kinds later
        return p
    end

    local items = p.items
    if type(items) ~= "table" then
        logger:error("Price has no 'items' list")
        return nil
    end

    local normalized = {}
    for _, line in ipairs(items) do
        local n = normalizeCostLine(line)
        if n then
            table.insert(normalized, n)
        end
    end
    p.items = normalized
    return p
end

-- -----------------------------
-- Reward (actions) resolution
-- -----------------------------
local function resolveReward(rewardsTable, rewardRefOrInline, fallbackItemType, qty, logger)
    local r
    if rewardRefOrInline == nil then
        -- auto-reward: give the item
        return {
            display = {
                item = fallbackItemType
            },
            actions = {{
                type = "giveItem",
                item = fallbackItemType,
                amount = qty or 1
            }}
        }
    end

    if type(rewardRefOrInline) == "string" then
        r = rewardsTable[rewardRefOrInline]
        if type(r) ~= "table" then
            logger:error("Unknown reward key: " .. tostring(rewardRefOrInline))
            return nil
        end
        r = shallowCopy(r)
    elseif type(rewardRefOrInline) == "table" then
        r = shallowCopy(rewardRefOrInline)
    else
        logger:error("Invalid reward ref type: " .. tostring(type(rewardRefOrInline)))
        return nil
    end

    -- minimal normalization
    r.actions = r.actions or {}
    r.display = r.display or {
        item = fallbackItemType
    }
    return r
end

-- -----------------------------
-- Group expansion (include items/categories/tags)
-- -----------------------------
local function itemExists(itemType)
    -- Server-side in PZ: getScriptManager():FindItem(itemType)
    if getScriptManager then
        local sm = getScriptManager()
        if sm and sm:FindItem(itemType) then
            return true
        end
    end
    return false
end

-- Builds a map of displayCategory -> set of fullItemName, cached for the compile run.
-- Only called if any group uses include.categories.
local itemCategoryCache = nil
local function getItemCategoryCache()
    if itemCategoryCache then
        return itemCategoryCache
    end
    itemCategoryCache = {}
    if not getScriptManager then
        return itemCategoryCache
    end
    local sm = getScriptManager()
    if not sm then
        return itemCategoryCache
    end
    local items = sm:getAllItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item then
            local ok, _ = pcall(function()
                local cat = tostring(item:getDisplayCategory() or "None")
                local id = tostring(item:getFullName())
                if not itemCategoryCache[cat] then
                    itemCategoryCache[cat] = {}
                end
                itemCategoryCache[cat][id] = true
            end)
        end
    end
    return itemCategoryCache
end

local function expandGroupItems(groupDef, logger)
    local outSet = {}
    local include = groupDef.include or {}

    -- explicit items
    if type(include.items) == "table" then
        for _, itemType in ipairs(include.items) do
            outSet[itemType] = true
        end
    end

    -- category-based discovery: include all game items whose displayCategory matches
    if type(include.categories) == "table" and #include.categories > 0 then
        local catCache = getItemCategoryCache()
        for _, cat in ipairs(include.categories) do
            local catItems = catCache[cat]
            if catItems then
                for id, _ in pairs(catItems) do
                    outSet[id] = true
                end
            else
                logger:warn("Group include.categories: no items found for category '" .. tostring(cat) .. "'")
            end
        end
    end

    -- blacklist (items)
    if type(groupDef.blacklist) == "table" then
        for _, itemType in ipairs(groupDef.blacklist) do
            outSet[itemType] = nil
        end
    end

    -- blacklist.categories: remove all items of these display categories
    if type(groupDef.blacklistCategories) == "table" and #groupDef.blacklistCategories > 0 then
        local catCache = getItemCategoryCache()
        for _, cat in ipairs(groupDef.blacklistCategories) do
            local catItems = catCache[cat]
            if catItems then
                for id, _ in pairs(catItems) do
                    outSet[id] = nil
                end
            end
        end
    end

    -- convert set -> array
    local out = {}
    for itemType, _ in pairs(outSet) do
        table.insert(out, itemType)
    end
    table.sort(out)
    return out
end

-- -----------------------------
-- Offer compilation
-- -----------------------------
local function buildOfferId(poolKey, itemType)
    return tostring(poolKey) .. "|" .. tostring(itemType)
end

local function normalizeOffer(offer)
    offer = offer or {}
    if offer.qty == nil then
        offer.qty = 1
    end
    if offer.weight == nil then
        offer.weight = 1.0
    end
    -- stock/cooldown left as-is
    return offer
end

-- Apply precedence: pool.defaults -> group.defaults -> item
local function compileOfferForItem(ctx, poolKey, poolDef, groupDef, itemType, itemDef, logger)
    local merged = {}

    merged = deepMerge(merged, poolDef.defaults or {})
    merged = deepMerge(merged, (groupDef and groupDef.defaults) or {})
    merged = deepMerge(merged, itemDef or {})

    -- backward compat: pools might still use "prices"
    if merged.price == nil and merged.prices ~= nil then
        merged.price = merged.prices
    end

    -- conditions merge (AND)
    merged.conditions = mergeConditions(mergeConditions(poolDef.defaults and poolDef.defaults.conditions,
        groupDef and groupDef.defaults and groupDef.defaults.conditions), itemDef and itemDef.conditions)

    merged.offer = normalizeOffer(merged.offer)

    local priceResolved = resolvePrice(ctx.prices, merged.price, logger)
    local rewardResolved = resolveReward(ctx.rewards, merged.reward, itemType, merged.offer.qty, logger)

    local offerId = buildOfferId(poolKey, itemType)
    local offerConditions = normalizeConditions(merged.conditions)

    -- For grantTrait reward actions: filter out disabledInMultiplayer offers on MP server,
    -- and auto-inject a canGrantTrait condition for mutex/already-has checks at runtime.
    if rewardResolved and type(rewardResolved.actions) == "table" then
        local isMP = isServer and isServer() and isClient and not isClient()
        for _, action in ipairs(rewardResolved.actions) do
            if action.type == "addTrait" and type(action.trait) == "string" then
                -- Filter disabledInMultiplayer at compile time on dedicated MP server
                if isMP and CharacterTraitDefinition then
                    local traits = CharacterTraitDefinition.getTraits()
                    for i = 0, traits:size() - 1 do
                        local t = traits:get(i)
                        if t and tostring(t:getType()) == action.trait then
                            local disabled = false
                            pcall(function()
                                -- TODO: I don't think this does anything
                                disabled = t.isRemoveInMP and t:isRemoveInMP()
                            end)
                            if disabled then
                                logger:warn("Offer '" .. offerId .. "' grants trait '" .. action.trait ..
                                                "' which is disabled in multiplayer. Offer skipped.")
                                return offerId, nil -- signal caller to skip
                            end
                            break
                        end
                    end
                end

                -- Auto-inject canGrantTrait condition (handles mutex + already-has at runtime)
                local condKey = "__trait:" .. action.trait
                ctx.autoCondsDefs = ctx.autoCondsDefs or {}
                ctx.autoCondsDefs[condKey] = {
                    test = "canGrantTrait",
                    args = {
                        trait = action.trait
                    }
                }

                offerConditions = offerConditions or {
                    all = {}
                }
                offerConditions.all = offerConditions.all or {}
                local found = false
                for _, k in ipairs(offerConditions.all) do
                    if k == condKey then
                        found = true;
                        break
                    end
                end
                if not found then
                    table.insert(offerConditions.all, condKey)
                end
            end

            -- Auto-inject canRemoveTrait condition: player must actually have the trait to remove it
            if action.type == "removeTrait" and type(action.trait) == "string" then
                local condKey = "__removeTrait:" .. action.trait
                ctx.autoCondsDefs = ctx.autoCondsDefs or {}
                ctx.autoCondsDefs[condKey] = {
                    test = "canRemoveTrait",
                    args = {
                        trait = action.trait
                    }
                }

                offerConditions = offerConditions or {
                    all = {}
                }
                offerConditions.all = offerConditions.all or {}
                local found = false
                for _, k in ipairs(offerConditions.all) do
                    if k == condKey then
                        found = true;
                        break
                    end
                end
                if not found then
                    table.insert(offerConditions.all, condKey)
                end
            end

            -- Auto-inject perkBoostBetween for applyBoost actions: gate purchase if boost already active
            if action.type == "applyBoost" and type(action.skill) == "string" then
                local level = math.min(3, math.max(1, math.floor(action.multiplier or 1)))
                local prevTier = level - 1 -- must hold exactly the previous tier to upgrade
                local boostCondKey = "__boost:" .. action.skill .. ":" .. tostring(prevTier)
                ctx.autoCondsDefs = ctx.autoCondsDefs or {}
                ctx.autoCondsDefs[boostCondKey] = {
                    test = "perkBoostBetween",
                    args = {
                        perk = action.skill,
                        min = prevTier, -- exact match: must be at previous tier
                        max = prevTier
                    }
                }
                offerConditions = offerConditions or {
                    all = {}
                }
                offerConditions.all = offerConditions.all or {}
                local boostFound = false
                for _, k in ipairs(offerConditions.all) do
                    if k == boostCondKey then
                        boostFound = true;
                        break
                    end
                end
                if not boostFound then
                    table.insert(offerConditions.all, boostCondKey)
                end
            end
        end
    end

    return offerId, {
        id = offerId,
        item = itemType,
        price = priceResolved,
        reward = rewardResolved,
        offer = merged.offer,
        conditions = offerConditions,
        meta = {
            sourceGroup = groupDef and groupDef.__key or nil,
            category = (groupDef and groupDef.label) or poolDef.fallbackCategory or nil,
            fallbackTexture = (groupDef and groupDef.fallbackTexture) or poolDef.fallbackTexture or nil
        }
    }
end

-- -----------------------------
-- Public: compile all
-- ctx expects:
--  ctx.prices, ctx.rewards, ctx.conditionsDefs, ctx.items, ctx.groups, ctx.pools, ctx.shops
-- -----------------------------
function Compiler.compileAll(ctx)
    -- Reset the item category cache so each compile run reflects current game state
    itemCategoryCache = nil

    local logger = newLogger()
    local activeMods = getActiveModsSet()

    -- Resolve inheritance for all tables that support it.
    -- We'll create "resolved" maps for each.
    local resolved = {
        prices = {},
        rewards = {},
        conditionsDefs = {},
        items = {},
        groups = {},
        pools = {},
        shops = {}
    }

    local function resolveTable(defs, out, tableName)
        for key, _ in pairs(defs) do
            local entry, trace = resolveWithInheritance(defs, key, logger)
            if entry then
                entry.__key = key
                entry.__trace = trace
                out[key] = entry
            end
        end
    end

    resolveTable(ctx.prices or {}, resolved.prices, "prices")
    resolveTable(ctx.rewards or {}, resolved.rewards, "rewards")
    resolveTable(ctx.conditionsDefs or {}, resolved.conditionsDefs, "conditions")
    resolveTable(ctx.items or {}, resolved.items, "items")
    resolveTable(ctx.groups or {}, resolved.groups, "groups")
    resolveTable(ctx.pools or {}, resolved.pools, "pools")
    resolveTable(ctx.shops or {}, resolved.shops, "shops")

    -- Apply gating: note templates can exist, but if gated-out and referenced, we treat as error later.
    local function gatedOut(entry)
        return not isAllowed(entry, activeMods)
    end

    -- Compile pools -> offers
    ctx.autoCondsDefs = ctx.autoCondsDefs or {} -- accumulates auto-generated condition defs
    local runtime = {
        shops = {},
        pools = {},
        conditionsDefs = resolved.conditionsDefs
    }

    for poolKey, poolDef in pairs(resolved.pools) do
        if not gatedOut(poolDef) and poolDef.template ~= true then
            local poolRuntime = {
                key = poolKey,
                gate = poolDef.gate,
                roll = poolDef.roll,
                offers = {}
            }

            -- collect items from sources
            local sources = poolDef.sources or {}
            local itemsSet = {}

            -- groups
            if type(sources.groups) == "table" then
                for _, groupKey in ipairs(sources.groups) do
                    local groupDef = resolved.groups[groupKey]
                    if type(groupDef) ~= "table" then
                        logger:error("Pool '" .. poolKey .. "' references missing group: " .. tostring(groupKey))
                    else
                        if gatedOut(groupDef) then
                            logger:error("Pool '" .. poolKey .. "' references group '" .. groupKey ..
                                             "' but it is gated/disabled.")
                        elseif groupDef.template == true then
                            logger:error("Pool '" .. poolKey .. "' references group '" .. groupKey ..
                                             "' but it is a template.")
                        else
                            local expanded = expandGroupItems(groupDef, logger)
                            for _, itemType in ipairs(expanded) do
                                itemsSet[itemType] = {
                                    fromGroup = groupDef
                                }
                            end
                        end
                    end
                end
            end

            -- direct items
            if type(sources.items) == "table" then
                for _, itemType in ipairs(sources.items) do
                    itemsSet[itemType] = itemsSet[itemType] or {
                        fromGroup = nil
                    }
                end
            end

            -- category-based items: include all non-template items whose resolved
            -- reward has a matching category (inherited from reward templates).
            if type(sources.categories) == "table" then
                local catSet = {}
                for _, cat in ipairs(sources.categories) do
                    catSet[cat] = true
                end

                for itemKey, itemDef in pairs(resolved.items) do
                    if itemDef.template ~= true and not itemsSet[itemKey] then
                        local rewardKey = itemDef.reward
                        if type(rewardKey) == "string" then
                            local rewardDef = resolved.rewards[rewardKey]
                            if rewardDef and catSet[rewardDef.category] then
                                itemsSet[itemKey] = {
                                    fromGroup = nil
                                }
                            end
                        end
                    end
                end
            end

            -- build offers
            for itemType, meta in pairs(itemsSet) do
                local itemDef = resolved.items[itemType]
                if itemDef and itemDef.template == true then
                    logger:warn("Item key '" .. itemType .. "' is marked template=true but was pulled into pool '" ..
                                    poolKey .. "'. Skipping.")
                else
                    -- if itemDef exists but is gated-out, skip that item
                    if itemDef and gatedOut(itemDef) then
                        -- silent skip or warn; I prefer warn
                        logger:warn("Item '" .. itemType .. "' is disabled/gated; skipping in pool '" .. poolKey .. "'.")
                    else
                        -- validate item exists for game items only.
                        -- Non-item offers (trait, skill, boost, vehicle) use arbitrary
                        -- string keys without a module prefix (no "."), so skip them.
                        if itemType:find("%.") and not itemExists(itemType) then
                            logger:warn("Unknown item type '" .. itemType .. "' (pool '" .. poolKey ..
                                            "'). It may be from a mod or typo.")
                        end

                        local offerId, offer = compileOfferForItem({
                            prices = resolved.prices,
                            rewards = resolved.rewards,
                            autoCondsDefs = ctx.autoCondsDefs
                        }, poolKey, poolDef, meta.fromGroup and (function()
                            local g = meta.fromGroup
                            g.__key = g.__key or nil
                            return g
                        end)() or nil, itemType, itemDef, logger)

                        if offer == nil then
                            -- skipped (e.g. disabledInMultiplayer)
                        elseif offer.price and offer.reward then
                            poolRuntime.offers[offerId] = offer
                        elseif not offer.price then
                            logger:error("Offer '" .. offerId .. "' has no price (use price='free' if intended)")
                        else
                            logger:error("Failed to compile offer for " .. tostring(itemType) .. " in pool " ..
                                             tostring(poolKey))
                        end
                    end
                end
            end

            runtime.pools[poolKey] = poolRuntime
        end
    end

    -- Merge auto-generated condition defs (canGrantTrait, perkBoostBetween etc.) into runtime
    for k, v in pairs(ctx.autoCondsDefs) do
        runtime.conditionsDefs[k] = v
    end

    -- Compile shops (mostly pass-through + gating)
    for shopKey, shopDef in pairs(resolved.shops) do
        if not gatedOut(shopDef) and shopDef.template ~= true then
            runtime.shops[shopKey] = {
                key = shopKey,
                category = shopDef.category,
                sprites = shopDef.sprites,
                unpoweredSprites = shopDef.unpoweredSprites,
                powered = shopDef.powered,
                poolSets = shopDef.poolSets,
                throttle = shopDef.throttle,
                restockFrequency = shopDef.restockFrequency,
                background = shopDef.background,
                defaultView = shopDef.defaultView
            }
        end
    end

    return runtime, logger
end
