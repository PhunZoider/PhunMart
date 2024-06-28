return {{
    abstract = true,
    key = "base-food",
    tab = "Food",
    tags = "food",
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
    key = "base-food-foodbaking",
    inherits = "base-food",
    tab = "Baking",
    tags = "food,foodbaking"
}, {
    abstract = true,
    key = "base-food-foodready",
    inherits = "base-food",
    tab = "Ready to Eat",
    tags = "food,foodready"
}, {
    abstract = true,
    key = "base-food-foodsnack",
    inherits = "base-food",
    tab = "Snack",
    tags = "food,foodsnack"
}, {
    abstract = true,
    key = "base-food-foodutensil",
    inherits = "base-food",
    tab = "Utensils",
    tags = "food,foodutensil"
}, {
    abstract = true,
    key = "base-food-foodalcohol",
    inherits = "base-food",
    tab = "Alcohol",
    tags = "food,foodalcohol"
}, {
    abstract = true,
    key = "base-food-foodjunk",
    inherits = "base-food",
    tab = "Junk Food",
    tags = "food,foodjunk"
}, {
    abstract = true,
    key = "base-food-foodcondiment",
    inherits = "base-food",
    tab = "Condiment",
    tags = "food,foodcondiment"
}, {
    abstract = true,
    key = "base-food-fooddrink",
    inherits = "base-food",
    tab = "Drink",
    tags = "food,fooddrink"
}, {
    abstract = true,
    key = "base-food-foodfruit",
    inherits = "base-food",
    tab = "Fruit and Veg",
    tags = "food,foodfruit"
}, {
    abstract = true,
    key = "base-food-foodmeat",
    inherits = "base-food",
    tab = "Meat",
    tags = "food,foodmeat"
}, {
    abstract = true,
    key = "base-food-foodseafood",
    inherits = "base-food",
    tab = "Seafood",
    tags = "food,foodseafood"
}, {
    abstract = true,
    key = "base-food-fooddairy",
    inherits = "base-food",
    tab = "Dairy",
    tags = "food,fooddairy"
}, {
    abstract = true,
    key = "base-food-foodcanned",
    inherits = "base-food",
    tab = "Canned",
    tags = "food,foodcanned"
}, {
    abstract = true,
    key = "base-food-jfoodunkfood",
    inherits = "base-food",
    tags = "food,jfoodunkfood"
}, {
    abstract = true,
    key = "base-food-foodbulk",
    inherits = "base-food",
    tab = "Bulk",
    tags = "food,foodbulk"
}, {
    abstract = true,
    key = "base-food-foodinsect",
    inherits = "base-food",
    tags = "food,foodinsect"
}, {
    abstract = true,
    key = "base-food-foodpie",
    inherits = "base-food",
    tab = "Pie and Cake",
    tags = "food,foodpie"
}, {
    abstract = true,
    key = "base-food-foodpasta",
    inherits = "base-food",
    tab = "Pasta",
    tags = "food,foodpasta"
}, {
    name = "Base.BeanBowl",
    inherits = "base-food"
}, {
    name = "Base.Peach",
    inherits = "base-food"
}, {
    name = "Base.WhiskeyFull",
    inherits = "base-food-foodalcohol"
}, {
    name = "Base.Wine",
    inherits = "base-food-foodalcohol"
}, {
    name = "Base.Wine2",
    inherits = "base-food-foodalcohol"
}, {
    name = "Base.BeerCan",
    inherits = "base-food-foodalcohol"
}, {
    name = "Base.Beer",
    inherits = "base-food-foodalcohol"
}, {
    name = "Base.BeerBottle",
    inherits = "base-food-foodalcohol"
}, {
    name = "Base.GlassWineWater",
    inherits = "base-food-foodalcohol"
}, {
    name = "SapphCooking.CachacaFull",
    inherits = "base-food-foodalcohol",
    mod = "sapphcooking"
}, {
    name = "Base.GingerPickled",
    inherits = "base-food-foodalcohol"
}, {
    name = "SapphCooking.Churn_Wine",
    inherits = "base-food-foodalcohol",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.TequilaFull",
    inherits = "base-food-foodalcohol",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.GinFull",
    inherits = "base-food-foodalcohol",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.LiqueurBottle",
    inherits = "base-food-foodalcohol",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CocktailGlass",
    inherits = "base-food-foodalcohol",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Vermouth",
    inherits = "base-food-foodalcohol",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.VodkaFull",
    inherits = "base-food-foodalcohol",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SakeFull",
    inherits = "base-food-foodalcohol",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.RumFull",
    inherits = "base-food-foodalcohol",
    mod = "sapphcooking"
}, {
    name = "Base.Beer2",
    inherits = "base-food-foodalcohol"
}, {
    name = "SapphCooking.SausageinBatter",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "Base.CakeRaw",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.DriedChickpeas",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.DriedKidneyBeans",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.DoughRolled",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Lard",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.MuffinTray",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.RicePaper",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.CocoaPowder",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.CookieChocolateChipDough",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.DriedSplitPeas",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.GingerRoot",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Basil",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.DoughnutPlain",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.TacoShell",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Flour",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.DriedBlackBeans",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.BaguetteDough",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Icing",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Margarine",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.CookiesShortbreadDough",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.PieDough",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Chives",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.DoughnutFrosted",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Cilantro",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Sugar",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.CookiesOatmealDough",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Pot",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.BreadDough",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Cornbread",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.CookiesSugar",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Oregano",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.DoughnutChocolate",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Yeast",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Bread",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.PotOfStew",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Parsley",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Tortilla",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.PotOfSoup",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Vinegar",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Seaweed",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.OilVegetable",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.DriedLentils",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.BreadSlices",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Rice",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.BouillonCube",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.WaterPotRice",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.BakingTrayBread",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.LemonGrass",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.CookiesChocolateDough",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Thistle",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.BakingSoda",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.DriedWhiteBeans",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Rosemary",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.BakingTray",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.RiceBowl",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Muffintray_Biscuit",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.CookiesSugarDough",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.Baguette",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.RiceVinegar",
    inherits = "base-food-foodbaking"
}, {
    name = "farming.Potato",
    inherits = "base-food-foodbaking"
}, {
    name = "SapphCooking.BowlofMashedPotatoes",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithQueso",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ArborioRiceBowl",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CanolaOil",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CutPeeledPotato",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PeanutOil",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Gingerbread_Man",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithSpaguettiandMeatballs",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BakedPotato_Evolved",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MonosodiumGlutamate_MSG",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ArborioRice",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.FilledMeatPastaDough",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Banana_Bread",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Flatbread",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_PorkwRiceUn",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithMeltedWhiteChocolate",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.FryBatter",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithSpaguetti",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WaterSaucepanwithPotatoes",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BeefBroth",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Gingerbread_House",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithSugarKernels",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.VegetableBroth",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.DoughnutCutter",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MessTray",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithBeefStew",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "Base.Sage",
    inherits = "base-food-foodbaking"
}, {
    name = "SapphCooking.Blender_Prep_Puree",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithJapaneseCurry",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SausageCasing",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithBrownRice",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.FlatbreadEvolved",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "Base.RicePot",
    inherits = "base-food-foodbaking"
}, {
    name = "SapphCooking.BreadCrumbs",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "Base.DoughnutJelly",
    inherits = "base-food-foodbaking"
}, {
    name = "SapphCooking.RiceBeanBowl",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithMashedPotatoes",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithKernelCorn",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithOil",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BakedPotato",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BowlShavedIce",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SmallDough",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BowlShavedIceEvolved",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Gingerbread_Wall",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.FlatbreadDough",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithBorschtPrep",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "Base.Thyme",
    inherits = "base-food-foodbaking"
}, {
    name = "SapphCooking.CroissaintDough",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BrownRice",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "Base.Dough",
    inherits = "base-food-foodbaking"
}, {
    name = "SapphCooking.SaucepanwithRavioli",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithStock",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WontonWrappers",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BowlofOmurice",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithArborioRice",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BananaBread_Dough",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithCheese",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithMeltedChocolate",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WildGarlicBreadUn",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WildGarlicBreadPiece",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Gingerbread_Dough",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithNoodleSoup",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PastaDough",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WontonWrappersDough",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PotofVegetableStock",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SlicedBanana_Bread",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithTortellini",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "Base.BakingTray_Muffin",
    inherits = "base-food-foodbaking"
}, {
    name = "SapphCooking.SaucepanwithRisotto",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PeeledPotato",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_PorkwRice",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Gingerbread_Pieces",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Blender_Puree",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BrownRiceBowl",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "Base.Sausage",
    inherits = "base-food-foodbaking"
}, {
    name = "SapphCooking.RolledPastaDough",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "Base.OatsRaw",
    inherits = "base-food-foodbaking"
}, {
    name = "SapphCooking.SaucepanwithChickenStroganoff",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithBorscht",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "Base.Cornflour",
    inherits = "base-food-foodbaking"
}, {
    name = "SapphCooking.BreadSlices_Curry",
    inherits = "base-food-foodbaking",
    mod = "sapphcooking"
}, {
    name = "Base.SugarBrown",
    inherits = "base-food-foodbaking"
}, {
    name = "Base.SackProduce_Strawberry",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Lettuce",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Eggplant",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Cabbage",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.BoxOfJars",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Carrot",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Peach",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Grapes",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Pear",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Tomato",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Cherry",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_RedRadish",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Corn",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Potato",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_BellPepper",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Leek",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Apple",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.SackProduce_Broccoli",
    inherits = "base-food-foodbulk"
}, {
    name = "Base.CannedPineapple",
    inherits = "base-food-foodcanned"
}, {
    name = "SapphCooking.FishFilletinBatter",
    inherits = "base-food-foodcanned",
    mod = "sapphcooking"
}, {
    name = "Base.CannedPeasOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedSardines",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedPeachesOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedPineappleOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedSardinesOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.TinnedBeans",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedFruitCocktailOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedCabbage",
    inherits = "base-food-foodcanned"
}, {
    name = "SapphCooking.CanofBeets",
    inherits = "base-food-foodcanned",
    mod = "sapphcooking"
}, {
    name = "Base.CannedFruitCocktail",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedTomatoOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedTomato",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedChiliOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.Marinara",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedPotatoOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.Dogfood",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedCarrots",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedBologneseOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "SapphCooking.PoutineBowl",
    inherits = "base-food-foodcanned",
    mod = "sapphcooking"
}, {
    name = "Base.CannedCarrotsOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedFruitBeverage",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedCornedBeef",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.TunaTinOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedBroccoli",
    inherits = "base-food-foodcanned"
}, {
    name = "SapphCooking.CannedSausages",
    inherits = "base-food-foodcanned",
    mod = "sapphcooking"
}, {
    name = "Base.CannedPotato2",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedLeek",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedBolognese",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedEggplant",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedPotato",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedCorn",
    inherits = "base-food-foodcanned"
}, {
    name = "SapphCooking.CannedBacon",
    inherits = "base-food-foodcanned",
    mod = "sapphcooking"
}, {
    name = "Base.CannedMushroomSoup",
    inherits = "base-food-foodcanned"
}, {
    name = "SapphCooking.CannedBread",
    inherits = "base-food-foodcanned",
    mod = "sapphcooking"
}, {
    name = "Base.CannedCornedBeefOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedRedRadish",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.DogfoodOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedFruitBeverageOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedChili",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.TinnedSoup",
    inherits = "base-food-foodcanned"
}, {
    name = "SapphCooking.CannedEggs",
    inherits = "base-food-foodcanned",
    mod = "sapphcooking"
}, {
    name = "Base.CannedPeas",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.TunaTin",
    inherits = "base-food-foodcanned"
}, {
    name = "SapphCooking.OpenCanofBeets",
    inherits = "base-food-foodcanned",
    mod = "sapphcooking"
}, {
    name = "Base.CannedTomato2",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedCornOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedBellPepper",
    inherits = "base-food-foodcanned"
}, {
    name = "Base.CannedPeaches",
    inherits = "base-food-foodcanned"
}, {
    name = "SapphCooking.TinofCaviar",
    inherits = "base-food-foodcanned",
    mod = "sapphcooking"
}, {
    name = "Base.CannedMushroomSoupOpen",
    inherits = "base-food-foodcanned"
}, {
    name = "SapphCooking.CanofProteinPowder",
    inherits = "base-food-foodcanned",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PoutineBowlEvolved",
    inherits = "base-food-foodcanned",
    mod = "sapphcooking"
}, {
    name = "Base.CannedCarrots2",
    inherits = "base-food-foodcanned"
}, {
    name = "SapphCooking.HomemadeKetchup",
    inherits = "base-food-foodcondiment",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Mustard_Sachet",
    inherits = "base-food-foodcondiment",
    mod = "sapphcooking"
}, {
    name = "Base.GravyMix",
    inherits = "base-food-foodcondiment"
}, {
    name = "SapphCooking.SlicedBellPepper",
    inherits = "base-food-foodcondiment",
    mod = "sapphcooking"
}, {
    name = "Base.BellPepper",
    inherits = "base-food-foodcondiment"
}, {
    name = "Base.Ketchup",
    inherits = "base-food-foodcondiment"
}, {
    name = "Base.PepperHabanero",
    inherits = "base-food-foodcondiment"
}, {
    name = "Base.OilOlive",
    inherits = "base-food-foodcondiment"
}, {
    name = "Base.SugarPacket",
    inherits = "base-food-foodcondiment"
}, {
    name = "SapphCooking.SoySauce_Sachet",
    inherits = "base-food-foodcondiment",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Bowl_Marinade",
    inherits = "base-food-foodcondiment",
    mod = "sapphcooking"
}, {
    name = "Base.Soysauce",
    inherits = "base-food-foodcondiment"
}, {
    name = "Base.PepperJalapeno",
    inherits = "base-food-foodcondiment"
}, {
    name = "Base.Salt",
    inherits = "base-food-foodcondiment"
}, {
    name = "Base.Wasabi",
    inherits = "base-food-foodcondiment"
}, {
    name = "Base.Honey",
    inherits = "base-food-foodcondiment"
}, {
    name = "Base.Mustard",
    inherits = "base-food-foodcondiment"
}, {
    name = "Base.MapleSyrup",
    inherits = "base-food-foodcondiment"
}, {
    name = "Base.Gravy",
    inherits = "base-food-foodcondiment"
}, {
    name = "SapphCooking.MRE_SausageswGravyUn",
    inherits = "base-food-foodcondiment",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Syrup_Caramel",
    inherits = "base-food-foodcondiment",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaltPacket",
    inherits = "base-food-foodcondiment",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.NoodleSachet_Beef",
    inherits = "base-food-foodcondiment",
    mod = "sapphcooking"
}, {
    name = "Base.Hotsauce",
    inherits = "base-food-foodcondiment"
}, {
    name = "farming.MayonnaiseFull",
    inherits = "base-food-foodcondiment"
}, {
    name = "farming.RemouladeFull",
    inherits = "base-food-foodcondiment"
}, {
    name = "farming.MayonnaiseHalf",
    inherits = "base-food-foodcondiment"
}, {
    name = "farming.RemouladeHalf",
    inherits = "base-food-foodcondiment"
}, {
    name = "farming.BaconBits",
    inherits = "base-food-foodcondiment"
}, {
    name = "Base.Pepper",
    inherits = "base-food-foodcondiment"
}, {
    name = "SapphCooking.DicedBellPepper",
    inherits = "base-food-foodcondiment",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_SausageswGravy",
    inherits = "base-food-foodcondiment",
    mod = "sapphcooking"
}, {
    name = "Base.EggScrambled",
    inherits = "base-food-fooddairy"
}, {
    name = "SapphCooking.SapphCutGrilledCheese",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.CannedMilk",
    inherits = "base-food-fooddairy"
}, {
    name = "SapphCooking.Blender_Milkshake",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.EggOmelette",
    inherits = "base-food-fooddairy"
}, {
    name = "SapphCooking.MRE_CheeseTortelliniUn",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Cured_EggYolk",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Mug_Milkshake",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.CheeseSandwich",
    inherits = "base-food-fooddairy"
}, {
    name = "Base.Milk",
    inherits = "base-food-fooddairy"
}, {
    name = "SapphCooking.PowderedEggs",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.WildEggs",
    inherits = "base-food-fooddairy"
}, {
    name = "SapphCooking.BrownEgg",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PopbottlewithMilk",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ColaBottlewithMilk",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BowlwithBeatenEggs",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MugSpiffo_Milkshake",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ButtermilkBottle",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ParmesanCheese",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.Butter",
    inherits = "base-food-fooddairy"
}, {
    name = "SapphCooking.ScotchEggRaw",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_CheeseTortellini",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Churn_Buttermilk",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SlicedEggplant",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BottlewithMilk",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.EggPoached",
    inherits = "base-food-fooddairy"
}, {
    name = "SapphCooking.BrownEggCarton",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.SushiEgg",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.Maki",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.Salmon",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.MozzarelaCheese",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.EggCarton",
    inherits = "base-food-fooddairy"
}, {
    name = "SapphCooking.EggYolk",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.Eggplant",
    inherits = "base-food-fooddairy"
}, {
    name = "SapphCooking.BeverageMilkshake",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.Egg",
    inherits = "base-food-fooddairy"
}, {
    name = "Base.Yoghurt",
    inherits = "base-food-fooddairy"
}, {
    name = "SapphCooking.ScotchEgg",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CreamCheese",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.HomemadeSourCream",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.Cheese",
    inherits = "base-food-fooddairy"
}, {
    name = "SapphCooking.MugRed_Milkshake",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CanofPowderedMilk",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.StrawberryMilk",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MugWhite_Milkshake",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SourCream",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.Processedcheese",
    inherits = "base-food-fooddairy"
}, {
    name = "SapphCooking.SapphCutCheeseSandwich",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.AlmondMilk",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.GrilledCheese",
    inherits = "base-food-fooddairy"
}, {
    name = "Base.CannedMilkOpen",
    inherits = "base-food-fooddairy"
}, {
    name = "SapphCooking.Bread_Egginhole",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.FriedEggplant",
    inherits = "base-food-fooddairy",
    mod = "sapphcooking"
}, {
    name = "Base.WaterBottleFull",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.Beverage",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.Coffee2",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.BagelPoppy",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.Teabag",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.Lollipop",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.Pop3",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.Pop2",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.HotDrinkTea",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.Teacup",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.PopBottle",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.Beverage2",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.HotDrink",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.ColdCuppa",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.JuiceBox",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.HotDrinkRed",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.ColdDrinkRed",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.TinnedSoupOpen",
    inherits = "base-food-fooddrink"
}, {
    name = "SapphCooking.Drinkmix_Peach",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Drinkmix_Orange",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Blender_Juice",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CoffeePacket",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Popsicle_Green",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Popsicle_White",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Drinkmix_Grape",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MugBrewCoffee4",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MugBrewCoffee3",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MugBrewCoffee2",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ThermosCoffee",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BottleofLemonJuice",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Popsicle_Orange",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "Base.ColdDrinkSpiffo",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.ColdDrinkWhite",
    inherits = "base-food-fooddrink"
}, {
    name = "SapphCooking.Drinkmix_Lemon",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BottleofGrapeJuice",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ColaBottlewithProteinShake",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PopBottlewithProteinShake",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Blender_Prep_Juice",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BottleofPeachJuice",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.GrindedCoffee",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "Base.HotDrinkWhite",
    inherits = "base-food-fooddrink"
}, {
    name = "SapphCooking.Popsicle_Blue",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PackofCoffeeFilters",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "Base.Teabag2",
    inherits = "base-food-fooddrink"
}, {
    name = "SapphCooking.ColaBottle",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BottleofWatermelonJuice",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "Base.Popcorn",
    inherits = "base-food-fooddrink"
}, {
    name = "Base.HotDrinkSpiffo",
    inherits = "base-food-fooddrink"
}, {
    name = "SapphCooking.BottleofJuice",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Popsicle_Purple",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MugBrewCoffee",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ThermosBeverage",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Popsicle_Pink",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Drinkmix_Watermelon",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Popsicle_Yellow",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Popsicle_Red",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ThermosSoup",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.EnergyDrink",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ThermosCoffeeEvolved",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BottleofOrangeJuice",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.HomemadePopcorn",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "Base.Pop",
    inherits = "base-food-fooddrink"
}, {
    name = "SapphCooking.CarbonatedWater",
    inherits = "base-food-fooddrink",
    mod = "sapphcooking"
}, {
    name = "Base.Pineapple",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.SackProduce_Onion",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.BerryGeneric1",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.HalloweenPumpkin",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.PieBlueberry",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.BerryGeneric4",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.WatermelonSmashed",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Onion",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Violets",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Acorn",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Banana",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Zucchini",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Daikon",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Lemon",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Peas",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Pear",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Broccoli",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.MixedVegetables",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Orange",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.WinterBerry",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.FriedOnionRingsCraft",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.HollyBerry",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Grapefruit",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Leek",
    inherits = "base-food-foodfruit"
}, {
    name = "farming.BloomingBroccoli",
    inherits = "base-food-foodfruit"
}, {
    name = "farming.Tomato",
    inherits = "base-food-foodfruit"
}, {
    name = "farming.Cabbage",
    inherits = "base-food-foodfruit"
}, {
    name = "farming.Strewberrie",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.BeautyBerry",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.PieApple",
    inherits = "base-food-foodfruit"
}, {
    name = "farming.RedRadish",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Corn",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.BottleofPineappleJuice",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.BerryPoisonIvy",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.MRE_ChiliwBeans",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.CakeStrawberryShortcake",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.CoffeeBeansBag",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.TomatoPaste",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.Tomato_Sachet",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.Cornmeal",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Pumpkin",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Dandelions",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.SlicedTomato",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Corn_Cob",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Jello_Pineapple",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.OpenCanofKernelCorn",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Drinkmix_Pineapple",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.BerryGeneric2",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.MRE_ChiliwBeansUn",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.Grapes",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.BerryBlue",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Rosehips",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.CanofKernelCorn",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SlicedCarrots",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.OnionRings",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.BowlJello_Pineapple",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.Mango",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.FriedOnionRings",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Watermelon",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.MushroomGeneric5",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Carrots",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.MushroomGeneric6",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.Jello_Grape",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.OpenBeans",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Apple",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.SlicedZucchini",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.MushroomGeneric3",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.MushroomGeneric4",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.BowlJello_Lime",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.MushroomGeneric1",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.MushroomGeneric2",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.BerryBlack",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.Drinkmix_Strawberry",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.MushroomGeneric7",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.CornFrozen",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.BottleofAppleJuice",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BowlJello_Strawberry",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Drinkmix_Apple",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Jello_Lime",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.WatermelonSliced",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.BloomingOnion",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Jello_Strawberry",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.AvocadoOil",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Corn_CobEvolved",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.Nettles",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.BowlJello_Grape",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.Blackbeans",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.DicedTomato",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Syrup_Strawberry",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.BerryGeneric3",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Avocado",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Lettuce",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Cherry",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.DicedCarrots",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BottleofStrawberryJuice",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.GrapeLeaves",
    inherits = "base-food-foodfruit"
}, {
    name = "SapphCooking.DicedBroccoli",
    inherits = "base-food-foodfruit",
    mod = "sapphcooking"
}, {
    name = "Base.BerryGeneric5",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Lime",
    inherits = "base-food-foodfruit"
}, {
    name = "Base.Centipede2",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.Millipede2",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.Centipede",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.Grasshopper",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.Cockroach",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.Cricket",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.SawflyLarva",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.Millipede",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.Termites",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.AmericanLadyCaterpillar",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.SilkMothCaterpillar",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.Pillbug",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.MonarchCaterpillar",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.BandedWoolyBearCaterpillar",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.SwallowtailCaterpillar",
    inherits = "base-food-foodinsect"
}, {
    name = "Base.Plonkies",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.CremeBruleeBowl",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CottonCandy_Orange",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.Allsorts",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.Marshmallows",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.CookiesShortbread",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.WhiteChocolate",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.PeanutButterSandwich",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.CandyCigarette",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.CinnamonRoll",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.CottonCandy_Purple",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanWhiteChocolate",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.ConeIcecreamMelted",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.CandyPopcorn",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.Icecream",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.ConeIcecream",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.PeanutButter",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.CandyCorn",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.CookiesChocolate",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.HotChocolate3",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.HotChocolate4",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.Chocolate",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.HotChocolate2",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CottonCandy_Green",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ChocolateEgg_Small",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.CandyFruitSlices",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.ChocoCakes",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.Broken_FortuneCookie",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.CandyPackage",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.Syrup_Chocolate",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Mochi",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.SnoGlobes",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.RockCandy",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.JamMarmalade",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.ChocolateCoveredCoffeeBeans",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.IcecreamSandwich",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BowlofCandy",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.ChocolateChips",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.CottonCandy_Yellow",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.IcecreamMelted",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.ChocolateCake",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.CookieJelly",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.ChocolateEgg_Large",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanHotChocolate",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.Smore",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.CandyApple",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CottonCandy_Red",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.Candycane",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.LicoriceRed",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.Eclair_WhiteChocolate",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.HardCandies",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.HotChocolate",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanChocolate",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.Croissant",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.Bonbon",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Eclair_Chocolate",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PeanutButter_Sachet",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Eclair",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CottonCandy_Blue",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CaramelPuddingBowl",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.CookieChocolateChip",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.JamFruit",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.Biscuit",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.JellyBeans",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.Ladyfingers",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Heart_Chocolate",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.Modjeska",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.CakeChocolate",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.ChocolateEgg_Medium",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ChocolatePuddingBowl",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.ConeIcecreamToppings",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.LicoriceBlack",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.Bonbon_Liqueur",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.IcecreamSandwichMelted",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CottonCandy_Pink",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CottonCandy_White",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.MintCandy",
    inherits = "base-food-foodjunk"
}, {
    name = "SapphCooking.FortuneCookie",
    inherits = "base-food-foodjunk",
    mod = "sapphcooking"
}, {
    name = "Base.Cone",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.Jujubes",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.Painauchocolat",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.HiHis",
    inherits = "base-food-foodjunk"
}, {
    name = "Base.MeatSteamBun",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.MRE_InChickenStrogonoffUn",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "Base.BaloneySlice",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.Chicken",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.DeadSquirrel",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.ChickenNuggets",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.WoodenSkewersMeat",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.TenderizedMeat",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SlicedChicken",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BreadedTenderizedMeat",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "Base.DeadRabbit",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.Slug2",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.DeadMouse",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.DeadRat",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.Steak",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.Slug",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.PorkChop",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.Smallanimalmeat",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.Salami",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.Pepperoni",
    inherits = "base-food-foodmeat"
}, {
    name = "farming.Bacon",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.DeadBird",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.SalamiSlice",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.MeatPatty",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.ChickenBroth",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.DeadRatinBatter",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.TurkeyLegs",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Meatballs",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "Base.ChickenFried",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.MRE_InRiceMincedMeat",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "Base.MincedMeat",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.NoodleSachet_Chicken",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.DumplingsMeatUn",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_InRiceMincedMeatUn",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "Base.MuttonChop",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.InstantNoodles_Chicken",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SlicedChickenBatter",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "Base.FrogMeat",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.MRE_OmeletwHamUn",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_InChickenStrogonoff",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "Base.Ham",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.Smallbirdmeat",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.SmallBirdMeatinBatter",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "Base.Baloney",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.Frog",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.MRE_MeatballsinSauce",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BowlofMashedPotatoes_Meatballs",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_MeatballsinSauceUn",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BowlofRiceChickenStroganoff",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SlicedSteak",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_OmeletwHam",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "Base.ChickenFoot",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.Seitan",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "Base.Tofu",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.MincedMeat_Chicken",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "farming.BaconRashers",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.HamSlice",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.Snail",
    inherits = "base-food-foodmeat"
}, {
    name = "Base.Rabbitmeat",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.FriedBirdMeat",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "Base.MeatDumpling",
    inherits = "base-food-foodmeat"
}, {
    name = "SapphCooking.BowlofChickenStroganoff",
    inherits = "base-food-foodmeat",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.InstantNoodles_Beef",
    inherits = "base-food-foodpasta",
    mod = "sapphcooking"
}, {
    name = "Base.RamenBowl",
    inherits = "base-food-foodpasta"
}, {
    name = "Base.WaterPotPasta",
    inherits = "base-food-foodpasta"
}, {
    name = "Base.PastaPot",
    inherits = "base-food-foodpasta"
}, {
    name = "Base.Ramen",
    inherits = "base-food-foodpasta"
}, {
    name = "SapphCooking.Ravioli",
    inherits = "base-food-foodpasta",
    mod = "sapphcooking"
}, {
    name = "Base.Pasta",
    inherits = "base-food-foodpasta"
}, {
    name = "SapphCooking.PastaSheets",
    inherits = "base-food-foodpasta",
    mod = "sapphcooking"
}, {
    name = "Base.PastaBowl",
    inherits = "base-food-foodpasta"
}, {
    name = "SapphCooking.Tortellini",
    inherits = "base-food-foodpasta",
    mod = "sapphcooking"
}, {
    name = "Base.PiePumpkin",
    inherits = "base-food-foodpie"
}, {
    name = "Base.CakeBatter",
    inherits = "base-food-foodpie"
}, {
    name = "SapphCooking.TiramisuPiece",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CakeSlice_NianGao",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.RatattouilePiece",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "Base.Cupcake",
    inherits = "base-food-foodpie"
}, {
    name = "Base.CakeCheeseCake",
    inherits = "base-food-foodpie"
}, {
    name = "SapphCooking.Cake_NianGao",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "Base.Pie",
    inherits = "base-food-foodpie"
}, {
    name = "SapphCooking.CarrotCake",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "Base.PiePrep",
    inherits = "base-food-foodpie"
}, {
    name = "Base.CakeCarrot",
    inherits = "base-food-foodpie"
}, {
    name = "Base.CakePrep",
    inherits = "base-food-foodpie"
}, {
    name = "SapphCooking.LasagnaPiece",
    inherits = "base-food-foodpie",
    mod = "sapphcooking"
}, {
    name = "Base.PieWholeRaw",
    inherits = "base-food-foodpie"
}, {
    name = "Base.CakeRedVelvet",
    inherits = "base-food-foodpie"
}, {
    name = "Base.PieLemonMeringue",
    inherits = "base-food-foodpie"
}, {
    name = "Base.PieWholeRawSweet",
    inherits = "base-food-foodpie"
}, {
    name = "Base.CakeBlackForest",
    inherits = "base-food-foodpie"
}, {
    name = "Base.CakeSlice",
    inherits = "base-food-foodpie"
}, {
    name = "Base.PieKeyLime",
    inherits = "base-food-foodpie"
}, {
    name = "Base.QuaggaCakes",
    inherits = "base-food-foodpie"
}, {
    name = "Base.Crappie",
    inherits = "base-food-foodpie"
}, {
    name = "Base.FruitSalad",
    inherits = "base-food-foodready"
}, {
    name = "Base.CookiesOatmeal",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.Crepe",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.NoodleSoup",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.SpringrollEvolved",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PizzaPeel",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_Pack10",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.Springroll",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.TakeoutBoxFood_Noodle",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.FryingPan_BaconandEggs",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PlateBlue_HuevosRancheros",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PlateFancy_HuevosRancherosEvolved",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.BurgerRecipe",
    inherits = "base-food-foodready"
}, {
    name = "Base.BakingTray_Muffin_Recipe",
    inherits = "base-food-foodready"
}, {
    name = "Base.MuffinFruit",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.CrepeEvolved",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BowlofMarshmallows",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.Macandcheese",
    inherits = "base-food-foodready"
}, {
    name = "Base.StewBowl",
    inherits = "base-food-foodready"
}, {
    name = "Base.Pickles",
    inherits = "base-food-foodready"
}, {
    name = "Base.MuffinGeneric",
    inherits = "base-food-foodready"
}, {
    name = "Base.BagelSesame",
    inherits = "base-food-foodready"
}, {
    name = "Base.Toast",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.MRE_Spaguetti",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_Pack9",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_Pack8",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.Fries",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.PlateBlue_BaconandEggs",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BowlofChili",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.EggBoiled",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.Saucepan_ShuiZhuYuCooked",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.TVDinner",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.Blender_Prep_Smoothie",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SpringrollWrapper",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.ArrozConLecheBowl",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.PancakesRecipe",
    inherits = "base-food-foodready"
}, {
    name = "Base.Oatmeal",
    inherits = "base-food-foodready"
}, {
    name = "Base.Waffles",
    inherits = "base-food-foodready"
}, {
    name = "Base.OystersFried",
    inherits = "base-food-foodready"
}, {
    name = "Base.Burrito",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.HotdogBun",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Plate_HuevosRancheros",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WoodenSkewersMarshmallows_Melted",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MeatballsCooked",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WoodenSkewersMarshmallows",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.DumplingsMeatCooked",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "farming.Salad",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.HotdogSandwichEvolved",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.Corndog",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.BleachBottlewithProteinShake",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.Hotdog",
    inherits = "base-food-foodready"
}, {
    name = "Base.BurritoRecipe",
    inherits = "base-food-foodready"
}, {
    name = "Base.CerealBowl",
    inherits = "base-food-foodready"
}, {
    name = "Base.Pizza",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.MRE_LasagnaUn",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Plate_HuevosRancherosEvolved",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PizzaCutter",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BeverageSmoothie",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.WafflesRecipe",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.Schnitzel",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PlateOrange_HuevosRancherosEvolved",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CevicheBowlEvolved",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CanofRefriedBeans",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_Pack5",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Falafel_Fried",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PlateOrange_HuevosRancheros",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithJapaneseCurryCooked",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BowlofBorscht",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Plate_BaconandEggs",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_Pack4",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Takoyaki",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WildGarlicBreadCooked",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_Pack7",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WokFriedRiceEvolved",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_SpaguettiUn",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.HomemadeFries",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.Onigiri",
    inherits = "base-food-foodready"
}, {
    name = "Base.Perogies",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.PlateOrange_BaconandEggs",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.Cereal",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.BottlewithProteinShake",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SapphCorndog",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.BaguetteSandwich",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.TakeoutBoxFood",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.TacoRecipe",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.PlateFancy_BaconandEggs",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_Pack6",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_Pack1",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.Taco",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.SmashBurger",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.HotdogCustom",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.BagelPlain",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.MRE_Pack3",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_Pack2",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.FriedRat",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.DumplingsVegetableUn",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BowlofFriedRice",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.PizzaRecipe",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.Saucepan_Custard_Cooked",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.SoupBowl",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.PotofVegetableStockUncooked",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PlateFancy_HuevosRancheros",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.Sandwich",
    inherits = "base-food-foodready"
}, {
    name = "Base.SushiFish",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.BowlofRisotto",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithUncookedSpaguetti",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_InBeefStrogonoff",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Spice_PestoBowl",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithCookedCutPotatoes",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PlateBlue_HuevosRancherosEvolved",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.FrenchToast_Prep",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.SaucepanwithUncookedSpaguettiandMeatballs",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_Lasagna",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Falafel_Uncooked",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.RoastingpanwithUncookedLasagna",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.TakeoutBoxFood_Soup",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.Guacamole",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.MRE_BeefStew",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.FishFried",
    inherits = "base-food-foodready"
}, {
    name = "Base.Burger",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.WoodenSkewersRatCooked",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.TunaSandwich",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_InBeefStrogonoffUn",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Blender_Smoothie",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.PizzaWhole",
    inherits = "base-food-foodready"
}, {
    name = "Base.OmeletteRecipe",
    inherits = "base-food-foodready"
}, {
    name = "Base.PotOfSoupRecipe",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.CevicheBowl",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_BeefStewUn",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.FrenchToast_Evolved",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.RoastingpanwithRatatouilleCooked",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.HotdogEvolved",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.DumplingsVegetableCooked",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.TofuFried",
    inherits = "base-food-foodready"
}, {
    name = "Base.RefriedBeans",
    inherits = "base-food-foodready"
}, {
    name = "SapphCooking.Tanghulu",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WoodenSkewersInsect",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_Pack11",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MRE_Pack12",
    inherits = "base-food-foodready",
    mod = "sapphcooking"
}, {
    name = "Base.ShrimpFried",
    inherits = "base-food-foodseafood"
}, {
    name = "Base.ShrimpDumpling",
    inherits = "base-food-foodseafood"
}, {
    name = "Base.Oysters",
    inherits = "base-food-foodseafood"
}, {
    name = "Base.FishFillet",
    inherits = "base-food-foodseafood"
}, {
    name = "Base.SquidCalamari",
    inherits = "base-food-foodseafood"
}, {
    name = "Base.Squid",
    inherits = "base-food-foodseafood"
}, {
    name = "Base.ShrimpFriedCraft",
    inherits = "base-food-foodseafood"
}, {
    name = "Base.Shrimp",
    inherits = "base-food-foodseafood"
}, {
    name = "Base.Lobster",
    inherits = "base-food-foodseafood"
}, {
    name = "SapphCooking.BowlJello_Orange",
    inherits = "base-food-foodsnack",
    mod = "sapphcooking"
}, {
    name = "Base.Crisps3",
    inherits = "base-food-foodsnack"
}, {
    name = "SapphCooking.ProteinBar",
    inherits = "base-food-foodsnack",
    mod = "sapphcooking"
}, {
    name = "Base.Peppermint",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.Crisps4",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.Peanuts",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.SunflowerSeeds",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.GummyWorms",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.Crisps",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.BeefJerky",
    inherits = "base-food-foodsnack"
}, {
    name = "SapphCooking.Jello_Orange",
    inherits = "base-food-foodsnack",
    mod = "sapphcooking"
}, {
    name = "Base.GranolaBar",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.GummyBears",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.Crisps2",
    inherits = "base-food-foodsnack"
}, {
    name = "SapphCooking.GrahamCrackersEvolved",
    inherits = "base-food-foodsnack",
    mod = "sapphcooking"
}, {
    name = "Base.GrahamCrackers",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.Pretzel",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.Gum",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.Edamame",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.DehydratedMeatStick",
    inherits = "base-food-foodsnack"
}, {
    name = "SapphCooking.CrackersEvolved",
    inherits = "base-food-foodsnack",
    mod = "sapphcooking"
}, {
    name = "Base.Crackers",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.TortillaChips",
    inherits = "base-food-foodsnack"
}, {
    name = "Base.EmptyJar",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.Saucepan_ArrozLeche",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.PancakesCraft",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.RoastingpanwithRatatouilleUn",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.Fork",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.MugSpiffo",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.RicePan",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.Saucepan",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.PanFriedVegetables",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.GridlePan",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.WokPan_KungPaoChicken",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.KitchenKnife",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.EmptyThermos",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WokPan_CacioPepePrep",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Chopsticks_Sapph",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WokPan_Oil",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WokPan",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Mug_Evolved",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.TinOpener",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.Pancakes",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.WaterSaucepanArborioRice",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.CocktailMixerEvolved",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Saucepan_ArrozLecheUn",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MugSpiffo_Evolved",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.TiramisuPan",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.RollingPin",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.FryingPanFriedRiceEvolved",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.ButterKnife",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.MeatCleaver",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.PlasticCup_Evolved",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.Kettle",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.FryingPanwithOil",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.WaterSaucepanPasta",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.Saucepan_Custard",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.GriddlePanFriedVegetables",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.WokPan_CacioPepeEvolved",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.BowlofRiceJapaneseCurry",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.Spoon",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.MugWhite",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.PanFriedVegetables2",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.Spatula",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.CocktailMixerPrep",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Saucepan_ShuiZhuYuUn",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WokPan_Yakisoba",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.LowballGlass",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MugWhite_Evolved",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.CarvingFork",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.BakingPan",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.MugCoffee",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.GrillBrush",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.BowlofJapaneseCurry",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.RoastingpanwithLasagna",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PlasticSpork",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MugCoffee4",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MugCoffee3",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WoodenSkewers",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.OvenMitt",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.MugRed",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.MetalWhisk",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Empty_FrenchPress",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.FryingPanwithFriedRice",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.JarLid",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.Pan",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.MetalSpork",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MugRed_Evolved",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.WaterSaucepanRice",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.WokPanwithFriedRice",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Laddle",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.PotatoPancakes",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.PancakeMix",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.WoodenSkewersRat",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WoodSpork",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WokPan_YakisobaEvolved",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.Mugl",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.Panfish",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.WoodenSpoon",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WokPan_RoastVeg",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.PastaPan",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.WoodenSkewersVegetable",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.MugCoffee2",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Saucepan_InstantNoodles",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.WaterSaucepanBrownRice",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.BreadKnife",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.IcePick",
    inherits = "base-food-foodutensil"
}, {
    name = "SapphCooking.Coffee_FrenchPress",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Ladle_Wood",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.Saucepan_InstantNoodlesEvolved",
    inherits = "base-food-foodutensil",
    mod = "sapphcooking"
}, {
    name = "Base.RoastingPan",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.Mugfull",
    inherits = "base-food-foodutensil"
}, {
    name = "Base.KitchenTongs",
    inherits = "base-food-foodutensil"
}}
