-- PhunMart2 Prices
-- Defines named price configs referenced by pools and offers.
--
-- kind = "free"                              no cost
-- kind = "currency", pool, amount            deducted from the player's wallet pool
-- kind = "items", items = {{item, amount}}   physical items consumed from inventory
--
-- pool "change"  = loose coin balance (stored in cents: 25 = $0.25)
-- pool "tokens"  = special bound tokens (integer count)
return {

    -- ── Free ─────────────────────────────────────────────────────────────────
    free = {
        kind = "free"
    },

    -- ── Change (cents) ───────────────────────────────────────────────────────
    -- Typical vending machine prices. Remember: 1 nickel = 5¢, 1 dime = 10¢, 1 quarter = 25¢.

    change_05 = {
        kind = "currency",
        pool = "change",
        amount = 5 -- $0.05  (one nickel)
    },
    change_10 = {
        kind = "currency",
        pool = "change",
        amount = 10 -- $0.10  (one dime)
    },
    change_25 = {
        kind = "currency",
        pool = "change",
        amount = 25 -- $0.25  (one quarter)
    },
    change_50 = {
        kind = "currency",
        pool = "change",
        amount = 50 -- $0.50
    },
    change_75 = {
        kind = "currency",
        pool = "change",
        amount = 75 -- $0.75
    },
    change_100 = {
        kind = "currency",
        pool = "change",
        amount = 100 -- $1.00
    },
    change_150 = {
        kind = "currency",
        pool = "change",
        amount = 150 -- $1.50
    },
    change_200 = {
        kind = "currency",
        pool = "change",
        amount = 200 -- $2.00
    },
    change_250 = {
        kind = "currency",
        pool = "change",
        amount = 250 -- $2.50
    },
    change_500 = {
        kind = "currency",
        pool = "change",
        amount = 500 -- $5.00
    },

    -- ── Tokens ───────────────────────────────────────────────────────────────
    -- Special bound tokens. Used for premium shops (traits, vehicles, etc.)

    token_1 = {
        kind = "currency",
        pool = "tokens",
        amount = 1
    },
    token_2 = {
        kind = "currency",
        pool = "tokens",
        amount = 2
    },
    token_3 = {
        kind = "currency",
        pool = "tokens",
        amount = 3
    },
    token_5 = {
        kind = "currency",
        pool = "tokens",
        amount = 5
    },
    token_6 = {
        kind = "currency",
        pool = "tokens",
        amount = 6
    },
    token_9 = {
        kind = "currency",
        pool = "tokens",
        amount = 9
    },
    token_12 = {
        kind = "currency",
        pool = "tokens",
        amount = 12
    },
    token_15 = {
        kind = "currency",
        pool = "tokens",
        amount = 15
    },
    token_18 = {
        kind = "currency",
        pool = "tokens",
        amount = 18
    },
    token_24 = {
        kind = "currency",
        pool = "tokens",
        amount = 24
    },
    token_30 = {
        kind = "currency",
        pool = "tokens",
        amount = 30
    },

    tokens = {
        kind = "currency",
        pool = "tokens",
        amount = 2
    },

    tokens_mid = {
        kind = "currency",
        pool = "tokens",
        amount = 4
    },

    tokens_high = {
        kind = "currency",
        pool = "tokens",
        amount = 8
    },

    -- ── Named tiers (used by pool defaults) ──────────────────────────────────

    coin_5 = {
        kind = "currency",
        pool = "change",
        amount = 5 -- $0.05
    },
    coin_10 = {
        kind = "currency",
        pool = "change",
        amount = 10 -- $0.10
    },
    coin_25 = {
        kind = "currency",
        pool = "change",
        amount = 25 -- $0.25
    },
    coin_40 = {
        kind = "currency",
        pool = "change",
        amount = 40 -- $0.40
    },
    coin_50 = {
        kind = "currency",
        pool = "change",
        amount = 50 -- $0.50
    },
    coin_75 = {
        kind = "currency",
        pool = "change",
        amount = 75 -- $0.75
    },
    coin_boost = {
        kind = "currency",
        pool = "change",
        amount = 200 -- $2.00  (basic boost, budget shop)
    },
    coin_boost_t2 = {
        kind = "currency",
        pool = "change",
        amount = 350 -- $3.50  (enhanced boost, gifted shop)
    },
    coin_boost_t3 = {
        kind = "currency",
        pool = "change",
        amount = 500 -- $5.00  (superior boost, luxury shop)
    },
    coin_low = {
        kind = "currency",
        pool = "change",
        amount = {
            min = 250,
            max = 600
        } -- $5.00
    },
    coin_mid = {
        kind = "currency",
        pool = "change",
        amount = {
            min = 1000,
            max = 1200
        } -- $10.00
    },
    coin_high = {
        kind = "currency",
        pool = "change",
        amount = {
            min = 3000,
            max = 6000
        } -- $50.00
    },

    -- ── Collector self-pay ────────────────────────────────────────────────────
    -- Used by collector pools. "self" means the player hands over N of the
    -- displayed offer item; no coins or tokens are deducted.

    self_1 = {
        kind = "self",
        amount = 1
    },
    self_3 = {
        kind = "self",
        amount = 3
    },
    self_5 = {
        kind = "self",
        amount = 5
    },
    self_10 = {
        kind = "self",
        amount = 10
    },

    -- ── Vehicles (tokens) ────────────────────────────────────────────────────
    -- WrentAWreck and similar shops use token-based pricing for vehicles.

    vehicle_common = {
        kind = "currency",
        pool = "change",
        amount = {
            min = 1000,
            max = 2000
        }
    },
    vehicle_uncommon = {
        kind = "currency",
        pool = "change",
        amount = {
            min = 2000,
            max = 4000
        }
    },
    vehicle_rare = {
        kind = "currency",
        pool = "change",
        amount = {
            min = 4000,
            max = 8000
        }
    }

    -- ── Physical items ───────────────────────────────────────────────────────
    -- Use for barter-style shops or recipes that require inventory items.
    -- (Uncomment and adapt as needed)

    -- bandage_1 = {
    --     kind  = "items",
    --     items = {{ item = "Base.Bandage", amount = 1 }}
    -- },

}
