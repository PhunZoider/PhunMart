return {{
    abstract = true,
    key = "base-tools",
    tab = "Tools",
    tags = "tools",
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
    key = "base-tools-toolwelding",
    inherits = "base-tools",
    tab = "Welding",
    tags = "tools,toolwelding"
}, {
    abstract = true,
    key = "base-tools-toolmecanics",
    inherits = "base-tools",
    tab = "Mechanics",
    tags = "tools,toolmecanics"
}, {
    name = "SapphCooking.Blender",
    inherits = "base-tools",
    mod = "sapphcooking"
}, {
    name = "Base.PickAxeHandle",
    inherits = "base-tools"
}, {
    name = "Base.Tongs",
    inherits = "base-tools"
}, {
    name = "Base.Screwdriver",
    inherits = "base-tools"
}, {
    name = "Base.ClubHammer",
    inherits = "base-tools"
}, {
    name = "Base.Sledgehammer",
    inherits = "base-tools"
}, {
    name = "Base.BallPeenHammer",
    inherits = "base-tools"
}, {
    name = "Base.Wrench",
    inherits = "base-tools"
}, {
    name = "Base.Axe",
    inherits = "base-tools"
}, {
    name = "Base.Paintbrush",
    inherits = "base-tools"
}, {
    name = "Base.HammerStone",
    inherits = "base-tools"
}, {
    name = "Base.WoodenMallet",
    inherits = "base-tools"
}, {
    name = "Base.HandAxe",
    inherits = "base-tools"
}, {
    name = "Base.HandScythe",
    inherits = "base-tools"
}, {
    name = "Base.Saw",
    inherits = "base-tools"
}, {
    name = "Base.LugWrench",
    inherits = "base-tools"
}, {
    name = "Base.WoodAxe",
    inherits = "base-tools"
}, {
    name = "Base.HandFork",
    inherits = "base-tools"
}, {
    name = "Base.Hammer",
    inherits = "base-tools"
}, {
    name = "Base.TirePump",
    inherits = "base-tools"
}, {
    name = "Base.AxeStone",
    inherits = "base-tools"
}, {
    name = "Base.PipeWrench",
    inherits = "base-tools"
}, {
    name = "Base.SnowShovel",
    inherits = "base-tools"
}, {
    name = "Base.Bellows",
    inherits = "base-tools"
}, {
    name = "Base.Sledgehammer2",
    inherits = "base-tools"
}, {
    name = "Base.PickAxe",
    inherits = "base-tools"
}, {
    name = "Base.Crowbar",
    inherits = "base-tools"
}, {
    name = "Base.Needle",
    inherits = "base-tools"
}, {
    name = "Base.BlowTorch",
    inherits = "base-tools-toolwelding"
}, {
    name = "Base.GardenSaw",
    inherits = "base-tools"
}, {
    name = "SapphCooking.CarvingForkSapph",
    inherits = "base-tools",
    mod = "sapphcooking"
}, {
    name = "damnCraft.TireRepairKit",
    inherits = "base-tools",
    mod = "damnlib"
}, {
    name = "damnCraft.TireRepairTools",
    inherits = "base-tools",
    mod = "damnlib"
}, {
    name = "SapphCooking.MeatTenderizer_Wood",
    inherits = "base-tools",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MeatTenderizer",
    inherits = "base-tools",
    mod = "sapphcooking"
}, {
    name = "camping.SteelAndFlint",
    inherits = "base-tools"
}, {
    name = "PhunSpawn.Escape Vent",
    inherits = "base-tools",
    mod = "phunspawn",
    price = {
        currency = 80
    }
}, {
    name = "Base.WeldingMask",
    inherits = "base-tools-toolwelding"
}, {
    name = "damnCraft.PlasticWeldingKit",
    inherits = "base-tools-toolwelding",
    mod = "damnlib"
}, {
    name = "damnCraft.PlasticWeldingGun",
    inherits = "base-tools-toolwelding",
    mod = "damnlib"
}, {
    name = "Base.OverlookFireAxe",
    inherits = "base-tools",
    mod = "PertsPartyTiles"
}, {
    name = "Base.EntrenchingToolBlack_Blade",
    inherits = "base-tools",
    mod = "VFExpansion1"
}, {
    name = "Base.EntrenchingTool_Blade",
    inherits = "base-tools",
    mod = "VFExpansion1"
}, {
    name = "Base.EntrenchingTool_Folded",
    inherits = "base-tools",
    mod = "VFExpansion1"
}, {
    name = "Base.BatLeth",
    inherits = "base-tools",
    mod = "PertsPartyTiles"
}, {
    name = "Base.DjackzVinyl",
    inherits = "base-tools",
    mod = "Pitstop"
}, {
    name = "Base.EntrenchingToolBlack_Blunt",
    inherits = "base-tools",
    mod = "VFExpansion1"
}, {
    name = "Base.EntrenchingToolBlack_Folded",
    inherits = "base-tools",
    mod = "VFExpansion1"
}, {
    name = "Base.EntrenchingTool_Blunt",
    inherits = "base-tools",
    mod = "VFExpansion1"
}, {
    name = "BZMClothing.Saw",
    inherits = "base-tools",
    mod = "MonmouthCounty_new"
}, {
    name = "BZMClothing.GardenSaw",
    inherits = "base-tools",
    mod = "MonmouthCounty_new"
}, {
    name = "EHE.SignalFlare",
    inherits = "base-tools",
    mod = "ExpandedHelicopterEvents"
}, {
    name = "EHE.HandFlare",
    inherits = "base-tools",
    mod = "ExpandedHelicopterEvents"
}, {
    name = "MonmouthWeapons.Crowbarski",
    inherits = "base-tools",
    mod = "MonmouthCounty_new"
}, {
    name = "MonmouthWeapons.AxeBZMCrafted",
    inherits = "base-tools",
    mod = "MonmouthCounty_new"
}, {
    name = "MonmouthWeapons.PickAxePink",
    inherits = "base-tools",
    mod = "MonmouthCounty_new"
}, {
    name = "MonmouthWeapons.Hammer_Reinforced",
    inherits = "base-tools",
    mod = "MonmouthCounty_new"
}, {
    name = "MonmouthWeapons.CrowbarScorpion",
    inherits = "base-tools",
    mod = "MonmouthCounty_new"
}, {
    name = "SOMW.EntrenchingShovel",
    inherits = "base-tools",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.IceAxe",
    inherits = "base-tools",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.GardenScythe",
    inherits = "base-tools",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.GardenBrushCutter",
    inherits = "base-tools",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.HandFile",
    inherits = "base-tools",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.UniAxe",
    inherits = "base-tools",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.AxeHammer",
    inherits = "base-tools",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.HookMachete",
    inherits = "base-tools",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "SOMW.CampingHatchet",
    inherits = "base-tools",
    mod = "SimpleOverhaulMeleeWeapons"
}}
