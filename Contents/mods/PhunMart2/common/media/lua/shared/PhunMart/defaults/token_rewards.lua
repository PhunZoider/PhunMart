-- PhunMart Token Rewards - Default Configuration
-- This file defines when players automatically earn tokens/rewards for:
--   playtime      - rewards for cumulative survived (game) time
--   zombieKills   - rewards for cumulative zombie kills
--   sprinterKills - rewards for cumulative sprinter kills
--
-- Each entry uses either:
--   atMinutes / kills  - one-time milestone (fires exactly once per wipe)
--   everyMinutes / everyKills - recurring (fires every N minutes/kills)
--
-- rewards entries: { item="FullItemName", amount=N }
--   item must be a valid inventory item full name (e.g. "PhunMart.Token")
--   Currency items (PhunMart.Token, PhunMart.Nickel, etc.) are credited directly
--   to the player wallet. All other items are spawned into inventory.
--
-- To override: place PhunMart_TokenRewards.json in your server Lua folder.
-- The override file is loaded in full (not merged), so copy and modify this file.
return {
    -- playtime: one-time milestone rewards at cumulative survived time thresholds.
    -- Minutes are GAME minutes (getHoursSurvived), summed across the player's
    -- characters in this save. At the default 1h day length, 1 game hour is
    -- 2.5 real minutes (1 real minute = 24 game minutes). Comments give the
    -- real-time equivalent. Each milestone fires exactly once per wipe.
    playtime = {{
        atMinutes = 120,
        rewards = {{
            item = "PhunMart.Token",
            amount = 1
        }}
    }, -- ~5 real minutes
    {
        atMinutes = 720,
        rewards = {{
            item = "PhunMart.Token",
            amount = 1
        }}
    }, -- ~30 real minutes
    {
        atMinutes = 2880,
        rewards = {{
            item = "PhunMart.Token",
            amount = 1
        }}
    }, -- ~2 real hours
    {
        atMinutes = 7200,
        rewards = {{
            item = "PhunMart.Token",
            amount = 1
        }}
    }, -- ~5 real hours
    {
        atMinutes = 17280,
        rewards = {{
            item = "PhunMart.Token",
            amount = 1
        }}
    }, -- ~12 real hours
    {
        atMinutes = 43200,
        rewards = {{
            item = "PhunMart.Token",
            amount = 1
        }}
    } -- ~30 real hours
    },

    -- zombieKills: one-time milestone rewards for cumulative zombie kills.
    -- "Normal" zombies only (sprinters tracked separately below).
    -- Milestones are only granted once per wipe (tracked in save file).
    zombieKills = {{
        kills = 100,
        rewards = {{
            item = "PhunMart.Token",
            amount = 1
        }}
    }, {
        kills = 500,
        rewards = {{
            item = "PhunMart.Token",
            amount = 2
        }}
    }, {
        kills = 1000,
        rewards = {{
            item = "PhunMart.Token",
            amount = 5
        }}
    }},

    -- sprinterKills: one-time milestone rewards for cumulative sprinter kills.
    -- Sprinter detection uses zombie:isSprinter() on the client side.
    -- Milestones are only granted once per wipe (tracked in save file).
    sprinterKills = {{
        kills = 50,
        rewards = {{
            item = "PhunMart.Token",
            amount = 1
        }}
    }, {
        kills = 200,
        rewards = {{
            item = "PhunMart.Token",
            amount = 3
        }}
    }}
}
