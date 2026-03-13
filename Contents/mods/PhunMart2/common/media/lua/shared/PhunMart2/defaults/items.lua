return {

    -- =========================================================
    -- TRAIT OFFER ITEMS
    -- Each maps an offer key to a reward key (both defined in Rewards.lua).
    -- Price = abs(trait cost from dump) * 3 tokens.
    -- canGrantTrait / canRemoveTrait conditions are auto-injected by the compiler.
    -- =========================================================

    -- Positive traits  (price = cost * 3)
    ["offer:add_brave"] = { -- cost 4  → 12t
        price = "token_12",
        reward = "add_brave",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_fasthealer"] = { -- cost 6  → 18t
        price = "token_18",
        reward = "add_fasthealer",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_strong"] = { -- cost 10 → 30t
        price = "token_30",
        reward = "add_strong",
        offer = {
            weight = 0.5
        }
    },
    ["offer:add_stout"] = { -- cost 6  → 18t
        price = "token_18",
        reward = "add_stout",
        offer = {
            weight = 0.7
        }
    },
    ["offer:add_athletic"] = { -- cost 10 → 30t
        price = "token_30",
        reward = "add_athletic",
        offer = {
            weight = 0.5
        }
    },
    ["offer:add_fit"] = { -- cost 6  → 18t
        price = "token_18",
        reward = "add_fit",
        offer = {
            weight = 0.7
        }
    },
    ["offer:add_gymnast"] = { -- cost 5  → 15t
        price = "token_15",
        reward = "add_gymnast",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_organized"] = { -- cost 4  → 12t
        price = "token_12",
        reward = "add_organized",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_dextrous"] = { -- cost 2  → 6t
        price = "token_6",
        reward = "add_dextrous",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_graceful"] = { -- cost 4  → 12t
        price = "token_12",
        reward = "add_graceful",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_keenhearing"] = { -- cost 6  → 18t
        price = "token_18",
        reward = "add_keenhearing",
        offer = {
            weight = 0.8
        }
    },
    ["offer:add_eagleeyed"] = { -- cost 4  → 12t
        price = "token_12",
        reward = "add_eagleeyed",
        offer = {
            weight = 0.8
        }
    },
    ["offer:add_thickskinned"] = { -- cost 8  → 24t
        price = "token_24",
        reward = "add_thickskinned",
        offer = {
            weight = 0.5
        }
    },
    ["offer:add_irongut"] = { -- cost 3  → 9t
        price = "token_9",
        reward = "add_irongut",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_resilient"] = { -- cost 4  → 12t
        price = "token_12",
        reward = "add_resilient",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_fastlearner"] = { -- cost 6  → 18t
        price = "token_18",
        reward = "add_fastlearner",
        offer = {
            weight = 0.7
        }
    },
    ["offer:add_crafty"] = { -- cost 3  → 9t
        price = "token_9",
        reward = "add_crafty",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_inconspicuous"] = { -- cost 4  → 12t
        price = "token_12",
        reward = "add_inconspicuous",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_fastreader"] = { -- cost 2  → 6t
        price = "token_6",
        reward = "add_fastreader",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_lighteater"] = { -- cost 2  → 6t
        price = "token_6",
        reward = "add_lighteater",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_lowthirst"] = { -- cost 2  → 6t
        price = "token_6",
        reward = "add_lowthirst",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_needslesssleep"] = { -- cost 2  → 6t
        price = "token_6",
        reward = "add_needslesssleep",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_jogger"] = { -- cost 4  → 12t
        price = "token_12",
        reward = "add_jogger",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_brawler"] = { -- cost 6  → 18t
        price = "token_18",
        reward = "add_brawler",
        offer = {
            weight = 0.8
        }
    },
    ["offer:add_hiker"] = { -- cost 6  → 18t
        price = "token_18",
        reward = "add_hiker",
        offer = {
            weight = 0.8
        }
    },
    ["offer:add_formerscout"] = { -- cost 6  → 18t
        price = "token_18",
        reward = "add_formerscout",
        offer = {
            weight = 0.7
        }
    },
    ["offer:add_outdoorsman"] = { -- cost 2  → 6t
        price = "token_6",
        reward = "add_outdoorsman",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_herbalist"] = { -- cost 4  → 12t
        price = "token_12",
        reward = "add_herbalist",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_hunter"] = { -- cost 8  → 24t
        price = "token_24",
        reward = "add_hunter",
        offer = {
            weight = 0.5
        }
    },
    ["offer:add_fishing"] = { -- cost 4  → 12t
        price = "token_12",
        reward = "add_fishing",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_cook"] = { -- cost 3  → 9t
        price = "token_9",
        reward = "add_cook",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_nutritionist"] = { -- cost 4  → 12t
        price = "token_12",
        reward = "add_nutritionist",
        offer = {
            weight = 0.8
        }
    },
    ["offer:add_firstaid"] = { -- cost 4  → 12t
        price = "token_12",
        reward = "add_firstaid",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_handy"] = { -- cost 8  → 24t
        price = "token_24",
        reward = "add_handy",
        offer = {
            weight = 0.5
        }
    },
    ["offer:add_mechanic"] = { -- cost 3  → 9t
        price = "token_9",
        reward = "add_mechanic",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_tailor"] = { -- cost 4  → 12t
        price = "token_12",
        reward = "add_tailor",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_blacksmith"] = { -- cost 6  → 18t
        price = "token_18",
        reward = "add_blacksmith",
        offer = {
            weight = 0.7
        }
    },
    ["offer:add_mason"] = { -- cost 2  → 6t
        price = "token_6",
        reward = "add_mason",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_whittler"] = { -- cost 2  → 6t
        price = "token_6",
        reward = "add_whittler",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_adrenalinejunkie"] = { -- cost 4  → 12t
        price = "token_12",
        reward = "add_adrenalinejunkie",
        offer = {
            weight = 0.8
        }
    },
    ["offer:add_nightvision"] = { -- cost 2  → 6t
        price = "token_6",
        reward = "add_nightvision",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_speeddemon"] = { -- cost 1  → 3t
        price = "token_3",
        reward = "add_speeddemon",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_inventive"] = { -- cost 2  → 6t
        price = "token_6",
        reward = "add_inventive",
        offer = {
            weight = 1.0
        }
    },
    ["offer:add_wildernessknowledge"] = { -- cost 8 → 24t
        price = "token_24",
        reward = "add_wildernessknowledge",
        offer = {
            weight = 0.5
        }
    },
    ["offer:add_gardener"] = { -- cost 2  → 6t
        price = "token_6",
        reward = "add_gardener",
        offer = {
            weight = 1.0
        }
    },

    -- Negative trait removals  (price = abs(cost) * 3)
    ["offer:remove_slowlearner"] = { -- cost -6 → 18t
        price = "token_18",
        reward = "remove_slowlearner",
        offer = {
            weight = 1.0
        }
    },
    ["offer:remove_clumsy"] = { -- cost -2 → 6t
        price = "token_6",
        reward = "remove_clumsy",
        offer = {
            weight = 1.0
        }
    },
    ["offer:remove_weakstomach"] = { -- cost -3 → 9t
        price = "token_9",
        reward = "remove_weakstomach",
        offer = {
            weight = 1.0
        }
    },
    ["offer:remove_slowhealer"] = { -- cost -3 → 9t
        price = "token_9",
        reward = "remove_slowhealer",
        offer = {
            weight = 1.0
        }
    },
    ["offer:remove_insomniac"] = { -- cost -6 → 18t
        price = "token_18",
        reward = "remove_insomniac",
        offer = {
            weight = 0.8
        }
    },
    ["offer:remove_highthirst"] = { -- cost -1 → 3t
        price = "token_3",
        reward = "remove_highthirst",
        offer = {
            weight = 1.0
        }
    },
    ["offer:remove_shortsighted"] = { -- cost -2 → 6t
        price = "token_6",
        reward = "remove_shortsighted",
        offer = {
            weight = 1.0
        }
    },
    ["offer:remove_conspicuous"] = { -- cost -4 → 12t
        price = "token_12",
        reward = "remove_conspicuous",
        offer = {
            weight = 0.8
        }
    },
    ["offer:remove_cowardly"] = { -- cost -2 → 6t
        price = "token_6",
        reward = "remove_cowardly",
        offer = {
            weight = 1.0
        }
    },
    ["offer:remove_disorganized"] = { -- cost -6 → 18t
        price = "token_18",
        reward = "remove_disorganized",
        offer = {
            weight = 0.8
        }
    },
    ["offer:remove_heartyappetite"] = { -- cost -4 → 12t
        price = "token_12",
        reward = "remove_heartyappetite",
        offer = {
            weight = 0.8
        }
    },
    ["offer:remove_pacifist"] = { -- cost -4 → 12t
        price = "token_12",
        reward = "remove_pacifist",
        offer = {
            weight = 0.8
        }
    },
    ["offer:remove_slowreader"] = { -- cost -2 → 6t
        price = "token_6",
        reward = "remove_slowreader",
        offer = {
            weight = 1.0
        }
    },
    ["offer:remove_thinskinned"] = { -- cost -8 → 24t
        price = "token_24",
        reward = "remove_thinskinned",
        offer = {
            weight = 0.5
        }
    },
    ["offer:remove_outofshape"] = { -- cost -6 → 18t  [DISABLED: re-applied by engine if Fitness < 3]
        enabled = false,
        price = "token_18",
        reward = "remove_outofshape",
        offer = {
            weight = 0.8
        }
    },
    ["offer:remove_hardofhearing"] = { -- cost -4 → 12t
        price = "token_12",
        reward = "remove_hardofhearing",
        offer = {
            weight = 0.8
        }
    },
    ["offer:remove_allthumbs"] = { -- cost -2 → 6t
        price = "token_6",
        reward = "remove_allthumbs",
        offer = {
            weight = 1.0
        }
    },
    ["offer:remove_hemophobic"] = { -- cost -5 → 15t
        price = "token_15",
        reward = "remove_hemophobic",
        offer = {
            weight = 0.7
        }
    },
    ["offer:remove_needsmoresleep"] = { -- cost -4 → 12t
        price = "token_12",
        reward = "remove_needsmoresleep",
        offer = {
            weight = 0.8
        }
    },
    ["offer:remove_asthmatic"] = { -- cost -5 → 15t
        price = "token_15",
        reward = "remove_asthmatic",
        offer = {
            weight = 0.7
        }
    },
    ["offer:remove_smoker"] = { -- cost -2 → 6t  [DISABLED: removing trait doesn't cure addiction mood]
        enabled = false,
        price = "token_6",
        reward = "remove_smoker",
        offer = {
            weight = 1.0
        }
    },
    ["offer:remove_feeble"] = { -- cost -6 → 18t
        price = "token_18",
        reward = "remove_feeble",
        offer = {
            weight = 0.7
        }
    },
    ["offer:remove_pronetoillness"] = { -- cost -4 → 12t
        price = "token_12",
        reward = "remove_pronetoillness",
        offer = {
            weight = 0.8
        }
    },
    ["offer:remove_claustrophobic"] = { -- cost -4 → 12t
        price = "token_12",
        reward = "remove_claustrophobic",
        offer = {
            weight = 0.8
        }
    },
    ["offer:remove_agoraphobic"] = { -- cost -4 → 12t
        price = "token_12",
        reward = "remove_agoraphobic",
        offer = {
            weight = 0.8
        }
    },
    ["offer:remove_unfit"] = { -- cost -10 → 30t  [DISABLED: re-applied by engine if Fitness < 1]
        enabled = false,
        price = "token_30",
        reward = "remove_unfit",
        offer = {
            weight = 0.5
        }
    },
    ["offer:remove_sundaydriver"] = { -- cost -1 → 3t
        price = "token_3",
        reward = "remove_sundaydriver",
        offer = {
            weight = 1.0
        }
    },

    -- =========================================================
    -- VEHICLE OFFER ITEMS
    -- stock=1 with long restock keeps vehicles feeling rare
    -- =========================================================

    SmallCar = {
        price = "vehicle_common",
        reward = "vehicle_smallcar",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    SmallCar02 = {
        price = "vehicle_common",
        reward = "vehicle_smallcar",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    CarNormal = {
        price = "vehicle_uncommon",
        reward = "vehicle_normalcar",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    ModernCar = {
        price = "vehicle_uncommon",
        reward = "vehicle_normalcar",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    ModernCar02 = {
        price = "vehicle_uncommon",
        reward = "vehicle_normalcar",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    CarStationWagon = {
        price = "vehicle_uncommon",
        reward = "vehicle_stationwagon",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    CarLuxury = {
        price = "vehicle_rare",
        reward = "vehicle_luxury",
        offer = {
            weight = 0.5,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    SportsCar = {
        price = "vehicle_rare",
        reward = "vehicle_sportscar",
        offer = {
            weight = 0.5,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    SUV = {
        price = "vehicle_uncommon",
        reward = "vehicle_suv",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    OffRoad = {
        price = "vehicle_uncommon",
        reward = "vehicle_offroad",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    PickUpTruck = {
        price = "vehicle_uncommon",
        reward = "vehicle_pickup",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    PickUpVan = {
        price = "vehicle_uncommon",
        reward = "vehicle_pickup",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    Van = {
        price = "vehicle_common",
        reward = "vehicle_van",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    VanSeats = {
        price = "vehicle_common",
        reward = "vehicle_van",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    StepVan = {
        price = "vehicle_common",
        reward = "vehicle_stepvan",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    }

    -- XP and boost offer items are defined in PhunMart2_XP_Items.lua (generated)

}
