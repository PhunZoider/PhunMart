-- Reverse lookup across the definition graph: given a definition key, find
-- everything that points at it.
--
-- The definition tables form a chain (shop → pool → group → item/special →
-- price) but only ever store the forward direction, so nothing in the editor
-- could previously answer "what breaks if I remove this". This walks the
-- compiled context to answer it. Used to warn before a delete, and intended as
-- the basis for a "Used by" view on the definition panels.

require "PhunMart/core"
local Core = PhunMart
local refs = {}

-- Does `list` contain `key`?
local function listHas(list, key)
    if type(list) ~= "table" then
        return false
    end
    for _, v in ipairs(list) do
        if v == key then
            return true
        end
    end
    return false
end

--- Find everything referencing `key` within category `kind`.
-- @param kind  "prices" | "groups" | "pools" | "specials" | "items"
-- @return array of {kind, key, via} where `via` names the field that holds the
--         reference, so the caller can explain the relationship.
function refs.find(kind, key)
    local defs = Core.defs or {}
    local out = {}

    local function add(refKind, refKey, via)
        table.insert(out, {
            kind = refKind,
            key = refKey,
            via = via
        })
    end

    if kind == "prices" then
        for k, d in pairs(defs.items or {}) do
            if d.price == key then
                add("items", k, "price")
            end
        end
        for k, d in pairs(defs.groups or {}) do
            if d.defaults and d.defaults.price == key then
                add("groups", k, "default price")
            end
        end
        for k, d in pairs(defs.pools or {}) do
            if d.defaults and d.defaults.price == key then
                add("pools", k, "default price")
            end
        end
        for k, d in pairs(defs.specials or {}) do
            if d.price == key then
                add("specials", k, "price")
            end
        end
        for k, d in pairs(defs.prices or {}) do
            if d.inherit == key then
                add("prices", k, "inherit")
            end
        end
        for k, d in pairs(defs.shops or {}) do
            for i, set in ipairs(d.poolSets or {}) do
                if set.price == key then
                    add("shops", k, "pool set " .. tostring(i))
                end
            end
        end

    elseif kind == "groups" then
        for k, d in pairs(defs.pools or {}) do
            if d.sources and listHas(d.sources.groups, key) then
                add("pools", k, "sources")
            end
        end

    elseif kind == "pools" then
        for k, d in pairs(defs.shops or {}) do
            for i, set in ipairs(d.poolSets or {}) do
                for _, entry in ipairs(set.keys or {}) do
                    if entry.key == key then
                        add("shops", k, "pool set " .. tostring(i))
                        break
                    end
                end
            end
        end

    elseif kind == "specials" then
        for k, d in pairs(defs.groups or {}) do
            if listHas(d.specials, key) then
                add("groups", k, "specials")
            elseif d.defaults and d.defaults.reward == key then
                add("groups", k, "default reward")
            end
        end
        for k, d in pairs(defs.items or {}) do
            if d.reward == key then
                add("items", k, "reward")
            end
        end
        for k, d in pairs(defs.specials or {}) do
            if d.inherit == key then
                add("specials", k, "inherit")
            end
        end

    elseif kind == "items" then
        -- Item definitions are keyed by item type, so anything naming that
        -- type counts as a reference.
        for k, d in pairs(defs.groups or {}) do
            if listHas(d.items, key) then
                add("groups", k, "items")
            elseif listHas(d.blacklist, key) then
                add("groups", k, "blacklist")
            end
        end
        for k, d in pairs(defs.pools or {}) do
            if listHas(d.blacklist, key) then
                add("pools", k, "blacklist")
            end
        end
    end

    table.sort(out, function(a, b)
        if a.kind ~= b.kind then
            return a.kind < b.kind
        end
        return a.key < b.key
    end)
    return out
end

--- Walk the reference chain upwards to the shop types that ultimately draw on
--- `key`, e.g. a price used by items that sit in groups that feed pools that a
--- shop rolls from. Used to work out which machines a definition edit affects.
--- Returns a sorted array of shop type keys.
function refs.findShops(kind, key)
    if kind == "shops" then
        return {key}
    end

    local shops, seen = {}, {}
    local queue = {{
        kind = kind,
        key = key
    }}
    -- `seen` handles the cycles the graph genuinely contains (price inherit
    -- chains, special inherit chains); the counter is a backstop so a malformed
    -- override can't hang the client.
    local guard = 0
    while #queue > 0 and guard < 2000 do
        guard = guard + 1
        local cur = table.remove(queue, 1)
        local id = cur.kind .. "/" .. tostring(cur.key)
        if not seen[id] then
            seen[id] = true
            if cur.kind == "shops" then
                shops[cur.key] = true
            else
                for _, r in ipairs(refs.find(cur.kind, cur.key)) do
                    table.insert(queue, r)
                end
            end
        end
    end

    local out = {}
    for k in pairs(shops) do
        table.insert(out, k)
    end
    table.sort(out)
    return out
end

--- Short human-readable summary of refs.find, e.g. "3 pools, 1 shop".
function refs.summarise(found)
    local counts, order = {}, {}
    for _, r in ipairs(found) do
        if not counts[r.kind] then
            counts[r.kind] = 0
            table.insert(order, r.kind)
        end
        counts[r.kind] = counts[r.kind] + 1
    end
    local parts = {}
    for _, k in ipairs(order) do
        local n = counts[k]
        -- Trim the plural when there's only one (pools -> pool).
        local label = n == 1 and k:gsub("s$", "") or k
        table.insert(parts, tostring(n) .. " " .. label)
    end
    return table.concat(parts, ", ")
end

Core.references = refs
return refs
