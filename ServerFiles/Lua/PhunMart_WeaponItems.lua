return {{
    abstract = true,
    key = "base-weapons",
    tab = "Weapons",
    tags = "weapons",
    inventory = {
        min = 1,
        max = 5
    },
    price = {
        currency = {
            base = 1,
            min = 3,
            max = 5
        }
    }
}, {
    abstract = true,
    key = "base-weapons-wepmelee",
    inherits = "base-weapons",
    tab = "Melee",
    tags = "weapons,wepmelee"
}, {
    abstract = true,
    key = "base-weapons-wepexplosive",
    inherits = "base-weapons",
    tab = "Explosive",
    tags = "weapons,wepexplosive"
}, {
    abstract = true,
    key = "base-weapons-wepcrafting",
    inherits = "base-weapons",
    tab = "Crafting",
    tags = "weapons,wepcrafting"
}, {
    abstract = true,
    key = "base-weapons-wepbulkammo",
    inherits = "base-weapons",
    tags = "weapons,wepbulkammo"
}, {
    abstract = true,
    key = "base-weapons-wepammo",
    inherits = "base-weapons",
    tab = "Ammo",
    tags = "weapons,wepammo"
}, {
    abstract = true,
    key = "base-weapons-wepaccessory",
    inherits = "base-weapons",
    tags = "weapons,wepaccessory"
}, {
    abstract = true,
    key = "base-weapons-wepmisc",
    inherits = "base-weapons",
    tab = "Misc",
    tags = "weapons,wepmisc"
}, {
    abstract = true,
    key = "base-weapons-weppistol",
    inherits = "base-weapons",
    tab = "Pistol",
    tags = "weapons,weppistol"
}, {
    abstract = true,
    key = "base-weapons-wepshotgun",
    inherits = "base-weapons",
    tab = "Shotgun",
    tags = "weapons,wepshotgun"
}, {
    abstract = true,
    key = "base-weapons-weprifle",
    inherits = "base-weapons",
    tab = "Rifle",
    tags = "weapons,weprifle"
}, {
    name = "Base.RecoilPad",
    inherits = "base-weapons-wepaccessory"
}, {
    name = "Base.GunLight",
    inherits = "base-weapons-wepaccessory"
}, {
    name = "Base.x2Scope",
    inherits = "base-weapons-wepaccessory"
}, {
    name = "Base.x8Scope",
    inherits = "base-weapons-wepaccessory"
}, {
    name = "Base.FiberglassStock",
    inherits = "base-weapons-wepaccessory"
}, {
    name = "Base.RedDot",
    inherits = "base-weapons-wepaccessory"
}, {
    name = "Base.Laser",
    inherits = "base-weapons-wepaccessory"
}, {
    name = "Base.IronSight",
    inherits = "base-weapons-wepaccessory"
}, {
    name = "Base.Bayonnet",
    inherits = "base-weapons-wepaccessory"
}, {
    name = "Base.ChokeTubeFull",
    inherits = "base-weapons-wepaccessory"
}, {
    name = "Base.ChokeTubeImproved",
    inherits = "base-weapons-wepaccessory"
}, {
    name = "Base.x4Scope",
    inherits = "base-weapons-wepaccessory"
}, {
    name = "Base.556Bullets",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.Bullets9mm",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.M14Clip",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.308Clip",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.223Clip",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.Bullets44",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.Bullets45",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.556Clip",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.Bullets38",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.223Bullets",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.9mmClip",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.44Clip",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.308Bullets",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.ShotgunShells",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.45Clip",
    inherits = "base-weapons-wepammo"
}, {
    name = "Base.Bullets38Box",
    inherits = "base-weapons-wepbulkammo"
}, {
    name = "Base.223Box",
    inherits = "base-weapons-wepbulkammo"
}, {
    name = "Base.ShotgunShellsBox",
    inherits = "base-weapons-wepbulkammo"
}, {
    name = "Base.Bullets45Box",
    inherits = "base-weapons-wepbulkammo"
}, {
    name = "Base.Bullets44Box",
    inherits = "base-weapons-wepbulkammo"
}, {
    name = "Base.556Box",
    inherits = "base-weapons-wepbulkammo"
}, {
    name = "Base.Bullets9mmBox",
    inherits = "base-weapons-wepbulkammo"
}, {
    name = "Base.308Box",
    inherits = "base-weapons-wepbulkammo"
}, {
    name = "Base.223BulletsMold",
    inherits = "base-weapons-wepcrafting"
}, {
    name = "Base.308BulletsMold",
    inherits = "base-weapons-wepcrafting"
}, {
    name = "Base.ShotgunShellsMold",
    inherits = "base-weapons-wepcrafting"
}, {
    name = "Base.9mmBulletsMold",
    inherits = "base-weapons-wepcrafting"
}, {
    name = "Base.PipeBomb",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.SmokeBombTriggered",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.AerosolbombTriggered",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.NoiseTrap",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.NoiseTrapSensorV2",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.NoiseTrapSensorV1",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.NoiseTrapSensorV3",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.Aerosolbomb",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.AerosolbombRemote",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.NoiseTrapTriggered",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.SmokeBombSensorV3",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.SmokeBombSensorV1",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.SmokeBombSensorV2",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.SmokeBombRemote",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.FlameTrapSensorV3",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.FlameTrapSensorV2",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.FlameTrapSensorV1",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.FlameTrapTriggered",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.PipeBombRemote",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.PipeBombSensorV1",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.PipeBombSensorV2",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.PipeBombSensorV3",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.AerosolbombSensorV3",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.AerosolbombSensorV1",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.AerosolbombSensorV2",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.FlameTrapRemote",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.FlameTrap",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.NoiseTrapRemote",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.Molotov",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.PipeBombTriggered",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.SmokeBomb",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.AmmoStraps",
    inherits = "base-weapons-wepexplosive"
}, {
    name = "Base.SpearHandFork",
    inherits = "base-weapons-wepmelee"
}, {
    name = "SapphCooking.SpearChefKnife1",
    inherits = "base-weapons-wepmelee",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SpearChefKnife2",
    inherits = "base-weapons-wepmelee",
    mod = "sapphcooking"
}, {
    name = "Base.Stake",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.PlankNail",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SpearFork",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.Nightstick",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SpearHuntingKnife",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SmashedBottle",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SpearScrewdriver",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SpearCrafted",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.Katana",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SpearScalpel",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.FlintKnife",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SpearIcePick",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SpearBreadKnife",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SpearSpoon",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.LeadPipe",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SpearScissors",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.HuntingKnife",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SpearMachete",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.Machete",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SpearKnife",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.TableLeg",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.BaseballBatNails",
    inherits = "base-weapons-wepmelee"
}, {
    name = "SapphCooking.SpearChefKnife3",
    inherits = "base-weapons-wepmelee",
    mod = "sapphcooking"
}, {
    name = "Base.DoubleBarrelShotgun",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.MetalBar",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.Chainsaw",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.MetalPipe",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.PickAxeHandleSpiked",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.DoubleBarrelShotgunSawnoff",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SpearLetterOpener",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.WoodenLance",
    inherits = "base-weapons-wepmelee"
}, {
    name = "Base.SpearButterKnife",
    inherits = "base-weapons-wepmelee"
}, {
    name = "SapphCooking.ChefKnife1",
    inherits = "base-weapons-wepmelee",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ChefKnife2",
    inherits = "base-weapons-wepmelee",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ChefKnife3",
    inherits = "base-weapons-wepmelee",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SpearSpork",
    inherits = "base-weapons-wepmelee",
    mod = "sapphcooking"
}, {
    name = "Base.Sling",
    inherits = "base-weapons-wepmisc"
}, {
    name = "Base.Revolver_Long",
    inherits = "base-weapons-weppistol"
}, {
    name = "Base.Revolver_Short",
    inherits = "base-weapons-weppistol"
}, {
    name = "Base.Pistol3",
    inherits = "base-weapons-weppistol"
}, {
    name = "Base.Pistol",
    inherits = "base-weapons-weppistol"
}, {
    name = "Base.Revolver",
    inherits = "base-weapons-weppistol"
}, {
    name = "Base.Pistol2",
    inherits = "base-weapons-weppistol"
}, {
    name = "Base.AssaultRifle",
    inherits = "base-weapons-weprifle"
}, {
    name = "Base.VarmintRifle",
    inherits = "base-weapons-weprifle"
}, {
    name = "Base.AssaultRifle2",
    inherits = "base-weapons-weprifle"
}, {
    name = "Base.HuntingRifle",
    inherits = "base-weapons-weprifle"
}, {
    name = "Base.ShotgunSawnoff",
    inherits = "base-weapons-wepshotgun"
}, {
    name = "Base.Shotgun",
    inherits = "base-weapons-wepshotgun"
}}
