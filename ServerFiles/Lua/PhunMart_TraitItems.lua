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
        quantity = 6
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
        ["Price.Money"] = 4
    },
    traits = {
        Resilient = false,
        ProneToIllness = false
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
