return {
    bat = {

        enabled = true,
        mods = {
            require = {},
            forbid = {}
        },
        display = {
            item = "Base.BaseballBat", -- used for UI icon fallback
            overlay = nil,
            text = nil,
            texture = nil
        },

        actions = {{
            type = "giveItem",
            item = "Base.BaseballBat"
        } -- default amount=1
        }
    },

    bat_bundle = {
        display = {
            item = "Base.BaseballBat"
        },
        actions = {{
            type = "giveItem",
            item = "Base.BaseballBat",
            amount = 1
        }, {
            type = "giveItem",
            item = "Base.Nails",
            amount = 25
        }}
    },

    remove_smoker = {
        display = {
            text = "Remove Smoker"
        },
        actions = {{
            type = "removeTrait",
            trait = "Smoker"
        }}
    },

    spawn_van = {
        display = {
            text = "Van"
        },
        actions = {{
            type = "spawnVehicle",
            script = "Base.Van",
            args = {
                condition = 80,
                fuel = 0.2
            }
        }}
    }
}
