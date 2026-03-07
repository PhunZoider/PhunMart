return {
    bats_base = {
        defaults = {
            price = "low",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"Weapons"}
        }
    },
    bats_rare = {
        inherit = "bats_base",
        defaults = {
            offer = {
                weight = 0.2
            }
        },
        blacklist = {"Base.BaseballBat_ScrapSheet"}
    },
    bats = {
        priority = 50, -- higher wins if item appears in multiple groups in same pool

        defaults = {
            price = "low",
            offer = {
                weight = 1.0
            },
            conditions = {
                all = {"minHours"}
            }
        },

        include = {
            items = {"Base.BaseballBat", "Base.BaseballBat_ScrapSheet", "Base.BaseballBat_Nails"},

            -- optional “discovery” from item meta (you’ll implement matching)
            categories = {"Weapons"},
            tags = {"Bat"} -- if you decide to support tags
        },

        blacklist = {
            -- "Base.AluminumBat"
        }
    }
}
