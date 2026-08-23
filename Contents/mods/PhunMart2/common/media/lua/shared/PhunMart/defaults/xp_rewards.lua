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
        },
        price = "currency_low",
        offer = {
            weight = 1.0
        },
        actions = {{
            type = "giveXP",
            amount = 75
        }}
    },
    xp_reward_t2_base = {
        template = true,
        kind = "skill",
        category = "xp_t2",
        display = {
            texture = "media/textures/icons/xp_t2.png",
            overlay = "media/textures/plus-2.png"
        },
        price = "currency_mid",
        offer = {
            weight = 1.0
        },
        actions = {{
            type = "giveXP",
            amount = 250
        }}
    },
    xp_reward_t3_base = {
        template = true,
        kind = "skill",
        category = "xp_t3",
        display = {
            texture = "media/textures/icons/xp_t3.png",
            overlay = "media/textures/plus-3.png"
        },
        price = "currency_high",
        offer = {
            weight = 0.8
        },
        actions = {{
            type = "giveXP",
            amount = 750
        }}
    },
    boost_reward_t1_base = {
        template = true,
        kind = "boost",
        category = "boost_t1",
        display = {
            texture = "media/textures/icons/boost.png",
            overlay = "media/textures/boost-1.png"
        },
        price = "currency_boost",
        offer = {
            weight = 0.4,
            stock = {
                min = 1,
                max = 1,
                restockHours = 48
            }
        },
        -- No hours here, deliberately. It used to sit on 34 of the 35 tier one
        -- boosts and on none of the tiers above, and nothing ever read it:
        -- grantReward's applyBoost branch calls setPerkBoost(perk, level) and
        -- the game decides how long a boost lasts.
        actions = {{
            type = "applyBoost",
            multiplier = 1
        }}
    },
    boost_reward_t2_base = {
        template = true,
        kind = "boost",
        category = "boost_t2",
        display = {
            texture = "media/textures/icons/boost.png",
            overlay = "media/textures/boost-2.png"
        },
        price = "currency_boost_t2",
        offer = {
            weight = 0.4,
            stock = {
                min = 1,
                max = 1,
                restockHours = 48
            }
        },
        actions = {{
            type = "applyBoost",
            multiplier = 2
        }}
    },
    boost_reward_t3_base = {
        template = true,
        kind = "boost",
        category = "boost_t3",
        display = {
            texture = "media/textures/icons/boost.png",
            overlay = "media/textures/boost-3.png"
        },
        price = "currency_boost_t3",
        offer = {
            weight = 0.4,
            stock = {
                min = 1,
                max = 1,
                restockHours = 48
            }
        },
        actions = {{
            type = "applyBoost",
            multiplier = 3
        }}
    },

    ---------------------------------------------------------------------------
    -- Cooking
    ---------------------------------------------------------------------------
    skill_Cooking_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Cooking_lt3"},
        display = {
            text = "Cooking XP (small)"
        },
        actions = {{
            skill = "Cooking"
        }}
    },
    skill_Cooking_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Cooking_mid"},
        display = {
            text = "Cooking XP (medium)"
        },
        actions = {{
            skill = "Cooking"
        }}
    },
    skill_Cooking_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Cooking_high"},
        display = {
            text = "Cooking XP (large)"
        },
        actions = {{
            skill = "Cooking"
        }}
    },
    boost_Cooking = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Cooking Boost (basic)"
        },
        actions = {{
            skill = "Cooking"
        }}
    },

    ---------------------------------------------------------------------------
    -- Fitness
    ---------------------------------------------------------------------------
    skill_Fitness_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Fitness_lt3"},
        display = {
            text = "Fitness XP (small)"
        },
        actions = {{
            skill = "Fitness"
        }}
    },
    skill_Fitness_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Fitness_mid"},
        display = {
            text = "Fitness XP (medium)"
        },
        actions = {{
            skill = "Fitness"
        }}
    },
    skill_Fitness_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Fitness_high"},
        display = {
            text = "Fitness XP (large)"
        },
        actions = {{
            skill = "Fitness"
        }}
    },
    boost_Fitness = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Fitness Boost (basic)"
        },
        actions = {{
            skill = "Fitness"
        }}
    },

    ---------------------------------------------------------------------------
    -- Strength
    ---------------------------------------------------------------------------
    skill_Strength_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Strength_lt3"},
        display = {
            text = "Strength XP (small)"
        },
        actions = {{
            skill = "Strength"
        }}
    },
    skill_Strength_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Strength_mid"},
        display = {
            text = "Strength XP (medium)"
        },
        actions = {{
            skill = "Strength"
        }}
    },
    skill_Strength_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Strength_high"},
        display = {
            text = "Strength XP (large)"
        },
        actions = {{
            skill = "Strength"
        }}
    },
    boost_Strength = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Strength Boost (basic)"
        },
        actions = {{
            skill = "Strength"
        }}
    },

    ---------------------------------------------------------------------------
    -- Blunt (Long Blunt)
    ---------------------------------------------------------------------------
    skill_Blunt_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Blunt_lt3"},
        display = {
            text = "Long Blunt XP (small)"
        },
        actions = {{
            skill = "Blunt"
        }}
    },
    skill_Blunt_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Blunt_mid"},
        display = {
            text = "Long Blunt XP (medium)"
        },
        actions = {{
            skill = "Blunt"
        }}
    },
    skill_Blunt_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Blunt_high"},
        display = {
            text = "Long Blunt XP (large)"
        },
        actions = {{
            skill = "Blunt"
        }}
    },
    boost_Blunt = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Long Blunt Boost (basic)"
        },
        actions = {{
            skill = "Blunt"
        }}
    },

    ---------------------------------------------------------------------------
    -- Axe
    ---------------------------------------------------------------------------
    skill_Axe_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Axe_lt3"},
        display = {
            text = "Axe XP (small)"
        },
        actions = {{
            skill = "Axe"
        }}
    },
    skill_Axe_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Axe_mid"},
        display = {
            text = "Axe XP (medium)"
        },
        actions = {{
            skill = "Axe"
        }}
    },
    skill_Axe_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Axe_high"},
        display = {
            text = "Axe XP (large)"
        },
        actions = {{
            skill = "Axe"
        }}
    },
    boost_Axe = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Axe Boost (basic)"
        },
        actions = {{
            skill = "Axe"
        }}
    },

    ---------------------------------------------------------------------------
    -- Lightfoot (Lightfooted)
    ---------------------------------------------------------------------------
    skill_Lightfoot_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Lightfoot_lt3"},
        display = {
            text = "Lightfooted XP (small)"
        },
        actions = {{
            skill = "Lightfoot"
        }}
    },
    skill_Lightfoot_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Lightfoot_mid"},
        display = {
            text = "Lightfooted XP (medium)"
        },
        actions = {{
            skill = "Lightfoot"
        }}
    },
    skill_Lightfoot_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Lightfoot_high"},
        display = {
            text = "Lightfooted XP (large)"
        },
        actions = {{
            skill = "Lightfoot"
        }}
    },
    boost_Lightfoot = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Lightfooted Boost (basic)"
        },
        actions = {{
            skill = "Lightfoot"
        }}
    },

    ---------------------------------------------------------------------------
    -- Nimble
    ---------------------------------------------------------------------------
    skill_Nimble_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Nimble_lt3"},
        display = {
            text = "Nimble XP (small)"
        },
        actions = {{
            skill = "Nimble"
        }}
    },
    skill_Nimble_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Nimble_mid"},
        display = {
            text = "Nimble XP (medium)"
        },
        actions = {{
            skill = "Nimble"
        }}
    },
    skill_Nimble_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Nimble_high"},
        display = {
            text = "Nimble XP (large)"
        },
        actions = {{
            skill = "Nimble"
        }}
    },
    boost_Nimble = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Nimble Boost (basic)"
        },
        actions = {{
            skill = "Nimble"
        }}
    },

    ---------------------------------------------------------------------------
    -- Sprinting (Running)
    ---------------------------------------------------------------------------
    skill_Sprinting_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Sprinting_lt3"},
        display = {
            text = "Running XP (small)"
        },
        actions = {{
            skill = "Sprinting"
        }}
    },
    skill_Sprinting_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Sprinting_mid"},
        display = {
            text = "Running XP (medium)"
        },
        actions = {{
            skill = "Sprinting"
        }}
    },
    skill_Sprinting_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Sprinting_high"},
        display = {
            text = "Running XP (large)"
        },
        actions = {{
            skill = "Sprinting"
        }}
    },
    boost_Sprinting = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Running Boost (basic)"
        },
        actions = {{
            skill = "Sprinting"
        }}
    },

    ---------------------------------------------------------------------------
    -- Sneak (Sneaking)
    ---------------------------------------------------------------------------
    skill_Sneak_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Sneak_lt3"},
        display = {
            text = "Sneaking XP (small)"
        },
        actions = {{
            skill = "Sneak"
        }}
    },
    skill_Sneak_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Sneak_mid"},
        display = {
            text = "Sneaking XP (medium)"
        },
        actions = {{
            skill = "Sneak"
        }}
    },
    skill_Sneak_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Sneak_high"},
        display = {
            text = "Sneaking XP (large)"
        },
        actions = {{
            skill = "Sneak"
        }}
    },
    boost_Sneak = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Sneaking Boost (basic)"
        },
        actions = {{
            skill = "Sneak"
        }}
    },

    ---------------------------------------------------------------------------
    -- Woodwork (Carpentry)
    ---------------------------------------------------------------------------
    skill_Woodwork_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Woodwork_lt3"},
        display = {
            text = "Carpentry XP (small)"
        },
        actions = {{
            skill = "Woodwork"
        }}
    },
    skill_Woodwork_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Woodwork_mid"},
        display = {
            text = "Carpentry XP (medium)"
        },
        actions = {{
            skill = "Woodwork"
        }}
    },
    skill_Woodwork_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Woodwork_high"},
        display = {
            text = "Carpentry XP (large)"
        },
        actions = {{
            skill = "Woodwork"
        }}
    },
    boost_Woodwork = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Carpentry Boost (basic)"
        },
        actions = {{
            skill = "Woodwork"
        }}
    },

    ---------------------------------------------------------------------------
    -- Aiming
    ---------------------------------------------------------------------------
    skill_Aiming_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Aiming_lt3"},
        display = {
            text = "Aiming XP (small)"
        },
        actions = {{
            skill = "Aiming"
        }}
    },
    skill_Aiming_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Aiming_mid"},
        display = {
            text = "Aiming XP (medium)"
        },
        actions = {{
            skill = "Aiming"
        }}
    },
    skill_Aiming_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Aiming_high"},
        display = {
            text = "Aiming XP (large)"
        },
        actions = {{
            skill = "Aiming"
        }}
    },
    boost_Aiming = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Aiming Boost (basic)"
        },
        actions = {{
            skill = "Aiming"
        }}
    },

    ---------------------------------------------------------------------------
    -- Reloading
    ---------------------------------------------------------------------------
    skill_Reloading_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Reloading_lt3"},
        display = {
            text = "Reloading XP (small)"
        },
        actions = {{
            skill = "Reloading"
        }}
    },
    skill_Reloading_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Reloading_mid"},
        display = {
            text = "Reloading XP (medium)"
        },
        actions = {{
            skill = "Reloading"
        }}
    },
    skill_Reloading_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Reloading_high"},
        display = {
            text = "Reloading XP (large)"
        },
        actions = {{
            skill = "Reloading"
        }}
    },
    boost_Reloading = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Reloading Boost (basic)"
        },
        actions = {{
            skill = "Reloading"
        }}
    },

    ---------------------------------------------------------------------------
    -- Farming (Agriculture)
    ---------------------------------------------------------------------------
    skill_Farming_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Farming_lt3"},
        display = {
            text = "Agriculture XP (small)"
        },
        actions = {{
            skill = "Farming"
        }}
    },
    skill_Farming_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Farming_mid"},
        display = {
            text = "Agriculture XP (medium)"
        },
        actions = {{
            skill = "Farming"
        }}
    },
    skill_Farming_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Farming_high"},
        display = {
            text = "Agriculture XP (large)"
        },
        actions = {{
            skill = "Farming"
        }}
    },
    boost_Farming = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Agriculture Boost (basic)"
        },
        actions = {{
            skill = "Farming"
        }}
    },

    ---------------------------------------------------------------------------
    -- Fishing
    ---------------------------------------------------------------------------
    skill_Fishing_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Fishing_lt3"},
        display = {
            text = "Fishing XP (small)"
        },
        actions = {{
            skill = "Fishing"
        }}
    },
    skill_Fishing_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Fishing_mid"},
        display = {
            text = "Fishing XP (medium)"
        },
        actions = {{
            skill = "Fishing"
        }}
    },
    skill_Fishing_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Fishing_high"},
        display = {
            text = "Fishing XP (large)"
        },
        actions = {{
            skill = "Fishing"
        }}
    },
    boost_Fishing = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Fishing Boost (basic)"
        },
        actions = {{
            skill = "Fishing"
        }}
    },

    ---------------------------------------------------------------------------
    -- Trapping
    ---------------------------------------------------------------------------
    skill_Trapping_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Trapping_lt3"},
        display = {
            text = "Trapping XP (small)"
        },
        actions = {{
            skill = "Trapping"
        }}
    },
    skill_Trapping_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Trapping_mid"},
        display = {
            text = "Trapping XP (medium)"
        },
        actions = {{
            skill = "Trapping"
        }}
    },
    skill_Trapping_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Trapping_high"},
        display = {
            text = "Trapping XP (large)"
        },
        actions = {{
            skill = "Trapping"
        }}
    },
    boost_Trapping = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Trapping Boost (basic)"
        },
        actions = {{
            skill = "Trapping"
        }}
    },

    ---------------------------------------------------------------------------
    -- PlantScavenging (Foraging)
    ---------------------------------------------------------------------------
    skill_PlantScavenging_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_PlantScavenging_lt3"},
        display = {
            text = "Foraging XP (small)"
        },
        actions = {{
            skill = "PlantScavenging"
        }}
    },
    skill_PlantScavenging_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_PlantScavenging_mid"},
        display = {
            text = "Foraging XP (medium)"
        },
        actions = {{
            skill = "PlantScavenging"
        }}
    },
    skill_PlantScavenging_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_PlantScavenging_high"},
        display = {
            text = "Foraging XP (large)"
        },
        actions = {{
            skill = "PlantScavenging"
        }}
    },
    boost_PlantScavenging = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Foraging Boost (basic)"
        },
        actions = {{
            skill = "PlantScavenging"
        }}
    },

    ---------------------------------------------------------------------------
    -- Doctor (First Aid)
    ---------------------------------------------------------------------------
    skill_Doctor_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Doctor_lt3"},
        display = {
            text = "First Aid XP (small)"
        },
        actions = {{
            skill = "Doctor"
        }}
    },
    skill_Doctor_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Doctor_mid"},
        display = {
            text = "First Aid XP (medium)"
        },
        actions = {{
            skill = "Doctor"
        }}
    },
    skill_Doctor_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Doctor_high"},
        display = {
            text = "First Aid XP (large)"
        },
        actions = {{
            skill = "Doctor"
        }}
    },
    boost_Doctor = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "First Aid Boost (basic)"
        },
        actions = {{
            skill = "Doctor"
        }}
    },

    ---------------------------------------------------------------------------
    -- Electricity (Electrical)
    ---------------------------------------------------------------------------
    skill_Electricity_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Electricity_lt3"},
        display = {
            text = "Electrical XP (small)"
        },
        actions = {{
            skill = "Electricity"
        }}
    },
    skill_Electricity_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Electricity_mid"},
        display = {
            text = "Electrical XP (medium)"
        },
        actions = {{
            skill = "Electricity"
        }}
    },
    skill_Electricity_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Electricity_high"},
        display = {
            text = "Electrical XP (large)"
        },
        actions = {{
            skill = "Electricity"
        }}
    },
    boost_Electricity = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Electrical Boost (basic)"
        },
        actions = {{
            skill = "Electricity"
        }}
    },

    ---------------------------------------------------------------------------
    -- Blacksmith (Blacksmithing)
    ---------------------------------------------------------------------------
    skill_Blacksmith_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Blacksmith_lt3"},
        display = {
            text = "Blacksmithing XP (small)"
        },
        actions = {{
            skill = "Blacksmith"
        }}
    },
    skill_Blacksmith_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Blacksmith_mid"},
        display = {
            text = "Blacksmithing XP (medium)"
        },
        actions = {{
            skill = "Blacksmith"
        }}
    },
    skill_Blacksmith_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Blacksmith_high"},
        display = {
            text = "Blacksmithing XP (large)"
        },
        actions = {{
            skill = "Blacksmith"
        }}
    },
    boost_Blacksmith = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Blacksmithing Boost (basic)"
        },
        actions = {{
            skill = "Blacksmith"
        }}
    },

    ---------------------------------------------------------------------------
    -- MetalWelding (Welding)
    ---------------------------------------------------------------------------
    skill_MetalWelding_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_MetalWelding_lt3"},
        display = {
            text = "Welding XP (small)"
        },
        actions = {{
            skill = "MetalWelding"
        }}
    },
    skill_MetalWelding_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_MetalWelding_mid"},
        display = {
            text = "Welding XP (medium)"
        },
        actions = {{
            skill = "MetalWelding"
        }}
    },
    skill_MetalWelding_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_MetalWelding_high"},
        display = {
            text = "Welding XP (large)"
        },
        actions = {{
            skill = "MetalWelding"
        }}
    },
    boost_MetalWelding = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Welding Boost (basic)"
        },
        actions = {{
            skill = "MetalWelding"
        }}
    },

    ---------------------------------------------------------------------------
    -- Mechanics
    ---------------------------------------------------------------------------
    skill_Mechanics_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Mechanics_lt3"},
        display = {
            text = "Mechanics XP (small)"
        },
        actions = {{
            skill = "Mechanics"
        }}
    },
    skill_Mechanics_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Mechanics_mid"},
        display = {
            text = "Mechanics XP (medium)"
        },
        actions = {{
            skill = "Mechanics"
        }}
    },
    skill_Mechanics_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Mechanics_high"},
        display = {
            text = "Mechanics XP (large)"
        },
        actions = {{
            skill = "Mechanics"
        }}
    },
    boost_Mechanics = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Mechanics Boost (basic)"
        },
        actions = {{
            skill = "Mechanics"
        }}
    },

    ---------------------------------------------------------------------------
    -- Spear
    ---------------------------------------------------------------------------
    skill_Spear_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Spear_lt3"},
        display = {
            text = "Spear XP (small)"
        },
        actions = {{
            skill = "Spear"
        }}
    },
    skill_Spear_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Spear_mid"},
        display = {
            text = "Spear XP (medium)"
        },
        actions = {{
            skill = "Spear"
        }}
    },
    skill_Spear_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Spear_high"},
        display = {
            text = "Spear XP (large)"
        },
        actions = {{
            skill = "Spear"
        }}
    },
    boost_Spear = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Spear Boost (basic)"
        },
        actions = {{
            skill = "Spear"
        }}
    },

    ---------------------------------------------------------------------------
    -- Maintenance
    ---------------------------------------------------------------------------
    skill_Maintenance_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Maintenance_lt3"},
        display = {
            text = "Maintenance XP (small)"
        },
        actions = {{
            skill = "Maintenance"
        }}
    },
    skill_Maintenance_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Maintenance_mid"},
        display = {
            text = "Maintenance XP (medium)"
        },
        actions = {{
            skill = "Maintenance"
        }}
    },
    skill_Maintenance_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Maintenance_high"},
        display = {
            text = "Maintenance XP (large)"
        },
        actions = {{
            skill = "Maintenance"
        }}
    },
    boost_Maintenance = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Maintenance Boost (basic)"
        },
        actions = {{
            skill = "Maintenance"
        }}
    },

    ---------------------------------------------------------------------------
    -- SmallBlade (Short Blade)
    ---------------------------------------------------------------------------
    skill_SmallBlade_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_SmallBlade_lt3"},
        display = {
            text = "Short Blade XP (small)"
        },
        actions = {{
            skill = "SmallBlade"
        }}
    },
    skill_SmallBlade_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_SmallBlade_mid"},
        display = {
            text = "Short Blade XP (medium)"
        },
        actions = {{
            skill = "SmallBlade"
        }}
    },
    skill_SmallBlade_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_SmallBlade_high"},
        display = {
            text = "Short Blade XP (large)"
        },
        actions = {{
            skill = "SmallBlade"
        }}
    },
    boost_SmallBlade = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Short Blade Boost (basic)"
        },
        actions = {{
            skill = "SmallBlade"
        }}
    },

    ---------------------------------------------------------------------------
    -- LongBlade (Long Blade)
    ---------------------------------------------------------------------------
    skill_LongBlade_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_LongBlade_lt3"},
        display = {
            text = "Long Blade XP (small)"
        },
        actions = {{
            skill = "LongBlade"
        }}
    },
    skill_LongBlade_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_LongBlade_mid"},
        display = {
            text = "Long Blade XP (medium)"
        },
        actions = {{
            skill = "LongBlade"
        }}
    },
    skill_LongBlade_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_LongBlade_high"},
        display = {
            text = "Long Blade XP (large)"
        },
        actions = {{
            skill = "LongBlade"
        }}
    },
    boost_LongBlade = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Long Blade Boost (basic)"
        },
        actions = {{
            skill = "LongBlade"
        }}
    },

    ---------------------------------------------------------------------------
    -- SmallBlunt (Short Blunt)
    ---------------------------------------------------------------------------
    skill_SmallBlunt_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_SmallBlunt_lt3"},
        display = {
            text = "Short Blunt XP (small)"
        },
        actions = {{
            skill = "SmallBlunt"
        }}
    },
    skill_SmallBlunt_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_SmallBlunt_mid"},
        display = {
            text = "Short Blunt XP (medium)"
        },
        actions = {{
            skill = "SmallBlunt"
        }}
    },
    skill_SmallBlunt_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_SmallBlunt_high"},
        display = {
            text = "Short Blunt XP (large)"
        },
        actions = {{
            skill = "SmallBlunt"
        }}
    },
    boost_SmallBlunt = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Short Blunt Boost (basic)"
        },
        actions = {{
            skill = "SmallBlunt"
        }}
    },

    ---------------------------------------------------------------------------
    -- Tailoring
    ---------------------------------------------------------------------------
    skill_Tailoring_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Tailoring_lt3"},
        display = {
            text = "Tailoring XP (small)"
        },
        actions = {{
            skill = "Tailoring"
        }}
    },
    skill_Tailoring_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Tailoring_mid"},
        display = {
            text = "Tailoring XP (medium)"
        },
        actions = {{
            skill = "Tailoring"
        }}
    },
    skill_Tailoring_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Tailoring_high"},
        display = {
            text = "Tailoring XP (large)"
        },
        actions = {{
            skill = "Tailoring"
        }}
    },
    boost_Tailoring = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Tailoring Boost (basic)"
        },
        actions = {{
            skill = "Tailoring"
        }}
    },

    ---------------------------------------------------------------------------
    -- Tracking
    ---------------------------------------------------------------------------
    skill_Tracking_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Tracking_lt3"},
        display = {
            text = "Tracking XP (small)"
        },
        actions = {{
            skill = "Tracking"
        }}
    },
    skill_Tracking_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Tracking_mid"},
        display = {
            text = "Tracking XP (medium)"
        },
        actions = {{
            skill = "Tracking"
        }}
    },
    skill_Tracking_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Tracking_high"},
        display = {
            text = "Tracking XP (large)"
        },
        actions = {{
            skill = "Tracking"
        }}
    },
    boost_Tracking = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Tracking Boost (basic)"
        },
        actions = {{
            skill = "Tracking"
        }}
    },

    ---------------------------------------------------------------------------
    -- Husbandry (Animal Care)
    ---------------------------------------------------------------------------
    skill_Husbandry_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Husbandry_lt3"},
        display = {
            text = "Animal Care XP (small)"
        },
        actions = {{
            skill = "Husbandry"
        }}
    },
    skill_Husbandry_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Husbandry_mid"},
        display = {
            text = "Animal Care XP (medium)"
        },
        actions = {{
            skill = "Husbandry"
        }}
    },
    skill_Husbandry_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Husbandry_high"},
        display = {
            text = "Animal Care XP (large)"
        },
        actions = {{
            skill = "Husbandry"
        }}
    },
    boost_Husbandry = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Animal Care Boost (basic)"
        },
        actions = {{
            skill = "Husbandry"
        }}
    },

    ---------------------------------------------------------------------------
    -- FlintKnapping (Knapping)
    ---------------------------------------------------------------------------
    skill_FlintKnapping_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_FlintKnapping_lt3"},
        display = {
            text = "Knapping XP (small)"
        },
        actions = {{
            skill = "FlintKnapping"
        }}
    },
    skill_FlintKnapping_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_FlintKnapping_mid"},
        display = {
            text = "Knapping XP (medium)"
        },
        actions = {{
            skill = "FlintKnapping"
        }}
    },
    skill_FlintKnapping_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_FlintKnapping_high"},
        display = {
            text = "Knapping XP (large)"
        },
        actions = {{
            skill = "FlintKnapping"
        }}
    },
    boost_FlintKnapping = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Knapping Boost (basic)"
        },
        actions = {{
            skill = "FlintKnapping"
        }}
    },

    ---------------------------------------------------------------------------
    -- Masonry
    ---------------------------------------------------------------------------
    skill_Masonry_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Masonry_lt3"},
        display = {
            text = "Masonry XP (small)"
        },
        actions = {{
            skill = "Masonry"
        }}
    },
    skill_Masonry_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Masonry_mid"},
        display = {
            text = "Masonry XP (medium)"
        },
        actions = {{
            skill = "Masonry"
        }}
    },
    skill_Masonry_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Masonry_high"},
        display = {
            text = "Masonry XP (large)"
        },
        actions = {{
            skill = "Masonry"
        }}
    },
    boost_Masonry = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Masonry Boost (basic)"
        },
        actions = {{
            skill = "Masonry"
        }}
    },

    ---------------------------------------------------------------------------
    -- Pottery
    ---------------------------------------------------------------------------
    skill_Pottery_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Pottery_lt3"},
        display = {
            text = "Pottery XP (small)"
        },
        actions = {{
            skill = "Pottery"
        }}
    },
    skill_Pottery_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Pottery_mid"},
        display = {
            text = "Pottery XP (medium)"
        },
        actions = {{
            skill = "Pottery"
        }}
    },
    skill_Pottery_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Pottery_high"},
        display = {
            text = "Pottery XP (large)"
        },
        actions = {{
            skill = "Pottery"
        }}
    },
    boost_Pottery = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Pottery Boost (basic)"
        },
        actions = {{
            skill = "Pottery"
        }}
    },

    ---------------------------------------------------------------------------
    -- Carving
    ---------------------------------------------------------------------------
    skill_Carving_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Carving_lt3"},
        display = {
            text = "Carving XP (small)"
        },
        actions = {{
            skill = "Carving"
        }}
    },
    skill_Carving_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Carving_mid"},
        display = {
            text = "Carving XP (medium)"
        },
        actions = {{
            skill = "Carving"
        }}
    },
    skill_Carving_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Carving_high"},
        display = {
            text = "Carving XP (large)"
        },
        actions = {{
            skill = "Carving"
        }}
    },
    boost_Carving = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Carving Boost (basic)"
        },
        actions = {{
            skill = "Carving"
        }}
    },

    ---------------------------------------------------------------------------
    -- Butchering
    ---------------------------------------------------------------------------
    skill_Butchering_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Butchering_lt3"},
        display = {
            text = "Butchering XP (small)"
        },
        actions = {{
            skill = "Butchering"
        }}
    },
    skill_Butchering_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Butchering_mid"},
        display = {
            text = "Butchering XP (medium)"
        },
        actions = {{
            skill = "Butchering"
        }}
    },
    skill_Butchering_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Butchering_high"},
        display = {
            text = "Butchering XP (large)"
        },
        actions = {{
            skill = "Butchering"
        }}
    },
    boost_Butchering = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Butchering Boost (basic)"
        },
        actions = {{
            skill = "Butchering"
        }}
    },

    ---------------------------------------------------------------------------
    -- Glassmaking
    ---------------------------------------------------------------------------
    skill_Glassmaking_t1 = {
        inherit = "xp_reward_t1_base",
        conditions = {"perk_Glassmaking_lt3"},
        display = {
            text = "Glassmaking XP (small)"
        },
        actions = {{
            skill = "Glassmaking"
        }}
    },
    skill_Glassmaking_t2 = {
        inherit = "xp_reward_t2_base",
        conditions = {"perk_Glassmaking_mid"},
        display = {
            text = "Glassmaking XP (medium)"
        },
        actions = {{
            skill = "Glassmaking"
        }}
    },
    skill_Glassmaking_t3 = {
        inherit = "xp_reward_t3_base",
        conditions = {"perk_Glassmaking_high"},
        display = {
            text = "Glassmaking XP (large)"
        },
        actions = {{
            skill = "Glassmaking"
        }}
    },
    boost_Glassmaking = {
        inherit = "boost_reward_t1_base",
        display = {
            text = "Glassmaking Boost (basic)"
        },
        actions = {{
            skill = "Glassmaking"
        }}
    },

    ---------------------------------------------------------------------------
    -- TIER 2 BOOST REWARDS (enhanced, setPerkBoost level 2, 100% XP bonus)
    ---------------------------------------------------------------------------
    boost_Cooking_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Cooking Boost (enhanced)"
        },
        actions = {{
            skill = "Cooking"
        }}
    },
    boost_Fitness_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Fitness Boost (enhanced)"
        },
        actions = {{
            skill = "Fitness"
        }}
    },
    boost_Strength_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Strength Boost (enhanced)"
        },
        actions = {{
            skill = "Strength"
        }}
    },
    boost_Blunt_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Blunt Boost (enhanced)"
        },
        actions = {{
            skill = "Blunt"
        }}
    },
    boost_Axe_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Axe Boost (enhanced)"
        },
        actions = {{
            skill = "Axe"
        }}
    },
    boost_Lightfoot_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Lightfoot Boost (enhanced)"
        },
        actions = {{
            skill = "Lightfoot"
        }}
    },
    boost_Nimble_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Nimble Boost (enhanced)"
        },
        actions = {{
            skill = "Nimble"
        }}
    },
    boost_Sprinting_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Sprinting Boost (enhanced)"
        },
        actions = {{
            skill = "Sprinting"
        }}
    },
    boost_Sneak_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Sneak Boost (enhanced)"
        },
        actions = {{
            skill = "Sneak"
        }}
    },
    boost_Woodwork_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Woodwork Boost (enhanced)"
        },
        actions = {{
            skill = "Woodwork"
        }}
    },
    boost_Aiming_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Aiming Boost (enhanced)"
        },
        actions = {{
            skill = "Aiming"
        }}
    },
    boost_Reloading_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Reloading Boost (enhanced)"
        },
        actions = {{
            skill = "Reloading"
        }}
    },
    boost_Farming_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Farming Boost (enhanced)"
        },
        actions = {{
            skill = "Farming"
        }}
    },
    boost_Fishing_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Fishing Boost (enhanced)"
        },
        actions = {{
            skill = "Fishing"
        }}
    },
    boost_Trapping_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Trapping Boost (enhanced)"
        },
        actions = {{
            skill = "Trapping"
        }}
    },
    boost_PlantScavenging_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Foraging Boost (enhanced)"
        },
        actions = {{
            skill = "PlantScavenging"
        }}
    },
    boost_Doctor_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "First Aid Boost (enhanced)"
        },
        actions = {{
            skill = "Doctor"
        }}
    },
    boost_Electricity_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Electrical Boost (enhanced)"
        },
        actions = {{
            skill = "Electricity"
        }}
    },
    boost_Blacksmith_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Blacksmithing Boost (enhanced)"
        },
        actions = {{
            skill = "Blacksmith"
        }}
    },
    boost_MetalWelding_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Welding Boost (enhanced)"
        },
        actions = {{
            skill = "MetalWelding"
        }}
    },
    boost_Mechanics_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Mechanics Boost (enhanced)"
        },
        actions = {{
            skill = "Mechanics"
        }}
    },
    boost_Spear_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Spear Boost (enhanced)"
        },
        actions = {{
            skill = "Spear"
        }}
    },
    boost_Maintenance_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Maintenance Boost (enhanced)"
        },
        actions = {{
            skill = "Maintenance"
        }}
    },
    boost_SmallBlade_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Short Blade Boost (enhanced)"
        },
        actions = {{
            skill = "SmallBlade"
        }}
    },
    boost_LongBlade_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Long Blade Boost (enhanced)"
        },
        actions = {{
            skill = "LongBlade"
        }}
    },
    boost_SmallBlunt_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Short Blunt Boost (enhanced)"
        },
        actions = {{
            skill = "SmallBlunt"
        }}
    },
    boost_Tailoring_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Tailoring Boost (enhanced)"
        },
        actions = {{
            skill = "Tailoring"
        }}
    },
    boost_Tracking_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Tracking Boost (enhanced)"
        },
        actions = {{
            skill = "Tracking"
        }}
    },
    boost_Husbandry_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Husbandry Boost (enhanced)"
        },
        actions = {{
            skill = "Husbandry"
        }}
    },
    boost_FlintKnapping_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Knapping Boost (enhanced)"
        },
        actions = {{
            skill = "FlintKnapping"
        }}
    },
    boost_Masonry_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Masonry Boost (enhanced)"
        },
        actions = {{
            skill = "Masonry"
        }}
    },
    boost_Pottery_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Pottery Boost (enhanced)"
        },
        actions = {{
            skill = "Pottery"
        }}
    },
    boost_Carving_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Carving Boost (enhanced)"
        },
        actions = {{
            skill = "Carving"
        }}
    },
    boost_Butchering_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Butchering Boost (enhanced)"
        },
        actions = {{
            skill = "Butchering"
        }}
    },
    boost_Glassmaking_t2 = {
        inherit = "boost_reward_t2_base",
        display = {
            text = "Glassmaking Boost (enhanced)"
        },
        actions = {{
            skill = "Glassmaking"
        }}
    },

    ---------------------------------------------------------------------------
    -- TIER 3 BOOST REWARDS (superior, setPerkBoost level 3, 125% XP bonus)
    ---------------------------------------------------------------------------
    boost_Cooking_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Cooking Boost (superior)"
        },
        actions = {{
            skill = "Cooking"
        }}
    },
    boost_Fitness_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Fitness Boost (superior)"
        },
        actions = {{
            skill = "Fitness"
        }}
    },
    boost_Strength_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Strength Boost (superior)"
        },
        actions = {{
            skill = "Strength"
        }}
    },
    boost_Blunt_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Blunt Boost (superior)"
        },
        actions = {{
            skill = "Blunt"
        }}
    },
    boost_Axe_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Axe Boost (superior)"
        },
        actions = {{
            skill = "Axe"
        }}
    },
    boost_Lightfoot_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Lightfoot Boost (superior)"
        },
        actions = {{
            skill = "Lightfoot"
        }}
    },
    boost_Nimble_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Nimble Boost (superior)"
        },
        actions = {{
            skill = "Nimble"
        }}
    },
    boost_Sprinting_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Sprinting Boost (superior)"
        },
        actions = {{
            skill = "Sprinting"
        }}
    },
    boost_Sneak_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Sneak Boost (superior)"
        },
        actions = {{
            skill = "Sneak"
        }}
    },
    boost_Woodwork_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Woodwork Boost (superior)"
        },
        actions = {{
            skill = "Woodwork"
        }}
    },
    boost_Aiming_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Aiming Boost (superior)"
        },
        actions = {{
            skill = "Aiming"
        }}
    },
    boost_Reloading_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Reloading Boost (superior)"
        },
        actions = {{
            skill = "Reloading"
        }}
    },
    boost_Farming_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Farming Boost (superior)"
        },
        actions = {{
            skill = "Farming"
        }}
    },
    boost_Fishing_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Fishing Boost (superior)"
        },
        actions = {{
            skill = "Fishing"
        }}
    },
    boost_Trapping_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Trapping Boost (superior)"
        },
        actions = {{
            skill = "Trapping"
        }}
    },
    boost_PlantScavenging_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Foraging Boost (superior)"
        },
        actions = {{
            skill = "PlantScavenging"
        }}
    },
    boost_Doctor_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "First Aid Boost (superior)"
        },
        actions = {{
            skill = "Doctor"
        }}
    },
    boost_Electricity_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Electrical Boost (superior)"
        },
        actions = {{
            skill = "Electricity"
        }}
    },
    boost_Blacksmith_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Blacksmithing Boost (superior)"
        },
        actions = {{
            skill = "Blacksmith"
        }}
    },
    boost_MetalWelding_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Welding Boost (superior)"
        },
        actions = {{
            skill = "MetalWelding"
        }}
    },
    boost_Mechanics_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Mechanics Boost (superior)"
        },
        actions = {{
            skill = "Mechanics"
        }}
    },
    boost_Spear_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Spear Boost (superior)"
        },
        actions = {{
            skill = "Spear"
        }}
    },
    boost_Maintenance_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Maintenance Boost (superior)"
        },
        actions = {{
            skill = "Maintenance"
        }}
    },
    boost_SmallBlade_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Short Blade Boost (superior)"
        },
        actions = {{
            skill = "SmallBlade"
        }}
    },
    boost_LongBlade_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Long Blade Boost (superior)"
        },
        actions = {{
            skill = "LongBlade"
        }}
    },
    boost_SmallBlunt_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Short Blunt Boost (superior)"
        },
        actions = {{
            skill = "SmallBlunt"
        }}
    },
    boost_Tailoring_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Tailoring Boost (superior)"
        },
        actions = {{
            skill = "Tailoring"
        }}
    },
    boost_Tracking_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Tracking Boost (superior)"
        },
        actions = {{
            skill = "Tracking"
        }}
    },
    boost_Husbandry_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Husbandry Boost (superior)"
        },
        actions = {{
            skill = "Husbandry"
        }}
    },
    boost_FlintKnapping_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Knapping Boost (superior)"
        },
        actions = {{
            skill = "FlintKnapping"
        }}
    },
    boost_Masonry_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Masonry Boost (superior)"
        },
        actions = {{
            skill = "Masonry"
        }}
    },
    boost_Pottery_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Pottery Boost (superior)"
        },
        actions = {{
            skill = "Pottery"
        }}
    },
    boost_Carving_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Carving Boost (superior)"
        },
        actions = {{
            skill = "Carving"
        }}
    },
    boost_Butchering_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Butchering Boost (superior)"
        },
        actions = {{
            skill = "Butchering"
        }}
    },
    boost_Glassmaking_t3 = {
        inherit = "boost_reward_t3_base",
        display = {
            text = "Glassmaking Boost (superior)"
        },
        actions = {{
            skill = "Glassmaking"
        }}
    },

}
