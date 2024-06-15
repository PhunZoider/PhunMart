return {{
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:can",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Canned",
    tags = "canned",
    level = 1,
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:ing",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Misc",
    tags = "food",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:junk",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Junk",
    tags = "junk",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:ready",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Ready",
    tags = "readytoeat",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:drink",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Drink",
    tags = "drinks",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:bulk",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Bulk",
    tags = "veg",
    probability = 5,
    price = {
        currency = {
            min = 10,
            max = 25
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:fruit",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Fruit",
    tags = "fruit",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:bug",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Bugs",
    tags = "bugs",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:alcohol",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Alcohol",
    tag = "alcohol",
    price = {
        currency = {
            min = 1,
            max = 5
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:meat",
    inventory = {
        min = 2,
        max = 5
    },
    tags = "meat",
    tab = "Meat",
    price = {
        currency = {
            min = 3,
            max = 10
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:cond",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Condiments",
    tags = "condiments",
    price = {
        currency = {
            min = 10,
            max = 30
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:pie",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Baked",
    tags = "baked",
    price = {
        currency = {
            min = 10,
            max = 30
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:fish",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Fish",
    tags = "fish",
    price = {
        currency = {
            min = 4,
            max = 10
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:veg",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Veg",
    tags = "veg",
    price = {
        currency = {
            min = 4,
            max = 10
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:bake",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Bakery",
    tags = "cooking",
    price = {
        currency = {
            min = 4,
            max = 10
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:bread",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Breads",
    tags = "breads",
    price = {
        currency = {
            min = 4,
            max = 10
        }
    }
}, {
    abstract = true, -- don't validate this item or use it for anything other than inheriting from
    key = "base-food:medical",
    inventory = {
        min = 2,
        max = 5
    },
    tab = "Medical",
    tags = "cure",
    price = {
        currency = {
            min = 4,
            max = 10
        }
    }
}, {
    name = "Base.CannedPineapple",
    inherits = "base-food:can"
}, {
    name = "Base.Crackers",
    inherits = "base-food:ing"
}, {
    name = "Base.GummyBears",
    inherits = "base-food:junk"
}, {
    name = "Base.StewBowl",
    inherits = "base-food:ready"
}, {
    name = "Base.ColdCuppa",
    inherits = "base-food:drink"
}, {
    name = "Base.Corndog",
    inherits = "base-food:ready"
}, {
    name = "Base.CannedTomatoOpen",
    inherits = "base-food:can"
}, {
    name = "Base.SackProduce_Strawberry",
    inherits = "base-food:bulk"
}, {
    name = "Base.Watermelon",
    inherits = "base-food:fruit"
}, {
    name = "Base.SackProduce_Grapes",
    inherits = "base-food:bulk"
}, {
    name = "Base.SwallowtailCaterpillar",
    inherits = "base-food:bug"
}, {
    name = "Base.CannedMushroomSoup",
    inherits = "base-food:can"
}, {
    name = "Base.WhiskeyFull",
    inherits = "base-food:alcohol"
}, {
    name = "Base.PizzaRecipe",
    inherits = "base-food:ready"
}, {
    name = "Base.Rabbitmeat",
    inherits = "base-food:meat"
}, {
    name = "Base.Jujubes",
    inherits = "base-food:junk"
}, {
    name = "Base.Peanuts",
    inherits = "base-food:ready"
}, {
    name = "Base.Flour",
    inherits = "base-food:ing"
}, {
    name = "Base.CandyPackage",
    inherits = "base-food:junk"
}, {
    name = "Base.CannedTomato",
    inherits = "base-food:can"
}, {
    name = "Base.Yoghurt",
    inherits = "base-food:ready"
}, {
    name = "Base.Termites",
    inherits = "base-food:bug"
}, {
    name = "Base.SackProduce_Cabbage",
    inherits = "base-food:bulk"
}, {
    name = "Base.Apple",
    inherits = "base-food:fruit"
}, {
    name = "Base.CannedRedRadish",
    inherits = "base-food:can"
}, {
    name = "Base.Mustard",
    inherits = "base-food:cond"
}, {
    name = "Base.GingerPickled",
    inherits = "base-food:can"
}, {
    name = "Base.Cockroach",
    inherits = "base-food:bug"
}, {
    name = "Base.SugarPacket",
    inherits = "base-food:cond"
}, {
    name = "Base.Waffles",
    inherits = "base-food:ready"
}, {
    name = "Base.BerryBlue",
    inherits = "base-food:fruit"
}, {
    name = "Base.OystersFried",
    inherits = "base-food:ready"
}, {
    name = "Base.Avocado",
    inherits = "base-food:fruit"
}, {
    name = "Base.Millipede",
    inherits = "base-food:bug"
}, {
    name = "Base.HotDrinkTea",
    inherits = "base-food:drink"
}, {
    name = "Base.HotDrink",
    inherits = "base-food:drink"
}, {
    name = "Base.CakeRaw",
    inherits = "base-food:pie"
}, {
    name = "Base.JuiceBox",
    inherits = "base-food:drink"
}, {
    name = "Base.HollyBerry",
    inherits = "base-food:fruit"
}, {
    name = "Base.CakeSlice",
    inherits = "base-food:pie"
}, {
    name = "Base.Smallbirdmeat",
    inherits = "base-food:meat"
}, {
    name = "Base.Ramen",
    inherits = "base-food:ing"
}, {
    name = "Base.ShrimpFriedCraft",
    inherits = "base-food:ready"
}, {
    name = "Base.Shrimp",
    inherits = "base-food:fish"
}, {
    name = "Base.CannedPotatoOpen",
    inherits = "base-food:can"
}, {
    name = "Base.MeatSteamBun",
    inherits = "base-food:ready"
}, {
    name = "Base.PepperJalapeno",
    inherits = "base-food:veg"
}, {
    name = "Base.Salmon",
    inherits = "base-food:fish"
}, {
    name = "Base.BeautyBerry",
    inherits = "base-food:fruit"
}, {
    name = "Base.RefriedBeans",
    inherits = "base-food:ing"
}, {
    name = "Base.CookiesOatmeal",
    inherits = "base-food:junk"
}, {
    name = "Base.CannedBologneseOpen",
    inherits = "base-food:can"
}, {
    name = "Base.Hotsauce",
    inherits = "base-food:cond"
}, {
    name = "Base.WildEggs",
    inherits = "base-food:ing"
}, {
    name = "Base.MeatDumpling",
    inherits = "base-food:ready"
}, {
    name = "Base.BurgerRecipe",
    inherits = "base-food:ready"
}, {
    name = "Base.TomatoPaste",
    inherits = "base-food:ing"
}, {
    name = "Base.Grasshopper",
    inherits = "base-food:bug"
}, {
    name = "Base.Marshmallows",
    inherits = "base-food:junk"
}, {
    name = "Base.Beer2",
    inherits = "base-food:alcohol"
}, {
    name = "Base.ConeIcecream",
    inherits = "base-food:junk"
}, {
    name = "Base.Fries",
    inherits = "base-food:junk"
}, {
    name = "Base.SawflyLarva",
    inherits = "base-food:bug"
}, {
    name = "Base.Chocolate",
    inherits = "base-food:junk"
}, {
    name = "Base.CandyFruitSlices",
    inherits = "base-food:junk"
}, {
    name = "Base.BaguetteDough",
    inherits = "base-food:bake"
}, {
    name = "Base.DoughnutFrosted",
    inherits = "base-food:junk"
}, {
    name = "Base.TunaTin",
    inherits = "base-food:can"
}, {
    name = "Base.SnoGlobes",
    inherits = "base-food:junk"
}, {
    name = "Base.BreadDough",
    inherits = "base-food:bake"
}, {
    name = "Base.BouillonCube",
    inherits = "base-food:ing"
}, {
    name = "Base.ChocolateCoveredCoffeeBeans",
    inherits = "base-food:ing"
}, {
    name = "Base.PieKeyLime",
    inherits = "base-food:pie"
}, {
    name = "Base.ShrimpDumpling",
    inherits = "base-food:ready"
}, {
    name = "Base.BaloneySlice",
    inherits = "base-food:meat"
}, {
    name = "Base.MushroomGeneric5",
    inherits = "base-food:ing"
}, {
    name = "Base.MushroomGeneric6",
    inherits = "base-food:ing"
}, {
    name = "Base.SushiEgg",
    inherits = "base-food:ing"
}, {
    name = "Base.MushroomGeneric3",
    inherits = "base-food:ing"
}, {
    name = "Base.MushroomGeneric4",
    inherits = "base-food:ing"
}, {
    name = "Base.MushroomGeneric1",
    inherits = "base-food:ing"
}, {
    name = "Base.Toast",
    inherits = "base-food:bread"
}, {
    name = "Base.MushroomGeneric2",
    inherits = "base-food:ing"
}, {
    name = "Base.MushroomGeneric7",
    inherits = "base-food:ing"
}, {
    name = "Base.CannedSardines",
    inherits = "base-food:can"
}, {
    name = "Base.Popcorn",
    inherits = "base-food:junk"
}, {
    name = "Base.Pretzel",
    inherits = "base-food:junk"
}, {
    name = "Base.CookieChocolateChip",
    inherits = "base-food:junk"
}, {
    name = "Base.JellyBeans",
    inherits = "base-food:junk"
}, {
    name = "Base.Cupcake",
    inherits = "base-food:junk"
}, {
    name = "Base.Blackbeans",
    inherits = "base-food:ing"
}, {
    name = "Base.Trout",
    inherits = "base-food:fish"
}, {
    name = "Base.ChickenFoot",
    inherits = "base-food:meat"
}, {
    name = "Base.Rosemary",
    inherits = "base-food:ing"
}, {
    name = "Base.EggOmelette",
    inherits = "base-food:ready"
}, {
    name = "Base.Cone",
    inherits = "base-food:junk"
}, {
    name = "Base.CannedFruitCocktail",
    inherits = "base-food:can"
}, {
    name = "Base.GrapeLeaves",
    inherits = "base-food:ing"
}, {
    name = "Base.TofuFried",
    inherits = "base-food:ready"
}, {
    name = "Base.PieLemonMeringue",
    inherits = "base-food:pie"
}, {
    name = "Base.BaitFish",
    inherits = "base-food:fish"
}, {
    name = "Base.BerryGeneric5",
    inherits = "base-food:fruit"
}, {
    name = "Base.Lime",
    inherits = "base-food:fruit"
}, {
    name = "Base.BerryGeneric1",
    inherits = "base-food:fruit"
}, {
    name = "Base.BerryGeneric2",
    inherits = "base-food:fruit"
}, {
    name = "Base.BerryGeneric3",
    inherits = "base-food:fruit"
}, {
    name = "Base.BerryGeneric4",
    inherits = "base-food:fruit"
}, {
    name = "Base.Leek",
    inherits = "base-food:veg"
}, {
    name = "Base.Corn",
    inherits = "base-food:veg"
}, {
    name = "Base.Sage",
    inherits = "base-food:ing"
}, {
    name = "Base.Wine",
    inherits = "base-food:alcohol"
}, {
    name = "Base.GrilledCheese",
    inherits = "base-food:ready"
}, {
    name = "Base.PancakesCraft",
    inherits = "base-food:ready"
}, {
    name = "Base.DoughnutJelly",
    inherits = "base-food:junk"
}, {
    name = "Base.BagelPlain",
    inherits = "base-food:bread"
}, {
    name = "Base.Salt",
    inherits = "base-food:cond"
}, {
    name = "Base.Lettuce",
    inherits = "base-food:veg"
}, {
    name = "Base.Guacamole",
    inherits = "base-food:ing"
}, {
    name = "Base.Centipede2",
    inherits = "base-food:bug"
}, {
    name = "Base.Thyme",
    inherits = "base-food:ing"
}, {
    name = "Base.SackProduce_Onion",
    inherits = "base-food:bulk"
}, {
    name = "Base.Dough",
    inherits = "base-food:bake"
}, {
    name = "Base.CannedMilkOpen",
    inherits = "base-food:can"
}, {
    name = "Base.TortillaChips",
    inherits = "base-food:junk"
}, {
    name = "Base.CannedBroccoli",
    inherits = "base-food:can"
}, {
    name = "Base.FishRoe",
    inherits = "base-food:ready"
}, {
    name = "Base.MuttonChop",
    inherits = "base-food:meat"
}, {
    name = "Base.OmeletteRecipe",
    inherits = "base-food:ready"
}, {
    name = "Base.EggPoached",
    inherits = "base-food:ready"
}, {
    name = "Base.SackProduce_Cherry",
    inherits = "base-food:bulk"
}, {
    name = "Base.Centipede",
    inherits = "base-food:meat"
}, {
    name = "Base.PanFriedVegetables",
    inherits = "base-food:ready"
}, {
    name = "Base.CinnamonRoll",
    inherits = "base-food:junk"
}, {
    name = "Base.CannedBolognese",
    inherits = "base-food:can"
}, {
    name = "Base.SackProduce_Lettuce",
    inherits = "base-food:bulk"
}, {
    name = "Base.PeanutButter",
    inherits = "base-food:ing"
}, {
    name = "Base.Zucchini",
    inherits = "base-food:veg"
}, {
    name = "Base.Daikon",
    inherits = "base-food:veg"
}, {
    name = "Base.Pike",
    inherits = "base-food:fish"
}, {
    name = "Base.Peas",
    inherits = "base-food:veg"
}, {
    name = "Base.Sausage",
    inherits = "base-food:meat"
}, {
    name = "Base.Pear",
    inherits = "base-food:fruit"
}, {
    name = "Base.CakeBatter",
    inherits = "base-food:bake"
}, {
    name = "Base.Crisps3",
    inherits = "base-food:junk"
}, {
    name = "Base.Crisps2",
    inherits = "base-food:junk"
}, {
    name = "Base.Crisps4",
    inherits = "base-food:junk"
}, {
    name = "Base.CannedFruitBeverageOpen",
    inherits = "base-food:can"
}, {
    name = "Base.TinnedSoup",
    inherits = "base-food:can"
}, {
    name = "Base.OatsRaw",
    inherits = "base-food:ing"
}, {
    name = "Base.CakeChocolate",
    inherits = "base-food:pie"
}, {
    name = "Base.Butter",
    inherits = "base-food:ing"
}, {
    name = "Base.Cornflour",
    inherits = "base-food:ing"
}, {
    name = "Base.CannedBellPepper",
    inherits = "base-food:can"
}, {
    name = "Base.CannedPeaches",
    inherits = "base-food:can"
}, {
    name = "Base.FruitSalad",
    inherits = "base-food:ready"
}, {
    name = "Base.SugarBrown",
    inherits = "base-food:ing"
}, {
    name = "Base.SackProduce_Potato",
    inherits = "base-food:bulk"
}, {
    name = "Base.SackProduce_Broccoli",
    inherits = "base-food:bulk"
}, {
    name = "Base.CannedPeachesOpen",
    inherits = "base-food:can"
}, {
    name = "Base.PieApple",
    inherits = "base-food:ready"
}, {
    name = "Base.PotOfSoupRecipe",
    inherits = "base-food:ready"
}, {
    name = "Base.Peppermint",
    inherits = "base-food:ing"
}, {
    name = "Base.CookiesShortbread",
    inherits = "base-food:junk"
}, {
    name = "Base.Wine2",
    inherits = "base-food:alcohol"
}, {
    name = "Base.Squid",
    inherits = "base-food:fish"
}, {
    name = "Base.Gravy",
    inherits = "base-food:cond"
}, {
    name = "Base.BerryPoisonIvy",
    inherits = "base-food:fruit"
}, {
    name = "Base.Steak",
    inherits = "base-food:meat"
}, {
    name = "Base.Macandcheese",
    inherits = "base-food:ready"
}, {
    name = "Base.SackProduce_Eggplant",
    inherits = "base-food:bulk"
}, {
    name = "Base.Salami",
    inherits = "base-food:meat"
}, {
    name = "Base.PepperHabanero",
    inherits = "base-food:veg"
}, {
    name = "Base.CakeStrawberryShortcake",
    inherits = "base-food:pie"
}, {
    name = "Base.Pepperoni",
    inherits = "base-food:meat"
}, {
    name = "Base.CookiesChocolate",
    inherits = "base-food:junk"
}, {
    name = "Base.PanFriedVegetables2",
    inherits = "base-food:ready"
}, {
    name = "Base.PieWholeRawSweet",
    inherits = "base-food:pie"
}, {
    name = "Base.DriedChickpeas",
    inherits = "base-food:veg"
}, {
    name = "Base.GranolaBar",
    inherits = "base-food:ready"
}, {
    name = "Base.DriedKidneyBeans",
    inherits = "base-food:veg"
}, {
    name = "Base.DoughRolled",
    inherits = "base-food:bake"
}, {
    name = "Base.OilOlive",
    inherits = "base-food:cond"
}, {
    name = "Base.EggBoiled",
    inherits = "base-food:ready"
}, {
    name = "Base.DeadBird",
    inherits = "base-food:meat"
}, {
    name = "Base.Edamame",
    inherits = "base-food:ready"
}, {
    name = "Base.HiHis",
    inherits = "base-food:junk"
}, {
    name = "Base.BurritoRecipe",
    inherits = "base-food:ready"
}, {
    name = "Base.Lard",
    inherits = "base-food:ing"
}, {
    name = "Base.SackProduce_Corn",
    inherits = "base-food:bulk"
}, {
    name = "Base.BeefJerky",
    inherits = "base-food:ready"
}, {
    name = "Base.DeadSquirrel",
    inherits = "base-food:meat"
}, {
    name = "Base.CakeBlackForest",
    inherits = "base-food:pie"
}, {
    name = "Base.DeadMouse",
    inherits = "base-food:meat"
}, {
    name = "Base.SackProduce_Leek",
    inherits = "base-food:bulk"
}, {
    name = "Base.PorkChop",
    inherits = "base-food:meat"
}, {
    name = "Base.CannedCarrots",
    inherits = "base-food:can"
}, {
    name = "Base.CandyCorn",
    inherits = "base-food:junk"
}, {
    name = "Base.RicePaper",
    inherits = "base-food:ing"
}, {
    name = "Base.PieWholeRaw",
    inherits = "base-food:pie"
}, {
    name = "Base.ChickenFried",
    inherits = "base-food:ready"
}, {
    name = "Base.Catfish",
    inherits = "base-food:fish"
}, {
    name = "Base.ColdDrinkSpiffo",
    inherits = "base-food:drink"
}, {
    name = "Base.CocoaPowder",
    inherits = "base-food:ing"
}, {
    name = "Base.ColdDrinkWhite",
    inherits = "base-food:drink"
}, {
    name = "Base.GummyWorms",
    inherits = "base-food:junk"
}, {
    name = "Base.CookieChocolateChipDough",
    inherits = "base-food:bake"
}, {
    name = "Base.DriedSplitPeas",
    inherits = "base-food:veg"
}, {
    name = "Base.Oysters",
    inherits = "base-food:fish"
}, {
    name = "Base.CannedCarrotsOpen",
    inherits = "base-food:can"
}, {
    name = "Base.ChocoCakes",
    inherits = "base-food:junk"
}, {
    name = "Base.Taco",
    inherits = "base-food:ready"
}, {
    name = "Base.CannedCornedBeef",
    inherits = "base-food:can"
}, {
    name = "Base.OnionRings",
    inherits = "base-food:ready"
}, {
    name = "Base.GingerRoot",
    inherits = "base-food:ing"
}, {
    name = "Base.DehydratedMeatStick",
    inherits = "base-food:junk"
}, {
    name = "Base.Mango",
    inherits = "base-food:fruit"
}, {
    name = "Base.SackProduce_Peach",
    inherits = "base-food:bulk"
}, {
    name = "Base.Basil",
    inherits = "base-food:ing"
}, {
    name = "Base.FriedOnionRings",
    inherits = "base-food:ready"
}, {
    name = "Base.SackProduce_Pear",
    inherits = "base-food:bulk"
}, {
    name = "Base.RockCandy",
    inherits = "base-food:junk"
}, {
    name = "Base.JamMarmalade",
    inherits = "base-food:ing"
}, {
    name = "Base.CannedEggplant",
    inherits = "base-food:veg"
}, {
    name = "Base.DoughnutPlain",
    inherits = "base-food:junk"
}, {
    name = "Base.SackProduce_RedRadish",
    inherits = "base-food:bulk"
}, {
    name = "Base.TacoShell",
    inherits = "base-food:ing"
}, {
    name = "Base.BeerCan",
    inherits = "base-food:alcohol"
}, {
    name = "Base.Milk",
    inherits = "base-food:drink"
}, {
    name = "Base.Springroll",
    inherits = "base-food:ing"
}, {
    name = "Base.HotDrinkWhite",
    inherits = "base-food:drink"
}, {
    name = "Base.Pancakes",
    inherits = "base-food:ready"
}, {
    name = "Base.IcecreamMelted",
    inherits = "base-food:ready"
}, {
    name = "Base.DriedBlackBeans",
    inherits = "base-food:veg"
}, {
    name = "Base.CookieJelly",
    inherits = "base-food:junk"
}, {
    name = "Base.CakeRedVelvet",
    inherits = "base-food:pie"
}, {
    name = "Base.CannedTomato2",
    inherits = "base-food:can"
}, {
    name = "Base.Beer",
    inherits = "base-food:alcohol"
}, {
    name = "Base.Icing",
    inherits = "base-food:ing"
}, {
    name = "Base.CannedCornOpen",
    inherits = "base-food:can"
}, {
    name = "Base.Teabag2",
    inherits = "base-food:drink"
}, {
    name = "Base.Margarine",
    inherits = "base-food:ing"
}, {
    name = "Base.LicoriceRed",
    inherits = "base-food:junk"
}, {
    name = "Base.CookiesShortbreadDough",
    inherits = "base-food:bake"
}, {
    name = "Base.PieDough",
    inherits = "base-food:bake"
}, {
    name = "Base.CornFrozen",
    inherits = "base-food:veg"
}, {
    name = "Base.Chives",
    inherits = "base-food:ing"
}, {
    name = "Base.Oatmeal",
    inherits = "base-food:ready"
}, {
    name = "Base.Burrito",
    inherits = "base-food:ready"
}, {
    name = "Base.Cheese",
    inherits = "base-food:ing"
}, {
    name = "Base.WatermelonSliced",
    inherits = "base-food:fruit"
}, {
    name = "Base.HotDrinkSpiffo",
    inherits = "base-food:drink"
}, {
    name = "Base.Pizza",
    inherits = "base-food:ready"
}, {
    name = "Base.BandedWoolyBearCaterpillar",
    inherits = "base-food:bug"
}, {
    name = "Base.CannedCarrots2",
    inherits = "base-food:can"
}, {
    name = "Base.CannedPeasOpen",
    inherits = "base-food:veg"
}, {
    name = "Base.FrogMeat",
    inherits = "base-food:meat"
}, {
    name = "Base.Biscuit",
    inherits = "base-food:bread"
}, {
    name = "Base.BeerBottle",
    inherits = "base-food:alcohol"
}, {
    name = "Base.PotatoPancakes",
    inherits = "base-food:ready"
}, {
    name = "Base.Gum",
    inherits = "base-food:junk"
}, {
    name = "Base.Perogies",
    inherits = "base-food:junk"
}, {
    name = "Base.Cereal",
    inherits = "base-food:ready"
}, {
    name = "Base.Nettles",
    inherits = "base-food:ing"
}, {
    name = "Base.CannedMilk",
    inherits = "base-food:can"
}, {
    name = "Base.Cilantro",
    inherits = "base-food:ing"
}, {
    name = "Base.Pie",
    inherits = "base-food:pie"
}, {
    name = "Base.PiePrep",
    inherits = "base-food:bake"
}, {
    name = "Base.ConeIcecreamToppings",
    inherits = "base-food:junk"
}, {
    name = "Base.Crisps",
    inherits = "base-food:junk"
}, {
    name = "Base.BellPepper",
    inherits = "base-food:veg"
}, {
    name = "Base.CannedPineappleOpen",
    inherits = "base-food:can"
}, {
    name = "Base.Cherry",
    inherits = "base-food:fruit"
}, {
    name = "Base.MintCandy",
    inherits = "base-food:junk"
}, {
    name = "Base.Maggots",
    inherits = "base-food:bug"
}, {
    name = "Base.Maggots2",
    inherits = "base-food:bug"
}, {
    name = "Base.Sugar",
    inherits = "base-food:cond"
}, {
    name = "Base.FishFried",
    inherits = "base-food:ready"
}, {
    name = "Base.Soysauce",
    inherits = "base-food:cond"
}, {
    name = "Base.CannedSardinesOpen",
    inherits = "base-food:can"
}, {
    name = "Base.CookiesOatmealDough",
    inherits = "base-food:bake"
}, {
    name = "Base.HamSlice",
    inherits = "base-food:meat"
}, {
    name = "Base.Pop",
    inherits = "base-food:drink"
}, {
    name = "Base.TinnedBeans",
    inherits = "base-food:can"
}, {
    name = "Base.CannedFruitCocktailOpen",
    inherits = "base-food:can"
}, {
    name = "Base.Maki",
    inherits = "base-food:fish"
}, {
    name = "Base.CannedCabbage",
    inherits = "base-food:can"
}, {
    name = "Base.Chicken",
    inherits = "base-food:meat"
}, {
    name = "Base.GlassWineWater",
    inherits = "base-food:alcohol"
}, {
    name = "Base.Cornbread",
    inherits = "base-food:ready"
}, {
    name = "Base.CookiesSugar",
    inherits = "base-food:ing"
}, {
    name = "Base.Pineapple",
    inherits = "base-food:fruit"
}, {
    name = "Base.SunflowerSeeds",
    inherits = "base-food:ready"
}, {
    name = "Base.Ham",
    inherits = "base-food:ready"
}, {
    name = "Base.Pumpkin",
    inherits = "base-food:veg"
}, {
    name = "Base.Oregano",
    inherits = "base-food:ing"
}, {
    name = "Base.SushiFish",
    inherits = "base-food:ready"
}, {
    name = "Base.DoughnutChocolate",
    inherits = "base-food:junk"
}, {
    name = "Base.Beverage",
    inherits = "base-food:drink"
}, {
    name = "Base.HardCandies",
    inherits = "base-food:junk"
}, {
    name = "Base.CannedChiliOpen",
    inherits = "base-food:can"
}, {
    name = "Base.ShrimpFried",
    inherits = "base-food:ready"
}, {
    name = "Base.QuaggaCakes",
    inherits = "base-food:junk"
}, {
    name = "Base.SalamiSlice",
    inherits = "base-food:meat"
}, {
    name = "Base.Icecream",
    inherits = "base-food:junk"
}, {
    name = "Base.Coffee2",
    inherits = "base-food:drink"
}, {
    name = "Base.Yeast",
    inherits = "base-food:bake"
}, {
    name = "Base.Bass",
    inherits = "base-food:fish"
}, {
    name = "Base.Marinara",
    inherits = "base-food:can"
}, {
    name = "Base.BagelPoppy",
    inherits = "base-food:bread"
}, {
    name = "Base.Pasta",
    inherits = "base-food:ing"
}, {
    name = "Base.Pickles",
    inherits = "base-food:ing"
}, {
    name = "Base.Cornmeal",
    inherits = "base-food:ing"
}, {
    name = "Base.Teabag",
    inherits = "base-food:drink"
}, {
    name = "Base.Bread",
    inherits = "base-food:bread"
}, {
    name = "Base.Cricket",
    inherits = "base-food:bug"
}, {
    name = "Base.CheeseSandwich",
    inherits = "base-food:ready"
}, {
    name = "Base.Dogfood",
    inherits = "base-food:can"
}, {
    name = "Base.Worm",
    inherits = "base-food:bug"
}, {
    name = "Base.SackProduce_Carrot",
    inherits = "base-food:veg"
}, {
    name = "Base.Lollipop",
    inherits = "base-food:junk"
}, {
    name = "Base.Grapes",
    inherits = "base-food:fruit"
}, {
    name = "Base.PotOfStew",
    inherits = "base-food:ready"
}, {
    name = "Base.Parsley",
    inherits = "base-food:ing"
}, {
    name = "Base.Rosehips",
    inherits = "base-food:ing"
}, {
    name = "Base.Baloney",
    inherits = "base-food:meat"
}, {
    name = "Base.FishFillet",
    inherits = "base-food:meat"
}, {
    name = "Base.BaguetteSandwich",
    inherits = "base-food:ready"
}, {
    name = "Base.RamenBowl",
    inherits = "base-food:ready"
}, {
    name = "Base.Carrots",
    inherits = "base-food:veg"
}, {
    name = "Base.MapleSyrup",
    inherits = "base-food:cond"
}, {
    name = "Base.OpenBeans",
    inherits = "base-food:can"
}, {
    name = "Base.DeadRabbit",
    inherits = "base-food:meat"
}, {
    name = "Base.BagelSesame",
    inherits = "base-food:bread"
}, {
    name = "Base.Crappie",
    inherits = "base-food:fish"
}, {
    name = "Base.BerryBlack",
    inherits = "base-food:fruit"
}, {
    name = "Base.Tortilla",
    inherits = "base-food:ing"
}, {
    name = "Base.Croissant",
    inherits = "base-food:bread"
}, {
    name = "Base.CerealBowl",
    inherits = "base-food:ready"
}, {
    name = "Base.JamFruit",
    inherits = "base-food:ing"
}, {
    name = "Base.Panfish",
    inherits = "base-food:fish"
}, {
    name = "Base.Frog",
    inherits = "base-food:bug"
}, {
    name = "Base.PotOfSoup",
    inherits = "base-food:ready"
}, {
    name = "Base.LicoriceBlack",
    inherits = "base-food:junk"
}, {
    name = "Base.Sandwich",
    inherits = "base-food:ready"
}, {
    name = "Base.Pop3",
    inherits = "base-food:drink"
}, {
    name = "Base.Pepper",
    inherits = "base-food:veg"
}, {
    name = "Base.Pop2",
    inherits = "base-food:drink"
}, {
    name = "Base.Vinegar",
    inherits = "base-food:ing"
}, {
    name = "Base.Seaweed",
    inherits = "base-food:ing"
}, {
    name = "Base.EggScrambled",
    inherits = "base-food:ready"
}, {
    name = "Base.Snail",
    inherits = "base-food:bug"
}, {
    name = "Base.Painauchocolat",
    inherits = "base-food:bread"
}, {
    name = "Base.Mugfull",
    inherits = "base-food:drink"
}, {
    name = "Base.OilVegetable",
    inherits = "base-food:ing"
}, {
    name = "Base.SackProduce_BellPepper",
    inherits = "base-food:bulk"
}, {
    name = "Base.CannedFruitBeverage",
    inherits = "base-food:drink"
}, {
    name = "Base.DriedLentils",
    inherits = "base-food:veg"
}, {
    name = "Base.Tofu",
    inherits = "base-food:ing"
}, {
    name = "Base.HalloweenPumpkin",
    inherits = "base-food:veg"
}, {
    name = "Base.Ketchup",
    inherits = "base-food:cond"
}, {
    name = "Base.NoodleSoup",
    inherits = "base-food:ready"
}, {
    name = "Base.BreadSlices",
    inherits = "base-food:bread"
}, {
    name = "Base.TVDinner",
    inherits = "base-food:ready"
}, {
    name = "Base.Hotdog",
    inherits = "base-food:ready"
}, {
    name = "Base.Rice",
    inherits = "base-food:ing"
}, {
    name = "Base.PieBlueberry",
    inherits = "base-food:pie"
}, {
    name = "Base.PopBottle",
    inherits = "base-food:drink"
}, {
    name = "Base.PiePumpkin",
    inherits = "base-food:pie"
}, {
    name = "Base.Smallanimalmeat",
    inherits = "base-food:bug"
}, {
    name = "Base.GrahamCrackers",
    inherits = "base-food:ing"
}, {
    name = "Base.Crayfish",
    inherits = "base-food:fish"
}, {
    name = "Base.Beverage2",
    inherits = "base-food:drink"
}, {
    name = "Base.CannedPotato2",
    inherits = "base-food:can"
}, {
    name = "Base.Onion",
    inherits = "base-food:veg"
}, {
    name = "Base.Plonkies",
    inherits = "base-food:junk"
}, {
    name = "Base.Lobster",
    inherits = "base-food:fish"
}, {
    name = "Base.BeanBowl",
    inherits = "base-food:ready"
}, {
    name = "Base.WafflesRecipe",
    inherits = "base-food:ready"
}, {
    name = "Base.SoupBowl",
    inherits = "base-food:ready"
}, {
    name = "Base.Violets",
    inherits = "base-food:ing"
}, {
    name = "Base.CannedLeek",
    inherits = "base-food:can"
}, {
    name = "Base.PeanutButterSandwich",
    inherits = "base-food:ready"
}, {
    name = "Base.Banana",
    inherits = "base-food:fruit"
}, {
    name = "Base.CannedPotato",
    inherits = "base-food:can"
}, {
    name = "Base.Millipede2",
    inherits = "base-food:bug"
}, {
    name = "Base.Processedcheese",
    inherits = "base-food:junk"
}, {
    name = "Base.CakeCheeseCake",
    inherits = "base-food:pie"
}, {
    name = "Base.CannedCorn",
    inherits = "base-food:can"
}, {
    name = "Base.LemonGrass",
    inherits = "base-food:ing"
}, {
    name = "Base.CannedCornedBeefOpen",
    inherits = "base-food:can"
}, {
    name = "Base.Slug2",
    inherits = "base-food:bug"
}, {
    name = "Base.DeadRat",
    inherits = "base-food:meat"
}, {
    name = "Base.ConeIcecreamMelted",
    inherits = "base-food:junk"
}, {
    name = "Base.CookiesChocolateDough",
    inherits = "base-food:bake"
}, {
    name = "Base.MuffinGeneric",
    inherits = "base-food:ready"
}, {
    name = "Base.DogfoodOpen",
    inherits = "base-food:can"
}, {
    name = "Base.WineInGlass",
    inherits = "base-food:alcohol"
}, {
    name = "Base.Thistle",
    inherits = "base-food:ing"
}, {
    name = "Base.CannedChili",
    inherits = "base-food:can"
}, {
    name = "Base.PastaBowl",
    inherits = "base-food:ready"
}, {
    name = "Base.Lemon",
    inherits = "base-food:fruit"
}, {
    name = "Base.SquidCalamari",
    inherits = "base-food:ready"
}, {
    name = "Base.SackProduce_Tomato",
    inherits = "base-food:bulk"
}, {
    name = "Base.AmericanLadyCaterpillar",
    inherits = "base-food:bug"
}, {
    name = "Base.PizzaWhole",
    inherits = "base-food:ready"
}, {
    name = "Base.CannedPeas",
    inherits = "base-food:can"
}, {
    name = "Base.Broccoli",
    inherits = "base-food:veg"
}, {
    name = "Base.Perch",
    inherits = "base-food:fish"
}, {
    name = "Base.ChickenNuggets",
    inherits = "base-food:ready"
}, {
    name = "Base.ChocolateChips",
    inherits = "base-food:ing"
}, {
    name = "Base.DriedWhiteBeans",
    inherits = "base-food:ing"
}, {
    name = "Base.Peach",
    inherits = "base-food:fruit"
}, {
    name = "Base.HotDrinkRed",
    inherits = "base-food:drink"
}, {
    name = "Base.SilkMothCaterpillar",
    inherits = "base-food:bug"
}, {
    name = "Base.Smore",
    inherits = "base-food:junk"
}, {
    name = "Base.Slug",
    inherits = "base-food:bug"
}, {
    name = "Base.MixedVegetables",
    inherits = "base-food:ready"
}, {
    name = "Base.Wasabi",
    inherits = "base-food:cond"
}, {
    name = "Base.Candycane",
    inherits = "base-food:junk"
}, {
    name = "Base.CakeCarrot",
    inherits = "base-food:pie"
}, {
    name = "Base.Orange",
    inherits = "base-food:fruit"
}, {
    name = "Base.MeatPatty",
    inherits = "base-food:meat"
}, {
    name = "Base.PancakesRecipe",
    inherits = "base-food:ready"
}, {
    name = "Base.Honey",
    inherits = "base-food:cond"
}, {
    name = "Base.Pillbug",
    inherits = "base-food:bug"
}, {
    name = "Base.WinterBerry",
    inherits = "base-food:fruit"
}, {
    name = "Base.MincedMeat",
    inherits = "base-food:meat"
}, {
    name = "Base.MonarchCaterpillar",
    inherits = "base-food:bug"
}, {
    name = "Base.FriedOnionRingsCraft",
    inherits = "base-food:ready"
}, {
    name = "Base.RiceBowl",
    inherits = "base-food:ready"
}, {
    name = "Base.Onigiri",
    inherits = "base-food:ready"
}, {
    name = "Base.CookiesSugarDough",
    inherits = "base-food:bake"
}, {
    name = "Base.Modjeska",
    inherits = "base-food:junk"
}, {
    name = "Base.SackProduce_Apple",
    inherits = "base-food:bulk"
}, {
    name = "Base.Baguette",
    inherits = "base-food:bread"
}, {
    name = "Base.GriddlePanFriedVegetables",
    inherits = "base-food:ready"
}, {
    name = "Base.RiceVinegar",
    inherits = "base-food:ing"
}, {
    name = "Base.EggCarton",
    inherits = "base-food:ing"
}, {
    name = "Base.Burger",
    inherits = "base-food:ready"
}, {
    name = "Base.CakePrep",
    inherits = "base-food:bake"
}, {
    name = "Base.Eggplant",
    inherits = "base-food:veg"
}, {
    name = "Base.Grapefruit",
    inherits = "base-food:fruit"
}, {
    name = "Base.ColdDrinkRed",
    inherits = "base-food:drink"
}, {
    name = "Base.Egg",
    inherits = "base-food:ing"
}, {
    name = "Base.TinnedSoupOpen",
    inherits = "base-food:can"
}, {
    name = "Base.MuffinFruit",
    inherits = "base-food:junk"
}, {
    name = "Base.CannedMushroomSoupOpen",
    inherits = "base-food:can"
}, {
    name = "farming.Tomato",
    inherits = "base-food:veg"
}, {
    name = "farming.Bacon",
    inherits = "base-food:meat"
}, {
    name = "farming.BaconRashers",
    inherits = "base-food:meat"
}, {
    name = "farming.Potato",
    inherits = "base-food:veg"
}, {
    name = "farming.MayonnaiseFull",
    inherits = "base-food:cond"
}, {
    name = "farming.Cabbage",
    inherits = "base-food:veg"
}, {
    name = "farming.Salad",
    inherits = "base-food:ready"
}, {
    name = "farming.Strewberrie",
    inherits = "base-food:fruit"
}, {
    name = "farming.MayonnaiseHalf",
    inherits = "base-food:cond"
}, {
    name = "farming.RedRadish",
    inherits = "base-food:veg"
}, {
    name = "farming.BaconBits",
    inherits = "base-food:meat"
}, {
    name = "TheyKnew.Zomboxycycline",
    inherits = "base-food:medical",
    mod = "TheyKnew"
}, {
    name = "TheyKnew.Zomboxivir",
    inherits = "base-food:medical",
    mod = "TheyKnew"
}}
