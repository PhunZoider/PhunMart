return {

    -- =========================================================
    -- GoodPhoods  (health foods, fresh produce, ingredients)
    -- =========================================================

    food_fresh = {
        defaults = {
            price = "coin_5",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"Food"}
        },
        -- Remove junk, candy, alcohol, soda so only wholesome food remains
        blacklist = { -- Chips / savoury snacks
        "Base.Crisps", "Base.Crisps2", "Base.Crisps3", "Base.Crisps4", "Base.TortillaChips", "Base.TortillaChipsBaked",
        "Base.PorkRinds", -- Candy & sweets
        "Base.CandyCorn", "Base.CandyGummyfish", "Base.CandyMolasses", "Base.CandyNovapops", "Base.Candycane",
        "Base.CandyPackage", "Base.GummyBears", "Base.GummyWorms", "Base.Jujubes", "Base.HardCandies",
        "Base.LicoriceBlack", "Base.LicoriceRed", "Base.Lollipop", "Base.MintCandy", "Base.Peppermint",
        "Base.RockCandy", "Base.AllSorts", "Base.CandyFruitSlices", "Base.CandyCaramels", "Base.Modjeska",
        -- Chocolate bars
        "Base.Chocolate_Butterchunkers", "Base.Chocolate_Candy", "Base.Chocolate_Crackle", "Base.Chocolate_Deux",
        "Base.Chocolate_GalacticDairy", "Base.Chocolate_HeartBox", "Base.Chocolate_Smirkers", "Base.Chocolate_SnikSnak",
        "Base.Chocolate_RoysPBPucks", "Base.ChocoCakes", -- Donuts & junk pastries
        "Base.DoughnutChocolate", "Base.DoughnutFrosted", "Base.DoughnutJelly", "Base.DoughnutPlain", -- Soda / cola
        "Base.Pop", "Base.Pop2", "Base.Pop3", "Base.PopBottle", "Base.SodaCan", "Base.PopBottleRare", -- Alcohol
        "Base.BeerBottle", "Base.BeerCan", "Base.BeerImported", "Base.BeerPack", "Base.BeerCanPack", "Base.Whiskey",
        "Base.Rum", "Base.Vodka", "Base.Gin", "Base.Tequila", "Base.Brandy", "Base.Scotch", "Base.Port", "Base.Sherry",
        "Base.Vermouth", "Base.CoffeeLiquer", "Base.Wine", "Base.Wine2", "Base.Wine2Open", "Base.WineAged",
        "Base.WineBox", "Base.WineOpen", "Base.WineScrewtop", "Base.WineRed_Boxed", "Base.WineWhite_Boxed",
        "Base.Champagne", "Base.Cider", -- Fast food / junk meals
        "Base.Hotdog", "Base.HotdogPack", "Base.Hotdog_single", "Base.Burger", "Base.BurgerRecipe", "Base.Pizza",
        "Base.PizzaRecipe", "Base.PizzaWhole", "Base.TVDinner", "Base.FrenchFries", "Base.Fries",
        "Base.Frozen_FrenchFries", "Base.Frozen_TatoDots", "Base.TatoDots", "Base.Corndog", -- Pet food
        "Base.Dogfood", "Base.DogfoodOpen", "Base.Dogfood_Box", "Base.CatFoodBag", "Base.CatTreats", "Base.DogFoodBag",
        -- Insects / gross items
        "Base.Worm", "Base.Maggots", "Base.Cockroach", "Base.Cricket", "Base.Centipede", "Base.Centipede2",
        "Base.Grasshopper", "Base.Ladybug", "Base.Leech", "Base.Millipede", "Base.Millipede2", "Base.Pillbug",
        "Base.Slug", "Base.Slug2", "Base.Snail", "Base.Tadpole", "Base.Termites", "Base.AmericanLadyCaterpillar",
        "Base.BandedWoolyBearCaterpillar", "Base.MonarchCaterpillar", "Base.SawflyLarva", "Base.SilkMothCaterpillar",
        "Base.SwallowtailCaterpillar", -- Dead animals
        "Base.DeadBird", "Base.DeadMouse", "Base.DeadMousePups", "Base.DeadMousePupsSkinned", "Base.DeadMouseSkinned",
        "Base.DeadRat", "Base.DeadRatBaby", "Base.DeadRatBabySkinned", "Base.DeadRatSkinned", "Base.DeadSquirrel"}
    },

    food_cooking_utensils = {
        defaults = {
            price = "coin_10",
            offer = {
                weight = 0.5
            }
        },
        include = {
            categories = {"Cooking"}
        }
    },

    -- =========================================================
    -- PhatPhoods  (junk food, candy, soda, alcohol)
    -- =========================================================

    food_junk = {
        defaults = {
            price = "coin_5",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = {"Base.Crisps", "Base.Crisps2", "Base.Crisps3", "Base.Crisps4", "Base.TortillaChips",
                     "Base.PorkRinds", "Base.CandyCorn", "Base.CandyGummyfish", "Base.CandyMolasses",
                     "Base.CandyNovapops", "Base.Candycane", "Base.GummyBears", "Base.GummyWorms", "Base.Jujubes",
                     "Base.HardCandies", "Base.LicoriceBlack", "Base.LicoriceRed", "Base.Lollipop", "Base.MintCandy",
                     "Base.Peppermint", "Base.RockCandy", "Base.AllSorts", "Base.CandyFruitSlices",
                     "Base.CandyCaramels", "Base.Chocolate_Butterchunkers", "Base.Chocolate_Candy",
                     "Base.Chocolate_Crackle", "Base.Chocolate_Deux", "Base.Chocolate_GalacticDairy",
                     "Base.Chocolate_Smirkers", "Base.Chocolate_SnikSnak", "Base.Chocolate_RoysPBPucks",
                     "Base.Chocolate_HeartBox", "Base.ChocoCakes", "Base.DoughnutChocolate", "Base.DoughnutFrosted",
                     "Base.DoughnutJelly", "Base.DoughnutPlain", "Base.Pop", "Base.Pop2", "Base.Pop3", "Base.PopBottle",
                     "Base.SodaCan", "Base.Hotdog", "Base.Hotdog_single", "Base.Burger", "Base.Pizza",
                     "Base.PizzaWhole", "Base.TVDinner", "Base.Corndog", "Base.FrenchFries", "Base.Fries",
                     "Base.Frozen_FrenchFries", "Base.TatoDots", "Base.Frozen_TatoDots", "Base.Crackers",
                     "Base.GrahamCrackers", "Base.Popcorn", "Base.Popsicle", "Base.Icecream", "Base.IcecreamSandwich",
                     "Base.FudgeePop", "Base.GranolaBar", "Base.CrispyRiceSquare", "Base.QuaggaCakes",
                     "Base.ScoutCookies", "Base.CookieChocolateChip", "Base.CookiesChocolate", "Base.CookiesOatmeal",
                     "Base.CookiesShortbread", "Base.CookiesSugar"}
        }
    },

    food_alcohol = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 0.8
            }
        },
        include = {
            items = {"Base.BeerBottle", "Base.BeerCan", "Base.BeerImported", "Base.Whiskey", "Base.Rum", "Base.Vodka",
                     "Base.Gin", "Base.Tequila", "Base.Brandy", "Base.Scotch", "Base.Port", "Base.Sherry", "Base.Wine",
                     "Base.Wine2", "Base.WineAged", "Base.WineScrewtop", "Base.Champagne", "Base.Cider"}
        }
    },

    -- =========================================================
    -- PittyTheTool  (tools, hardware)
    -- =========================================================

    tools_general = {
        defaults = {
            price = "coin_mid",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"Tool", "ToolWeapon"}
        }
    },

    -- =========================================================
    -- FinalAmmendment  (guns and ammo)
    -- =========================================================

    ammo_all = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"Ammo"}
        }
    },

    weapons_firearms = {
        defaults = {
            price = "coin_high",
            offer = {
                weight = 0.5
            }
        },
        include = {
            categories = {"Weapon"}
        },
        -- Remove melee-only sub-categories to keep firearms focus
        blacklistCategories = {"WeaponCrafted", "WeaponImprovised", "CookingWeapon", "FishingWeapon", "GardeningWeapon",
                               "HouseholdWeapon", "InstrumentWeapon", "JunkWeapon", "MaterialWeapon", "SportsWeapon",
                               "AnimalPartWeapon", "FirstAidWeapon", "VehicleMaintenanceWeapon"}
    },

    weapons_parts = {
        defaults = {
            price = "coin_mid",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"WeaponPart"}
        }
    },

    explosives = {
        defaults = {
            price = "coin_high",
            offer = {
                weight = 0.3
            }
        },
        include = {
            categories = {"Explosives"}
        }
    },

    -- =========================================================
    -- CarAParts  (vehicle maintenance)
    -- =========================================================

    vehicle_parts = {
        defaults = {
            price = "coin_mid",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"VehicleMaintenance", "VehicleMaintenanceWeapon"}
        }
    },

    -- =========================================================
    -- CSVPharmacy  (medical)
    -- =========================================================

    medical_all = {
        defaults = {
            price = "coin_mid",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"FirstAid", "FirstAidWeapon"}
        }
    },

    -- =========================================================
    -- RadioHacks  (electronics, communications)
    -- =========================================================

    electronics_all = {
        defaults = {
            price = "coin_mid",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"Electronics", "Communications"}
        }
    },

    -- =========================================================
    -- Phish4U  (fishing, sports, camping)
    -- =========================================================

    fishing_gear = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"Fishing", "FishingWeapon"}
        }
    },

    sports_gear = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"Sports", "SportsWeapon"}
        }
    },

    camping_gear = {
        defaults = {
            price = "coin_mid",
            offer = {
                weight = 0.5
            }
        },
        include = {
            categories = {"Camping"}
        }
    },

    -- =========================================================
    -- HoesNMoes  (gardening, animals, trapping)
    -- =========================================================

    gardening_all = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"Gardening", "GardeningWeapon"}
        }
    },

    animal_supplies = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 0.8
            }
        },
        include = {
            categories = {"Animal"}
        }
    },

    trapping_gear = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 0.8
            }
        },
        include = {
            categories = {"Trapping"}
        }
    },

    -- =========================================================
    -- HardWear  (clothing)
    -- =========================================================

    clothing_all = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"Clothing", "Appearance"}
        }
    },

    protective_gear = {
        defaults = {
            price = "coin_mid",
            offer = {
                weight = 0.8
            }
        },
        include = {
            categories = {"ProtectiveGear"}
        }
    },

    -- =========================================================
    -- ShedsAndCommoners  (books, literature, recipe magazines)
    -- =========================================================

    skill_books_all = {
        defaults = {
            price = "coin_mid",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"SkillBook", "Literature", "RecipeResource"}
        }
    },

    -- =========================================================
    -- MichellesCrafts  (arts, crafts, paint, hobby materials)
    -- =========================================================

    crafts_paint = {
        defaults = {
            price = "coin_5",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"Paint"}
        }
    },

    crafts_materials = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 0.8
            }
        },
        include = {
            categories = {"Material"}
        }
        -- Note: Material is large (386 items) and includes leathers, fabrics, clay, metals.
        -- Admins may want to blacklist industrial/weapon components for a purer crafts feel.
    },

    crafts_sewing = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 0.8
            }
        },
        include = {
            items = {"Base.Scissors", "Base.NeedleThread", "Base.Needle", "Base.Thread", "Base.SpoolOfThread",
                     "Base.DenimStrips", "Base.LeatherStrips", "Base.SewingPattern"}
        }
    },

    -- =========================================================
    -- WrentAWreck  (vehicles - clean only, no smashed/burnt/trailers)
    -- =========================================================

    -- Budget tier: small cars (gold 5-10)
    vehicles_small = {
        label = "Small Cars",
        fallbackTexture = "Item_ToyCar",
        defaults = {
            price = "vehicle_common",
            reward = "vehicle_smallcar",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = {"SmallCar", "SmallCar02", "CarNormal", "CarTaxi", "CarTaxi2", "CarStationWagon", "CarStationWagon2"}
        }
    },

    -- Budget tier: panel vans, step vans, pickup vans (gold 5-10)
    vehicles_vans = {
        label = "Vans & Pickups",
        fallbackTexture = "Item_CarSeat",
        defaults = {
            price = "vehicle_common",
            reward = "vehicle_van",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = { -- Generic vans
            "Van", "VanSeats", "VanMail", "VanMechanic", "VanBuilder", "VanUtility", "VanRadio", "VanAmbulance",
            "VanSpiffo", -- Branded transit/work vans
            "Van_Transit", "Van_Leather", "Van_CraftSupplies", "Van_VoltMojo", "Van_BugWipers", "Van_Masonry",
            "Van_Glass", "Van_MassGenFac", "Van_LectroMax", "Van_Locksmith", "Van_KnoxDisti", "Van_Perfick_Potato",
            "Van_HeritageTailors", "Van_Blacksmith", -- Branded company vans
            "VanKnoxCom", "VanMooreMechanics", "VanMetalworker", "VanMeltingPointMetal", "VanMetalheads",
            "VanKorshunovs", "VanJonesFabrication", "VanDeerValley", "VanPluggedInElectrics", "VanOldMill",
            "VanPennSHam", "VanMicheles", "VanGreenes", "VanGardenGods", "VanCarpenter", "VanGardener",
            "VanRiversideFabrication", "VanOvoFarm", "VanLouisvilleLandscaping", "VanCoastToCoast",
            "VanSchwabSheetMetal", "VanUncloggers", "VanTreyBaines", "VanPlattAuto", "VanMobileMechanics",
            "VanBrewsterHarbin", "VanBeckmans", "VanMccoy", "VanJohnMcCoy", "VanKnobCreekGas", "VanFossoil",
            "VanKerrHomes", "VanWPCarpentry", "VanRosewoodworking", -- Van seats variants
            "VanSeats_Trippy", "VanSeats_Space", "VanSeats_Mural", "VanSeats_Creature", "VanSeats_LadyDelighter",
            "VanSeats_Valkyrie", "VanSeats_Prison", "VanSeatsAirportShuttle", "VanRadio_3N",
            -- Step vans (large cargo vans)
            "StepVan", "StepVanMail", "StepVanAirportCatering", "StepVan_Citr8", "StepVan_CompleteRepairShop",
            "StepVan_LouisvilleSWAT", "StepVan_LouisvilleMotorShop", "StepVan_SmartKut", "StepVan_HuangsLaundry",
            "StepVan_Blacksmith", "StepVan_Glass", "StepVan_MarineBites", "StepVan_SouthEasternHosp", "StepVan_Propane",
            "StepVan_Zippee", "StepVan_Genuine_Beer", "StepVan_Heralds", "StepVan_SouthEasternPaint",
            "StepVan_MobileLibrary", "StepVan_Jorgensen", "StepVan_Plonkies", "StepVan_Florist", "StepVan_Butchers",
            "StepVan_Mechanic", "StepVan_Masonry", "StepVan_Cereal", "StepVan_RandisPlants", "StepVan_Scarlet",
            "StepVan_USL", -- Pickup vans (light cargo)
            "PickUpVan", "PickUpVanMccoy", "PickUpVanYingsWood", "PickUpVanMarchRidgeConstruction", "PickUpVanBuilder",
            "PickUpVanWeldingbyCamille", "PickUpVanKimbleKonstruction", "PickUpVanMetalworker",
            "PickUpVanHeltonMetalWorking", "PickUpVanBrickingIt", "PickUpVanCallowayLandscaping", "PickUpVan_Camo",
            "PickUpVanLightsRanger", "PickUpVanLightsPolice", "PickUpVanLightsStatePolice", "PickUpVanLightsFire",
            "PickUpVanLightsFossoil", "PickUpVanLightsCarpenter", "PickUpVanLightsLouisvilleCounty",
            "PickUpVanLightsKentuckyLumber"}
        }
    },

    -- Standard tier: modern/mid-range cars (gold 10-20)
    vehicles_normal = {
        label = "Cars & Sedans",
        fallbackTexture = "Item_CarKey", -- the classic
        defaults = {
            price = "vehicle_uncommon",
            reward = "vehicle_normalcar",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = {"ModernCar", "ModernCar02", "ModernCar_Martin", "CarLightsKST", "CarLightsLouisvilleCounty",
                     "CarLightsRanger", "CarLightsPolice", "CarLightsBulletinSheriff", "CarLightsMuldraughPolice",
                     "ModernCarLightsCityLouisvillePD", "ModernCarLightsMeadeSheriff", "ModernCarLightsWestPoint"}
        }
    },

    -- Standard tier: pickup trucks (gold 10-20)
    vehicles_trucks = {
        label = "Pickup Trucks",
        fallbackTexture = "Item_CarTrunk",
        defaults = {
            price = "vehicle_uncommon",
            reward = "vehicle_pickup",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = {"PickUpTruck", "PickUpTruck_Camo", "PickUpTruckMccoy", "PickUpTruckLightsFossoil",
                     "PickUpTruckLightsRanger", "PickUpTruckLightsAirportSecurity", "PickUpTruckLightsAirport",
                     "PickUpTruckJPLandscaping", "PickUpTruckLightsFire"}
        }
    },

    -- Standard tier: off-road / SUV (gold 10-20)
    vehicles_4x4 = {
        label = "Off-Road & SUVs",
        fallbackTexture = "Item_CarTire",
        defaults = {
            price = "vehicle_uncommon",
            reward = "vehicle_offroad",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = {"OffRoad", "SUV"}
        }
    },

    -- =========================================================
    -- Collectors  (items the machine buys from players → bound tokens)
    -- Each entry here becomes one offer slot: bring N of this item, receive tokens.
    -- Add items players commonly loot that have trade value. Keep the list
    -- manageable — too many slots makes the grid feel sparse on restock.
    -- =========================================================

    collectors_scrap = {
        defaults = {
            price = "self_5",
            reward = "token_collector_common",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"Memento"}
        }
    },

    collectors_valuables = {
        defaults = {
            price = "self_1",
            reward = "token_collector_rare",
            offer = {
                weight = 0.6
            }
        },
        include = {
            categories = {"Memento"}
        }
    },

    -- Premium tier: luxury, sports, race cars (gold 20-40)
    vehicles_luxury = {
        label = "Luxury & Sports Cars",
        fallbackTexture = "Item_CarWindshield",
        defaults = {
            price = "vehicle_rare",
            reward = "vehicle_luxury",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = {"CarLuxury", "SportsCar", "SportsCar_ez", "RaceCar12", "RaceCar34", "RaceCar58"}
        }
    }

}
