-- Covers groups that sell recorded media (VHS tapes, CDs) title by title.
--
-- A tape is one item in the game with its title attached afterwards, and only
-- the loot spawner attaches one. Sold by item type alone it arrives blank. A
-- group with `recordings` set expands each such item into one offer per title,
-- and the things worth pinning are the ones that fail silently in the game:
--   * every title surviving as its own offer, not collapsing into one
--   * the title reaching the action that hands the tape over
--   * the item an offer names staying the real item, for icons and tooltips
--   * a named special's shared actions not picking up one offer's title
--
-- Run: luajit test_recordings.lua   (or run.cmd, which runs all of them)

local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = arg[1] or (here .. "/../..")
package.path = here .. "/?.lua;" .. package.path

local harness = require "harness"

local shared = root .. "/Contents/mods/PhunMart2/common/media/lua/shared"
package.path = shared .. "/?.lua;" .. package.path

harness.installGlobals()

-- Two tape items, one ordinary item, and the recordings they can hold.
local MEDIA_CAT = {
    ["Base.VHS_Retail"] = "Retail-VHS",
    ["Base.VHS_Home"] = "Home-VHS"
}
local ITEMS = {
    ["Base.VHS_Retail"] = true,
    ["Base.VHS_Home"] = true,
    ["Base.Popcorn"] = true
}

_G.RecMedia = {
    ["film-a"] = {
        itemDisplayName = "RM_film_a",
        category = "Retail-VHS",
        spawning = 0,
        lines = {{text = "x", codes = "BOR-1"}}
    },
    ["woodcraft"] = {
        itemDisplayName = "RM_woodcraft",
        category = "Retail-VHS",
        spawning = 2,
        lines = {{text = "x", codes = "BOR-1"}, {text = "y", codes = "CRP+1"}, {text = "z", codes = "CRP+1"}}
    },
    ["home-a"] = {
        itemDisplayName = "RM_home_a",
        category = "Home-VHS",
        spawning = 0,
        lines = {}
    },
    ["cd-a"] = {
        itemDisplayName = "RM_cd_a",
        category = "CDs",
        spawning = 0,
        lines = {}
    }
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
            return "Entertainment"
        end,
        getRecordedMediaCat = function()
            return MEDIA_CAT[full]
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
            return {
                size = function()
                    return 0
                end,
                get = function()
                    return nil
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
    return {getOptionByName = function() return nil end}
end
_G.ModData = {
    getOrCreate = function()
        return {}
    end
}

require "PhunMart/core"
require "PhunMart/compiler"
local Compiler = PhunMart.compiler
local Recordings = require "PhunMart/recordings"

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

--- Compile one pool built from `group`, and return its offers.
local function compileGroup(group, specials)
    local ctx = {
        prices = {
            cheap = {kind = "change", amount = 10},
            dear = {kind = "change", amount = 99}
        },
        specials = specials or {},
        conditionsDefs = {},
        items = {},
        groups = {g = group},
        pools = {p = {sources = {groups = {"g"}}}},
        shops = {}
    }
    local runtime = Compiler.compileAll(ctx)
    return runtime.pools.p and runtime.pools.p.offers or {}
end

--- Offers keyed by "item#media" (or item), so assertions read as sets.
local function byKey(offers)
    local out, count = {}, 0
    for _, offer in pairs(offers) do
        out[offer.media and Recordings.key(offer.item, offer.media) or offer.item] = offer
        count = count + 1
    end
    return out, count
end

---------------------------------------------------------------------------

print("-- keys --")
do
    local key = Recordings.key("Base.VHS_Retail", "film-a")
    local item, media = Recordings.split(key)
    ok("a key splits back into item and title", item == "Base.VHS_Retail" and media == "film-a")
    local plain, none = Recordings.split("Base.Axe")
    ok("a plain item splits into itself and nothing", plain == "Base.Axe" and none == nil)
end

print("-- a group without recordings --")
do
    local offers, count = byKey(compileGroup({
        defaults = {price = "cheap"},
        items = {"Base.VHS_Retail"}
    }))
    ok("sells the tape once, as before", count == 1 and offers["Base.VHS_Retail"] ~= nil, "got " .. count)
end

print("-- a group with recordings --")
do
    local offers, count = byKey(compileGroup({
        defaults = {price = "cheap"},
        recordings = true,
        items = {"Base.VHS_Retail", "Base.VHS_Home", "Base.Popcorn"}
    }))
    ok("one offer per title, plus the ordinary item", count == 4, "got " .. count)
    ok("every retail title is there", offers["Base.VHS_Retail#film-a"] ~= nil and
        offers["Base.VHS_Retail#woodcraft"] ~= nil)
    ok("home tapes draw from their own category", offers["Base.VHS_Home#home-a"] ~= nil)
    ok("no tape draws from another category", offers["Base.VHS_Retail#home-a"] == nil and
        offers["Base.VHS_Retail#cd-a"] == nil)
    ok("the blank tape is no longer sold", offers["Base.VHS_Retail"] == nil)
    ok("an item with no recordings is left alone", offers["Base.Popcorn"] ~= nil)

    local offer = offers["Base.VHS_Retail#film-a"]
    ok("the offer names the real item", offer and offer.item == "Base.VHS_Retail")
    ok("and carries its title", offer and offer.media == "film-a")
    ok("its id is unique to the title", offer and offer.id == "p|Base.VHS_Retail#film-a")

    local action = offer and offer.reward and offer.reward.actions and offer.reward.actions[1]
    ok("the action gives the real item", action and action.type == "giveItem" and action.item == "Base.VHS_Retail")
    ok("with the title on it", action and action.media == "film-a")
end

print("-- pricing the tapes that teach a skill --")
do
    local offers = byKey(compileGroup({
        defaults = {price = "cheap"},
        recordings = {
            skill = {price = "dear"}
        },
        items = {"Base.VHS_Retail"}
    }))
    local skill = offers["Base.VHS_Retail#woodcraft"]
    local film = offers["Base.VHS_Retail#film-a"]
    ok("both compile", skill ~= nil and film ~= nil)
    ok("the skill tape takes the skill price", skill and film and
        not harness.deepEqual(skill.price, film.price))
    ok("which is the one it was given", skill and harness.deepEqual(skill.price, byKey(compileGroup({
        defaults = {price = "dear"},
        items = {"Base.VHS_Retail"}
    }))["Base.VHS_Retail"].price))
end

print("-- leaving one title out --")
do
    local offers, count = byKey(compileGroup({
        defaults = {price = "cheap"},
        recordings = true,
        items = {"Base.VHS_Retail"},
        blacklist = {"Base.VHS_Retail#woodcraft"}
    }))
    ok("the blacklisted title is gone", offers["Base.VHS_Retail#woodcraft"] == nil)
    ok("the rest stay", count == 1 and offers["Base.VHS_Retail#film-a"] ~= nil, "got " .. count)
end

print("-- a named special giving the tape --")
do
    local special = {
        actions = {{
            type = "giveItem",
            item = "Base.VHS_Retail"
        }}
    }
    local offers = byKey(compileGroup({
        defaults = {price = "cheap", reward = "tape"},
        recordings = true,
        items = {"Base.VHS_Retail"}
    }, {tape = special}))
    local a = offers["Base.VHS_Retail#film-a"]
    local b = offers["Base.VHS_Retail#woodcraft"]
    ok("each offer gets its own title", a and b and a.reward.actions[1].media == "film-a" and
        b.reward.actions[1].media == "woodcraft")
    ok("and the special itself is untouched", special.actions[1].media == nil)
end

print("-- labels --")
do
    -- getText is the identity in the harness, so the label shows its keys.
    ok("a plain title is its name", Recordings.label("film-a") == "RM_film_a")
    ok("a skill tape names the skill once", Recordings.label("woodcraft") == "RM_woodcraft (IGUI_perks_Carpentry)",
        tostring(Recordings.label("woodcraft")))
    ok("an unknown title has no label", Recordings.label("nope") == nil)
end

print("-- restocking a machine --")
do
    -- buildOffers dedupes the candidates it rolls from, and used to do it on
    -- the item alone: every title after the first was thrown away, leaving a
    -- machine of 280 tapes selling one.
    local server = root .. "/Contents/mods/PhunMart2/common/media/lua/server"
    package.path = server .. "/?.lua;" .. package.path
    package.preload["Map/SGlobalObject"] = function()
        _G.SGlobalObject = {
            derive = function(self, name)
                local cls = setmetatable({}, {__index = self})
                cls.__index = cls
                return cls
            end
        }
    end
    package.preload["PhunMart_Server/system"] = function()
        PhunMart.ServerSystem = PhunMart.ServerSystem or {}
    end
    _G.ZombRand = function(a, b)
        return b and a or 0
    end
    require "PhunMart_Server/system_object"
    PhunMart.getBlacklist = PhunMart.getBlacklist or function()
        return {}
    end

    local ctx = {
        prices = {cheap = {kind = "change", amount = 10}},
        specials = {},
        conditionsDefs = {},
        items = {},
        groups = {g = {defaults = {price = "cheap"}, recordings = true, items = {"Base.VHS_Retail"}}},
        pools = {p = {sources = {groups = {"g"}}}},
        shops = {T = {category = "Test", roll = {mode = "all"}, poolSets = {{keys = {"p"}}}}}
    }
    PhunMart.runtime = Compiler.compileAll(ctx)
    local shop = setmetatable({type = "T", x = 0, y = 0}, PhunMart.ServerObject)
    local okCall, err = pcall(shop.buildOffers, shop)
    ok("restocks", okCall, tostring(err))
    local offers, count = byKey(shop.offers or {})
    ok("every title makes it onto the machine", count == 2, "got " .. count)
    local offer = offers["Base.VHS_Retail#woodcraft"]
    ok("still carrying its title", offer and offer.media == "woodcraft")
end

---------------------------------------------------------------------------

print("")
print("passed: " .. passed .. "  failed: " .. failed)
if failed > 0 then
    os.exit(1)
end
