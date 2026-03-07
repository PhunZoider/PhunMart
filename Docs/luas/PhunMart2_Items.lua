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

    book_level1 = {
        price = "very_low",
        offer = {
            qty = 1,
            weight = 0.5
        }
    },
    book_level2 = {
        price = "low",
        offer = {
            qty = 1,
            weight = 0.5
        }
    },
    book_level3 = {
        price = "med",
        offer = {
            qty = 1,
            weight = 0.5
        }
    },
    book_level4 = {
        price = "high",
        offer = {
            qty = 1,
            weight = 0.5
        }
    },
    book_level5 = {
        price = "med_gold",
        offer = {
            qty = 1,
            weight = 0.5
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
    },

    ["Base.BookCooking1"] = {
        inherit = "book_level1"
    },
    ["Base.BookCooking2"] = {
        inherit = "book_level2"
    },
    ["Base.BookCooking3"] = {
        inherit = "book_level3"
    },
    ["Base.BookCooking4"] = {
        inherit = "book_level4"
    },
    ["Base.BookCooking5"] = {
        inherit = "book_level5"
    },
    ["Base.BookFishing1"] = {
        inherit = "book_level1"
    },
    ["Base.BookFishing2"] = {
        inherit = "book_level2"
    },
    ["Base.BookFishing3"] = {
        inherit = "book_level3"
    },
    ["Base.BookFishing4"] = {
        inherit = "book_level4"
    },
    ["Base.BookFishing5"] = {
        inherit = "book_level5"
    }

}
