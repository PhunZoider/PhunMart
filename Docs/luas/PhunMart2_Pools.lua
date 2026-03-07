return {
    weapons = {
        priority = 10, -- used if shop tries multiple pools and you ever want ordering

        enabled = true,
        mods = {
            forbid = {"SomeOverhaul"}
        },

        defaults = {
            price = "low10",
            offer = {
                weight = 1.0
            }
        },

        sources = {
            groups = {"bats"},
            items = {"Base.Katana"} -- allow direct adds
        },

        gate = {
            zones = {"rosewood", "louisville"}, -- optional
            months = {1, 2, 3} -- optional
            -- future: dayOfWeek, weather, worldAge, sandbox option checks
        },

        roll = {
            -- how selection works for this pool (optional)
            mode = "weighted", -- "all" | "weighted" | "randomN"
            count = 20 -- if randomN, how many offers to pick
        }
    }
}
