return {

    -- =========================================================
    -- GoodPhoods  (health food, ingredients, cooking supplies)
    -- =========================================================
    pool_goodphoods = {
        defaults = {
            price = "coin_low"
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
            price = "coin_low"
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
    -- FinalAmendment  (guns, ammo, explosives)
    -- =========================================================
    pool_finalamendment_melee = {
        defaults = {
            price = "coin_mid"
        },
        sources = {
            groups = {"weapons_melee"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 2,
                max = 3
            }
        }
    },

    pool_finalamendment_ammo = {
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
    pool_finalamendment_guns = {
        defaults = {
            price = "coin_high"
        },
        zones = {
            difficulty = {3, 4}
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
    pool_finalamendment_explosives = {
        defaults = {
            price = "coin_high"
        },
        zones = {
            difficulty = {4}
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
        zones = {
            difficulty = {1, 2}
        },
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
        zones = {
            difficulty = {2, 3}
        },
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
        zones = {
            difficulty = {4}
        },
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
        defaults = {
            price = "tokens_mid"
        },
        fallbackTexture = "Item_Notebook",
        fallbackCategory = "Positive Traits",
        sources = {
            rewards = {"trait_add"}
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
        defaults = {
            price = "tokens_mid"
        },
        fallbackTexture = "Item_Notebook",
        fallbackCategory = "Remove Negative Traits",
        sources = {
            rewards = {"trait_remove"}
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
    -- CSVPharmacy  (medical supplies — 3 tiers across 2 pools)
    -- basic pool: medical_cheap + medical_standard, all zones, 4-7 items
    -- rare pool:  medical_rare (prescription drugs), zones 2+, 1-3 items
    -- =========================================================
    pool_csvpharmacy_basic = {
        sources = {
            groups = {"medical_cheap", "medical_standard"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 4,
                max = 7
            }
        }
    },
    pool_csvpharmacy_rare = {
        zones = {
            difficulty = {2, 3, 4}
        },
        sources = {
            groups = {"medical_rare"}
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
    -- HardWear  (clothing + protective gear — 2 pools)
    -- clothing pool:   casual/work clothing, all zones, 4-7 items
    -- protective pool: helmets/vests/tactical, zones 2+, 2-4 items
    -- =========================================================
    pool_hardwear_clothing = {
        sources = {
            groups = {"hardwear_clothing"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 4,
                max = 7
            }
        }
    },
    pool_hardwear_protective = {
        zones = {
            difficulty = {2, 3, 4, 5}
        },
        sources = {
            groups = {"hardwear_protective"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 2,
                max = 4
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
    -- Collectors  (buyback machine: items → bound tokens)
    -- 4 tiers weighted by in-world rarity. Higher tiers appear less often
    -- on the grid and pay more bound tokens per transaction.
    -- =========================================================
    pool_collectors = {
        sources = {
            groups = {"collectors_junk", "collectors_curios", "collectors_rare", "collectors_legendary"}
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
    -- XPerience  (XP grants - one pool per tier, sources use reward category)
    -- Defined in PhunMart_XP_Items.lua and PhunMart_XP_Conditions.lua
    --
    -- Zone difficulty gating (requires PhunZones):
    --   Zone 1       → budget only          (+1 level grants)
    --   Zone 2       → budget + gifted mix  (+1/+2)
    --   Zone 3       → gifted + luxury mix  (+2/+3)
    --   Zone 4     → luxury only          (+3 level grants)
    -- Unzoned locations get all tiers (permissive fallback).
    -- =========================================================
    pool_xp_budget = {
        zones = {
            difficulty = {1, 2}
        },
        fallbackTexture = "Item_Book",
        fallbackCategory = "Skills",
        sources = {
            rewards = {"xp_t1"}
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
        zones = {
            difficulty = {2, 3}
        },
        fallbackTexture = "Item_Book",
        fallbackCategory = "Skills",
        sources = {
            rewards = {"xp_t2"}
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
        zones = {
            difficulty = {3, 4}
        },
        fallbackTexture = "Item_Book",
        fallbackCategory = "Skills",
        sources = {
            rewards = {"xp_t3"}
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
        zones = {
            difficulty = {1, 2}
        },
        fallbackTexture = "Item_Book",
        fallbackCategory = "Boosts",
        sources = {
            rewards = {"boost_t1"}
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
        zones = {
            difficulty = {2, 3}
        },
        fallbackTexture = "Item_Book",
        fallbackCategory = "Boosts",
        sources = {
            rewards = {"boost_t2"}
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
        zones = {
            difficulty = {3, 4}
        },
        fallbackTexture = "Item_Book",
        fallbackCategory = "Boosts",
        sources = {
            rewards = {"boost_t3"}
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
    -- ShedsAndCommoners  (skill books by volume tier + misc literature)
    -- Zone difficulty gating mirrors BudgetXPerience pattern:
    --   Zone 1       → t1 only          (Vol 1, levels 1-2)
    --   Zone 2       → t1 + t2 mix      (Vol 1-2, levels 1-4)
    --   Zone 3       → t2 + t3 mix      (Vol 2-3, levels 3-6)
    --   Zone 4       → t3 + t4 mix      (Vol 3-5, levels 5-10)
    --   Zone 5       → t4 only          (Vol 4-5, levels 7-10)
    -- Misc (Literature, RecipeResource) available in all zones.
    -- =========================================================
    pool_shedsandcommoners_t1 = {
        zones = {
            difficulty = {1, 2}
        },
        sources = {
            groups = {"skill_books_t1"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 2,
                max = 4
            }
        }
    },
    pool_shedsandcommoners_t2 = {
        zones = {
            difficulty = {2, 3}
        },
        sources = {
            groups = {"skill_books_t2"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 2,
                max = 4
            }
        }
    },
    pool_shedsandcommoners_t3 = {
        zones = {
            difficulty = {3, 4}
        },
        sources = {
            groups = {"skill_books_t3"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 2,
                max = 3
            }
        }
    },
    pool_shedsandcommoners_t4 = {
        zones = {
            difficulty = {4}
        },
        sources = {
            groups = {"skill_books_t4"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 1,
                max = 3
            }
        }
    },
    pool_shedsandcommoners_misc = {
        sources = {
            groups = {"skill_books_misc"}
        },
        roll = {
            mode = "weighted",
            count = {
                min = 2,
                max = 3
            }
        }
    }

}
