if isClient() then
    return
end

require "PhunMart2/core"
local Core = PhunMart

Core.playtimeRewards = {}
local R = Core.playtimeRewards

local SAVE_FILE = "PhunMart2_PlaytimeTracking.lua"

-- Persistent data loaded from / saved to SAVE_FILE.
-- username → { totalMinutes = N, playtimeRewards = { ["60"] = lastMultiple, ... } }
R.data = {}

function R:load()
    self.data = Core.tools.loadTable(SAVE_FILE) or {}
    self.loaded = true
end

function R:save()
    Core.tools.saveTable(SAVE_FILE, self.data)
end

-- Returns the persistent data record for a player, creating it if absent.
function R:getPlayerData(usernameOrPlayer)

    local name = type(usernameOrPlayer) == "string" and usernameOrPlayer or usernameOrPlayer:getUsername()

    if not self.data[name] then
        self.data[name] = {
            previousHours = 0,
            claimed = {}
        }
    end
    local pd = self.data[name]
    if not pd.previousHours then
        pd.previousHours = 0
    end
    if not pd.claimed then
        pd.claimed = {}
    end
    return pd
end

-- Check and grant any unclaimed playtime milestone rewards for a player.
function R:checkPlaytimeRewards(player)
    local username = player:getUsername()
    local pd = self:getPlayerData(username)
    local cfg = Core.tokenRewardsCfg and Core.tokenRewardsCfg.playtime
    if not cfg then
        return
    end

    for _, entry in ipairs(cfg) do
        local threshold = entry.atMinutes
        if threshold and threshold > 0 then
            local key = "playtime_" .. tostring(threshold)
            if pd.previousHours + player:getHoursSurvived() >= threshold and not pd.claimed[key] then
                pd.claimed[key] = true
                for _, reward in ipairs(entry.rewards or {}) do
                    local label = math.floor(threshold / 60) > 0 and (math.floor(threshold / 60) .. "h playtime") or
                                      (threshold .. "m playtime")
                    Core:grantConfigReward(player, reward, label)
                end
                Core.debugLn("[PlaytimeRewards] " .. username .. " claimed milestone " .. key)
            end
        end
    end
end

-- currently online players, then persists the updated data.
function R:tick()
    if not self.loaded then return end
    local players = Core.tools.onlinePlayers(true)
    if not players then
        return
    end
    for i = 0, players:size() - 1 do
        local player = players:get(i)
        if player then
            self:checkPlaytimeRewards(player)
        end
    end
    self:save()
end
