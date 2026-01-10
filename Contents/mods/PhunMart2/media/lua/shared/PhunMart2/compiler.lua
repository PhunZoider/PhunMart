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

local function expandGroupItems(groupDef, logger)
    local outSet = {}
    local include = groupDef.include or {}

    -- explicit items
    if type(include.items) == "table" then
        for _, itemType in ipairs(include.items) do
            outSet[itemType] = true
        end
    end

    -- categories/tags discovery is optional; you can implement later.
    -- Placeholders so schema is ready:
    -- include.categories = {...}
    -- include.tags = {...}

    -- blacklist
    if type(groupDef.blacklist) == "table" then
        for _, itemType in ipairs(groupDef.blacklist) do
            outSet[itemType] = nil
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

    if itemType == "Base.Katana" then
        print("[PhunMart2] poolDef.defaults.price=" .. tostring(poolDef.defaults and poolDef.defaults.price))
        print("[PhunMart2] poolDef.defaults.prices=" .. tostring(poolDef.defaults and poolDef.defaults.prices))
    end

    if itemType == "Base.Katana" then
        print("[PhunMart2] Katana merged.price = " .. tostring(merged.price))
        print("[PhunMart2] Prices.low10 exists? " .. tostring(ctx.prices and ctx.prices["low10"] ~= nil))
    end

    local priceResolved = resolvePrice(ctx.prices, merged.price, logger)
    local rewardResolved = resolveReward(ctx.rewards, merged.reward, itemType, merged.offer.qty, logger)

    local offerId = buildOfferId(poolKey, itemType)

    return offerId, {
        id = offerId,
        item = itemType,
        price = priceResolved,
        reward = rewardResolved,
        offer = merged.offer,
        conditions = normalizeConditions(merged.conditions),
        meta = {
            sourceGroup = groupDef and groupDef.__key or nil
        }
    }
end

-- -----------------------------
-- Public: compile all
-- ctx expects:
--  ctx.prices, ctx.rewards, ctx.conditionsDefs, ctx.items, ctx.groups, ctx.pools, ctx.shops
-- -----------------------------
function Compiler.compileAll(ctx)
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
    local runtime = {
        shops = {},
        pools = {}
    }

    for poolKey, poolDef in pairs(resolved.pools) do
        if not gatedOut(poolDef) and poolDef.template ~= true then
            local poolRuntime = {
                key = poolKey,
                gate = poolDef.gate,
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
                        -- validate item exists (optional warning)
                        if not itemExists(itemType) then
                            logger:warn("Unknown item type '" .. itemType .. "' (pool '" .. poolKey ..
                                            "'). It may be from a mod or typo.")
                        end

                        local offerId, offer = compileOfferForItem({
                            prices = resolved.prices,
                            rewards = resolved.rewards
                        }, poolKey, poolDef, meta.fromGroup and (function()
                            local g = meta.fromGroup
                            g.__key = g.__key or nil
                            return g
                        end)() or nil, itemType, itemDef, logger)

                        if offer and offer.price and offer.reward then
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

    -- Compile shops (mostly pass-through + gating)
    for shopKey, shopDef in pairs(resolved.shops) do
        if not gatedOut(shopDef) and shopDef.template ~= true then
            runtime.shops[shopKey] = {
                key = shopKey,
                category = shopDef.category,
                sprites = shopDef.sprites,
                unpoweredSprites = shopDef.unpoweredSprites,
                poolSets = shopDef.poolSets,
                throttle = shopDef.throttle
            }
        end
    end

    return runtime, logger
end
