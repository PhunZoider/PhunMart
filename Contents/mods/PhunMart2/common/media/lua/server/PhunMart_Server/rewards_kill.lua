if isClient() then return end

require "PhunMart/core"
local Core = PhunMart

Core.killRewards = {}
local R = Core.killRewards

local SAVE_FILE = "PhunMart_KillTracking.lua"

-- Persistent data loaded from / saved to SAVE_FILE.
-- username → {
--   zombieKills  = N,   -- total cumulative normal zombie kills
--   sprinterKills = N,  -- total cumulative sprinter kills
--   claimed = {         -- set of milestone keys already rewarded
--     ["zombie_100"] = true,
--     ["sprinter_50"] = true,
--     ...
--   }
-- }
R.data = {}

function R:load()
    self.data = Core.fileUtils.loadTable(SAVE_FILE) or {}
    self.loaded = true
end

function R:save()
    Core.fileUtils.saveTable(SAVE_FILE, self.data)
end

-- Returns the persistent data record for a player, creating it if absent.
-- In SP, getUsername() returns the character name which changes per playthrough,
-- so we key on a constant to preserve progress across characters.
function R:getPlayerData(username)
    if Core.isLocal then username = 0 end
    if not self.data[username] then
        self.data[username] = {
            zombieKills = 0,
            sprinterKills = 0,
            claimed = {}
        }
    end
    local pd = self.data[username]
    if not pd.zombieKills then pd.zombieKills = 0 end
    if not pd.sprinterKills then pd.sprinterKills = 0 end
    if not pd.claimed then pd.claimed = {} end
    return pd
end

-- Check a kill milestone list against a current cumulative count.
-- Grants any unclaimed milestones whose threshold is met.
-- milestones: array of { kills=N, rewards={{item,amount},...} }
-- prefix: string used to key the claim record (e.g. "zombie" or "sprinter")
local function checkMilestones(player, pd, milestones, count, prefix)
    if not milestones then return end
    local username = player:getUsername()
    for _, entry in ipairs(milestones) do
        if entry.kills and count >= entry.kills then
            local key = prefix .. "_" .. tostring(entry.kills)
            if not pd.claimed[key] then
                pd.claimed[key] = true
                for _, reward in ipairs(entry.rewards or {}) do
                    Core:grantConfigReward(player, reward, "kill milestone: " .. entry.kills .. " " .. prefix .. "s")
                end
                Core.debugLn("[KillRewards] " .. username .. " claimed milestone " .. key)
            end
        elseif entry.everyKills and entry.everyKills > 0 then
            local key = prefix .. "_every_" .. tostring(entry.everyKills)
            local multiple = math.floor(count / entry.everyKills)
            if multiple > (pd.claimed[key] or 0) then
                local gained = multiple - (pd.claimed[key] or 0)
                pd.claimed[key] = multiple
                for _ = 1, gained do
                    for _, reward in ipairs(entry.rewards or {}) do
                        Core:grantConfigReward(player, reward, "every " .. entry.everyKills .. " " .. prefix .. "s")
                    end
                end
                Core.debugLn("[KillRewards] " .. username .. " claimed " .. gained .. "x recurring " .. key)
            end
        end
    end
end

-- Called by the server command handler when a client reports a batch of kills.
-- normal:   count of non-sprinter zombies killed this batch
-- sprinter: count of sprinter zombies killed this batch
function R:reportKills(player, normal, sprinter)
    if not self.loaded then return end
    if Core.getOption("EnableTokenPool") == false then return end
    local username = player:getUsername()
    local pd = self:getPlayerData(username)

    -- Accumulate
    if normal > 0 then
        pd.zombieKills = pd.zombieKills + normal
    end
    if sprinter > 0 then
        pd.sprinterKills = pd.sprinterKills + sprinter
    end

    -- Check milestones
    local cfg = Core.tokenRewardsCfg or {}
    if normal > 0 or sprinter > 0 then
        checkMilestones(player, pd, cfg.zombieKills,   pd.zombieKills,   "zombie")
        checkMilestones(player, pd, cfg.sprinterKills, pd.sprinterKills, "sprinter")
    end

    self:save()
end
