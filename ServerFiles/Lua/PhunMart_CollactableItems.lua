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
    }}
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
        ["Base.GoldScraps"] = 75
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
        ["Base.SilverScraps"] = 25
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
    inherits = "base-collectors-3",
    display = {
        label = "BZMClothing.Rubberducky3",
        overlay = "traiter-token-overlay"
    },
    price = {
        ["BZMClothing.Rubberducky3"] = 6
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    mod = "MonmouthCounty_new"
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
        label = "Tikitown.Baseball_Card_14",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tikitown.Baseball_Card_14"] = 2
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
        label = "Tikitown.Baseball_Card_32",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["Tikitown.Baseball_Card_32"] = 2
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
    inherits = "base-collectors-1",
    display = {
        label = "RoundPlushies.Plushie_Cat3",
        overlay = "traiter-token-overlay"
    },
    price = {
        ["RoundPlushies.Plushie_Cat3"] = 1
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    mod = "RoundPlushies"
}, {
    inherits = "base-collectors-2",
    display = {
        label = "RoundPlushies.Plushie_Chicken1",
        overlay = "traiter-token-overlay"
    },
    price = {
        ["RoundPlushies.Plushie_Chicken1"] = 1
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    mod = "RoundPlushies"
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
        ["RoundPlushies.Plushie_Dog2"] = 2
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
        ["RoundPlushies.Plushie_Sheep"] = 3
    },
    mod = "RoundPlushies"
}, {
    inherits = "base-collectors-4",
    display = {
        label = "BZMClothing.ToyBearSmall",
        overlay = "traiter-token-overlay"
    },
    receive = {{
        label = "PhunMart.TraiterToken",
        type = "ITEM"
    }},
    price = {
        ["BZMClothing.ToyBearSmall"] = 6
    },
    mod = "BZMClothing"
}}
