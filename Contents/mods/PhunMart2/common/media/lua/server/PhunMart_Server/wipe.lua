if isClient() then
    return
end

-- Noticing that the world was replaced, and clearing what should not have
-- outlived it.
--
-- PhunMart keeps two kinds of persistent state in two places with different
-- lifetimes. Definitions live in files beside the mod, one set per install, so
-- a wipe keeps the shops you configured. Player state lives in ModData, one set
-- per save, so a wipe takes it with it.
--
-- Except it does not, quite. Wallets, purchase history and the reward trackers
-- are mirrored to files as well, so they survive a crash between game saves.
-- Those files have the install lifetime, not the save lifetime, and nothing
-- ever told them apart: Core.wallet:load merges the file back over the empty
-- ModData of a brand new world and hands everybody their old balance.
--
-- So the save is stamped with a token that the shared state file remembers.
-- A save with no stamp, when we have seen a stamped one before and the
-- trackers still hold data, is a new world wearing an old world's money.
--
-- Detection only raises a flag. What to clear is a judgement call about a
-- particular server, and quietly deleting balances on boot is not a decision
-- this code gets to make.

local Core = PhunMart
local fileUtils = require "PhunMart_Server/utils_file"
local State = require "PhunMart_Server/state"

local Wipe = {}

-- The last world we saw, mirrored into the save's own ModData.
local WORLD_KEY = "worldToken"
-- Raised on detection, cleared when an admin has dealt with it either way.
local PENDING_KEY = "wipePending"

-- Its own ModData table rather than a key on "PhunMart": that one holds shop
-- instances and is walked with pairs(), so a stray string value in it would be
-- read as an instance and crash the walk.
local WORLD_MODDATA = "PhunMart_World"

local function log(msg)
    print("[PhunMart][wipe] " .. msg)
    if Core.debugLn then
        Core.debugLn("[wipe] " .. msg)
    end
end

local function countKeys(tbl)
    local n = 0
    for _ in pairs(tbl or {}) do
        n = n + 1
    end
    return n
end

--- Empty a table without replacing it. The wallet table is ModData and the
--- others are held by reference all over the mod, so handing back a fresh one
--- would leave every existing reference pointing at the old contents.
--- Clearing keys during pairs() is defined; adding them is not.
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
-- What counts as a tracker
--
-- `live` is the in-memory table once the server has booted; `file` is where it
-- is mirrored. Detection reads the files, because it runs before the loads.
-- Everything after that works on the live tables and saves them back.
---------------------------------------------------------------------------

Wipe.trackers = {{
    key = "wallets",
    file = "PhunMart_Wallet.txt",
    live = function()
        return Core.wallet and Core.wallet.data
    end,
    save = function()
        if Core.wallet then
            Core.wallet:save()
        end
    end
}, {
    key = "purchases",
    file = "PhunMart_Purchases.txt",
    live = function()
        return Core.purchases and Core.purchases.histories
    end,
    save = function()
        if Core.purchases then
            Core.purchases:save()
        end
    end
}, {
    key = "playtime",
    file = "PhunMart_PlaytimeTracking.txt",
    live = function()
        return Core.playtimeRewards and Core.playtimeRewards.data
    end,
    save = function()
        if Core.playtimeRewards then
            Core.playtimeRewards:save()
        end
    end
}, {
    key = "kills",
    file = "PhunMart_KillTracking.txt",
    live = function()
        return Core.killRewards and Core.killRewards.data
    end,
    save = function()
        if Core.killRewards then
            Core.killRewards:save()
        end
    end
}}

--- How many players each tracker is holding data for. Live tables where they
--- exist, falling back to the files for a call made before the loads.
function Wipe.counts()
    local out = {}
    for _, t in ipairs(Wipe.trackers) do
        local tbl = t.live()
        if tbl == nil then
            tbl = fileUtils.loadTable(t.file)
        end
        out[t.key] = countKeys(tbl)
    end
    return out
end

--- Whether the files hold anything, read from disk regardless of what is in
--- memory. Detection is a question about what survived the save, and the live
--- tables at boot are empty either way, so asking them would answer "nothing"
--- for a genuine wipe and miss it entirely.
local function anyTrackerFileData()
    for _, t in ipairs(Wipe.trackers) do
        if countKeys(fileUtils.loadTable(t.file)) > 0 then
            return true
        end
    end
    return false
end

---------------------------------------------------------------------------
-- Detection
---------------------------------------------------------------------------

local function newToken()
    -- Seconds plus noise. Two worlds created in the same second on the same
    -- machine is not a case worth engineering around, but it costs nothing to
    -- make it impossible rather than unlikely.
    return tostring(getTimestamp()) .. "-" .. tostring(ZombRand(1000000))
end

--- Compare the running save against the last one we saw. Called once, from
--- Core:ini, before the trackers load.
--- @return true when a wipe was detected on this boot
function Wipe.check()
    if Wipe._checked then
        return Wipe.isPending()
    end
    Wipe._checked = true

    local md = ModData.getOrCreate(WORLD_MODDATA)
    local saveToken = md.token
    local seenToken = State.get(WORLD_KEY)

    if saveToken ~= nil then
        -- A stamped save. If it is not the one we last saw, the admin has
        -- switched saves or restored a backup rather than wiped. The tracker
        -- files are shared by every save on the machine either way, so there is
        -- nothing here we could tell them that would be true.
        if saveToken ~= seenToken then
            State.set(WORLD_KEY, saveToken)
        end
        return false
    end

    -- No stamp on this save, so it has never run PhunMart before.
    saveToken = newToken()
    md.token = saveToken

    if seenToken == nil then
        -- Nor have we stamped anything else. Either a fresh install or the
        -- first boot after this feature shipped; both have nothing to compare
        -- against, so mark and move on. This is what keeps the upgrade from
        -- announcing a wipe to everybody at once.
        State.set(WORLD_KEY, saveToken)
        return false
    end

    if not anyTrackerFileData() then
        -- New world, and nothing left over to worry about.
        State.set(WORLD_KEY, saveToken)
        return false
    end

    State.setAll({
        [WORLD_KEY] = saveToken,
        [PENDING_KEY] = true
    })
    log("new world detected with player data left from the previous one")
    return true
end

function Wipe.isPending()
    return State.get(PENDING_KEY) == true
end

--- Stop asking. Called once an admin has either cleared something or decided
--- to keep it; both count as having dealt with it.
function Wipe.dismiss()
    State.set(PENDING_KEY, false)
end

---------------------------------------------------------------------------
-- Clearing
---------------------------------------------------------------------------

--- Clear the trackers named in `opts`, a set of tracker keys.
---
--- `opts.wallets` resets rather than empties: balances go, bound totals come
--- back, which is what a wallet reset has always meant everywhere else in the
--- mod. `opts.bound` additionally zeroes those, for a wipe that is meant to
--- carry nothing at all forward.
---
--- @return a table of tracker key -> how many records it touched
function Wipe.clear(opts)
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
            Core.wallet:save()
            done.wallets = #keys
        else
            done.wallets = 0
        end
    end

    for _, t in ipairs(Wipe.trackers) do
        -- Wallets are handled above; the rest are a straight empty.
        if t.key ~= "wallets" and opts[t.key] then
            done[t.key] = clearTable(t.live())
            t.save()
        end
    end

    local summary = {}
    for key, n in pairs(done) do
        table.insert(summary, key .. "=" .. tostring(n))
    end
    table.sort(summary)
    log("cleared " .. (#summary > 0 and table.concat(summary, " ") or "nothing"))

    Wipe.dismiss()
    return done
end

Core.wipe = Wipe
return Wipe
