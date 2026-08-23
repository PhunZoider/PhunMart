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

-- The order the four tiles are read in. ServerObject:getSpriteIndex maps
-- E to 1, S to 2, W to 3 and anything else to 4, so the list is not the
-- compass order anyone would guess and the fields say which is which.
local FACINGS = {"IGUI_PhunMart_Wiz_East", "IGUI_PhunMart_Wiz_South", "IGUI_PhunMart_Wiz_West",
                 "IGUI_PhunMart_Wiz_North"}

--- The texture for one tile name, or nil when nothing matches. Guarded because
--- the sprite manager is the game's, not ours, and an unknown name from a mod
--- that is not loaded should show an empty frame rather than end the wizard.
local function tileTexture(name)
    if not name or name == "" then
        return nil
    end
    local ok, tex = pcall(function()
        local spr = IsoSpriteManager.instance:getSprite(name)
        return spr and spr:getTextureForCurrentFrame(IsoDirections.S) or nil
    end)
    return ok and tex or nil
end

local function backgroundTexture(name)
    if not name or name == "" then
        return nil
    end
    local ok, tex = pcall(getTexture, "media/textures/" .. name)
    return ok and tex or nil
end

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

--- A sandbox value if it is readable, otherwise the shipped default. Read here
--- rather than written into a hint so the number an admin sees is the one their
--- server is actually using.
local function sandbox(key, fallback)
    local v = Core.settings and Core.settings[key]
    if v == nil and SandboxVars and SandboxVars.PhunMart then
        v = SandboxVars.PhunMart[key]
    end
    return v or fallback
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

--- Which price to start on. Alphabetical order put animals_cheap first, which
--- is a strange thing to suggest as a shop's default. currency_mid is the
--- middle of the shipped ladder and the least surprising starting point.
local function defaultPrice(prices)
    for _, preferred in ipairs({"currency_mid", "currency_low", "currency_base"}) do
        for _, k in ipairs(prices) do
            if k == preferred then
                return k
            end
        end
    end
    return prices[1]
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

    sendClientCommand(Core.name, Core.commands.upsertShopDefinition, {
        type = key,
        title = values.name,
        category = values.category,
        probability = values.probability,
        minDistance = values.minDistance,
        background = values.background,
        sprites = values.sprites,
        -- Left off entirely when there are none. A machine that does not need
        -- power has nothing to draw in its unpowered state, and an empty list
        -- would be stored as a real, wrong answer.
        unpoweredSprites = (values.unpoweredSprites and #values.unpoweredSprites > 0) and values.unpoweredSprites or
            nil,
        restockFrequency = values.restockFrequency,
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
-- Reading the form
---------------------------------------------------------------------------

-- Every dropdown here ends with this, so an admin shipping their own tileset
-- or artwork is not limited to what happens to be in the base mod.
local OTHER = "IGUI_PhunMart_Wiz_Other"

local function isOther(value)
    return value == getText(OTHER)
end

--- Comma-separated names into a trimmed list, skipping blanks so a trailing
--- comma or a double one does not become an empty tile name.
local function parseCsv(text)
    local out = {}
    for s in tostring(text or ""):gmatch("[^,]+") do
        s = s:match("^%s*(.-)%s*$")
        if s ~= "" then
            table.insert(out, s)
        end
    end
    return out
end

--- A combo's value, unless it is the Other entry, in which case whatever was
--- typed into the companion field.
local function pickOrCustom(form, comboKey, textKey)
    local chosen = form:getFieldValue(comboKey)
    if isOther(chosen) then
        local typed = form:getFieldValue(textKey)
        return (typed ~= "") and typed or nil
    end
    return chosen
end

--- The four tile names for one state of the machine. A named set expands from
--- its first tile; Other reads the comma-separated field, which may be empty
--- for unpowered because that art is optional.
local function chosenSprites(form, tileByLabel, which)
    if isOther(form:getFieldValue("appearance")) then
        return parseCsv(form:getFieldValue(which == "sprites" and "spritesCsv" or "unpoweredCsv"))
    end
    local powered, unpowered = spritesFrom(tileByLabel[form:getFieldValue("appearance")] or "phunmart_01_0")
    return which == "sprites" and powered or unpowered
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

    -- Last on every list, so what already exists reads as the suggestion and
    -- bringing your own is the deliberate choice rather than the first thing
    -- you trip over.
    table.insert(appearances, getText(OTHER))
    table.insert(backgrounds, getText(OTHER))
    table.insert(categories, getText(OTHER))

    local form
    form = FormPanel:new({
        width = math.floor(420 * FONT_SCALE),
        title = getText("IGUI_PhunMart_Wiz_NewShop"),
        onApply = function(f)
            local name = f:getFieldValue("name")
            local rollLo, rollHi = f:getFieldRange("roll")
            local groupKey = create({
                key = keyFromName(name),
                name = name,
                category = pickOrCustom(f, "category", "categoryOther"),
                probability = math.floor(f:getFieldNumber("probability") or 15),
                minDistance = f:getFieldNumber("minDistance"),
                background = pickOrCustom(f, "background", "backgroundOther"),
                sprites = chosenSprites(f, tileByLabel, "sprites"),
                unpoweredSprites = chosenSprites(f, tileByLabel, "unpowered"),
                price = f:getFieldValue("price"),
                restockFrequency = f:getFieldNumber("restockFrequency"),
                rollMin = math.floor(rollLo or 4),
                rollMax = math.floor(rollHi or 8)
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
    -- Category is a real question again: placement now keeps two shops of the
    -- same category apart, not just two of the same type. Two food machines on
    -- one street was the thing minDistance was meant to prevent.
    form:addComboField("category", getText("IGUI_PhunMart_Lbl_Category"), {
        options = categories,
        selected = categories[1],
        hint = getText("IGUI_PhunMart_Wiz_Hint_Category"),
        group = "w_name",
        onChange = function(f)
            f:setFieldVisible("categoryOther", isOther(f:getFieldValue("category")))
        end
    })
    form:addTextField("categoryOther", getText("IGUI_PhunMart_Wiz_Lbl_Other"), {
        default = "",
        hint = getText("IGUI_PhunMart_Wiz_Hint_CategoryOther"),
        group = "w_name",
        conditional = true
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
        group = "w_look",
        onChange = function(f)
            local other = isOther(f:getFieldValue("appearance"))
            f:setFieldVisible("spritesCsv", other)
            f:setFieldVisible("unpoweredCsv", other)
        end
    })
    -- Eight fields for an admin who has packed their own tileset. Only the
    -- powered four are required: a machine that needs no power has no unpowered
    -- state to draw.
    -- Two comma-separated fields rather than eight boxes. Eight made the step
    -- taller than the screen at some resolutions, which pushed the unpowered
    -- ones out of sight and made them look broken. The preview below carries
    -- the facing labels, so nothing is lost by not naming each box, and this
    -- matches how the existing shop editor already takes its sprite lists.
    form:addTextField("spritesCsv", getText("IGUI_PhunMart_Wiz_Lbl_Sprites"), {
        default = "",
        hint = getText("IGUI_PhunMart_Wiz_Hint_Sprites"),
        group = "w_look",
        conditional = true,
        validate = function(value, f)
            if not isOther(f:getFieldValue("appearance")) then
                return nil
            end
            local n = #parseCsv(value)
            if n == 0 then
                return getText("IGUI_PhunMart_Err_Required")
            end
            if n ~= 4 then
                return getText("IGUI_PhunMart_Wiz_Err_FourTiles", tostring(n))
            end
        end
    })
    form:addTextField("unpoweredCsv", getText("IGUI_PhunMart_Wiz_Lbl_Unpowered"), {
        default = "",
        hint = getText("IGUI_PhunMart_Wiz_Hint_Unpowered"),
        group = "w_look",
        conditional = true,
        validate = function(value, f)
            if not isOther(f:getFieldValue("appearance")) then
                return nil
            end
            local n = #parseCsv(value)
            if n > 0 and n ~= 4 then
                return getText("IGUI_PhunMart_Wiz_Err_FourTiles", tostring(n))
            end
        end
    })
    -- Shown whatever the choice: the point of a preview is to confirm the set
    -- is the one you meant, which matters most when you typed the names.
    form:addImageField("spritePreview", getText("IGUI_PhunMart_Wiz_Lbl_Preview"), {
        group = "w_look",
        images = function()
            local out = {}
            for i, name in ipairs(chosenSprites(form, tileByLabel, "sprites") or {}) do
                table.insert(out, {
                    texture = tileTexture(name),
                    label = getText(FACINGS[i] or "")
                })
            end
            -- Unpowered on the same row, after a gap. A second row would have
            -- cost the height this step was already short of, and the two sets
            -- read as a pair anyway: same four facings, lights off.
            for i, name in ipairs(chosenSprites(form, tileByLabel, "unpowered") or {}) do
                table.insert(out, {
                    texture = tileTexture(name),
                    label = getText(FACINGS[i] or ""),
                    gap = (i == 1)
                })
            end
            return out
        end
    })
    form:addComboField("background", getText("IGUI_PhunMart_Wiz_Lbl_Background"), {
        options = backgrounds,
        selected = backgrounds[1],
        hint = getText("IGUI_PhunMart_Wiz_Hint_Background"),
        group = "w_look",
        onChange = function(f)
            f:setFieldVisible("backgroundOther", isOther(f:getFieldValue("background")))
        end
    })
    form:addTextField("backgroundOther", getText("IGUI_PhunMart_Wiz_Lbl_Other"), {
        default = "",
        hint = getText("IGUI_PhunMart_Wiz_Hint_BackgroundOther"),
        group = "w_look",
        conditional = true
    })
    form:addImageField("backgroundPreview", getText("IGUI_PhunMart_Wiz_Lbl_Preview"), {
        group = "w_look",
        height = math.floor(72 * FONT_SCALE),
        images = function()
            return {{
                texture = backgroundTexture(pickOrCustom(form, "background", "backgroundOther"))
            }}
        end
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
    -- One number, checked twice: against the nearest machine of this same type
    -- and against the nearest of anything sharing its category. Blank rather
    -- than 300, because blank falls back to the DefaultDistance sandbox
    -- setting, which is the better answer until someone has a reason to differ.
    form:addTextField("minDistance", getText("IGUI_PhunMart_Wiz_Lbl_MinDistance"), {
        default = "",
        -- The sandbox value goes in the hint rather than into the box: leaving
        -- it blank means "follow the setting" and pre-filling the number would
        -- pin it to today's value forever.
        hint = getText("IGUI_PhunMart_Wiz_Hint_MinDistance", tostring(sandbox("DefaultDistance", 200))),
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
        selected = defaultPrice(prices),
        hint = getText("IGUI_PhunMart_Wiz_Hint_Price"),
        group = "w_stock"
    })
    form:addTextField("restockFrequency", getText("IGUI_PhunMart_Wiz_Lbl_Restock"), {
        default = "",
        hint = getText("IGUI_PhunMart_Wiz_Hint_Restock", tostring(sandbox("DefaultHoursToRestock", 72))),
        group = "w_stock",
        integer = true,
        min = 1
    })
    -- One range rather than two stacked boxes. It is a span, and stacking made
    -- the second look like a separate question.
    form:addRangeField("roll", getText("IGUI_PhunMart_Wiz_Lbl_Roll"), {
        minDefault = "4",
        maxDefault = "8",
        hint = getText("IGUI_PhunMart_Wiz_Hint_Roll"),
        group = "w_stock",
        integer = true,
        min = 0,
        requireBoth = true
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

    -- Nothing starts on Other, so none of the fields it reveals should be on
    -- screen. They stay hidden until a combo asks for them, and stepping leaves
    -- that decision alone.
    form:setFieldVisible("backgroundOther", false)
    form:setFieldVisible("spritesCsv", false)
    form:setFieldVisible("unpoweredCsv", false)

    form:initialise()
    form:addToUIManager()
    form:bringToTop()
    return form
end

Core.ui.shop_wizard = ShopWizard
return ShopWizard
