return {{
    abstract = true,
    key = "base-collectors-1",
    tab = "Items",
    tags = "collectables1",
    inventory = false,
    maxLimit = 1,
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    maxBoundCurrency = {
        ["PhunMart.TraiterToken"] = 20
    }
}, {
    abstract = true,
    inherits = "base-collectors-1",
    key = "base-collectors-2",
    tags = "collectables2"
}, {
    abstract = true,
    inherits = "base-collectors-1",
    key = "base-collectors-3",
    tags = "collectables3"
}, {
    abstract = true,
    key = "base-collectors-4",
    inherits = "base-collectors-1",
    tags = "collectables4"
}, {
    key = "base-collectors-scrap-gold",
    tab = "Scraps",
    tags = "scrap-gold",
    display = {
        label = "Base.GoldScraps",
        overlay = "cheese-token-overlay"
    },
    inventory = false,
    price = {
        ["Base.GoldScraps"] = 15
    },
    mod = "PhunStuff",
    receive = {{
        label = "PhunMart.CheeseToken",
        type = "ITEM"
    }}
}, {
    key = "base-collectors-scrap-silver",
    tab = "Scraps",
    tags = "scrap-silver",
    display = {
        label = "Base.SilverScraps",
        name = "Base.SilverScraps",
        type = "ITEM",
        overlay = "silver-dollar-overlay"
    },
    inventory = false,
    price = {
        ["Base.SilverScraps"] = 5
    },
    mod = "PhunStuff",
    receive = {{
        label = "PhunMart.SilverDollar",
        type = "ITEM"
    }}
}, {
    key = "base-collectors-scrap-gems",
    tab = "Scraps",
    tags = "scrap-gems",
    display = {
        label = "Base.GemScrap",
        overlay = "traiter-token-overlay"
    },
    inventory = false,
    price = {
        ["Base.GemScrap"] = 150
    },
    mod = "PhunStuff",
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }}
}, {

    inherits = "base-collectors-1",
    display = {
        label = "Base.StitchesPlushie",
        overlay = "traiter-token-overlay"
    },
    price = {
        ["Base.StitchesPlushie"] = 3
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    mod = "Authentic Z - Current"
}, {
    inherits = "base-collectors-1",
    display = {
        label = "Tsarcraft.CassetteBananaramaVenus",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tsarcraft.CassetteBananaramaVenus"] = 1
    },
    mod = "Music_Hits_And_More"

}, {
    inherits = "base-collectors-1",
    display = {
        label = "AuthenticZClothing.ToyBear",
        overlay = "traiter-token-overlay"
    },
    price = {
        ["AuthenticZClothing.ToyBear"] = 1
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    mod = "Authentic Z - Current"
}, {
    inherits = "base-collectors-1",
    display = {
        label = "RoundPlushies.Plushie_Cat3",
        overlay = "traiter-token-overlay"
    },
    price = {
        ["RoundPlushies.Plushie_Cat1/RoundPlushies.Plushie_Cat2/RoundPlushies.Plushie_Cat3"] = 1
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    mod = "RoundPlushies"
}, {
    inherits = "base-collectors-1",
    display = {
        label = "pkmncards.003Venusaurcard",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["pkmncards.003Venusaurcard"] = 2
    },
    mod = "tikitown"
}, {
    inherits = "base-collectors-1",
    display = {
        label = "AuthenticZClothing.GroguAZ",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["AuthenticZClothing.GroguAZ"] = 3
    },
    mod = "Authentic Z - Current"
}, {
    inherits = "base-collectors-1",
    display = {
        label = "AuthenticZClothing.Flamingo",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["AuthenticZClothing.Flamingo"] = 3
    },
    mod = "Authentic Z - Current"
}, {
    inherits = "base-collectors-1",
    display = {
        label = "AuthenticZClothing.OtisPug",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["AuthenticZClothing.OtisPug"] = 3
    },
    mod = "Authentic Z - Current"
}, {
    inherits = "base-collectors-1",
    display = {
        label = "UndeadSurvivor.BountyPhoto01",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["UndeadSurvivor.BountyPhoto01"] = 2
    },
    mod = "UndeadSuvivor"
}, {
    inherits = "base-collectors-1",
    display = {
        label = "UndeadSurvivor.BountyPhoto09",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["UndeadSurvivor.BountyPhoto09"] = 2
    },
    mod = "UndeadSuvivor"
}, {
    inherits = "base-collectors-1",
    display = {
        label = "pkmncards.006Charizardcard",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["pkmncards.006Charizardcard"] = 2
    },
    mod = "tikitown"
}, {

    inherits = "base-collectors-1",
    display = {
        label = "pkmncards.011Metapodcard",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["pkmncards.011Metapodcard"] = 2
    },
    mod = "tikitown"
}, {
    inherits = "base-collectors-1",
    display = {
        label = "JTG.DannyNews",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["JTG.DannyNews"] = 2
    },
    mod = "NorthKillian"

}, {
    inherits = "base-collectors-1",
    display = {
        label = "Tsarcraft.VinylDoctorWhoThemeSong(1963)",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tsarcraft.VinylDoctorWhoThemeSong(1963)"] = 2
    },
    mod = "Music_Hits_And_More"

}, {

    inherits = "base-collectors-1",
    display = {
        label = "Tsarcraft.VinylEddyGrantElectricAvenue",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tsarcraft.VinylEddyGrantElectricAvenue"] = 2
    },
    mod = "Music_Hits_And_More"

}, {
    inherits = "base-collectors-1",
    display = {
        label = "Tsarcraft.VinylNoDoubtJustAGirl",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tsarcraft.VinylNoDoubtJustAGirl"] = 2
    },
    mod = "Music_Hits_And_More"

}, {
    inherits = "base-collectors-2",
    display = {
        label = "MonmouthClothing.Hat_Silent_Bob",
        overlay = "traiter-token-overlay"
    },
    price = {
        ["MonmouthClothing.Hat_Silent_Bob"] = 1
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    mod = "MonmouthCounty_new"
}, {
    inherits = "base-collectors-2",
    display = {
        label = "Base.StitchesPlushie",
        overlay = "traiter-token-overlay"
    },
    price = {
        ["Base.StitchesPlushie"] = 3
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }}
}, {
    inherits = "base-collectors-2",
    display = {
        label = "UndeadSurvivor.BountyPhoto03",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["UndeadSurvivor.BountyPhoto03"] = 2
    },
    mod = "UndeadSuvivor"
}, {
    inherits = "base-collectors-2",
    display = {
        label = "UndeadSurvivor.BountyPhoto06",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["UndeadSurvivor.BountyPhoto06"] = 2
    },
    mod = "UndeadSuvivor"
}, {
    inherits = "base-collectors-2",
    display = {
        label = "Tsarcraft.VinylCyndiLauperGirlsJustWannaHaveFun",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tsarcraft.VinylCyndiLauperGirlsJustWannaHaveFun"] = 2
    },
    mod = "Music_Hits_And_More"

}, {
    inherits = "base-collectors-2",
    display = {
        label = "BZMClothing.SpiffoBatman",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["BZMClothing.SpiffoBatman/Base.BatmanPlushie"] = 2
    },
    mod = "MonmouthCounty_new"
}, {

    inherits = "base-collectors-2",
    display = {
        label = "RoundPlushies.Plushie_Chicken1",
        overlay = "traiter-token-overlay"
    },
    price = {
        ["RoundPlushies.Plushie_Chicken1/RoundPlushies.Plushie_Chicken2/RoundPlushies.Plushie_Chicken3"] = 1
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    mod = "RoundPlushies"

}, {
    inherits = "base-collectors-2",
    display = {
        label = "AuthenticZClothing.SpiffoHeart",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["AuthenticZClothing.SpiffoHeart"] = 2
    },
    mod = "Authentic Z - Current"
}, {
    inherits = "base-collectors-2",
    display = {
        label = "Tikitown.Baseball_Card_29",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tikitown.Baseball_Card_29"] = 2
    },
    mod = "tikitown"
}, {

    inherits = "base-collectors-2",
    display = {
        label = "pkmncards.014Kakunacard",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["pkmncards.014Kakunacard"] = 2
    },
    mod = "tikitown"
}, {

    inherits = "base-collectors-2",
    display = {
        label = "Tsarcraft.VinylLennyKravitzAreYouGonnaGoMyWay",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tsarcraft.VinylLennyKravitzAreYouGonnaGoMyWay"] = 2
    },
    mod = "Music_Hits_And_More"

}, {
    inherits = "base-collectors-2",
    display = {
        label = "Base.SpoonPic11",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Base.SpoonPic11"] = 1
    },
    mod = "PictureThis"

}, {

    inherits = "base-collectors-2",
    display = {
        label = "Base.SpoonPic10",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Base.SpoonPic10"] = 1
    },
    mod = "PictureThis"

}, {

    inherits = "base-collectors-2",
    display = {
        label = "Tsarcraft.VinylPrince1999",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tsarcraft.VinylPrince1999"] = 2
    },
    mod = "Music_Hits_And_More"

}, {
    inherits = "base-collectors-2",
    display = {
        label = "JTG.CMNews",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["JTG.CMNews"] = 2
    },
    mod = "NorthKillian"

}, {
    inherits = "base-collectors-2",
    display = {
        label = "Tsarcraft.VinylRobertPalmerAddictedToLove",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tsarcraft.VinylRobertPalmerAddictedToLove"] = 2
    },
    mod = "Music_Hits_And_More"

}, {

    inherits = "base-collectors-3",
    display = {
        label = "Base.Rubberducky",
        overlay = "traiter-token-overlay"
    },
    price = {
        ["Base.Rubberducky/BZMClothing.Rubberducky3/AuthenticZClothing.Rubberducky3/Base.Rubberducky2"] = 6
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }}
}, {
    inherits = "base-collectors-3",
    display = {
        label = "Tikitown.Baseball_Card_04",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tikitown.Baseball_Card_04"] = 2
    },
    mod = "tikitown"
}, {
    inherits = "base-collectors-3",
    display = {
        label = "Tikitown.Baseball_Card_07",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tikitown.Baseball_Card_07"] = 2
    },
    mod = "tikitown"
}, {
    inherits = "base-collectors-3",
    display = {
        label = "pkmncards.024Arbokcard",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["pkmncards.024Arbokcard"] = 2
    },
    mod = "tikitown"
}, {
    inherits = "base-collectors-3",
    display = {
        label = "Tikitown.Baseball_Card_19",
        overlay = "traiter-token-overlay"
    },
    price = {
        ["Tikitown.Baseball_Card_19"] = 2
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    mod = "tikitown"
}, {
    inherits = "base-collectors-3",
    display = {
        label = "Tikitown.Baseball_Card_25",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tikitown.Baseball_Card_25"] = 2
    },
    mod = "tikitown"
}, {
    inherits = "base-collectors-3",
    display = {
        label = "pkmncards.030Nidorinacard",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["pkmncards.030Nidorinacard"] = 2
    },
    mod = "tikitown"
}, {
    inherits = "base-collectors-3",
    display = {
        label = "Tikitown.Sorted_Full_Baseball_Card_Box",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tikitown.Sorted_Full_Baseball_Card_Box"] = 1
    },
    mod = "tikitown"

}, {

    inherits = "base-collectors-3",
    display = {
        label = "Tsarcraft.CassetteEddieMurphyPartyAlltheTime",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tsarcraft.CassetteEddieMurphyPartyAlltheTime"] = 3
    },
    mod = "Music_Hits_And_More"

}, {
    inherits = "base-collectors-3",
    display = {
        label = "AuthenticZClothing.SpiffoSanta",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["AuthenticZClothing.SpiffoSanta"] = 3
    },
    mod = "Authentic Z - Current"
}, {

    inherits = "base-collectors-3",
    display = {
        label = "RoundPlushies.Plushie_Dog2",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["RoundPlushies.Plushie_Dog1/RoundPlushies.Plushie_Dog2/RoundPlushies.Plushie_Dog3"] = 2
    },
    mod = "RoundPlushies"
}, {

    inherits = "base-collectors-3",
    display = {
        label = "RoundPlushies.Plushie_Sheep",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["BZMClothing.SheepPlushie/RoundPlushies.Plushie_Sheep"] = 3
    },
    mod = "RoundPlushies"
}, {
    inherits = "base-collectors-4",
    display = {
        label = "BZMClothing.SpiffoDredd",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["BZMClothing.SpiffoDredd"] = 1
    },
    mod = "MonmouthCounty_new"

}, {

    inherits = "base-collectors-4",
    display = {
        label = "Tikitown.Baseball_Card_19",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tikitown.Baseball_Card_19"] = 2
    },
    mod = "tikitown"
}, {
    inherits = "base-collectors-4",
    display = {
        label = "Base.SpoonPic2",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Base.SpoonPic2"] = 1
    },
    mod = "PictureThis"
}, {
    inherits = "base-collectors-4",
    display = {
        label = "Base.ChrisPic",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Base.ChrisPic"] = 1
    },
    mod = "PictureThis"
}, {

    inherits = "base-collectors-4",
    display = {
        label = "JTG.AlexNews",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["JTG.AlexNews"] = 2
    },
    mod = "NorthKillian"

}, {
    inherits = "base-collectors-4",
    display = {
        label = "Tsarcraft.VinylWhitneyHoustonHowWillIKnow",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tsarcraft.VinylWhitneyHoustonHowWillIKnow"] = 2
    },
    mod = "Music_Hits_And_More"

}, {

    inherits = "base-collectors-4",
    display = {
        label = "Tsarcraft.VinylWilsonPhillipsHoldOn",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tsarcraft.VinylWilsonPhillipsHoldOn"] = 2
    },
    mod = "Music_Hits_And_More"

}, {

    inherits = "base-collectors-4",
    display = {
        label = "Tsarcraft.VinylTheSpinnersWorkingmywaybacktoyou",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tsarcraft.VinylTheSpinnersWorkingmywaybacktoyou"] = 2
    },
    mod = "Music_Hits_And_More"

}, {
    inherits = "base-collectors-4",
    display = {
        label = "Tsarcraft.VinylStoneTemplePilotsPlush",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tsarcraft.VinylStoneTemplePilotsPlush"] = 2
    },
    mod = "Music_Hits_And_More"

}, {
    inherits = "base-collectors-4",
    display = {
        label = "pkmncards.148Dragonaircard",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["pkmncards.148Dragonaircard"] = 2
    },
    mod = "tikitown"
}, {
    inherits = "base-collectors-4",
    display = {
        label = "Base.ToyBear",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["BZMClothing.ToyBear/BZMClothing.ToyBearSmall/AuthenticZClothing.ToyBearSmall/AuthenticZClothing.ToyBear/Base.ToyBear"] = 6
    }
}, {
    inherits = "base-collectors-4",
    display = {
        label = "AuthenticZClothing.SpiffoShamrock",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["AuthenticZClothing.SpiffoShamrock"] = 3
    },
    mod = "Authentic Z - Current"
}, {
    inherits = "base-collectors-4",
    display = {
        label = "AuthenticZClothing.SpiffoPlushieRainbow",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["AuthenticZClothing.SpiffoPlushieRainbow"] = 3
    },
    mod = "Authentic Z - Current"
}}
