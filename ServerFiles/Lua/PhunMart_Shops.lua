return { --[[

    Base shops
    These are used for creating the actual shops used in the world

--]] {
    abstract = true,
    key = "base:shop",
    fills = {
        min = 2,
        max = 5
    },
    probability = 15,
    restock = 120,
    currency = "Base.Money", -- the default currency for shops
    backgroundImage = "machine-none",
    spites = {"location_shop_accessories_01_17", "location_shop_accessories_01_16", "location_shop_accessories_01_28",
              "location_shop_accessories_01_29", "location_shop_accessories_01_19", "location_shop_accessories_01_18"}
}, {
    abstract = true,
    key = "base:food",
    inherits = "base:shop",
    pools = {
        items = {{
            rolls = 7,
            filters = {
                tags = "food,fruit,drink",
                files = "PhunMart_FoodItems.lua"
            }
        }, {
            rolls = 6,
            filters = {
                tags = "veg,cooking,readytoeat",
                files = "PhunMart_FoodItems.lua"
            }
        }}
    },
    backgroundImage = "machine-good-phoods"
}, {
    abstract = true,
    key = "base:junk_food",
    inherits = "base:food",
    filters = {
        tags = "junk,breads,readytoeat,condiments,pie"
    },
    backgroundImage = "machine-phat-phoods"
}, {
    abstract = true,
    key = "base:tools",
    inherits = "base:shop",
    backgroundImage = "machine-pity-the-tool",
    filters = {
        tags = "welding,tools,melee,mechanics",
        files = "PhunMart_ToolItems.lua"
    }
}, {
    abstract = true,
    key = "base:xp",
    inherits = "base:shop",
    backgroundImage = "machine-budget-xp",
    currency = "PhunMart.TraiterToken", -- change default currency to traiter tokens
    filters = {
        tags = "perks1,perks2",
        files = "PhunMart_PerkItems.lua"
    }
}, {
    abstract = true,
    key = "base:xp2",
    inherits = "base:xp",
    backgroundImage = "machine-gifted-xp",
    filters = {
        tags = "perks2,perks3,boosts1,boosts2"
    }
}, {
    abstract = true,
    key = "base:xp3",
    inherits = "base:xp",
    backgroundImage = "machine-luxury-xp",
    filters = {
        tags = "perks3,perks4,boosts3,boosts4"
    }
}, {
    abstract = true,
    key = "base:traits",
    inherits = "base:shop",
    requiresPower = true,
    backgroundImage = "machine-new-u",
    filters = {
        tags = "positive,negative",
        files = "PhunMart_TraitItems.lua"
    }
}, {
    abstract = true,
    key = "base:vehicles",
    inherits = "base:shop",
    requiresPower = true,
    backgroundImage = "machine-wrent-a-wreck",
    filters = {
        files = "PhunMart_VehicleItems.lua"
    }
}, {
    abstract = true,
    key = "base:guns",
    inherits = "base:shop",
    backgroundImage = "machine-final-ammendment",
    filters = {
        tags = "ammo,pistol,melee,wear",
        files = "PhunMart_WeaponItems.lua"
    }
}, {
    abstract = true,
    key = "base:travel",
    inherits = "base:shop",
    backgroundImage = "machine-budget-travel",
    filters = {
        files = "PhunMart_PortItems.lua"
    }
}, --[[

    Actual shops

--]] {
    key = "SHOP:FOOD:phat_phoods",
    inherits = "base:junk_food"

}, {
    key = "SHOP:FOOD:good_phoods",
    inherits = "base:food"
}, {
    key = "SHOP:FOOD:phat_foods_alcohol",
    inherits = "base:junk_food",
    filters = {
        tags = "alcohol"
    }
}, {
    key = "SHOP:TOOLS:pitty_the_tool",
    inherits = "base:tools"
}, {
    key = "SHOP:XP:great_xperiences",
    inherits = "base:xp"
}, {
    key = "SHOP:XP:great_xperiences_2",
    inherits = "base:xp2"
}, {
    key = "SHOP:TRAITS:traiter_joes",
    inherits = "base:traits"
}, {
    key = "SHOP:CARS:wrent_a_wreck",
    inherits = "base:vehicles"
}, {
    key = "SHOP:WEAPONS:final_ammendment",
    inherits = "base:guns",
    requiresPower = true
}, {
    key = "SHOP:TRVEL:budget_travel",
    inherits = "base:travel"
}}
