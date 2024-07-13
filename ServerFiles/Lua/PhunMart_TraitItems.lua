return {{
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-trait:positive",
    inventory = {
        min = 1,
        max = 3
    },
    tab = "Positive",
    type = "TRAIT",
    tags = "positive"
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-trait:negativetrade",
    display = {
        type = "TRAIT",
        overlay = "token-overlay"
    },
    inventory = {
        min = 1,
        max = 3
    },
    maxCharLimit = 1,
    tab = "Negative",
    type = "TRAIT",
    tags = "negativetrade"
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-trait:negative",
    display = {
        type = "TRAIT"
    },
    inventory = {
        min = 1,
        max = 3
    },
    maxCharLimit = 1,
    tab = "Remove",
    type = "TRAIT",
    tags = "negative"
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Agoraphobic",
    display = {
        label = "Agoraphobic"
    },
    receive = {{
        type = "trait",
        name = "Agoraphobic",
        tag = "REMOVE"
    }},
    price = {
        currency = 4
    },
    traits = {
        Agoraphobic = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Agoraphobic"
    },
    receive = {{
        type = "trait",
        name = "AllThumbs"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 4
    }},
    traits = {
        Agoraphobic = false,
        Brave = false,
        Desensitized = false,
        Claustophobic = false,
        AdrenalineJunkie = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:AllThumbs",
    display = {
        label = "AllThumbs"
    },
    price = {
        currency = 2
    },
    receive = {{
        type = "trait",
        name = "AllThumbs",
        tag = "REMOVE"
    }},
    traits = {
        AllThumbs = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "AllThumbs"
    },
    receive = {{
        type = "trait",
        name = "AllThumbs"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 2
    }},
    traits = {
        AllThumbs = false,
        Dextrous = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Mechanics",
    professions = {
        mechanics = false
    },
    inventory = {
        min = 1,
        max = 3
    },
    price = {
        currency = 5
    },
    traits = {
        Mechanics = false
    }
}, {
    name = "Fishing",
    inherits = "base-trait:positive",
    price = {
        currency = 4
    },
    traits = {
        Fishing = false
    }
}, {
    inherits = "base-trait:Asthmatic",
    display = {
        label = "Agoraphobic"
    },
    receive = {{
        type = "trait",
        name = "Asthmatic"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 5
    }},
    traits = {
        Asthmatic = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Athletic",
    price = {
        currency = 10
    },
    enabled = false,
    traits = {
        Athletic = false,
        Overweight = false,
        Fit = false,
        Obese = false,
        ["Out of Shape"] = false,
        Unfit = false,
        ["Very Underweight"] = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Axeman",
    professions = {
        lumberjack = false
    },
    price = {
        currency = 10
    },
    traits = {
        Axeman = false
    }
}, {
    inherits = "base-trait:positive",
    name = "BaseballPlayer",
    price = {
        currency = 4
    },
    traits = {
        BaseballPlayer = false
    }
}, {
    name = "Brave",
    inherits = "base-trait:positive",
    price = {
        currency = 4
    },
    traits = {
        Brave = false,
        Cowardly = false,
        Agoraphobic = false,
        Claustophobic = false,
        Desensitized = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Brawler",
    price = {
        currency = 6
    },
    traits = {
        Brawler = false
    }
}, {
    name = "Burglar",
    inherits = "base-trait:positive",
    professions = {
        burglar = false
    },
    price = {
        currency = 3
    },
    traits = {
        Burglar = false
    }
}, {
    inherits = "base-trait:positive",
    name = "NightVision",
    price = {
        currency = 2
    },
    traits = {
        NightVision = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Claustophobic",
    display = {
        label = "Claustophobic"
    },
    price = {
        currency = 6
    },
    receive = {{
        type = "trait",
        name = "Claustophobic",
        tag = "REMOVE"
    }},
    traits = {
        Claustophobic = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Claustophobic"
    },
    receive = {{
        type = "trait",
        name = "Claustophobic"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 6
    }},
    traits = {
        Claustophobic = false,
        Brave = false,
        Agoraphobic = false,
        AdrenalineJunkie = false,
        Desensitized = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Clumsy",
    display = {
        label = "Clumsy"
    },
    receive = {{
        type = "trait",
        name = "Clumsy",
        tag = "REMOVE"
    }},
    price = {
        currency = 1
    },
    traits = {
        Clumsy = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Clumsy"
    },
    receive = {{
        type = "trait",
        name = "Clumsy"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 1
    }},
    traits = {
        Clumsy = false,
        Graceful = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Conspicuous",
    display = {
        label = "Conspicuous"
    },
    price = {
        currency = 4
    },
    receive = {{
        type = "trait",
        name = "Conspicuous",
        tag = "REMOVE"
    }},
    traits = {
        Conspicuous = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Conspicuous"
    },
    receive = {{
        type = "trait",
        name = "Conspicuous"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 4
    }},
    traits = {
        Conspicuous = false,
        Inconspicuous = false
    }
}, {
    inherits = "base-trait:positive",
    display = {
        label = "Cook"
    },
    professions = {
        burgerflipper = false,
        chef = false
    },
    price = {
        currency = 6
    },
    traits = {
        Cook = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Cowardly",
    display = {
        label = "Cowardly"
    },
    price = {
        currency = 2
    },
    receive = {{
        type = "trait",
        name = "Cowardly",
        tag = "REMOVE"
    }},
    traits = {
        Cowardly = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Cowardly"
    },
    receive = {{
        type = "trait",
        name = "Cowardly"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 2
    }},
    traits = {
        Cowardly = false,
        Brave = false,
        Desensitized = false,
        AdrenalineJunkie = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Deaf",
    display = {
        label = "Deaf"
    },
    price = {
        currency = 12
    },
    receive = {{
        type = "trait",
        name = "Deaf",
        tag = "REMOVE"
    }},
    traits = {
        Deaf = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Deaf"
    },
    receive = {{
        type = "trait",
        name = "Deaf"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 12
    }},
    traits = {
        Deaf = false,
        HardOfHearing = false,
        KeenHearing = false
    }
}, {
    inherits = "base-trait:positive",
    display = {
        label = "Desensitized"
    },
    professions = {
        veteran = false
    },
    price = {
        currency = 6
    },
    traits = {
        Desensitized = false,
        Hemophobic = false,
        Cowardly = false,
        Brave = false,
        Agoraphobic = false,
        Claustophobic = false,
        AdrenalineJunkie = false
    }
}, {
    inherits = "base-trait:positive",
    display = {
        label = "Dextrous"
    },
    price = {
        currency = 2
    },
    traits = {
        Dextrous = false,
        AllThumbs = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Disorganized",
    display = {
        label = "Disorganized"
    },
    price = {
        currency = 4
    },
    receive = {{
        type = "trait",
        name = "Disorganized",
        tag = "REMOVE"
    }},
    traits = {
        Disorganized = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Disorganized"
    },
    receive = {{
        type = "trait",
        name = "Disorganized"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 4
    }},
    traits = {
        Disorganized = false,
        Organized = false
    }
}, {
    inherits = "base-trait:positive",
    display = {
        label = "EagleEyed"
    },
    price = {
        currency = 6
    },
    traits = {
        EagleEyed = false,
        ShortSighted = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Emaciated",
    display = {
        label = "Emaciated"
    },
    price = {
        currency = 1
    },
    receive = {{
        type = "trait",
        name = "Emaciated",
        tag = "REMOVE"
    }},
    traits = {
        Emaciated = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Emaciated"
    },
    enabled = false, -- this would be free points
    receive = {{
        type = "trait",
        name = "Emaciated"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 1
    }},
    traits = {
        Emaciated = false,
        Overweight = false,
        Obese = false
    }
}, {
    inherits = "base-trait:positive",
    name = "FastHealer",
    price = {
        currency = 6
    },
    traits = {
        FastHealer = false,
        SlowHealer = false
    }
}, {
    inherits = "base-trait:positive",
    name = "FastLearner",
    price = {
        currency = 6
    },
    traits = {
        FastLearner = false,
        SlowLearner = false
    }
}, {
    inherits = "base-trait:positive",
    name = "FastReader",
    price = {
        currency = 2
    },
    traits = {
        FastReader = false,
        SlowReader = false,
        Illiterate = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Hemophobic",
    display = {
        label = "Hemophobic"
    },
    price = {
        currency = 5
    },
    receive = {{
        type = "trait",
        name = "Hemophobic",
        tag = "REMOVE"
    }},
    traits = {
        Hemophobic = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Hemophobic"
    },
    receive = {{
        type = "trait",
        name = "Hemophobic"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 5
    }},
    traits = {
        Hemophobic = true,
        Desensitized = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Feeble",
    display = {
        label = "Feeble"
    },
    price = {
        currency = 6
    },
    receive = {{
        type = "trait",
        name = "Feeble",
        tag = "REMOVE"
    }},
    traits = {
        Feeble = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Feeble"
    },
    enabled = false, -- can be abused
    receive = {{
        type = "trait",
        name = "Feeble"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 6
    }},
    traits = {
        Feeble = false,
        Weak = false,
        Stout = false,
        Strong = false
    }
}, {
    inherits = "base-trait:positive",
    name = "FirstAid",
    price = {
        currency = 4
    },
    traits = {
        FirstAid = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Fit",
    inventory = {
        min = 1,
        max = 3
    },
    enabled = false, -- could be abused
    price = {
        currency = 6
    },
    traits = {
        Fit = false,
        Obese = false,
        Athletic = false,
        ["Out of Shape"] = false,
        Unfit = false,
        Overweight = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Formerscout",
    price = {
        currency = 6
    },
    traits = {
        Formerscout = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Gardener",
    price = {
        currency = 4
    },
    traits = {
        Gardener = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Graceful",
    price = {
        currency = 1
    },
    traits = {
        Graceful = false,
        Clumsy = false
    }
}, {
    name = "Gymnast",
    inherits = "base-trait:positive",
    price = {
        currency = 5
    },
    traits = {
        Gymnast = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Handy",
    price = {
        currency = 8
    },
    traits = {
        Handy = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:HardOfHearing",
    display = {
        label = "HardOfHearing"
    },
    price = {
        currency = 6
    },
    receive = {{
        type = "trait",
        name = "HardOfHearing",
        tag = "REMOVE"
    }},
    traits = {
        HardOfHearing = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "HardOfHearing"
    },
    receive = {{
        type = "trait",
        name = "HardOfHearing"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 6
    }},
    traits = {
        HardOfHearing = false,
        KeenHearing = false,
        Deaf = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:HeartyAppitite",
    display = {
        label = "HeartyAppitite"
    },
    price = {
        currency = 4
    },
    receive = {{
        type = "trait",
        name = "HeartyAppitite",
        tag = "REMOVE"
    }},
    traits = {
        HeartyAppitite = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "HeartyAppitite"
    },
    receive = {{
        type = "trait",
        name = "HeartyAppitite"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 4
    }},
    enabled = false,
    traits = {
        HeartyAppitite = false,
        ["Very Underweight"] = false,
        LightEater = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Herbalist",
    price = {
        currency = 6
    },
    traits = {
        Herbalist = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:HighThirst",
    display = {
        label = "HighThirst"
    },
    price = {
        currency = 6
    },
    receive = {{
        type = "trait",
        name = "HighThirst",
        tag = "REMOVE"
    }},
    traits = {
        HighThirst = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "HighThirst"
    },
    receive = {{
        type = "trait",
        name = "HighThirst"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 6
    }},
    traits = {
        HighThirst = false,
        LowThirst = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Hiker",
    price = {
        currency = 6
    },
    traits = {
        Hiker = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Hunter",
    price = {
        currency = 8
    },
    traits = {
        Hunter = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Illiterate",
    display = {
        label = "Illiterate"
    },
    price = {
        currency = 8
    },
    receive = {{
        type = "trait",
        name = "Illiterate",
        tag = "REMOVE"
    }},
    traits = {
        Illiterate = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Illiterate"
    },
    receive = {{
        type = "trait",
        name = "Illiterate"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 8
    }},
    traits = {
        Illiterate = false,
        SlowReader = false,
        FastReader = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Inconspicuous",
    price = {
        currency = 4
    },
    traits = {
        Inconspicuous = false,
        Conspicuous = false
    }
}, {
    inherits = "base-trait:positive",
    name = "IronGut",
    inventory = {
        min = 1,
        max = 3
    },
    price = {
        currency = 3
    },
    traits = {
        IronGut = false,
        WeakStomach = false
    }
}, {
    inherits = "base-trait:positive",
    name = "KeenHearing",
    price = {
        currency = 6
    },
    traits = {
        KeenHearing = false,
        HardOfHearing = false,
        Deaf = false
    }
}, {
    inherits = "base-trait:positive",
    name = "LightEater",
    price = {
        currency = 4
    },
    traits = {
        LightEater = false,
        Obese = false,
        HeartyAppitite = false
    }
}, {
    inherits = "base-trait:positive",
    name = "LowThirst",
    inventory = {
        min = 1,
        max = 3
    },
    price = {
        currency = 6
    },
    traits = {
        LowThirst = false,
        HighThirst = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Lucky",
    enabled = false, -- for mp?
    inventory = {
        min = 1,
        max = 3
    },
    price = {
        currency = 4
    },
    traits = {
        Lucky = false,
        Unlucky = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Marksman",
    professions = {
        policeofficer = false
    },
    price = {
        currency = 4
    },
    traits = {
        Marksman = false
    }
}, {
    inherits = "base-trait:positive",
    name = "NightOwl",
    enabled = false, -- not for MP
    professions = {
        securityguard = false
    },
    price = {
        currency = 4
    },
    traits = {
        NightOwl = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Nutritionist",
    professions = {
        fitnessInstructor = false
    },
    price = {
        currency = 4
    },
    traits = {
        Nutritionist = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Obese",
    enabled = false, -- only for char creation
    display = {
        label = "Obese"
    },
    price = {
        currency = 10
    },
    receive = {{
        type = "trait",
        name = "Obese",
        tag = "REMOVE"
    }},
    traits = {
        Obese = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Obese"
    },
    enabled = false, -- could be abused for free points
    receive = {{
        type = "trait",
        name = "Obese"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 10
    }},
    traits = {
        Obese = false,
        Overweight = false,
        Underweight = false,
        ["Very Underweight"] = false,
        Emaciated = false,
        LightEater = false,
        Fit = false,
        Athletic = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Organized",
    inventory = {
        min = 1,
        max = 3
    },
    price = {
        currency = 6
    },
    traits = {
        Organized = false,
        Disorganized = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Out of Shape",
    display = {
        label = "Out of Shape"
    },
    enabled = false, -- only for char creation
    price = {
        currency = 6
    },
    receive = {{
        type = "trait",
        name = "Out of Shape",
        tag = "REMOVE"
    }},
    traits = {
        ["Out of Shape"] = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Out of Shape"
    },
    enabled = false, -- can be abused
    receive = {{
        type = "trait",
        name = "Out of Shape"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 2
    }},
    traits = {
        ["Out of Shape"] = false,
        Athletic = false,
        Fit = false,
        Unfit = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Outdoorsman",
    price = {
        currency = 2
    },
    traits = {
        Outdoorsman = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Overweight",
    enabled = false, -- only for char creation
    display = {
        label = "Overweight"
    },
    price = {
        currency = 6
    },
    receive = {{
        type = "trait",
        name = "Overweight",
        tag = "REMOVE"
    }},
    traits = {
        Overweight = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Overweight"
    },
    enabled = false, -- could be abused
    receive = {{
        type = "trait",
        name = "Overweight"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 6
    }},
    traits = {
        Overweight = false,
        Obese = false,
        Underweight = false,
        ["Very Underweight"] = false,
        Emaciated = false,
        Athletic = false,
        Fit = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Pacifist",
    display = {
        label = "Pacifist"
    },
    price = {
        currency = 4
    },
    receive = {{
        type = "trait",
        name = "Pacifist",
        tag = "REMOVE"
    }},
    traits = {
        Pacifist = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Pacifist"
    },
    receive = {{
        type = "trait",
        name = "Pacifist"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 4
    }},
    traits = {
        Pacifist = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:ProneToIllness",
    display = {
        label = "ProneToIllness"
    },
    price = {
        currency = 4
    },
    receive = {{
        type = "trait",
        name = "ProneToIllness",
        tag = "REMOVE"
    }},
    traits = {
        ProneToIllness = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "ProneToIllness"
    },
    receive = {{
        type = "trait",
        name = "ProneToIllness"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 4
    }},
    traits = {
        ProneToIllness = false,
        Resilient = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Resilient",
    price = {
        currency = 4
    },
    traits = {
        Resilient = false,
        ProneToIllness = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Insomniac",
    display = {
        label = "Insomniac"
    },
    enabled = false, -- not for MP
    price = {
        currency = 6
    },
    receive = {{
        type = "trait",
        name = "Insomniac",
        tag = "REMOVE"
    }},
    traits = {
        Insomniac = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Insomniac"
    },
    enabled = false, -- not for MP
    receive = {{
        type = "trait",
        name = "Insomniac"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 6
    }},
    traits = {
        Insomniac = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Jogger",
    inventory = {
        min = 1,
        max = 3
    },
    price = {
        currency = 4
    },
    traits = {
        Jogger = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Tailor",
    price = {
        currency = 4
    },
    traits = {
        -- Tailor = falses
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:ShortSighted",
    display = {
        label = "ShortSighted"
    },
    price = {
        currency = 4
    },
    receive = {{
        type = "trait",
        name = "ShortSighted",
        tag = "REMOVE"
    }},
    traits = {
        ShortSighted = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "ShortSighted"
    },
    receive = {{
        type = "trait",
        name = "ShortSighted"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 4
    }},
    traits = {
        ShortSighted = false,
        EagleEyed = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:NeedsMoreSleep",
    display = {
        label = "NeedsMoreSleep"
    },
    enabled = false, -- not for MP
    price = {
        currency = 4
    },
    receive = {{
        type = "trait",
        name = "NeedsMoreSleep",
        tag = "REMOVE"
    }},
    traits = {
        NeedsMoreSleep = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "NeedsMoreSleep"
    },
    enabled = false, -- not for MP
    receive = {{
        type = "trait",
        name = "NeedsMoreSleep"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 4
    }},
    traits = {
        NeedsMoreSleep = false,
        NeedsLessSleep = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:SlowHealer",
    display = {
        label = "SlowHealer"
    },
    price = {
        currency = 6
    },
    receive = {{
        type = "trait",
        name = "SlowHealer",
        tag = "REMOVE"
    }},
    traits = {
        SlowHealer = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "SlowHealer"
    },
    receive = {{
        type = "trait",
        name = "SlowHealer"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 6
    }},
    traits = {
        SlowHealer = false,
        FastHealer = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:SlowLearner",
    display = {
        label = "SlowLearner"
    },
    price = {
        currency = 6
    },
    receive = {{
        type = "trait",
        name = "SlowLearner",
        tag = "REMOVE"
    }},
    traits = {
        SlowLearner = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "SlowLearner"
    },
    receive = {{
        type = "trait",
        name = "SlowLearner"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 6
    }},
    traits = {
        SlowLearner = false,
        FastLearner = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:SlowReader",
    display = {
        label = "SlowReader"
    },
    price = {
        currency = 2
    },
    receive = {{
        type = "trait",
        name = "SlowReader",
        tag = "REMOVE"
    }},
    traits = {
        SlowReader = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "SlowReader"
    },
    receive = {{
        type = "trait",
        name = "SlowReader"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 2
    }},
    traits = {
        SlowReader = false,
        FastReader = false,
        Illiterate = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Smoker",
    display = {
        label = "Smoker"
    },
    price = {
        currency = 4
    },
    receive = {{
        type = "trait",
        name = "Smoker",
        tag = "REMOVE"
    }},
    traits = {
        Smoker = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Smoker"
    },
    receive = {{
        type = "trait",
        name = "Smoker"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 4
    }},
    traits = {
        Smoker = false
    }
}, {
    inherits = "base-trait:positive",
    name = "SpeedDemon",
    price = {
        currency = 1
    },
    traits = {
        SpeedDemon = false,
        SundayDriver = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Stout",
    enabled = false,
    price = {
        currency = 6
    },
    traits = {
        Stout = false,
        Weak = false,
        Feeble = false,
        Strong = false
    }
}, {
    inherits = "base-trait:positive",
    name = "Strong",
    enabled = false,
    price = {
        currency = 10
    },
    traits = {
        Strong = false,
        Weak = false,
        Feeble = false,
        Stout = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:SundayDriver",
    display = {
        label = "SundayDriver"
    },
    price = {
        currency = 1
    },
    receive = {{
        type = "trait",
        name = "SundayDriver",
        tag = "REMOVE"
    }},
    traits = {
        SundayDriver = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "SundayDriver"
    },
    receive = {{
        type = "trait",
        name = "SundayDriver"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 1
    }},
    traits = {
        SundayDriver = false,
        SpeedDemon = false
    }
}, {
    inherits = "base-trait:positive",
    name = "ThickSkinned",
    price = {
        currency = 8
    },
    traits = {
        ThickSkinned = false,
        Thinskinned = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Thinskinned",
    display = {
        label = "Thinskinned"
    },
    price = {
        currency = 8
    },
    receive = {{
        type = "trait",
        name = "Thinskinned",
        tag = "REMOVE"
    }},
    traits = {
        Thinskinned = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Thinskinned"
    },
    receive = {{
        type = "trait",
        name = "Thinskinned"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 8
    }},
    traits = {
        Thinskinned = false,
        ThickSkinned = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Underweight",
    enabled = false, -- only for char creation
    display = {
        label = "Underweight"
    },
    price = {
        currency = 6
    },
    receive = {{
        type = "trait",
        name = "Underweight",
        tag = "REMOVE"
    }},
    traits = {
        Underweight = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Underweight"
    },
    enabled = false, -- could be abused
    receive = {{
        type = "trait",
        name = "Underweight"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 6
    }},
    traits = {
        Underweight = false,
        Overweight = false,
        ["Very Underweight"] = false,
        Obese = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Unfit",
    display = {
        label = "Unfit"
    },
    price = {
        currency = 10
    },
    enabled = false, -- only for char creation
    receive = {{
        type = "trait",
        name = "Unfit",
        tag = "REMOVE"
    }},
    traits = {
        Unfit = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Unfit"
    },
    enabled = false, -- could be abused
    receive = {{
        type = "trait",
        name = "Unfit"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 10
    }},
    traits = {
        Unfit = false,
        Athletic = false,
        Fit = false,
        ["Out of Shape"] = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Unlucky",
    display = {
        label = "Unlucky"
    },
    price = {
        currency = 4
    },
    receive = {{
        type = "trait",
        name = "Unlucky",
        tag = "REMOVE"
    }},
    traits = {
        Unlucky = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Unlucky"
    },
    enabled = false, -- not available in MP?
    receive = {{
        type = "trait",
        name = "Unlucky"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 4
    }},
    traits = {
        Unlucky = false,
        Lucky = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Very Underweight",
    enabled = false, -- only for char creation
    display = {
        label = "Very Underweight"
    },
    price = {
        currency = 10
    },
    receive = {{
        type = "trait",
        name = "Very Underweight",
        tag = "REMOVE"
    }},
    traits = {
        ["Very Underweight"] = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Very Underweight"
    },
    enabled = false, -- could be abused
    receive = {{
        type = "trait",
        name = "Very Underweight"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 10
    }},
    traits = {
        ["Very Underweight"] = false,
        Underweight = false,
        HeartyAppitite = false,
        Overweight = false,
        Obese = false,
        Athletic = false
    }
}, {
    inherits = "base-trait:positive",
    name = "NeedsLessSleep",
    enabled = false, -- not for mp
    inventory = {
        min = 1,
        max = 3
    },
    price = {
        currency = 2
    },
    traits = {
        NeedsLessSleep = false,
        NeedsMoreSleep = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:Weak",
    enabled = false, -- only for char creation
    display = {
        label = "Weak"
    },
    price = {
        currency = 10
    },
    receive = {{
        type = "trait",
        name = "Weak",
        tag = "REMOVE"
    }},
    traits = {
        Weak = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "Weak"
    },
    enabled = false,
    receive = {{
        type = "trait",
        name = "Weak"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 10
    }},
    traits = {
        Weak = false,
        Strong = false,
        Stout = false,
        Feeble = false
    }
}, {
    inherits = "base-trait:negative",
    key = "TRAIT:NEG:WeakStomach",
    display = {
        label = "WeakStomach"
    },
    price = {
        currency = 3
    },
    receive = {{
        type = "trait",
        name = "WeakStomach",
        tag = "REMOVE"
    }},
    traits = {
        WeakStomach = true
    }
}, {
    inherits = "base-trait:negativetrade",
    display = {
        label = "WeakStomach"
    },
    receive = {{
        type = "trait",
        name = "WeakStomach"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 3
    }},
    traits = {
        WeakStomach = false,
        IronGut = false
    }
}}
