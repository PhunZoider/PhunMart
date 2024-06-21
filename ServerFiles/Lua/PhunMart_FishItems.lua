return {{
    abstract = true,
    key = "base-fish",
    tab = "Fish",
    tags = "fish",
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
    key = "base-fish-tackle",
    inherits = "base-fish",
    tab = "Tackle",
    tags = "fish,tackle"
}, {
    name = "Base.Salmon",
    inherits = "base-fish"
}, {
    name = "Base.Trout",
    inherits = "base-fish"
}, {
    name = "Base.FishRoe",
    inherits = "base-fish"
}, {
    name = "Base.Pike",
    inherits = "base-fish"
}, {
    name = "Base.Catfish",
    inherits = "base-fish"
}, {
    name = "Base.Maki",
    inherits = "base-fish"
}, {
    name = "Base.Bass",
    inherits = "base-fish"
}, {
    name = "Base.Crayfish",
    inherits = "base-fish"
}, {
    name = "Base.Perch",
    inherits = "base-fish"
}, {
    name = "Base.FishingLine",
    inherits = "base-fish-tackle"
}, {
    name = "Base.FishingRodBreak",
    inherits = "base-fish-tackle"
}, {
    name = "Base.Maggots",
    inherits = "base-fish-tackle"
}, {
    name = "Base.Maggots2",
    inherits = "base-fish-tackle"
}, {
    name = "Base.BaitFish",
    inherits = "base-fish-tackle"
}, {
    name = "Base.CraftedFishingRod",
    inherits = "base-fish-tackle"
}, {
    name = "Base.Worm",
    inherits = "base-fish-tackle"
}, {
    name = "Base.FishingNet",
    inherits = "base-fish-tackle"
}, {
    name = "Base.FishingRod",
    inherits = "base-fish-tackle"
}, {
    name = "Base.BrokenFishingNet",
    inherits = "base-fish-tackle"
}, {
    name = "Base.FishingTackle2",
    inherits = "base-fish-tackle"
}, {
    name = "Base.FishingTackle",
    inherits = "base-fish-tackle"
}, {
    name = "Base.CraftedFishingRodTwineLine",
    inherits = "base-fish-tackle"
}, {
    name = "Base.FishingRodTwineLine",
    inherits = "base-fish-tackle"
}}
