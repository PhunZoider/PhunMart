return {

    -- =========================================================
    -- GoodPhoods  (health foods, fresh produce, ingredients)
    -- =========================================================

    food_fresh = {
        defaults = {
            price = "coin_low",
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
        "Base.RockCandy", "Base.CandyFruitSlices", "Base.CandyCaramels", "Base.Modjeska", -- Chocolate bars
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
        "Base.DeadRat", "Base.DeadRatBaby", "Base.DeadRatBabySkinned", "Base.DeadRatSkinned", "Base.DeadSquirrel",
        -- Box / bulk-pack food variants
        "Base.TunaTin_Box", "Base.WaterRationCan_Box", "Base.TinnedBeans_Box", "Base.DentedCan_Box",
        "Base.CannedPeas_Box", "Base.CannedCornedBeef_Box", "Base.CannedCarrots_Box", "Base.CannedBolognese_Box",
        "Base.Macandcheese_Box", "Base.CannedMilk_Box", "Base.CannedCorn_Box", "Base.CannedFruitCocktail_Box",
        "Base.CannedMushroomSoup_Box", "Base.CannedPineapple_Box", "Base.CannedFruitBeverage_Box",
        "Base.CannedSardines_Box", "Base.MysteryCan_Box", "Base.CannedChili_Box", "Base.CannedPeaches_Box",
        "Base.TinnedSoup_Box", "Base.CannedTomato_Box", "Base.CannedPotato_Box", -- Produce boxes
        "Base.ProduceBox_ExtraLarge", "Base.ProduceBox_ExtraSmall", "Base.ProduceBox_Large", "Base.ProduceBox_Medium",
        "Base.ProduceBox_Small"}
    },

    food_cooking_utensils = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 0.5
            }
        },
        include = {
            categories = {"Cooking"}
        },
        blacklist = {"Base.BoxOfJars"}
    },

    -- =========================================================
    -- PhatPhoods  (junk food, candy, soda, alcohol)
    -- =========================================================

    food_junk = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = {"Base.Crisps", "Base.Crisps2", "Base.Crisps3", "Base.Crisps4", "Base.TortillaChips",
                     "Base.PorkRinds", "Base.CandyCorn", "Base.CandyGummyfish", "Base.CandyMolasses",
                     "Base.CandyNovapops", "Base.Candycane", "Base.GummyBears", "Base.GummyWorms", "Base.Jujubes",
                     "Base.HardCandies", "Base.LicoriceBlack", "Base.LicoriceRed", "Base.Lollipop", "Base.MintCandy",
                     "Base.Peppermint", "Base.RockCandy", "Base.CandyFruitSlices", "Base.CandyCaramels",
                     "Base.Chocolate_Butterchunkers", "Base.Chocolate_Candy", "Base.Chocolate_Crackle",
                     "Base.Chocolate_Deux", "Base.Chocolate_GalacticDairy", "Base.Chocolate_Smirkers",
                     "Base.Chocolate_SnikSnak", "Base.Chocolate_RoysPBPucks", "Base.Chocolate_HeartBox",
                     "Base.ChocoCakes", "Base.DoughnutChocolate", "Base.DoughnutFrosted", "Base.DoughnutJelly",
                     "Base.DoughnutPlain", "Base.Pop", "Base.Pop2", "Base.Pop3", "Base.PopBottle", "Base.SodaCan",
                     "Base.Hotdog", "Base.Hotdog_single", "Base.Burger", "Base.Pizza", "Base.PizzaWhole",
                     "Base.TVDinner", "Base.Corndog", "Base.FrenchFries", "Base.Fries", "Base.Frozen_FrenchFries",
                     "Base.TatoDots", "Base.Frozen_TatoDots", "Base.Crackers", "Base.GrahamCrackers", "Base.Popcorn",
                     "Base.Popsicle", "Base.Icecream", "Base.IcecreamSandwich", "Base.FudgeePop", "Base.GranolaBar",
                     "Base.CrispyRiceSquare", "Base.QuaggaCakes", "Base.ScoutCookies", "Base.CookieChocolateChip",
                     "Base.CookiesChocolate", "Base.CookiesOatmeal", "Base.CookiesShortbread", "Base.CookiesSugar"}
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
        },
        blacklist = {"Base.Bullets357Box", "Base.ShotgunShellsBox", "Base.Bullets9mmBox", "Base.3030Box",
                     "Base.Bullets44Box", "Base.Bullets38Box", "Base.308Box", "Base.556Box", "Base.Bullets45Box"}
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
    -- CSVPharmacy  (medical — 3 tiers)
    -- cheap:    common wound care      $0.50-$1.50  (coin_xlow)
    -- standard: tools/boxes/pills      $2.50-$6.00  (coin_low)
    -- rare:     prescription drugs     $10-$12      (coin_mid, zone 2+)
    -- =========================================================

    -- Tier 1: widely available wound care items (high spawn weight in PZ loot)
    medical_cheap = {
        defaults = {
            price = "coin_xlow",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = {"Bandage", "Bandaid", "BandageDirty", "AlcoholBandage", "AlcoholRippedSheets", "AlcoholWipes",
                     "AlcoholedCottonBalls", "CottonBalls", "Coldpack", "Disinfectant"}
        }
    },

    -- Tier 2: tools and general pills (medium spawn weight)
    medical_standard = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = {"SutureNeedle", "SutureNeedleHolder", "Tweezers", "Forceps_Forged", "ScissorsBluntMedical",
                     "Splint", "Pills", "PillsVitamins", "Stethoscope"}
        }
    },

    -- Tier 3: prescription/controlled drugs — rare in PZ loot, zone-gated to 2+.
    -- B42 script names: PillsAntiDep / PillsBeta / PillsSleepingTablets (NOT Antidepressants etc.)
    medical_rare = {
        defaults = {
            price = "coin_mid",
            offer = {
                weight = 0.7
            }
        },
        include = {
            items = {"Antibiotics", "PillsAntiDep", "PillsBeta", "PillsSleepingTablets"}
        }
    },

    -- =========================================================
    -- HardWear  (clothing + protective gear — 2 tiers)
    -- clothing:   casual/work clothing         $2.50-$6.00  (coin_low)
    -- protective: helmets/vests/tactical gear  $10-$12      (coin_mid, zone 2+)
    -- =========================================================

    -- Tier 1: all civilian and work clothing (DisplayCategory = Clothing, ~481 items in B42)
    hardwear_clothing = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"Clothing"}
        }
    },

    -- Tier 2: helmets, vests, pads, and tactical equipment (DisplayCategory = ProtectiveGear, ~290 items in B42)
    -- Zone-gated to zones 2+ at the pool level so military/SWAT gear only appears in harder areas.
    hardwear_protective = {
        defaults = {
            price = "coin_mid",
            offer = {
                weight = 1.0
            }
        },
        include = {
            categories = {"ProtectiveGear"}
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
        },
        blacklist = {"Base.BatteryBox", "Base.LightBulbBox"}
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
        },
        blacklist = {"Base.FishingHookBox"}
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

    -- =========================================================
    -- ShedsAndCommoners  (skill books by volume tier + misc literature)
    -- Skill books: 25 skills × 5 volumes (Vol 1=lvl1-2, 2=3-4, 3=5-6, 4=7-8, 5=9-10)
    -- Zone-gated via pool defs: t1 in easy zones, t4 in hard zones.
    -- =========================================================

    skill_books_t1 = {
        defaults = {
            price = "change_50",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = {"BookAiming1", "BookBlacksmith1", "BookButchering1", "BookCarpentry1", "BookCarving1",
                     "BookCooking1", "BookElectrician1", "BookFancy1", "BookFarming1", "BookFirstAid1", "BookFishing1",
                     "BookFlintKnapping1", "BookForaging1", "BookGlassmaking1", "BookHusbandry1", "BookLongBlade1",
                     "BookMaintenance1", "BookMasonry1", "BookMechanic1", "BookMetalWelding1", "BookPottery1",
                     "BookReloading1", "BookTailoring1", "BookTracking1", "BookTrapping1"}
        }
    },

    skill_books_t2 = {
        defaults = {
            price = "change_100",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = {"BookAiming2", "BookBlacksmith2", "BookButchering2", "BookCarpentry2", "BookCarving2",
                     "BookCooking2", "BookElectrician2", "BookFancy2", "BookFarming2", "BookFirstAid2", "BookFishing2",
                     "BookFlintKnapping2", "BookForaging2", "BookGlassmaking2", "BookHusbandry2", "BookLongBlade2",
                     "BookMaintenance2", "BookMasonry2", "BookMechanic2", "BookMetalWelding2", "BookPottery2",
                     "BookReloading2", "BookTailoring2", "BookTracking2", "BookTrapping2"}
        }
    },

    skill_books_t3 = {
        defaults = {
            price = "change_200",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = {"BookAiming3", "BookBlacksmith3", "BookButchering3", "BookCarpentry3", "BookCarving3",
                     "BookCooking3", "BookElectrician3", "BookFancy3", "BookFarming3", "BookFirstAid3", "BookFishing3",
                     "BookFlintKnapping3", "BookForaging3", "BookGlassmaking3", "BookHusbandry3", "BookLongBlade3",
                     "BookMaintenance3", "BookMasonry3", "BookMechanic3", "BookMetalWelding3", "BookPottery3",
                     "BookReloading3", "BookTailoring3", "BookTracking3", "BookTrapping3"}
        }
    },

    skill_books_t4 = {
        defaults = {
            price = "change_500",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = { -- Vol 4 (levels 7-8)
            "BookAiming4", "BookBlacksmith4", "BookButchering4", "BookCarpentry4", "BookCarving4", "BookCooking4",
            "BookElectrician4", "BookFancy4", "BookFarming4", "BookFirstAid4", "BookFishing4", "BookFlintKnapping4",
            "BookForaging4", "BookGlassmaking4", "BookHusbandry4", "BookLongBlade4", "BookMaintenance4", "BookMasonry4",
            "BookMechanic4", "BookMetalWelding4", "BookPottery4", "BookReloading4", "BookTailoring4", "BookTracking4",
            "BookTrapping4", -- Vol 5 (levels 9-10)
            "BookAiming5", "BookBlacksmith5", "BookButchering5", "BookCarpentry5", "BookCarving5", "BookCooking5",
            "BookElectrician5", "BookFancy5", "BookFarming5", "BookFirstAid5", "BookFishing5", "BookFlintKnapping5",
            "BookForaging5", "BookGlassmaking5", "BookHusbandry5", "BookLongBlade5", "BookMaintenance5", "BookMasonry5",
            "BookMechanic5", "BookMetalWelding5", "BookPottery5", "BookReloading5", "BookTailoring5", "BookTracking5",
            "BookTrapping5"}
        }
    },

    skill_books_misc = {
        defaults = {
            price = "change_25",
            offer = {
                weight = 0.7
            }
        },
        include = {
            categories = {"Literature", "RecipeResource"}
        }
    },

    -- =========================================================
    -- MichellesCrafts  (arts, crafts, paint, hobby materials)
    -- =========================================================

    crafts_paint = {
        defaults = {
            price = "coin_low",
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
        },
        -- Note: Material is large (386 items) and includes leathers, fabrics, clay, metals.
        -- Admins may want to blacklist industrial/weapon components for a purer crafts feel.
        blacklist = {"Base.NailsBox", "Base.AdhesiveTapeBox", "Base.PaperclipBox", "Base.DuctTapeBox", "Base.ScrewsBox"}
    },

    crafts_sewing = {
        defaults = {
            price = "coin_low",
            offer = {
                weight = 0.8
            }
        },
        include = {
            items = {"Base.Scissors", "Base.Needle", "Base.Thread", "Base.DenimStrips", "Base.LeatherStrips",
                     "Base.SewingPattern"}
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
    -- Tiered by in-world spawn rarity (from ProceduralDistributions + Distributions).
    -- t1 = junk/curios (1 token), t2 = rare (2 tokens), t3 = legendary (3 tokens)
    -- =========================================================

    -- Tier 1a: Junk — abundant toys/games (weight >100). Bring 3 → 1 token.
    collectors_junk = {
        defaults = {
            price = "self_3",
            reward = "token_collector_t1",
            offer = {
                weight = 1.0
            }
        },
        include = {
            items = {"Dice_00", "Dice_4", "Dice_6", "Dice_8", "Dice_10", "Dice_12", "Dice_20", "ToyCar", "ToyPlane",
                     "Doll", "Yoyo", "Bricktoys", "Cube", "Revolver_CapGun", "Rifle_CapGun", "CapGunCap", "CapGunCapBox"}
        }
    },

    -- Tier 1b: Curios — common collectibles and antiques (weight 5-100). Bring 2 → 1 token.
    collectors_curios = {
        defaults = {
            price = "self_2",
            reward = "token_collector_t1",
            offer = {
                weight = 0.8
            }
        },
        include = {
            items = { -- Gemstones (thematically valuable despite common spawn)
            "Ruby", "Sapphire", "Emerald", "Diamond", -- Vessels and antiques
            "Goblet", "Goblet_Wood", "Locket", "Pocketwatch", "Crystal_Large", -- Trophies and medals
            "TrophyBronze", "TrophySilver", "TrophyGold", "Medal_Bronze", "Medal_Silver", "Medal_Gold", -- Curiosities
            "SnowGlobe", "TarotCardDeck", "OujaBoard", "MilitaryMedal", "SuspiciousPackage", "Katana_Handle",
            -- Specimen jars
            "Specimen_Minerals", "Specimen_Brain", "Specimen_Tapeworm", "Specimen_MonkeyHead", "Specimen_FetalPiglet",
            "Specimen_FetalLamb", "Specimen_FetalCalf", "Specimen_Octopus", -- Skulls
            "Hominid_Skull", "Hominid_Skull_Partial", "Hominid_Skull_Fragment"}
        }
    },

    -- Tier 2: Rare — scarce items (weight <5, naturally spawnable). Bring 1 → 2 tokens.
    collectors_rare = {
        defaults = {
            price = "self_1",
            reward = "token_collector_t2",
            offer = {
                weight = 0.5
            }
        },
        include = {
            items = { -- Fine vessels
            "Crystal", "Goblet_Silver", "Goblet_Gold", -- Character portraits (weight ~0.23 each)
            "BobPic", "CaseyPic", "ChrisPic", "HankPic", "JamesPic", "KatePic", "MariannePic", "CortmanPic",
            -- Rare wearables
            "Hat_ArmyWWII", "Hat_Stovepipe_UncleSam", "Glasses_MonocleLeft", "Glasses_Cosmetic_MonocleLeft",
            -- Novelties
            "Necklace_Teeth", "KeyRing_Spiffos", "Lunchbox2", -- Halloween masks (weight ~2.4 each, seasonal)
            "Hat_HalloweenMaskWitch", "Hat_HalloweenMaskVampire", "Hat_HalloweenMaskSkeleton",
            "Hat_HalloweenMaskPumpkin", "Hat_HalloweenMaskMonster", "Hat_HalloweenMaskDevil", "Hat_Witch"}
        }
    },

    -- Tier 3: Legendary — near-zero or zero spawn weight; event/admin drops. Bring 1 → 3 tokens.
    collectors_legendary = {
        defaults = {
            price = "self_1",
            reward = "token_collector_t3",
            offer = {
                weight = 0.2
            }
        },
        include = {
            items = { -- Band merchandise (weight ~0.03)
            "Jacket_LeatherWildRacoons", "Jacket_LeatherIronRodent", "Jacket_LeatherBarrelDogs",
            "Vest_Leather_WildRaccoons", "Vest_Leather_IronRodents", "Vest_Leather_BarrelDogs", "Vest_Leather_Biker",
            "Vest_Leather_Veteran", -- Ultra-rare event / loot (weight <0.01 or not in tables)
            "HalloweenCandyBucket", "KeyRing_StinkyFace", "Amethyst", "SilverCoin", "GoldCoin", "RatKing",
            "LargeMeteorite", -- Spiffo collectibles (zero spawn — admin/event only)
            "SpiffoSuit", "Hat_Spiffo", "Hat_Jay", "Hat_GoldStar", "HobbyHorse", "Hat_Cowboy_Plastic",
            "Hat_BaseballCap_Spiffos", "Hat_BaseballCap_Spiffos_Reverse", "Hat_BaseballCap_SpiffosLogo",
            "Hat_BaseballCap_SpiffosLogo_Reverse", -- Racing keyrings (zero spawn — admin/event only)
            "KeyRing_Racing12", "KeyRing_Racing34", "KeyRing_Racing58", -- Dog tags (zero spawn variants)
            "Necklace_DogTag_Male", "Necklace_DogTag_Female"}
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
