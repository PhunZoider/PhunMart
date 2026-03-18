if isServer() then
    return
end

local Core = PhunMart
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
local KeyPicker = require "PhunMart_Client/ui/base/key_picker"

local FONT_SCALE = FormPanel.FONT_SCALE

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
            if not pools or #pools == 0 then
                return
            end

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

            local defaultWeight = f:getFieldNumber("weight") or 1.0
            for _, poolKey in ipairs(pools) do
                table.insert(result.keys, {
                    key = poolKey,
                    weight = weightByKey[poolKey] or defaultWeight
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
        default = "1.0",
        hint = getText("IGUI_PhunMart_Hint_PoolWeight")
    })
    form:addComboField("price", getText("IGUI_PhunMart_Lbl_DefaultPrice"), {
        options = priceKeys,
        selected = currentPrice,
        hint = getText("IGUI_PhunMart_Hint_SetPrice")
    })
    form:addRangeField("roll", getText("IGUI_PhunMart_Lbl_DefaultRoll"), {
        min = rollMinDefault,
        max = rollMaxDefault,
        hint = getText("IGUI_PhunMart_Hint_DefaultRoll")
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

local function createEditModal(shopKey, shopDef, cb)
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
            local result = {}

            result.enabled = f:getFieldValue("enabled")

            local prob = f:getFieldNumber("probability")
            if prob then
                result.probability = prob
            end

            local dist = f:getFieldNumber("minDistance")
            if dist then
                result.minDistance = dist
            end

            local restock = f:getFieldNumber("restockFrequency")
            if restock then
                result.restockFrequency = restock
            end

            local view = f:getFieldValue("defaultView")
            if view == "list" then
                result.defaultView = "list"
            end

            local bg = f:getFieldValue("background")
            if bg and bg ~= "" then
                result.background = bg
            end

            local sprites = parseCSV(f:getFieldValue("sprites"))
            if sprites then
                result.sprites = sprites
            end

            local unpSprites = parseCSV(f:getFieldValue("unpSprites"))
            if unpSprites then
                result.unpoweredSprites = unpSprites
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
            end

            local poolSets = f:getFieldValue("poolSets")
            if poolSets and #poolSets > 0 then
                result.poolSets = poolSets
            end

            if cb then
                cb(shopKey, result)
            end
            f:close()
        end
    })

    form:addCheckField("enabled", getText("IGUI_PhunMart_Lbl_Enabled"), {
        checked = def.enabled ~= false,
        text = getText("IGUI_PhunMart_Lbl_Enabled")
    })
    form:addTextField("probability", getText("IGUI_PhunMart_Lbl_Probability"), {
        default = tostring(def.probability or 1),
        hint = getText("IGUI_PhunMart_Hint_Probability")
    })
    form:addTextField("minDistance", getText("IGUI_PhunMart_Lbl_MinDistance"), {
        default = def.minDistance and tostring(def.minDistance) or "",
        hint = getText("IGUI_PhunMart_Hint_MinDistance")
    })
    form:addTextField("restockFrequency", getText("IGUI_PhunMart_Lbl_RestockFrequency"), {
        default = def.restockFrequency and tostring(def.restockFrequency) or "",
        hint = getText("IGUI_PhunMart_Hint_RestockFrequency")
    })
    form:addComboField("defaultView", getText("IGUI_PhunMart_Lbl_DefaultView"), {
        options = {"grid", "list"},
        selected = def.defaultView or "grid",
        hint = getText("IGUI_PhunMart_Hint_ViewMode")
    })
    form:addTextField("background", getText("IGUI_PhunMart_Lbl_Background"), {
        default = def.background or "",
        hint = getText("IGUI_PhunMart_Hint_Background")
    })
    form:addTextField("sprites", getText("IGUI_PhunMart_Lbl_Sprites"), {
        default = def.sprites and table.concat(def.sprites, ", ") or "",
        hint = getText("IGUI_PhunMart_Hint_Sprites")
    })
    form:addTextField("unpSprites", getText("IGUI_PhunMart_Lbl_UnpSprites"), {
        default = def.unpoweredSprites and table.concat(def.unpoweredSprites, ", ") or "",
        hint = getText("IGUI_PhunMart_Hint_UnpSprites")
    })
    form:addRangeField("roll", getText("IGUI_PhunMart_Lbl_RollMin"), {
        min = rollMinDefault,
        max = rollMaxDefault,
        hint = getText("IGUI_PhunMart_Hint_ShopRoll")
    })

    form:addListField("poolSets", getText("IGUI_PhunMart_Lbl_PoolSets"), {
        items = editPoolSets,
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
    if not shopDef then
        local runtime = Core.runtime and Core.runtime.shops
        shopDef = runtime and runtime[shopKey]
    end
    if not shopDef then
        return
    end

    createEditModal(shopKey, shopDef, function(key, def)
        def.type = key
        sendClientCommand(Core.name, Core.commands.upsertShopDefinition, def)
        if not Core.isLocal and Core.defs and Core.defs.shops then
            Core.defs.shops[key] = def
        end
        Core.debugLn("[PhunMart] Shop updated: " .. key)
    end)
end
