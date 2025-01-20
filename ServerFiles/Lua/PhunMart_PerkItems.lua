return {{
    abstract = true,
    key = "base-perk:basic1",
    level = 1,
    display = {
        type = "PERK",
        overlay = "plus-1"
    },
    inventory = {
        min = 1,
        max = 3
    },
    tab = "XP",
    tags = "perks1"
}, {
    abstract = true,
    key = "base-perk:basic2",
    level = 2,
    display = {
        type = "PERK",
        overlay = "plus-2"
    },
    inventory = {
        min = 1,
        max = 3
    },
    tab = "XP",
    tags = "perks2"
}, {
    abstract = true,
    key = "base-perk:basic3",
    level = 2,
    display = {
        type = "PERK",
        overlay = "plus-3"
    },
    inventory = {
        min = 1,
        max = 3
    },
    tab = "XP",
    tags = "perks3"
}, {
    abstract = true,
    key = "base-perk:basic4",
    level = 2,
    display = {
        type = "PERK",
        overlay = "plus-4"
    },
    inventory = {
        min = 1,
        max = 3
    },
    tab = "XP",
    tags = "perks4"
}, {
    abstract = true,
    key = "base-boost:basic1",
    level = 1,
    display = {
        type = "BOOST",
        overlay = "boost-1"
    },
    inventory = {
        min = 1,
        max = 3
    },
    tab = "Boost",
    tags = "boosts1"
}, {
    abstract = true,
    key = "base-boost:basic2",
    level = 2,
    display = {
        type = "BOOST",
        overlay = "boost-2"
    },
    inventory = {
        min = 1,
        max = 3
    },
    tab = "Boost",
    tags = "boosts2"
}, {
    abstract = true,
    key = "base-boost:basic3",
    level = 2,
    display = {
        type = "BOOST",
        overlay = "boost-3"
    },
    inventory = {
        min = 1,
        max = 3
    },
    tab = "Boost",
    tags = "boosts3"
}, {
    abstract = true,
    key = "base-boost:basic4",
    level = 2,
    display = {
        type = "BOOST",
        overlay = "boost-4"
    },
    inventory = {
        min = 1,
        max = 3
    },
    tab = "Boost",
    tags = "boosts4"
}, {
    inherits = "base-perk:basic1",
    enabled = false,
    display = {
        label = "Engineering"
    },
    quantity = 75,
    skills = {
        Engineering = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    enabled = false,
    display = {
        label = "Engineering"
    },
    quantity = 3,
    skills = {
        Engineering = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Engineering = false
    }
}, {
    inherits = "base-perk:basic2",
    enabled = false,
    display = {
        label = "Engineering",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Engineering = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    enabled = false,
    display = {
        label = "Engineering",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Engineering = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Engineering = false
    }
}, {
    inherits = "base-perk:basic3",
    enabled = false,
    display = {
        label = "Engineering",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Engineering = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    enabled = false,
    display = {
        label = "Engineering",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Engineering = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Engineering = false
    }
}, {
    inherits = "base-perk:basic4",
    enabled = false,
    display = {
        label = "Engineering",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Engineering = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    enabled = false,
    display = {
        label = "Engineering",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Engineering = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Engineering = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Cooking"
    },
    quantity = 75,
    skills = {
        Cooking = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Cooking"
    },
    quantity = 3,
    skills = {
        Cooking = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Cooking = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Cooking",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Cooking = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Cooking",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Cooking = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Cooking = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Cooking",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Cooking = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Cooking",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Cooking = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Cooking = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Cooking",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Cooking = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Cooking",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Cooking = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Cooking = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Fitness"
    },
    quantity = 1500,
    skills = {
        Fitness = {
            max = 2
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Fitness"
    },
    quantity = 3,
    skills = {
        Fitness = {
            max = 2
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Fitness = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Fitness",
        labelExt = "II"
    },
    quantity = 6000,
    skills = {
        Fitness = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 400
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Fitness",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Fitness = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 600
    },
    boosts = {
        Fitness = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Fitness",
        labelExt = "III"
    },
    quantity = 18000,
    skills = {
        Fitness = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 900
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Fitness",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Fitness = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 1800
    },
    boosts = {
        Fitness = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Fitness",
        labelExt = "IV"
    },
    quantity = 60000,
    skills = {
        Fitness = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 3000
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Fitness",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Fitness = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 6000
    },
    boosts = {
        Fitness = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Strength"
    },
    quantity = 1500,
    skills = {
        Strength = {
            max = 2
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Strength"
    },
    quantity = 3,
    skills = {
        Strength = {
            max = 2
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Strength = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Strength",
        labelExt = "II"
    },
    quantity = 6000,
    skills = {
        Strength = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 400
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Strength",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Strength = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 600
    },
    boosts = {
        Strength = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Strength",
        labelExt = "III"
    },
    quantity = 18000,
    skills = {
        Strength = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 900
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Strength",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Strength = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 1800
    },
    boosts = {
        Strength = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Strength",
        labelExt = "IV"
    },
    quantity = 60000,
    skills = {
        Strength = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 3000
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Strength",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Strength = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 6000
    },
    boosts = {
        Strength = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Long Blunt"
    },
    quantity = 75,
    skills = {
        ["Long Blunt"] = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Long Blunt"
    },
    quantity = 3,
    skills = {
        ["Long Blunt"] = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        ["Long Blunt"] = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Long Blunt",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        ["Long Blunt"] = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Long Blunt",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        ["Long Blunt"] = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        ["Long Blunt"] = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Long Blunt",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        ["Long Blunt"] = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Long Blunt",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        ["Long Blunt"] = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        ["Long Blunt"] = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Long Blunt",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        ["Long Blunt"] = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Long Blunt",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        ["Long Blunt"] = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        ["Long Blunt"] = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Axe"
    },
    quantity = 75,
    skills = {
        Axe = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Axe"
    },
    quantity = 3,
    skills = {
        Axe = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Axe = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Axe",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Axe = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Axe",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Axe = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Axe = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Axe",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Axe = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Axe",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Axe = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Axe = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Axe",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Axe = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Axe",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Axe = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Axe = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Sprinting"
    },
    quantity = 75,
    skills = {
        Sprinting = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Sprinting"
    },
    quantity = 3,
    skills = {
        Sprinting = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Sprinting = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Sprinting",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Sprinting = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Sprinting",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Sprinting = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Sprinting = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Sprinting",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Sprinting = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Sprinting",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Sprinting = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Sprinting = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Sprinting",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Sprinting = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Sprinting",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Sprinting = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Sprinting = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Lightfooted"
    },
    quantity = 75,
    skills = {
        Lightfooted = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Lightfooted"
    },
    quantity = 3,
    skills = {
        Lightfooted = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Lightfooted = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Lightfooted",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Lightfooted = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Lightfooted",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Lightfooted = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Lightfooted = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Lightfooted",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Lightfooted = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Lightfooted",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Lightfooted = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Lightfooted = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Lightfooted",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Lightfooted = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Lightfooted",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Lightfooted = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Lightfooted = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Nimble"
    },
    quantity = 75,
    skills = {
        Nimble = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Nimble"
    },
    quantity = 3,
    skills = {
        Nimble = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Nimble = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Nimble",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Nimble = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Nimble",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Nimble = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Nimble = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Nimble",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Nimble = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Nimble",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Nimble = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Nimble = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Nimble",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Nimble = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Nimble",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Nimble = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Nimble = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Sneaking"
    },
    quantity = 75,
    skills = {
        Sneaking = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Sneaking"
    },
    quantity = 3,
    skills = {
        Sneaking = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Sneaking = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Sneaking",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Sneaking = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Sneaking",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Sneaking = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Sneaking = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Sneaking",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Sneaking = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Sneaking",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Sneaking = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Sneaking = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Sneaking",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Sneaking = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Sneaking",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Sneaking = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Sneaking = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Carpentry"
    },
    quantity = 75,
    skills = {
        Carpentry = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Carpentry"
    },
    quantity = 3,
    skills = {
        Carpentry = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Carpentry = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Carpentry",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Carpentry = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Carpentry",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Carpentry = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Carpentry = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Carpentry",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Carpentry = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Carpentry",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Carpentry = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Carpentry = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Carpentry",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Carpentry = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Carpentry",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Carpentry = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Carpentry = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Aiming"
    },
    quantity = 75,
    skills = {
        Aiming = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Aiming"
    },
    quantity = 3,
    skills = {
        Aiming = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Aiming = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Aiming",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Aiming = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Aiming",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Aiming = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Aiming = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Aiming",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Aiming = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Aiming",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Aiming = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Aiming = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Aiming",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Aiming = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Aiming",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Aiming = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Aiming = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Reloading"
    },
    quantity = 75,
    skills = {
        Reloading = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Reloading"
    },
    quantity = 3,
    skills = {
        Reloading = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Reloading = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Reloading",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Reloading = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Reloading",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Reloading = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Reloading = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Reloading",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Reloading = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Reloading",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Reloading = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Reloading = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Reloading",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Reloading = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Reloading",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Reloading = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Reloading = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Farming"
    },
    quantity = 75,
    skills = {
        Farming = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Farming"
    },
    quantity = 3,
    skills = {
        Farming = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Farming = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Farming",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Farming = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Farming",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Farming = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Farming = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Farming",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Farming = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Farming",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Farming = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Farming = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Farming",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Farming = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Farming",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Farming = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Farming = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Fishing"
    },
    quantity = 75,
    skills = {
        Fishing = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Fishing"
    },
    quantity = 3,
    skills = {
        Fishing = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Fishing = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Fishing",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Fishing = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Fishing",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Fishing = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Fishing = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Fishing",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Fishing = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Fishing",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Fishing = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Fishing = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Fishing",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Fishing = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Fishing",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Fishing = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Fishing = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Trapping"
    },
    quantity = 75,
    skills = {
        Trapping = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Trapping"
    },
    quantity = 3,
    skills = {
        Trapping = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Trapping = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Trapping",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Trapping = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Trapping",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Trapping = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Trapping = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Trapping",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Trapping = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Trapping",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Trapping = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Trapping = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Trapping",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Trapping = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Trapping",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Trapping = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Trapping = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Foraging"
    },
    quantity = 75,
    skills = {
        Foraging = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Foraging"
    },
    quantity = 3,
    skills = {
        Foraging = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Foraging = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Foraging",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Foraging = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Foraging",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Foraging = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Foraging = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Foraging",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Foraging = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Foraging",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Foraging = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Foraging = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Foraging",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Foraging = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Foraging",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Foraging = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Foraging = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "First Aid"
    },
    quantity = 75,
    skills = {
        ["First Aid"] = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "First Aid"
    },
    quantity = 3,
    skills = {
        ["First Aid"] = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        ["First Aid"] = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "First Aid",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        ["First Aid"] = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "First Aid",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        ["First Aid"] = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        ["First Aid"] = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "First Aid",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        ["First Aid"] = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "First Aid",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        ["First Aid"] = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        ["First Aid"] = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "First Aid",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        ["First Aid"] = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "First Aid",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        ["First Aid"] = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        ["First Aid"] = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Electrical"
    },
    quantity = 75,
    skills = {
        Electrical = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Electrical"
    },
    quantity = 3,
    skills = {
        Electrical = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Electrical = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Electrical",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Electrical = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Electrical",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Electrical = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Electrical = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Electrical",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Electrical = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Electrical",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Electrical = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Electrical = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Electrical",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Electrical = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Electrical",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Electrical = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Electrical = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Metalworking"
    },
    quantity = 75,
    skills = {
        Metalworking = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Metalworking"
    },
    quantity = 3,
    skills = {
        Metalworking = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Metalworking = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Metalworking",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Metalworking = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Metalworking",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Metalworking = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Metalworking = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Metalworking",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Metalworking = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Metalworking",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Metalworking = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Metalworking = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Metalworking",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Metalworking = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Metalworking",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Metalworking = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Metalworking = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Mechanics"
    },
    quantity = 75,
    skills = {
        Mechanics = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Mechanics"
    },
    quantity = 3,
    skills = {
        Mechanics = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Mechanics = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Mechanics",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Mechanics = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Mechanics",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Mechanics = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Mechanics = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Mechanics",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Mechanics = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Mechanics",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Mechanics = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Mechanics = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Mechanics",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Mechanics = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Mechanics",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Mechanics = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Mechanics = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Spear"
    },
    quantity = 75,
    skills = {
        Spear = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Spear"
    },
    quantity = 3,
    skills = {
        Spear = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Spear = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Spear",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Spear = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Spear",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Spear = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Spear = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Spear",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Spear = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Spear",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Spear = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Spear = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Spear",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Spear = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Spear",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Spear = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Spear = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Maintenance"
    },
    quantity = 75,
    skills = {
        Maintenance = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Maintenance"
    },
    quantity = 3,
    skills = {
        Maintenance = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Maintenance = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Maintenance",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Maintenance = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Maintenance",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Maintenance = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Maintenance = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Maintenance",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Maintenance = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Maintenance",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Maintenance = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Maintenance = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Maintenance",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Maintenance = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Maintenance",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Maintenance = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Maintenance = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Short Blade"
    },
    quantity = 75,
    skills = {
        ["Short Blade"] = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Short Blade"
    },
    quantity = 3,
    skills = {
        ["Short Blade"] = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        ["Short Blade"] = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Short Blade",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        ["Short Blade"] = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Short Blade",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        ["Short Blade"] = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        ["Short Blade"] = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Short Blade",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        ["Short Blade"] = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Short Blade",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        ["Short Blade"] = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        ["Short Blade"] = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Short Blade",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        ["Short Blade"] = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Short Blade",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        ["Short Blade"] = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        ["Short Blade"] = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Long Blade"
    },
    quantity = 75,
    skills = {
        ["Long Blade"] = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Long Blade"
    },
    quantity = 3,
    skills = {
        ["Long Blade"] = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        ["Long Blade"] = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Long Blade",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        ["Long Blade"] = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Long Blade",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        ["Long Blade"] = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        ["Long Blade"] = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Long Blade",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        ["Long Blade"] = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Long Blade",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        ["Long Blade"] = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        ["Long Blade"] = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Long Blade",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        ["Long Blade"] = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Long Blade",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        ["Long Blade"] = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        ["Long Blade"] = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Short Blunt"
    },
    quantity = 75,
    skills = {
        ["Short Blunt"] = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Short Blunt"
    },
    quantity = 3,
    skills = {
        ["Short Blunt"] = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        ["Short Blunt"] = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Short Blunt",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        ["Short Blunt"] = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Short Blunt",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        ["Short Blunt"] = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        ["Short Blunt"] = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Short Blunt",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        ["Short Blunt"] = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Short Blunt",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        ["Short Blunt"] = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        ["Short Blunt"] = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Short Blunt",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        ["Short Blunt"] = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Short Blunt",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        ["Short Blunt"] = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        ["Short Blunt"] = false
    }
}, {
    inherits = "base-perk:basic1",
    display = {
        label = "Tailoring"
    },
    quantity = 75,
    skills = {
        Tailoring = {
            max = 2
        }
    },
    price = {
        currency = 7
    }
}, {
    inherits = "base-boost:basic1",
    display = {
        label = "Tailoring"
    },
    quantity = 3,
    skills = {
        Tailoring = {
            max = 2
        }
    },
    price = {
        currency = 7
    },
    boosts = {
        Tailoring = false
    }
}, {
    inherits = "base-perk:basic2",
    display = {
        label = "Tailoring",
        labelExt = "II"
    },
    quantity = 300,
    skills = {
        Tailoring = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    }
}, {
    inherits = "base-boost:basic2",
    display = {
        label = "Tailoring",
        labelExt = "II"
    },
    quantity = 3,
    skills = {
        Tailoring = {
            min = 3,
            max = 5
        }
    },
    price = {
        currency = 30
    },
    boosts = {
        Tailoring = false
    }
}, {
    inherits = "base-perk:basic3",
    display = {
        label = "Tailoring",
        labelExt = "III"
    },
    quantity = 1500,
    skills = {
        Tailoring = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    }
}, {
    inherits = "base-boost:basic3",
    display = {
        label = "Tailoring",
        labelExt = "III"
    },
    quantity = 3,
    skills = {
        Tailoring = {
            min = 6,
            max = 8
        }
    },
    price = {
        currency = 150
    },
    boosts = {
        Tailoring = false
    }
}, {
    inherits = "base-perk:basic4",
    display = {
        label = "Tailoring",
        labelExt = "IV"
    },
    quantity = 4500,
    skills = {
        Tailoring = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    }
}, {
    inherits = "base-boost:basic4",
    display = {
        label = "Tailoring",
        labelExt = "IV"
    },
    quantity = 3,
    skills = {
        Tailoring = {
            min = 9,
            max = 10
        }
    },
    price = {
        currency = 450
    },
    boosts = {
        Tailoring = false
    }
}}
