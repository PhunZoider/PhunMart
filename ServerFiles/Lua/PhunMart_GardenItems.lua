return {{
    abstract = true,
    key = "base-gardening",
    tab = "Gardening",
    tags = "gardening",
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
    key = "base-gardening-gardenseeds",
    inherits = "base-gardening",
    tab = "Seeds",
    tags = "gardening,gardenseeds"
}, {
    abstract = true,
    key = "base-gardening-gardentools",
    inherits = "base-gardening",
    tab = "Tools",
    tags = "gardening,gardentools"
}, {
    name = "farming.PotatoSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "farming.RedRadishBagSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "farming.CarrotSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "farming.PotatoBagSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "farming.CabbageSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "farming.StrewberrieBagSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "farming.StrewberrieSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "farming.TomatoBagSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "farming.BroccoliBagSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "farming.BroccoliSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "farming.TomatoSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "farming.RedRadishSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "farming.CarrotBagSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "farming.CabbageBagSeed",
    inherits = "base-gardening-gardenseeds"
}, {
    name = "Base.LeafRake",
    inherits = "base-gardening-gardentools"
}, {
    name = "farming.WateredCan",
    inherits = "base-gardening-gardentools"
}, {
    name = "Base.Rake",
    inherits = "base-gardening-gardentools"
}, {
    name = "USMIL.WaterCan0",
    inherits = "base-gardening-gardentools",
    mod = "damnlib"
}, {
    name = "farming.HandShovel",
    inherits = "base-gardening-gardentools"
}, {
    name = "Base.Shovel",
    inherits = "base-gardening-gardentools"
}, {
    name = "Base.GardenHoe",
    inherits = "base-gardening-gardentools"
}, {
    name = "farming.GardeningSprayFull",
    inherits = "base-gardening-gardentools"
}, {
    name = "Base.Fertilizer",
    inherits = "base-gardening-gardentools"
}, {
    name = "farming.GardeningSprayEmpty",
    inherits = "base-gardening-gardentools"
}, {
    name = "farming.GardeningSprayCigarettes",
    inherits = "base-gardening-gardentools"
}, {
    name = "farming.WateredCanFull",
    inherits = "base-gardening-gardentools"
}, {
    name = "farming.GardeningSprayMilk",
    inherits = "base-gardening-gardentools"
}, {
    name = "Base.GardenFork",
    inherits = "base-gardening-gardentools"
}, {
    name = "Base.Shovel2",
    inherits = "base-gardening-gardentools"
}, {
    name = "SOMW.GardenShears",
    inherits = "base-gardening-gardentools",
    mod = "SimpleOverhaulMeleeWeapons"
}}
