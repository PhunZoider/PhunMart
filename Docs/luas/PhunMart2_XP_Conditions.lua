-- PhunMart2_XP_Conditions.lua
-- Perk level gate conditions for all 35 skill perks, three bands each.
--
-- Band definitions:
--   _lt3  : perk level 0-2  (beginner, eligible for T1/budget XP)
--   _mid  : perk level 3-6  (intermediate, eligible for T2/gifted XP)
--   _high : perk level 7+   (advanced, eligible for T3/luxury XP)
--
-- test = "perkLevelBetween"
--   args.perk : PZ perk key (matches Perks.<key> enum)
--   args.min  : inclusive lower bound (omit = no lower bound)
--   args.max  : inclusive upper bound (omit = no upper bound)

return {

    ---------------------------------------------------------------------------
    -- Cooking
    ---------------------------------------------------------------------------
    perk_Cooking_lt3  = { test = "perkLevelBetween", args = { perk = "Cooking", max = 2 } },
    perk_Cooking_mid  = { test = "perkLevelBetween", args = { perk = "Cooking", min = 3, max = 6 } },
    perk_Cooking_high = { test = "perkLevelBetween", args = { perk = "Cooking", min = 7 } },

    ---------------------------------------------------------------------------
    -- Fitness
    ---------------------------------------------------------------------------
    perk_Fitness_lt3  = { test = "perkLevelBetween", args = { perk = "Fitness", max = 2 } },
    perk_Fitness_mid  = { test = "perkLevelBetween", args = { perk = "Fitness", min = 3, max = 6 } },
    perk_Fitness_high = { test = "perkLevelBetween", args = { perk = "Fitness", min = 7 } },

    ---------------------------------------------------------------------------
    -- Strength
    ---------------------------------------------------------------------------
    perk_Strength_lt3  = { test = "perkLevelBetween", args = { perk = "Strength", max = 2 } },
    perk_Strength_mid  = { test = "perkLevelBetween", args = { perk = "Strength", min = 3, max = 6 } },
    perk_Strength_high = { test = "perkLevelBetween", args = { perk = "Strength", min = 7 } },

    ---------------------------------------------------------------------------
    -- Blunt (Long Blunt)
    ---------------------------------------------------------------------------
    perk_Blunt_lt3  = { test = "perkLevelBetween", args = { perk = "Blunt", max = 2 } },
    perk_Blunt_mid  = { test = "perkLevelBetween", args = { perk = "Blunt", min = 3, max = 6 } },
    perk_Blunt_high = { test = "perkLevelBetween", args = { perk = "Blunt", min = 7 } },

    ---------------------------------------------------------------------------
    -- Axe
    ---------------------------------------------------------------------------
    perk_Axe_lt3  = { test = "perkLevelBetween", args = { perk = "Axe", max = 2 } },
    perk_Axe_mid  = { test = "perkLevelBetween", args = { perk = "Axe", min = 3, max = 6 } },
    perk_Axe_high = { test = "perkLevelBetween", args = { perk = "Axe", min = 7 } },

    ---------------------------------------------------------------------------
    -- Lightfoot (Lightfooted)
    ---------------------------------------------------------------------------
    perk_Lightfoot_lt3  = { test = "perkLevelBetween", args = { perk = "Lightfoot", max = 2 } },
    perk_Lightfoot_mid  = { test = "perkLevelBetween", args = { perk = "Lightfoot", min = 3, max = 6 } },
    perk_Lightfoot_high = { test = "perkLevelBetween", args = { perk = "Lightfoot", min = 7 } },

    ---------------------------------------------------------------------------
    -- Nimble
    ---------------------------------------------------------------------------
    perk_Nimble_lt3  = { test = "perkLevelBetween", args = { perk = "Nimble", max = 2 } },
    perk_Nimble_mid  = { test = "perkLevelBetween", args = { perk = "Nimble", min = 3, max = 6 } },
    perk_Nimble_high = { test = "perkLevelBetween", args = { perk = "Nimble", min = 7 } },

    ---------------------------------------------------------------------------
    -- Sprinting (Running)
    ---------------------------------------------------------------------------
    perk_Sprinting_lt3  = { test = "perkLevelBetween", args = { perk = "Sprinting", max = 2 } },
    perk_Sprinting_mid  = { test = "perkLevelBetween", args = { perk = "Sprinting", min = 3, max = 6 } },
    perk_Sprinting_high = { test = "perkLevelBetween", args = { perk = "Sprinting", min = 7 } },

    ---------------------------------------------------------------------------
    -- Sneak (Sneaking)
    ---------------------------------------------------------------------------
    perk_Sneak_lt3  = { test = "perkLevelBetween", args = { perk = "Sneak", max = 2 } },
    perk_Sneak_mid  = { test = "perkLevelBetween", args = { perk = "Sneak", min = 3, max = 6 } },
    perk_Sneak_high = { test = "perkLevelBetween", args = { perk = "Sneak", min = 7 } },

    ---------------------------------------------------------------------------
    -- Woodwork (Carpentry)
    ---------------------------------------------------------------------------
    perk_Woodwork_lt3  = { test = "perkLevelBetween", args = { perk = "Woodwork", max = 2 } },
    perk_Woodwork_mid  = { test = "perkLevelBetween", args = { perk = "Woodwork", min = 3, max = 6 } },
    perk_Woodwork_high = { test = "perkLevelBetween", args = { perk = "Woodwork", min = 7 } },

    ---------------------------------------------------------------------------
    -- Aiming
    ---------------------------------------------------------------------------
    perk_Aiming_lt3  = { test = "perkLevelBetween", args = { perk = "Aiming", max = 2 } },
    perk_Aiming_mid  = { test = "perkLevelBetween", args = { perk = "Aiming", min = 3, max = 6 } },
    perk_Aiming_high = { test = "perkLevelBetween", args = { perk = "Aiming", min = 7 } },

    ---------------------------------------------------------------------------
    -- Reloading
    ---------------------------------------------------------------------------
    perk_Reloading_lt3  = { test = "perkLevelBetween", args = { perk = "Reloading", max = 2 } },
    perk_Reloading_mid  = { test = "perkLevelBetween", args = { perk = "Reloading", min = 3, max = 6 } },
    perk_Reloading_high = { test = "perkLevelBetween", args = { perk = "Reloading", min = 7 } },

    ---------------------------------------------------------------------------
    -- Farming (Agriculture)
    ---------------------------------------------------------------------------
    perk_Farming_lt3  = { test = "perkLevelBetween", args = { perk = "Farming", max = 2 } },
    perk_Farming_mid  = { test = "perkLevelBetween", args = { perk = "Farming", min = 3, max = 6 } },
    perk_Farming_high = { test = "perkLevelBetween", args = { perk = "Farming", min = 7 } },

    ---------------------------------------------------------------------------
    -- Fishing
    ---------------------------------------------------------------------------
    perk_Fishing_lt3  = { test = "perkLevelBetween", args = { perk = "Fishing", max = 2 } },
    perk_Fishing_mid  = { test = "perkLevelBetween", args = { perk = "Fishing", min = 3, max = 6 } },
    perk_Fishing_high = { test = "perkLevelBetween", args = { perk = "Fishing", min = 7 } },

    ---------------------------------------------------------------------------
    -- Trapping
    ---------------------------------------------------------------------------
    perk_Trapping_lt3  = { test = "perkLevelBetween", args = { perk = "Trapping", max = 2 } },
    perk_Trapping_mid  = { test = "perkLevelBetween", args = { perk = "Trapping", min = 3, max = 6 } },
    perk_Trapping_high = { test = "perkLevelBetween", args = { perk = "Trapping", min = 7 } },

    ---------------------------------------------------------------------------
    -- PlantScavenging (Foraging)
    ---------------------------------------------------------------------------
    perk_PlantScavenging_lt3  = { test = "perkLevelBetween", args = { perk = "PlantScavenging", max = 2 } },
    perk_PlantScavenging_mid  = { test = "perkLevelBetween", args = { perk = "PlantScavenging", min = 3, max = 6 } },
    perk_PlantScavenging_high = { test = "perkLevelBetween", args = { perk = "PlantScavenging", min = 7 } },

    ---------------------------------------------------------------------------
    -- Doctor (First Aid)
    ---------------------------------------------------------------------------
    perk_Doctor_lt3  = { test = "perkLevelBetween", args = { perk = "Doctor", max = 2 } },
    perk_Doctor_mid  = { test = "perkLevelBetween", args = { perk = "Doctor", min = 3, max = 6 } },
    perk_Doctor_high = { test = "perkLevelBetween", args = { perk = "Doctor", min = 7 } },

    ---------------------------------------------------------------------------
    -- Electricity (Electrical)
    ---------------------------------------------------------------------------
    perk_Electricity_lt3  = { test = "perkLevelBetween", args = { perk = "Electricity", max = 2 } },
    perk_Electricity_mid  = { test = "perkLevelBetween", args = { perk = "Electricity", min = 3, max = 6 } },
    perk_Electricity_high = { test = "perkLevelBetween", args = { perk = "Electricity", min = 7 } },

    ---------------------------------------------------------------------------
    -- Blacksmith (Blacksmithing)
    ---------------------------------------------------------------------------
    perk_Blacksmith_lt3  = { test = "perkLevelBetween", args = { perk = "Blacksmith", max = 2 } },
    perk_Blacksmith_mid  = { test = "perkLevelBetween", args = { perk = "Blacksmith", min = 3, max = 6 } },
    perk_Blacksmith_high = { test = "perkLevelBetween", args = { perk = "Blacksmith", min = 7 } },

    ---------------------------------------------------------------------------
    -- MetalWelding (Welding)
    ---------------------------------------------------------------------------
    perk_MetalWelding_lt3  = { test = "perkLevelBetween", args = { perk = "MetalWelding", max = 2 } },
    perk_MetalWelding_mid  = { test = "perkLevelBetween", args = { perk = "MetalWelding", min = 3, max = 6 } },
    perk_MetalWelding_high = { test = "perkLevelBetween", args = { perk = "MetalWelding", min = 7 } },

    ---------------------------------------------------------------------------
    -- Mechanics
    ---------------------------------------------------------------------------
    perk_Mechanics_lt3  = { test = "perkLevelBetween", args = { perk = "Mechanics", max = 2 } },
    perk_Mechanics_mid  = { test = "perkLevelBetween", args = { perk = "Mechanics", min = 3, max = 6 } },
    perk_Mechanics_high = { test = "perkLevelBetween", args = { perk = "Mechanics", min = 7 } },

    ---------------------------------------------------------------------------
    -- Spear
    ---------------------------------------------------------------------------
    perk_Spear_lt3  = { test = "perkLevelBetween", args = { perk = "Spear", max = 2 } },
    perk_Spear_mid  = { test = "perkLevelBetween", args = { perk = "Spear", min = 3, max = 6 } },
    perk_Spear_high = { test = "perkLevelBetween", args = { perk = "Spear", min = 7 } },

    ---------------------------------------------------------------------------
    -- Maintenance
    ---------------------------------------------------------------------------
    perk_Maintenance_lt3  = { test = "perkLevelBetween", args = { perk = "Maintenance", max = 2 } },
    perk_Maintenance_mid  = { test = "perkLevelBetween", args = { perk = "Maintenance", min = 3, max = 6 } },
    perk_Maintenance_high = { test = "perkLevelBetween", args = { perk = "Maintenance", min = 7 } },

    ---------------------------------------------------------------------------
    -- SmallBlade (Short Blade)
    ---------------------------------------------------------------------------
    perk_SmallBlade_lt3  = { test = "perkLevelBetween", args = { perk = "SmallBlade", max = 2 } },
    perk_SmallBlade_mid  = { test = "perkLevelBetween", args = { perk = "SmallBlade", min = 3, max = 6 } },
    perk_SmallBlade_high = { test = "perkLevelBetween", args = { perk = "SmallBlade", min = 7 } },

    ---------------------------------------------------------------------------
    -- LongBlade (Long Blade)
    ---------------------------------------------------------------------------
    perk_LongBlade_lt3  = { test = "perkLevelBetween", args = { perk = "LongBlade", max = 2 } },
    perk_LongBlade_mid  = { test = "perkLevelBetween", args = { perk = "LongBlade", min = 3, max = 6 } },
    perk_LongBlade_high = { test = "perkLevelBetween", args = { perk = "LongBlade", min = 7 } },

    ---------------------------------------------------------------------------
    -- SmallBlunt (Short Blunt)
    ---------------------------------------------------------------------------
    perk_SmallBlunt_lt3  = { test = "perkLevelBetween", args = { perk = "SmallBlunt", max = 2 } },
    perk_SmallBlunt_mid  = { test = "perkLevelBetween", args = { perk = "SmallBlunt", min = 3, max = 6 } },
    perk_SmallBlunt_high = { test = "perkLevelBetween", args = { perk = "SmallBlunt", min = 7 } },

    ---------------------------------------------------------------------------
    -- Tailoring
    ---------------------------------------------------------------------------
    perk_Tailoring_lt3  = { test = "perkLevelBetween", args = { perk = "Tailoring", max = 2 } },
    perk_Tailoring_mid  = { test = "perkLevelBetween", args = { perk = "Tailoring", min = 3, max = 6 } },
    perk_Tailoring_high = { test = "perkLevelBetween", args = { perk = "Tailoring", min = 7 } },

    ---------------------------------------------------------------------------
    -- Tracking
    ---------------------------------------------------------------------------
    perk_Tracking_lt3  = { test = "perkLevelBetween", args = { perk = "Tracking", max = 2 } },
    perk_Tracking_mid  = { test = "perkLevelBetween", args = { perk = "Tracking", min = 3, max = 6 } },
    perk_Tracking_high = { test = "perkLevelBetween", args = { perk = "Tracking", min = 7 } },

    ---------------------------------------------------------------------------
    -- Husbandry (Animal Care)
    ---------------------------------------------------------------------------
    perk_Husbandry_lt3  = { test = "perkLevelBetween", args = { perk = "Husbandry", max = 2 } },
    perk_Husbandry_mid  = { test = "perkLevelBetween", args = { perk = "Husbandry", min = 3, max = 6 } },
    perk_Husbandry_high = { test = "perkLevelBetween", args = { perk = "Husbandry", min = 7 } },

    ---------------------------------------------------------------------------
    -- FlintKnapping (Knapping)
    ---------------------------------------------------------------------------
    perk_FlintKnapping_lt3  = { test = "perkLevelBetween", args = { perk = "FlintKnapping", max = 2 } },
    perk_FlintKnapping_mid  = { test = "perkLevelBetween", args = { perk = "FlintKnapping", min = 3, max = 6 } },
    perk_FlintKnapping_high = { test = "perkLevelBetween", args = { perk = "FlintKnapping", min = 7 } },

    ---------------------------------------------------------------------------
    -- Masonry
    ---------------------------------------------------------------------------
    perk_Masonry_lt3  = { test = "perkLevelBetween", args = { perk = "Masonry", max = 2 } },
    perk_Masonry_mid  = { test = "perkLevelBetween", args = { perk = "Masonry", min = 3, max = 6 } },
    perk_Masonry_high = { test = "perkLevelBetween", args = { perk = "Masonry", min = 7 } },

    ---------------------------------------------------------------------------
    -- Pottery
    ---------------------------------------------------------------------------
    perk_Pottery_lt3  = { test = "perkLevelBetween", args = { perk = "Pottery", max = 2 } },
    perk_Pottery_mid  = { test = "perkLevelBetween", args = { perk = "Pottery", min = 3, max = 6 } },
    perk_Pottery_high = { test = "perkLevelBetween", args = { perk = "Pottery", min = 7 } },

    ---------------------------------------------------------------------------
    -- Carving
    ---------------------------------------------------------------------------
    perk_Carving_lt3  = { test = "perkLevelBetween", args = { perk = "Carving", max = 2 } },
    perk_Carving_mid  = { test = "perkLevelBetween", args = { perk = "Carving", min = 3, max = 6 } },
    perk_Carving_high = { test = "perkLevelBetween", args = { perk = "Carving", min = 7 } },

    ---------------------------------------------------------------------------
    -- Butchering
    ---------------------------------------------------------------------------
    perk_Butchering_lt3  = { test = "perkLevelBetween", args = { perk = "Butchering", max = 2 } },
    perk_Butchering_mid  = { test = "perkLevelBetween", args = { perk = "Butchering", min = 3, max = 6 } },
    perk_Butchering_high = { test = "perkLevelBetween", args = { perk = "Butchering", min = 7 } },

    ---------------------------------------------------------------------------
    -- Glassmaking
    ---------------------------------------------------------------------------
    perk_Glassmaking_lt3  = { test = "perkLevelBetween", args = { perk = "Glassmaking", max = 2 } },
    perk_Glassmaking_mid  = { test = "perkLevelBetween", args = { perk = "Glassmaking", min = 3, max = 6 } },
    perk_Glassmaking_high = { test = "perkLevelBetween", args = { perk = "Glassmaking", min = 7 } },

}
