return {{
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-ammo:basic",
    inventory = {
        min = 2,
        max = 5
    },
    probability = 5,
    tab = "Ammo",
    tags = "ammo",
    price = {
        currency = {
            min = 10,
            max = 25
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-ammo:craft",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Crafting",
    tags = "ammocraft",
    price = {
        currency = {
            min = 5,
            max = 15
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-ammo:clip",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Clips",
    tags = "ammoclips",
    price = {
        currency = {
            min = 5,
            max = 15
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-explosives:misc",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Explosives",
    tags = "explosives",
    price = {
        currency = {
            min = 15,
            max = 25
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-weapon:rifle",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Rifles",
    tags = "rifles",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-weapon:misc",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Misc",
    tags = "melee",
    probability = 5,
    price = {
        currency = {
            min = 10,
            max = 25
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-weapon:shotgun",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Shotguns",
    tags = "shotguns",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-weapon:melee",
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
    key = "base-weapon:pistol",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Pistols",
    tag = "pistols",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-weaponpart:wear",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Outfits",
    tag = "outfits",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-weaponpart:attachment",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Attachments",
    tag = "attachments",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    name = "Base.Bayonnet",
    inherits = "base-weaponpart:attachment"
}, {
    name = "Base.ChokeTubeFull",
    inherits = "base-weaponpart:attachment"
}, {
    name = "Base.ChokeTubeImproved",
    inherits = "base-weaponpart:attachment"
}, {
    name = "Base.FiberglassStock",
    inherits = "base-weaponpart:attachment"
}, {
    name = "Base.GunLight",
    inherits = "base-weaponpart:attachment"
}, {
    name = "Base.IronSight",
    inherits = "base-weaponpart:attachment"
}, {
    name = "Base.Laser",
    inherits = "base-weaponpart:attachment"
}, {
    name = "Base.RecoilPad",
    inherits = "base-weaponpart:attachment"
}, {
    name = "Base.RedDot",
    inherits = "base-weaponpart:attachment"
}, {
    name = "Base.Sling",
    inherits = "base-weaponpart:attachment"
}, {
    name = "Base.x2Scope",
    inherits = "base-weaponpart:attachment"
}, {
    name = "Base.x4Scope",
    inherits = "base-weaponpart:attachment"
}, {
    name = "Base.x8Scope",
    inherits = "base-weaponpart:attachment"
}, {
    name = "Base.223Box",
    inherits = "base-ammo:basic"
}, {
    name = "Base.223Bullets",
    inherits = "base-ammo:basic"
}, {
    name = "Base.308Box",
    inherits = "base-ammo:basic"
}, {
    name = "Base.308Bullets",
    inherits = "base-ammo:basic"
}, {
    name = "Base.556Box",
    inherits = "base-ammo:basic"
}, {
    name = "Base.556Bullets",
    inherits = "base-ammo:basic"
}, {
    name = "Base.Bullets38",
    inherits = "base-ammo:basic"
}, {
    name = "Base.Bullets38Box",
    inherits = "base-ammo:basic"
}, {
    name = "Base.Bullets44",
    inherits = "base-ammo:basic"
}, {
    name = "Base.Bullets44Box",
    inherits = "base-ammo:basic"
}, {
    name = "Base.Bullets45",
    inherits = "base-ammo:basic"
}, {
    name = "Base.Bullets45Box",
    inherits = "base-ammo:basic"
}, {
    name = "Base.Bullets9mm",
    inherits = "base-ammo:basic"
}, {
    name = "Base.Bullets9mmBox",
    inherits = "base-ammo:basic"
}, {
    name = "Base.ShotgunShells",
    inherits = "base-ammo:basic"
}, {
    name = "Base.ShotgunShellsBox",
    inherits = "base-ammo:basic"
}, {
    name = "Base.223Clip",
    inherits = "base-ammo:clip"
}, {
    name = "Base.308Clip",
    inherits = "base-ammo:clip"
}, {
    name = "Base.44Clip",
    inherits = "base-ammo:clip"
}, {
    name = "Base.45Clip",
    inherits = "base-ammo:clip"
}, {
    name = "Base.556Clip",
    inherits = "base-ammo:clip"
}, {
    name = "Base.9mmClip",
    inherits = "base-ammo:clip"
}, {
    name = "Base.M14Clip",
    inherits = "base-ammo:clip"
}, {
    name = "Base.223BulletsMold",
    inherits = "base-ammo:craft"
}, {
    name = "Base.308BulletsMold",
    inherits = "base-ammo:craft"
}, {
    name = "Base.9mmBulletsMold",
    inherits = "base-ammo:craft"
}, {
    name = "Base.ShotgunShellsMold",
    inherits = "base-ammo:craft"
}, {
    name = "Base.HuntingKnife",
    inherits = "base-weapon:melee"
}, {
    name = "Base.Katana",
    inherits = "base-weapon:melee"
}, {
    name = "Base.LeadPipe",
    inherits = "base-weapon:melee"
}, {
    name = "Base.Machete",
    inherits = "base-weapon:melee"
}, {
    name = "Base.MetalBar",
    inherits = "base-weapon:melee"
}, {
    name = "Base.MetalPipe",
    inherits = "base-weapon:melee"
}, {
    name = "Base.Nightstick",
    inherits = "base-weapon:melee"
}, {
    name = "Base.Aerosolbomb",
    inherits = "base-explosives:misc"
}, {
    name = "Base.FlameTrap",
    inherits = "base-explosives:misc"
}, {
    name = "Base.FlameTrapRemote",
    inherits = "base-explosives:misc"
}, {
    name = "Base.FlameTrapTriggered",
    inherits = "base-explosives:misc"
}, {
    name = "Base.Molotov",
    inherits = "base-explosives:misc"
}, {
    name = "Base.NoiseTrap",
    inherits = "base-explosives:misc"
}, {
    name = "Base.NoiseTrapRemote",
    inherits = "base-explosives:misc"
}, {
    name = "Base.PipeBomb",
    inherits = "base-explosives:misc"
}, {
    name = "Base.PipeBombRemote",
    inherits = "base-explosives:misc"
}, {
    name = "Base.SmokeBomb",
    inherits = "base-explosives:misc"
}, {
    name = "Base.SmokeBombRemote",
    inherits = "base-explosives:misc"
}, {
    name = "Base.Chainsaw",
    inherits = "base-weapon:misc"
}, {
    name = "Base.Pistol",
    inherits = "base-weapon:pistol"
}, {
    name = "Base.Pistol2",
    inherits = "base-weapon:pistol"
}, {
    name = "Base.Pistol3",
    inherits = "base-weapon:pistol"
}, {
    name = "Base.Revolver",
    inherits = "base-weapon:pistol"
}, {
    name = "Base.Revolver_Long",
    inherits = "base-weapon:pistol"
}, {
    name = "Base.Revolver_Short",
    inherits = "base-weapon:pistol"
}, {
    name = "Base.AssaultRifle",
    inherits = "base-weapon:rifle"
}, {
    name = "Base.AssaultRifle2",
    inherits = "base-weapon:rifle"
}, {
    name = "Base.HuntingRifle",
    inherits = "base-weapon:rifle"
}, {
    name = "Base.VarmintRifle",
    inherits = "base-weapon:rifle"
}, {
    name = "Base.DoubleBarrelShotgun",
    inherits = "base-weapon:shotgun"
}, {
    name = "Base.DoubleBarrelShotgunSawnoff",
    inherits = "base-weapon:shotgun"
}, {
    name = "Base.Shotgun",
    inherits = "base-weapon:shotgun"
}, {
    name = "Base.ShotgunSawnoff",
    inherits = "base-weapon:shotgun"
}, {
    name = "Base.AmmoStraps",
    inherits = "base-weaponpart:wear"
}}
