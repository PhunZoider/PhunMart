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
            base = 10,
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
    tags = "weapons,wepbulkammo",
    price = {
        ["PhunMart.SilverDollar"] = {
            base = 20,
            min = 3,
            max = 5
        }
    }
}, {
    abstract = true,
    key = "base-weapons-packammo",
    inherits = "base-weapons",
    tags = "weapons,wepbulkammo",
    price = {
        ["PhunMart.SilverDollar"] = {
            base = 80,
            min = 10,
            max = 20
        }
    }
}, {
    abstract = true,
    key = "base-weapons-wepcrateammo",
    inherits = "base-weapons",
    tags = "weapons,wepbulkammo",
    price = {
        ["PhunMart.SilverDollar"] = {
            base = 1200,
            min = 100,
            max = 300
        }
    }
}, {
    abstract = true,
    key = "base-weapons-clips",
    inherits = "base-weapons",
    tab = "Clips",
    tags = "weapons,wepammo"
}, {
    abstract = true,
    key = "base-weapons-wepammo",
    inherits = "base-weapons",
    tab = "Ammo",
    tags = "weapons,wepammo",
    price = {
        ["PhunMart.SilverDollar"] = {
            base = 10,
            min = 3,
            max = 5
        }
    }
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
    inherits = "base-weapons-wepammo",
    quantity = 10
}, {
    name = "Base.Bullets9mm",
    inherits = "base-weapons-wepammo",
    quantity = 10
}, {
    name = "Base.M14Clip",
    inherits = "base-weapons-clips"
}, {
    name = "Base.308Clip",
    inherits = "base-weapons-clips"
}, {
    name = "Base.223Clip",
    inherits = "base-weapons-clips"
}, {
    name = "Base.Bullets44",
    inherits = "base-weapons-wepammo",
    quantity = 10
}, {
    name = "Base.Bullets45",
    inherits = "base-weapons-wepammo",
    quantity = 10
}, {
    name = "Base.556Clip",
    inherits = "base-weapons-clips"
}, {
    name = "Base.Bullets38",
    inherits = "base-weapons-wepammo",
    quantity = 10
}, {
    name = "Base.223Bullets",
    inherits = "base-weapons-wepammo",
    quantity = 10
}, {
    name = "Base.9mmClip",
    inherits = "base-weapons-clips"
}, {
    name = "Base.44Clip",
    inherits = "base-weapons-clips"
}, {
    name = "Base.308Bullets",
    inherits = "base-weapons-wepammo",
    quantity = 10
}, {
    name = "Base.ShotgunShells",
    inherits = "base-weapons-wepammo",
    quantity = 10
}, {
    name = "Base.45Clip",
    inherits = "base-weapons-clips"
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
}, {
    name = "VFECombination.Combination556M16Magazine_20",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "Base.1022",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.SKS",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.38Case",
    inherits = "base-weapons-wepbulkammo",
    mod = "VFExpansion1"
}, {
    name = "Base.308Case",
    inherits = "base-weapons-wepbulkammo",
    mod = "VFExpansion1"
}, {
    name = "Base.Spas12",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.9mmPack",
    inherits = "base-weapons-packammo",
    mod = "VFExpansion1"
}, {
    name = "Base.9mmCrate",
    inherits = "base-weapons-wepcrateammo",
    mod = "VFExpansion1"
}, {
    name = "Base.Coupled556",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.308Crate",
    inherits = "base-weapons-wepcrateammo",
    mod = "VFExpansion1"
}, {
    name = "Base.CampCarbine",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.22Pack",
    inherits = "base-weapons-packammo",
    mod = "VFExpansion1"
}, {
    name = "Base.MP5SD",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.762Pack",
    inherits = "base-weapons-packammo",
    mod = "VFExpansion1"
}, {
    name = "Base.TheZapper",
    inherits = "base-weapons",
    mod = "Pitstop"
}, {
    name = "Base.M41APulse",
    inherits = "base-weapons",
    mod = "Pitstop"
}, {
    name = "Base.M16Bayonet",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.44Crate",
    inherits = "base-weapons-wepcrateammo",
    mod = "VFExpansion1"
}, {
    name = "Base.556Crate",
    inherits = "base-weapons-wepcrateammo",
    mod = "VFExpansion1"
}, {
    name = "Base.M60_Link",
    inherits = "base-weapons",
    mod = "VFExpansion1",
    quantity = 10
}, {
    name = "Base.44Pack",
    inherits = "base-weapons-packammo",
    mod = "VFExpansion1"
}, {
    name = "Base.BuckRogersGun",
    inherits = "base-weapons",
    mod = "Pitstop"
}, {
    name = "Base.223Crate",
    inherits = "base-weapons-wepcrateammo",
    mod = "VFExpansion1"
}, {
    name = "Base.MK23SOCOM",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.45Crate",
    inherits = "base-weapons-wepcrateammo",
    mod = "VFExpansion1"
}, {
    name = "Base.38Crate",
    inherits = "base-weapons-wepcrateammo",
    mod = "VFExpansion1"
}, {
    name = "Base.MekLeth",
    inherits = "base-weapons",
    mod = "PertsPartyTiles"
}, {
    name = "Base.MK2",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.M60_Link_Die",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.MP5",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.CAR15DFolded",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.223Pack",
    inherits = "base-weapons-packammo",
    mod = "VFExpansion1"
}, {
    name = "Base.Mini14Unfolded",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.Coupled762",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.MK2SD",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.AK47",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.Boltgun",
    inherits = "base-weapons",
    mod = "Pitstop"
}, {
    name = "Base.MAC10Unfolded",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.CZ75",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.22Case",
    inherits = "base-weapons-wepbulkammo",
    mod = "VFExpansion1"
}, {
    name = "Base.SKSSpiker",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.MAC10Folded",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.Glock",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.44Case",
    inherits = "base-weapons-wepbulkammo",
    mod = "VFExpansion1"
}, {
    name = "Base.FAL",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.CAR15",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.762Case",
    inherits = "base-weapons-wepbulkammo",
    mod = "VFExpansion1"
}, {
    name = "Base.MP5Unfolded",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "VFECombination.Combination556M16Magazine_21",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "Base.45Pack",
    inherits = "base-weapons-packammo",
    mod = "VFExpansion1"
}, {
    name = "Base.Rusty",
    inherits = "base-weapons",
    mod = "NewEkron"
}, {
    name = "Base.556Case",
    inherits = "base-weapons-wepbulkammo",
    mod = "VFExpansion1"
}, {
    name = "Base.Mini14Folded",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.Glock18",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.223Case",
    inherits = "base-weapons-wepbulkammo",
    mod = "VFExpansion1"
}, {
    name = "Base.ShellHolder",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.AK47Folded",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.762Crate",
    inherits = "base-weapons-wepcrateammo",
    mod = "VFExpansion1"
}, {
    name = "Base.MP5Folded",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.Mini14",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.Fisticuffs",
    inherits = "base-weapons",
    mod = "BrutalHandwork"
}, {
    name = "Base.45Case",
    inherits = "base-weapons-wepbulkammo",
    mod = "VFExpansion1"
}, {
    name = "Base.Tec9",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.M60MMG_Bipod",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.E11Blaster",
    inherits = "base-weapons",
    mod = "Pitstop"
}, {
    name = "Base.38Pack",
    inherits = "base-weapons-packammo",
    mod = "VFExpansion1"
}, {
    name = "Base.CAR15D",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.9mmCase",
    inherits = "base-weapons-wepbulkammo",
    mod = "VFExpansion1"
}, {
    name = "Base.308Pack",
    inherits = "base-weapons-packammo",
    mod = "VFExpansion1"
}, {
    name = "Base.SKSSpikerBayonet",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.556Pack",
    inherits = "base-weapons-packammo",
    mod = "VFExpansion1"
}, {
    name = "Base.UziUnfolded",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.MP5HK",
    inherits = "base-weapons",
    mod = "Pitstop"
}, {
    name = "Base.22Crate",
    inherits = "base-weapons-wepcrateammo",
    mod = "VFExpansion1"
}, {
    name = "Base.Spas12Folded",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.CAR15Folded",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.FALClassic",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.AK47Unfolded",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.P229",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.M60MMG",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "Base.UziFolded",
    inherits = "base-weapons",
    mod = "VFExpansion1"
}, {
    name = "UndeadSurvivor.DruidBow(WIP)",
    inherits = "base-weapons",
    mod = "UndeadSuvivor"
}, {
    name = "BZMFirearms.LawgiverMKII2012",
    inherits = "base-weapons",
    mod = "MonmouthCounty_new"
}, {
    name = "Tikitown.Tikitorch_Brown",
    inherits = "base-weapons",
    mod = "tikitown"
}, {
    name = "Tikitown.Tikitorch_Special",
    inherits = "base-weapons",
    mod = "tikitown"
}, {
    name = "Tikitown.Tikitorch_Red",
    inherits = "base-weapons",
    mod = "tikitown"
}, {
    name = "Tikitown.Tikitorch_Base",
    inherits = "base-weapons",
    mod = "tikitown"
}, {
    name = "Tikitown.Tikitorch_Blue",
    inherits = "base-weapons",
    mod = "tikitown"
}, {
    name = "SOMW.GardenShearBlade",
    inherits = "base-weapons",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.LShapedLugWrench",
    inherits = "base-weapons",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.ShortTreeBranch",
    inherits = "base-weapons",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.SharpTrowel",
    inherits = "base-weapons",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.Kukri",
    inherits = "base-weapons",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "VFECombination.Combination556M16Magazine_25",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_24",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_23",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_22",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_29",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_28",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_27",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_26",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_9",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_8",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_1",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_0",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_3",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_2",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_5",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_10",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_4",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_31",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_7",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_30",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_6",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_14",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_13",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_12",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_11",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_18",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_17",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_16",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_15",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.Combination556M16Magazine_19",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "Base.HeadhunterScope",
    inherits = "base-weapons-wepaccessory",
    mod = "UndeadSuvivor"
}, {
    name = "Base.ShotgunSawnoffNoStock",
    inherits = "base-weapons-wepaccessory",
    mod = "VFExpansion1"
}, {
    name = "Tikitown.LaserTag_Cartridge",
    inherits = "base-weapons-wepaccessory",
    mod = "tikitown"
}, {
    name = "Tikitown.LaserTag_Gun",
    inherits = "base-weapons-wepaccessory",
    mod = "tikitown"
}, {
    name = "Base.DoubleBarrelShotgunSawnoffNoStock",
    inherits = "base-weapons-wepaccessory",
    mod = "VFExpansion1"
}, {
    name = "Base.308BulletsLinked",
    inherits = "base-weapons-wepammo",
    mod = "VFExpansion1",
    quantity = 10
}, {
    name = "Base.ShotgunShellsCase",
    inherits = "base-weapons-wepbulkammo",
    mod = "VFExpansion1"
}, {
    name = "Base.FALClip",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1"
}, {
    name = "Base.ShotgunShellsCrate",
    inherits = "base-weapons-wepcrateammo",
    mod = "VFExpansion1"
}, {
    name = "VFECombination.Combination556M16NoClip_1",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.CombinationShotgunShellNoClip_1",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "Base.ShotgunShellsPack",
    inherits = "base-weapons-packammo",
    mod = "VFExpansion1"
}, {
    name = "Base.762Bullets",
    inherits = "base-weapons-wepammo",
    mod = "VFExpansion1",
    quantity = 10
}, {
    name = "Base.22Bullets",
    inherits = "base-weapons-wepammo",
    mod = "VFExpansion1",
    quantity = 10
}, {
    name = "VFECombination.CombinationM500ShotgunShellNoClip_4",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.CombinationM500ShotgunShellNoClip_3",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.CombinationM500ShotgunShellNoClip_2",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "VFECombination.CombinationM500ShotgunShellNoClip_1",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "BZMFirearms.LawgiverMKII2012Clip",
    inherits = "base-weapons-clips",
    mod = "MonmouthCounty_new"
}, {
    name = "VFECombination.Combination308NoClip_1",
    inherits = "base-weapons-clips",
    mod = "VFExpansion1",
    enabled = false
}, {
    name = "Base.M60_Links_Box",
    inherits = "base-weapons-wepbulkammo",
    mod = "VFExpansion1"
}, {
    name = "Base.22Box",
    inherits = "base-weapons-wepbulkammo",
    mod = "VFExpansion1"
}, {
    name = "Base.762Box",
    inherits = "base-weapons-wepbulkammo",
    mod = "VFExpansion1"
}, {
    name = "Vac.44MagnumBulletsMold",
    inherits = "base-weapons-wepcrafting",
    mod = "vac"
}, {
    name = "Vac.762BulletsMold",
    inherits = "base-weapons-wepcrafting",
    mod = "vac_vfe_patch"
}, {
    name = "Vac.38SpecialBulletsMold",
    inherits = "base-weapons-wepcrafting",
    mod = "vac"
}, {
    name = "Vac.556mmBulletsMold",
    inherits = "base-weapons-wepcrafting",
    mod = "vac"
}, {
    name = "Vac.22BulletsMold",
    inherits = "base-weapons-wepcrafting",
    mod = "vac_vfe_patch"
}, {
    name = "Vac.45AutoBulletsMold",
    inherits = "base-weapons-wepcrafting",
    mod = "vac"
}, {
    name = "Base.ShellStraps",
    inherits = "base-weapons-wepexplosive",
    mod = "VFExpansion1"
}, {
    name = "MonmouthWeapons.SpearGungnir",
    inherits = "base-weapons-wepmelee",
    mod = "MonmouthCounty_new"
}, {
    name = "Base.SpearBayonet",
    inherits = "base-weapons-wepmelee",
    mod = "VFExpansion1"
}, {
    name = "SOMW.LongMetalBar",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpearCampyKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.SpearMilitaryKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.LongLeadPipe",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.SpearKukri",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpearKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpearMilitaryMachete",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpearTantoKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.ShovelAxe",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.BaseballBatBarbedWire",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpearHuntingKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpearMachete",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.ButterflyKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.SpearSharpTrowel",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpear",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.SpearGardenShearBlade",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpearIcePick",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.MilitaryMachete",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.MilitaryKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.SpearMilitaryMachete",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.CricketBat",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpearSharpTrowel",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.CombatKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.Shovel2Axe",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.LongMetalPipe",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpearHandFork",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpearBreadKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.ShovelSpear",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.SpearCombatKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.TantoKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "Base.556BattlePack",
    inherits = "base-weapons-packammo",
    mod = "VFExpansion1"
}, {
    name = "SOMW.CricketBatNails",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.BaseballBatWire",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.SpearCampyKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.HalfPlank",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpearMilitaryKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.SpearTantoKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "UndeadSurvivor.PrepperKnifeSwing",
    inherits = "base-weapons-wepmelee",
    mod = "UndeadSuvivor"
}, {
    name = "UndeadSurvivor.StalkerKnife",
    inherits = "base-weapons-wepmelee",
    mod = "UndeadSuvivor"
}, {
    name = "SOMW.CampyKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpearScrewdriver",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "UndeadSurvivor.AmazonaSpear",
    inherits = "base-weapons-wepmelee",
    mod = "UndeadSuvivor"
}, {
    name = "SOMW.BaseballBatScrews",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "UndeadSurvivor.PrepperKnifeKnock",
    inherits = "base-weapons-wepmelee",
    mod = "UndeadSuvivor"
}, {
    name = "SOMW.PlankSpearKukri",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "UndeadSurvivor.PrepperKnifeStab",
    inherits = "base-weapons-wepmelee",
    mod = "UndeadSuvivor"
}, {
    name = "SOMW.SpearChippedStone",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.PlankSpearGardenShearBlade",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "Tikitown.TikitownBattery",
    inherits = "base-weapons-wepmelee",
    mod = "tikitown"
}, {
    name = "SOMW.PlankSpearCombatKnife",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.HalfPlankNails",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.Shovel2Spear",
    inherits = "base-weapons-wepmelee",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "Base.AZZK_pistol",
    inherits = "base-weapons-weppistol",
    mod = "PertsPartyTiles"
}, {
    name = "Base.FutureRevolver",
    inherits = "base-weapons-weppistol",
    mod = "Pitstop"
}, {
    name = "Base.CyberPistol",
    inherits = "base-weapons-weppistol",
    mod = "Pitstop"
}, {
    name = "Base.M2400_Rifle",
    inherits = "base-weapons-weprifle",
    mod = "VFExpansion1"
}, {
    name = "Base.AssaultRifleMasterkey",
    inherits = "base-weapons-weprifle",
    mod = "VFExpansion1"
}, {
    name = "Base.DeadlyHeadhunterRifle",
    inherits = "base-weapons-weprifle",
    mod = "UndeadSuvivor"
}, {
    name = "Base.SniperRifle",
    inherits = "base-weapons-weprifle",
    mod = "VFExpansion1"
}, {
    name = "Base.AssaultRifleBayonet",
    inherits = "base-weapons-weprifle",
    mod = "VFExpansion1"
}, {
    name = "Base.LeverRifle2",
    inherits = "base-weapons-weprifle",
    mod = "VFExpansion1"
}, {
    name = "Base.AssaultRifleM1",
    inherits = "base-weapons-weprifle",
    mod = "VFExpansion1"
}, {
    name = "Base.LeverRifle",
    inherits = "base-weapons-weprifle",
    mod = "VFExpansion1"
}, {
    name = "Base.FutureAssaultRifle",
    inherits = "base-weapons-weprifle",
    mod = "Pitstop"
}, {
    name = "Base.HeadhunterRifle",
    inherits = "base-weapons-weprifle",
    mod = "UndeadSuvivor"
}, {
    name = "Base.ShotgunSemi2",
    inherits = "base-weapons-wepshotgun",
    mod = "VFExpansion1"
}, {
    name = "Base.AssaultRifleMasterkeyShotgun",
    inherits = "base-weapons-wepshotgun",
    mod = "VFExpansion1"
}, {
    name = "Base.ShotgunSilent",
    inherits = "base-weapons-wepshotgun",
    mod = "VFExpansion1"
}, {
    name = "Base.Shotgun2",
    inherits = "base-weapons-wepshotgun",
    mod = "VFExpansion1"
}, {
    name = "Base.FutureShotgun",
    inherits = "base-weapons-wepshotgun",
    mod = "Pitstop"
}, {
    name = "Base.Shotgun2Bayonet",
    inherits = "base-weapons-wepshotgun",
    mod = "VFExpansion1"
}, {
    name = "Base.ShotgunSemi",
    inherits = "base-weapons-wepshotgun",
    mod = "VFExpansion1"
}, {
    name = "Base.M2400_Shotgun",
    inherits = "base-weapons-wepshotgun",
    mod = "VFExpansion1"
}}
