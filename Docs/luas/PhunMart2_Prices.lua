return {

    -- ── Free ─────────────────────────────────────────────────────────────────
    free = {
        kind = "free"
    },

    -- ── Silver coins ─────────────────────────────────────────────────────────
    coin_1 = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = 1
        }}
    },
    coin_5 = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = 5
        }}
    },
    coin_10 = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = 10
        }}
    },
    coin_15 = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = 15
        }}
    },
    coin_25 = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = 25
        }}
    },
    coin_40 = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = 40
        }}
    },
    coin_50 = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = 50
        }}
    },
    coin_75 = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = 75
        }}
    },
    coin_100 = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = 100
        }}
    },

    -- Range variants (for shops that feel more organic)
    coin_low = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = {
                min = 5,
                max = 15
            }
        }}
    },
    coin_mid = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = {
                min = 20,
                max = 40
            }
        }}
    },
    coin_high = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = {
                min = 50,
                max = 80
            }
        }}
    },
    coin_vhigh = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = {
                min = 80,
                max = 120
            }
        }}
    },

    -- ── Gold coins ───────────────────────────────────────────────────────────
    gold_1 = {
        kind = "items",
        items = {{
            item = "Base.Gold",
            amount = 1
        }}
    },
    gold_5 = {
        kind = "items",
        items = {{
            item = "Base.Gold",
            amount = 5
        }}
    },
    gold_10 = {
        kind = "items",
        items = {{
            item = "Base.Gold",
            amount = 10
        }}
    },
    gold_25 = {
        kind = "items",
        items = {{
            item = "Base.Gold",
            amount = 25
        }}
    },

    -- XP boosts (slightly more expensive than same-tier XP to reflect duration benefit)
    coin_boost = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = 20
        }}
    },

    -- ── Trait token (placeholder - replace item key when implemented) ─────────
    -- token_trait = { kind = "items", items = {{ item = "PhunMart.TraitToken", amount = 1 }} },

    -- ── Vehicle (separate kind, not items) ───────────────────────────────────
    -- Vehicles use gold coins as premium currency
    vehicle_common = {
        kind = "items",
        items = {{
            item = "Base.Gold",
            amount = {
                min = 5,
                max = 10
            }
        }}
    },
    vehicle_uncommon = {
        kind = "items",
        items = {{
            item = "Base.Gold",
            amount = {
                min = 10,
                max = 20
            }
        }}
    },
    vehicle_rare = {
        kind = "items",
        items = {{
            item = "Base.Gold",
            amount = {
                min = 20,
                max = 40
            }
        }}
    }

}
