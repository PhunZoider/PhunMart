-- PhunMart2_TokenRewards.lua
-- Server override for the periodic token reward system.
--
-- Place this file in your server's Zomboid/Lua/ folder to customise rewards.
-- If this file is absent, the built-in defaults from
--   PhunMart2/defaults/token_rewards.lua
-- are used instead.
--
-- This file is loaded in full (not merged with defaults), so copy and modify
-- it to change any section.
--
-- ============================================================
-- SECTION: playtime
-- ============================================================
-- One-time milestone rewards at cumulative real-world online time thresholds.
-- atMinutes is total minutes played (persists across restarts/disconnects).
-- Each milestone fires exactly once per wipe - not a repeating odometer.
-- Spacing the milestones gives them an achievement feel (10m welcome,
-- 1h committed, 5h regular, 10h dedicated, 15h hardcore).
--
-- ============================================================
-- SECTION: zombieKills / sprinterKills
-- ============================================================
-- One-time milestone rewards for cumulative kills (since last wipe).
-- Each milestone is only granted once per player per wipe.
-- Kill counts are reported by the client in 30-second batches (honour system).
-- Sprinter kills are detected via zombie:isSprinter() on the client.
--
-- ============================================================
-- rewards format
-- ============================================================
-- Each reward entry: { item = "FullItemName", amount = N }
--   - PhunMart currency items (Nickel, Dime, Quarter, Token) are credited
--     directly to the player wallet. Token is bound (account wallet).
--   - Any other item full name is spawned directly into player inventory.
--
-- ============================================================

return {
    -- Playtime milestones (one-time each, atMinutes = cumulative real-world minutes online)
    playtime = {
        { atMinutes = 10,  rewards = { { item = "PhunMart.Token", amount = 1 } } },  -- welcome
        { atMinutes = 60,  rewards = { { item = "PhunMart.Token", amount = 1 } } },  -- first hour
        { atMinutes = 300, rewards = { { item = "PhunMart.Token", amount = 2 } } },  -- 5h
        { atMinutes = 600, rewards = { { item = "PhunMart.Token", amount = 3 } } },  -- 10h
        { atMinutes = 900, rewards = { { item = "PhunMart.Token", amount = 5 } } },  -- 15h
        -- Can mix in other items at milestones too:
        -- { atMinutes = 1200, rewards = { { item = "PhunMart.Token", amount = 5 }, { item = "Base.Katana", amount = 1 } } },
    },

    -- Normal zombie kill milestones (cumulative, one-time each)
    zombieKills = {
        { kills = 100,  rewards = { { item = "PhunMart.Token", amount = 1 } } },
        { kills = 500,  rewards = { { item = "PhunMart.Token", amount = 2 } } },
        { kills = 1000, rewards = { { item = "PhunMart.Token", amount = 5 } } },
        -- Additional milestones can be added freely:
        -- { kills = 5000, rewards = { { item = "PhunMart.Token", amount = 10 } } },
    },

    -- Sprinter kill milestones (cumulative, one-time each)
    sprinterKills = {
        { kills = 50,  rewards = { { item = "PhunMart.Token", amount = 1 } } },
        { kills = 200, rewards = { { item = "PhunMart.Token", amount = 3 } } },
        -- { kills = 500, rewards = { { item = "PhunMart.Token", amount = 5 } } },
    },
}
