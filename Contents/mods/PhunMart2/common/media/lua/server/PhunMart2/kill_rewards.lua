if isClient() then return end

require "PhunMart2/core"
local Core = PhunMart

Core.killRewards = {}
local R = Core.killRewards

local SAVE_FILE = "PhunMart2_KillTracking.lua"

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
    self.data = Core.tools.loadTable(SAVE_FILE) or {}
    self.loaded = true
end

function R:save()
    Core.tools.saveTable(SAVE_FILE, self.data)
end

-- Returns the persistent data record for a player, creating it if absent.
function R:getPlayerData(username)
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
    for _, entry in ipairs(milestones) do
        local threshold = entry.kills
        if threshold and count >= threshold then
            local key = prefix .. "_" .. tostring(threshold)
            if not pd.claimed[key] then
                pd.claimed[key] = true
                for _, reward in ipairs(entry.rewards or {}) do
                    Core:grantConfigReward(player, reward, "kill milestone: " .. count .. " " .. prefix .. "s")
                end
                Core.debugLn("[KillRewards] " .. player:getUsername() .. " claimed milestone " .. key)
            end
        end
    end
end

-- Called by the server command handler when a client reports a batch of kills.
-- normal:   count of non-sprinter zombies killed this batch
-- sprinter: count of sprinter zombies killed this batch
function R:reportKills(player, normal, sprinter)
    if not self.loaded then return end
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
