require "PhunMart/core"
local Core = PhunMart

-- ─────────────────────────────────────────────────────────────────────────────
-- Auction House shared definitions (Phase 1: buy-now only, currency only)
-- ─────────────────────────────────────────────────────────────────────────────

Core.auctionHouse = Core.auctionHouse or {}
local AH = Core.auctionHouse

-- Listing status constants
AH.STATUS = {
    ACTIVE    = "ACTIVE",
    SOLD      = "SOLD",
    EXPIRED   = "EXPIRED",
    CANCELLED = "CANCELLED"
}

-- Collection entry reason constants
AH.REASON = {
    PURCHASED = "purchased",   -- buyer received item
    SALE      = "sale",        -- seller received proceeds
    EXPIRED   = "expired",     -- unsold item returned
    CANCELLED = "cancelled"    -- seller cancelled, item returned
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Sandbox-backed settings (read at call time so hot-reload works)
-- ─────────────────────────────────────────────────────────────────────────────

function AH.isEnabled()
    return Core.getOption("AHEnabled", true)
end

function AH.getMaxListings()
    return Core.getOption("AHMaxListings", 10)
end

function AH.getExpiryHours()
    return Core.getOption("AHExpiryHours", 72)
end

function AH.getFeePercent()
    return Core.getOption("AHFeePercent", 5)
end

function AH.getMinPrice()
    return Core.getOption("AHMinPrice", 5)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Validation helpers (callable from both sides)
-- ─────────────────────────────────────────────────────────────────────────────

-- Phase 1: only currency prices allowed
function AH.validatePrice(price)
    if type(price) ~= "table" then
        return false, "price must be a table"
    end
    if price.kind ~= "currency" then
        return false, "only currency prices supported"
    end
    if type(price.pool) ~= "string" or price.pool == "" then
        return false, "price.pool required"
    end
    if type(price.amount) ~= "number" or price.amount < AH.getMinPrice() then
        return false, "price.amount must be >= " .. AH.getMinPrice()
    end
    return true
end

-- Check whether an item type is listable (real game item, not currency)
function AH.isListableItem(fullType)
    if type(fullType) ~= "string" or fullType == "" then
        return false
    end
    -- Reject PhunMart currency items
    if Core.wallet and Core.wallet:isCurrency(fullType) then
        return false
    end
    -- Reject special internal items
    if fullType == "PhunMart.DroppedWallet" or fullType == "PhunMart.VehicleKeySpawner" then
        return false
    end
    return true
end

-- Calculate fee from sale amount
function AH.calcFee(amount)
    local pct = AH.getFeePercent()
    if pct <= 0 then
        return 0
    end
    return math.floor(amount * pct / 100)
end

-- Generate a unique listing ID (server-side counter is authoritative,
-- but this fallback uses world age + random for robustness)
function AH.makeId(counter)
    return "ah_" .. tostring(counter or 0)
end
