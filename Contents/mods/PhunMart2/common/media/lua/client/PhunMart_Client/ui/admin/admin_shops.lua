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

-- Get sorted price definition keys for the combo.
local function getPriceKeys()
    local prices = Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"
    local keys = {""}
    for k in pairs(prices) do
        table.insert(keys, k)
    end
    table.sort(keys, function(a, b)
        if a == "" then
            return true
        end
        if b == "" then
            return false
        end
        return a < b
    end)
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

-- Resolve the effective price for a pool set row.
local function resolveSetPrice(set)
    return set.price or nil
end

-- Format a pool set into column cells: {pools, price, roll}
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

    -- Price column (may be a string key or a resolved table from runtime; display the key)
    local rawPrice = resolveSetPrice(set)
    local price = type(rawPrice) == "string" and rawPrice or ""

    -- Roll column
    local rollText = ""
    if set.roll and set.roll.count then
        local c = set.roll.count
        rollText = tostring(c.min) .. "-" .. tostring(c.max)
    end

    return {poolsText, price, rollText}
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

    local currentPrice = type(set.price) == "string" and set.price or ""

    -- Collect selected pool keys
    local selectedPools = {}
    for _, entry in ipairs(set.keys or {}) do
        table.insert(selectedPools, entry.key)
    end

    -- Build weight lookup from existing data
    local weightByKey = {}
    for _, entry in ipairs(set.keys or {}) do
        weightByKey[entry.key] = entry.weight or 1.0
    end

    -- What the Weight field opens on, and what "unchanged" means for it.
    --
    -- The field used to default to 1.0 whatever the pools actually held, and on
    -- save it was applied only to pools that had no weight yet. So it misreported
    -- the current state, and editing it did nothing to any pool already in the
    -- set: a control that looked live and was not.
    --
    -- Now it shows the weight when they all agree, and blank when they do not.
    -- Blank means leave each pool as it is. Anything else is applied to every
    -- pool in the set, which is what a single field labelled Weight should do.
    local commonWeight, mixedWeights = nil, false
    for _, entry in ipairs(set.keys or {}) do
        local w = entry.weight or 1.0
        if commonWeight == nil then
            commonWeight = w
        elseif commonWeight ~= w then
            mixedWeights = true
        end
    end
    local weightDefault = mixedWeights and "" or tostring(commonWeight or 1.0)

    local function formatPoolDisplay(keys)
        if not keys or #keys == 0 then
            return getText("IGUI_PhunMart_Lbl_None")
        end
        local limit = math.min(#keys, 3)
        local names = {}
        for i = 1, limit do
            names[i] = keys[i]
        end
        local text = table.concat(names, ", ")
        if #keys > limit then
            text = text .. " +" .. tostring(#keys - limit) .. " more"
        end
        return text
    end

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddPoolSet") or getText("IGUI_PhunMart_Title_EditPoolSet")

    local priceKeys = getPriceKeys()

    local form = FormPanel:new({
        width = math.floor(420 * FONT_SCALE),
        title = titleText,
        onApply = function(f)
            local pools = f:getFieldValue("pools")

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

            local price = f:getFieldValue("price")
            if price and price ~= "" then
                result.price = price
            end

            -- A number applies to every pool here; blank keeps what each one
            -- already had, and gives a pool just added the usual 1.0.
            local weight = f:getFieldNumber("weight")
            for _, poolKey in ipairs(pools) do
                table.insert(result.keys, {
                    key = poolKey,
                    weight = weight or weightByKey[poolKey] or 1.0
                })
            end

            if cb then
                cb(result)
            end
            f:close()
        end
    })

    form:addPickerField("pools", getText("IGUI_PhunMart_Lbl_Pools"), {
        value = selectedPools,
        display = formatPoolDisplay(selectedPools),
        required = true,
        onPick = function(f, field)
            local poolKeys = getPoolKeys()
            KeyPicker.open(getSpecificPlayer(0), poolKeys, selectedPools, function(keys)
                selectedPools = keys or {}
                f:setPickerValue("pools", selectedPools, formatPoolDisplay(selectedPools))
            end, {
                title = getText("IGUI_PhunMart_Admin_PickPools")
            })
        end
    })
    form:addTextField("weight", getText("IGUI_PhunMart_Lbl_Weight"), {
        default = weightDefault,
        hint = mixedWeights and getText("IGUI_PhunMart_Hint_PoolWeightMixed") or
            getText("IGUI_PhunMart_Hint_PoolWeight"),
        numeric = true,
        min = 0
    })
    form:addComboField("price", getText("IGUI_PhunMart_Lbl_DefaultPrice"), {
        options = priceKeys,
        selected = currentPrice,
        hint = getText("IGUI_PhunMart_Hint_SetPrice")
    })
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
            result.minDistance = f:getFieldNumber("minDistance")
            result.restockFrequency = f:getFieldNumber("restockFrequency")
            -- getFieldNumber returns nil for an empty box, which is the third
            -- state this field needs: nil follows the server setting, 0 opts
            -- out of it, and a number sets this shop's own pace.
            result.rerollFrequency = f:getFieldNumber("rerollFrequency")

            local title = f:getFieldValue("title")
            result.title = (title ~= "") and title or nil

            local view = f:getFieldValue("defaultView")
            result.defaultView = (view == "list") and "list" or nil

            local bg = f:getFieldValue("background")
            result.background = (bg and bg ~= "") and bg or nil

            result.sprites = parseCSV(f:getFieldValue("sprites"))
            result.unpoweredSprites = parseCSV(f:getFieldValue("unpSprites"))

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
    -- Last in Basics rather than first in the form: a switch you flip rarely,
    -- not the thing you came to read.
    form:addCheckField("enabled", getText("IGUI_PhunMart_Lbl_Enabled"), {
        checked = def.enabled ~= false,
        text = getText("IGUI_PhunMart_Lbl_Enabled"),
        hint = getText("IGUI_PhunMart_Hint_ShopEnabled"),
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
    form:addTextField("background", getText("IGUI_PhunMart_Lbl_Background"), {
        default = def.background or "",
        hint = getText("IGUI_PhunMart_Hint_Background"),
        section = "s_look"
    })
    form:addTextField("sprites", getText("IGUI_PhunMart_Lbl_Sprites"), {
        default = def.sprites and table.concat(def.sprites, ", ") or "",
        hint = getText("IGUI_PhunMart_Hint_Sprites"),
        section = "s_look",
        onChange = function(f)
            f:reflowFields()
        end
    })
    form:addTextField("unpSprites", getText("IGUI_PhunMart_Lbl_UnpSprites"), {
        default = def.unpoweredSprites and table.concat(def.unpoweredSprites, ", ") or "",
        hint = getText("IGUI_PhunMart_Hint_UnpSprites"),
        section = "s_look",
        onChange = function(f)
            f:reflowFields()
        end
    })
    -- The tiles themselves, so a sprite name typed wrong is visibly wrong rather
    -- than discovered by walking to a machine that renders as nothing.
    form:addImageField("spritePreview", getText("IGUI_PhunMart_Lbl_Preview"), {
        section = "s_look",
        height = math.floor(64 * FONT_SCALE),
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
            name = getText("IGUI_PhunMart_Col_Price"),
            size = 0.55
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
    -- Read from defs (uncompiled) so poolSet.price is still a string key.
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
