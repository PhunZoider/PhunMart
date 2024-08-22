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
    minDistance = 500,
    spites = {"location_shop_accessories_01_17", "location_shop_accessories_01_16", "location_shop_accessories_01_28",
              "location_shop_accessories_01_29", "location_shop_accessories_01_19", "location_shop_accessories_01_18",
              "location_shop_accessories_01_31", "location_shop_accessories_01_30"}
}, {
    label = "Good Phoods",
    key = "shop-good-foods",
    inherits = "base-shop",
    type = "FOOD",
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
    backgroundImage = "machine-good-phoods",
    sprites = {
        sheet = 1,
        row = 2,
        east = "phunmart_01_0",
        south = "phunmart_01_1"
    }
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
    backgroundImage = "machine-collectors",
    sprites = {
        sheet = 3,
        row = 2,
        east = "phunmart_01_2",
        south = "phunmart_01_3"
    }
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
    backgroundImage = "machine-collectors",
    sprites = {
        sheet = 3,
        row = 2,
        east = "phunmart_01_2",
        south = "phunmart_01_3"
    }
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
    backgroundImage = "machine-collectors",
    sprites = {
        sheet = 3,
        row = 2,
        east = "phunmart_01_2",
        south = "phunmart_01_3"
    }
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
    backgroundImage = "machine-collectors",
    sprites = {
        sheet = 3,
        row = 2,
        east = "phunmart_01_2",
        south = "phunmart_01_3"
    }
}, {
    key = "shop-phat-foods",
    inherits = "base-shop",
    generate = false,
    type = "FOOD",
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
    backgroundImage = "machine-phat-phoods",
    sprites = {
        sheet = 1,
        row = 3,
        east = "phunmart_01_22",
        south = "phunmart_01_23"
    }
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
    },
    sprites = {
        sheet = 1,
        row = 4,
        east = "phunmart_01_6",
        south = "phunmart_01_7"
    }
}, {

    key = "shop-books",
    inherits = "base-shop",
    type = "BOOKS",
    backgroundImage = "machine-sheds-and-commoners",
    basePrice = 45,
    pools = {
        items = {{
            filters = {
                tags = "literature,litmisc"
            }
        }, {
            filters = {
                tags = "literature,magazine"
            }
        }, {
            filters = {
                tags = "literature,book"
            }
        }}
    },
    sprites = {
        sheet = 3,
        row = 4,
        east = "phunmart_01_6",
        south = "phunmart_01_7"
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
    },
    sprites = {
        sheet = 2,
        row = 6,
        east = "phunmart_01_32",
        south = "phunmart_01_33"
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
    },
    sprites = {
        sheet = 2,
        row = 7,
        east = "phunmart_01_28",
        south = "phunmart_01_29"
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
    },
    sprites = {
        sheet = 2,
        row = 8,
        east = "phunmart_01_27",
        south = "phunmart_01_28"
    }
}, {

    key = "shop-traits",
    inherits = "base-shop",
    label = "TraiterJoe",
    type = "TRAITS",
    minDistance = 5000,
    currency = "PhunMart.TraiterToken", -- change default currency to traiter tokens
    requiresPower = true,
    backgroundImage = "machine-traiter-joes",
    filters = {
        tags = "positive,negative"
    },
    sprites = {
        sheet = 2,
        row = 1,
        east = "phunmart_01_14",
        south = "phunmart_01_15"
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
    },
    sprites = {
        sheet = 1,
        row = 6,
        east = "phunmart_01_10",
        south = "phunmart_01_11"
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
    },
    sprites = {
        sheet = 1,
        row = 6,
        east = "phunmart_01_10",
        south = "phunmart_01_11"
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
    },
    sprites = {
        sheet = 1,
        row = 8,
        east = "phunmart_01_12",
        south = "phunmart_01_13"
    }
}, {

    key = "shop-csv",
    inherits = "base-shop",
    label = "CSV",
    type = "MEDICAL",
    backgroundImage = "machine-csv",
    filters = {
        tags = "medical"
    },
    sprites = {
        sheet = 2,
        row = 2,
        east = "phunmart_01_16",
        south = "phunmart_01_17"
    }
}, {

    key = "shop-electronics",
    inherits = "base-shop",
    label = "Electronics",
    type = "ELECTRONICS",
    backgroundImage = "machine-electronics",
    filters = {
        tags = "electronics"
    },
    sprites = {
        sheet = 2,
        row = 3,
        east = "phunmart_01_18",
        south = "phunmart_01_19"
    }
}, {

    key = "shop-hoes",
    inherits = "base-shop",
    label = "Hoes",
    type = "GARDENING",
    backgroundImage = "machine-hoes",
    filters = {
        tags = "gardening"
    },
    sprites = {
        sheet = 2,
        row = 5,
        east = "phunmart_01_24",
        south = "phunmart_01_25"
    }
}, {

    key = "shop-crafts",
    inherits = "base-shop",
    label = "Michelles",
    type = "CRAFTS",
    backgroundImage = "machine-michelles",
    filters = {
        tags = "crafts,paint"
    },
    sprites = {
        sheet = 1,
        row = 7,
        east = "phunmart_01_30",
        south = "phunmart_01_31"
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
    },
    sprites = {
        sheet = 2,
        row = 4,
        east = "phunmart_01_20",
        south = "phunmart_01_21"
    }
}, {

    key = "shop-weapons",
    inherits = "base-shop",
    label = "Final Ammendment",
    type = "WEAPONS",
    backgroundImage = "machine-final-ammendment",
    currency = "PhunMart.CheeseToken", -- the default currency for shops
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
    },
    sprites = {
        sheet = 1,
        row = 5,
        east = "phunmart_01_8",
        south = "phunmart_01_9"
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
    },
    sprites = {
        sheet = 1,
        row = 5,
        east = "phunmart_01_8",
        south = "phunmart_01_9"
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
    },
    sprites = {
        sheet = 1,
        row = 5,
        east = "phunmart_01_8",
        south = "phunmart_01_9"
    }
}}
