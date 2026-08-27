if isClient() then
    return
end

require "PhunMart/core"
local Core = PhunMart

Core.playtimeRewards = {}
local R = Core.playtimeRewards

-- Held in ModData, so it belongs to the save the progress was earned in.
-- username → { previousHours = N, claimed = { ["playtime_60"] = true, ... } }
--
-- This was PhunMart_PlaytimeTracking.txt, which had the install lifetime
-- rather than the save's: milestones stayed claimed across a wipe, and every
-- world on the machine shared one set of them.
R.data = {}

-- The key singleplayer files its progress under. The string "0" and not the
-- number 0, which is what it used to be: the legacy import reads a converted
-- PhunMart_PlaytimeTracking.json, and JSON object keys are necessarily
-- strings, so a number on this side would never match the record coming in.
-- "0" rather than a readable name because that is what the old number turns
-- into through the converter. Same constant in wallet.lua and rewards_kill.lua.
local SP_KEY = "0"

function R:load()
    self.data = ModData.getOrCreate("PhunMart_PlaytimeTracking")
    self.loaded = true
end

-- Returns the persistent data record for a player, creating it if absent.
-- In SP, getUsername() returns the character name which changes per playthrough,
-- so we key on a constant to preserve progress across characters.
function R:getPlayerData(usernameOrPlayer)

    local name
    if Core.isLocal then
        name = SP_KEY
    elseif type(usernameOrPlayer) == "string" then
        name = usernameOrPlayer
    else
        name = usernameOrPlayer:getUsername()
    end

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
    if Core.getOption("EnableTokenPool") == false then
        return
    end
    local username = player:getUsername()
    local pd = self:getPlayerData(username)
    local cfg = Core.tokenRewardsCfg and Core.tokenRewardsCfg.playtime
    if not cfg then
        return
    end

    local totalMinutes = (pd.previousHours + player:getHoursSurvived()) * 60

    for _, entry in ipairs(cfg) do
        if entry.atMinutes and entry.atMinutes > 0 then
            local threshold = entry.atMinutes
            local key = "playtime_" .. tostring(threshold)
            if totalMinutes >= threshold and not pd.claimed[key] then
                pd.claimed[key] = true
                local label = math.floor(threshold / 60) > 0 and (math.floor(threshold / 60) .. "h playtime") or
                                  (threshold .. "m playtime")
                for _, reward in ipairs(entry.rewards or {}) do
                    Core:grantConfigReward(player, reward, label)
                end
                Core.debugLn("[PlaytimeRewards] " .. username .. " claimed milestone " .. key)
            end
        elseif entry.everyMinutes and entry.everyMinutes > 0 then
            local interval = entry.everyMinutes
            local key = "playtime_every_" .. tostring(interval)
            local multiple = math.floor(totalMinutes / interval)
            if pd.claimed[key] == nil then
                pd.claimed[key] = multiple
                Core.debugLn("[PlaytimeRewards] " .. username .. " initialized recurring baseline " .. key .. " at " ..
                                 multiple)
            elseif multiple > pd.claimed[key] then
                local gained = multiple - pd.claimed[key]
                pd.claimed[key] = multiple
                local label = interval .. "m interval"
                for _ = 1, gained do
                    for _, reward in ipairs(entry.rewards or {}) do
                        Core:grantConfigReward(player, reward, label)
                    end
                end
                Core.debugLn("[PlaytimeRewards] " .. username .. " claimed " .. gained .. "x recurring " .. key)
            end
        end
    end
end

-- currently online players, then persists the updated data.
function R:tick()
    if not self.loaded then
        return
    end
    local players = Core.utils.onlinePlayers(true)
    if not players then
        return
    end
    for i = 0, players:size() - 1 do
        local player = players:get(i)
        if player then
            self:checkPlaytimeRewards(player)
        end
    end
end
