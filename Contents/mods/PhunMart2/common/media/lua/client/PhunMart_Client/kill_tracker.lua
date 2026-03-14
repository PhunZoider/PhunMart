if isServer() then
    return
end

require "PhunMart/core"
local Core = PhunMart

local pendingNormal = 0
local pendingSprinter = 0
local lastFlushTime = 0
local FLUSH_INTERVAL = 30 -- real-world seconds between batched reports

local checkSprinters = nil

-- Count every zombie death reported on this client.
-- Uses isSprinter() to distinguish sprinter vs. normal.
Events.OnZombieDead.Add(function(zombie)
    if not zombie then
        return
    end

    if checkSprinters == nil then
        -- Check if the isSprinter() method exists on zombies. It was added in 41.62.
        checkSprinters = PhunSprinters ~= nil
    end

    local killer = zombie:getAttackedBy()
    local data = {}
    if checkSprinters then
        data = zombie:getModData().PhunSprinters or {}
    end
    if data.sprinter then
        pendingSprinter = pendingSprinter + 1
    else
        pendingNormal = pendingNormal + 1
    end

end)

-- Every tick: flush the pending batch to the server if the interval has elapsed
-- and there is anything to report.
Events.OnTick.Add(function()
    if pendingNormal == 0 and pendingSprinter == 0 then
        return
    end
    local now = getTimestamp()
    if now - lastFlushTime < FLUSH_INTERVAL then
        return
    end
    lastFlushTime = now
    sendClientCommand(Core.name, Core.commands.reportKills, {
        normal = pendingNormal,
        sprinter = pendingSprinter
    })
    pendingNormal = 0
    pendingSprinter = 0
end)
