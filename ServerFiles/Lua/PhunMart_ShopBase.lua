return {{
    abstract = true, -- don't validate this shop or use it for anything other than inheriting from
    key = "base:phatphoods",
    fills = {
        min = 3,
        max = 5
    },
    filters = {
        tags = "junk,breads,readytoeat,condiments,pie",
        files = "PhunMart_FoodItems.lua"
    },
    backgroundImage = "machine-phat-phoods"
}, {
    abstract = true, -- don't validate this shop or use it for anything other than inheriting from
    key = "base:goodphoods",
    fills = {
        min = 3,
        max = 5
    },
    filters = {
        tags = "food,fruit,drink,veg,cooking,readytoeat",
        files = "PhunMart_FoodItems.lua"
    },
    backgroundImage = "machine-good-phoods"
}, {
    abstract = true, -- don't validate this shop or use it for anything other than inheriting from
    key = "base:pittythetool",
    fills = {
        min = 3,
        max = 5
    },
    probability = 15,
    restock = 120,
    backgroundImage = "machine-pity-the-tool",
    filters = {
        tags = "welding,tools,melee,mechanics",
        files = "PhunMart_ToolItems.lua"
    }
}, {
    abstract = true, -- don't validate this shop or use it for anything other than inheriting from
    key = "base:xperiences",
    fills = {
        min = 1,
        max = 5
    },
    probability = 15,
    restock = 120,
    backgroundImage = "machine-budget-xp",
    filters = {
        tags = "perks1,perks2",
        files = "PhunMart_PerkItems.lua"
    }
}, {
    abstract = true, -- don't validate this shop or use it for anything other than inheriting from
    key = "base:xperiences2",
    fills = {
        min = 1,
        max = 5
    },
    probability = 15,
    restock = 120,
    backgroundImage = "machine-budget-xp",
    filters = {
        tags = "perks2,perks3,boosts1,boosts2",
        files = "PhunMart_PerkItems.lua"
    }
}, {
    abstract = true, -- don't validate this shop or use it for anything other than inheriting from
    key = "base:traiterjoes",
    fills = {
        min = 3,
        max = 5
    },
    probability = 15,
    requiresPower = true,
    restock = 120,
    backgroundImage = "machine-new-u"
}, {
    abstract = true, -- don't validate this shop or use it for anything other than inheriting from
    key = "base:wrentawreck",
    fills = {
        min = 3,
        max = 5
    },
    probability = 15,
    requiresPower = true,
    restock = 120,
    backgroundImage = "machine-wrent-a-wreck",
    filters = {
        files = "PhunMart_VehicleItems.lua"
    }
}, {
    abstract = true, -- don't validate this shop or use it for anything other than inheriting from
    key = "base:finalammendment",
    fills = {
        min = 3,
        max = 5
    },
    probability = 15,
    restock = 120,
    backgroundImage = "machine-final-ammendment",
    filters = {
        tags = "ammo,pistol,melee,wear",
        files = "PhunMart_WeaponItems.lua"
    }
}, {
    abstract = true, -- don't validate this shop or use it for anything other than inheriting from
    key = "base:budgettravel",
    fills = {
        min = 3,
        max = 5
    },
    probability = 15,
    restock = 120,
    backgroundImage = "machine-budget-travel",
    filters = {
        files = "PhunMart_PortItems.lua"
    }
}}
