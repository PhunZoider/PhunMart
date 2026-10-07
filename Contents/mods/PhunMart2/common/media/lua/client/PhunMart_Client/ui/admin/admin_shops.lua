if isServer() then
    return
end

local Core = PhunMart
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
local KeyPicker = require "PhunMart_Client/ui/base/key_picker"
local PendingRestock = require "PhunMart_Client/ui/admin/pending_restock"
local tools = require "PhunMart_Client/ui/ui_utils"

local FONT_SCALE = FormPanel.FONT_SCALE
local FACINGS = tools.TILE_FACINGS
local tileTexture = tools.tileTexture

Core.ui.admin_shops = {}
local AdminShops = Core.ui.admin_shops

---------------------------------------------------------------------------
-- Pool Set Helpers
---------------------------------------------------------------------------

-- Get sorted pool definition keys for the picker.
local function getPoolKeys()
    local pools = Core.defs and Core.defs.pools or require "PhunMart/defaults/pools"
    local keys = {}
    for k in pairs(pools) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

-- The last entry on the category combo, so a name the mod has never seen is
-- still reachable. Same string and same behaviour as the wizard's dropdowns.
local OTHER = "IGUI_PhunMart_Wiz_Other"

local function isOther(value)
    return value == getText(OTHER)
end

-- Categories already in use. Blank leads, because a shop is allowed to have
-- none, and Other trails, so bringing your own reads as the deliberate choice.
-- `current` is folded in for a shop read from the runtime fallback, which may
-- name a category no definition still declares.
--- A texture as the dropdown names it: "phunmart/zetsy.png" and "zetsy" are the
--- same file, and showing the long form beside the short one reads as two.
local function shortTexture(name)
    if type(name) ~= "string" or name == "" or not Core.looks then
        return name
    end
    local path = Core.looks.findTexture(name)
    return path and Core.looks.shortName(path) or name
end

-- Machine textures to pick from (client looks.lua), with `current` folded in when
-- it is not one of them, so a shop naming its texture some other way still shows
-- what it has. Blank leads: no 3D texture, the machine stays on its tiles.
local function getTextureKeys(current)
    current = shortTexture(current)
    local keys = Core.looks and Core.looks.textureOptions() or {}
    local seen = {}
    for _, k in ipairs(keys) do
        seen[k] = true
    end
    if type(current) == "string" and current ~= "" and not seen[current] then
        table.insert(keys, current)
        table.sort(keys)
    end
    table.insert(keys, 1, "")
    table.insert(keys, getText(OTHER))
    return keys
end

--- The texture the look fields currently name, Other resolved.
local function chosenTexture(f)
    local tex = f:getFieldValue("texture")
    if isOther(tex) then
        tex = f:getFieldValue("textureOther")
    end
    return (tex and tex ~= "") and tex or nil
end

local function getCategoryKeys(current)
    local seen = {}
    local keys = {}
    for _, def in pairs(Core.defs and Core.defs.shops or {}) do
        if type(def.category) == "string" and def.category ~= "" and not seen[def.category] then
            seen[def.category] = true
            table.insert(keys, def.category)
        end
    end
    if type(current) == "string" and current ~= "" and not seen[current] then
        table.insert(keys, current)
    end
    table.sort(keys)
    table.insert(keys, 1, "")
    table.insert(keys, getText(OTHER))
    return keys
end

-- Deep-copy a pool set so edits don't mutate the original.
local function copySet(set)
    if not set then
        return {
            keys = {}
        }
    end
    local copy = {
        keys = {}
    }
    if set.roll and set.roll.count then
        copy.roll = {
            mode = "weighted",
            count = {
                min = set.roll.count.min,
                max = set.roll.count.max
            }
        }
    end
    if type(set.price) == "string" then
        copy.price = set.price
    end
    for _, entry in ipairs(set.keys or {}) do
        table.insert(copy.keys, {
            key = entry.key,
            weight = entry.weight or 1.0
        })
    end
    return copy
end

-- Deep-copy an entire poolSets array.
local function copyPoolSets(poolSets)
    if not poolSets then
        return {}
    end
    local result = {}
    for _, set in ipairs(poolSets) do
        table.insert(result, copySet(set))
    end
    return result
end

-- Format a pool set into column cells: {pools, roll}
local function formatSetColumns(set)
    -- Pools column
    local poolParts = {}
    for _, entry in ipairs(set.keys or {}) do
        if entry.weight and entry.weight ~= 1.0 then
            table.insert(poolParts, entry.key .. ":" .. tostring(entry.weight))
        else
            table.insert(poolParts, entry.key)
        end
    end
    local poolsText = table.concat(poolParts, ", ")

    -- Roll column
    local rollText = ""
    if set.roll and set.roll.count then
        local c = set.roll.count
        rollText = tostring(c.min) .. "-" .. tostring(c.max)
    end

    return {poolsText, rollText}
end

-- Also keep a simple format for the list item text (used internally by ISScrollingListBox)
local function formatSetRow(set)
    local cells = formatSetColumns(set)
    return cells[1]
end

---------------------------------------------------------------------------
-- Pool Set Edit Sub-Form
---------------------------------------------------------------------------

local function createSetEditForm(setData, isNew, cb)
    local set = setData or {
        keys = {}
    }

    local rollMinDefault = ""
    local rollMaxDefault = ""
    if set.roll and set.roll.count then
        rollMinDefault = tostring(set.roll.count.min or "")
        rollMaxDefault = tostring(set.roll.count.max or "")
    end

    -- One row per pool, each carrying its own weight.
    --
    -- This was a picker for membership with a single Weight box beside it, and
    -- that box could only say one thing about every pool in the set. It could
    -- report a mixture, by going blank, but it could not create one: there was
    -- no way to put a pool at 0.5 next to one at 1.0. Blended sets are exactly
    -- where the weights matter -- BudgetXPerience ships with its boost pools at
    -- half the weight of the XP pools beside them -- so the shape the defaults
    -- lean on was the one shape this form could not produce. A list of rows can.
    local keyRows = {}
    for _, entry in ipairs(set.keys or {}) do
        table.insert(keyRows, {
            key = entry.key,
            weight = entry.weight or 1.0
        })
    end

    local function formatKeyColumns(row)
        return {row.key, tostring(row.weight or 1.0)}
    end

    local function formatKeyRow(row)
        return row.key
    end

    -- One number, for the row already chosen. The pool itself is not editable
    -- here: swapping a row's pool is deleting it and adding the other, and a
    -- combo of every pool sitting beside the weight would make the small edit
    -- look like the large one.
    local function editRowWeight(form, field, index, data)
        local wf = FormPanel:new({
            width = math.floor(300 * FONT_SCALE),
            title = data.key,
            onApply = function(w)
                form:updateListItem("keys", index, {
                    key = data.key,
                    weight = w:getFieldNumber("weight") or 1.0
                })
                w:close()
            end
        })
        wf:addTextField("weight", getText("IGUI_PhunMart_Lbl_Weight"), {
            default = tostring(data.weight or 1.0),
            hint = getText("IGUI_PhunMart_Hint_PoolWeightRow"),
            numeric = true,
            min = 0,
            required = true
        })
        wf:initialise()
        wf:addToUIManager()
        wf:bringToTop()
        return wf
    end

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddPoolSet") or getText("IGUI_PhunMart_Title_EditPoolSet")

    local form = FormPanel:new({
        width = math.floor(420 * FONT_SCALE),
        title = titleText,
        -- A set with no pools sells nothing. The picker this replaced was marked
        -- required for the same reason; a list field has no such flag, so the
        -- rule moves to the form.
        validate = function(f)
            local rows = f:getFieldValue("keys")
            if not rows or #rows == 0 then
                return getText("IGUI_PhunMart_Err_NeedPool")
            end
        end,
        onApply = function(f)
            local result = {
                keys = {}
            }

            local rollMin, rollMax = f:getFieldRange("roll")
            if rollMin and rollMax then
                result.roll = {
                    mode = "weighted",
                    count = {
                        min = rollMin,
                        max = rollMax
                    }
                }
            end

            -- Not on the form any more, but a hand written override may still
            -- carry one, so an edit here must not silently delete it. See the
            -- note further down, where that combo used to sit.
            if type(set.price) == "string" then
                result.price = set.price
            end

            for _, row in ipairs(f:getFieldValue("keys") or {}) do
                table.insert(result.keys, {
                    key = row.key,
                    weight = row.weight or 1.0
                })
            end

            if cb then
                cb(result)
            end
            f:close()
        end
    })

    form:addListField("keys", getText("IGUI_PhunMart_Lbl_Pools"), {
        items = keyRows,
        rows = 4,
        hint = getText("IGUI_PhunMart_Hint_PoolList"),
        columns = {{
            name = getText("IGUI_PhunMart_Col_Pool"),
            size = 0
        }, {
            name = getText("IGUI_PhunMart_Col_Weight"),
            size = 0.70
        }},
        formatColumns = formatKeyColumns,
        formatItem = formatKeyRow,
        -- Offers only the pools not already here, so the same pool cannot land
        -- in one set twice carrying two different weights.
        onAdd = function(f, field)
            local inSet = {}
            for _, row in ipairs(f:getFieldValue("keys") or {}) do
                inSet[row.key] = true
            end
            local available = {}
            for _, k in ipairs(getPoolKeys()) do
                if not inSet[k] then
                    table.insert(available, k)
                end
            end
            KeyPicker.open(getSpecificPlayer(0), available, {}, function(keys)
                for _, k in ipairs(keys or {}) do
                    f:addListItem("keys", {
                        key = k,
                        weight = 1.0
                    })
                end
            end, {
                title = getText("IGUI_PhunMart_Admin_PickPools")
            })
        end,
        onEdit = editRowWeight,
        -- The set names pools by key and says nothing else about them, so deciding
        -- whether the right ones are in here meant leaving the form, finding the
        -- pool in the Pools tab and coming back. Both destinations already
        -- existed; neither was reachable from the place that asks the question.
        buttons = {{
            text = getText("IGUI_PhunMart_Btn_Open"),
            onClick = function(f, field, index, data)
                if Core.ui.admin_pools and Core.ui.admin_pools.OnEditPool then
                    Core.ui.admin_pools.OnEditPool(getSpecificPlayer(0), data.key)
                end
            end
        }, {
            text = getText("IGUI_PhunMart_Btn_ViewContents"),
            onClick = function(f, field, index, data)
                sendClientCommand(Core.name, Core.commands.requestPool, {
                    poolKey = data.key
                })
            end
        }}
    })
    -- There was a "Fallback price" combo here. A pool set's price is only read
    -- when the offer itself has none (system_object.lua, bakePrice), and an
    -- offer gets its price baked at compile time from pool defaults, group
    -- defaults, its special or its item override. Forty-nine of the fifty-nine
    -- shipped groups set defaults.price and the other ten are priced by their
    -- special or per item, so nothing shipped can reach the fallback: the value
    -- here could not change a single price on a shelf.
    --
    -- It read as the opposite. It sat beside a roll that does override the
    -- pool's, under a label promising the default price for the set, so the
    -- obvious way to reprice a shop was to change it, and the obvious result was
    -- nothing at all. Prices live on the group (or the item, or the special);
    -- that is where an admin has to go, and a dead lever pointing elsewhere is
    -- worse than no lever. The data key still works if anyone writes one by
    -- hand, and an edit here preserves it.
    form:addRangeField("roll", getText("IGUI_PhunMart_Lbl_DefaultRoll"), {
        minDefault = rollMinDefault,
        maxDefault = rollMaxDefault,
        hint = getText("IGUI_PhunMart_Hint_DefaultRoll"),
        integer = true,
        min = 0,
        requireBoth = true
    })

    form:initialise()
    form:addToUIManager()
    form:bringToTop()
    return form
end

---------------------------------------------------------------------------
-- Edit Modal (FormPanel-based)
---------------------------------------------------------------------------

-- Parse a comma-separated string into a trimmed array. Returns nil for empty input.
local function parseCSV(text)
    if not text or text == "" then
        return nil
    end
    local result = {}
    for s in text:gmatch("[^,]+") do
        s = s:match("^%s*(.-)%s*$")
        if s ~= "" then
            table.insert(result, s)
        end
    end
    if #result == 0 then
        return nil
    end
    return result
end


-- A per-shop yes/no that may also defer to a sandbox option. The first entry
-- names what the server currently says, so "default" is never a mystery.
local function overrideOptions(option)
    local server = SandboxVars.PhunMart and SandboxVars.PhunMart[option] == true
    return {getText("IGUI_PhunMart_Opt_ServerDefault",
        getText(server and "IGUI_PhunMart_Opt_Yes" or "IGUI_PhunMart_Opt_No")), getText("IGUI_PhunMart_Opt_Yes"),
            getText("IGUI_PhunMart_Opt_No")}
end

local function overrideIndex(value)
    if value == true then
        return 2
    elseif value == false then
        return 3
    end
    return 1
end

-- nil when left on the server default, which tombstones the key on save.
local function overrideValue(text)
    if text == getText("IGUI_PhunMart_Opt_Yes") then
        return true
    elseif text == getText("IGUI_PhunMart_Opt_No") then
        return false
    end
    return nil
end

-- `shopDef` populates the fields and may come from the compiled runtime as a
-- fallback. `preserveBase` is the definition-table entry only. The compiled
-- runtime carries resolved offers and prices that must never be written back
-- into an override file, so it is not a safe base to copy forward from.
local function createEditModal(shopKey, shopDef, preserveBase, cb)
    local def = shopDef or {}

    local rollMinDefault = ""
    local rollMaxDefault = ""
    if def.roll and def.roll.count then
        rollMinDefault = tostring(def.roll.count.min or "")
        rollMaxDefault = tostring(def.roll.count.max or "")
    end

    -- Deep-copy poolSets so list edits don't mutate the live data
    local editPoolSets = copyPoolSets(def.poolSets)

    local form = FormPanel:new({
        width = math.floor(560 * FONT_SCALE),
        title = getText("IGUI_PhunMart_Title_EditX", shopKey or ""),
        onApply = function(f)
            -- Start from the existing definition so anything this form doesn't
            -- model survives the round trip; diffTable drops what's unchanged
            -- and tombstones what we clear below.
            local result = Core.utils.deepCopy(preserveBase or {})

            -- Only written when disabled; absent already means enabled. Clearing
            -- the key tombstones it, so re-enabling still carries.
            --
            -- Spelled out rather than `x and nil or false`: that idiom cannot
            -- yield nil, because `and nil` is falsy and `or false` then takes
            -- over. It returned false for both answers, so every save disabled
            -- whatever it was saving.
            if f:getFieldValue("enabled") then
                result.enabled = nil
            else
                result.enabled = false
            end
            result.probability = f:getFieldNumber("probability")

            -- Blank clears it, which tombstones the key and puts the shop back
            -- to being spaced against its own type alone.
            local category = f:getFieldValue("category")
            if isOther(category) then
                category = f:getFieldValue("categoryOther")
            end
            result.category = (category and category ~= "") and category or nil

            result.minDistance = f:getFieldNumber("minDistance")
            result.restockFrequency = f:getFieldNumber("restockFrequency")
            -- getFieldNumber returns nil for an empty box, which is the third
            -- state this field needs: nil follows the server setting, 0 opts
            -- out of it, and a number sets this shop's own pace.
            result.rerollFrequency = f:getFieldNumber("rerollFrequency")

            result.moveable = overrideValue(f:getFieldValue("moveable"))
            result.destructible = overrideValue(f:getFieldValue("destructible"))

            local title = f:getFieldValue("title")
            result.title = (title ~= "") and title or nil

            local view = f:getFieldValue("defaultView")
            result.defaultView = (view == "list") and "list" or nil

            local bg = f:getFieldValue("background")
            result.background = (bg and bg ~= "") and bg or nil

            result.texture = chosenTexture(f)

            result.sprites = parseCSV(f:getFieldValue("sprites"))
            result.unpoweredSprites = parseCSV(f:getFieldValue("unpSprites"))

            -- Same shape as enabled above, inverted: only written when true,
            -- because absent already means the machine needs no power. Clearing
            -- the key tombstones it, so turning the requirement back off sticks.
            if f:getFieldValue("powered") then
                result.powered = true
            else
                result.powered = nil
            end

            local rollMin, rollMax = f:getFieldRange("roll")
            if rollMin and rollMax then
                result.roll = {
                    mode = "weighted",
                    count = {
                        min = rollMin,
                        max = rollMax
                    }
                }
            else
                result.roll = nil
            end

            local poolSets = f:getFieldValue("poolSets")
            result.poolSets = (poolSets and #poolSets > 0) and poolSets or nil

            if cb then
                cb(shopKey, result)
            end
            f:close()
        end
    })

    -- Identity, above the tabs. What you are editing should not be on a tab you
    -- might not be looking at. The form used to open on the Enabled tickbox,
    -- which is a state, not a name.
    form:addTextField("key", getText("IGUI_PhunMart_Lbl_Key"), {
        default = shopKey or "",
        editable = false,
        hint = getText("IGUI_PhunMart_Hint_ShopKey")
    })
    form:addTextField("title", getText("IGUI_PhunMart_Lbl_Title"), {
        default = def.title or "",
        hint = getText("IGUI_PhunMart_Hint_ShopTitle")
    })

    form:addTextField("probability", getText("IGUI_PhunMart_Lbl_Probability"), {
        default = tostring(def.probability or 1),
        hint = getText("IGUI_PhunMart_Hint_Probability"),
        numeric = true,
        min = 0,
        section = "s_basics"
    })
    -- Not a label. Placement keeps a machine away from the nearest of its own
    -- type and from the nearest of anything sharing its category, whichever is
    -- closer, which is what stops two food machines landing on one street. The
    -- wizard has always asked for it and the edit form never did, so a category
    -- could be chosen once when the shop was created and never changed again.
    -- It sits directly above minDistance because that is the number it changes
    -- the meaning of.
    form:addComboField("category", getText("IGUI_PhunMart_Lbl_Category"), {
        options = getCategoryKeys(def.category),
        selected = def.category or "",
        hint = getText("IGUI_PhunMart_Hint_ShopCategory"),
        section = "s_basics",
        onChange = function(f)
            f:setFieldVisible("categoryOther", isOther(f:getFieldValue("category")))
        end
    })
    form:addTextField("categoryOther", getText("IGUI_PhunMart_Wiz_Lbl_Other"), {
        default = "",
        hint = getText("IGUI_PhunMart_Wiz_Hint_CategoryOther"),
        section = "s_basics",
        conditional = true
    })
    -- Hidden until Other is chosen. A form opens on a real category or on none,
    -- never on Other, so this always starts closed.
    form:setFieldVisible("categoryOther", false)
    form:addTextField("minDistance", getText("IGUI_PhunMart_Lbl_MinDistance"), {
        default = def.minDistance and tostring(def.minDistance) or "",
        hint = getText("IGUI_PhunMart_Hint_MinDistance"),
        integer = true,
        min = 0,
        section = "s_basics"
    })
    -- Beside the other placement rules, because it is one: how long a machine
    -- stays this shop before picking another. Blank defers to the server
    -- setting, 0 opts this shop out of it.
    form:addTextField("rerollFrequency", getText("IGUI_PhunMart_Lbl_RerollFrequency"), {
        default = def.rerollFrequency and tostring(def.rerollFrequency) or "",
        hint = getText("IGUI_PhunMart_Hint_RerollFrequency"),
        integer = true,
        min = 0,
        section = "s_basics"
    })
    -- What players may do to a standing machine. Each defers to its sandbox
    -- option until set here; admins are never restricted either way.
    form:addComboField("moveable", getText("IGUI_PhunMart_Lbl_Moveable"), {
        options = overrideOptions("ShopsMoveable"),
        selected = overrideIndex(def.moveable),
        hint = getText("IGUI_PhunMart_Hint_Moveable"),
        section = "s_basics"
    })
    form:addComboField("destructible", getText("IGUI_PhunMart_Lbl_Destructible"), {
        options = overrideOptions("ShopsDestructible"),
        selected = overrideIndex(def.destructible),
        hint = getText("IGUI_PhunMart_Hint_Destructible"),
        section = "s_basics"
    })
    -- Last in Basics rather than first in the form: a switch you flip rarely,
    -- not the thing you came to read.
    form:addCheckField("enabled", getText("IGUI_PhunMart_Lbl_Enabled"), {
        checked = def.enabled ~= false,
        text = getText("IGUI_PhunMart_Lbl_Enabled"),
        hint = getText("IGUI_PhunMart_Hint_ShopEnabled"),
        section = "s_basics"
    })
    -- With the basics, not the look: it decides whether the machine works at
    -- all without mains, and only after that how it looks when it does not.
    form:addCheckField("powered", getText("IGUI_PhunMart_Lbl_Powered"), {
        checked = def.powered == true,
        text = getText("IGUI_PhunMart_Lbl_Powered_Checkbox"),
        hint = getText("IGUI_PhunMart_Hint_Powered"),
        section = "s_basics"
    })

    -- Grid or list is how the shop looks when opened, so it belongs with the
    -- rest of the machine's appearance rather than among the placement rules.
    form:addComboField("defaultView", getText("IGUI_PhunMart_Lbl_DefaultView"), {
        options = {"grid", "list"},
        selected = def.defaultView or "grid",
        hint = getText("IGUI_PhunMart_Hint_ViewMode"),
        section = "s_look"
    })
    -- The machine's picture comes first: it is the 3D model and, unless a
    -- background overrides it, the shop window too (client looks.lua).
    form:addComboField("texture", getText("IGUI_PhunMart_Lbl_MachineTexture"), {
        options = getTextureKeys(def.texture),
        selected = shortTexture(def.texture) or "",
        hint = getText("IGUI_PhunMart_Hint_MachineTexture"),
        section = "s_look",
        onChange = function(f)
            f:setFieldVisible("textureOther", isOther(f:getFieldValue("texture")))
            f:reflowFields()
        end
    })
    form:addTextField("textureOther", getText("IGUI_PhunMart_Wiz_Lbl_Other"), {
        default = "",
        hint = getText("IGUI_PhunMart_Hint_MachineTextureOther"),
        section = "s_look",
        conditional = true,
        onChange = function(f)
            f:reflowFields()
        end,
        -- A name with no file behind it leaves the machine on its plain tiles,
        -- and the only other place that says so is the console.
        validate = function(value, f)
            if not isOther(f:getFieldValue("texture")) then
                return nil
            end
            if value and value ~= "" and Core.looks and not Core.looks.findTexture(value) then
                return getText("IGUI_PhunMart_Err_NoMachineTexture", value)
            end
        end
    })
    form:addTextField("background", getText("IGUI_PhunMart_Lbl_Background"), {
        default = def.background or "",
        hint = getText("IGUI_PhunMart_Hint_Background"),
        section = "s_look"
    })
    form:addTextField("sprites", getText("IGUI_PhunMart_Lbl_FallbackSprites"), {
        default = def.sprites and table.concat(def.sprites, ", ") or "",
        hint = getText("IGUI_PhunMart_Hint_FallbackSprites"),
        section = "s_look",
        onChange = function(f)
            f:reflowFields()
        end
    })
    form:addTextField("unpSprites", getText("IGUI_PhunMart_Lbl_FallbackUnpSprites"), {
        default = def.unpoweredSprites and table.concat(def.unpoweredSprites, ", ") or "",
        hint = getText("IGUI_PhunMart_Hint_FallbackUnpSprites"),
        section = "s_look",
        onChange = function(f)
            f:reflowFields()
        end
    })
    -- Everything the machine can look like in one row: the 3D machine wearing
    -- the chosen texture, then the 2D tiles when there are any, so a sprite
    -- name typed wrong is visibly wrong rather than discovered by walking to a
    -- machine that renders as nothing.
    form:addSceneField("machinePreview", getText("IGUI_PhunMart_Lbl_Preview3D"), {
        section = "s_look",
        height = math.floor(110 * FONT_SCALE),
        width = math.floor(80 * FONT_SCALE),
        imageHeight = math.floor(64 * FONT_SCALE),
        update = function(scene, f)
            if Core.looks then
                Core.looks.showInScene(scene, chosenTexture(f))
            end
        end,
        images = function()
            local out = {}
            local function add(csv, gap)
                local first = true
                for i, name in ipairs(parseCSV(csv) or {}) do
                    table.insert(out, {
                        texture = tileTexture(name),
                        -- Which way the tile faces, not its name: the names are
                        -- already in the box above, and the order is not the
                        -- compass order anyone would guess.
                        label = getText(FACINGS[i] or ""),
                        gap = first and gap or false
                    })
                    first = false
                end
            end
            add(form:getFieldValue("sprites"), false)
            add(form:getFieldValue("unpSprites"), true)
            return out
        end
    })
    form:setFieldVisible("textureOther", isOther(form:getFieldValue("texture")))

    -- How often it restocks sits with what it restocks, not with where it spawns.
    form:addTextField("restockFrequency", getText("IGUI_PhunMart_Lbl_RestockFrequency"), {
        default = def.restockFrequency and tostring(def.restockFrequency) or "",
        hint = getText("IGUI_PhunMart_Hint_RestockFrequency"),
        numeric = true,
        min = 0,
        section = "s_stock"
    })
    form:addRangeField("roll", getText("IGUI_PhunMart_Lbl_RollMin"), {
        minDefault = rollMinDefault,
        maxDefault = rollMaxDefault,
        hint = getText("IGUI_PhunMart_Hint_ShopRoll"),
        integer = true,
        min = 0,
        requireBoth = true,
        section = "s_stock"
    })

    form:addListField("poolSets", getText("IGUI_PhunMart_Lbl_PoolSets"), {
        items = editPoolSets,
        section = "s_stock",
        rows = 3,
        columns = {{
            name = getText("IGUI_PhunMart_Col_Pool"),
            size = 0
        }, {
            name = getText("IGUI_PhunMart_Col_Roll"),
            size = 0.80
        }},
        formatColumns = formatSetColumns,
        formatItem = formatSetRow,
        onAdd = function(f, field)
            createSetEditForm(nil, true, function(newSet)
                f:addListItem("poolSets", newSet)
            end)
        end,
        onEdit = function(f, field, index, data)
            createSetEditForm(copySet(data), false, function(editedSet)
                f:updateListItem("poolSets", index, editedSet)
            end)
        end
    })

    -- Before initialise: only one section's fields are visible, and the window
    -- is sized from what is on screen.
    -- Stock leads, and so is the tab the form opens on. It holds the pool sets,
    -- which is what a shop actually sells and the reason most edits start; the
    -- Basics tab is spawn chance, minimum distance and reroll frequency, which
    -- are set once and revisited rarely.
    form:setSections({{
        section = "s_stock",
        label = getText("IGUI_PhunMart_Sec_Stock")
    }, {
        section = "s_basics",
        label = getText("IGUI_PhunMart_Sec_Basics")
    }, {
        section = "s_look",
        label = getText("IGUI_PhunMart_Sec_Appearance")
    }})

    form:initialise()
    form:addToUIManager()
    form:bringToTop()
    return form
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

function AdminShops.OnOpenPanel(player, shopKey)
    -- Read from defs (uncompiled) so pool set fields are still raw keys rather
    -- than the resolved tables the runtime carries.
    -- Fall back to runtime for fields not in defs (backwards compat).
    local defs = Core.defs and Core.defs.shops
    local shopDef = defs and defs[shopKey]
    local preserveBase = shopDef
    if not shopDef then
        local runtime = Core.runtime and Core.runtime.shops
        shopDef = runtime and runtime[shopKey]
    end
    if not shopDef then
        return
    end

    createEditModal(shopKey, shopDef, preserveBase, function(key, def)
        def.type = key
        sendClientCommand(Core.name, Core.commands.upsertShopDefinition, def)
        PendingRestock.note("shops", key)
        if not Core.isLocal and Core.defs and Core.defs.shops then
            Core.defs.shops[key] = def
        end
        Core.debugLn("[PhunMart] Shop updated: " .. key)
    end)
end
