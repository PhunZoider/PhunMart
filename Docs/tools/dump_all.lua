--[[
    PhunMart2 - Data Dump Tool
    ===========================
    The actual tool lives at:
        Contents/mods/PhunMart2/common/media/lua/client/PhunMart2/tools/dump_all.lua

    It loads automatically with the mod and adds the admin chat command:

        /dumppz [all|perks|traits|categories|items|vehicles]

    Output files are written to:
        Windows: C:\Users\<you>\Zomboid\Lua\PhunMart2_dump_<name>.lua
        Linux:   ~/Zomboid/Lua/PhunMart2_dump_<name>.lua

    Files produced:
        PhunMart2_dump_perks.lua        -- perk index, key, display name, hasIcon
        PhunMart2_dump_traits.lua       -- trait key, display name, description
        PhunMart2_dump_categories.lua   -- unique item display categories (sorted)
        PhunMart2_dump_items.lua        -- all items: id, name, category, type
        PhunMart2_dump_vehicles.lua     -- all vehicle script names
--]]
