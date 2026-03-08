return {

    ---------------------------------------------------------------------------
    -- Base templates
    ---------------------------------------------------------------------------

    xp_t1_base = {
        template = true,
        offer = {
            weight = 1.0
        }
    },
    xp_t2_base = {
        template = true,
        offer = {
            weight = 1.0
        }
    },
    xp_t3_base = {
        template = true,
        offer = {
            weight = 0.8
        }
    },
    boost_base_xp = {
        template = true,
        offer = {
            weight = 0.4,
            stock = {
                min = 0,
                max = 1,
                restockHours = 48
            }
        }
    },

    ---------------------------------------------------------------------------
    -- Cooking
    ---------------------------------------------------------------------------
    xp_Cooking_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Cooking_t1",
        conditions = {"perk_Cooking_lt3"}
    },
    xp_Cooking_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Cooking_t2",
        conditions = {"perk_Cooking_mid"}
    },
    xp_Cooking_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Cooking_t3",
        conditions = {"perk_Cooking_high"}
    },
    boost_Cooking = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Cooking"
    },

    ---------------------------------------------------------------------------
    -- Fitness
    ---------------------------------------------------------------------------
    xp_Fitness_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Fitness_t1",
        conditions = {"perk_Fitness_lt3"}
    },
    xp_Fitness_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Fitness_t2",
        conditions = {"perk_Fitness_mid"}
    },
    xp_Fitness_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Fitness_t3",
        conditions = {"perk_Fitness_high"}
    },
    boost_Fitness = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Fitness"
    },

    ---------------------------------------------------------------------------
    -- Strength
    ---------------------------------------------------------------------------
    xp_Strength_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Strength_t1",
        conditions = {"perk_Strength_lt3"}
    },
    xp_Strength_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Strength_t2",
        conditions = {"perk_Strength_mid"}
    },
    xp_Strength_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Strength_t3",
        conditions = {"perk_Strength_high"}
    },
    boost_Strength = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Strength"
    },

    ---------------------------------------------------------------------------
    -- Blunt (Long Blunt)
    ---------------------------------------------------------------------------
    xp_Blunt_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Blunt_t1",
        conditions = {"perk_Blunt_lt3"}
    },
    xp_Blunt_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Blunt_t2",
        conditions = {"perk_Blunt_mid"}
    },
    xp_Blunt_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Blunt_t3",
        conditions = {"perk_Blunt_high"}
    },
    boost_Blunt = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Blunt"
    },

    ---------------------------------------------------------------------------
    -- Axe
    ---------------------------------------------------------------------------
    xp_Axe_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Axe_t1",
        conditions = {"perk_Axe_lt3"}
    },
    xp_Axe_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Axe_t2",
        conditions = {"perk_Axe_mid"}
    },
    xp_Axe_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Axe_t3",
        conditions = {"perk_Axe_high"}
    },
    boost_Axe = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Axe"
    },

    ---------------------------------------------------------------------------
    -- Lightfoot (Lightfooted)
    ---------------------------------------------------------------------------
    xp_Lightfoot_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Lightfoot_t1",
        conditions = {"perk_Lightfoot_lt3"}
    },
    xp_Lightfoot_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Lightfoot_t2",
        conditions = {"perk_Lightfoot_mid"}
    },
    xp_Lightfoot_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Lightfoot_t3",
        conditions = {"perk_Lightfoot_high"}
    },
    boost_Lightfoot = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Lightfoot"
    },

    ---------------------------------------------------------------------------
    -- Nimble
    ---------------------------------------------------------------------------
    xp_Nimble_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Nimble_t1",
        conditions = {"perk_Nimble_lt3"}
    },
    xp_Nimble_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Nimble_t2",
        conditions = {"perk_Nimble_mid"}
    },
    xp_Nimble_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Nimble_t3",
        conditions = {"perk_Nimble_high"}
    },
    boost_Nimble = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Nimble"
    },

    ---------------------------------------------------------------------------
    -- Sprinting (Running)
    ---------------------------------------------------------------------------
    xp_Sprinting_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Sprinting_t1",
        conditions = {"perk_Sprinting_lt3"}
    },
    xp_Sprinting_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Sprinting_t2",
        conditions = {"perk_Sprinting_mid"}
    },
    xp_Sprinting_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Sprinting_t3",
        conditions = {"perk_Sprinting_high"}
    },
    boost_Sprinting = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Sprinting"
    },

    ---------------------------------------------------------------------------
    -- Sneak (Sneaking)
    ---------------------------------------------------------------------------
    xp_Sneak_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Sneak_t1",
        conditions = {"perk_Sneak_lt3"}
    },
    xp_Sneak_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Sneak_t2",
        conditions = {"perk_Sneak_mid"}
    },
    xp_Sneak_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Sneak_t3",
        conditions = {"perk_Sneak_high"}
    },
    boost_Sneak = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Sneak"
    },

    ---------------------------------------------------------------------------
    -- Woodwork (Carpentry)
    ---------------------------------------------------------------------------
    xp_Woodwork_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Woodwork_t1",
        conditions = {"perk_Woodwork_lt3"}
    },
    xp_Woodwork_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Woodwork_t2",
        conditions = {"perk_Woodwork_mid"}
    },
    xp_Woodwork_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Woodwork_t3",
        conditions = {"perk_Woodwork_high"}
    },
    boost_Woodwork = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Woodwork"
    },

    ---------------------------------------------------------------------------
    -- Aiming
    ---------------------------------------------------------------------------
    xp_Aiming_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Aiming_t1",
        conditions = {"perk_Aiming_lt3"}
    },
    xp_Aiming_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Aiming_t2",
        conditions = {"perk_Aiming_mid"}
    },
    xp_Aiming_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Aiming_t3",
        conditions = {"perk_Aiming_high"}
    },
    boost_Aiming = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Aiming"
    },

    ---------------------------------------------------------------------------
    -- Reloading
    ---------------------------------------------------------------------------
    xp_Reloading_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Reloading_t1",
        conditions = {"perk_Reloading_lt3"}
    },
    xp_Reloading_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Reloading_t2",
        conditions = {"perk_Reloading_mid"}
    },
    xp_Reloading_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Reloading_t3",
        conditions = {"perk_Reloading_high"}
    },
    boost_Reloading = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Reloading"
    },

    ---------------------------------------------------------------------------
    -- Farming (Agriculture)
    ---------------------------------------------------------------------------
    xp_Farming_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Farming_t1",
        conditions = {"perk_Farming_lt3"}
    },
    xp_Farming_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Farming_t2",
        conditions = {"perk_Farming_mid"}
    },
    xp_Farming_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Farming_t3",
        conditions = {"perk_Farming_high"}
    },
    boost_Farming = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Farming"
    },

    ---------------------------------------------------------------------------
    -- Fishing
    ---------------------------------------------------------------------------
    xp_Fishing_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Fishing_t1",
        conditions = {"perk_Fishing_lt3"}
    },
    xp_Fishing_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Fishing_t2",
        conditions = {"perk_Fishing_mid"}
    },
    xp_Fishing_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Fishing_t3",
        conditions = {"perk_Fishing_high"}
    },
    boost_Fishing = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Fishing"
    },

    ---------------------------------------------------------------------------
    -- Trapping
    ---------------------------------------------------------------------------
    xp_Trapping_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Trapping_t1",
        conditions = {"perk_Trapping_lt3"}
    },
    xp_Trapping_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Trapping_t2",
        conditions = {"perk_Trapping_mid"}
    },
    xp_Trapping_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Trapping_t3",
        conditions = {"perk_Trapping_high"}
    },
    boost_Trapping = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Trapping"
    },

    ---------------------------------------------------------------------------
    -- PlantScavenging (Foraging)
    ---------------------------------------------------------------------------
    xp_PlantScavenging_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_PlantScavenging_t1",
        conditions = {"perk_PlantScavenging_lt3"}
    },
    xp_PlantScavenging_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_PlantScavenging_t2",
        conditions = {"perk_PlantScavenging_mid"}
    },
    xp_PlantScavenging_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_PlantScavenging_t3",
        conditions = {"perk_PlantScavenging_high"}
    },
    boost_PlantScavenging = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_PlantScavenging"
    },

    ---------------------------------------------------------------------------
    -- Doctor (First Aid)
    ---------------------------------------------------------------------------
    xp_Doctor_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Doctor_t1",
        conditions = {"perk_Doctor_lt3"}
    },
    xp_Doctor_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Doctor_t2",
        conditions = {"perk_Doctor_mid"}
    },
    xp_Doctor_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Doctor_t3",
        conditions = {"perk_Doctor_high"}
    },
    boost_Doctor = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Doctor"
    },

    ---------------------------------------------------------------------------
    -- Electricity (Electrical)
    ---------------------------------------------------------------------------
    xp_Electricity_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Electricity_t1",
        conditions = {"perk_Electricity_lt3"}
    },
    xp_Electricity_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Electricity_t2",
        conditions = {"perk_Electricity_mid"}
    },
    xp_Electricity_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Electricity_t3",
        conditions = {"perk_Electricity_high"}
    },
    boost_Electricity = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Electricity"
    },

    ---------------------------------------------------------------------------
    -- Blacksmith (Blacksmithing)
    ---------------------------------------------------------------------------
    xp_Blacksmith_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Blacksmith_t1",
        conditions = {"perk_Blacksmith_lt3"}
    },
    xp_Blacksmith_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Blacksmith_t2",
        conditions = {"perk_Blacksmith_mid"}
    },
    xp_Blacksmith_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Blacksmith_t3",
        conditions = {"perk_Blacksmith_high"}
    },
    boost_Blacksmith = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Blacksmith"
    },

    ---------------------------------------------------------------------------
    -- MetalWelding (Welding)
    ---------------------------------------------------------------------------
    xp_MetalWelding_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_MetalWelding_t1",
        conditions = {"perk_MetalWelding_lt3"}
    },
    xp_MetalWelding_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_MetalWelding_t2",
        conditions = {"perk_MetalWelding_mid"}
    },
    xp_MetalWelding_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_MetalWelding_t3",
        conditions = {"perk_MetalWelding_high"}
    },
    boost_MetalWelding = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_MetalWelding"
    },

    ---------------------------------------------------------------------------
    -- Mechanics
    ---------------------------------------------------------------------------
    xp_Mechanics_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Mechanics_t1",
        conditions = {"perk_Mechanics_lt3"}
    },
    xp_Mechanics_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Mechanics_t2",
        conditions = {"perk_Mechanics_mid"}
    },
    xp_Mechanics_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Mechanics_t3",
        conditions = {"perk_Mechanics_high"}
    },
    boost_Mechanics = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Mechanics"
    },

    ---------------------------------------------------------------------------
    -- Spear
    ---------------------------------------------------------------------------
    xp_Spear_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Spear_t1",
        conditions = {"perk_Spear_lt3"}
    },
    xp_Spear_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Spear_t2",
        conditions = {"perk_Spear_mid"}
    },
    xp_Spear_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Spear_t3",
        conditions = {"perk_Spear_high"}
    },
    boost_Spear = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Spear"
    },

    ---------------------------------------------------------------------------
    -- Maintenance
    ---------------------------------------------------------------------------
    xp_Maintenance_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Maintenance_t1",
        conditions = {"perk_Maintenance_lt3"}
    },
    xp_Maintenance_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Maintenance_t2",
        conditions = {"perk_Maintenance_mid"}
    },
    xp_Maintenance_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Maintenance_t3",
        conditions = {"perk_Maintenance_high"}
    },
    boost_Maintenance = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Maintenance"
    },

    ---------------------------------------------------------------------------
    -- SmallBlade (Short Blade)
    ---------------------------------------------------------------------------
    xp_SmallBlade_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_SmallBlade_t1",
        conditions = {"perk_SmallBlade_lt3"}
    },
    xp_SmallBlade_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_SmallBlade_t2",
        conditions = {"perk_SmallBlade_mid"}
    },
    xp_SmallBlade_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_SmallBlade_t3",
        conditions = {"perk_SmallBlade_high"}
    },
    boost_SmallBlade = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_SmallBlade"
    },

    ---------------------------------------------------------------------------
    -- LongBlade (Long Blade)
    ---------------------------------------------------------------------------
    xp_LongBlade_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_LongBlade_t1",
        conditions = {"perk_LongBlade_lt3"}
    },
    xp_LongBlade_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_LongBlade_t2",
        conditions = {"perk_LongBlade_mid"}
    },
    xp_LongBlade_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_LongBlade_t3",
        conditions = {"perk_LongBlade_high"}
    },
    boost_LongBlade = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_LongBlade"
    },

    ---------------------------------------------------------------------------
    -- SmallBlunt (Short Blunt)
    ---------------------------------------------------------------------------
    xp_SmallBlunt_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_SmallBlunt_t1",
        conditions = {"perk_SmallBlunt_lt3"}
    },
    xp_SmallBlunt_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_SmallBlunt_t2",
        conditions = {"perk_SmallBlunt_mid"}
    },
    xp_SmallBlunt_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_SmallBlunt_t3",
        conditions = {"perk_SmallBlunt_high"}
    },
    boost_SmallBlunt = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_SmallBlunt"
    },

    ---------------------------------------------------------------------------
    -- Tailoring
    ---------------------------------------------------------------------------
    xp_Tailoring_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Tailoring_t1",
        conditions = {"perk_Tailoring_lt3"}
    },
    xp_Tailoring_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Tailoring_t2",
        conditions = {"perk_Tailoring_mid"}
    },
    xp_Tailoring_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Tailoring_t3",
        conditions = {"perk_Tailoring_high"}
    },
    boost_Tailoring = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Tailoring"
    },

    ---------------------------------------------------------------------------
    -- Tracking
    ---------------------------------------------------------------------------
    xp_Tracking_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Tracking_t1",
        conditions = {"perk_Tracking_lt3"}
    },
    xp_Tracking_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Tracking_t2",
        conditions = {"perk_Tracking_mid"}
    },
    xp_Tracking_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Tracking_t3",
        conditions = {"perk_Tracking_high"}
    },
    boost_Tracking = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Tracking"
    },

    ---------------------------------------------------------------------------
    -- Husbandry (Animal Care)
    ---------------------------------------------------------------------------
    xp_Husbandry_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Husbandry_t1",
        conditions = {"perk_Husbandry_lt3"}
    },
    xp_Husbandry_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Husbandry_t2",
        conditions = {"perk_Husbandry_mid"}
    },
    xp_Husbandry_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Husbandry_t3",
        conditions = {"perk_Husbandry_high"}
    },
    boost_Husbandry = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Husbandry"
    },

    ---------------------------------------------------------------------------
    -- FlintKnapping (Knapping)
    ---------------------------------------------------------------------------
    xp_FlintKnapping_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_FlintKnapping_t1",
        conditions = {"perk_FlintKnapping_lt3"}
    },
    xp_FlintKnapping_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_FlintKnapping_t2",
        conditions = {"perk_FlintKnapping_mid"}
    },
    xp_FlintKnapping_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_FlintKnapping_t3",
        conditions = {"perk_FlintKnapping_high"}
    },
    boost_FlintKnapping = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_FlintKnapping"
    },

    ---------------------------------------------------------------------------
    -- Masonry
    ---------------------------------------------------------------------------
    xp_Masonry_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Masonry_t1",
        conditions = {"perk_Masonry_lt3"}
    },
    xp_Masonry_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Masonry_t2",
        conditions = {"perk_Masonry_mid"}
    },
    xp_Masonry_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Masonry_t3",
        conditions = {"perk_Masonry_high"}
    },
    boost_Masonry = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Masonry"
    },

    ---------------------------------------------------------------------------
    -- Pottery
    ---------------------------------------------------------------------------
    xp_Pottery_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Pottery_t1",
        conditions = {"perk_Pottery_lt3"}
    },
    xp_Pottery_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Pottery_t2",
        conditions = {"perk_Pottery_mid"}
    },
    xp_Pottery_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Pottery_t3",
        conditions = {"perk_Pottery_high"}
    },
    boost_Pottery = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Pottery"
    },

    ---------------------------------------------------------------------------
    -- Carving
    ---------------------------------------------------------------------------
    xp_Carving_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Carving_t1",
        conditions = {"perk_Carving_lt3"}
    },
    xp_Carving_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Carving_t2",
        conditions = {"perk_Carving_mid"}
    },
    xp_Carving_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Carving_t3",
        conditions = {"perk_Carving_high"}
    },
    boost_Carving = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Carving"
    },

    ---------------------------------------------------------------------------
    -- Butchering
    ---------------------------------------------------------------------------
    xp_Butchering_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Butchering_t1",
        conditions = {"perk_Butchering_lt3"}
    },
    xp_Butchering_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Butchering_t2",
        conditions = {"perk_Butchering_mid"}
    },
    xp_Butchering_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Butchering_t3",
        conditions = {"perk_Butchering_high"}
    },
    boost_Butchering = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Butchering"
    },

    ---------------------------------------------------------------------------
    -- Glassmaking
    ---------------------------------------------------------------------------
    xp_Glassmaking_t1 = {
        inherit = "xp_t1_base",
        price = "coin_10",
        reward = "skill_Glassmaking_t1",
        conditions = {"perk_Glassmaking_lt3"}
    },
    xp_Glassmaking_t2 = {
        inherit = "xp_t2_base",
        price = "coin_25",
        reward = "skill_Glassmaking_t2",
        conditions = {"perk_Glassmaking_mid"}
    },
    xp_Glassmaking_t3 = {
        inherit = "xp_t3_base",
        price = "coin_75",
        reward = "skill_Glassmaking_t3",
        conditions = {"perk_Glassmaking_high"}
    },
    boost_Glassmaking = {
        inherit = "boost_base_xp",
        price = "coin_boost",
        reward = "boost_Glassmaking"
    }

}
