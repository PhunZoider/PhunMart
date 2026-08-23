if isServer() then
    return
end

-- Guided creation of a new shop type.
--
-- Until now there was no way to create one at all: AdminShops.OnOpenPanel
-- returns early unless the shop already exists, and the Shops list had no New
-- button. The server has always accepted a new key; nothing ever offered one.
--
-- A shop is not one definition, it is three. The machine needs a pool to draw
-- from, and the pool needs a group to gather items. Asking someone to create
-- those in the right order, in three different tabs, before anything appears in
-- the world is the "obtuse and klunky" complaint in its purest form. So the
-- wizard writes all three and finishes by opening the group, which is the only
-- one with a question still outstanding: what does it sell?

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
local PendingRestock = require "PhunMart_Client/ui/admin/pending_restock"

local FONT_SCALE = ListPanel.FONT_SCALE

local ShopWizard = {}

---------------------------------------------------------------------------
-- Appearance
--
-- A machine needs four powered tiles and four unpowered ones, taken as a block
-- of eight: the first four lit, the last four dark. Every shipped shop follows
-- that, so a spare block is describable by its first tile alone.
---------------------------------------------------------------------------

local SPARE_SETS = {{
    first = "phunmart_01_0",
    label = "Generic machine"
}, {
    first = "phunmart_01_16"
}, {
    first = "phunmart_02_48"
}, {
    first = "phunmart_02_56"
}, {
    first = "phunmart_03_16"
}, {
    first = "phunmart_03_40"
}, {
    first = "phunmart_03_48"
}, {
    first = "phunmart_03_56"
}}

--- Expand a first-tile name into the eight the shop definition needs.
--- Returns powered, unpowered, or nil when the name is not of the form
--- <sheet>_<index>.
local function spritesFrom(firstTile)
    local sheet, idx = tostring(firstTile or ""):match("^(.+)_(%d+)$")
    if not sheet then
        return nil
    end
    idx = tonumber(idx)
    local powered, unpowered = {}, {}
    for i = 0, 3 do
        table.insert(powered, sheet .. "_" .. tostring(idx + i))
        table.insert(unpowered, sheet .. "_" .. tostring(idx + 4 + i))
    end
    return powered, unpowered
end

--- Every appearance on offer: the spare tile blocks, then each existing shop
--- to copy. Copying is listed because it is what an admin with no spare art
--- would do anyway, and it is better to offer it than to have them discover
--- that the wizard cannot help.
local function appearanceOptions()
    local opts, byLabel = {}, {}

    for i, set in ipairs(SPARE_SETS) do
        local label = set.label or getText("IGUI_PhunMart_Wiz_SpareSet", tostring(i))
        table.insert(opts, label)
        byLabel[label] = set.first
    end

    local shops = Core.defs and Core.defs.shops or {}
    local keys = {}
    for k in pairs(shops) do
        table.insert(keys, k)
    end
    table.sort(keys)
    for _, k in ipairs(keys) do
        local def = shops[k]
        if def.sprites and def.sprites[1] then
            local name = Core.shopLabel(k)
            local label = getText("IGUI_PhunMart_Wiz_LooksLike", name)
            table.insert(opts, label)
            byLabel[label] = def.sprites[1]
        end
    end

    return opts, byLabel
end

local function backgroundOptions()
    local seen, opts = {}, {}
    for _, def in pairs(Core.defs and Core.defs.shops or {}) do
        if def.background and not seen[def.background] then
            seen[def.background] = true
            table.insert(opts, def.background)
        end
    end
    table.sort(opts)
    return opts
end

---------------------------------------------------------------------------
-- Keys
---------------------------------------------------------------------------

--- "Bob's Bait Shop" becomes "BobsBaitShop", matching how every shipped shop
--- is keyed. Editable afterwards, because a derived key is a guess.
local function keyFromName(name)
    local out = (name or ""):gsub("[^%w%s]", ""):gsub("%s+(%w)", function(c)
        return c:upper()
    end):gsub("%s", "")
    return (out:gsub("^%l", string.upper))
end

local function categoryOptions()
    local seen, opts = {}, {}
    for _, def in pairs(Core.defs and Core.defs.shops or {}) do
        if def.category and not seen[def.category] then
            seen[def.category] = true
            table.insert(opts, def.category)
        end
    end
    table.sort(opts)
    return opts
end

local function priceOptions()
    local opts = {}
    for k in pairs(Core.defs and Core.defs.prices or {}) do
        table.insert(opts, k)
    end
    table.sort(opts)
    return opts
end

---------------------------------------------------------------------------
-- Creation
---------------------------------------------------------------------------

--- Write the three definitions and hand back the group key so the caller can
--- open it. Order matters only for readability; the server recompiles after
--- each one and an intermediate state referencing a group that does not exist
--- yet just logs a warning on that pass.
local function create(values)
    local key = values.key
    local groupKey = key:lower() .. "_items"
    local poolKey = "pool_" .. key:lower()

    sendClientCommand(Core.name, Core.commands.upsertGroupDef, {
        key = groupKey,
        def = {
            title = getText("IGUI_PhunMart_Wiz_GroupTitle", values.name),
            label = values.name,
            items = {}
        }
    })

    sendClientCommand(Core.name, Core.commands.upsertPoolDef, {
        key = poolKey,
        def = {
            title = getText("IGUI_PhunMart_Wiz_PoolTitle", values.name),
            sources = {
                groups = {groupKey}
            }
        }
    })

    local powered, unpowered = spritesFrom(values.firstTile)
    sendClientCommand(Core.name, Core.commands.upsertShopDefinition, {
        type = key,
        title = values.name,
        category = values.category,
        probability = values.probability,
        minDistance = values.minDistance,
        background = values.background,
        sprites = powered,
        unpoweredSprites = unpowered,
        roll = {
            mode = "weighted",
            count = {
                min = values.rollMin,
                max = values.rollMax
            }
        },
        poolSets = {{
            price = values.price,
            keys = {{
                key = poolKey,
                weight = 1.0
            }}
        }}
    })

    PendingRestock.note("shops", key)
    return groupKey
end

---------------------------------------------------------------------------
-- The form
---------------------------------------------------------------------------

function ShopWizard.open(player, onDone)
    local shops = Core.defs and Core.defs.shops or {}
    local appearances, tileByLabel = appearanceOptions()
    local backgrounds = backgroundOptions()
    local categories = categoryOptions()
    local prices = priceOptions()

    local form
    form = FormPanel:new({
        width = math.floor(420 * FONT_SCALE),
        title = getText("IGUI_PhunMart_Wiz_NewShop"),
        onApply = function(f)
            local name = f:getFieldValue("name")
            local groupKey = create({
                key = keyFromName(name),
                name = name,
                category = f:getFieldValue("category"),
                probability = math.floor(f:getFieldNumber("probability") or 15),
                minDistance = f:getFieldNumber("minDistance") or 300,
                background = f:getFieldValue("background"),
                firstTile = tileByLabel[f:getFieldValue("appearance")] or "phunmart_01_0",
                price = f:getFieldValue("price"),
                rollMin = math.floor(f:getFieldNumber("rollMin") or 4),
                rollMax = math.floor(f:getFieldNumber("rollMax") or 8)
            })
            f:close()
            if onDone then
                onDone(groupKey)
            end
        end
    })

    ---------------------------------------------------------------- step 1
    form:addSeparator("s_name", {
        text = getText("IGUI_PhunMart_Wiz_Step_Name"),
        group = "w_name"
    })
    -- No key field. Every shipped shop is keyed from its name anyway, and a key
    -- is an implementation detail that a first shop should not have to have an
    -- opinion about. It is derived here and shown in the Shops list straight
    -- afterwards, since that column already puts the key beside the name.
    form:addTextField("name", getText("IGUI_PhunMart_Wiz_Lbl_Name"), {
        default = "",
        hint = getText("IGUI_PhunMart_Wiz_Hint_Name"),
        group = "w_name",
        required = true,
        validate = function(value)
            local key = keyFromName(value)
            if key == "" then
                return getText("IGUI_PhunMart_Wiz_Err_NameChars")
            end
            if shops[key] then
                return getText("IGUI_PhunMart_Wiz_Err_NameTaken", key)
            end
        end
    })
    form:addComboField("category", getText("IGUI_PhunMart_Lbl_Category"), {
        options = categories,
        selected = categories[1],
        hint = getText("IGUI_PhunMart_Wiz_Hint_Category"),
        group = "w_name"
    })

    ---------------------------------------------------------------- step 2
    form:addSeparator("s_look", {
        text = getText("IGUI_PhunMart_Wiz_Step_Look"),
        group = "w_look"
    })
    form:addComboField("appearance", getText("IGUI_PhunMart_Wiz_Lbl_Appearance"), {
        options = appearances,
        selected = appearances[1],
        hint = getText("IGUI_PhunMart_Wiz_Hint_Appearance"),
        group = "w_look"
    })
    form:addComboField("background", getText("IGUI_PhunMart_Wiz_Lbl_Background"), {
        options = backgrounds,
        selected = backgrounds[1],
        hint = getText("IGUI_PhunMart_Wiz_Hint_Background"),
        group = "w_look"
    })

    ---------------------------------------------------------------- step 3
    form:addSeparator("s_world", {
        text = getText("IGUI_PhunMart_Wiz_Step_World"),
        group = "w_world"
    })
    -- Relative weight, not a percentage: system.lua sums every shop's
    -- probability and rolls against the total. So no upper bound, and 15 is
    -- the shipped default rather than 10.
    form:addTextField("probability", getText("IGUI_PhunMart_Wiz_Lbl_Probability"), {
        default = "15",
        hint = getText("IGUI_PhunMart_Wiz_Hint_Probability"),
        group = "w_world",
        required = true,
        integer = true,
        min = 0
    })
    form:addTextField("minDistance", getText("IGUI_PhunMart_Wiz_Lbl_MinDistance"), {
        default = "300",
        hint = getText("IGUI_PhunMart_Wiz_Hint_MinDistance"),
        group = "w_world",
        integer = true,
        min = 0
    })

    ---------------------------------------------------------------- step 4
    form:addSeparator("s_stock", {
        text = getText("IGUI_PhunMart_Wiz_Step_Stock"),
        group = "w_stock"
    })
    form:addComboField("price", getText("IGUI_PhunMart_Wiz_Lbl_Price"), {
        options = prices,
        selected = prices[1],
        hint = getText("IGUI_PhunMart_Wiz_Hint_Price"),
        group = "w_stock"
    })
    form:addTextField("rollMin", getText("IGUI_PhunMart_Wiz_Lbl_RollMin"), {
        default = "4",
        hint = getText("IGUI_PhunMart_Wiz_Hint_Roll"),
        group = "w_stock",
        integer = true,
        min = 0
    })
    form:addTextField("rollMax", getText("IGUI_PhunMart_Wiz_Lbl_RollMax"), {
        default = "8",
        group = "w_stock",
        integer = true,
        min = 0,
        validate = function(value, f)
            local lo = f:getFieldNumber("rollMin")
            local hi = tonumber(value)
            if lo and hi and hi < lo then
                return getText("IGUI_PhunMart_Wiz_Err_RollOrder")
            end
        end
    })

    form:setSteps({{
        group = "w_name"
    }, {
        group = "w_look"
    }, {
        group = "w_world"
    }, {
        group = "w_stock"
    }})

    form:initialise()
    form:addToUIManager()
    form:bringToTop()
    return form
end

Core.ui.shop_wizard = ShopWizard
return ShopWizard
