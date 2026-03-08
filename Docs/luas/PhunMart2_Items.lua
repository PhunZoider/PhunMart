-- PhunMart2 Default Items
-- Game items (key = itemType): reward auto-generated from key if omitted.
-- Non-item offers (arbitrary key): must have explicit reward reference.
return {

    -- =========================================================
    -- TRAIT OFFER ITEMS
    -- Each maps an offer key to a reward key (both defined in Rewards.lua).
    -- Price: placeholder coin_50 until trait token currency is implemented.
    -- canGrantTrait condition is auto-injected by the compiler for addTrait actions.
    -- =========================================================

    -- Positive traits
    ["offer:add_brave"]           = { price = "coin_50", reward = "add_brave",           offer = { weight = 1.0 } },
    ["offer:add_fasthealer"]      = { price = "coin_50", reward = "add_fasthealer",       offer = { weight = 1.0 } },
    ["offer:add_strong"]          = { price = "coin_75", reward = "add_strong",           offer = { weight = 0.5 } },
    ["offer:add_stout"]           = { price = "coin_50", reward = "add_stout",            offer = { weight = 0.7 } },
    ["offer:add_athletic"]        = { price = "coin_75", reward = "add_athletic",         offer = { weight = 0.5 } },
    ["offer:add_fit"]             = { price = "coin_50", reward = "add_fit",              offer = { weight = 0.7 } },
    ["offer:add_gymnast"]         = { price = "coin_40", reward = "add_gymnast",          offer = { weight = 1.0 } },
    ["offer:add_organized"]       = { price = "coin_40", reward = "add_organized",        offer = { weight = 1.0 } },
    ["offer:add_dextrous"]        = { price = "coin_25", reward = "add_dextrous",         offer = { weight = 1.0 } },
    ["offer:add_graceful"]        = { price = "coin_40", reward = "add_graceful",         offer = { weight = 1.0 } },
    ["offer:add_keenhearing"]     = { price = "coin_50", reward = "add_keenhearing",      offer = { weight = 0.8 } },
    ["offer:add_eagleeyed"]       = { price = "coin_40", reward = "add_eagleeyed",        offer = { weight = 0.8 } },
    ["offer:add_thickskinned"]    = { price = "coin_75", reward = "add_thickskinned",     offer = { weight = 0.5 } },
    ["offer:add_irongut"]         = { price = "coin_25", reward = "add_irongut",          offer = { weight = 1.0 } },
    ["offer:add_resilient"]       = { price = "coin_40", reward = "add_resilient",        offer = { weight = 1.0 } },
    ["offer:add_fastlearner"]     = { price = "coin_50", reward = "add_fastlearner",      offer = { weight = 0.7 } },
    ["offer:add_crafty"]          = { price = "coin_25", reward = "add_crafty",           offer = { weight = 1.0 } },
    ["offer:add_inconspicuous"]   = { price = "coin_40", reward = "add_inconspicuous",    offer = { weight = 1.0 } },
    ["offer:add_fastreader"]      = { price = "coin_25", reward = "add_fastreader",       offer = { weight = 1.0 } },
    ["offer:add_lighteater"]      = { price = "coin_25", reward = "add_lighteater",       offer = { weight = 1.0 } },
    ["offer:add_lowthirst"]       = { price = "coin_25", reward = "add_lowthirst",        offer = { weight = 1.0 } },
    ["offer:add_needslesssleep"]  = { price = "coin_25", reward = "add_needslesssleep",   offer = { weight = 1.0 } },
    ["offer:add_jogger"]          = { price = "coin_40", reward = "add_jogger",           offer = { weight = 1.0 } },
    ["offer:add_brawler"]         = { price = "coin_50", reward = "add_brawler",          offer = { weight = 0.8 } },
    ["offer:add_hiker"]           = { price = "coin_50", reward = "add_hiker",            offer = { weight = 0.8 } },
    ["offer:add_formerscout"]     = { price = "coin_50", reward = "add_formerscout",      offer = { weight = 0.7 } },
    ["offer:add_outdoorsman"]     = { price = "coin_25", reward = "add_outdoorsman",      offer = { weight = 1.0 } },
    ["offer:add_herbalist"]       = { price = "coin_40", reward = "add_herbalist",        offer = { weight = 1.0 } },
    ["offer:add_hunter"]          = { price = "coin_75", reward = "add_hunter",           offer = { weight = 0.5 } },
    ["offer:add_fishing"]         = { price = "coin_40", reward = "add_fishing",          offer = { weight = 1.0 } },
    ["offer:add_cook"]            = { price = "coin_25", reward = "add_cook",             offer = { weight = 1.0 } },
    ["offer:add_nutritionist"]    = { price = "coin_40", reward = "add_nutritionist",     offer = { weight = 0.8 } },
    ["offer:add_firstaid"]        = { price = "coin_40", reward = "add_firstaid",         offer = { weight = 1.0 } },
    ["offer:add_handy"]           = { price = "coin_75", reward = "add_handy",            offer = { weight = 0.5 } },
    ["offer:add_mechanic"]        = { price = "coin_25", reward = "add_mechanic",         offer = { weight = 1.0 } },
    ["offer:add_tailor"]          = { price = "coin_40", reward = "add_tailor",           offer = { weight = 1.0 } },
    ["offer:add_blacksmith"]      = { price = "coin_50", reward = "add_blacksmith",       offer = { weight = 0.7 } },
    ["offer:add_mason"]           = { price = "coin_25", reward = "add_mason",            offer = { weight = 1.0 } },
    ["offer:add_whittler"]        = { price = "coin_25", reward = "add_whittler",         offer = { weight = 1.0 } },
    ["offer:add_adrenalinejunkie"]= { price = "coin_40", reward = "add_adrenalinejunkie", offer = { weight = 0.8 } },
    ["offer:add_nightvision"]     = { price = "coin_25", reward = "add_nightvision",      offer = { weight = 1.0 } },
    ["offer:add_speeddemon"]      = { price = "coin_10", reward = "add_speeddemon",       offer = { weight = 1.0 } },
    ["offer:add_inventive"]       = { price = "coin_25", reward = "add_inventive",        offer = { weight = 1.0 } },
    ["offer:add_wildernessknowledge"] = { price = "coin_75", reward = "add_wildernessknowledge", offer = { weight = 0.5 } },
    ["offer:add_gardener"]        = { price = "coin_25", reward = "add_gardener",         offer = { weight = 1.0 } },

    -- Negative trait removals
    ["offer:remove_slowlearner"]  = { price = "coin_50", reward = "remove_slowlearner",   offer = { weight = 1.0 } },
    ["offer:remove_clumsy"]       = { price = "coin_25", reward = "remove_clumsy",        offer = { weight = 1.0 } },
    ["offer:remove_weakstomach"]  = { price = "coin_25", reward = "remove_weakstomach",   offer = { weight = 1.0 } },
    ["offer:remove_slowhealer"]   = { price = "coin_25", reward = "remove_slowhealer",    offer = { weight = 1.0 } },
    ["offer:remove_insomniac"]    = { price = "coin_50", reward = "remove_insomniac",     offer = { weight = 0.8 } },
    ["offer:remove_highthirst"]   = { price = "coin_10", reward = "remove_highthirst",    offer = { weight = 1.0 } },
    ["offer:remove_shortsighted"] = { price = "coin_25", reward = "remove_shortsighted",  offer = { weight = 1.0 } },
    ["offer:remove_conspicuous"]  = { price = "coin_40", reward = "remove_conspicuous",   offer = { weight = 0.8 } },
    ["offer:remove_cowardly"]     = { price = "coin_25", reward = "remove_cowardly",      offer = { weight = 1.0 } },
    ["offer:remove_disorganized"] = { price = "coin_50", reward = "remove_disorganized",  offer = { weight = 0.8 } },
    ["offer:remove_heartyappetite"]={ price = "coin_40", reward = "remove_heartyappetite",offer = { weight = 0.8 } },
    ["offer:remove_pacifist"]     = { price = "coin_40", reward = "remove_pacifist",      offer = { weight = 0.8 } },
    ["offer:remove_slowreader"]   = { price = "coin_25", reward = "remove_slowreader",    offer = { weight = 1.0 } },
    ["offer:remove_thinskinned"]  = { price = "coin_75", reward = "remove_thinskinned",   offer = { weight = 0.5 } },
    ["offer:remove_outofshape"]   = { price = "coin_50", reward = "remove_outofshape",    offer = { weight = 0.8 } },
    ["offer:remove_hardofhearing"]= { price = "coin_40", reward = "remove_hardofhearing", offer = { weight = 0.8 } },
    ["offer:remove_allthumbs"]    = { price = "coin_25", reward = "remove_allthumbs",     offer = { weight = 1.0 } },
    ["offer:remove_hemophobic"]   = { price = "coin_50", reward = "remove_hemophobic",    offer = { weight = 0.7 } },
    ["offer:remove_needsmoresleep"]={ price = "coin_40", reward = "remove_needsmoresleep", offer = { weight = 0.8 } },
    ["offer:remove_asthmatic"]    = { price = "coin_50", reward = "remove_asthmatic",     offer = { weight = 0.7 } },
    ["offer:remove_smoker"]       = { price = "coin_25", reward = "remove_smoker",        offer = { weight = 1.0 } },
    ["offer:remove_feeble"]       = { price = "coin_50", reward = "remove_feeble",        offer = { weight = 0.7 } },
    ["offer:remove_pronetoillness"]={ price = "coin_40", reward = "remove_pronetoillness", offer = { weight = 0.8 } },
    ["offer:remove_claustrophobic"]={ price = "coin_40", reward = "remove_claustrophobic", offer = { weight = 0.8 } },
    ["offer:remove_agoraphobic"]  = { price = "coin_40", reward = "remove_agoraphobic",   offer = { weight = 0.8 } },
    ["offer:remove_unfit"]        = { price = "coin_75", reward = "remove_unfit",         offer = { weight = 0.5 } },
    ["offer:remove_sundaydriver"] = { price = "coin_10", reward = "remove_sundaydriver",  offer = { weight = 1.0 } },

    -- =========================================================
    -- VEHICLE OFFER ITEMS
    -- stock=1 with long restock keeps vehicles feeling rare
    -- =========================================================

    ["vehicle:SmallCar"]      = { price = "vehicle_common",   reward = "vehicle_smallcar",    offer = { weight = 1.0, stock = { min=0, max=1, restockHours=168 } } },
    ["vehicle:SmallCar02"]    = { price = "vehicle_common",   reward = "vehicle_smallcar",    offer = { weight = 1.0, stock = { min=0, max=1, restockHours=168 } } },
    ["vehicle:CarNormal"]     = { price = "vehicle_uncommon", reward = "vehicle_normalcar",   offer = { weight = 1.0, stock = { min=0, max=1, restockHours=168 } } },
    ["vehicle:ModernCar"]     = { price = "vehicle_uncommon", reward = "vehicle_normalcar",   offer = { weight = 1.0, stock = { min=0, max=1, restockHours=168 } } },
    ["vehicle:ModernCar02"]   = { price = "vehicle_uncommon", reward = "vehicle_normalcar",   offer = { weight = 1.0, stock = { min=0, max=1, restockHours=168 } } },
    ["vehicle:CarStationWagon"]={ price = "vehicle_uncommon", reward = "vehicle_stationwagon",offer = { weight = 1.0, stock = { min=0, max=1, restockHours=168 } } },
    ["vehicle:CarLuxury"]     = { price = "vehicle_rare",     reward = "vehicle_luxury",      offer = { weight = 0.5, stock = { min=0, max=1, restockHours=336 } } },
    ["vehicle:SportsCar"]     = { price = "vehicle_rare",     reward = "vehicle_sportscar",   offer = { weight = 0.5, stock = { min=0, max=1, restockHours=336 } } },
    ["vehicle:SUV"]           = { price = "vehicle_uncommon", reward = "vehicle_suv",         offer = { weight = 1.0, stock = { min=0, max=1, restockHours=168 } } },
    ["vehicle:OffRoad"]       = { price = "vehicle_uncommon", reward = "vehicle_offroad",     offer = { weight = 1.0, stock = { min=0, max=1, restockHours=168 } } },
    ["vehicle:PickUpTruck"]   = { price = "vehicle_uncommon", reward = "vehicle_pickup",      offer = { weight = 1.0, stock = { min=0, max=1, restockHours=168 } } },
    ["vehicle:PickUpVan"]     = { price = "vehicle_uncommon", reward = "vehicle_pickup",      offer = { weight = 1.0, stock = { min=0, max=1, restockHours=168 } } },
    ["vehicle:Van"]           = { price = "vehicle_common",   reward = "vehicle_van",         offer = { weight = 1.0, stock = { min=0, max=1, restockHours=168 } } },
    ["vehicle:VanSeats"]      = { price = "vehicle_common",   reward = "vehicle_van",         offer = { weight = 1.0, stock = { min=0, max=1, restockHours=168 } } },
    ["vehicle:StepVan"]       = { price = "vehicle_common",   reward = "vehicle_stepvan",     offer = { weight = 1.0, stock = { min=0, max=1, restockHours=168 } } },

    -- XP and boost offer items are defined in PhunMart2_XP_Items.lua (generated)

}
