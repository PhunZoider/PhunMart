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
            base = 3,
            min = 3,
            max = 5
        }
    }
}, {
    abstract = true,
    key = "base-fish-tackle",
    inherits = "base-fish",
    tab = "Tackle",
    tags = "fish,tackle",
    price = {
        currency = 3
    }
}, {
    abstract = true,
    key = "base-fish-bait",
    inherits = "base-fish",
    tab = "Bait",
    tags = "fish,bait",
    price = {
        currency = 2
    }
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
    name = "Base.Bass",
    inherits = "base-fish"
}, {
    name = "Base.Crayfish",
    inherits = "base-fish"
}, {
    name = "Base.Crappie",
    inherits = "base-fish"
}, {
    name = "Base.Perch",
    inherits = "base-fish"
}, {
    name = "Base.FishingLine",
    inherits = "base-fish-tackle"
}, {
    name = "Base.FishingRodBreak",
    inherits = "base-fish-tackle",
    enabled = false
}, {
    name = "Base.Maggots",
    inherits = "base-fish-bait"
}, {
    name = "Base.Maggots2",
    inherits = "base-fish-bait"
}, {
    name = "Base.BaitFish",
    inherits = "base-fish-tackle"
}, {
    name = "Base.CraftedFishingRod",
    inherits = "base-fish-tackle"
}, {
    name = "Base.Worm",
    inherits = "base-fish-bait"
}, {
    name = "Base.FishingNet",
    inherits = "base-fish-tackle"
}, {
    name = "Base.FishingRod",
    inherits = "base-fish-tackle"
}, {
    name = "Base.BrokenFishingNet",
    inherits = "base-fish-tackle",
    enabled = false
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
}, {
    name = "Base.dasBootFull",
    inherits = "base-food",
    mod = "63Type2Van"
}, {
    name = "CanteensAndBottles.GymBottleSpiffoade",
    inherits = "base-food",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.FlaskBourbon",
    inherits = "base-food",
    mod = "CanteensAndBottles"
}, {
    name = "EHE.MealReadytoEatEHE",
    inherits = "base-food",
    mod = "ExpandedHelicopterEvents"
}, {
    name = "SapphCooking.CrabStick",
    inherits = "base-food",
    mod = "sapphcooking"
}, {
    name = "FunctionalAppliances.FASwillerKeg",
    inherits = "base-food",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABubLiteKeg",
    inherits = "base-food",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABubKeg",
    inherits = "base-food",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FASwillerLiteKeg",
    inherits = "base-food",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHomeBrewKeg",
    inherits = "base-food",
    mod = "FunctionalAppliances"
}, {
    name = "MonmouthFoods.ZombieBombs",
    inherits = "base-food",
    mod = "MonmouthCounty_new"
}, {
    name = "MonmouthFoods.IrnBru",
    inherits = "base-food",
    mod = "MonmouthCounty_new"
}, {
    name = "MonmouthFoods.MoobysSeltzerTropical",
    inherits = "base-food",
    mod = "MonmouthCounty_new"
}, {
    name = "SapphCooking.MozzarelaSticks",
    inherits = "base-food",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Macaron_Green",
    inherits = "base-food",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Truffle",
    inherits = "base-food",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.HomemadeSauce_Evolved",
    inherits = "base-food",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Macaron_Blue",
    inherits = "base-food",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Macaron_Purple",
    inherits = "base-food",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Macaron_Red",
    inherits = "base-food",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Macaron_Yellow",
    inherits = "base-food",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Macaron_Pink",
    inherits = "base-food",
    mod = "sapphcooking"
}, {
    name = "FunctionalAppliances.FASwillerLiteBeerBottle",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupSwillerLiteBeer",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABubLiteBeerBottle",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHomeBrewBeerBottle",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugStout",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugBubLiteBeer",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPopBottleRootBeer",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugLightLager",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupBubLiteBeer",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupBeer",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupSwillerBeer",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugPilsner",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugHomeBrewBeer",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugSkunked",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FASwillerBeerBottle",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAFountainCupRootBeerSoda",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupHomeBrewBeer",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABubBeerBottle",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugSwillerLiteBeer",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FARootBeerSodaSyrupBox",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugSwillerBeer",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugPorter",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugWater",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugBeer",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupBubBeer",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugAPA2",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugAPA1",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMug",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugIPA1",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugIPA2",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugBubBeer",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABeerMugAmericanLager",
    inherits = "base-food-foodalcohol",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAFriedDoughboy",
    inherits = "base-food-foodbaking",
    mod = "FunctionalAppliances"
}, {
    name = "SapphCooking.CakeRaw_Carrot",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeRaw_BlackForestCake",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "FunctionalAppliances.FAPotatoWedges",
    inherits = "base-food-foodbaking",
    mod = "FunctionalAppliances"
}, {
    name = "SapphCooking.CakeRaw_RedVelvet",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "FunctionalAppliances.FAPotatoSkins",
    inherits = "base-food-foodbaking",
    mod = "FunctionalAppliances"
}, {
    name = "SapphCooking.CakeRaw_Birthday",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "FunctionalAppliances.FAOrangeSodaSyrupBox",
    inherits = "base-food-foodcondiment",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAMixedBerriesSodaSyrupBox",
    inherits = "base-food-foodcondiment",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAColaSodaSyrupBox",
    inherits = "base-food-foodcondiment",
    mod = "FunctionalAppliances"
}, {
    name = "SapphCooking.Stuffed_BellPepper",
    inherits = "base-food-foodcondiment",
    mod = "sapphcooking"
}, {
    name = "FunctionalAppliances.FAFriedCheeseSticks",
    inherits = "base-food-fooddairy",
    mod = "FunctionalAppliances"
}, {
    name = "SapphCooking.Pot_CheesePreparation",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Wooden_CheeseMolds",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "FunctionalAppliances.FABatteredCheese",
    inherits = "base-food-fooddairy",
    mod = "FunctionalAppliances"
}, {
    name = "SapphCooking.Pot_Cheese",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Wooden_CheeseMolds_Water",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Wooden_CheeseMoldsCurds",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Wooden_CheeseMoldsBlue",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Parmesan_CheeseWheel",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Wooden_CheeseMoldsFull",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Bucket_CheeseBlue",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Blue_CheeseWheel",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Bucket_Cheese",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Pot_CheeseBlue",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Pot_CheeseCurds",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BlueCheese",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Bucket_CheeseCurds",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "WaterDispenser.WaterJugWaterFull",
    inherits = "base-food-fooddrink",
    mod = "WaterDispenser"
}, {
    name = "BZMClothing.Pop3",
    inherits = "base-food-fooddrink",
    mod = "MonmouthCounty_new"
}, {
    name = "FunctionalAppliances.FAPopBottleLemonLime",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "BZMClothing.Pop2",
    inherits = "base-food-fooddrink",
    mod = "MonmouthCounty_new"
}, {
    name = "FunctionalAppliances.FAHotDrinkCoffeeRed",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "BZMClothing.Pop",
    inherits = "base-food-fooddrink",
    mod = "MonmouthCounty_new"
}, {
    name = "FunctionalAppliances.FAHotDrinkCappuccinoTeacup",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkEspressoRed",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkEspressoMugl",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkCappuccinoMugl",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkLatteMugl",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPopBottleCola",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkCappuccinoRed",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkEspressoTeacup",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkEspressoSpiffo",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkLatteWhite",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "BZMClothing.PopBottle",
    inherits = "base-food-fooddrink",
    mod = "MonmouthCounty_new"
}, {
    name = "CanteensAndBottles.GymBottleBlueYellowWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.MedicinalCanteenGreenWhiteWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.MedicinalCanteenRedWhiteWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "FunctionalAppliances.FAHotDrinkLatteTeacup",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkCappuccinoSpiffo",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAFountainCupCarbonatedWater",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "CanteensAndBottles.SmallWaterskinWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "FunctionalAppliances.FAHotDrinkLatteRed",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkTeaWhite",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkTeaRed",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkCappuccinoWhite",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPopBottleCarbonatedWater",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkEspressoWhite",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAFountainCupWater",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "CanteensAndBottles.GymBottleOrangeCharcoalWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.CampingCanteenTartanWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.CampingCanteenReadyPrepWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.FlaskWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "FunctionalAppliances.FAHotDrinkCoffeeWhite",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkCoffeeSpiffo",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAHotDrinkCoffeeMugl",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FATheaterPopcorn",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "CanteensAndBottles.FlaskSpiffoWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.CampingCanteenArmyWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.MedicinalCanteenWhiteRedWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "FunctionalAppliances.FAFountainCupColaSoda",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "CanteensAndBottles.GiantWaterBottleWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "FunctionalAppliances.FAHotDrinkLatteSpiffo",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "CanteensAndBottles.FlaskSpiffoJuice",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.MedicinalCanteenWhiteGreenWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "FunctionalAppliances.FAButteredPopcorn",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "CanteensAndBottles.GymBottleSpiffoWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "FunctionalAppliances.FAHotDrinkTeaMugl",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "CanteensAndBottles.CanteenArmyGreenWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "FunctionalAppliances.FAHotDrinkTeaSpiffo",
    inherits = "base-food-fooddrink",
    mod = "FunctionalAppliances"
}, {
    name = "CanteensAndBottles.CanteenOliveDrabWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.LargeWaterskinWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.GymBottlePurpleGreyWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "CanteensAndBottles.QualityWaterskinWater",
    inherits = "base-food-fooddrink",
    mod = "CanteensAndBottles"
}, {
    name = "FunctionalAppliances.FABloomingOnion",
    inherits = "base-food-foodfruit",
    mod = "FunctionalAppliances"
}, {
    name = "MonmouthFoods.MoobysSeltzerLemon",
    inherits = "base-food-foodfruit",
    mod = "MonmouthCounty_new"
}, {
    name = "FunctionalAppliances.FAFountainCupOrangeSoda",
    inherits = "base-food-foodfruit",
    mod = "FunctionalAppliances"
}, {
    name = "MonmouthFoods.MoobysSeltzerPineberry",
    inherits = "base-food-foodfruit",
    mod = "MonmouthCounty_new"
}, {
    name = "FunctionalAppliances.FAFountainCupLemonLimeSoda",
    inherits = "base-food-foodfruit",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABatteredBloomingOnion",
    inherits = "base-food-foodfruit",
    mod = "FunctionalAppliances"
}, {
    name = "SapphCooking.CakeRaw_Strawberry",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "FunctionalAppliances.FAPopBottleBerry",
    inherits = "base-food-foodfruit",
    mod = "FunctionalAppliances"
}, {
    name = "SapphCooking.CakePrep_StrawberryCake",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "FunctionalAppliances.FAFriedBloomingOnion",
    inherits = "base-food-foodfruit",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FALemonLimeSodaSyrupBox",
    inherits = "base-food-foodfruit",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAFountainCupBerrySoda",
    inherits = "base-food-foodfruit",
    mod = "FunctionalAppliances"
}, {
    name = "MonmouthFoods.MoobysSeltzerViolet",
    inherits = "base-food-foodfruit",
    mod = "MonmouthCounty_new"
}, {
    name = "SapphCooking.LettuceWrap",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.LettuceWrap_Evolved",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeStrawberry_Candle",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeSlice_Strawberry",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakePrep_Chocolate",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeRaw_Chocolate",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeSlice_Chocolate",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Eclair_Evolved",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Macaron_Cookies_Yellow",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Eclair_WhiteChocolate_Evolved",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Macaron_Cookies_Red",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeChocolate_Candle",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Macaron_Cookies_Purple",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PackofCandyCigarretes",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Macaron_Cookies_Pink",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Eclair_Chocolate_Evolved",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Macaron_Cookies_Green",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Macaron_Cookies_Blue",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "FunctionalAppliances.FAFriedChickenTenders",
    inherits = "base-food-foodmeat",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABatteredChicken",
    inherits = "base-food-foodmeat",
    mod = "FunctionalAppliances"
}, {
    name = "MonmouthFoods.SteakBake",
    inherits = "base-food-foodmeat",
    mod = "MonmouthCounty_new"
}, {
    name = "FunctionalAppliances.FAFriedChickenFillet",
    inherits = "base-food-foodmeat",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FABatteredChickenFillet",
    inherits = "base-food-foodmeat",
    mod = "FunctionalAppliances"
}, {
    name = "SOMW.MeatTenderizer",
    inherits = "base-food-foodmeat",
    mod = "SimpleOverhaulMeleeWeapons"
}, {
    name = "FunctionalAppliances.FAChickenFillet",
    inherits = "base-food-foodmeat",
    mod = "FunctionalAppliances"
}, {
    name = "SpoonEssentialCrafting.SpoonDeadBody",
    inherits = "base-food-foodmeat",
    mod = "EssentialCrafting"
}, {
    name = "SapphCooking.CakePrep_Carrot",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeSlice_RedVelvet",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakePrep_RedVelvet",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Cake_Candle",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeSlice_Carrot",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakePrep_BlackForestCake",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeSlice_BlackForest",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeSlice_Birthday",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeBlackForest_Candle",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeRedVelvet_Candle",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeCarrot_Candle",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeBirthday_Candle",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Wokpan_BaconandEggs",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "FunctionalAppliances.FAHotdog",
    inherits = "base-food-foodready",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAFriedPotatoSkins",
    inherits = "base-food-foodready",
    mod = "FunctionalAppliances"
}, {
    name = "SpoonEssentialCrafting.SpoonMassGraveFull",
    inherits = "base-food-foodutensil",
    mod = "EssentialCrafting"
}, {
    name = "FunctionalAppliances.FAPlasticCupAPA2",
    inherits = "base-food-foodutensil",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupPilsner",
    inherits = "base-food-foodutensil",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupAPA1",
    inherits = "base-food-foodutensil",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupStout",
    inherits = "base-food-foodutensil",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupAmericanLager",
    inherits = "base-food-foodutensil",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupSkunked",
    inherits = "base-food-foodutensil",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupIPA1",
    inherits = "base-food-foodutensil",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupWater",
    inherits = "base-food-foodutensil",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupPorter",
    inherits = "base-food-foodutensil",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupLightLager",
    inherits = "base-food-foodutensil",
    mod = "FunctionalAppliances"
}, {
    name = "FunctionalAppliances.FAPlasticCupIPA2",
    inherits = "base-food-foodutensil",
    mod = "FunctionalAppliances"
}, {
    name = "SpoonEssentialCrafting.SpoonMassGraveEmpty",
    inherits = "base-food-foodutensil",
    mod = "EssentialCrafting"
}}
