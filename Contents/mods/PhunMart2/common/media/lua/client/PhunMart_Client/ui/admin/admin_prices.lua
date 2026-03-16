if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
local tools = require "PhunMart_Client/ui/ui_utils"
local ItemPicker = require "PhunMart_Client/ui/base/item_picker"

local PAD = ListPanel.PAD
local ROW_H = ListPanel.ROW_H
local FONT_SCALE = ListPanel.FONT_SCALE
local FONT_HGT_SMALL = ListPanel.FONT_HGT_SMALL
local FONT_HGT_MEDIUM = ListPanel.FONT_HGT_MEDIUM
local SCROLLBAR_W = ListPanel.SCROLLBAR_W

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

-- Format a price amount for display.
local function formatAmount(priceDef)
    if priceDef.kind == "free" then
        return ""
    end
    if priceDef.kind == "items" then
        local item = priceDef.item
        if not item and priceDef.items and priceDef.items[1] then
            item = priceDef.items[1].item
        end
        local amt = priceDef.amount or (priceDef.items and priceDef.items[1] and priceDef.items[1].amount) or 1
        if type(amt) == "table" then
            return tostring(amt.min) .. "-" .. tostring(amt.max) .. "x " .. (item or "?")
        end
        return tostring(amt) .. "x " .. (item or "?")
    end
    local amount = priceDef.amount
    if amount == nil then
        return ""
    end
    if type(amount) == "table" then
        if priceDef.pool == "change" then
            return tools.formatCents(amount.min) .. " - " .. tools.formatCents(amount.max)
        end
        return tostring(amount.min) .. " - " .. tostring(amount.max)
    end
    if priceDef.pool == "change" then
        return tools.formatCents(amount)
    end
    return tostring(amount)
end

-- Resolve the effective kind for a price def by walking the inheritance chain.
local function resolveKind(priceDef)
    if priceDef.kind then
        return priceDef.kind, priceDef.pool
    end
    if priceDef.inherit then
        local prices = Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"
        local parent = prices[priceDef.inherit]
        if parent then
            return resolveKind(parent)
        end
    end
    return nil, nil
end

-- Format the kind column display.
local function formatKind(priceDef)
    local kind, pool = resolveKind(priceDef)
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

local function onKindChanged(form)
    local kind = form:getFieldValue("kind")
    local isCurrency = kind == "currency"
    local isFree = kind == "free"
    local isItems = kind == "items"

    form:setFieldVisible("pool", isCurrency)
    form:setFieldVisible("amount", not isFree)
    form:setFieldVisible("max", not isFree and not isItems)
    form:setFieldVisible("items", isItems)
end

local function createEditModal(priceKey, priceDef, isNew, cb)
    local def = priceDef or {}

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
        onApply = function(f)
            local key = f:getFieldValue("key")
            if not key or key == "" then return end

            local kind = f:getFieldValue("kind")
            local result = { kind = kind }

            if kind == "currency" then
                result.pool = f:getFieldValue("pool")
                local amt = f:getFieldNumber("amount")
                local maxAmt = f:getFieldNumber("max")
                if not amt then return end
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
                if not amt then return end
                result.amount = math.floor(amt + 0.5)
            elseif kind == "items" then
                local items = f:getFieldValue("items")
                if not items or #items == 0 then return end
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
            if inherit and inherit ~= "" then result.inherit = inherit end

            local factor = f:getFieldNumber("factor")
            if factor and factor ~= 1 then result.factor = factor end

            -- Preserve substitutes the editor doesn't manage yet
            if priceDef and priceDef.substitutes then
                result.substitutes = priceDef.substitutes
            end

            if cb then cb(key, result) end
            f:close()
        end,
    })

    form:addTextField("key", getText("IGUI_PhunMart_Lbl_Key"), {
        default = priceKey or "", editable = isNew,
    })
    form:addComboField("kind", getText("IGUI_PhunMart_Lbl_Kind"), {
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
    })
    form:addTextField("max", getText("IGUI_PhunMart_Lbl_Max"), {
        default = maxDefault,
        hint = getText("IGUI_PhunMart_Hint_FixedAmount"),
        group = "max",
    })
    form:addPickerField("items", getText("IGUI_PhunMart_Lbl_Items"), {
        value = selectedItems,
        display = formatItemList(selectedItems),
        group = "item",
        onPick = function(f, field)
            ItemPicker.open(getSpecificPlayer(0), selectedItems, function(keys)
                selectedItems = keys or {}
                f:setPickerValue("items", selectedItems, formatItemList(selectedItems))
            end)
        end,
    })
    form:addTextField("inherit", getText("IGUI_PhunMart_Lbl_Inherit"), {
        default = def.inherit or "",
        hint = getText("IGUI_PhunMart_Hint_InheritKey"),
    })
    form:addTextField("factor", getText("IGUI_PhunMart_Lbl_Factor"), {
        default = factorDefault,
        hint = getText("IGUI_PhunMart_Hint_Factor"),
    })

    form:initialise()
    -- Apply initial visibility based on kind
    onKindChanged(form)

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

function UI.OnOpenPanel(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        local core = getCore()
        local width = math.floor(500 * FONT_SCALE)
        local height = math.floor(450 * FONT_SCALE)
        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2
        instance = UI:new(x, y, width, height, player)
        instance:setTitle(getText("IGUI_PhunMart_Title_PriceDefs"))
        instance.description = getText("IGUI_PhunMart_Desc_PriceDefs")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    instance:addToUIManager()
    instance:setVisible(true)
    instance:refreshPrices()
    return instance
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self.list.doDrawItem = self.drawRow
    self.list:setOnMouseDoubleClick(self, self.onDoubleClick)

    self:addListColumn(getText("IGUI_PhunMart_Col_Key"), 0)
    self:addListColumn(getText("IGUI_PhunMart_Col_Kind"), 0.38)
    self:addListColumn(getText("IGUI_PhunMart_Col_Inherit"), 0.56)
    self:addListColumn(getText("IGUI_PhunMart_Col_Amount"), 0.76)

    self:addBottomButton(getText("IGUI_PhunMart_Btn_New"), self.onAddClick)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), self.onEditClick, true)
end

function UI:getFilterText(itemData)
    return itemData.key .. " " .. itemData.kind .. " " .. itemData.inherit
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
    table.sort(keys)

    for _, key in ipairs(keys) do
        local def = prices[key]
        self:addListItem(key, {
            key = key,
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

function UI:close()
    ISCollapsableWindowJoypad.close(self)
    UI.instances[self.playerIndex] = nil
end

function UI:drawRow(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9
    local textY = y + (self.itemheight - FONT_HGT_SMALL) / 2

    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15)
    end
    if alt then
        self:drawRect(0, y, self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5)
    end
    self:drawRectBorder(0, y, self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    local xoffset = 10
    local data = item.item
    local rightEdge = self.width - SCROLLBAR_W

    -- Key column (clipped to column 1 width)
    local col1X = self.columns[1].size
    local col2X = self.columns[2].size
    local col3X = self.columns[3].size
    local col4X = self.columns[4].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    self:setStencilRect(col1X, clipY, col2X - col1X, clipY2 - clipY)
    self:drawText(data.key, xoffset, textY, 1, 1, 1, a, self.font)
    self:clearStencilRect()

    -- Kind column
    self:setStencilRect(col2X, clipY, col3X - col2X, clipY2 - clipY)
    self:drawText(data.kind, col2X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Inherit column
    if data.inherit ~= "" then
        self:setStencilRect(col3X, clipY, col4X - col3X, clipY2 - clipY)
        self:drawText(data.inherit, col3X + 4, textY, 0.6, 0.8, 0.6, a, self.font)
        self:clearStencilRect()
    end

    -- Amount column (right-aligned, accounting for scrollbar)
    local amountWidth = getTextManager():MeasureStringX(self.font, data.amount)
    self:drawText(data.amount, rightEdge - amountWidth - xoffset, textY, 1, 1, 1, a, self.font)

    self.itemsHeight = y + self.itemheight
    return self.itemsHeight
end
