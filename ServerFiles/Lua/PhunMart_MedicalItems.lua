return {{
    abstract = true,
    key = "base-medical",
    tab = "Medical",
    tags = "medical",
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
    key = "base-medical-medbandage",
    inherits = "base-medical",
    tab = "Bandage",
    tags = "medical,medbandage"
}, {
    abstract = true,
    key = "base-medical-medcomponent",
    inherits = "base-medical",
    tab = "Component",
    tags = "medical,medcomponent"
}, {
    abstract = true,
    key = "base-medical-medtools",
    inherits = "base-medical",
    tab = "Tools",
    tags = "medical,medtools"
}, {
    abstract = true,
    key = "base-medical-medpills",
    inherits = "base-medical",
    tab = "Pills",
    tags = "medical,medpills"
}, {
    name = "Base.AlcoholRippedSheets",
    inherits = "base-medical-medbandage"
}, {
    name = "Base.AlcoholBandage",
    inherits = "base-medical-medbandage"
}, {
    name = "Base.Bandage",
    inherits = "base-medical-medbandage"
}, {
    name = "Base.Bandaid",
    inherits = "base-medical-medbandage"
}, {
    name = "Base.WildGarlicCataplasm",
    inherits = "base-medical-medcomponent"
}, {
    name = "Base.PlantainCataplasm",
    inherits = "base-medical-medcomponent"
}, {
    name = "Base.CottonBalls",
    inherits = "base-medical-medcomponent"
}, {
    name = "Base.Plantain",
    inherits = "base-medical-medcomponent"
}, {
    name = "Base.Ginseng",
    inherits = "base-medical-medcomponent"
}, {
    name = "Base.AlcoholedCottonBalls",
    inherits = "base-medical-medcomponent"
}, {
    name = "Base.CommonMallow",
    inherits = "base-medical-medcomponent"
}, {
    name = "Base.BlackSage",
    inherits = "base-medical-medcomponent"
}, {
    name = "Base.Comfrey",
    inherits = "base-medical-medcomponent"
}, {
    name = "Base.WildGarlic2",
    inherits = "base-medical-medcomponent"
}, {
    name = "Base.WildGarlic",
    inherits = "base-medical-medcomponent"
}, {
    name = "Base.ComfreyCataplasm",
    inherits = "base-medical-medcomponent"
}, {
    name = "Base.Disinfectant",
    inherits = "base-medical-medcomponent"
}, {
    name = "Base.PillsAntiDep",
    inherits = "base-medical-medpills"
}, {
    name = "Base.PillsBeta",
    inherits = "base-medical-medpills"
}, {
    name = "Base.PillsSleepingTablets",
    inherits = "base-medical-medpills"
}, {
    name = "PhunRad.Iodine",
    inherits = "base-medical-medpills"
}, {
    name = "Base.Antibiotics",
    inherits = "base-medical-medpills"
}, {
    name = "TheyKnew.Zomboxivir",
    inherits = "base-medical-medpills",
    mod = "PhunStuff"
}, {
    name = "Base.PillsVitamins",
    inherits = "base-medical-medpills"
}, {
    name = "Base.Pills",
    inherits = "base-medical-medpills"
}, {
    name = "TheyKnew.Zomboxycycline",
    inherits = "base-medical-medpills",
    mod = "PhunStuff"
}, {
    name = "Base.Tissue",
    inherits = "base-medical-medtools"
}, {
    name = "Base.SutureNeedleHolder",
    inherits = "base-medical-medtools"
}, {
    name = "Base.Gloves_Surgical",
    inherits = "base-medical-medtools"
}, {
    name = "Base.Scalpel",
    inherits = "base-medical-medtools"
}, {
    name = "Base.SutureNeedle",
    inherits = "base-medical-medtools"
}, {
    name = "Base.AlcoholWipes",
    inherits = "base-medical-medtools"
}, {
    name = "Base.Tweezers",
    inherits = "base-medical-medtools"
}, {
    name = "Base.MortarPestle",
    inherits = "base-medical-medtools"
}, {
    name = "Base.Coldpack",
    inherits = "base-medical-medtools"
}, {
    name = "Base.Hat_SurgicalCap_Blue",
    inherits = "base-medical-medtools"
}, {
    name = "Base.Hat_SurgicalMask_Blue",
    inherits = "base-medical-medtools"
}, {
    name = "Base.Hat_SurgicalMask_Green",
    inherits = "base-medical-medtools"
}, {
    name = "Base.Splint",
    inherits = "base-medical-medtools"
}, {
    name = "Base.Hat_SurgicalCap_Green",
    inherits = "base-medical-medtools"
}, {
    name = "Base.AdrenalineSyringe",
    inherits = "base-medical-medtools",
    mod = "BB_FirstAidOverhaul_Alt"
}, {
    name = "CanteensAndBottles.MedicinalCanteenRedWhiteMedicine-medpills",
    inherits = "base-medical",
    mod = "CanteensAndBottles"
}, {
    name = "Base.Syringe1",
    inherits = "base-medical-medtools",
    mod = "BB_FirstAidOverhaul_Alt"
}, {
    name = "Base.EmptySyringe",
    inherits = "base-medical",
    mod = "BB_FirstAidOverhaul_Alt"
}, {
    name = "CanteensAndBottles.MedicinalCanteenGreenWhiteSerum-medpills",
    inherits = "base-medical",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.MedicinalCanteenWhiteRedMedicine-medpills",
    inherits = "base-medical",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.MedicinalCanteenWhiteGreenSerum-medpills",
    inherits = "base-medical",
    mod = "CanteensAndBottles"
}, {
    name = "Base.AlcoholBandage2Dirty",
    inherits = "base-medical-medbandage",
    mod = "BB_FirstAidOverhaul_Alt"
}, {
    name = "Base.AlcoholBandage2",
    inherits = "base-medical-medbandage",
    mod = "BB_FirstAidOverhaul_Alt"
}, {
    name = "Base.Cologne",
    inherits = "base-medical-medpills",
    mod = "EssentialCrafting"
}, {
    name = "Base.Perfume",
    inherits = "base-medical-medpills",
    mod = "EssentialCrafting"
}, {
    name = "RadiatedZones.Iodine",
    inherits = "base-medical-medpills",
    mod = "RadiatedZones"
}, {
    name = "RadiatedZones.CivGeigerTeller",
    inherits = "base-medical-medtools",
    mod = "RadiatedZones"
}, {
    name = "RadiatedZones.GeigerTeller",
    inherits = "base-medical-medtools",
    mod = "RadiatedZones"
}}
