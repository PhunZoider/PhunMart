if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
local tools = require "PhunMart_Client/ui/ui_utils"
local ItemPicker = require "PhunMart_Client/ui/base/item_picker"
local DeleteHelper = require "PhunMart_Client/ui/base/delete_helper"
local PendingRestock = require "PhunMart_Client/ui/admin/pending_restock"
local CurrencyTool = require "PhunMart_Client/ui/admin/currency_tool"

local PAD = ListPanel.PAD
local ROW_H = ListPanel.ROW_H
local FONT_SCALE = ListPanel.FONT_SCALE
local FONT_HGT_SMALL = ListPanel.FONT_HGT_SMALL
local FONT_HGT_MEDIUM = ListPanel.FONT_HGT_MEDIUM
local SCROLLBAR_W = ListPanel.SCROLLBAR_W

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

-- Read a field the definition may have inherited rather than set.
--
-- Only kind and pool used to be resolved this way, which left the Amount column
-- reading raw stored numbers: 44 of the 48 shipped prices inherit, so a row
-- would say "change" under Kind and print 200 under Amount where the Kind
-- column had already worked out it meant $2.00.
--
-- Depth-limited because an override file can name a parent that names it back,
-- and this runs while drawing.
-- Shared, because the currency tool needs the same walk and two copies of this
-- rule drifting apart is exactly how the Kind and Amount columns came to
-- disagree about the same row.
local resolveField = tools.resolvePriceField

-- The "inherits nothing" entry in the Inherits combo. Held once so the option
-- text and the test on save cannot drift apart.
local NONE = getText("IGUI_PhunMart_Lbl_None")

-- Format a price amount for display. Note this shows the amount as stored,
-- without applying factor, so a scaled child reads as its own base figure.
local function formatAmount(priceDef)
    local kind = resolveField(priceDef, "kind")
    if kind == "free" then
        return ""
    end
    local pool = resolveField(priceDef, "pool")
    if kind == "items" then
        local items = resolveField(priceDef, "items")
        local item = resolveField(priceDef, "item")
        if not item and items and items[1] then
            item = items[1].item
        end
        local amt = priceDef.amount or (items and items[1] and items[1].amount) or 1
        if type(amt) == "table" then
            return tostring(amt.min) .. "-" .. tostring(amt.max) .. "x " .. (item or "?")
        end
        return tostring(amt) .. "x " .. (item or "?")
    end
    local amount = resolveField(priceDef, "amount")
    if amount == nil then
        return ""
    end
    if type(amount) == "table" then
        if pool == "change" then
            return tools.formatCents(amount.min) .. " - " .. tools.formatCents(amount.max)
        end
        return tostring(amount.min) .. " - " .. tostring(amount.max)
    end
    if pool == "change" then
        return tools.formatCents(amount)
    end
    return tostring(amount)
end

-- Format the kind column display.
local function formatKind(priceDef)
    local kind, pool = resolveField(priceDef, "kind"), resolveField(priceDef, "pool")
    local base
    if kind == "free" then
        base = getText("IGUI_PhunMart_Free")
    elseif kind == "currency" then
        base = pool or "currency"
    elseif kind == "self" then
        base = "self"
    elseif kind == "items" then
        base = "items"
    else
        base = kind or "?"
    end
    return base
end

---------------------------------------------------------------------------
-- Edit / Add Modal (FormPanel-based)
---------------------------------------------------------------------------

local function resolveItemDisplay(itemKey)
    if not itemKey then return getText("IGUI_PhunMart_Lbl_None") end
    local si = getScriptManager():getItem(itemKey)
    return si and si:getDisplayName() or itemKey
end

local function formatItemList(keys)
    if not keys or #keys == 0 then
        return getText("IGUI_PhunMart_Lbl_None")
    end
    local names = {}
    local limit = math.min(#keys, 3)
    for i = 1, limit do
        names[i] = resolveItemDisplay(keys[i])
    end
    local text = table.concat(names, ", ")
    if #keys > limit then
        text = text .. " +" .. tostring(#keys - limit) .. " more"
    end
    return text
end

--- Show only the fields the chosen payment kind uses.
---
--- `kind` may be passed in, and has to be for the first call. Widgets are built
--- when the window is added to the UI manager, and getFieldValue on a combo
--- that does not exist yet returns "" rather than failing. That matched none of
--- the branches below, so on open the Pool row was always hidden and Amount and
--- Max were always shown, whatever the price actually was.
local function onKindChanged(form, kind)
    kind = kind or form:getFieldValue("kind")
    local isCurrency = kind == "currency"
    local isFree = kind == "free"
    local isItems = kind == "items"

    form:setFieldVisible("pool", isCurrency)
    form:setFieldVisible("amount", not isFree)
    form:setFieldVisible("max", not isFree and not isItems)
    form:setFieldVisible("items", isItems)
end

--- Where each form field reads from, for saying whether the value on screen is
--- this price's own or its parent's. See markInheritedFields below.
local PRICE_FIELD_SOURCE = {
    kind = function(d)
        return d.kind ~= nil
    end,
    pool = function(d)
        return d.pool ~= nil
    end,
    amount = function(d)
        return d.amount ~= nil
    end,
    max = function(d)
        return type(d.amount) == "table" and d.amount.max ~= nil
    end,
    factor = function(d)
        return d.factor ~= nil
    end,
    items = function(d)
        return d.item ~= nil or d.items ~= nil
    end
}

local function createEditModal(priceKey, priceDef, isNew, cb)
    -- `raw` is what this price stores; `def` is what it resolves to once its
    -- parent has been folded in. The form reads the resolved one.
    --
    -- It used to read the raw table, and 44 of the 48 shipped prices declare
    -- neither kind nor pool. A combo cannot show a blank: it sits on its first
    -- option, so every one of those opened reading "free", and Apply wrote that
    -- back along with clearing the amount. Opening an inheriting price and
    -- pressing Apply made it free.
    local raw = priceDef or {}
    local prices = Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"
    local def = (priceKey and tools.resolveInherited(prices, priceKey)) or raw
    -- What this price would be if it declared nothing: the yardstick for
    -- deciding, on save, whether a value is its own or borrowed.
    local parentDef = tools.resolveParent(prices, raw)

    -- Pre-compute amount default (convert cents to dollars for display)
    local amountDefault = ""
    if def.amount then
        local amt = def.amount
        if type(amt) == "table" then
            amountDefault = def.pool == "change" and tostring(amt.min / 100) or tostring(amt.min)
        else
            amountDefault = def.pool == "change" and tostring(amt / 100) or tostring(amt)
        end
    end

    local maxDefault = ""
    if type(def.amount) == "table" then
        maxDefault = def.pool == "change" and tostring(def.amount.max / 100) or tostring(def.amount.max)
    end

    local factorDefault = ""
    if def.factor and def.factor ~= 1 then
        factorDefault = tostring(def.factor)
    end

    -- Resolve initial items for picker (from legacy .item or .items array)
    local selectedItems = {}
    if def.item then
        table.insert(selectedItems, def.item)
    elseif def.items then
        for _, entry in ipairs(def.items) do
            if entry.item then table.insert(selectedItems, entry.item) end
        end
    end

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddPrice") or getText("IGUI_PhunMart_Title_EditX", priceKey or "")

    local form = FormPanel:new({
        width = math.floor(360 * FONT_SCALE),
        title = titleText,
        onDelete = (not isNew) and function(f)
            DeleteHelper.confirm("prices", priceKey, function()
                if not f._removed then
                    f._removed = true
                    f:close()
                end
            end)
        end or nil,
        onApply = function(f)
            local key = f:getFieldValue("key")

            local kind = f:getFieldValue("kind")
            -- From the raw definition, not the resolved one: starting from
            -- resolved would copy every inherited value onto this entry and
            -- freeze it there. Keys this form does not model (substitutes, and
            -- anything added later) still survive the edit.
            local result = Core.utils.deepCopy(raw)
            result.kind = kind
            -- Each branch below owns a different shape; clear the other shapes'
            -- fields so switching kind doesn't leave stale ones behind.
            result.pool = nil
            result.amount = nil
            result.item = nil
            result.items = nil

            if kind == "currency" then
                result.pool = f:getFieldValue("pool")
                local amt = f:getFieldNumber("amount")
                local maxAmt = f:getFieldNumber("max")
                if result.pool == "change" then
                    amt = math.floor(amt * 100 + 0.5)
                    if maxAmt then maxAmt = math.floor(maxAmt * 100 + 0.5) end
                else
                    amt = math.floor(amt + 0.5)
                    if maxAmt then maxAmt = math.floor(maxAmt + 0.5) end
                end
                if maxAmt and maxAmt > amt then
                    result.amount = { min = amt, max = maxAmt }
                else
                    result.amount = amt
                end
            elseif kind == "self" then
                local amt = f:getFieldNumber("amount")
                result.amount = math.floor(amt + 0.5)
            elseif kind == "items" then
                local items = f:getFieldValue("items")
                local amt = f:getFieldNumber("amount")
                amt = amt and math.floor(amt + 0.5) or 1
                if #items == 1 then
                    result.item = items[1]
                    result.amount = amt
                else
                    result.items = {}
                    for _, itemKey in ipairs(items) do
                        table.insert(result.items, { item = itemKey, amount = amt })
                    end
                end
            end

            local inherit = f:getFieldValue("inherit")
            result.inherit = (inherit ~= "" and inherit ~= NONE) and inherit or nil

            local factor = f:getFieldNumber("factor")
            result.factor = (factor and factor ~= 1) and factor or nil

            local title = f:getFieldValue("title")
            result.title = (title ~= "") and title or nil

            -- Drop anything the parent already says, so this entry keeps only
            -- what makes it different and keeps following the parent for the
            -- rest. Without this every save freezes the whole resolved price.
            if parentDef then
                tools.pruneInherited(result, parentDef)
            end

            if cb then cb(key, result) end
            f:close()
        end,
    })

    form:addTextField("key", getText("IGUI_PhunMart_Lbl_Key"), {
        default = priceKey or "", editable = isNew,
        required = true,
        validate = isNew and function(value)
            if prices[value] then
                return getText("IGUI_PhunMart_Err_KeyInUse")
            end
        end or nil,
    })
    form:addTextField("title", getText("IGUI_PhunMart_Lbl_Title"), {
        -- Raw, not resolved: a name is this entry's own or it has none, and
        -- showing the parent's would suggest it had been given one.
        default = raw.title or "",
        hint = getText("IGUI_PhunMart_Hint_Title"),
    })
    -- Prices and specials both store a `kind`, but they mean different things:
    -- here it selects how the player pays, there it is the sort of special.
    -- Separate strings so neither label has to be vague enough to cover both.
    form:addComboField("kind", getText("IGUI_PhunMart_Lbl_PriceKind"), {
        options = {"free", "currency", "self", "items"},
        selected = def.kind or "free",
        onChange = function(f) onKindChanged(f) end,
    })
    form:addComboField("pool", getText("IGUI_PhunMart_Lbl_Pool"), {
        options = {"change", "tokens"},
        selected = def.pool or "change",
        group = "currency",
    })
    form:addTextField("amount", getText("IGUI_PhunMart_Lbl_Amount"), {
        default = amountDefault,
        hint = getText("IGUI_PhunMart_Hint_AmountDollars"),
        group = "amount",
        numeric = true, min = 0,
        -- Required for currency and self, but optional for items, where a blank
        -- amount means one of each.
        validate = function(value, f)
            local kind = f:getFieldValue("kind")
            if value == "" and (kind == "currency" or kind == "self") then
                return getText("IGUI_PhunMart_Err_Required")
            end
        end,
    })
    form:addTextField("max", getText("IGUI_PhunMart_Lbl_Max"), {
        default = maxDefault,
        hint = getText("IGUI_PhunMart_Hint_FixedAmount"),
        group = "max",
        numeric = true, min = 0,
    })
    form:addPickerField("items", getText("IGUI_PhunMart_Lbl_Items"), {
        value = selectedItems,
        display = formatItemList(selectedItems),
        group = "item",
        required = true,
        onPick = function(f, field)
            ItemPicker.open(getSpecificPlayer(0), selectedItems, function(keys)
                selectedItems = keys or {}
                f:setPickerValue("items", selectedItems, formatItemList(selectedItems))
            end)
        end,
    })
    -- A combo rather than a typed key, matching the specials editor. It cannot
    -- name a price that does not exist and cannot name itself, which is what
    -- the two validations underneath it used to be for.
    local inheritOptions = {NONE}
    local inheritKeys = {}
    for k in pairs(prices) do
        if k ~= priceKey then
            table.insert(inheritKeys, k)
        end
    end
    table.sort(inheritKeys)
    for _, k in ipairs(inheritKeys) do
        table.insert(inheritOptions, k)
    end
    -- An override naming a price that has since gone would otherwise drop off
    -- the list and read as "(none)", quietly unparenting itself on the next save.
    if raw.inherit and raw.inherit ~= "" and not prices[raw.inherit] then
        table.insert(inheritOptions, raw.inherit)
    end

    form:addComboField("inherit", getText("IGUI_PhunMart_Lbl_Inherit"), {
        options = inheritOptions,
        selected = (raw.inherit and raw.inherit ~= "") and raw.inherit or NONE,
        hint = getText("IGUI_PhunMart_Hint_InheritKey"),
        button = {
            text = getText("IGUI_PhunMart_Btn_OpenParent"),
            onClick = function(f)
                local parentKey = f:getFieldValue("inherit")
                local parentRaw = parentKey and parentKey ~= NONE and prices[parentKey]
                if parentRaw then
                    createEditModal(parentKey, parentRaw, false, cb)
                end
            end
        }
    })
    form:addTextField("factor", getText("IGUI_PhunMart_Lbl_Factor"), {
        default = factorDefault,
        hint = getText("IGUI_PhunMart_Hint_Factor"),
        numeric = true, min = 0,
    })

    -- Say which values came from the parent, before initialise: a marked field
    -- needs a message row and that decides how tall the form is.
    if raw.inherit and raw.inherit ~= "" then
        for fieldKey, hasValue in pairs(PRICE_FIELD_SOURCE) do
            if not hasValue(raw) and hasValue(def) then
                form:setFieldInherited(fieldKey, raw.inherit)
            end
        end
    end

    -- Before initialise, and told the kind rather than asked for it: the combo
    -- does not exist yet. Also means the window height is computed from the
    -- fields that will actually be on screen.
    onKindChanged(form, def.kind or "free")

    form:initialise()

    form:addToUIManager()
    form:bringToTop()
    return form
end

---------------------------------------------------------------------------
-- Main Prices Panel (ListPanel subclass)
---------------------------------------------------------------------------

Core.ui.admin_prices = ListPanel:derive("PhunPricesAdminUI")
Core.ui.admin_prices.instances = {}
local UI = Core.ui.admin_prices
UI._defKind = "prices"

--- Build this panel as a view for the tabbed shell. The shell owns the size
--- and position, so both are placeholders until its first layout pass.
function UI.createTab(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        instance = UI:new(0, 0, 100, 100, player)
        instance.description = getText("IGUI_PhunMart_Desc_PriceDefs")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    return instance
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self.list.doDrawItem = ListPanel.defaultDrawRow
    self.list:setOnMouseDoubleClick(self, self.onDoubleClick)

    self:addNameColumn()
    self:addListColumn(getText("IGUI_PhunMart_Col_Kind"), 0.38, {field = "kind"})
    self:addListColumn(getText("IGUI_PhunMart_Col_Inherit"), 0.56, {field = "inherit", color = {0.6, 0.8, 0.6}})
    self:addListColumn(getText("IGUI_PhunMart_Col_Amount"), 0.76, {
        field = "amount",
        color = {1, 1, 1},
        align = "right"
    })

    -- On the Prices tab because that is what it edits, and first because it is
    -- the one thing here a server owner is most likely to want and least
    -- likely to find: it is a single edit to currency_base that reprices
    -- everything inheriting from it.
    self:addBottomButton(getText("IGUI_PhunMart_Cur_Btn"), self.onCurrencyClick)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_New"), self.onAddClick)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), self.onEditClick, true)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Delete"), self.onDeleteClick, true)
end

function UI:onCurrencyClick()
    CurrencyTool.open(self.player, function()
        self:refreshPrices()
    end)
end

function UI:onDeleteClick()
    if not self.list.selected or self.list.selected == 0 then
        return
    end
    local selectedItem = self.list.items[self.list.selected]
    if not selectedItem then
        return
    end
    DeleteHelper.confirm("prices", selectedItem.item.key, function()
        self:refreshPrices()
    end)
end

function UI:getFilterText(itemData)
    return itemData.key .. " " .. (itemData.title or "") .. " " .. itemData.kind .. " " .. itemData.inherit
end

function UI:refreshPrices()
    self:clearList()

    -- Read from compiled context (defaults + overrides merged)
    local prices = Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"

    -- Sort keys alphabetically for stable display
    local keys = {}
    for k in pairs(prices) do
        table.insert(keys, k)
    end
    self:sortKeysByName(keys, prices)

    for _, key in ipairs(keys) do
        local def = prices[key]
        local name, title = self:rowName(key, def)
        self:addListItem(name, {
            key = key,
            name = name,
            title = title,
            kind = formatKind(def),
            inherit = def.inherit or "",
            amount = formatAmount(def),
            def = def
        })
    end
end

local function savePriceDef(self, key, def)
    sendClientCommand(Core.name, Core.commands.upsertPriceDef, {
        key = key,
        def = def
    })
    PendingRestock.note("prices", key)
    -- In SP, skip optimistic update: shared Lua state means the server-side
    -- recompile will update Core.defs directly, and mutating it here would
    -- poison the diff in upsertDefinition (it compares against Core.defs).
    if not Core.isLocal and Core.defs and Core.defs.prices then
        Core.defs.prices[key] = def
    end
    self:refreshPrices()
end

function UI:onAddClick()
    createEditModal(nil, nil, true, function(key, def)
        savePriceDef(self, key, def)
    end)
end

function UI:onEditClick()
    if not self.list.selected or self.list.selected == 0 then
        return
    end
    local selectedItem = self.list.items[self.list.selected]
    if not selectedItem then
        return
    end
    local data = selectedItem.item
    createEditModal(data.key, data.def, false, function(key, def)
        savePriceDef(self, key, def)
    end)
end

function UI:onDoubleClick(item)
    createEditModal(item.key, item.def, false, function(key, def)
        savePriceDef(self, key, def)
    end)
end

UI.refresh = UI.refreshPrices
