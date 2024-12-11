return {{
    isTemplate = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base:food",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Food",
    level = 1,
    price = {
        ["Base.Money"] = {
            min = 1,
            max = 5
        }
    }
}, {
    isTemplate = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base:fruit",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Fruits",
	tags = "fruits,healthy",
    price = {
        ["Base.Money"] = {
            min = 1,
            max = 5
        }
    }
}, {
    isTemplate = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base:junkfood",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Food",
	tags = "meats,junk",
    price = {
        ["Base.Money"] = {
            min = 1,
            max = 5
        }
    }
}, {
    isTemplate = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base:fish",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Fish",
	tags = "fish",
    price = {
        ["Base.Money"] = {
            min = 1,
            max = 5
        }
    }
}, {
    isTemplate = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base:breads",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Bread",
    price = {
        ["Base.Money"] = {
            min = 1,
            max = 5
        }
    }
}, {
    isTemplate = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base:raw-meat",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Meat",
	tags = "meat,cooking",
    price = {
        ["Base.Money"] = {
            min = 1,
            max = 5
        }
    }
}, {
    isTemplate = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base:foodingredients",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Ingredients",
	tags = "healthy,cooking",
    price = {
        ["Base.Money"] = {
            min = 1,
            max = 5
        }
    }
}, {
    isTemplate = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base:cannedfood",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Canned",
	tags = "food",
    price = {
        ["Base.Money"] = {
            min = 1,
            max = 5
        }
    }
}, {
    isTemplate = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base:drink",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Drink",
	tag = "drinks",
    price = {
        ["Base.Money"] = {
            min = 1,
            max = 5
        }
    }
}, {
    isTemplate = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base:alcohol",
    inventory = {
        min = 2,
        max = 5
    },
	tags = "alcohol",
    tab = "Alcohol",
    price = {
        ["Base.Money"] = {
            min = 3,
            max = 10
        }
    }
}, {
    isTemplate = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base:pistols",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Guns",
    price = {
        ["PhunWallet.SilverToken"] = {
            min = 10,
            max = 30
        }
    }
}, {
    isTemplate = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base:rifles",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Rifles",
    price = {
        ["PhunWallet.SilverToken"] = {
            min = 10,
            max = 30
        }
    }
}, {
    isTemplate = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base:tools",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Tools",
    price = {
        ["PhunWallet.SilverToken"] = {
            min = 4,
            max = 10
        }
    }
}}
