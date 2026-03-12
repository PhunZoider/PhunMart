-- PhunMart2 Token Rewards - Default Configuration
-- This file defines when players automatically earn tokens/rewards for:
--   playtime      - milestone rewards for cumulative online time (one-time each)
--   zombieKills   - cumulative zombie kill milestones (one-time, wipe-persistent)
--   sprinterKills - cumulative sprinter kill milestones (one-time, wipe-persistent)
--
-- rewards entries: { item="FullItemName", amount=N }
--   item must be a valid inventory item full name (e.g. "PhunMart.Token")
--   Currency items (PhunMart.Token, PhunMart.Nickel, etc.) are credited directly
--   to the player wallet. All other items are spawned into inventory.
--
-- To override: place PhunMart2_TokenRewards.lua in your server Lua folder.
-- The override file is loaded in full (not merged), so copy and modify this file.
return {
    -- playtime: one-time milestone rewards at cumulative online time thresholds.
    -- Each milestone fires exactly once per wipe.
    playtime = {{
        atMinutes = 10,
        rewards = {{
            item = "PhunMart.Token",
            amount = 1
        }}
    }, {
        atMinutes = 60,
        rewards = {{
            item = "PhunMart.Token",
            amount = 1
        }}
    }, {
        atMinutes = 300,
        rewards = {{
            item = "PhunMart.Token",
            amount = 2
        }}
    }, -- 5h
    {
        atMinutes = 600,
        rewards = {{
            item = "PhunMart.Token",
            amount = 3
        }}
    }, -- 10h
    {
        atMinutes = 900,
        rewards = {{
            item = "PhunMart.Token",
            amount = 5
        }}
    } -- 15h
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
