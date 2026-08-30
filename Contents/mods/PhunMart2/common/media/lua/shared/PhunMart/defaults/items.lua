return {

    -- =========================================================
    -- ITEM OVERRIDES
    -- =========================================================
    --
    -- Ships empty, deliberately.
    --
    -- An entry here adjusts the price, offer weight, stock or conditions of ONE
    -- item, on top of whatever the pool and group it came from already said.
    -- Precedence, lowest first:
    --
    --     pool.defaults -> group.defaults -> the special -> this file
    --
    -- It earns its keep on an item a group pulled in by CATEGORY, where there is
    -- no other way to single one out. Naming an item a group already lists
    -- explicitly is usually the wrong tool: move it to a group whose defaults
    -- say what you want instead, and its siblings come with it.
    --
    -- This file used to hold sixteen vehicle entries and read like a vehicle
    -- mapping table. Ten of them restated their group's defaults word for word.
    -- The other six moved a single script into another price band while the
    -- twenty-odd variants beside it stayed put. Vehicle groups now carry the
    -- band themselves, so all sixteen are gone. See defaults/groups.lua.
    --
    -- Format, for when you do need one:
    --
    --     ["Base.Axe"] = {
    --         price = "tools_expensive",
    --         offer = { weight = 0.25, stock = { min = 1, max = 2 } }
    --     }
    --
    -- XP and boost offer items are defined in PhunMart_XP_Items.json (generated)

}
