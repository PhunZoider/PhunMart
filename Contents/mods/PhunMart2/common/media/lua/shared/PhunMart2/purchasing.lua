require "PhunMart2/core"
local Core = PhunMart
local Wallet = Core.wallet

-- Price formats supported:
--   { kind = "free" }
--   { kind = "currency", pool = "change", amount = 75 }
--   { kind = "currency", pool = "tokens", amount = 1 }
--   { kind = "items", items = {{ item = "Base.Bandage", amount = 2 }} }

function Core:canAfford(player, price)
    if price.kind == "free" then
        return true
    elseif price.kind == "currency" then
        return Wallet:getBalance(player, price.pool) >= price.amount
    elseif price.kind == "items" then
        for _, entry in ipairs(price.items or {}) do
            if player:getInventory():getItemCountRecursive(entry.item) < entry.amount then
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
        Wallet:adjustByPool(player, "current", price.pool, -price.amount)
        return true
    elseif price.kind == "items" then
        for _, entry in ipairs(price.items or {}) do
            player:getInventory():RemoveItemAmount(entry.item, entry.amount)
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
