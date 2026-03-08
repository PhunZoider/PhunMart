--[[
    PhunMart2 - Data Dump Tool
    ===========================
    Chat command (MP admin):  /dumppz [all|perks|traits|categories|items|vehicles]
    Lua console (SP/debug):   PhunDump.run("all")   or   PhunDump.items() etc.

    Writes Lua-formatted dump files to:
        Windows: C:\Users\<you>\Zomboid\Lua\PhunMart2_dump_<name>.lua
        Linux:   ~/Zomboid/Lua/PhunMart2_dump_<name>.lua
--]] PhunDump = {} -- global so Lua console can call it directly

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function print_chat(msg)
    if getSoundManager then -- client-side guard
        local chat = ISChat.instance
        if chat then
            chat:addLineInChat(ISChat.addLineInChat, "[PhunDump] " .. msg, 0)
        end
    end
    print("[PhunDump] " .. msg)
end

local function writeFile(name, lines)
    local filename = "PhunMart2_dump_" .. name .. ".lua"
    local ok, err = pcall(function()
        local writer = getFileWriter(filename, false, false)
        writer:write(table.concat(lines))
        writer:close()
    end)
    if ok then
        print_chat("Written: " .. filename)
    else
        print_chat("FAILED: " .. filename .. " — " .. tostring(err))
    end
end

local function isAdmin()
    if not isClient() then
        return true
    end -- singleplayer or server console = always ok
    local player = getSpecificPlayer(0)
    if not player then
        return false
    end
    local level = player:getAccessLevel()
    return level == "admin" or level == "moderator"
end

-- ─── Dump routines ───────────────────────────────────────────────────────────

function PhunDump.perks()
    local lines = {"-- PhunMart2 Perk Dump\n",
                   "-- 'key' is tostring(perk:getType()) — use this as your cache/lookup key\n", "return {\n"}
    for i = 0, Perks.getMaxIndex() - 1 do
        local perkEnum = Perks.fromIndex(i)
        local perk = PerkFactory.getPerk(perkEnum)
        if perk then
            local ok, row = pcall(function()
                local key = tostring(perk:getType())
                local name = tostring(perk:getName())
                local isLeaf = tostring(perk:getParent()) ~= tostring(Perks.None)
                return string.format('  { index = %3d, key = %-30s name = %-40s isLeaf = %s },\n', i,
                    string.format("%q,", key), string.format("%q,", name), tostring(isLeaf))
            end)
            if ok then
                lines[#lines + 1] = row
            end
        end
    end
    lines[#lines + 1] = "}\n"
    writeFile("perks", lines)
end

function PhunDump.traits()
    local lines = {"-- PhunMart2 Trait Dump\n", "-- 'key' is trait:getType() — use as lookup key\n",
                   "-- cost > 0 = good trait, cost < 0 = bad trait\n", "return {\n"}
    local ok, err = pcall(function()
        local traits = CharacterTraitDefinition.getTraits()
        for i = 0, traits:size() - 1 do
            local trait = traits:get(i)
            if trait then
                local rok, row = pcall(function()
                    local key = tostring(trait:getType())
                    local name = tostring(trait:getLabel())
                    local cost = trait:getCost()
                    local desc = tostring(trait:getDescription() or "")
                    local tex = trait:getTexture()
                    local texName = tex and tostring(tex:getName()) or ""
                    local disabledMP = trait.isRemoveInMP and trait:isRemoveInMP()
                    desc = desc:gsub("[\r\n]+", " "):gsub("%s+", " "):match("^%s*(.-)%s*$") or ""

                    -- collect mutually exclusive trait keys
                    local mutex = {}
                    local mlist = trait:getMutuallyExclusiveTraits()
                    if mlist then
                        for j = 0, mlist:size() - 1 do
                            local m = mlist:get(j)
                            if m then
                                mutex[#mutex + 1] = string.format("%q", tostring(m))
                            end
                        end
                    end
                    local mutexStr = #mutex > 0 and ("{ " .. table.concat(mutex, ", ") .. " }") or "nil"

                    return string.format(
                        '  { key = %-35s name = %-40s cost = %3d, disabledMP = %-5s texture = %-35s mutex = %s, desc = %q },\n',
                        string.format("%q,", key), string.format("%q,", name), cost, tostring(disabledMP) .. ",",
                        string.format("%q,", texName), mutexStr, desc)
                end)
                if rok then
                    lines[#lines + 1] = row
                end
            end
        end
    end)
    if not ok then
        lines[#lines + 1] = "  -- ERROR: " .. tostring(err) .. "\n"
        print_chat("Trait error: " .. tostring(err))
    end
    lines[#lines + 1] = "}\n"
    writeFile("traits", lines)
end

function PhunDump.categories()
    local lines = {"-- PhunMart2 Item Category Dump\n",
                   "-- Unique display categories across all items, alphabetically sorted\n", "return {\n"}
    local seen, cats = {}, {}
    local items = getScriptManager():getAllItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item then
            local cat = tostring(item:getDisplayCategory() or "None")
            if not seen[cat] then
                seen[cat] = true
                cats[#cats + 1] = cat
            end
        end
    end
    table.sort(cats)
    for _, cat in ipairs(cats) do
        lines[#lines + 1] = string.format("  %q,\n", cat)
    end
    lines[#lines + 1] = "}\n"
    writeFile("categories", lines)
end

function PhunDump.items()
    local items = getScriptManager():getAllItems()
    local total = items:size()
    print_chat("Iterating " .. total .. " items (may take a moment)...")
    local lines = {"-- PhunMart2 Item Dump\n",
                   "-- 'id' is the full script name used with AddItem() and compiler item refs\n", "return {\n"}
    for i = 0, total - 1 do
        local item = items:get(i)
        if item then
            local ok, row = pcall(function()
                local id = tostring(item:getFullName())
                local name = tostring(item:getDisplayName() or "")
                local category = tostring(item:getDisplayCategory() or "None")
                return string.format('  { id = %-55s name = %-40s category = %q },\n', string.format("%q,", id),
                    string.format("%q,", name), category)
            end)
            if ok then
                lines[#lines + 1] = row
            end
        end
    end
    lines[#lines + 1] = "}\n"
    writeFile("items", lines)
end

function PhunDump.vehicles()
    local lines = {"-- PhunMart2 Vehicle Dump\n", "return {\n"}
    local ok, err = pcall(function()
        local scripts = getScriptManager():getAllVehicleScripts()
        for i = 0, scripts:size() - 1 do
            local vs = scripts:get(i)
            if vs then
                lines[#lines + 1] = string.format("  %q,\n", tostring(vs:getName()))
            end
        end
    end)
    if not ok then
        lines[#lines + 1] = "  -- ERROR: " .. tostring(err) .. "\n"
        print_chat("Vehicle error: " .. tostring(err))
    end
    lines[#lines + 1] = "}\n"
    writeFile("vehicles", lines)
end

-- ─── Command dispatch ─────────────────────────────────────────────────────────

local COMMANDS = {
    perks = PhunDump.perks,
    traits = PhunDump.traits,
    categories = PhunDump.categories,
    items = PhunDump.items,
    vehicles = PhunDump.vehicles
}

-- PhunDump.run("all") — callable from Lua console in SP/debug mode
function PhunDump.run(arg)
    if not isAdmin() then
        print_chat("Admin access required.")
        return
    end

    arg = (arg or ""):lower():match("^%s*(.-)%s*$")

    if arg == "" or arg == "all" then
        print_chat("Running full dump...")
        PhunDump.perks()
        PhunDump.traits()
        PhunDump.categories()
        PhunDump.vehicles()
        PhunDump.items() -- largest, run last
        print_chat("Done. Check Zomboid/Lua/ in your user data folder.")
    elseif COMMANDS[arg] then
        print_chat("Dumping " .. arg .. "...")
        COMMANDS[arg]()
        print_chat("Done.")
    else
        print_chat("Unknown target: '" .. arg .. "'. Usage: /dumppz [all|perks|traits|categories|items|vehicles]")
    end
end

-- ─── Chat command hook ────────────────────────────────────────────────────────

local function hookChat()
    local orig = ISChat.onCommandEntered
    ISChat.onCommandEntered = function(self)
        local text = self.chatText.internal or ""
        local cmd, arg = text:match("^(/dumppz)%s*(.*)")
        if cmd then
            runDump(arg)
            -- clear the input without sending to server
            self.chatText:setText("")
            return
        end
        orig(self)
    end
end

Events.OnGameStart.Add(hookChat)
