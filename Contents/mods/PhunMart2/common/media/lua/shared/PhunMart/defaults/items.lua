return {

    -- =========================================================
    -- VEHICLE OFFER ITEMS
    -- stock=1 with long restock keeps vehicles feeling rare
    -- =========================================================
    --
    -- These exist to put one vehicle in a different CLASS from the rest of its
    -- group: CarStationWagon leaves the small-car class, PickUpTruck leaves the
    -- van class. See the comment above the vehicles_* groups in groups.lua for
    -- what a class supplies and what it does not.
    --
    -- The entries below that name the same reward their group already defaults
    -- to, SmallCar and SmallCar02 among them, are doing nothing. They are left
    -- alone only because removing a shipped default is a migration rather than
    -- a deletion.
    --
    -- Every entry in this file is a vehicle, which makes the tab look like a
    -- vehicle mapping table. It is not. An item override adjusts the price,
    -- weight or stock of any single item an offer is built from, most usefully
    -- one a group pulled in by category, and nothing shipped demonstrates that.

    SmallCar = {
        price = "vehicle_common",
        reward = "vehicle_smallcar",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    SmallCar02 = {
        price = "vehicle_common",
        reward = "vehicle_smallcar",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    CarNormal = {
        price = "vehicle_uncommon",
        reward = "vehicle_normalcar",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    ModernCar = {
        price = "vehicle_uncommon",
        reward = "vehicle_normalcar",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    ModernCar02 = {
        price = "vehicle_uncommon",
        reward = "vehicle_normalcar",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    CarStationWagon = {
        price = "vehicle_uncommon",
        reward = "vehicle_stationwagon",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    CarLuxury = {
        price = "vehicle_rare",
        reward = "vehicle_luxury",
        offer = {
            weight = 0.5,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    SportsCar = {
        price = "vehicle_rare",
        reward = "vehicle_sportscar",
        offer = {
            weight = 0.5,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    SUV = {
        price = "vehicle_uncommon",
        reward = "vehicle_suv",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    OffRoad = {
        price = "vehicle_uncommon",
        reward = "vehicle_offroad",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    PickUpTruck = {
        price = "vehicle_uncommon",
        reward = "vehicle_pickup",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    PickUpVan = {
        price = "vehicle_uncommon",
        reward = "vehicle_pickup",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    Van = {
        price = "vehicle_common",
        reward = "vehicle_van",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    VanSeats = {
        price = "vehicle_common",
        reward = "vehicle_van",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    },
    StepVan = {
        price = "vehicle_common",
        reward = "vehicle_stepvan",
        offer = {
            weight = 1.0,
            stock = {
                min = 1,
                max = 1
            }
        }
    }

    -- XP and boost offer items are defined in PhunMart_XP_Items.json (generated)

}
