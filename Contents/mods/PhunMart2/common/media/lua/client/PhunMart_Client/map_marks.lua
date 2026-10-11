if isServer() then
    return
end

-- A mark on the player's world map for every machine they have shopped at.
--
-- The world map's annotations do not belong to the map window. They live on
-- MapItem.getSingleton(), the same store the window and the minimap both point
-- at, and it is saved with the world. The symbols API is only reachable through
-- a UIWorldMap, so one is built headless here, the way vanilla builds one to
-- measure stash maps, and pointed at that store. A symbol added through it shows
-- up in the map window whether or not the window has been opened yet.
--
-- The server decides whether marks exist at all and whether they cost a writing
-- tool (sandbox MarkShopsOnMap). The player decides whether they want them, in
-- what colour, and whether the shop's name is written beside the symbol.
--
-- Each machine is marked once per character. The key goes in the player's
-- modData once the mark is made, so a player who deletes a mark they did not
-- want does not get it back on their next visit. A visit that could not be
-- marked, for want of a pen, records nothing, and the next visit tries again.
--
-- The mark is private. It is the player's own note, made for them, and never
-- shared to a faction or safehouse unless they share it themselves.

local Core = PhunMart

local SYMBOL = "DollarSign"
local MODDATA_KEY = "PhunMart_MapMarks"

-- Sandbox MarkShopsOnMap
local MODE_DISABLED = 1
local MODE_NEEDS_TOOL = 2

-- Machines within this many tiles of a marked one share its mark.
local CLUSTER_RADIUS = 8
-- Sizes relative to the map at 100% on the player's size sliders. The symbol
-- matches one placed by hand; the default note font is far larger than a
-- symbol, so the label sits well below it.
local SYMBOL_SCALE = ISMap and ISMap.SCALE or 0.666
local LABEL_SCALE = 0.2

-- What the map window accepts as something to write with (ISWorldMapSymbols).
local WRITING_TOOLS = {"Pen", "Pencil", "RedPen", "BluePen", "GreenPen"}

---------------------------------------------------------------------------
-- Player options
---------------------------------------------------------------------------

-- Added to the page looks.lua creates, under Options > Mods.
local options = PZAPI.ModOptions:getOptions("PhunMart") or
                    PZAPI.ModOptions:create("PhunMart", getText("IGUI_PhunMart_Opt_Title"))
options:addSeparator()
options:addTitle(getText("IGUI_PhunMart_Opt_MapTitle"))
options:addTickBox("mapMarks", getText("IGUI_PhunMart_Opt_MapMarks"), true,
    getText("IGUI_PhunMart_Opt_MapMarks_tooltip"))
options:addTickBox("mapLabels", getText("IGUI_PhunMart_Opt_MapLabels"), true,
    getText("IGUI_PhunMart_Opt_MapLabels_tooltip"))
options:addSlider("mapSymbolSize", getText("IGUI_PhunMart_Opt_MapSymbolSize"), 50, 300, 10, 100,
    getText("IGUI_PhunMart_Opt_MapSymbolSize_tooltip"))
options:addSlider("mapLabelSize", getText("IGUI_PhunMart_Opt_MapLabelSize"), 50, 300, 10, 100,
    getText("IGUI_PhunMart_Opt_MapLabelSize_tooltip"))
options:addColorPicker("mapColor", getText("IGUI_PhunMart_Opt_MapColor"), 0.06, 0.39, 0.17, 1.0,
    getText("IGUI_PhunMart_Opt_MapColor_tooltip"))
-- looks.lua has already loaded saved values, before these options existed.
PZAPI.ModOptions:load()

local function optionOn(id)
    local o = options:getOption(id)
    return o == nil or o:getValue() ~= false
end

-- A size slider as a multiplier: 100 is 1.0.
local function optionSize(id)
    local o = options:getOption(id)
    local v = o and tonumber(o:getValue())
    if not v or v <= 0 then
        return 1.0
    end
    return v / 100
end

local function optionColor()
    local o = options:getOption("mapColor")
    local c = o and o:getValue()
    if not c then
        return 0.06, 0.39, 0.17
    end
    return c.r, c.g, c.b
end

---------------------------------------------------------------------------
-- Map
---------------------------------------------------------------------------

local symbolsAPI = nil

local function getSymbolsAPI()
    if symbolsAPI then
        return symbolsAPI
    end
    local mapItem = MapItem.getSingleton()
    if not mapItem then
        return nil
    end
    local ui = {}
    ui.javaObject = UIWorldMap.new(ui)
    ui.mapAPI = ui.javaObject:getAPIv3()
    ui.mapAPI:setMapItem(mapItem)
    symbolsAPI = ui.mapAPI:getSymbolsAPIv2()
    return symbolsAPI
end

local function hasWritingTool(player)
    local inv = player:getInventory()
    for _, item in ipairs(WRITING_TOOLS) do
        if inv:containsTagRecurse(ItemTag.get(ResourceLocation.of(item))) or inv:containsTypeRecurse(item) then
            return true
        end
    end
    return false
end

-- The first of our symbols within `radius` tiles of the spot, placed by this
-- file or by the player's own hand.
local function findMark(api, x, y, radius)
    for i = 0, api:getSymbolCount() - 1 do
        local sym = api:getSymbolByIndex(i)
        if sym:isTexture() and sym:getSymbolID() == SYMBOL and math.abs(sym:getWorldX() - x) <= radius and
            math.abs(sym:getWorldY() - y) <= radius then
            return sym
        end
    end
    return nil
end

-- The label this file wrote for a mark: a text symbol on the mark's own point.
local function findLabel(api, x, y)
    for i = 0, api:getSymbolCount() - 1 do
        local sym = api:getSymbolByIndex(i)
        if sym:isText() and math.abs(sym:getWorldX() - x) < 0.01 and math.abs(sym:getWorldY() - y) < 0.01 then
            return sym
        end
    end
    return nil
end

local function listsName(text, name)
    for part in string.gmatch(text, "[^,]+") do
        if part:match("^%s*(.-)%s*$") == name then
            return true
        end
    end
    return false
end

-- The label is sized in world tiles, like the symbol above it, so the two keep
-- their proportions and shrink together as the map zooms out. At the vanilla
-- note scale a shop name covers a city block, hence the much smaller scale.
-- A fixed size on screen was tried and dropped: the engine stores a symbol's
-- min zoom but never reads it, so nothing hid the label when zoomed far out.
local function addLabel(api, name, x, y, r, g, b)
    local text = api:addUntranslatedText(name, api:getDefaultTextLayerID(), x, y)
    text:setRGBA(r, g, b, 1.0)
    text:setAnchor(0.5, 0.0)
    text:setScale(LABEL_SCALE * optionSize("mapLabelSize"))
    return text
end

-- Returns true once the machine has a mark, whether placed now or found there.
local function placeMark(shopObj)
    local api = getSymbolsAPI()
    if not api then
        return false
    end
    -- Centre of the machine's tile.
    local x = shopObj.x + 0.5
    local y = shopObj.y + 0.5
    local name = optionOn("mapLabels") and Core.shopLabel(shopObj.type) or ""

    -- Machines stand in rows. Each one getting its own sign stacks them into
    -- an unreadable pile, so a machine near one already marked joins that
    -- mark and adds its name to the label.
    local mark = findMark(api, x, y, CLUSTER_RADIUS)
    if mark then
        if name ~= "" then
            local mx, my = mark:getWorldX(), mark:getWorldY()
            local label = findLabel(api, mx, my)
            if not label then
                addLabel(api, name, mx, my, mark:getRed(), mark:getGreen(), mark:getBlue())
            else
                local text = label:getUntranslatedText() or ""
                if not listsName(text, name) then
                    label:setUntranslatedText(text == "" and name or (text .. ", " .. name))
                end
            end
        end
        return true
    end

    local r, g, b = optionColor()

    -- The symbol sits on top of the point and the name hangs below it, so the
    -- two stay together at every zoom.
    local sym = api:addTexture(SYMBOL, x, y)
    sym:setRGBA(r, g, b, 1.0)
    sym:setAnchor(0.5, 1.0)
    sym:setScale(SYMBOL_SCALE * optionSize("mapSymbolSize"))

    if name ~= "" then
        addLabel(api, name, x, y, r, g, b)
    end
    return true
end

function Core.markShopOnMap(player, shopObj)
    if not player or not shopObj then
        return
    end
    local mode = Core.getOption("MarkShopsOnMap", MODE_NEEDS_TOOL)
    if mode == MODE_DISABLED or not optionOn("mapMarks") then
        return
    end

    local key = shopObj:getKey()
    local modData = player:getModData()
    modData[MODDATA_KEY] = modData[MODDATA_KEY] or {}
    local marks = modData[MODDATA_KEY]
    if marks[key] then
        return
    end

    if mode == MODE_NEEDS_TOOL and not hasWritingTool(player) then
        return
    end

    local ok, result = pcall(placeMark, shopObj)
    if not ok then
        Core.debugLn("markShopOnMap failed: " .. tostring(result))
    elseif result then
        marks[key] = true
    end
end
