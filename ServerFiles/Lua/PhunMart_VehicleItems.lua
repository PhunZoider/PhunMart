return {{
    abstract = true,
    key = "base-vehicle:basic",
    type = "VEHICLE",
    tab = "Car",
    inventory = {
        min = 1,
        max = 3
    },
    tags = "vehicle-car",
    price = {
        currency = {
            base = 100,
            min = 10,
            max = 50
        }
    }
}, {
    abstract = true,
    key = "base-vehicle:van",
    type = "VEHICLE",
    tab = "Van",
    inventory = {
        min = 1,
        max = 3
    },
    tags = "vehicle-van",
    price = {
        currency = {
            base = 100,
            min = 10,
            max = 50
        }
    }
}, {
    abstract = true,
    key = "base-vehicle:truck",
    type = "VEHICLE",
    tab = "Truck",
    inventory = {
        min = 1,
        max = 3
    },
    tags = "vehicle-truck",
    price = {
        currency = {
            base = 100,
            min = 10,
            max = 50
        }
    }
}, {
    abstract = true,
    key = "base-vehicle:other",
    type = "VEHICLE",
    tab = "Other",
    inventory = {
        min = 1,
        max = 3
    },
    tags = "vehicle-other",
    price = {
        currency = {
            base = 100,
            min = 10,
            max = 50
        }
    }
}, {
    name = "CarTaxi2",
    inherits = "base-vehicle:basic"
}, {
    name = "Van",
    inherits = "base-vehicle:van"
}, {
    name = "TrailerAdvert",
    inherits = "base-vehicle:other"
}, {
    name = "SportsCar",
    inherits = "base-vehicle:basic"
}, {
    name = "PickUpVanMccoy",
    inherits = "base-vehicle:truck"
}, {
    name = "TrailerCover",
    inherits = "base-vehicle:other"
}, {
    name = "SportsCar_ez",
    inherits = "base-vehicle:basic",
    disabled = true
}, {
    name = "SUV",
    inherits = "base-vehicle:truck"
}, {
    name = "ModernCar_ez",
    inherits = "base-vehicle:basic",
    deisabled = true
}, {
    name = "Van_Transit",
    inherits = "base-vehicle:van"
}, {
    name = "Van_MassGenFac",
    inherits = "base-vehicle:van"
}, {
    name = "Van_LectroMax",
    inherits = "base-vehicle:van"
}, {
    name = "PickUpTruckMccoy",
    inherits = "base-vehicle:truck"
}, {
    name = "VanSpiffo",
    inherits = "base-vehicle:van"
}, {
    name = "VanRadio_3N",
    inherits = "base-vehicle:van"
}, {
    name = "PickUpVanLightsPolice",
    inherits = "base-vehicle:basic"
}, {
    name = "ModernCar_Martin",
    inherits = "base-vehicle:basic"
}, {
    name = "Trailer",
    inherits = "base-vehicle:other"
}, {
    name = "86bounderHAzardmaterials",
    inherits = "base-vehicle:other"
}, {
    name = "PickUpTruck",
    inherits = "base-vehicle:truck"
}, {
    name = "CarLightsPolice",
    inherits = "base-vehicle:basic"
}, {
    name = "CarNormal",
    inherits = "base-vehicle:basic"
}, {
    name = "CarLights",
    inherits = "base-vehicle:basic"
}, {
    name = "ModernCar02",
    inherits = "base-vehicle:basic"
}, {
    name = "VanSeats",
    inherits = "base-vehicle:van"
}, {
    name = "SmallCar02",
    inherits = "base-vehicle:basic"
}, {
    name = "CarStationWagon2",
    inherits = "base-vehicle:basic"
}, {
    name = "PickUpTruckLights",
    inherits = "base-vehicle:truck"
}, {
    name = "PickUpVanLights",
    inherits = "base-vehicle:van"
}, {
    name = "PickUpVanLightsFire",
    inherits = "base-vehicle:van"
}, {
    name = "CarStationWagon",
    inherits = "base-vehicle:basic"
}, {
    name = "CarTaxi",
    inherits = "base-vehicle:basic"
}, {
    name = "Van_KnoxDisti",
    inherits = "base-vehicle:basic"
}, {
    name = "StepVan",
    inherits = "base-vehicle:van"
}, {
    name = "PickUpTruckLightsFire",
    inherits = "base-vehicle:basic"
}, {
    name = "OffRoad",
    inherits = "base-vehicle:truck"
}, {
    name = "VanAmbulance",
    inherits = "base-vehicle:van"
}, {
    name = "SmallCar",
    inherits = "base-vehicle:basic"
}, {
    name = "VanSpecial",
    inherits = "base-vehicle:van"
}, {
    name = "ModernCar",
    inherits = "base-vehicle:basic"
}, {
    name = "StepVanMail",
    inherits = "base-vehicle:van"
}, {
    name = "PickUpVan",
    inherits = "base-vehicle:basic"
}, {
    name = "CarLuxury",
    inherits = "base-vehicle:basic"
}, {
    name = "StepVan_Heralds",
    inherits = "base-vehicle:van"
}, {
    name = "StepVan_Scarlet",
    inherits = "base-vehicle:van"
}, {
    name = "VanRadio",
    inherits = "base-vehicle:van"
}}
