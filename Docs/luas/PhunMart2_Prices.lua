return {
    low10 = {
        kind = "items", -- future-proof: "items" | "vehicle" | "trait" | etc
        items = {{
            item = "Base.Silver",
            amount = 10
        }}
    },

    very_low = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = {
                min = 2,
                max = 5
            }
        }}
    },

    low = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = {
                min = 8,
                max = 12
            }
        }}
    },

    med = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = {
                min = 10,
                max = 22
            }
        }}
    },

    high = {
        kind = "items",
        items = {{
            item = "Base.Silver",
            amount = {
                min = 20,
                max = 50
            }
        }}
    },

    low_gold = {
        kind = "items",
        items = {{
            item = "Base.Gold",
            amount = {
                min = 1,
                max = 10
            }
        }}
    },

    med_gold = {
        kind = "items",
        items = {{
            item = "Base.Gold",
            amount = {
                min = 9,
                max = 25
            }
        }}
    },

    bear = {
        kind = "items",
        items = {{
            item = {"Base.ToyBear", "Base.ToyBear_Crafted_Cotton"}
        } -- defaults to 1
        }
    },

    trade_bat_for_nails = {
        kind = "items",
        items = {{
            item = "Base.BaseballBat",
            amount = 1
        }, {
            item = "Base.Nails",
            amount = 50
        }}
    }
}
