if isServer() then
    return
end

require "PhunMart/core"
local Core = PhunMart

-- playerNum -> { normal = N, sprinter = N }, for players controlled on this
-- machine only. Kept per killer so split screen does not pool both players'
-- kills into a single report credited to whoever sent it.
local pending = {}
local pendingCount = 0
local lastFlushTime = 0
local FLUSH_INTERVAL = 30 -- real-world seconds between batched reports

local checkSprinters = nil

-- OnZombieDead fires on every client that has the zombie loaded, not only on
-- the one whose player killed it, so counting the raw event credited every
-- player standing near a kill they had no part in. Credit the attacker, and
-- only when the attacker is a player this machine controls: a remote player's
-- kills are reported by their own client.
local function killerPlayerNum(zombie)
    local killer = zombie:getAttackedBy()
    -- instanceof("IsoPlayer") also matches IsoAnimal in current B42 builds, so
    -- reject animals explicitly before calling anything IsoPlayer-only.
    if not killer or not instanceof(killer, "IsoPlayer") or killer:isAnimal() then
        return nil
    end
    if not killer:isLocalPlayer() then
        return nil
    end
    return killer:getPlayerNum()
end

-- Count zombie deaths caused by a player on this client.
Events.OnZombieDead.Add(function(zombie)
    if not zombie then
        return
    end

    if Core.getOption("EnableTokenPool") == false then
        return
    end

    local num = killerPlayerNum(zombie)
    if not num then
        return
    end

    if checkSprinters == nil then
        -- Sprinters are flagged in mod data by PhunSprinters, so there is
        -- nothing to look up unless that mod is loaded.
        checkSprinters = PhunSprinters ~= nil
    end

    local data = {}
    if checkSprinters then
        data = zombie:getModData().PhunSprinters or {}
    end

    local batch = pending[num]
    if not batch then
        batch = {
            normal = 0,
            sprinter = 0
        }
        pending[num] = batch
        pendingCount = pendingCount + 1
    end

    if data.sprinter then
        batch.sprinter = batch.sprinter + 1
    else
        batch.normal = batch.normal + 1
    end

end)

-- Every tick: flush the pending batches to the server if the interval has
-- elapsed and there is anything to report.
Events.OnTick.Add(function()
    if pendingCount == 0 then
        return
    end
    local now = getTimestamp()
    if now - lastFlushTime < FLUSH_INTERVAL then
        return
    end
    lastFlushTime = now
    for num, batch in pairs(pending) do
        local player = getSpecificPlayer(num)
        if player then
            -- Four-argument form: the server credits the player the command
            -- names, rather than always attributing to player zero.
            sendClientCommand(player, Core.name, Core.commands.reportKills, {
                normal = batch.normal,
                sprinter = batch.sprinter
            })
        end
    end
    pending = {}
    pendingCount = 0
end)
