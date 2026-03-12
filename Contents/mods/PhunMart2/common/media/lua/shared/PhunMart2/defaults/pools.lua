return {

    -- =========================================================
    -- GoodPhoods  (health food, ingredients, cooking supplies)
    -- =========================================================
    pool_goodphoods = {
        defaults = {
            price = "coin_5"
        },
        sources = {
            groups = {"food_fresh", "food_cooking_utensils"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 6,
                max = 9
            }
        }
    },

    -- =========================================================
    -- PhatPhoods  (junk food, candy, booze)
    -- =========================================================
    pool_phatphoods = {
        defaults = {
            price = "coin_5",
            conditions = "oneTimePurchase"
        },
        sources = {
            groups = {"food_junk", "food_alcohol"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 6,
                max = 9
            }
        }
    },

    -- =========================================================
    -- PittyTheTool  (tools, hardware)
    -- =========================================================
    pool_pittythetool = {
        defaults = {
            price = "coin_mid"
        },
        sources = {
            groups = {"tools_general"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 5,
                max = 8
            }
        }
    },

    -- =========================================================
    -- FinalAmmendment  (guns, ammo, explosives)
    -- =========================================================
    pool_finalammendment_ammo = {
        defaults = {
            price = "coin_low"
        },
        sources = {
            groups = {"ammo_all"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 4,
                max = 7
            }
        }
    },
    pool_finalammendment_guns = {
        defaults = {
            price = "coin_high"
        },
        sources = {
            groups = {"weapons_firearms", "weapons_parts"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 3,
                max = 5
            }
        }
    },
    pool_finalammendment_explosives = {
        defaults = {
            price = "coin_high"
        },
        sources = {
            groups = {"explosives"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 1,
                max = 3
            }
        }
    },

    -- =========================================================
    -- WrentAWreck  (vehicles - one pool per tier)
    -- =========================================================
    pool_vehicles_budget = {
        sources = {
            groups = {"vehicles_small", "vehicles_vans"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 5,
                max = 8
            }
        }
    },
    pool_vehicles_standard = {
        sources = {
            groups = {"vehicles_normal", "vehicles_trucks", "vehicles_4x4"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 5,
                max = 8
            }
        }
    },
    pool_vehicles_premium = {
        sources = {
            groups = {"vehicles_luxury"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 5,
                max = 8
            }
        }
    },

    -- =========================================================
    -- MichellesCrafts  (arts, crafts, paint, materials)
    -- =========================================================
    pool_michellescrafts = {
        defaults = {
            price = "coin_low"
        },
        sources = {
            groups = {"crafts_paint", "crafts_materials", "crafts_sewing"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 5,
                max = 8
            }
        }
    },

    -- =========================================================
    -- CarAParts  (vehicle maintenance)
    -- =========================================================
    pool_caraparts = {
        defaults = {
            price = "coin_mid"
        },
        sources = {
            groups = {"vehicle_parts"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 5,
                max = 8
            }
        }
    },

    -- =========================================================
    -- TraiterJoes  (trait grants and removals)
    -- Sources use reward `category` field, not game item groups.
    -- =========================================================
    pool_traiter_good = {
        fallbackTexture = "Item_Notebook",
        fallbackCategory = "Positive Traits",
        sources = {
            categories = {"trait_add"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 3,
                max = 6
            }
        }
    },
    pool_traiter_bad_removal = {
        fallbackTexture = "Item_Notebook",
        fallbackCategory = "Remove Negative Traits",
        sources = {
            categories = {"trait_remove"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 3,
                max = 5
            }
        }
    },

    -- =========================================================
    -- CSVPharmacy  (medical supplies)
    -- =========================================================
    pool_csvpharmacy = {
        defaults = {
            price = "coin_mid"
        },
        sources = {
            groups = {"medical_all"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 5,
                max = 8
            }
        }
    },

    -- =========================================================
    -- RadioHacks  (electronics, communications)
    -- =========================================================
    pool_radiohacks = {
        defaults = {
            price = "coin_mid"
        },
        sources = {
            groups = {"electronics_all"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 5,
                max = 8
            }
        }
    },

    -- =========================================================
    -- Phish4U  (fishing, sports, camping)
    -- =========================================================
    pool_phish4u = {
        defaults = {
            price = "coin_low"
        },
        sources = {
            groups = {"fishing_gear", "sports_gear", "camping_gear"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 5,
                max = 8
            }
        }
    },

    -- =========================================================
    -- HoesNMoes  (gardening, animals, trapping)
    -- =========================================================
    pool_hoesnmoes = {
        defaults = {
            price = "coin_low"
        },
        sources = {
            groups = {"gardening_all", "animal_supplies", "trapping_gear"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 5,
                max = 8
            }
        }
    },

    -- =========================================================
    -- XPerience  (XP grants - one pool per tier, sources use reward category)
    -- Defined in PhunMart2_XP_Items.lua and PhunMart2_XP_Conditions.lua
    -- =========================================================
    pool_xp_budget = {
        fallbackTexture = "Item_Book",
        fallbackCategory = "Skills",
        sources = {
            categories = {"xp_t1"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 4,
                max = 6
            }
        }
    },
    pool_xp_gifted = {
        fallbackTexture = "Item_Book",
        fallbackCategory = "Skills",
        sources = {
            categories = {"xp_t2"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 4,
                max = 6
            }
        }
    },
    pool_xp_luxury = {
        fallbackTexture = "Item_Book",
        fallbackCategory = "Skills",
        sources = {
            categories = {"xp_t3"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 3,
                max = 5
            }
        }
    },
    pool_boost_budget = {
        fallbackTexture = "Item_Book",
        fallbackCategory = "Boosts",
        sources = {
            categories = {"boost_t1"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 2,
                max = 4
            }
        }
    },
    pool_boost_gifted = {
        fallbackTexture = "Item_Book",
        fallbackCategory = "Boosts",
        sources = {
            categories = {"boost_t2"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 2,
                max = 4
            }
        }
    },
    pool_boost_luxury = {
        fallbackTexture = "Item_Book",
        fallbackCategory = "Boosts",
        sources = {
            categories = {"boost_t3"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 2,
                max = 3
            }
        }
    },

    -- =========================================================
    -- HardWear  (clothing, protective gear)
    -- =========================================================
    pool_hardwear = {
        defaults = {
            price = "coin_low"
        },
        sources = {
            groups = {"clothing_all", "protective_gear"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 5,
                max = 8
            }
        }
    },

    -- =========================================================
    -- ShedsAndCommoners  (skill books, magazines)
    -- =========================================================
    pool_shedsandcommoners = {
        defaults = {
            price = "coin_mid"
        },
        sources = {
            groups = {"skill_books_all"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 4,
                max = 7
            }
        }
    }

}
