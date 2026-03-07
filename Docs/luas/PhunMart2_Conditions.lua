return {
    lowCarpentry = {
        test = "perkLevelBetween",
        args = {
            perk = "Woodwork",
            min = 1,
            max = 3
        }
    },

    max10Purchases = {
        test = "purchaseCountMax",
        args = {
            max = 10,
            scope = "player_item_shop"
        }
    },

    minHours = {
        test = "worldAgeHoursBetween",
        args = {
            min = 10,
            max = 20
        }
    },

    highBoost = {
        test = "perkBoostBetween",
        args = {
            perk = "Woodwork",
            min = 2,
            max = 3
        }
    },

    onlyCarpenters = {
        test = "professionIn",
        args = {
            professions = {"carpenter"}
        }
    },

    requiresItems = {
        test = "hasItems",
        args = {
            items = {{
                item = "Base.Nails",
                amount = 10
            }}
        }
    }
}
