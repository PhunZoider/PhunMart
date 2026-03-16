-- PhunMart Prices
-- Defines named price configs referenced by pools and offers.
--
-- kind = "free"                              no cost
-- kind = "currency", pool, amount            deducted from the player's wallet pool
-- kind = "items", item = "Base.X"            physical item consumed (shorthand for single item)
-- kind = "items", items = {{item, amount}}   physical items consumed (multi-item barter)
-- kind = "self", amount                      player hands over N of the offer item
--
-- pool "change"  = loose coin balance (stored in cents: 25 = $0.25)
-- pool "tokens"  = special bound tokens (integer count)
--
-- factor (optional, default 1):
--   Multiplies all amounts in the resolved price entry. Defined on a base entry
--   and inherited by children via `inherit`. Useful as a global economy scaling
--   knob (e.g. factor=2 doubles all prices) or when switching currency kind
--   (e.g. override currency_base to kind="items" with Base.Money).
--   Factor on a child replaces the parent's factor (no compounding).
--   Amounts are ceil'd after scaling; minimum 1.
return {

    -- ── Free ─────────────────────────────────────────────────────────────────
    free = {
        kind = "free"
    },

    -- ── Currency (cents) ────────────────────────────────────────────────────
    -- Base entry for all currency prices. Override this to switch currency kind
    -- or scale the entire economy (e.g. factor=0.5 halves all prices).
    currency_base = {
        kind = "currency",
        pool = "change",
        amount = 1,
        factor = 1
    },

    currency_05  = { inherit = "currency_base", amount = 5   }, -- $0.05  (one nickel)
    currency_10  = { inherit = "currency_base", amount = 10  }, -- $0.10  (one dime)
    currency_25  = { inherit = "currency_base", amount = 25  }, -- $0.25  (one quarter)
    currency_50  = { inherit = "currency_base", amount = 50  }, -- $0.50
    currency_75  = { inherit = "currency_base", amount = 75  }, -- $0.75
    currency_100 = { inherit = "currency_base", amount = 100 }, -- $1.00
    currency_150 = { inherit = "currency_base", amount = 150 }, -- $1.50
    currency_200 = { inherit = "currency_base", amount = 200 }, -- $2.00
    currency_250 = { inherit = "currency_base", amount = 250 }, -- $2.50
    currency_500 = { inherit = "currency_base", amount = 500 }, -- $5.00

    -- ── Tokens ───────────────────────────────────────────────────────────────
    -- Base entry for all token prices. Override to scale token economy.
    token_base = {
        kind = "currency",
        pool = "tokens",
        amount = 1,
        factor = 1
    },

    token_1  = { inherit = "token_base", amount = 1  },
    token_2  = { inherit = "token_base", amount = 2  },
    token_3  = { inherit = "token_base", amount = 3  },
    token_5  = { inherit = "token_base", amount = 5  },
    token_6  = { inherit = "token_base", amount = 6  },
    token_9  = { inherit = "token_base", amount = 9  },
    token_12 = { inherit = "token_base", amount = 12 },
    token_15 = { inherit = "token_base", amount = 15 },
    token_18 = { inherit = "token_base", amount = 18 },
    token_24 = { inherit = "token_base", amount = 24 },
    token_30 = { inherit = "token_base", amount = 30 },

    tokens      = { inherit = "token_base", amount = 2 },
    tokens_mid  = { inherit = "token_base", amount = 4 },
    tokens_high = { inherit = "token_base", amount = 8 },

    -- ── Named tiers (used by pool defaults) ──────────────────────────────────
    currency_boost    = { inherit = "currency_base", amount = 200 },  -- $2.00  (basic boost, budget shop)
    currency_boost_t2 = { inherit = "currency_base", amount = 350 },  -- $3.50  (enhanced boost, gifted shop)
    currency_boost_t3 = { inherit = "currency_base", amount = 500 },  -- $5.00  (superior boost, luxury shop)

    currency_xlow = { inherit = "currency_base", amount = { min = 50,   max = 150  } }, -- $0.50-$1.50
    currency_low  = { inherit = "currency_base", amount = { min = 250,  max = 600  } }, -- $2.50-$6.00
    currency_mid  = { inherit = "currency_base", amount = { min = 1000, max = 1200 } }, -- $10.00-$12.00
    currency_high = { inherit = "currency_base", amount = { min = 3000, max = 6000 } }, -- $30.00-$60.00

    -- ── Collector self-pay ────────────────────────────────────────────────────
    -- "self" means the player hands over N of the displayed offer item.
    self_base = {
        kind = "self",
        amount = 1,
        factor = 1
    },

    self_1  = { inherit = "self_base", amount = 1  },
    self_2  = { inherit = "self_base", amount = 2  },
    self_3  = { inherit = "self_base", amount = 3  },
    self_5  = { inherit = "self_base", amount = 5  },
    self_10 = { inherit = "self_base", amount = 10 },

    -- ── Vehicles ────────────────────────────────────────────────────────────
    -- WrentAWreck and similar shops. Inherits from currency_base so the global
    -- currency factor applies here too.
    vehicle_common   = { inherit = "currency_base", amount = { min = 1000, max = 2000 } },
    vehicle_uncommon = { inherit = "currency_base", amount = { min = 2000, max = 4000 } },
    vehicle_rare     = { inherit = "currency_base", amount = { min = 4000, max = 8000 } },

    -- ── Physical items ───────────────────────────────────────────────────────
    -- Use for barter-style shops or recipes that require inventory items.
    -- (Uncomment and adapt as needed)

    -- bandage_1 = {
    --     kind  = "items",
    --     items = {{ item = "Base.Bandage", amount = 1 }}
    -- },

}
