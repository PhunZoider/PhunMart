return { --[[

    Base shops
    These are used for creating the actual shops used in the world

--]] {
    abstract = true,
    key = "base:shop",
    label = "Vending Machine",
    fills = {
        min = 6,
        max = 10
    },
    probability = 15,
    restock = 24,
    maxRestock = 2,
    currency = "Base.Money", -- the default currency for shops
    backgroundImage = "machine-none",
    minDistance = 100,
    spites = {"location_shop_accessories_01_17", "location_shop_accessories_01_16", "location_shop_accessories_01_28",
              "location_shop_accessories_01_29", "location_shop_accessories_01_19", "location_shop_accessories_01_18"}
}, {
    abstract = true,
    label = "Good Phoods",
    key = "base:food",
    inherits = "base:shop",
    pools = {
        items = {{
            rolls = 7,
            filters = {
                tags = "foodfruit,fooddrink,foodbaking"
            }
        }, {
            rolls = 6,
            filters = {
                tags = "foodfruit,fooddrink,foodcooking,foodready"
            }
        }, {
            rolls = 6,
            filters = {
                tags = "foodutensil,foodmeat,foodseafood,fooddairy,foodcanned,foodbulk"
            }
        }}
    },
    backgroundImage = "machine-good-phoods"
}, {
    abstract = true,
    key = "base:junk_food",
    inherits = "base:food",
    label = "Phat Phoods",
    pools = {
        items = {{
            filters = {
                tags = "foodjunk,foodbreads"
            }
        }, {
            filters = {
                tags = "foodready,foodcondiment"
            }
        }, {
            filters = {
                tags = "foodpie,foodalcohol"
            }
        }}
    },
    backgroundImage = "machine-phat-phoods"
}, {
    abstract = true,
    key = "base:tools",
    inherits = "base:shop",
    backgroundImage = "machine-pity-the-tool",
    pools = {
        items = {{
            filters = {
                tags = "toolwelding,toolmecanics"
            }
        }, {
            filters = {
                tags = "tools"
            }
        }, {
            filters = {
                tags = "toolcamping"
            }
        }}
    }
}, {
    abstract = true,
    key = "base:xp",
    label = "Budget Xperiences",
    inherits = "base:shop",
    backgroundImage = "machine-budget-xp",
    currency = "PhunMart.TraiterToken", -- change default currency to traiter tokens
    filters = {
        tags = "perks1,perks2"
    }
}, {
    abstract = true,
    key = "base:xp2",
    inherits = "base:xp",
    label = "Gifted Xperiences",
    backgroundImage = "machine-gifted-xp",
    zones = {
        difficulty = 2
    },
    filters = {
        tags = "perks2,perks3,boosts1,boosts2"
    }
}, {
    abstract = true,
    key = "base:xp3",
    inherits = "base:xp",
    label = "Luxury Xperiences",
    backgroundImage = "machine-luxury-xp",
    zones = {
        difficulty = 3
    },
    filters = {
        tags = "perks3,perks4,boosts3,boosts4"
    }
}, {
    abstract = true,
    key = "base:traits",
    inherits = "base:shop",
    label = "TraiterJoe",
    requiresPower = true,
    backgroundImage = "machine-traiter-joes",
    filters = {
        tags = "positive,negative"
    }
}, {
    abstract = true,
    key = "base:vehicles",
    inherits = "base:shop",
    label = "Wrent a Wreck",
    requiresPower = true,
    backgroundImage = "machine-wrent-a-wreck",
    pools = {
        items = {{
            filters = {
                tags = "vehicle-car"
            }
        }, {
            filters = {
                tags = "vehicle-van"
            }
        }, {
            filters = {
                tags = "vehicle-truck,vehicle-other"
            }
        }}
    }
}, {
    abstract = true,
    key = "base:carapart",
    inherits = "base:shop",
    label = "Car-A-Part",
    backgroundImage = "machine-car-a-part",
    filters = {
        tags = "autozone"
    }
}, {
    abstract = true,
    key = "base:csv",
    inherits = "base:shop",
    label = "CSV",
    backgroundImage = "machine-csv",
    filters = {
        tags = "medical"
    }
}, {
    abstract = true,
    key = "base:electronics",
    inherits = "base:shop",
    label = "Electronics",
    backgroundImage = "machine-electrics",
    filters = {
        tags = "electronics"
    }
}, {
    abstract = true,
    key = "base:hoes",
    inherits = "base:shop",
    label = "Hoes",
    backgroundImage = "machine-hoes",
    filters = {
        tags = "gardening"
    }
}, {
    abstract = true,
    key = "base:crafts",
    inherits = "base:shop",
    label = "Michelles",
    backgroundImage = "machine-michelles",
    filters = {
        tags = "crafts"
    }
}, {
    abstract = true,
    key = "base:fish",
    inherits = "base:shop",
    label = "Fish",
    backgroundImage = "machine-phish4u",
    filters = {
        tags = "fish"
    }
}, {
    abstract = true,
    key = "base:guns",
    inherits = "base:shop",
    label = "Final Ammendment",
    backgroundImage = "machine-final-ammendment",

    pools = {
        items = {{
            filters = {
                tags = "wepmelee"
            }
        }, {
            filters = {
                tags = "wepammo"
            }
        }, {
            filters = {
                tags = "wepmisc,wepcrafting"
            }
        }}
    }
}, {
    abstract = true,
    key = "base:guns2",
    inherits = "base:shop",
    label = "Final Ammendment3",
    backgroundImage = "machine-final-ammendment",
    zones = {
        difficulty = 2
    },
    pools = {
        items = {{
            filters = {
                tags = "wepammo,weppistol"
            }
        }, {
            filters = {
                tags = "wepmisc,wepcrafting"
            }
        }}
    }
}, {
    abstract = true,
    key = "base:guns3",
    inherits = "base:shop",
    label = "Final Ammendment3",
    backgroundImage = "machine-final-ammendment",
    zones = {
        difficulty = {
            min = 3,
            max = 4
        }
    },
    pools = {
        items = {{
            filters = {
                tags = "weprifle,wepbulkammo"
            }
        }, {
            filters = {
                tags = "wepshotgun,wepexplosive"
            }
        }}
    }
}, --[[

    Actual shops

--]] {
    key = "SHOP:FOOD:phat_phoods",
    inherits = "base:junk_food"

}, {
    key = "SHOP:FOOD:good_phoods",
    inherits = "base:food"
}, {
    key = "SHOP:FOOD:phat_foods_alcohol",
    inherits = "base:junk_food",
    filters = {
        tags = "foodalcohol"
    }
}, {
    key = "SHOP:TOOLS:pitty_the_tool",
    inherits = "base:tools"
}, {
    key = "SHOP:XP:great_xperiences",
    inherits = "base:xp"
}, {
    key = "SHOP:XP:great_xperiences_2",
    inherits = "base:xp2"
}, {
    key = "SHOP:TRAITS:traiter_joes",
    inherits = "base:traits"
}, {
    key = "SHOP:CARS:wrent_a_wreck",
    inherits = "base:vehicles"
}, {
    key = "SHOP:WEAPONS:final_ammendment",
    inherits = "base:guns",
    requiresPower = true
}}
