return {

    GoodPhoods = {
        probability = 15,
        category = "Food",
        background = "machine-good-phoods.png",
        sprites = {"phunmart_01_8", "phunmart_01_9", "phunmart_01_10", "phunmart_01_11"},
        unpoweredSprites = {"phunmart_01_12", "phunmart_01_13", "phunmart_01_14", "phunmart_01_15"},
        roll = { mode = "weighted", count = { min = 6, max = 9 } },
        poolSets = {{
            price = "currency_low",
            keys = {{
                key = "pool_goodphoods",
                weight = 1.0
            }}
        }, {
            price = "currency_low",
            keys = {{
                key = "pool_phatphoods",
                weight = 1.0
            }}
        }}
    },

    PittyTheTool = {
        probability = 15,
        category = "Tool",
        background = "machine-pity-the-tool.png",
        sprites = {"phunmart_01_24", "phunmart_01_25", "phunmart_01_26", "phunmart_01_27"},
        unpoweredSprites = {"phunmart_01_28", "phunmart_01_29", "phunmart_01_30", "phunmart_01_31"},
        roll = { mode = "weighted", count = { min = 5, max = 8 } },
        poolSets = {{
            price = "currency_mid",
            keys = {{
                key = "pool_pittythetool",
                weight = 1.0
            }}
        }}
    },

    FinalAmendment = {
        probability = 8,
        minDistance = 400,
        category = "Weapon",
        background = "machine-final-amendment.png",
        sprites = {"phunmart_01_32", "phunmart_01_33", "phunmart_01_34", "phunmart_01_35"},
        unpoweredSprites = {"phunmart_01_36", "phunmart_01_37", "phunmart_01_38", "phunmart_01_39"},
        poolSets = {{
            price = "currency_mid",
            roll = { mode = "weighted", count = { min = 2, max = 3 } },
            keys = {{
                key = "pool_finalamendment_melee",
                weight = 1.0
            }}
        }, {
            price = "currency_low",
            roll = { mode = "weighted", count = { min = 4, max = 7 } },
            keys = {{
                key = "pool_finalamendment_ammo",
                weight = 1.0
            }}
        }, {
            price = "currency_high",
            roll = { mode = "weighted", count = { min = 3, max = 5 } },
            keys = {{
                key = "pool_finalamendment_guns",
                weight = 1.0
            }}
        }, {
            price = "currency_high",
            roll = { mode = "weighted", count = { min = 1, max = 3 } },
            keys = {{
                key = "pool_finalamendment_explosives",
                weight = 1.0
            }}
        }}
    },

    WrentAWreck = {
        probability = 5,
        minDistance = 500,
        category = "Vehicle",
        defaultView = "list",
        restockFrequency = 168, -- weekly car delivery
        background = "machine-wrent-a-wreck.png",
        sprites = {"phunmart_01_40", "phunmart_01_41", "phunmart_01_42", "phunmart_01_43"},
        unpoweredSprites = {"phunmart_01_44", "phunmart_01_45", "phunmart_01_46", "phunmart_01_47"},
        roll = { mode = "weighted", count = { min = 5, max = 8 } },
        poolSets = {{
            keys = {{
                key = "pool_vehicles_budget",
                weight = 1.0
            }}
        }, {
            keys = {{
                key = "pool_vehicles_standard",
                weight = 1.0
            }}
        }, {
            keys = {{
                key = "pool_vehicles_premium",
                weight = 1.0
            }}
        }}
    },

    MichellesCrafts = {
        probability = 15,
        category = "Crafts",
        background = "machine-michelles.png",
        sprites = {"phunmart_01_48", "phunmart_01_49", "phunmart_01_50", "phunmart_01_51"},
        unpoweredSprites = {"phunmart_01_52", "phunmart_01_53", "phunmart_01_54", "phunmart_01_55"},
        roll = { mode = "weighted", count = { min = 5, max = 8 } },
        poolSets = {{
            price = "currency_low",
            keys = {{
                key = "pool_michellescrafts",
                weight = 1.0
            }}
        }}
    },

    CarAParts = {
        probability = 15,
        category = "Vehicle",
        background = "machine-car-a-part.png",
        sprites = {"phunmart_01_56", "phunmart_01_57", "phunmart_01_58", "phunmart_01_59"},
        unpoweredSprites = {"phunmart_01_60", "phunmart_01_61", "phunmart_01_62", "phunmart_01_63"},
        roll = { mode = "weighted", count = { min = 5, max = 8 } },
        poolSets = {{
            price = "currency_mid",
            keys = {{
                key = "pool_caraparts",
                weight = 1.0
            }}
        }}
    },

    TraiterJoes = {
        probability = 5,
        minDistance = 500,
        category = "Trait",
        background = "machine-traiter-joes.png",
        sprites = {"phunmart_02_0", "phunmart_02_1", "phunmart_02_2", "phunmart_02_3"},
        unpoweredSprites = {"phunmart_02_4", "phunmart_02_5", "phunmart_02_6", "phunmart_02_7"},
        poolSets = {{
            price = "tokens_mid",
            roll = { mode = "weighted", count = { min = 3, max = 6 } },
            keys = {{
                key = "pool_traiter_good",
                weight = 1.0
            }}
        }, {
            price = "tokens_mid",
            roll = { mode = "weighted", count = { min = 3, max = 5 } },
            keys = {{
                key = "pool_traiter_bad_removal",
                weight = 1.0
            }}
        }}
    },

    CSVPharmacy = {
        probability = 15,
        category = "Medical",
        background = "machine-csv.png",
        sprites = {"phunmart_02_8", "phunmart_02_9", "phunmart_02_10", "phunmart_02_11"},
        unpoweredSprites = {"phunmart_02_12", "phunmart_02_13", "phunmart_02_14", "phunmart_02_15"},
        poolSets = {{
            roll = { mode = "weighted", count = { min = 4, max = 7 } },
            keys = {{
                key = "pool_csvpharmacy_basic",
                weight = 1.0
            }}
        }, {
            roll = { mode = "weighted", count = { min = 1, max = 3 } },
            keys = {{
                key = "pool_csvpharmacy_rare",
                weight = 1.0
            }}
        }}
    },

    RadioHacks = {
        probability = 15,
        category = "Electronics",
        background = "machine-electronics.png",
        sprites = {"phunmart_02_16", "phunmart_02_17", "phunmart_02_18", "phunmart_02_19"},
        unpoweredSprites = {"phunmart_02_20", "phunmart_02_21", "phunmart_02_22", "phunmart_02_23"},
        roll = { mode = "weighted", count = { min = 5, max = 8 } },
        poolSets = {{
            price = "currency_mid",
            keys = {{
                key = "pool_radiohacks",
                weight = 1.0
            }}
        }}
    },

    Phish4U = {
        probability = 15,
        category = "Fishing",
        background = "machine-phish4u.png",
        sprites = {"phunmart_02_24", "phunmart_02_25", "phunmart_02_26", "phunmart_02_27"},
        unpoweredSprites = {"phunmart_02_28", "phunmart_02_29", "phunmart_02_30", "phunmart_02_31"},
        roll = { mode = "weighted", count = { min = 5, max = 8 } },
        poolSets = {{
            price = "currency_low",
            keys = {{
                key = "pool_phish4u",
                weight = 1.0
            }}
        }}
    },

    HoesNMoes = {
        probability = 15,
        category = "Gardening",
        background = "machine-hoes.png",
        sprites = {"phunmart_02_32", "phunmart_02_33", "phunmart_02_34", "phunmart_02_35"},
        unpoweredSprites = {"phunmart_02_36", "phunmart_02_37", "phunmart_02_38", "phunmart_02_39"},
        roll = { mode = "weighted", count = { min = 5, max = 8 } },
        poolSets = {{
            price = "currency_low",
            keys = {{
                key = "pool_hoesnmoes",
                weight = 1.0
            }}
        }}
    },

    BudgetXPerience = {
        probability = 5,
        minDistance = 500,
        category = "XP",
        defaultView = "list",
        background = "machine-budget-xp.png",
        sprites = {"phunmart_02_40", "phunmart_02_41", "phunmart_02_42", "phunmart_02_43"},
        unpoweredSprites = {"phunmart_02_44", "phunmart_02_45", "phunmart_02_46", "phunmart_02_47"},
        roll = { mode = "weighted", count = { min = 4, max = 8 } },
        poolSets = {{
            keys = {{
                key = "pool_xp_budget",
                weight = 1.0
            }, {
                key = "pool_boost_budget",
                weight = 0.5
            }, {
                key = "pool_xp_gifted",
                weight = 1.0
            }, {
                key = "pool_boost_gifted",
                weight = 0.5
            }, {
                key = "pool_xp_luxury",
                weight = 1.0
            }, {
                key = "pool_boost_luxury",
                weight = 0.5
            }}
        }}
    },

    HardWear = {
        probability = 15,
        category = "Clothing",
        background = "machine-hard-wear.png",
        sprites = {"phunmart_03_0", "phunmart_03_1", "phunmart_03_2", "phunmart_03_3"},
        unpoweredSprites = {"phunmart_03_4", "phunmart_03_5", "phunmart_03_6", "phunmart_03_7"},
        poolSets = {{
            roll = { mode = "weighted", count = { min = 4, max = 7 } },
            keys = {{
                key = "pool_hardwear_clothing",
                weight = 1.0
            }}
        }, {
            roll = { mode = "weighted", count = { min = 2, max = 4 } },
            keys = {{
                key = "pool_hardwear_protective",
                weight = 1.0
            }}
        }}
    },

    ShedsAndCommoners = {
        probability = 15,
        category = "Literature",
        background = "machine-sheds-and-commoners.png",
        sprites = {"phunmart_03_24", "phunmart_03_25", "phunmart_03_26", "phunmart_03_27"},
        unpoweredSprites = {"phunmart_03_28", "phunmart_03_29", "phunmart_03_30", "phunmart_03_31"},
        roll = { mode = "weighted", count = { min = 5, max = 8 } },
        poolSets = {{
            keys = {{
                key = "pool_shedsandcommoners_t1",
                weight = 1.0
            }, {
                key = "pool_shedsandcommoners_t2",
                weight = 1.0
            }, {
                key = "pool_shedsandcommoners_t3",
                weight = 1.0
            }, {
                key = "pool_shedsandcommoners_t4",
                weight = 1.0
            }, {
                key = "pool_shedsandcommoners_misc",
                weight = 0.8
            }}
        }}
    },

    Collectors = {
        probability = 8,
        minDistance = 300,
        category = "Collectors",
        background = "machine-collectors.png",
        sprites = {"phunmart_03_8", "phunmart_03_9", "phunmart_03_10", "phunmart_03_11"},
        unpoweredSprites = {"phunmart_03_12", "phunmart_03_13", "phunmart_03_14", "phunmart_03_15"},
        roll = { mode = "weighted", count = { min = 1, max = 3 } },
        poolSets = {{
            keys = {{
                key = "pool_collectors",
                weight = 1.0
            }}
        }}
    }

}
