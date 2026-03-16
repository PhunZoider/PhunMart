return {

    -- =========================================================
    -- GoodPhoods  (health food, ingredients, cooking supplies)
    -- =========================================================
    pool_goodphoods = {
        sources = {
            groups = {"food_fresh", "food_cooking_utensils"}
        }
    },

    -- =========================================================
    -- PhatPhoods  (junk food, candy, booze)
    -- =========================================================
    pool_phatphoods = {
        sources = {
            groups = {"food_junk", "food_alcohol"}
        }
    },

    -- =========================================================
    -- PittyTheTool  (tools, hardware)
    -- =========================================================
    pool_pittythetool = {
        sources = {
            groups = {"tools_general"}
        }
    },

    -- =========================================================
    -- FinalAmendment  (guns, ammo, explosives)
    -- =========================================================
    pool_finalamendment_melee = {
        sources = {
            groups = {"weapons_melee"}
        }
    },

    pool_finalamendment_ammo = {
        sources = {
            groups = {"ammo_all"}
        }
    },
    pool_finalamendment_guns = {
        zones = {
            difficulty = {3, 4}
        },
        sources = {
            groups = {"weapons_firearms", "weapons_parts"}
        }
    },
    pool_finalamendment_explosives = {
        zones = {
            difficulty = {4}
        },
        sources = {
            groups = {"explosives"}
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
        }
    },
    pool_vehicles_standard = {
        zones = {
            difficulty = {2, 3}
        },
        sources = {
            groups = {"vehicles_normal", "vehicles_trucks", "vehicles_4x4"}
        }
    },
    pool_vehicles_premium = {
        zones = {
            difficulty = {4}
        },
        sources = {
            groups = {"vehicles_luxury"}
        }
    },

    -- =========================================================
    -- MichellesCrafts  (arts, crafts, paint, materials)
    -- =========================================================
    pool_michellescrafts = {
        sources = {
            groups = {"crafts_paint", "crafts_materials", "crafts_sewing"}
        }
    },

    -- =========================================================
    -- CarAParts  (vehicle maintenance)
    -- =========================================================
    pool_caraparts = {
        sources = {
            groups = {"vehicle_parts"}
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
            specials = {"trait_add"}
        }
    },
    pool_traiter_bad_removal = {
        fallbackTexture = "Item_Notebook",
        fallbackCategory = "Remove Negative Traits",
        sources = {
            specials = {"trait_remove"}
        }
    },

    -- =========================================================
    -- CSVPharmacy  (medical supplies -- 3 tiers across 2 pools)
    -- basic pool: medical_cheap + medical_standard, all zones
    -- rare pool:  medical_rare (prescription drugs), zones 2+
    -- =========================================================
    pool_csvpharmacy_basic = {
        sources = {
            groups = {"medical_cheap", "medical_standard"}
        }
    },
    pool_csvpharmacy_rare = {
        zones = {
            difficulty = {2, 3, 4}
        },
        sources = {
            groups = {"medical_rare"}
        }
    },

    -- =========================================================
    -- HardWear  (clothing + protective gear -- 2 pools)
    -- clothing pool:   casual/work clothing, all zones
    -- protective pool: helmets/vests/tactical, zones 2+
    -- =========================================================
    pool_hardwear_clothing = {
        sources = {
            groups = {"hardwear_clothing"}
        }
    },
    pool_hardwear_protective = {
        zones = {
            difficulty = {2, 3, 4, 5}
        },
        sources = {
            groups = {"hardwear_protective"}
        }
    },

    -- =========================================================
    -- RadioHacks  (electronics, communications)
    -- =========================================================
    pool_radiohacks = {
        sources = {
            groups = {"electronics_all"}
        }
    },

    -- =========================================================
    -- Phish4U  (fishing, sports, camping)
    -- =========================================================
    pool_phish4u = {
        sources = {
            groups = {"fishing_gear", "sports_gear", "camping_gear"}
        }
    },

    -- =========================================================
    -- HoesNMoes  (gardening, animals, trapping)
    -- =========================================================
    pool_hoesnmoes = {
        sources = {
            groups = {"gardening_all", "animal_supplies", "trapping_gear"}
        }
    },

    -- =========================================================
    -- Collectors  (buyback machine: items -> bound tokens)
    -- 4 tiers weighted by in-world rarity. Higher tiers appear less often
    -- on the grid and pay more bound tokens per transaction.
    -- =========================================================
    pool_collectors = {
        sources = {
            groups = {"collectors_junk", "collectors_curios", "collectors_rare", "collectors_legendary"}
        }
    },

    -- =========================================================
    -- XPerience  (XP grants - one pool per tier, sources use reward category)
    -- Defined in PhunMart_XP_Items.lua and PhunMart_XP_Conditions.lua
    --
    -- Zone difficulty gating (requires PhunZones):
    --   Zone 1       -> budget only          (+1 level grants)
    --   Zone 2       -> budget + gifted mix  (+1/+2)
    --   Zone 3       -> gifted + luxury mix  (+2/+3)
    --   Zone 4     -> luxury only          (+3 level grants)
    -- Unzoned locations get all tiers (permissive fallback).
    -- =========================================================
    pool_xp_budget = {
        zones = {
            difficulty = {0, 1, 2}
        },
        fallbackTexture = "Item_Book",
        fallbackCategory = "Skills",
        sources = {
            specials = {"xp_t1"}
        }
    },
    pool_xp_gifted = {
        zones = {
            difficulty = {2, 3}
        },
        fallbackTexture = "Item_Book",
        fallbackCategory = "Skills",
        sources = {
            specials = {"xp_t2"}
        }
    },
    pool_xp_luxury = {
        zones = {
            difficulty = {3, 4}
        },
        fallbackTexture = "Item_Book",
        fallbackCategory = "Skills",
        sources = {
            specials = {"xp_t3"}
        }
    },
    pool_boost_budget = {
        zones = {
            difficulty = {1, 2}
        },
        fallbackTexture = "Item_Book",
        fallbackCategory = "Boosts",
        sources = {
            specials = {"boost_t1"}
        }
    },
    pool_boost_gifted = {
        zones = {
            difficulty = {2, 3}
        },
        fallbackTexture = "Item_Book",
        fallbackCategory = "Boosts",
        sources = {
            specials = {"boost_t2"}
        }
    },
    pool_boost_luxury = {
        zones = {
            difficulty = {3, 4}
        },
        fallbackTexture = "Item_Book",
        fallbackCategory = "Boosts",
        sources = {
            specials = {"boost_t3"}
        }
    },

    -- =========================================================
    -- ShedsAndCommoners  (skill books by volume tier + misc literature)
    -- Zone difficulty gating mirrors BudgetXPerience pattern:
    --   Zone 1       -> t1 only          (Vol 1, levels 1-2)
    --   Zone 2       -> t1 + t2 mix      (Vol 1-2, levels 1-4)
    --   Zone 3       -> t2 + t3 mix      (Vol 2-3, levels 3-6)
    --   Zone 4       -> t3 + t4 mix      (Vol 3-5, levels 5-10)
    --   Zone 5       -> t4 only          (Vol 4-5, levels 7-10)
    -- Misc (Literature, RecipeResource) available in all zones.
    -- =========================================================
    pool_shedsandcommoners_t1 = {
        zones = {
            difficulty = {1, 2}
        },
        sources = {
            groups = {"skill_books_t1"}
        }
    },
    pool_shedsandcommoners_t2 = {
        zones = {
            difficulty = {2, 3}
        },
        sources = {
            groups = {"skill_books_t2"}
        }
    },
    pool_shedsandcommoners_t3 = {
        zones = {
            difficulty = {3, 4}
        },
        sources = {
            groups = {"skill_books_t3"}
        }
    },
    pool_shedsandcommoners_t4 = {
        zones = {
            difficulty = {4}
        },
        sources = {
            groups = {"skill_books_t4"}
        }
    },
    pool_shedsandcommoners_misc = {
        sources = {
            groups = {"skill_books_misc"}
        }
    }

}
