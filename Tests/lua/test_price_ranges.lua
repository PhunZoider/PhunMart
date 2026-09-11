-- Covers a price written as a range rather than a fixed figure: how the
-- compiler carries it, and how a restock rolls it.
--
-- The bug this was written for: the price editor refused an upper bound on
-- anything but a currency price, so a shop could not ask "1 to 50 gold bars"
-- even though every layer under the form already supported it. The refusal was
-- hiding a second one -- the items roll asked ZombRand for (min, max), whose
-- upper bound is exclusive, so 50 was never rolled and a 5 to 5 line asked for
-- an empty span.
--
-- Run: luajit test_price_ranges.lua   (or run.cmd, which runs all of them)

local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = arg[1] or (here .. "/../..")
package.path = here .. "/?.lua;" .. package.path

local harness = require "harness"

local shared = root .. "/Contents/mods/PhunMart2/common/media/lua/shared"
local server = root .. "/Contents/mods/PhunMart2/common/media/lua/server"
package.path = shared .. "/?.lua;" .. server .. "/?.lua;" .. package.path

harness.installGlobals()

local ITEMS = {
    ["Base.Axe"] = true,
    ["Base.Saw"] = true,
    ["Base.GoldBar"] = true,
    ["Base.Nails"] = true,
    ["Base.Plank"] = true
}

local function scriptItem(full)
    return {
        getFullName = function()
            return full
        end,
        getDisplayName = function()
            return full
        end,
        getDisplayCategory = function()
            return "None"
        end
    }
end

_G.getScriptManager = function()
    return {
        getVehicle = function()
            return nil
        end,
        FindItem = function(_, itemType)
            local full = itemType:find("%.") and itemType or ("Base." .. itemType)
            return ITEMS[full] and scriptItem(full) or nil
        end,
        getAllItems = function()
            local all = {}
            for full in pairs(ITEMS) do
                table.insert(all, scriptItem(full))
            end
            table.sort(all, function(a, b)
                return a:getFullName() < b:getFullName()
            end)
            return {
                size = function()
                    return #all
                end,
                get = function(_, i)
                    return all[i + 1]
                end
            }
        end
    }
end

_G.getActivatedMods = function()
    return {
        size = function()
            return 0
        end,
        get = function()
            return nil
        end
    }
end

_G.SandboxVars = {PhunMart = {Debug = false}}
_G.LuaEventManager = {AddEvent = function() end}
_G.getSandboxOptions = function()
    return {
        getOptionByName = function()
            return nil
        end
    }
end
_G.ModData = {
    getOrCreate = function()
        return {}
    end
}

require "PhunMart/core"
require "PhunMart/compiler"
local Compiler = PhunMart.compiler
local rollAmount = PhunMart.utils.rollAmount

harness.strip()

---------------------------------------------------------------------------

local passed, failed = 0, 0

local function ok(label, condition, detail)
    if condition then
        passed = passed + 1
        print("  ok    " .. label)
    else
        failed = failed + 1
        print("  FAIL  " .. label .. (detail and ("  <- " .. detail) or ""))
    end
end

--- A stand-in for ZombRand that always returns the highest value it could,
--- and records the span it was asked for. Both halves matter: the top of a
--- range is the value the old roll could never reach, and the span is how the
--- off-by-one shows up even when the result happens to look right.
local function topRoller()
    local r = {}
    r.spans = {}
    setmetatable(r, {
        __call = function(_, lo, hi)
            table.insert(r.spans, {lo, hi})
            return hi - 1
        end
    })
    return r
end

local function lowRoller()
    return function()
        return 0
    end
end

print("-- rollAmount, a fixed amount --")
do
    ok("a number passes through", rollAmount(7) == 7)
    ok("nil stays nil", rollAmount(nil) == nil)
    ok("a numeric string is read as a number", rollAmount("7") == 7)
end

print("-- rollAmount, a range --")
do
    local top = topRoller()
    local got = rollAmount({
        min = 1,
        max = 50
    }, nil, top)
    ok("the top of the range is reachable", got == 50, "got " .. tostring(got))
    ok("because the roll asks for one more than the span", top.spans[1][1] == 0 and top.spans[1][2] == 50,
        "asked for (" .. top.spans[1][1] .. ", " .. top.spans[1][2] .. ")")

    ok("the bottom is the low end", rollAmount({
        min = 1,
        max = 50
    }, nil, lowRoller()) == 1)
end

print("-- rollAmount, a range with nothing in it --")
do
    local top = topRoller()
    local got = rollAmount({
        min = 5,
        max = 5
    }, nil, top)
    ok("min == max resolves to that figure", got == 5, "got " .. tostring(got))
    ok("and is still a legal ask of ZombRand", top.spans[1][2] > top.spans[1][1],
        "ZombRand(0, 0) has no value to return")
end

print("-- rollAmount, stepped for change --")
do
    ok("the low end is the low end", rollAmount({
        min = 250,
        max = 600
    }, 5, lowRoller()) == 250)
    ok("the high end is reachable", rollAmount({
        min = 250,
        max = 600
    }, 5, topRoller()) == 600)
    -- 250 to 599 holds 69 whole nickels above 250, so the top the roll can
    -- reach is 595: a range whose ends are not both aligned never lands
    -- between the fives.
    local got = rollAmount({
        min = 250,
        max = 599
    }, 5, topRoller())
    ok("and a ragged top stays on a multiple of five", got == 595, "got " .. tostring(got))
end

print("-- rollAmount, a range an admin typed badly --")
do
    ok("a reversed range is read the right way round", rollAmount({
        min = 50,
        max = 1
    }, nil, lowRoller()) == 1)
    ok("a range with only a min is that min", rollAmount({
        min = 3
    }, nil, topRoller()) == 3)
    ok("a range with only a max is that max", rollAmount({
        max = 3
    }, nil, topRoller()) == 3)
    ok("a table that is neither is nil", rollAmount({}) == nil)
end

---------------------------------------------------------------------------
-- The compiler half: a range has to survive being resolved, or there is
-- nothing for the roll above to read.
---------------------------------------------------------------------------

local function defsWith(prices, groups)
    return {
        prices = prices,
        specials = {},
        conditionsDefs = {},
        items = {},
        groups = groups,
        pools = {},
        shops = {}
    }
end

--- The compiled price of the one offer a single-item group produces.
local function priceOf(prices, priceKey)
    local pool = Compiler.previewGroup(defsWith(prices, {
        g = {
            defaults = {
                price = priceKey
            },
            items = {"Base.Axe"}
        }
    }), "g")
    for _, offer in pairs(pool and pool.offers or {}) do
        return offer.price
    end
end

print("-- an items price written as a range --")
do
    -- What the bug report asked for: gold bars as the currency, 1 to 50 of
    -- them. The single-item shorthand the price editor saves.
    local price = priceOf({
        bars = {
            kind = "items",
            item = "Base.GoldBar",
            amount = {
                min = 1,
                max = 50
            }
        }
    }, "bars")
    ok("compiles to one cost line", price and price.kind == "items" and #(price.items or {}) == 1)
    local line = price and price.items and price.items[1]
    ok("naming the item", line and line.item == "Base.GoldBar")
    ok("with the range intact rather than flattened", type(line and line.amount) == "table" and line.amount.min == 1 and
        line.amount.max == 50, "got " .. tostring(line and line.amount))
end

print("-- a barter price where only one line is a range --")
do
    local price = priceOf({
        barter = {
            kind = "items",
            items = {{
                item = "Base.Nails",
                amount = {
                    min = 5,
                    max = 10
                }
            }, {
                item = "Base.Plank",
                amount = 3
            }}
        }
    }, "barter")
    local lines = price and price.items or {}
    ok("keeps both lines", #lines == 2, "got " .. #lines)
    ok("the ranged one as a range", type(lines[1] and lines[1].amount) == "table")
    ok("the fixed one as a figure", lines[2] and lines[2].amount == 3)
end

print("-- a self price written as a range --")
do
    local price = priceOf({
        collect = {
            kind = "self",
            amount = {
                min = 2,
                max = 6
            }
        }
    }, "collect")
    ok("stays a self price", price and price.kind == "self")
    ok("with the range intact", type(price and price.amount) == "table" and price.amount.min == 2 and
        price.amount.max == 6)
end

print("-- a factor applied to a ranged items price --")
do
    -- The economy knob scales both ends, so a range stays a range rather than
    -- collapsing onto whichever end the scaling read.
    local price = priceOf({
        bars = {
            kind = "items",
            item = "Base.GoldBar",
            amount = {
                min = 2,
                max = 10
            },
            factor = 2
        }
    }, "bars")
    local amt = price and price.items and price.items[1] and price.items[1].amount
    ok("both ends are scaled", type(amt) == "table" and amt.min == 4 and amt.max == 20,
        "got " .. tostring(amt and amt.min) .. " to " .. tostring(amt and amt.max))
end

---------------------------------------------------------------------------

print("")
print(passed .. " passed, " .. failed .. " failed")
os.exit(failed == 0 and 0 or 1)
