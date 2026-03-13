return {

    -- =========================================================
    -- TEMPLATES
    -- =========================================================

    trait_add_base = {
        template = true,
        kind = "trait",
        category = "trait_add",
        display = {
            texture = "media/textures/icons/trait_add.png"
        }
    },

    trait_remove_base = {
        template = true,
        kind = "trait",
        category = "trait_remove",
        display = {
            texture = "media/textures/icons/trait_remove.png"
        }
    },

    xp_t1_base = {
        template = true,
        kind = "skill",
        category = "xp_t1",
        display = {
            texture = "media/textures/icons/xp_t1.png"
        }
    },

    xp_t2_base = {
        template = true,
        kind = "skill",
        category = "xp_t2",
        display = {
            texture = "media/textures/icons/xp_t2.png"
        }
    },

    xp_t3_base = {
        template = true,
        kind = "skill",
        category = "xp_t3",
        display = {
            texture = "media/textures/icons/xp_t3.png"
        }
    },

    boost_t1_base = {
        template = true,
        kind = "boost",
        category = "boost_t1",
        display = {
            texture = "media/textures/icons/boost.png"
        }
    },

    boost_t2_base = {
        template = true,
        kind = "boost",
        category = "boost_t2",
        display = {
            texture = "media/textures/icons/boost.png"
        }
    },

    boost_t3_base = {
        template = true,
        kind = "boost",
        category = "boost_t3",
        display = {
            texture = "media/textures/icons/boost.png"
        }
    },

    vehicle_base = {
        template = true,
        kind = "vehicle",
        category = "vehicle"
    },

    -- =========================================================
    -- TRAIT ADDITIONS  (positive traits)
    -- trait key format from dump: "base:<name>"
    -- =========================================================

    add_brave = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Brave"
        },
        actions = {{
            type = "addTrait",
            trait = "base:brave"
        }}
    },
    add_fasthealer = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Fast Healer"
        },
        actions = {{
            type = "addTrait",
            trait = "base:fasthealer"
        }}
    },
    add_strong = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Strong"
        },
        actions = {{
            type = "addTrait",
            trait = "base:strong"
        }}
    },
    add_stout = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Stout"
        },
        actions = {{
            type = "addTrait",
            trait = "base:stout"
        }}
    },
    add_athletic = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Athletic"
        },
        actions = {{
            type = "addTrait",
            trait = "base:athletic"
        }}
    },
    add_fit = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Fit"
        },
        actions = {{
            type = "addTrait",
            trait = "base:fit"
        }}
    },
    add_gymnast = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Gymnast"
        },
        actions = {{
            type = "addTrait",
            trait = "base:gymnast"
        }}
    },
    add_organized = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Organized"
        },
        actions = {{
            type = "addTrait",
            trait = "base:organized"
        }}
    },
    add_dextrous = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Dextrous"
        },
        actions = {{
            type = "addTrait",
            trait = "base:dextrous"
        }}
    },
    add_graceful = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Graceful"
        },
        actions = {{
            type = "addTrait",
            trait = "base:graceful"
        }}
    },
    add_keenhearing = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Keen Hearing"
        },
        actions = {{
            type = "addTrait",
            trait = "base:keenhearing"
        }}
    },
    add_eagleeyed = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Eagle Eyed"
        },
        actions = {{
            type = "addTrait",
            trait = "base:eagleeyed"
        }}
    },
    add_thickskinned = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Thick-skinned"
        },
        actions = {{
            type = "addTrait",
            trait = "base:thickskinned"
        }}
    },
    add_irongut = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Iron Gut"
        },
        actions = {{
            type = "addTrait",
            trait = "base:irongut"
        }}
    },
    add_resilient = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Resilient"
        },
        actions = {{
            type = "addTrait",
            trait = "base:resilient"
        }}
    },
    add_fastlearner = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Fast Learner"
        },
        actions = {{
            type = "addTrait",
            trait = "base:fastlearner"
        }}
    },
    add_crafty = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Crafty"
        },
        actions = {{
            type = "addTrait",
            trait = "base:crafty"
        }}
    },
    add_inconspicuous = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Inconspicuous"
        },
        actions = {{
            type = "addTrait",
            trait = "base:inconspicuous"
        }}
    },
    add_fastreader = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Fast Reader"
        },
        actions = {{
            type = "addTrait",
            trait = "base:fastreader"
        }}
    },
    add_lighteater = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Light Eater"
        },
        actions = {{
            type = "addTrait",
            trait = "base:lighteater"
        }}
    },
    add_lowthirst = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Low Thirst"
        },
        actions = {{
            type = "addTrait",
            trait = "base:lowthirst"
        }}
    },
    add_needslesssleep = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Wakeful"
        },
        actions = {{
            type = "addTrait",
            trait = "base:needslesssleep"
        }}
    },
    add_jogger = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Runner"
        },
        actions = {{
            type = "addTrait",
            trait = "base:jogger"
        }}
    },
    add_brawler = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Brawler"
        },
        actions = {{
            type = "addTrait",
            trait = "base:brawler"
        }}
    },
    add_hiker = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Hiker"
        },
        actions = {{
            type = "addTrait",
            trait = "base:hiker"
        }}
    },
    add_formerscout = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Former Scout"
        },
        actions = {{
            type = "addTrait",
            trait = "base:formerscout"
        }}
    },
    add_outdoorsman = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Outdoorsy"
        },
        actions = {{
            type = "addTrait",
            trait = "base:outdoorsman"
        }}
    },
    add_herbalist = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Herbalist"
        },
        actions = {{
            type = "addTrait",
            trait = "base:herbalist"
        }}
    },
    add_hunter = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Hunter"
        },
        actions = {{
            type = "addTrait",
            trait = "base:hunter"
        }}
    },
    add_fishing = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Angler"
        },
        actions = {{
            type = "addTrait",
            trait = "base:fishing"
        }}
    },
    add_cook = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Keen Cook"
        },
        actions = {{
            type = "addTrait",
            trait = "base:cook"
        }}
    },
    add_nutritionist = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Nutritionist"
        },
        actions = {{
            type = "addTrait",
            trait = "base:nutritionist"
        }}
    },
    add_firstaid = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: First Aider"
        },
        actions = {{
            type = "addTrait",
            trait = "base:firstaid"
        }}
    },
    add_handy = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Handy"
        },
        actions = {{
            type = "addTrait",
            trait = "base:handy"
        }}
    },
    add_mechanic = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Vehicle Knowledge"
        },
        actions = {{
            type = "addTrait",
            trait = "base:mechanics"
        }}
    },
    add_tailor = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Sewer"
        },
        actions = {{
            type = "addTrait",
            trait = "base:tailor"
        }}
    },
    add_blacksmith = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Blacksmith"
        },
        actions = {{
            type = "addTrait",
            trait = "base:blacksmith"
        }}
    },
    add_mason = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Mason"
        },
        actions = {{
            type = "addTrait",
            trait = "base:mason"
        }}
    },
    add_whittler = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Whittler"
        },
        actions = {{
            type = "addTrait",
            trait = "base:whittler"
        }}
    },
    add_adrenalinejunkie = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Adrenaline Junkie"
        },
        actions = {{
            type = "addTrait",
            trait = "base:adrenalinejunkie"
        }}
    },
    add_nightvision = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Cat's Eyes"
        },
        actions = {{
            type = "addTrait",
            trait = "base:nightvision"
        }}
    },
    add_speeddemon = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Speed Demon"
        },
        actions = {{
            type = "addTrait",
            trait = "base:speeddemon"
        }}
    },
    add_inventive = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Inventive"
        },
        actions = {{
            type = "addTrait",
            trait = "base:inventive"
        }}
    },
    add_wildernessknowledge = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Wilderness Knowledge"
        },
        actions = {{
            type = "addTrait",
            trait = "base:wildernessknowledge"
        }}
    },
    add_gardener = {
        inherit = "trait_add_base",
        display = {
            text = "Gain: Gardener"
        },
        actions = {{
            type = "addTrait",
            trait = "base:gardener"
        }}
    },

    -- =========================================================
    -- TRAIT REMOVALS  (negative traits)
    -- =========================================================

    remove_slowlearner = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Slow Learner"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:slowlearner"
        }}
    },
    remove_clumsy = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Clumsy"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:clumsy"
        }}
    },
    remove_weakstomach = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Weak Stomach"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:weakstomach"
        }}
    },
    remove_slowhealer = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Slow Healer"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:slowhealer"
        }}
    },
    remove_insomniac = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Restless Sleeper"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:insomniac"
        }}
    },
    remove_highthirst = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: High Thirst"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:highthirst"
        }}
    },
    remove_shortsighted = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Short Sighted"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:shortsighted"
        }}
    },
    remove_conspicuous = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Conspicuous"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:conspicuous"
        }}
    },
    remove_cowardly = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Cowardly"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:cowardly"
        }}
    },
    remove_disorganized = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Disorganized"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:disorganized"
        }}
    },
    remove_heartyappetite = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Hearty Appetite"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:heartyappetite"
        }}
    },
    remove_pacifist = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Reluctant Fighter"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:pacifist"
        }}
    },
    remove_slowreader = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Slow Reader"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:slowreader"
        }}
    },
    remove_thinskinned = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Thin-skinned"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:thinskinned"
        }}
    },
    remove_outofshape = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Out of Shape"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:out of shape"
        }}
    },
    remove_hardofhearing = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Hard of Hearing"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:hardofhearing"
        }}
    },
    remove_allthumbs = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: All Thumbs"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:allthumbs"
        }}
    },
    remove_hemophobic = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Fear of Blood"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:hemophobic"
        }}
    },
    remove_needsmoresleep = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Sleepyhead"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:needsmoresleep"
        }}
    },
    remove_asthmatic = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Short of Breath"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:asthmatic"
        }}
    },
    remove_smoker = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Smoker"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:smoker"
        }}
    },
    remove_feeble = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Weak"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:feeble"
        }}
    },
    remove_pronetoillness = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Prone to Illness"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:pronetoillness"
        }}
    },
    remove_claustrophobic = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Claustrophobic"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:claustrophobic"
        }}
    },
    remove_agoraphobic = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Agoraphobic"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:agoraphobic"
        }}
    },
    remove_unfit = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Unfit"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:unfit"
        }}
    },
    remove_sundaydriver = {
        inherit = "trait_remove_base",
        display = {
            text = "Remove: Sunday Driver"
        },
        actions = {{
            type = "removeTrait",
            trait = "base:sundaydriver"
        }}
    },

    -- =========================================================
    -- VEHICLES  (key items spawned near player)
    -- script names confirmed from vehicle dump
    -- =========================================================

    vehicle_smallcar = {
        inherit = "vehicle_base",
        display = {
            text = "Small Car Key"
        },
        actions = {{
            type = "spawnVehicle",
            scripts = {"SmallCar", "SmallCar02"},
            args = {
                condition = {
                    min = 85,
                    max = 100
                },
                fuel = {
                    min = 0.3,
                    max = 0.7
                }
            }
        }}
    },
    vehicle_normalcar = {
        inherit = "vehicle_base",
        display = {
            text = "Car Key"
        },
        actions = {{
            type = "spawnVehicle",
            scripts = {"CarNormal", "ModernCar", "ModernCar02"},
            args = {
                condition = {
                    min = 85,
                    max = 100
                },
                fuel = {
                    min = 0.3,
                    max = 0.7
                }
            }
        }}
    },
    vehicle_stationwagon = {
        inherit = "vehicle_base",
        display = {
            text = "Station Wagon Key"
        },
        actions = {{
            type = "spawnVehicle",
            scripts = {"CarStationWagon", "CarStationWagon2"},
            args = {
                condition = {
                    min = 85,
                    max = 100
                },
                fuel = {
                    min = 0.3,
                    max = 0.7
                }
            }
        }}
    },
    vehicle_luxury = {
        inherit = "vehicle_base",
        display = {
            text = "Luxury Car Key"
        },
        actions = {{
            type = "spawnVehicle",
            script = "CarLuxury",
            args = {
                condition = {
                    min = 85,
                    max = 100
                },
                fuel = {
                    min = 0.3,
                    max = 0.7
                }
            }
        }}
    },
    vehicle_sportscar = {
        inherit = "vehicle_base",
        display = {
            text = "Sports Car Key"
        },
        actions = {{
            type = "spawnVehicle",
            script = "SportsCar",
            args = {
                condition = {
                    min = 85,
                    max = 100
                },
                fuel = {
                    min = 0.3,
                    max = 0.7
                }
            }
        }}
    },
    vehicle_suv = {
        inherit = "vehicle_base",
        display = {
            text = "SUV Key"
        },
        actions = {{
            type = "spawnVehicle",
            script = "SUV",
            args = {
                condition = {
                    min = 85,
                    max = 100
                },
                fuel = {
                    min = 0.3,
                    max = 0.7
                }
            }
        }}
    },
    vehicle_offroad = {
        inherit = "vehicle_base",
        display = {
            text = "Off-Road Key"
        },
        actions = {{
            type = "spawnVehicle",
            script = "OffRoad",
            args = {
                condition = {
                    min = 85,
                    max = 100
                },
                fuel = {
                    min = 0.3,
                    max = 0.7
                }
            }
        }}
    },
    vehicle_pickup = {
        inherit = "vehicle_base",
        display = {
            text = "Pickup Truck Key"
        },
        actions = {{
            type = "spawnVehicle",
            scripts = {"PickUpTruck", "PickUpVan"},
            args = {
                condition = {
                    min = 85,
                    max = 100
                },
                fuel = {
                    min = 0.3,
                    max = 0.7
                }
            }
        }}
    },
    vehicle_van = {
        inherit = "vehicle_base",
        display = {
            text = "Van Key"
        },
        actions = {{
            type = "spawnVehicle",
            scripts = {"Van", "VanSeats"},
            args = {
                condition = {
                    min = 85,
                    max = 100
                },
                fuel = {
                    min = 0.3,
                    max = 0.7
                }
            }
        }}
    },
    vehicle_stepvan = {
        inherit = "vehicle_base",
        display = {
            text = "Step Van Key"
        },
        actions = {{
            type = "spawnVehicle",
            script = "StepVan",
            args = {
                condition = {
                    min = 85,
                    max = 100
                },
                fuel = {
                    min = 0.3,
                    max = 0.7
                }
            }
        }}
    }

    -- XP rewards defined in PhunMart2_XP_Rewards.lua (generated file)
    -- Each follows pattern: skill_<Perk>_t1, skill_<Perk>_t2, skill_<Perk>_t3
    -- and: boost_<Perk>_t1, boost_<Perk>_t2, boost_<Perk>_t3

}
