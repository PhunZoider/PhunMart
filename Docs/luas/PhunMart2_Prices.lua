return {
    low10 = {
        kind = "items", -- future-proof: "items" | "vehicle" | "trait" | etc
        items = {{
            item = "Base.Silver",
            amount = 10
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
