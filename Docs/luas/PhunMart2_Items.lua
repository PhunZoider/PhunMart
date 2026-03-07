return {

    bat_template = {
        template = true,
        enabled = true,
        offer = {
            qty = 1,
            weight = 1.0
        },
        conditions = {
            all = {"minHours"}
        }
    },
    ["Base.BaseballBat"] = {
        inherit = "bat_template",
        price = "low",
        reward = "bat",

        conditions = {
            all = {"minHours"}
        }
    },

    ["Base.BaseballBat_ScrapSheet"] = {
        price = "low10",
        offer = {
            qty = 1,
            weight = 0.5
        }
    },

    ["Base.BaseballBat_Nails"] = {
        enabled = true,
        mods = {
            require = {"Brita_2"}
        }, -- example

        inherit = "Base.BaseballBat",

        price = "low10",
        offer = {
            qty = 2,
            weight = 0.2,
            stock = {
                min = 0,
                max = 2,
                restockHours = 72
            }
        },

        conditions = {
            all = {"highBoost", "lowCarpentry", "max10Purchases"}
        }
    }
}
