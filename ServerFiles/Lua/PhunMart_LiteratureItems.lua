return {{
    abstract = true,
    key = "base-literature",
    tab = "Literature",
    tags = "literature",
    inventory = {
        min = 1,
        max = 3
    },
    price = {
        currency = {
            base = 45,
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
}, {
    name = "BicPen.BicPen",
    inherits = "base-literature-litmisc",
    mod = "4ColorBicPenFix"
}, {
    name = "Base.LegalBook",
    inherits = "base-literature-book",
    mod = "PertsPartyTiles"
}, {
    name = "BZMClothing.TobinsSpiritGuideBook",
    inherits = "base-literature-book",
    mod = "MonmouthCounty_new"
}, {
    name = "DrivingSkill.DrivingSkill_BookDriving4",
    inherits = "base-literature-book",
    mod = "DrivingSkill"
}, {
    name = "DrivingSkill.DrivingSkill_BookDriving3",
    inherits = "base-literature-book",
    mod = "DrivingSkill"
}, {
    name = "DrivingSkill.DrivingSkill_BookDriving2",
    inherits = "base-literature-book",
    mod = "DrivingSkill"
}, {
    name = "DrivingSkill.DrivingSkill_BookDriving1",
    inherits = "base-literature-book",
    mod = "DrivingSkill"
}, {
    name = "DrivingSkill.DrivingSkill_BookDriving5",
    inherits = "base-literature-book",
    mod = "DrivingSkill"
}, {
    name = "Literacy.BookStrength1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookStrength3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookBlunt1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookStrength2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookStrength5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookBlunt3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookStrength4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookBlunt2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSmallBlunt4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookBlunt5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSmallBlunt3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookBlunt4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSmallBlunt5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSpear4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSpear5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookLongBlade5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSpear1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookLongBlade4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSpear2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookLongBlade3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSpear3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookNimble3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookNimble2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookNimble5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookNimble4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookLongBlade2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookLongBlade1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSmallBlade1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookReloading4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookReloading5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSmallBlade2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookReloading1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSmallBlade3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookReloading2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSmallBlade4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookReloading3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSmallBlade5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookMaintenance1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookAxe3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookAxe4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookAxe1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookAxe2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookLightfoot5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookLightfoot4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookLightfoot3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookLightfoot2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookLightfoot1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSprinting1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSprinting2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSprinting3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookMaintenance5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSprinting4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookMaintenance4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSprinting5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookMaintenance3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookMaintenance2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSneak3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSneak4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSneak5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSneak1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookAxe5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSneak2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookAiming1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookAiming5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookAiming4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookAiming3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookNimble1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookAiming2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookFitness2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookFitness1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookFitness4",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookFitness3",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookFitness5",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSmallBlunt2",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "Literacy.BookSmallBlunt1",
    inherits = "base-literature-book",
    mod = "Literacy"
}, {
    name = "SpoonEssentialCrafting.SheetPaperX",
    inherits = "base-literature-litmisc",
    mod = "EssentialCrafting"
}, {
    name = "Base.VFECraftingMag1",
    inherits = "base-literature-magazine",
    mod = "VFExpansion1"
}, {
    name = "Base.BMMagazineCars",
    inherits = "base-literature-magazine",
    mod = "BuildingMenu"
}, {
    name = "Base.BMMagazineSecretEntrances",
    inherits = "base-literature-magazine",
    mod = "BuildingMenu"
}, {
    name = "Base.BMMagazineGlass",
    inherits = "base-literature-magazine",
    mod = "BuildingMenu"
}, {
    name = "ISA.ISAMag1",
    inherits = "base-literature-magazine",
    mod = "ISA_41"
}, {
    name = "LightSensors.LSElectronicsMag",
    inherits = "base-literature-magazine",
    mod = "LightSensor"
}, {
    name = "SensorsTraps.LSElectronicsMagTraps",
    inherits = "base-literature-magazine",
    mod = "LightSensor"
}, {
    name = "MonmouthItems.BaCI1_Comic",
    inherits = "base-literature-magazine",
    mod = "MonmouthCounty_new"
}, {
    name = "MonmouthItems.BaCI2_Comic",
    inherits = "base-literature-magazine",
    mod = "MonmouthCounty_new"
}, {
    name = "MonmouthItems.BaCI3_Comic",
    inherits = "base-literature-magazine",
    mod = "MonmouthCounty_new"
}, {
    name = "Literacy.LiteracyMag",
    inherits = "base-literature-magazine",
    mod = "Literacy"
}, {
    name = "SAPPHEATER.HeaterMag1",
    inherits = "base-literature-magazine",
    mod = "SAPPHEATER_fixed"
}, {
    name = "SAPPHEATER.HeaterMag2",
    inherits = "base-literature-magazine",
    mod = "SAPPHEATER_fixed"
}, {
    name = "SAPPHEATER.HeaterMag3",
    inherits = "base-literature-magazine",
    mod = "SAPPHEATER_fixed"
}, {
    name = "AutoGate.AutoGateMag",
    inherits = "base-literature-magazine",
    mod = "AutomaticGateMotors"
}, {
    name = "TrueMusicJukebox.InstructionManual",
    inherits = "base-literature-magazine",
    mod = "TrueMusicJukebox"
}}
