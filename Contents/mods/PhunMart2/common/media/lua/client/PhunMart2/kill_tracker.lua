if isServer() then return end

require "PhunMart2/core"
local Core = PhunMart

local pendingNormal   = 0
local pendingSprinter = 0
local lastFlushTime   = 0
local FLUSH_INTERVAL  = 30  -- real-world seconds between batched reports

-- Count every zombie death reported on this client.
-- Uses isSprinter() to distinguish sprinter vs. normal.
Events.OnZombieDead.Add(function(zombie)
    if not zombie then return end
    local ok, sprinter = pcall(function() return zombie:isSprinter() end)
    if ok and sprinter then
        pendingSprinter = pendingSprinter + 1
    else
        -- Either isSprinter() returned false or threw (treat as normal).
        pendingNormal = pendingNormal + 1
    end
end)

-- Every tick: flush the pending batch to the server if the interval has elapsed
-- and there is anything to report.
Events.OnTick.Add(function()
    if pendingNormal == 0 and pendingSprinter == 0 then return end
    local now = getTimestamp()
    if now - lastFlushTime < FLUSH_INTERVAL then return end
    lastFlushTime = now
    sendClientCommand(Core.name, Core.commands.reportKills, {
        normal   = pendingNormal,
        sprinter = pendingSprinter
    })
    pendingNormal   = 0
    pendingSprinter = 0
end)
