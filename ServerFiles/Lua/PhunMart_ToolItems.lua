return {{
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-tool:welding",
    inventory = {
        min = 2,
        max = 5
    },
    probability = 5,
    tab = "Welding",
    tags = "welding",
    price = {
        currency = {
            min = 10,
            max = 25
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-tool:basic",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Misc",
    tags = "tools",
    price = {
        currency = {
            min = 5,
            max = 15
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-toolweapon:basic",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Misc",
    tags = "tools",
    price = {
        currency = {
            min = 5,
            max = 15
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-toolweapon:weapon",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Melee",
    tags = "melee",
    price = {
        currency = {
            min = 15,
            max = 25
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-tool:weapon",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Melee",
    tags = "melee",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-camping:camping",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Camping",
    tags = "camping",
    probability = 5,
    price = {
        currency = {
            min = 10,
            max = 25
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-tool:mec",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Mechanics",
    tags = "mechanics",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-toolweapon:melee",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Melee",
    tags = "melee",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-tool:tailoring",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Tailoring",
    tag = "tailoring",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    name = "Base.WeldingMask",
    inherits = "base-tool:welding"
}, {
    name = "Base.Tongs",
    inherits = "base-tool:basic"
}, {
    name = "Base.Screwdriver",
    inherits = "base-toolweapon:basic"
}, {
    name = "Base.ClubHammer",
    inherits = "base-toolweapon:basic"
}, {
    name = "Base.Sledgehammer",
    inherits = "base-toolweapon:basic"
}, {
    name = "Base.BallPeenHammer",
    inherits = "base-toolweapon:basic"
}, {
    name = "Base.Wrench",
    inherits = "base-toolweapon:basic"
}, {
    name = "Base.Axe",
    inherits = "base-toolweapon:weapon"
}, {
    name = "Base.Paintbrush",
    inherits = "base-tool:basic"
}, {
    name = "Base.HammerStone",
    inherits = "base-toolweapon:basic"
}, {
    name = "Base.WoodenMallet",
    inherits = "base-toolweapon:basic"
}, {
    name = "Base.HandAxe",
    inherits = "base-toolweapon:weapon"
}, {
    name = "Base.HandScythe",
    inherits = "base-toolweapon:weapon"
}, {
    name = "Base.Saw",
    inherits = "base-tool:basic"
}, {
    name = "Base.LugWrench",
    inherits = "base-tool:weapon"
}, {
    name = "Base.WoodAxe",
    inherits = "base-toolweapon:weapon"
}, {
    name = "Base.PercedWood",
    inherits = "base-camping:camping"
}, {
    name = "Base.HandFork",
    inherits = "base-toolweapon:weapon"
}, {
    name = "Base.Hammer",
    inherits = "base-toolweapon:basic"
}, {
    name = "Base.TirePump",
    inherits = "base-tool:mec"
}, {
    name = "Base.AxeStone",
    inherits = "base-toolweapon:weapon"
}, {
    name = "Base.PipeWrench",
    inherits = "base-toolweapon:weapon"
}, {
    name = "Base.CarBatteryCharger",
    inherits = "base-tool:mec"
}, {
    name = "Base.SnowShovel",
    inherits = "base-toolweapon:weapon"
}, {
    name = "Base.Sledgehammer2",
    inherits = "base-toolweapon:basic"
}, {
    name = "Base.PickAxe",
    inherits = "base-toolweapon:weapon"
}, {
    name = "Base.Jack",
    inherits = "base-tool:mec"
}, {
    name = "Base.Crowbar",
    inherits = "base-toolweapon:melee"
}, {
    name = "Base.FireWoodKit",
    inherits = "base-camping:camping"
}, {
    name = "Base.Needle",
    inherits = "base-tool:tailoring"
}, {
    name = "Base.BlowTorch",
    inherits = "base-tool:welding"
}, {
    name = "Base.GardenSaw",
    inherits = "base-tool:basic"
}, {
    name = "camping.CampingTent",
    inherits = "base-camping:camping"
}, {
    name = "camping.CampingTentKit",
    inherits = "base-camping:camping"
}, {
    name = "camping.CampfireKit",
    inherits = "base-camping:camping"
}}
