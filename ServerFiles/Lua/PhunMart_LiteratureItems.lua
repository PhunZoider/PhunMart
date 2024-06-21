return {{
    abstract = true,
    key = "base-literature",
    tab = "Literature",
    tags = "literature",
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
    key = "base-literature-book",
    inherits = "base-literature",
    tab = "Books",
    tags = "literature,book"
}, {
    abstract = true,
    key = "base-literature-magazine",
    inherits = "base-literature",
    tab = "Magazines",
    tags = "literature,magazine"
}, {
    abstract = true,
    key = "base-literature-misc",
    inherits = "base-literature",
    tags = "literature,misc"
}, {
    abstract = true,
    key = "base-literature-litmisc",
    inherits = "base-literature",
    tab = "Misc",
    tags = "literature,litmisc"
}, {
    abstract = true,
    key = "base-literature-schematic",
    inherits = "base-literature",
    tab = "Schematics",
    tags = "literature,schematic"
}, {
    name = "Base.BookFarming4",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFarming3",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFarming5",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFarming2",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFarming1",
    inherits = "base-literature-book"
}, {
    name = "Base.BookElectrician1",
    inherits = "base-literature-book"
}, {
    name = "Base.BookElectrician3",
    inherits = "base-literature-book"
}, {
    name = "Base.BookElectrician2",
    inherits = "base-literature-book"
}, {
    name = "Base.BookElectrician5",
    inherits = "base-literature-book"
}, {
    name = "Base.BookElectrician4",
    inherits = "base-literature-book"
}, {
    name = "Base.BookMechanic2",
    inherits = "base-literature-book"
}, {
    name = "Base.BookMechanic1",
    inherits = "base-literature-book"
}, {
    name = "Base.BookMechanic4",
    inherits = "base-literature-book"
}, {
    name = "Base.BookMechanic3",
    inherits = "base-literature-book"
}, {
    name = "Base.BookMechanic5",
    inherits = "base-literature-book"
}, {
    name = "Base.BookBlacksmith5",
    inherits = "base-literature-book"
}, {
    name = "Base.BookBlacksmith2",
    inherits = "base-literature-book"
}, {
    name = "Base.BookBlacksmith1",
    inherits = "base-literature-book"
}, {
    name = "Base.BookBlacksmith4",
    inherits = "base-literature-book"
}, {
    name = "Base.BookBlacksmith3",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFirstAid2",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFirstAid1",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFirstAid4",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFirstAid3",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFirstAid5",
    inherits = "base-literature-book"
}, {
    name = "Base.BookForaging4",
    inherits = "base-literature-book"
}, {
    name = "Base.BookForaging5",
    inherits = "base-literature-book"
}, {
    name = "Base.BookForaging1",
    inherits = "base-literature-book"
}, {
    name = "Base.BookForaging2",
    inherits = "base-literature-book"
}, {
    name = "Base.BookForaging3",
    inherits = "base-literature-book"
}, {
    name = "Base.Notebook",
    inherits = "base-literature-book"
}, {
    name = "Base.BookCooking3",
    inherits = "base-literature-book"
}, {
    name = "Base.BookCooking4",
    inherits = "base-literature-book"
}, {
    name = "Base.BookCooking1",
    inherits = "base-literature-book"
}, {
    name = "Base.BookCooking2",
    inherits = "base-literature-book"
}, {
    name = "Base.BookCooking5",
    inherits = "base-literature-book"
}, {
    name = "Base.BookTrapping4",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFishing2",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFishing1",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFishing4",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFishing3",
    inherits = "base-literature-book"
}, {
    name = "Base.BookFishing5",
    inherits = "base-literature-book"
}, {
    name = "Base.BookTailoring1",
    inherits = "base-literature-book"
}, {
    name = "Base.BookTailoring2",
    inherits = "base-literature-book"
}, {
    name = "Base.BookTailoring3",
    inherits = "base-literature-book"
}, {
    name = "Base.BookTailoring4",
    inherits = "base-literature-book"
}, {
    name = "Base.BookTailoring5",
    inherits = "base-literature-book"
}, {
    name = "Base.ComicBook",
    inherits = "base-literature-book"
}, {
    name = "Base.BookMetalWelding3",
    inherits = "base-literature-book"
}, {
    name = "Base.BookMetalWelding2",
    inherits = "base-literature-book"
}, {
    name = "Base.BookMetalWelding5",
    inherits = "base-literature-book"
}, {
    name = "Base.BookMetalWelding4",
    inherits = "base-literature-book"
}, {
    name = "Base.BookMetalWelding1",
    inherits = "base-literature-book"
}, {
    name = "Base.BookCarpentry5",
    inherits = "base-literature-book"
}, {
    name = "Base.BookCarpentry4",
    inherits = "base-literature-book"
}, {
    name = "Base.BookCarpentry3",
    inherits = "base-literature-book"
}, {
    name = "Base.BookCarpentry2",
    inherits = "base-literature-book"
}, {
    name = "Base.BookCarpentry1",
    inherits = "base-literature-book"
}, {
    name = "Base.Book",
    inherits = "base-literature-book"
}, {
    name = "Base.BookTrapping3",
    inherits = "base-literature-book"
}, {
    name = "Base.BookTrapping2",
    inherits = "base-literature-book"
}, {
    name = "Base.BookTrapping1",
    inherits = "base-literature-book"
}, {
    name = "Base.BookTrapping5",
    inherits = "base-literature-book"
}, {
    name = "Base.Journal",
    inherits = "base-literature-litmisc"
}, {
    name = "Base.Doodle",
    inherits = "base-literature-litmisc"
}, {
    name = "Base.SheetPaper2",
    inherits = "base-literature-litmisc"
}, {
    name = "Base.HuntingMag2",
    inherits = "base-literature-magazine"
}, {
    name = "Base.MagazineCrossword2",
    inherits = "base-literature-magazine"
}, {
    name = "Base.MagazineCrossword3",
    inherits = "base-literature-magazine"
}, {
    name = "Base.SmithingMag4",
    inherits = "base-literature-magazine"
}, {
    name = "Base.CookingMag1",
    inherits = "base-literature-magazine"
}, {
    name = "Base.CookingMag2",
    inherits = "base-literature-magazine"
}, {
    name = "Base.HottieZ",
    inherits = "base-literature-magazine"
}, {
    name = "Base.FarmingMag1",
    inherits = "base-literature-magazine"
}, {
    name = "Base.Magazine",
    inherits = "base-literature-magazine"
}, {
    name = "SapphCooking.AsianFoodMagazine",
    inherits = "base-literature-magazine",
    mod = "sapphcooking"
}, {
    name = "Base.HuntingMag3",
    inherits = "base-literature-magazine"
}, {
    name = "Base.HuntingMag1",
    inherits = "base-literature-magazine"
}, {
    name = "Base.MechanicMag1",
    inherits = "base-literature-magazine"
}, {
    name = "Base.MechanicMag2",
    inherits = "base-literature-magazine"
}, {
    name = "Base.HerbalistMag",
    inherits = "base-literature-magazine"
}, {
    name = "Base.MagazineWordsearch1",
    inherits = "base-literature-magazine"
}, {
    name = "Base.MagazineWordsearch2",
    inherits = "base-literature-magazine"
}, {
    name = "Base.MagazineWordsearch3",
    inherits = "base-literature-magazine"
}, {
    name = "Base.TVMagazine",
    inherits = "base-literature-magazine"
}, {
    name = "Base.MechanicMag3",
    inherits = "base-literature-magazine"
}, {
    name = "Base.SmithingMag3",
    inherits = "base-literature-magazine"
}, {
    name = "Base.SmithingMag2",
    inherits = "base-literature-magazine"
}, {
    name = "Base.SmithingMag1",
    inherits = "base-literature-magazine"
}, {
    name = "Base.FishingMag2",
    inherits = "base-literature-magazine"
}, {
    name = "Base.EngineerMagazine2",
    inherits = "base-literature-magazine"
}, {
    name = "Base.EngineerMagazine1",
    inherits = "base-literature-magazine"
}, {
    name = "Base.FishingMag1",
    inherits = "base-literature-magazine"
}, {
    name = "Base.MetalworkMag2",
    inherits = "base-literature-magazine"
}, {
    name = "Base.MetalworkMag1",
    inherits = "base-literature-magazine"
}, {
    name = "Base.MetalworkMag4",
    inherits = "base-literature-magazine"
}, {
    name = "Base.MetalworkMag3",
    inherits = "base-literature-magazine"
}, {
    name = "Base.MagazineCrossword1",
    inherits = "base-literature-magazine"
}, {
    name = "Base.ElectronicsMag4",
    inherits = "base-literature-magazine"
}, {
    name = "Base.ElectronicsMag3",
    inherits = "base-literature-magazine"
}, {
    name = "Base.ElectronicsMag2",
    inherits = "base-literature-magazine"
}, {
    name = "Base.ElectronicsMag1",
    inherits = "base-literature-magazine"
}, {
    name = "Base.ElectronicsMag5",
    inherits = "base-literature-magazine"
}, {
    name = "Radio.RadioMag2",
    inherits = "base-literature-magazine"
}, {
    name = "Radio.RadioMag3",
    inherits = "base-literature-magazine"
}, {
    name = "Radio.RadioMag1",
    inherits = "base-literature-magazine"
}, {
    name = "SapphCooking.SausageMakingMagazine",
    inherits = "base-literature-magazine",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.EuropeFoodMagazine",
    inherits = "base-literature-magazine",
    mod = "sapphcooking"
}, {
    name = "SapphCooking.PastaDoughMagazine",
    inherits = "base-literature-magazine",
    mod = "sapphcooking"
}, {
    name = "Base.Newspaper",
    inherits = "base-literature-misc"
}, {
    name = "damnCraft.MufflerSchematics",
    inherits = "base-literature-schematic",
    mod = "damnlib"
}, {
    name = "damnCraft.BumperSchematics",
    inherits = "base-literature-schematic",
    mod = "damnlib"
}, {
    name = "damnCraft.TrunkLidSchematics",
    inherits = "base-literature-schematic",
    mod = "damnlib"
}, {
    name = "damnCraft.SeatSchematics",
    inherits = "base-literature-schematic",
    mod = "damnlib"
}, {
    name = "damnCraft.SchematicsBox",
    inherits = "base-literature-schematic",
    mod = "damnlib"
}, {
    name = "damnCraft.WindowSchematics",
    inherits = "base-literature-schematic",
    mod = "damnlib"
}, {
    name = "damnCraft.RimSchematics",
    inherits = "base-literature-schematic",
    mod = "damnlib"
}, {
    name = "damnCraft.BodyworkSchematics",
    inherits = "base-literature-schematic",
    mod = "damnlib"
}, {
    name = "damnCraft.DoorSchematics",
    inherits = "base-literature-schematic",
    mod = "damnlib"
}, {
    name = "damnCraft.HoodSchematics",
    inherits = "base-literature-schematic",
    mod = "damnlib"
}}
