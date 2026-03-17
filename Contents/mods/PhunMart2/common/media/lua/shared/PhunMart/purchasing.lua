require "PhunMart/core"
local Core = PhunMart
-- NOTE: Do NOT cache Core.wallet here — wallet.lua loads after purchasing.lua
-- (alphabetical order), so Core.wallet is nil at module load time.
-- Access Core.wallet directly inside each function instead.

-- Price formats supported:
--   { kind = "free" }
--   { kind = "currency", pool = "change", amount = 75 }
--   { kind = "currency", pool = "tokens", amount = 1 }
--   { kind = "items", items = {{ item = "Base.Bandage", amount = 2 }} }

function Core:canAfford(player, price)
    if price.kind == "free" then
        return true
    elseif price.kind == "currency" then
        return Core.wallet:getBalance(player, price.pool) >= price.amount
    elseif price.kind == "items" then
        for _, entry in ipairs(price.items or {}) do
            local count = player:getInventory():getItemCountRecurse(entry.item)
            if entry.substitutes then
                for _, sub in ipairs(entry.substitutes) do
                    count = count + player:getInventory():getItemCountRecurse(sub)
                end
            end
            if count < entry.amount then
                return false
            end
        end
        return true
    end
    return false
end

-- Check all prices in a list. Returns: allAffordable (bool), failures (list of price entries).
function Core:canAffordAll(player, prices)
    local result = true
    local failures = {}
    for _, price in ipairs(prices or {}) do
        if not Core:canAfford(player, price) then
            result = false
            table.insert(failures, price)
        end
    end
    return result, failures
end

-- Deduct a single price from the player. Returns true on success.
function Core:deduct(player, price)
    if price.kind == "free" then
        return true
    elseif price.kind == "currency" then
        Core.wallet:adjustByPool(player, "current", price.pool, -price.amount)
        return true
    elseif price.kind == "items" then
        for _, entry in ipairs(price.items or {}) do
            local remaining = entry.amount
            -- Remove from primary item first
            local primaryCount = player:getInventory():getItemCountRecurse(entry.item)
            local fromPrimary = math.min(remaining, primaryCount)
            if fromPrimary > 0 then
                player:getInventory():RemoveAll(entry.item, fromPrimary)
                remaining = remaining - fromPrimary
            end
            -- Then from substitutes
            if remaining > 0 and entry.substitutes then
                for _, sub in ipairs(entry.substitutes) do
                    if remaining <= 0 then
                        break
                    end
                    local subCount = player:getInventory():getItemCountRecurse(sub)
                    local fromSub = math.min(remaining, subCount)
                    if fromSub > 0 then
                        player:getInventory():RemoveAll(sub, fromSub)
                        remaining = remaining - fromSub
                    end
                end
            end
        end
        return true
    end
    return false
end

-- Validates all prices first, then deducts all. Will not partially deduct.
-- Returns: success (bool), failures (list of unaffordable price entries).
function Core:deductAll(player, prices)
    local canAfford, failures = Core:canAffordAll(player, prices)
    if not canAfford then
        return false, failures
    end
    for _, price in ipairs(prices or {}) do
        Core:deduct(player, price)
    end
    return true, {}
end
