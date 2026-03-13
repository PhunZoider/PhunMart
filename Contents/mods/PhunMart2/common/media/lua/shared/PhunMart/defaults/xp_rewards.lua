return {

    ---------------------------------------------------------------------------
    -- TEMPLATES
    ---------------------------------------------------------------------------
    xp_reward_t1_base = {
        template = true,
        kind = "skill",
        category = "xp_t1",
        display = {
            texture = "media/textures/icons/xp_t1.png",
            overlay = "media/textures/plus-1.png"
        }
    },
    xp_reward_t2_base = {
        template = true,
        kind = "skill",
        category = "xp_t2",
        display = {
            texture = "media/textures/icons/xp_t2.png",
            overlay = "media/textures/plus-2.png"
        }
    },
    xp_reward_t3_base = {
        template = true,
        kind = "skill",
        category = "xp_t3",
        display = {
            texture = "media/textures/icons/xp_t3.png",
            overlay = "media/textures/plus-3.png"
        }
    },
    boost_reward_t1_base = {
        template = true,
        kind = "boost",
        category = "boost_t1",
        display = {
            texture = "media/textures/icons/boost.png",
            overlay = "media/textures/boost-1.png"
        }
    },
    boost_reward_t2_base = {
        template = true,
        kind = "boost",
        category = "boost_t2",
        display = {
            texture = "media/textures/icons/boost.png",
            overlay = "media/textures/boost-2.png"
        }
    },
    boost_reward_t3_base = {
        template = true,
        kind = "boost",
        category = "boost_t3",
        display = {
            texture = "media/textures/icons/boost.png",
            overlay = "media/textures/boost-3.png"
        }
    },

    ---------------------------------------------------------------------------
    -- Cooking
    ---------------------------------------------------------------------------
    skill_Cooking_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Cooking XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Cooking",
            amount = 75
        }}
    },
    skill_Cooking_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Cooking XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Cooking",
            amount = 250
        }}
    },
    skill_Cooking_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Cooking XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Cooking",
            amount = 750
        }}
    },
    boost_Cooking = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Cooking Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Cooking",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Fitness
    ---------------------------------------------------------------------------
    skill_Fitness_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Fitness XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Fitness",
            amount = 75
        }}
    },
    skill_Fitness_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Fitness XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Fitness",
            amount = 250
        }}
    },
    skill_Fitness_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Fitness XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Fitness",
            amount = 750
        }}
    },
    boost_Fitness = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Fitness Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Fitness",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Strength
    ---------------------------------------------------------------------------
    skill_Strength_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Strength XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Strength",
            amount = 75
        }}
    },
    skill_Strength_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Strength XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Strength",
            amount = 250
        }}
    },
    skill_Strength_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Strength XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Strength",
            amount = 750
        }}
    },
    boost_Strength = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Strength Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Strength",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Blunt (Long Blunt)
    ---------------------------------------------------------------------------
    skill_Blunt_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Long Blunt XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Blunt",
            amount = 75
        }}
    },
    skill_Blunt_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Long Blunt XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Blunt",
            amount = 250
        }}
    },
    skill_Blunt_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Long Blunt XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Blunt",
            amount = 750
        }}
    },
    boost_Blunt = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Long Blunt Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Blunt",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Axe
    ---------------------------------------------------------------------------
    skill_Axe_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Axe XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Axe",
            amount = 75
        }}
    },
    skill_Axe_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Axe XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Axe",
            amount = 250
        }}
    },
    skill_Axe_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Axe XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Axe",
            amount = 750
        }}
    },
    boost_Axe = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Axe Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Axe",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Lightfoot (Lightfooted)
    ---------------------------------------------------------------------------
    skill_Lightfoot_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Lightfooted XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Lightfoot",
            amount = 75
        }}
    },
    skill_Lightfoot_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Lightfooted XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Lightfoot",
            amount = 250
        }}
    },
    skill_Lightfoot_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Lightfooted XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Lightfoot",
            amount = 750
        }}
    },
    boost_Lightfoot = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Lightfooted Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Lightfoot",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Nimble
    ---------------------------------------------------------------------------
    skill_Nimble_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Nimble XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Nimble",
            amount = 75
        }}
    },
    skill_Nimble_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Nimble XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Nimble",
            amount = 250
        }}
    },
    skill_Nimble_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Nimble XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Nimble",
            amount = 750
        }}
    },
    boost_Nimble = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Nimble Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Nimble",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Sprinting (Running)
    ---------------------------------------------------------------------------
    skill_Sprinting_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Running XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Sprinting",
            amount = 75
        }}
    },
    skill_Sprinting_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Running XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Sprinting",
            amount = 250
        }}
    },
    skill_Sprinting_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Running XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Sprinting",
            amount = 750
        }}
    },
    boost_Sprinting = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Running Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Sprinting",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Sneak (Sneaking)
    ---------------------------------------------------------------------------
    skill_Sneak_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Sneaking XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Sneak",
            amount = 75
        }}
    },
    skill_Sneak_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Sneaking XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Sneak",
            amount = 250
        }}
    },
    skill_Sneak_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Sneaking XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Sneak",
            amount = 750
        }}
    },
    boost_Sneak = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Sneaking Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Sneak",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Woodwork (Carpentry)
    ---------------------------------------------------------------------------
    skill_Woodwork_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Carpentry XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Woodwork",
            amount = 75
        }}
    },
    skill_Woodwork_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Carpentry XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Woodwork",
            amount = 250
        }}
    },
    skill_Woodwork_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Carpentry XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Woodwork",
            amount = 750
        }}
    },
    boost_Woodwork = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Carpentry Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Woodwork",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Aiming
    ---------------------------------------------------------------------------
    skill_Aiming_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Aiming XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Aiming",
            amount = 75
        }}
    },
    skill_Aiming_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Aiming XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Aiming",
            amount = 250
        }}
    },
    skill_Aiming_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Aiming XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Aiming",
            amount = 750
        }}
    },
    boost_Aiming = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Aiming Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Aiming",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Reloading
    ---------------------------------------------------------------------------
    skill_Reloading_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Reloading XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Reloading",
            amount = 75
        }}
    },
    skill_Reloading_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Reloading XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Reloading",
            amount = 250
        }}
    },
    skill_Reloading_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Reloading XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Reloading",
            amount = 750
        }}
    },
    boost_Reloading = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Reloading Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Reloading",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Farming (Agriculture)
    ---------------------------------------------------------------------------
    skill_Farming_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Agriculture XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Farming",
            amount = 75
        }}
    },
    skill_Farming_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Agriculture XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Farming",
            amount = 250
        }}
    },
    skill_Farming_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Agriculture XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Farming",
            amount = 750
        }}
    },
    boost_Farming = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Agriculture Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Farming",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Fishing
    ---------------------------------------------------------------------------
    skill_Fishing_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Fishing XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Fishing",
            amount = 75
        }}
    },
    skill_Fishing_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Fishing XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Fishing",
            amount = 250
        }}
    },
    skill_Fishing_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Fishing XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Fishing",
            amount = 750
        }}
    },
    boost_Fishing = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Fishing Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Fishing",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Trapping
    ---------------------------------------------------------------------------
    skill_Trapping_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Trapping XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Trapping",
            amount = 75
        }}
    },
    skill_Trapping_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Trapping XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Trapping",
            amount = 250
        }}
    },
    skill_Trapping_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Trapping XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Trapping",
            amount = 750
        }}
    },
    boost_Trapping = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Trapping Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Trapping",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- PlantScavenging (Foraging)
    ---------------------------------------------------------------------------
    skill_PlantScavenging_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Foraging XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "PlantScavenging",
            amount = 75
        }}
    },
    skill_PlantScavenging_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Foraging XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "PlantScavenging",
            amount = 250
        }}
    },
    skill_PlantScavenging_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Foraging XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "PlantScavenging",
            amount = 750
        }}
    },
    boost_PlantScavenging = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Foraging Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "PlantScavenging",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Doctor (First Aid)
    ---------------------------------------------------------------------------
    skill_Doctor_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "First Aid XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Doctor",
            amount = 75
        }}
    },
    skill_Doctor_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "First Aid XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Doctor",
            amount = 250
        }}
    },
    skill_Doctor_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "First Aid XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Doctor",
            amount = 750
        }}
    },
    boost_Doctor = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "First Aid Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Doctor",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Electricity (Electrical)
    ---------------------------------------------------------------------------
    skill_Electricity_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Electrical XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Electricity",
            amount = 75
        }}
    },
    skill_Electricity_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Electrical XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Electricity",
            amount = 250
        }}
    },
    skill_Electricity_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Electrical XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Electricity",
            amount = 750
        }}
    },
    boost_Electricity = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Electrical Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Electricity",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Blacksmith (Blacksmithing)
    ---------------------------------------------------------------------------
    skill_Blacksmith_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Blacksmithing XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Blacksmith",
            amount = 75
        }}
    },
    skill_Blacksmith_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Blacksmithing XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Blacksmith",
            amount = 250
        }}
    },
    skill_Blacksmith_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Blacksmithing XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Blacksmith",
            amount = 750
        }}
    },
    boost_Blacksmith = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Blacksmithing Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Blacksmith",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- MetalWelding (Welding)
    ---------------------------------------------------------------------------
    skill_MetalWelding_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Welding XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "MetalWelding",
            amount = 75
        }}
    },
    skill_MetalWelding_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Welding XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "MetalWelding",
            amount = 250
        }}
    },
    skill_MetalWelding_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Welding XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "MetalWelding",
            amount = 750
        }}
    },
    boost_MetalWelding = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Welding Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "MetalWelding",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Mechanics
    ---------------------------------------------------------------------------
    skill_Mechanics_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Mechanics XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Mechanics",
            amount = 75
        }}
    },
    skill_Mechanics_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Mechanics XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Mechanics",
            amount = 250
        }}
    },
    skill_Mechanics_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Mechanics XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Mechanics",
            amount = 750
        }}
    },
    boost_Mechanics = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Mechanics Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Mechanics",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Spear
    ---------------------------------------------------------------------------
    skill_Spear_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Spear XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Spear",
            amount = 75
        }}
    },
    skill_Spear_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Spear XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Spear",
            amount = 250
        }}
    },
    skill_Spear_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Spear XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Spear",
            amount = 750
        }}
    },
    boost_Spear = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Spear Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Spear",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Maintenance
    ---------------------------------------------------------------------------
    skill_Maintenance_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Maintenance XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Maintenance",
            amount = 75
        }}
    },
    skill_Maintenance_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Maintenance XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Maintenance",
            amount = 250
        }}
    },
    skill_Maintenance_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Maintenance XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Maintenance",
            amount = 750
        }}
    },
    boost_Maintenance = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Maintenance Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Maintenance",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- SmallBlade (Short Blade)
    ---------------------------------------------------------------------------
    skill_SmallBlade_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Short Blade XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "SmallBlade",
            amount = 75
        }}
    },
    skill_SmallBlade_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Short Blade XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "SmallBlade",
            amount = 250
        }}
    },
    skill_SmallBlade_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Short Blade XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "SmallBlade",
            amount = 750
        }}
    },
    boost_SmallBlade = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Short Blade Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "SmallBlade",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- LongBlade (Long Blade)
    ---------------------------------------------------------------------------
    skill_LongBlade_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Long Blade XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "LongBlade",
            amount = 75
        }}
    },
    skill_LongBlade_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Long Blade XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "LongBlade",
            amount = 250
        }}
    },
    skill_LongBlade_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Long Blade XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "LongBlade",
            amount = 750
        }}
    },
    boost_LongBlade = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Long Blade Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "LongBlade",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- SmallBlunt (Short Blunt)
    ---------------------------------------------------------------------------
    skill_SmallBlunt_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Short Blunt XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "SmallBlunt",
            amount = 75
        }}
    },
    skill_SmallBlunt_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Short Blunt XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "SmallBlunt",
            amount = 250
        }}
    },
    skill_SmallBlunt_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Short Blunt XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "SmallBlunt",
            amount = 750
        }}
    },
    boost_SmallBlunt = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Short Blunt Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "SmallBlunt",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Tailoring
    ---------------------------------------------------------------------------
    skill_Tailoring_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Tailoring XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Tailoring",
            amount = 75
        }}
    },
    skill_Tailoring_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Tailoring XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Tailoring",
            amount = 250
        }}
    },
    skill_Tailoring_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Tailoring XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Tailoring",
            amount = 750
        }}
    },
    boost_Tailoring = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Tailoring Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Tailoring",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Tracking
    ---------------------------------------------------------------------------
    skill_Tracking_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Tracking XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Tracking",
            amount = 75
        }}
    },
    skill_Tracking_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Tracking XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Tracking",
            amount = 250
        }}
    },
    skill_Tracking_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Tracking XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Tracking",
            amount = 750
        }}
    },
    boost_Tracking = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Tracking Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Tracking",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Husbandry (Animal Care)
    ---------------------------------------------------------------------------
    skill_Husbandry_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Animal Care XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Husbandry",
            amount = 75
        }}
    },
    skill_Husbandry_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Animal Care XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Husbandry",
            amount = 250
        }}
    },
    skill_Husbandry_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Animal Care XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Husbandry",
            amount = 750
        }}
    },
    boost_Husbandry = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Animal Care Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Husbandry",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- FlintKnapping (Knapping)
    ---------------------------------------------------------------------------
    skill_FlintKnapping_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Knapping XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "FlintKnapping",
            amount = 75
        }}
    },
    skill_FlintKnapping_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Knapping XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "FlintKnapping",
            amount = 250
        }}
    },
    skill_FlintKnapping_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Knapping XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "FlintKnapping",
            amount = 750
        }}
    },
    boost_FlintKnapping = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Knapping Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "FlintKnapping",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Masonry
    ---------------------------------------------------------------------------
    skill_Masonry_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Masonry XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Masonry",
            amount = 75
        }}
    },
    skill_Masonry_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Masonry XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Masonry",
            amount = 250
        }}
    },
    skill_Masonry_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Masonry XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Masonry",
            amount = 750
        }}
    },
    boost_Masonry = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Masonry Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Masonry",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Pottery
    ---------------------------------------------------------------------------
    skill_Pottery_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Pottery XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Pottery",
            amount = 75
        }}
    },
    skill_Pottery_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Pottery XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Pottery",
            amount = 250
        }}
    },
    skill_Pottery_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Pottery XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Pottery",
            amount = 750
        }}
    },
    boost_Pottery = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Pottery Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Pottery",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Carving
    ---------------------------------------------------------------------------
    skill_Carving_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Carving XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Carving",
            amount = 75
        }}
    },
    skill_Carving_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Carving XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Carving",
            amount = 250
        }}
    },
    skill_Carving_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Carving XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Carving",
            amount = 750
        }}
    },
    boost_Carving = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Carving Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Carving",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Butchering
    ---------------------------------------------------------------------------
    skill_Butchering_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Butchering XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Butchering",
            amount = 75
        }}
    },
    skill_Butchering_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Butchering XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Butchering",
            amount = 250
        }}
    },
    skill_Butchering_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Butchering XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Butchering",
            amount = 750
        }}
    },
    boost_Butchering = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Butchering Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Butchering",
            multiplier = 1,
            hours = 24
        }}
    },

    ---------------------------------------------------------------------------
    -- Glassmaking
    ---------------------------------------------------------------------------
    skill_Glassmaking_t1 = {
        inherit = "xp_reward_t1_base",
        display = {
            text = "Glassmaking XP (small)"
        },
        actions = {{
            type = "giveXP",
            skill = "Glassmaking",
            amount = 75
        }}
    },
    skill_Glassmaking_t2 = {
        inherit = "xp_reward_t2_base",
        display = {
            text = "Glassmaking XP (medium)"
        },
        actions = {{
            type = "giveXP",
            skill = "Glassmaking",
            amount = 250
        }}
    },
    skill_Glassmaking_t3 = {
        inherit = "xp_reward_t3_base",
        display = {
            text = "Glassmaking XP (large)"
        },
        actions = {{
            type = "giveXP",
            skill = "Glassmaking",
            amount = 750
        }}
    },
    boost_Glassmaking = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Glassmaking Boost (basic)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Glassmaking",
            multiplier = 1
        }}
    },

    ---------------------------------------------------------------------------
    -- TIER 2 BOOST REWARDS (enhanced — setPerkBoost level 2, 100% XP bonus)
    ---------------------------------------------------------------------------
    boost_Cooking_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Cooking Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Cooking",
            multiplier = 2
        }}
    },
    boost_Fitness_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Fitness Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Fitness",
            multiplier = 2
        }}
    },
    boost_Strength_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Strength Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Strength",
            multiplier = 2
        }}
    },
    boost_Blunt_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Blunt Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Blunt",
            multiplier = 2
        }}
    },
    boost_Axe_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Axe Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Axe",
            multiplier = 2
        }}
    },
    boost_Lightfoot_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Lightfoot Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Lightfoot",
            multiplier = 2
        }}
    },
    boost_Nimble_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Nimble Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Nimble",
            multiplier = 2
        }}
    },
    boost_Sprinting_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Sprinting Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Sprinting",
            multiplier = 2
        }}
    },
    boost_Sneak_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Sneak Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Sneak",
            multiplier = 2
        }}
    },
    boost_Woodwork_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Woodwork Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Woodwork",
            multiplier = 2
        }}
    },
    boost_Aiming_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Aiming Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Aiming",
            multiplier = 2
        }}
    },
    boost_Reloading_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Reloading Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Reloading",
            multiplier = 2
        }}
    },
    boost_Farming_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Farming Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Farming",
            multiplier = 2
        }}
    },
    boost_Fishing_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Fishing Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Fishing",
            multiplier = 2
        }}
    },
    boost_Trapping_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Trapping Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Trapping",
            multiplier = 2
        }}
    },
    boost_PlantScavenging_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Foraging Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "PlantScavenging",
            multiplier = 2
        }}
    },
    boost_Doctor_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "First Aid Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Doctor",
            multiplier = 2
        }}
    },
    boost_Electricity_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Electrical Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Electricity",
            multiplier = 2
        }}
    },
    boost_Blacksmith_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Blacksmithing Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Blacksmith",
            multiplier = 2
        }}
    },
    boost_MetalWelding_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Welding Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "MetalWelding",
            multiplier = 2
        }}
    },
    boost_Mechanics_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Mechanics Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Mechanics",
            multiplier = 2
        }}
    },
    boost_Spear_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Spear Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Spear",
            multiplier = 2
        }}
    },
    boost_Maintenance_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Maintenance Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Maintenance",
            multiplier = 2
        }}
    },
    boost_SmallBlade_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Short Blade Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "SmallBlade",
            multiplier = 2
        }}
    },
    boost_LongBlade_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Long Blade Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "LongBlade",
            multiplier = 2
        }}
    },
    boost_SmallBlunt_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Short Blunt Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "SmallBlunt",
            multiplier = 2
        }}
    },
    boost_Tailoring_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Tailoring Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Tailoring",
            multiplier = 2
        }}
    },
    boost_Tracking_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Tracking Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Tracking",
            multiplier = 2
        }}
    },
    boost_Husbandry_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Husbandry Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Husbandry",
            multiplier = 2
        }}
    },
    boost_FlintKnapping_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Knapping Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "FlintKnapping",
            multiplier = 2
        }}
    },
    boost_Masonry_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Masonry Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Masonry",
            multiplier = 2
        }}
    },
    boost_Pottery_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Pottery Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Pottery",
            multiplier = 2
        }}
    },
    boost_Carving_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Carving Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Carving",
            multiplier = 2
        }}
    },
    boost_Butchering_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Butchering Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Butchering",
            multiplier = 2
        }}
    },
    boost_Glassmaking_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Glassmaking Boost (enhanced)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Glassmaking",
            multiplier = 2
        }}
    },

    ---------------------------------------------------------------------------
    -- TIER 3 BOOST REWARDS (superior — setPerkBoost level 3, 125% XP bonus)
    ---------------------------------------------------------------------------
    boost_Cooking_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Cooking Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Cooking",
            multiplier = 3
        }}
    },
    boost_Fitness_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Fitness Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Fitness",
            multiplier = 3
        }}
    },
    boost_Strength_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Strength Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Strength",
            multiplier = 3
        }}
    },
    boost_Blunt_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Blunt Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Blunt",
            multiplier = 3
        }}
    },
    boost_Axe_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Axe Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Axe",
            multiplier = 3
        }}
    },
    boost_Lightfoot_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Lightfoot Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Lightfoot",
            multiplier = 3
        }}
    },
    boost_Nimble_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Nimble Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Nimble",
            multiplier = 3
        }}
    },
    boost_Sprinting_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Sprinting Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Sprinting",
            multiplier = 3
        }}
    },
    boost_Sneak_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Sneak Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Sneak",
            multiplier = 3
        }}
    },
    boost_Woodwork_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Woodwork Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Woodwork",
            multiplier = 3
        }}
    },
    boost_Aiming_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Aiming Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Aiming",
            multiplier = 3
        }}
    },
    boost_Reloading_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Reloading Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Reloading",
            multiplier = 3
        }}
    },
    boost_Farming_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Farming Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Farming",
            multiplier = 3
        }}
    },
    boost_Fishing_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Fishing Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Fishing",
            multiplier = 3
        }}
    },
    boost_Trapping_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Trapping Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Trapping",
            multiplier = 3
        }}
    },
    boost_PlantScavenging_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Foraging Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "PlantScavenging",
            multiplier = 3
        }}
    },
    boost_Doctor_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "First Aid Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Doctor",
            multiplier = 3
        }}
    },
    boost_Electricity_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Electrical Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Electricity",
            multiplier = 3
        }}
    },
    boost_Blacksmith_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Blacksmithing Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Blacksmith",
            multiplier = 3
        }}
    },
    boost_MetalWelding_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Welding Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "MetalWelding",
            multiplier = 3
        }}
    },
    boost_Mechanics_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Mechanics Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Mechanics",
            multiplier = 3
        }}
    },
    boost_Spear_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Spear Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Spear",
            multiplier = 3
        }}
    },
    boost_Maintenance_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Maintenance Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Maintenance",
            multiplier = 3
        }}
    },
    boost_SmallBlade_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Short Blade Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "SmallBlade",
            multiplier = 3
        }}
    },
    boost_LongBlade_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Long Blade Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "LongBlade",
            multiplier = 3
        }}
    },
    boost_SmallBlunt_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Short Blunt Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "SmallBlunt",
            multiplier = 3
        }}
    },
    boost_Tailoring_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Tailoring Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Tailoring",
            multiplier = 3
        }}
    },
    boost_Tracking_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Tracking Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Tracking",
            multiplier = 3
        }}
    },
    boost_Husbandry_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Husbandry Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Husbandry",
            multiplier = 3
        }}
    },
    boost_FlintKnapping_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Knapping Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "FlintKnapping",
            multiplier = 3
        }}
    },
    boost_Masonry_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Masonry Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Masonry",
            multiplier = 3
        }}
    },
    boost_Pottery_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Pottery Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Pottery",
            multiplier = 3
        }}
    },
    boost_Carving_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Carving Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Carving",
            multiplier = 3
        }}
    },
    boost_Butchering_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Butchering Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Butchering",
            multiplier = 3
        }}
    },
    boost_Glassmaking_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Glassmaking Boost (superior)"
        },
        actions = {{
            type = "applyBoost",
            skill = "Glassmaking",
            multiplier = 3
        }}
    }

}
