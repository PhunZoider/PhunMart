return {

    GoodPhoods = {
        category = "Food",
        background = "machine-good-phoods.png",
        sprites = {"phunmart_01_8", "phunmart_01_9", "phunmart_01_10", "phunmart_01_11"},
        unpoweredSprites = {"phunmart_01_12", "phunmart_01_13", "phunmart_01_14", "phunmart_01_15"},
        poolSets = {{
            keys = {{
                key = "pool_goodphoods",
                weight = 1.0
            }}
        }}
    },

    PhatPhoods = {
        category = "Food",
        background = "machine-phat-phoods.png",
        sprites = {"phunmart_01_16", "phunmart_01_17", "phunmart_01_18", "phunmart_01_19"},
        unpoweredSprites = {"phunmart_01_20", "phunmart_01_21", "phunmart_01_22", "phunmart_01_23"},
        poolSets = {{
            keys = {{
                key = "pool_phatphoods",
                weight = 1.0
            }}
        }}
    },

    PittyTheTool = {
        category = "Tool",
        background = "machine-pity-the-tool.png",
        sprites = {"phunmart_01_24", "phunmart_01_25", "phunmart_01_26", "phunmart_01_27"},
        unpoweredSprites = {"phunmart_01_28", "phunmart_01_29", "phunmart_01_30", "phunmart_01_31"},
        poolSets = {{
            keys = {{
                key = "pool_pittythetool",
                weight = 1.0
            }}
        }}
    },

    FinalAmmendment = {
        category = "Weapon",
        background = "machine-final-ammendment.png",
        sprites = {"phunmart_01_32", "phunmart_01_33", "phunmart_01_34", "phunmart_01_35"},
        unpoweredSprites = {"phunmart_01_36", "phunmart_01_37", "phunmart_01_38", "phunmart_01_39"},
        poolSets = {{
            keys = {{
                key = "pool_finalammendment_ammo",
                weight = 1.0
            }, {
                key = "pool_finalammendment_guns",
                weight = 1.0
            }, {
                key = "pool_finalammendment_explosives",
                weight = 0.5
            }}
        }}
    },

    -- WrentAWreck: multiple poolSets let the shop show different tiers per zone.
    -- Gate by zone in each poolSet's `gate` block once gating is implemented.
    WrentAWreck = {
        category = "Vehicle",
        defaultView = "list",
        background = "machine-wrent-a-wreck.png",
        sprites = {"phunmart_01_40", "phunmart_01_41", "phunmart_01_42", "phunmart_01_43"},
        unpoweredSprites = {"phunmart_01_44", "phunmart_01_45", "phunmart_01_46", "phunmart_01_47"},
        poolSets = {{
            keys = {{
                key = "pool_vehicles_budget",
                weight = 1.0
            }}
        }, -- safe zones
        {
            keys = {{
                key = "pool_vehicles_standard",
                weight = 1.0
            }}
        }, -- mid zones
        {
            keys = {{
                key = "pool_vehicles_premium",
                weight = 1.0
            }}
        } -- danger zones
        }
    },

    MichellesCrafts = {
        category = "Crafts",
        background = "machine-michelles.png",
        sprites = {"phunmart_01_48", "phunmart_01_49", "phunmart_01_50", "phunmart_01_51"},
        unpoweredSprites = {"phunmart_01_52", "phunmart_01_53", "phunmart_01_54", "phunmart_01_55"},
        poolSets = {{
            keys = {{
                key = "pool_michellescrafts",
                weight = 1.0
            }}
        }}
    },

    CarAPart = {
        category = "Vehicle",
        background = "machine-car-a-part.png",
        sprites = {"phunmart_01_56", "phunmart_01_57", "phunmart_01_58", "phunmart_01_59"},
        unpoweredSprites = {"phunmart_01_60", "phunmart_01_61", "phunmart_01_62", "phunmart_01_63"},
        poolSets = {{
            keys = {{
                key = "pool_carapart",
                weight = 1.0
            }}
        }}
    },

    TraiterJoes = {
        category = "Trait",
        background = "machine-traiter-joes.png",
        sprites = {"phunmart_02_0", "phunmart_02_1", "phunmart_02_2", "phunmart_02_3"},
        unpoweredSprites = {"phunmart_02_4", "phunmart_02_5", "phunmart_02_6", "phunmart_02_7"},
        poolSets = {{
            keys = {{
                key = "pool_traiter_good",
                weight = 1.0
            }, {
                key = "pool_traiter_bad_removal",
                weight = 1.0
            }}
        }}
    },

    CSVPharmacy = {
        category = "Medical",
        background = "machine-csv.png",
        sprites = {"phunmart_02_8", "phunmart_02_9", "phunmart_02_10", "phunmart_02_11"},
        unpoweredSprites = {"phunmart_02_12", "phunmart_02_13", "phunmart_02_14", "phunmart_02_15"},
        poolSets = {{
            keys = {{
                key = "pool_csvpharmacy",
                weight = 1.0
            }}
        }}
    },

    RadioHacks = {
        category = "Electronics",
        background = "machine-electronics.png",
        sprites = {"phunmart_02_16", "phunmart_02_17", "phunmart_02_18", "phunmart_02_19"},
        unpoweredSprites = {"phunmart_02_20", "phunmart_02_21", "phunmart_02_22", "phunmart_02_23"},
        poolSets = {{
            keys = {{
                key = "pool_radiohacks",
                weight = 1.0
            }}
        }}
    },

    Phish4U = {
        category = "Fishing",
        background = "machine-phish4u.png",
        sprites = {"phunmart_02_24", "phunmart_02_25", "phunmart_02_26", "phunmart_02_27"},
        unpoweredSprites = {"phunmart_02_28", "phunmart_02_29", "phunmart_02_30", "phunmart_02_31"},
        poolSets = {{
            keys = {{
                key = "pool_phish4u",
                weight = 1.0
            }}
        }}
    },

    HoesNMoes = {
        category = "Gardening",
        background = "machine-hoes.png",
        sprites = {"phunmart_02_32", "phunmart_02_33", "phunmart_02_34", "phunmart_02_35"},
        unpoweredSprites = {"phunmart_02_36", "phunmart_02_37", "phunmart_02_38", "phunmart_02_39"},
        poolSets = {{
            keys = {{
                key = "pool_hoesnmoes",
                weight = 1.0
            }}
        }}
    },

    BudgetXPerience = {
        category = "XP",
        defaultView = "list",
        background = "machine-budget-xp.png",
        sprites = {"phunmart_02_40", "phunmart_02_41", "phunmart_02_42", "phunmart_02_43"},
        unpoweredSprites = {"phunmart_02_44", "phunmart_02_45", "phunmart_02_46", "phunmart_02_47"},
        poolSets = {{
            keys = {{
                key = "pool_xp_budget",
                weight = 1.0
            }, {
                key = "pool_boost_budget",
                weight = 0.5
            }}
        }}
    },

    GiftedXPerience = {
        category = "XP",
        defaultView = "list",
        background = "machine-gifted-xp.png",
        sprites = {"phunmart_02_48", "phunmart_02_49", "phunmart_02_50", "phunmart_02_51"},
        unpoweredSprites = {"phunmart_02_52", "phunmart_02_53", "phunmart_02_54", "phunmart_02_55"},
        poolSets = {{
            keys = {{
                key = "pool_xp_gifted",
                weight = 1.0
            }, {
                key = "pool_boost_gifted",
                weight = 0.5
            }}
        }}
    },

    LuxuryXPerience = {
        category = "XP",
        defaultView = "list",
        background = "machine-luxury-xp.png",
        sprites = {"phunmart_02_56", "phunmart_02_57", "phunmart_02_58", "phunmart_02_59"},
        unpoweredSprites = {"phunmart_02_60", "phunmart_02_61", "phunmart_02_62", "phunmart_02_63"},
        poolSets = {{
            keys = {{
                key = "pool_xp_luxury",
                weight = 1.0
            }, {
                key = "pool_boost_luxury",
                weight = 0.5
            }}
        }}
    },

    HardWear = {
        category = "Clothing",
        background = "machine-hard-wear.png",
        sprites = {"phunmart_03_0", "phunmart_03_1", "phunmart_03_2", "phunmart_03_3"},
        unpoweredSprites = {"phunmart_03_4", "phunmart_03_5", "phunmart_03_6", "phunmart_03_7"},
        poolSets = {{
            keys = {{
                key = "pool_hardwear",
                weight = 1.0
            }}
        }}
    },

    ShedsAndCommoners = {
        category = "Literature",
        background = "machine-sheds-and-commoners.png",
        sprites = {"phunmart_03_24", "phunmart_03_25", "phunmart_03_26", "phunmart_03_27"},
        unpoweredSprites = {"phunmart_03_28", "phunmart_03_29", "phunmart_03_30", "phunmart_03_31"},
        poolSets = {{
            keys = {{
                key = "pool_shedsandcommoners",
                weight = 1.0
            }}
        }}
    }

}
