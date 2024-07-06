return { --[[

    Base shops
    These are used for creating the actual shops used in the world

--]] {
    abstract = true,
    key = "base-shop",
    label = "Vending Machine",
    fills = {
        min = 6,
        max = 10
    },
    probability = 15,
    restock = 48,
    maxRestock = 1000,
    currency = "PhunMart.SilverDollar", -- the default currency for shops
    backgroundImage = "machine-none",
    minDistance = 100,
    spites = {"location_shop_accessories_01_17", "location_shop_accessories_01_16", "location_shop_accessories_01_28",
              "location_shop_accessories_01_29", "location_shop_accessories_01_19", "location_shop_accessories_01_18",
              "location_shop_accessories_01_31", "location_shop_accessories_01_30"}
}, {
    label = "Broken",
    broken = true,
    distance = 0,
    key = "broken-shop",
    inherits = "base-shop",

    pools = {
        items = {}
    },
    minDistance = 1,
    probability = 5,
    backgroundImage = "machine-broken"
}, {

    label = "Good Phoods",
    key = "shop-good-foods",
    inherits = "base-shop",
    type = "FOOD",
    minDistance = 10,
    pools = {
        items = {{
            filters = {
                tags = "foodfruit,fooddrink,foodbaking"
            }
        }, {
            filters = {
                tags = "foodfruit,fooddrink,foodcooking,foodready"
            }
        }, {
            filters = {
                tags = "foodutensil,foodmeat,foodseafood,fooddairy,foodcanned,foodbulk"
            }
        }}
    },
    backgroundImage = "machine-good-phoods"
}, {
    label = "Collectors",
    key = "shop-collectables",
    type = "COLLECTABLES",
    inherits = "base-shop",
    zones = {
        difficulty = 1
    },
    pools = {
        items = {{
            filters = {
                tags = "collectables1,scrap-silver"
            }
        }}
    },
    backgroundImage = "machine-collectors"
}, {
    label = "Collectors2",
    key = "shop-collectables2",
    inherits = "base-shop",
    type = "COLLECTABLES",
    fills = {
        min = 3,
        max = 7
    },
    zones = {
        difficulty = 2
    },
    pools = {
        items = {{
            filters = {
                tags = "collectables2,scrap-silver,scrap-gold"
            }
        }}
    },
    backgroundImage = "machine-collectors"
}, {
    label = "Collectors3",
    key = "shop-collectables3",
    inherits = "base-shop",
    type = "COLLECTABLES",
    fills = {
        min = 2,
        max = 4
    },
    zones = {
        difficulty = 3
    },
    pools = {
        items = {{
            filters = {
                tags = "collectables3,scrap-gold,scrap-gems"
            }
        }}
    },
    backgroundImage = "machine-collectors"
}, {
    label = "Collectors4",
    key = "shop-collectables4",
    inherits = "base-shop",
    type = "COLLECTABLES",
    fills = {
        min = 2,
        max = 4
    },
    zones = {
        difficulty = 4
    },
    pools = {
        items = {{
            filters = {
                tags = "collectables4,scrap-gold,scrap-gems"
            }
        }}
    },
    backgroundImage = "machine-collectors"
}, {
    key = "shop-phat-foods",
    inherits = "base-shop",
    type = "FOOD",
    minDistance = 10,
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
            basePrice = 4,
            filters = {
                tags = "foodpie,foodalcohol"
            }
        }}
    },
    backgroundImage = "machine-phat-phoods"
}, {

    key = "shop-tools",
    inherits = "base-shop",
    type = "TOOLS",
    backgroundImage = "machine-pity-the-tool",
    basePrice = 4,
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

    key = "shop-xp",
    label = "Budget Xperiences",
    inherits = "base-shop",
    backgroundImage = "machine-budget-xp",
    type = "XP",
    currency = "PhunMart.CheeseToken", -- change default currency to traiter tokens
    filters = {
        tags = "perks1,perks2"
    }
}, {

    key = "shop-xp2",
    inherits = "base-shop",
    label = "Gifted Xperiences",
    backgroundImage = "machine-gifted-xp",
    type = "XP",
    currency = "PhunMart.CheeseToken", -- change default currency to traiter tokens
    zones = {
        difficulty = 2
    },
    filters = {
        tags = "perks2,perks3,boosts1,boosts2"
    }
}, {

    key = "shop-xp3",
    inherits = "base-shop",
    label = "Luxury Xperiences",
    backgroundImage = "machine-luxury-xp",
    type = "XP",
    currency = "PhunMart.CheeseToken", -- change default currency to traiter tokens
    zones = {
        difficulty = {
            min = 3
        }
    },
    filters = {
        tags = "perks3,perks4,boosts3,boosts4"
    }
}, {

    key = "shop-traits",
    inherits = "base-shop",
    label = "TraiterJoe",
    type = "TRAITS",
    currency = "PhunMart.TraiterToken", -- change default currency to traiter tokens
    requiresPower = true,
    backgroundImage = "machine-traiter-joes",
    filters = {
        tags = "positive,negative"
    }
}, {

    key = "shop-vehicles",
    inherits = "base-shop",
    label = "Wrent a Wreck",
    type = "VEHICLES",
    currency = "PhunMart.CheeseToken", -- the default currency for shops
    basePrice = 10,
    requiresPower = true,
    backgroundImage = "machine-wrent-a-wreck",
    pools = {
        items = {{
            filters = {
                tags = "vehicle-car"
            }
        }, {
            basePrice = 10,
            filters = {
                tags = "vehicle-van"
            }
        }, {
            basePrice = 15,
            filters = {
                tags = "vehicle-truck,vehicle-other"
            }
        }}
    }
}, {

    key = "shop-vehicles2",
    inherits = "base-shop",
    label = "Wrent a Wreck2",
    type = "VEHICLES",
    currency = "PhunMart.CheeseToken", -- the default currency for shops
    requiresPower = true,
    backgroundImage = "machine-wrent-a-wreck",
    basePrice = 75,
    zones = {
        difficulty = {
            min = 3
        }
    },
    pools = {
        items = {{
            filters = {
                tags = "vehicle-special"
            }
        }}
    }
}, {

    key = "shop-carapart",
    inherits = "base-shop",
    label = "Car-A-Part",
    type = "CARPARTS",
    backgroundImage = "machine-car-a-part",
    basePrice = 25,
    filters = {
        tags = "autozone"
    }
}, {

    key = "shop-csv",
    inherits = "base-shop",
    label = "CSV",
    type = "MEDICAL",
    backgroundImage = "machine-csv",
    filters = {
        tags = "medical"
    }
}, {

    key = "shop-electronics",
    inherits = "base-shop",
    label = "Electronics",
    type = "ELECTRONICS",
    backgroundImage = "machine-electronics",
    filters = {
        tags = "electronics"
    }
}, {

    key = "shop-hoes",
    inherits = "base-shop",
    label = "Hoes",
    type = "GARDENING",
    backgroundImage = "machine-hoes",
    filters = {
        tags = "gardening"
    }
}, {

    key = "shop-crafts",
    inherits = "base-shop",
    label = "Michelles",
    type = "CRAFTS",
    backgroundImage = "machine-michelles",
    filters = {
        tags = "crafts,paint"
    }
}, {

    key = "shop-fish",
    inherits = "base-shop",
    label = "Fish",
    type = "FISH",
    backgroundImage = "machine-phish4u",
    pools = {
        items = {{
            filters = {
                tags = "fish,tackle"
            }
        }}
    }
}, {

    key = "shop-weapons",
    inherits = "base-shop",
    label = "Final Ammendment",
    type = "WEAPONS",
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
    key = "shop-weapons2",
    inherits = "base-shop",
    label = "Final Ammendment2",
    backgroundImage = "machine-final-ammendment",
    type = "WEAPONS",
    currency = "PhunMart.CheeseToken", -- the default currency for shops
    zones = {
        difficulty = {
            min = 2
        }
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
    key = "shop-weapons-3",
    inherits = "base-shop",
    label = "Final Ammendment3",
    currency = "PhunMart.CheeseToken", -- the default currency for shops
    type = "WEAPONS",
    backgroundImage = "machine-final-ammendment",
    zones = {
        difficulty = {
            min = 3
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
}}
