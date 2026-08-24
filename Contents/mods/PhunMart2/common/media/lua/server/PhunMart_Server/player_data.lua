if isClient() then
    return
end

-- Player data: where it lives, and clearing it on request.
--
-- Wallets, purchase history and the two reward trackers all live in ModData, so
-- they belong to the save that produced them. That is a recent change. They
-- used to be written to files beside the mod, which have the install lifetime
-- rather than the save's, and the mismatch caused three separate problems: a
-- wiped world inherited the previous one's balances, two saves on one machine
-- shared a purchase history, and the wallet's file-versus-ModData merge rule
-- preferred whichever number was larger, which could only ever create money.
--
-- Moving them removed all three at once, and with them the machinery that used
-- to detect a wipe and offer to tidy up after it. There is nothing left to
-- detect: a new world starts with new ModData and therefore starts empty.
--
-- What remains is the part that was worth keeping on its own merits. Clearing
-- player data mid-game is a thing admins want to do without wiping anything.

local Core = PhunMart
local fileUtils = require "PhunMart_Server/utils_file"
local State = require "PhunMart_Server/state"

local PlayerData = {}

-- One-off import of the files the old design left behind. Install-scoped, so
-- it happens for the first save loaded after upgrading and never again.
local IMPORTED_KEY = "trackersImported"

local function log(msg)
    print("[PhunMart][playerdata] " .. msg)
    if Core.debugLn then
        Core.debugLn("[playerdata] " .. msg)
    end
end

local function countKeys(tbl)
    local n = 0
    for _ in pairs(tbl or {}) do
        n = n + 1
    end
    return n
end

--- Empty a table without replacing it. These are ModData tables held by
--- reference all over the mod, so handing back a fresh one would leave every
--- existing reference pointing at the old contents. Clearing keys during
--- pairs() is defined; adding them is not.
local function clearTable(tbl)
    if type(tbl) ~= "table" then
        return 0
    end
    local n = 0
    for k in pairs(tbl) do
        tbl[k] = nil
        n = n + 1
    end
    return n
end

---------------------------------------------------------------------------
-- What counts as player data
--
-- `live` is the ModData table. `legacy` is the file the same data used to be
-- kept in, read once on upgrade and then left alone for good.
---------------------------------------------------------------------------

PlayerData.trackers = {{
    key = "wallets",
    -- No `legacy`: the old PhunMart_Wallet.txt was a mirror of ModData rather
    -- than the store itself, so this save already holds the right numbers and
    -- there is nothing to import. See importLegacy.
    live = function()
        return Core.wallet and Core.wallet.data
    end
}, {
    key = "purchases",
    legacy = "PhunMart_Purchases.txt",
    live = function()
        return Core.purchases and Core.purchases.histories
    end
}, {
    key = "playtime",
    legacy = "PhunMart_PlaytimeTracking.txt",
    live = function()
        return Core.playtimeRewards and Core.playtimeRewards.data
    end
}, {
    key = "kills",
    legacy = "PhunMart_KillTracking.txt",
    live = function()
        return Core.killRewards and Core.killRewards.data
    end
}}

--- How many players each tracker holds data for.
function PlayerData.counts()
    local out = {}
    for _, t in ipairs(PlayerData.trackers) do
        out[t.key] = countKeys(t.live())
    end
    return out
end

---------------------------------------------------------------------------
-- Import
---------------------------------------------------------------------------

--- Move what the old files hold into ModData, once.
---
--- Wallets are skipped. They were already ModData-backed with the file as a
--- mirror, so the save already has the right numbers and importing could only
--- reintroduce the cross-save bleed the move was meant to end.
---
--- The files are left exactly as they are. PZ Lua cannot delete them anyway,
--- and an untouched copy of everybody's balances costs nothing to keep and is
--- the only way back if this misreads something.
---
--- Install-scoped rather than per-save, so the first world loaded after the
--- upgrade takes the data and a world started later does not. That is right in
--- the case that matters, which is an admin upgrading and loading the server
--- they were already running.
function PlayerData.importLegacy()
    if State.get(IMPORTED_KEY) == true then
        return
    end

    local imported = {}
    for _, t in ipairs(PlayerData.trackers) do
        if t.legacy then
            local target = t.live()
            -- Only into an empty table. A save that already has data of its own
            -- is not one that needs anything restored to it.
            if type(target) == "table" and countKeys(target) == 0 then
                local saved = fileUtils.loadTable(t.legacy)
                local n = 0
                for key, value in pairs(saved or {}) do
                    target[key] = value
                    n = n + 1
                end
                if n > 0 then
                    table.insert(imported, t.key .. "=" .. tostring(n))
                end
            end
        end
    end

    State.set(IMPORTED_KEY, true)
    if #imported > 0 then
        log("imported from the old tracker files: " .. table.concat(imported, " "))
        log("the files themselves are untouched and no longer read")
    end
end

---------------------------------------------------------------------------
-- Clearing
---------------------------------------------------------------------------

--- Clear the trackers named in `opts`, a set of tracker keys.
---
--- `opts.wallets` resets rather than empties: balances go, bound totals come
--- back, which is what a wallet reset means everywhere else in the mod.
--- `opts.bound` additionally zeroes those, for a reset meant to carry nothing
--- forward at all.
---
--- @return a table of tracker key -> how many records it touched
function PlayerData.clear(opts)
    opts = opts or {}
    local done = {}

    if opts.wallets then
        local data = Core.wallet and Core.wallet.data
        if data then
            -- Keys first. reset() goes through Core.wallet:get, which creates a
            -- record when it does not find one, and adding a key mid-pairs() is
            -- undefined. It should always find one here, but "should" is not a
            -- reason to iterate a table something else is allowed to grow.
            local keys = {}
            for key in pairs(data) do
                table.insert(keys, key)
            end
            for _, key in ipairs(keys) do
                Core.wallet:reset(key)
                if opts.bound then
                    local w = data[key]
                    if w then
                        clearTable(w.current)
                        clearTable(w.bound)
                    end
                end
            end
            done.wallets = #keys
        else
            done.wallets = 0
        end
    end

    for _, t in ipairs(PlayerData.trackers) do
        -- Wallets are handled above; the rest are a straight empty.
        if t.key ~= "wallets" and opts[t.key] then
            done[t.key] = clearTable(t.live())
        end
    end

    local summary = {}
    for key, n in pairs(done) do
        table.insert(summary, key .. "=" .. tostring(n))
    end
    table.sort(summary)
    log("cleared " .. (#summary > 0 and table.concat(summary, " ") or "nothing"))

    return done
end

Core.playerData = PlayerData
return PlayerData
