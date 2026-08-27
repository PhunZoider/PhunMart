-- Covers the seasonal pool gate: parsing a months restriction, and deciding
-- whether a compiled pool is in season.
--
-- The one thing here that is genuinely easy to get wrong is the offset.
-- GameTime numbers months from zero, so a pool authored as month 12 has to be
-- matched against getMonth() == 11. Vanilla farming, foraging and Seasons all
-- write getMonth() + 1 for the same reason. Get it backwards and the Christmas
-- pool stocks in November, which is the kind of thing nobody notices until
-- December.
--
-- Run: luajit test_months.lua   (or run.cmd, which runs all of them)

local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = arg[1] or (here .. "/../..")
package.path = here .. "/?.lua;" .. package.path

local harness = require "harness"

local shared = root .. "/Contents/mods/PhunMart2/common/media/lua/shared"
local server = root .. "/Contents/mods/PhunMart2/common/media/lua/server"
package.path = shared .. "/?.lua;" .. server .. "/?.lua;" .. package.path

harness.installGlobals()

-- A stand-in for the engine clock. GameTime months are 0-based, so this stores
-- what the engine would store and the code under test does the adjusting.
local fakeMonth0 = nil
_G.getGameTime = function()
    if fakeMonth0 == nil then
        return nil
    end
    return {
        getMonth = function()
            return fakeMonth0
        end
    }
end

-- Set the world clock using a human month, 1-12.
local function setMonth(month1to12)
    fakeMonth0 = month1to12 and (month1to12 - 1) or nil
end

local utils = require "PhunMart/utils"

harness.strip()

---------------------------------------------------------------------------

local passed, failed = 0, 0

local function check(name, ok, detail)
    if ok then
        passed = passed + 1
        print("  ok    " .. name)
    else
        failed = failed + 1
        print("  FAIL  " .. name .. (detail and ("  -- " .. detail) or ""))
    end
end

local function listOf(value)
    return utils.monthsToList(utils.parseMonths(value))
end

local function sameList(got, want)
    if got == nil and want == nil then
        return true
    end
    if got == nil or want == nil then
        return false
    end
    if #got ~= #want then
        return false
    end
    for i = 1, #want do
        if got[i] ~= want[i] then
            return false
        end
    end
    return true
end

local function showList(list)
    if list == nil then
        return "nil"
    end
    local parts = {}
    for _, v in ipairs(list) do
        table.insert(parts, tostring(v))
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

---------------------------------------------------------------------------
print("\n-- parseMonths: empty means no restriction --")

for _, empty in ipairs({"nil", "", "{}", "  ,  "}) do
    local value = empty == "nil" and nil or (empty == "{}" and {} or empty)
    local set = utils.parseMonths(value)
    check("'" .. empty .. "' parses to no restriction", set == nil)
end

---------------------------------------------------------------------------
print("\n-- parseMonths: both spellings --")

check("CSV string '12'", sameList(listOf("12"), {12}), showList(listOf("12")))
check("CSV string '11,12'", sameList(listOf("11,12"), {11, 12}), showList(listOf("11,12")))
check("CSV with spaces ' 11 , 12 '", sameList(listOf(" 11 , 12 "), {11, 12}), showList(listOf(" 11 , 12 ")))
check("array {12}", sameList(listOf({12}), {12}), showList(listOf({12})))
check("array {11,12}", sameList(listOf({11, 12}), {11, 12}), showList(listOf({11, 12})))

-- The editor writes sorted, but a hand-authored override need not be.
check("unsorted input comes back sorted", sameList(listOf("12,3,7"), {3, 7, 12}), showList(listOf("12,3,7")))
check("duplicates collapse", sameList(listOf("12,12,12"), {12}), showList(listOf("12,12,12")))
check("all twelve months", #(listOf("1,2,3,4,5,6,7,8,9,10,11,12") or {}) == 12)

---------------------------------------------------------------------------
print("\n-- parseMonths: out of range is dropped and reported --")

local set, invalid = utils.parseMonths("13")
check("month 13 leaves no restriction", set == nil)
check("month 13 is reported as invalid", invalid ~= nil and invalid[1] == "13")

set, invalid = utils.parseMonths("0")
check("month 0 is invalid (months are 1-12, not 0-11)", set == nil and invalid ~= nil)

set, invalid = utils.parseMonths("12,13")
check("valid months survive alongside an invalid one", sameList(utils.monthsToList(set), {12}))
check("the invalid one is still reported", invalid ~= nil and invalid[1] == "13")

set, invalid = utils.parseMonths("dec")
check("non-numeric is invalid", set == nil and invalid ~= nil and invalid[1] == "dec")

set, invalid = utils.parseMonths("6.5")
check("fractional month is invalid", set == nil and invalid ~= nil)

set, invalid = utils.parseMonths(true)
check("a boolean is invalid rather than an error", set == nil and invalid ~= nil)

---------------------------------------------------------------------------
print("\n-- currentGameMonth: the 0-based engine, corrected --")

setMonth(12)
check("December reads as 12, not 11", utils.currentGameMonth() == 12,
    "got " .. tostring(utils.currentGameMonth()))
setMonth(1)
check("January reads as 1, not 0", utils.currentGameMonth() == 1, "got " .. tostring(utils.currentGameMonth()))
setMonth(7)
check("July reads as 7", utils.currentGameMonth() == 7, "got " .. tostring(utils.currentGameMonth()))

fakeMonth0 = nil
check("no clock yet returns nil", utils.currentGameMonth() == nil)

---------------------------------------------------------------------------
print("\n-- poolInSeason --")

local yearRound = {}
local december = {months = utils.parseMonths("12")}
local winter = {months = utils.parseMonths("11,12,1")}

check("a pool with no months sells in any month", utils.poolInSeason(yearRound, 6))
check("a pool with no months sells with no clock", utils.poolInSeason(yearRound, nil))

check("December pool sells in December", utils.poolInSeason(december, 12))
check("December pool does not sell in November", not utils.poolInSeason(december, 11))
check("December pool does not sell in January", not utils.poolInSeason(december, 1))

for m = 1, 12 do
    if m ~= 12 then
        if utils.poolInSeason(december, m) then
            check("December pool wrongly sells in month " .. m, false)
        end
    end
end
check("December pool sells in exactly one month", true)

check("winter pool sells in November", utils.poolInSeason(winter, 11))
check("winter pool sells in December", utils.poolInSeason(winter, 12))
check("winter pool sells in January", utils.poolInSeason(winter, 1))
check("winter pool does not sell in February", not utils.poolInSeason(winter, 2))
check("winter pool does not sell in July", not utils.poolInSeason(winter, 7))

-- The permissive fallback. A seasonal pool that silently vanished because the
-- clock was not ready would be very hard to trace back to this.
check("an unknown month sells rather than hides", utils.poolInSeason(december, nil))

---------------------------------------------------------------------------
print("\n-- end to end, through the engine clock --")

setMonth(12)
check("December pool is in season when the world says December",
    utils.poolInSeason(december, utils.currentGameMonth()))
setMonth(11)
check("December pool is out of season when the world says November",
    not utils.poolInSeason(december, utils.currentGameMonth()))
setMonth(1)
check("December pool is out of season when the world says January",
    not utils.poolInSeason(december, utils.currentGameMonth()))

---------------------------------------------------------------------------
print("")
print("passed: " .. passed .. "  failed: " .. failed)
if failed > 0 then
    os.exit(1)
end
