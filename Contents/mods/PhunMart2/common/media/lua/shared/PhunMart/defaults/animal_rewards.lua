-- Livestock claim-token rewards for HoesNMoes (and similar shops).
-- Purchase grants PhunMart.AnimalClaimToken; right-click outside to release.
local function animal(opts)
    return {
        inherit = "animal_base",
        price = opts.price or "animal_common",
        offer = {
            weight = opts.weight or 1.0,
            stock = {
                min = 1,
                max = opts.stockMax or 2
            }
        },
        display = {
            text = opts.text,
            texture = opts.icon
        },
        actions = {{
            type = "spawnAnimal",
            animal = opts.animal,
            breed = opts.breed,
            size = opts.size or "medium"
        }}
    }
end

return {

    -- =========================================================
    -- CHICKENS (small)
    -- =========================================================
    animal_hen_rhodeisland = animal({
        text = "Rhode Island Red Hen",
        icon = "Item_Chicken_HenBrown",
        animal = "hen",
        breed = "rhodeisland",
        size = "small",
        price = "animal_common",
        weight = 1.2
    }),
    animal_cockerel_rhodeisland = animal({
        text = "Rhode Island Red Cockerel",
        icon = "Item_Chicken_RoosterBrown",
        animal = "cockerel",
        breed = "rhodeisland",
        size = "small",
        price = "animal_common",
        weight = 0.8
    }),
    animal_chick_rhodeisland = animal({
        text = "Rhode Island Red Chick",
        icon = "Item_Chicken_Chick",
        animal = "chick",
        breed = "rhodeisland",
        size = "small",
        price = "animal_cheap",
        weight = 1.0,
        stockMax = 3
    }),
    animal_hen_leghorn = animal({
        text = "Leghorn Hen",
        icon = "Item_Chicken_HenWhite",
        animal = "hen",
        breed = "leghorn",
        size = "small",
        price = "animal_common",
        weight = 1.2
    }),
    animal_cockerel_leghorn = animal({
        text = "Leghorn Cockerel",
        icon = "Item_Chicken_RoosterWhite",
        animal = "cockerel",
        breed = "leghorn",
        size = "small",
        price = "animal_common",
        weight = 0.8
    }),
    animal_chick_leghorn = animal({
        text = "Leghorn Chick",
        icon = "Item_Chicken_Chick",
        animal = "chick",
        breed = "leghorn",
        size = "small",
        price = "animal_cheap",
        weight = 1.0,
        stockMax = 3
    }),

    -- =========================================================
    -- PIGS
    -- =========================================================
    animal_piglet_landrace = animal({
        text = "American Landrace Piglet",
        icon = "Item_PigWhite_Piglet",
        animal = "piglet",
        breed = "landrace",
        size = "medium",
        price = "animal_uncommon",
        weight = 1.0
    }),
    animal_sow_landrace = animal({
        text = "American Landrace Sow",
        icon = "Item_PigPink_Dead",
        animal = "sow",
        breed = "landrace",
        size = "large",
        price = "animal_rare",
        weight = 0.6
    }),
    animal_boar_landrace = animal({
        text = "American Landrace Boar",
        icon = "Item_PigPink_Dead",
        animal = "boar",
        breed = "landrace",
        size = "large",
        price = "animal_rare",
        weight = 0.5
    }),
    animal_piglet_largeblack = animal({
        text = "Large Black Piglet",
        icon = "Item_PigBlack_Piglet",
        animal = "piglet",
        breed = "largeblack",
        size = "medium",
        price = "animal_uncommon",
        weight = 1.0
    }),
    animal_sow_largeblack = animal({
        text = "Large Black Sow",
        icon = "Item_PigBlack_Dead",
        animal = "sow",
        breed = "largeblack",
        size = "large",
        price = "animal_rare",
        weight = 0.6
    }),
    animal_boar_largeblack = animal({
        text = "Large Black Boar",
        icon = "Item_PigBlack_Dead",
        animal = "boar",
        breed = "largeblack",
        size = "large",
        price = "animal_rare",
        weight = 0.5
    }),

    -- =========================================================
    -- SHEEP
    -- =========================================================
    animal_lamb_suffolk = animal({
        text = "Suffolk Lamb",
        icon = "Item_SheepSuffolk_Lamb",
        animal = "lamb",
        breed = "suffolk",
        size = "medium",
        price = "animal_uncommon",
        weight = 1.0
    }),
    animal_ewe_suffolk = animal({
        text = "Suffolk Ewe",
        icon = "Item_SheepSuffolk_Lamb",
        animal = "ewe",
        breed = "suffolk",
        size = "large",
        price = "animal_rare",
        weight = 0.7
    }),
    animal_ram_suffolk = animal({
        text = "Suffolk Ram",
        icon = "Item_SheepSuffolk_Lamb",
        animal = "ram",
        breed = "suffolk",
        size = "large",
        price = "animal_rare",
        weight = 0.6
    }),
    animal_lamb_rambouillet = animal({
        text = "Rambouillet Lamb",
        icon = "Item_SheepWhite_Lamb",
        animal = "lamb",
        breed = "rambouillet",
        size = "medium",
        price = "animal_uncommon",
        weight = 1.0
    }),
    animal_ewe_rambouillet = animal({
        text = "Rambouillet Ewe",
        icon = "Item_SheepWhite_Lamb",
        animal = "ewe",
        breed = "rambouillet",
        size = "large",
        price = "animal_rare",
        weight = 0.7
    }),
    animal_lamb_friesian = animal({
        text = "East Friesian Lamb",
        icon = "Item_SheepWhite_Lamb",
        animal = "lamb",
        breed = "friesian",
        size = "medium",
        price = "animal_uncommon",
        weight = 1.0
    }),
    animal_ewe_friesian = animal({
        text = "East Friesian Ewe",
        icon = "Item_SheepWhite_Lamb",
        animal = "ewe",
        breed = "friesian",
        size = "large",
        price = "animal_rare",
        weight = 0.7
    }),

    -- =========================================================
    -- CATTLE
    -- =========================================================
    animal_calf_angus = animal({
        text = "Angus Calf",
        icon = "Item_CowBlack_Calf",
        animal = "cowcalf",
        breed = "angus",
        size = "large",
        price = "animal_rare",
        weight = 0.8
    }),
    animal_cow_angus = animal({
        text = "Angus Cow",
        icon = "Item_CowBlack_Dead",
        animal = "cow",
        breed = "angus",
        size = "large",
        price = "animal_premium",
        weight = 0.5
    }),
    animal_bull_angus = animal({
        text = "Angus Bull",
        icon = "Item_CowBlackMale_Dead",
        animal = "bull",
        breed = "angus",
        size = "large",
        price = "animal_premium",
        weight = 0.4
    }),
    animal_calf_holstein = animal({
        text = "Holstein Calf",
        icon = "Item_CowSpotted_Calf",
        animal = "cowcalf",
        breed = "holstein",
        size = "large",
        price = "animal_rare",
        weight = 0.8
    }),
    animal_cow_holstein = animal({
        text = "Holstein Cow",
        icon = "Item_CowBlackWhite_Dead",
        animal = "cow",
        breed = "holstein",
        size = "large",
        price = "animal_premium",
        weight = 0.5
    }),
    animal_calf_simmental = animal({
        text = "Simmental Calf",
        icon = "Item_CowBrown_Calf",
        animal = "cowcalf",
        breed = "simmental",
        size = "large",
        price = "animal_rare",
        weight = 0.8
    }),
    animal_cow_simmental = animal({
        text = "Simmental Cow",
        icon = "Item_CowBrown_Dead",
        animal = "cow",
        breed = "simmental",
        size = "large",
        price = "animal_premium",
        weight = 0.5
    }),

    -- =========================================================
    -- TURKEYS (small/medium)
    -- =========================================================
    animal_turkeyhen = animal({
        text = "Turkey Hen",
        icon = "Item_TurkeyHen",
        animal = "turkeyhen",
        breed = "meleagris",
        size = "small",
        price = "animal_common",
        weight = 0.9
    }),
    animal_turkeytom = animal({
        text = "Turkey Tom",
        icon = "Item_Turkey",
        animal = "gobblers",
        breed = "meleagris",
        size = "small",
        price = "animal_common",
        weight = 0.8
    }),
    animal_turkeypoult = animal({
        text = "Turkey Poult",
        icon = "Item_TurkeyPoult",
        animal = "turkeypoult",
        breed = "meleagris",
        size = "small",
        price = "animal_cheap",
        weight = 1.0,
        stockMax = 3
    })
}
