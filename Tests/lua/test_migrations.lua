-- Migrations mutate an admin's own override files, in place, on server start.
-- A migration that gets it wrong is worse than no migration at all, so the ones
-- that move data rather than delete it are pinned here.
--
-- Run: luajit test_migrations.lua   (or run.cmd, which runs all of them)

local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = arg[1] or (here .. "/../..")
package.path = here .. "/?.lua;" .. package.path

local harness = require "harness"

local shared = root .. "/Contents/mods/PhunMart2/common/media/lua/shared"
local server = root .. "/Contents/mods/PhunMart2/common/media/lua/server"
package.path = shared .. "/?.lua;" .. server .. "/?.lua;" .. package.path

harness.installGlobals()

_G.SandboxVars = {PhunMart = {Debug = false}}
_G.LuaEventManager = {AddEvent = function() end}
_G.getSandboxOptions = function()
    return {getOptionByName = function() return nil end}
end
_G.ModData = {
    getOrCreate = function() return {} end
}

require "PhunMart/core"
local Core = _G.PhunMart
Core.fileUtils = require "PhunMart_Server/utils_file"

local Migrations = require "PhunMart_Server/migrations"

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

--- Whether a table holds nothing. `next` is not exposed in PZ B42.20.4, so
--- neither the mod nor its tests may reach for it.
local function isEmpty(t)
    for _ in pairs(t) do
        return false
    end
    return true
end

--- The migration at `version`, found by its stamp rather than its position.
local function migration(version)
    for _, m in ipairs(Migrations.list) do
        if m.version == version then
            return m
        end
    end
end

--- Run one migration over a set of override files and report what it touched.
local function run(version, files)
    local touched = {}
    local changed = migration(version).apply(files, function(name)
        touched[name] = true
    end)
    return changed, touched
end

local GROUPS = "PhunMart_Groups.json"
local ITEMS = "PhunMart_Items.json"
local SPECIALS = "PhunMart_Specials.json"

---------------------------------------------------------------------------

print("-- v2: a group that named a removed vehicle special --")
do
    local files = {
        [GROUPS] = {
            my_cars = {
                defaults = {reward = "vehicle_luxury"},
                items = {"CarLuxury", "91range"}
            }
        }
    }
    local changed, touched = run(2, files)
    local d = files[GROUPS].my_cars.defaults

    ok("it reports the change", changed == 1, "changed " .. tostring(changed))
    ok("and marks the file for writing", touched[GROUPS] == true)
    ok("the reward is cleared", d.reward == nil, "reward was " .. tostring(d.reward))
    ok("the band's price lands on the group", d.price == "vehicle_rare", "price was " .. tostring(d.price))
    ok("with the band's weight", d.offer and d.offer.weight == 0.5,
        "weight was " .. tostring(d.offer and d.offer.weight))
    ok("and single stock", d.offer and d.offer.stock and d.offer.stock.max == 1)
    ok("the condition range comes across", d.spawn and d.spawn.condition and d.spawn.condition.min == 85)
    ok("the car list is untouched", #files[GROUPS].my_cars.items == 2)
end

print("-- v2: an admin's own settings outrank the band --")
do
    -- Their price beat the special's before the migration ran. It has to keep
    -- beating it afterwards, or the upgrade quietly reprices their shop.
    local files = {
        [GROUPS] = {
            my_cars = {
                defaults = {
                    reward = "vehicle_luxury",
                    price = "my_own_price",
                    offer = {weight = 0.25},
                    spawn = {condition = {min = 10, max = 20}}
                }
            }
        }
    }
    run(2, files)
    local d = files[GROUPS].my_cars.defaults

    ok("their price survives", d.price == "my_own_price", "price was " .. tostring(d.price))
    ok("their weight survives", d.offer.weight == 0.25, "weight was " .. tostring(d.offer.weight))
    ok("their condition survives", d.spawn.condition.min == 10)
    ok("stock is still filled in", d.offer.stock ~= nil)
    ok("the reward is still cleared", d.reward == nil)
end

print("-- v2: an item override that named one --")
do
    local files = {
        [ITEMS] = {
            CarLuxury = {reward = "vehicle_luxury"},
            ["Base.Axe"] = {price = "tools_dear"}
        }
    }
    local changed = run(2, files)
    ok("only the vehicle entry is touched", changed == 1, "changed " .. tostring(changed))
    ok("its reward is cleared", files[ITEMS].CarLuxury.reward == nil)
    ok("its price comes from the band", files[ITEMS].CarLuxury.price == "vehicle_rare")
    ok("the unrelated item is left alone", files[ITEMS]["Base.Axe"].price == "tools_dear")
    ok("and gains nothing", files[ITEMS]["Base.Axe"].offer == nil)
end

print("-- v2: a stranded patch of a removed special --")
do
    -- A partial override of a shipped special that no longer exists would
    -- resolve to a special with no actions. That passes the "has a reward"
    -- check, so the offer would be SOLD and hand over nothing.
    local files = {
        [SPECIALS] = {
            vehicle_luxury = {price = "token_50"},
            vehicle_van = {
                price = "token_10",
                actions = {{type = "spawnVehicle", scripts = {"Van"}}}
            },
            add_brave = {price = "token_99"}
        }
    }
    local changed = run(2, files)

    ok("the actionless fragment is dropped", files[SPECIALS].vehicle_luxury == nil)
    ok("one that stands on its own is kept", files[SPECIALS].vehicle_van ~= nil)
    ok("an unrelated special is kept", files[SPECIALS].add_brave ~= nil)
    ok("only the fragment counted", changed == 1, "changed " .. tostring(changed))
end

print("-- v2: nothing to do --")
do
    local files = {
        [GROUPS] = {tools_general = {items = {"Base.Axe"}}}
    }
    local changed, touched = run(2, files)
    ok("it reports no changes", changed == 0, "changed " .. tostring(changed))
    ok("and touches no file", isEmpty(touched))
end

print("-- v2: files absent from disk --")
do
    -- loadTable returns nil for a file that is not there, so it never reaches
    -- the table. Indexing one unconditionally is the easy way to break start-up
    -- for everyone who never wrote an override.
    local changed = run(2, {})
    ok("an empty set is survivable", changed == 0, "changed " .. tostring(changed))
end

print("-- the version stamp covers every migration --")
do
    local highest = 0
    for _, m in ipairs(Migrations.list) do
        if m.version > highest then
            highest = m.version
        end
    end
    ok("CURRENT is not behind the list", Migrations.CURRENT >= highest,
        "CURRENT=" .. tostring(Migrations.CURRENT) .. " highest=" .. tostring(highest))
    ok("and not ahead of it", Migrations.CURRENT == highest,
        "CURRENT=" .. tostring(Migrations.CURRENT) .. " highest=" .. tostring(highest))
end

---------------------------------------------------------------------------

print("")
print("passed: " .. passed .. "  failed: " .. failed)
if failed > 0 then
    os.exit(1)
end
