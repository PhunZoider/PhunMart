if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
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
    if priceDef.inherit then
        base = base .. " <" .. priceDef.inherit
    end
    return base
end

---------------------------------------------------------------------------
-- Edit / Add Modal
---------------------------------------------------------------------------
local EditModal = ISCollapsableWindowJoypad:derive("PhunPriceEditModal")

function EditModal:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local th = self:titleBarHeight()
    local x = PAD
    local y = th + PAD
    local w = self.width - PAD * 2
    local labelW = getTextManager():MeasureStringX(UIFont.Small, "Amount: ") + 8

    -- Key entry
    self.keyLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Key"), 1, 1, 1, 1, UIFont.Small, true)
    self.keyLabel:initialise()
    self:addChild(self.keyLabel)

    self.keyEntry = ISTextEntryBox:new(self.priceKey or "", x + labelW, y, w - labelW, ROW_H)
    self.keyEntry:initialise()
    self.keyEntry:instantiate()
    if not self.isNew then
        self.keyEntry:setEditable(false)
    end
    self:addChild(self.keyEntry)
    y = y + ROW_H + PAD

    -- Kind combo
    self.kindLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Kind"), 1, 1, 1, 1, UIFont.Small, true)
    self.kindLabel:initialise()
    self:addChild(self.kindLabel)

    self.kindCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H, self, EditModal.onKindChanged)
    self.kindCombo:initialise()
    self.kindCombo:addOption("free")
    self.kindCombo:addOption("currency")
    self.kindCombo:addOption("self")
    self.kindCombo:addOption("items")
    if self.priceDef then
        local kind = self.priceDef.kind or "free"
        if kind == "free" then
            self.kindCombo.selected = 1
        elseif kind == "currency" then
            self.kindCombo.selected = 2
        elseif kind == "self" then
            self.kindCombo.selected = 3
        elseif kind == "items" then
            self.kindCombo.selected = 4
        end
    end
    self:addChild(self.kindCombo)
    y = y + ROW_H + PAD

    -- Pool combo (only for currency)
    self.poolLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Pool"), 1, 1, 1, 1, UIFont.Small, true)
    self.poolLabel:initialise()
    self:addChild(self.poolLabel)

    self.poolCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H)
    self.poolCombo:initialise()
    self.poolCombo:addOption("change")
    self.poolCombo:addOption("tokens")
    if self.priceDef and self.priceDef.pool == "tokens" then
        self.poolCombo.selected = 2
    end
    self:addChild(self.poolCombo)
    y = y + ROW_H + PAD

    -- Amount entry
    self.amountLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Amount"), 1, 1, 1, 1, UIFont.Small, true)
    self.amountLabel:initialise()
    self:addChild(self.amountLabel)

    local amountDefault = ""
    if self.priceDef and self.priceDef.amount then
        local amt = self.priceDef.amount
        if type(amt) == "table" then
            -- range -- populate min field, max below
            if self.priceDef.pool == "change" then
                amountDefault = tostring(amt.min / 100)
            else
                amountDefault = tostring(amt.min)
            end
        else
            if self.priceDef.pool == "change" then
                amountDefault = tostring(amt / 100)
            else
                amountDefault = tostring(amt)
            end
        end
    end

    self.amountEntry = ISTextEntryBox:new(amountDefault, x + labelW, y, w - labelW, ROW_H)
    self.amountEntry:initialise()
    self.amountEntry:instantiate()
    self:addChild(self.amountEntry)
    y = y + ROW_H + 2

    local hint = getText("IGUI_PhunMart_Hint_AmountDollars")
    self.amountHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, hint, 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.amountHint:initialise()
    self:addChild(self.amountHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Max amount entry (for ranges)
    self.maxLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Max"), 1, 1, 1, 1, UIFont.Small, true)
    self.maxLabel:initialise()
    self:addChild(self.maxLabel)

    local maxDefault = ""
    if self.priceDef and type(self.priceDef.amount) == "table" then
        local amt = self.priceDef.amount
        if self.priceDef.pool == "change" then
            maxDefault = tostring(amt.max / 100)
        else
            maxDefault = tostring(amt.max)
        end
    end

    self.maxEntry = ISTextEntryBox:new(maxDefault, x + labelW, y, w - labelW, ROW_H)
    self.maxEntry:initialise()
    self.maxEntry:instantiate()
    self:addChild(self.maxEntry)
    y = y + ROW_H + 2

    self.maxHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_FixedAmount"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.maxHint:initialise()
    self:addChild(self.maxHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Item entry (for kind="items") — display + Pick button
    self.itemLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Item"), 1, 1, 1, 1, UIFont.Small, true)
    self.itemLabel:initialise()
    self:addChild(self.itemLabel)

    self._selectedItem = nil
    if self.priceDef and self.priceDef.item then
        self._selectedItem = self.priceDef.item
    elseif self.priceDef and self.priceDef.items and self.priceDef.items[1] then
        self._selectedItem = self.priceDef.items[1].item
    end

    local pickBtnW = math.max(math.floor(60 * FONT_SCALE),
        getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Btn_Pick")) + PAD * 2)
    self.itemPickBtn = ISButton:new(x + w - pickBtnW, y, pickBtnW, ROW_H, getText("IGUI_PhunMart_Btn_Pick"), self, EditModal.onPickItem)
    self.itemPickBtn:initialise()
    self:addChild(self.itemPickBtn)

    self.itemDisplay = ISLabel:new(x + labelW, y, ROW_H, "", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self.itemDisplay:initialise()
    self:addChild(self.itemDisplay)
    self:refreshItemDisplay()
    y = y + ROW_H + PAD

    -- Inherit entry
    self.inheritLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Inherit"), 1, 1, 1, 1, UIFont.Small, true)
    self.inheritLabel:initialise()
    self:addChild(self.inheritLabel)

    local inheritDefault = self.priceDef and self.priceDef.inherit or ""
    self.inheritEntry = ISTextEntryBox:new(inheritDefault, x + labelW, y, w - labelW, ROW_H)
    self.inheritEntry:initialise()
    self.inheritEntry:instantiate()
    self:addChild(self.inheritEntry)
    y = y + ROW_H + 2

    self.inheritHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_InheritKey"), 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.inheritHint:initialise()
    self:addChild(self.inheritHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Factor entry
    self.factorLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Factor"), 1, 1, 1, 1, UIFont.Small, true)
    self.factorLabel:initialise()
    self:addChild(self.factorLabel)

    local factorDefault = ""
    if self.priceDef and self.priceDef.factor and self.priceDef.factor ~= 1 then
        factorDefault = tostring(self.priceDef.factor)
    end
    self.factorEntry = ISTextEntryBox:new(factorDefault, x + labelW, y, w - labelW, ROW_H)
    self.factorEntry:initialise()
    self.factorEntry:instantiate()
    self:addChild(self.factorEntry)
    y = y + ROW_H + 2

    self.factorHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_Factor"), 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.factorHint:initialise()
    self:addChild(self.factorHint)
    y = y + FONT_HGT_SMALL + PAD * 2

    -- Buttons
    local btnW = math.floor(80 * FONT_SCALE)
    local btnGap = PAD
    local totalBtnW = btnW * 2 + btnGap
    local btnX = (self.width - totalBtnW) / 2

    self.applyBtn = ISButton:new(btnX, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Apply"), self, EditModal.onApply)
    self.applyBtn:initialise()
    self:addChild(self.applyBtn)

    self.cancelBtn = ISButton:new(btnX + btnW + btnGap, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Cancel"), self, EditModal.onCancel)
    self.cancelBtn:initialise()
    if self.cancelBtn.enableCancelColor then
        self.cancelBtn:enableCancelColor()
    end
    self:addChild(self.cancelBtn)

    self:onKindChanged()
end

function EditModal:refreshItemDisplay()
    if self._selectedItem then
        local si = getScriptManager():getItem(self._selectedItem)
        local name = si and si:getDisplayName() or self._selectedItem
        self.itemDisplay:setName(name)
    else
        self.itemDisplay:setName(getText("IGUI_PhunMart_Lbl_None"))
    end
end

function EditModal:onPickItem()
    local modal = self
    local initial = self._selectedItem and {self._selectedItem} or {}
    local picker = ItemPicker.open(getSpecificPlayer(0), initial, function(key)
        modal._selectedItem = key
        modal:refreshItemDisplay()
    end)
    picker.singleSelect = true
end

function EditModal:onKindChanged()
    local kind = self.kindCombo:getSelectedText()
    local isCurrency = kind == "currency"
    local isFree = kind == "free"
    local isItems = kind == "items"

    self.poolLabel:setVisible(isCurrency)
    self.poolCombo:setVisible(isCurrency)
    self.amountLabel:setVisible(not isFree)
    self.amountEntry:setVisible(not isFree)
    self.amountHint:setVisible(isCurrency)
    self.maxLabel:setVisible(not isFree and not isItems)
    self.maxEntry:setVisible(not isFree and not isItems)
    self.maxHint:setVisible(not isFree and not isItems)
    self.itemLabel:setVisible(isItems)
    self.itemDisplay:setVisible(isItems)
    self.itemPickBtn:setVisible(isItems)
end

function EditModal:onApply()
    local key = self.keyEntry:getText()
    if not key or key == "" then
        return
    end

    local kind = self.kindCombo:getSelectedText()
    local def = {
        kind = kind
    }

    if kind == "free" then
        -- no extra fields
    elseif kind == "currency" then
        def.pool = self.poolCombo:getSelectedText()
        local amtText = self.amountEntry:getText()
        local maxText = self.maxEntry:getText()
        local amt = tonumber(amtText)
        local maxAmt = tonumber(maxText)
        if not amt then
            return
        end

        -- Convert dollars to cents for change pool
        if def.pool == "change" then
            amt = math.floor(amt * 100 + 0.5)
            if maxAmt then
                maxAmt = math.floor(maxAmt * 100 + 0.5)
            end
        else
            amt = math.floor(amt + 0.5)
            if maxAmt then
                maxAmt = math.floor(maxAmt + 0.5)
            end
        end

        if maxAmt and maxAmt > amt then
            def.amount = {
                min = amt,
                max = maxAmt
            }
        else
            def.amount = amt
        end
    elseif kind == "self" then
        local amt = tonumber(self.amountEntry:getText())
        if not amt then
            return
        end
        def.amount = math.floor(amt + 0.5)
    elseif kind == "items" then
        if not self._selectedItem or self._selectedItem == "" then
            return
        end
        def.item = self._selectedItem
        local amt = tonumber(self.amountEntry:getText())
        if amt then
            def.amount = math.floor(amt + 0.5)
        end
    end

    -- Inherit (optional, any kind)
    local inherit = self.inheritEntry:getText()
    if inherit and inherit ~= "" then
        def.inherit = inherit
    end

    -- Factor (optional, any kind)
    local factor = tonumber(self.factorEntry:getText())
    if factor and factor ~= 1 then
        def.factor = factor
    end

    -- Preserve fields the editor doesn't manage yet (e.g. substitutes, items array)
    if self.priceDef then
        if self.priceDef.substitutes and not def.substitutes then
            def.substitutes = self.priceDef.substitutes
        end
        if self.priceDef.items and not def.items then
            def.items = self.priceDef.items
        end
    end

    if self.cb then
        self.cb(key, def)
    end

    self:close()
end

function EditModal:onCancel()
    self:close()
end

function EditModal:new(priceKey, priceDef, isNew, cb)
    local modalW = math.floor(320 * FONT_SCALE)
    local modalH = PAD * 10 + FONT_HGT_MEDIUM + ROW_H * 9 + FONT_HGT_SMALL * 5 + PAD * 5
    local core = getCore()
    local sx = (core:getScreenWidth() - modalW) / 2
    local sy = (core:getScreenHeight() - modalH) / 2

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddPrice") or getText("IGUI_PhunMart_Title_EditX", priceKey)

    local o = ISCollapsableWindowJoypad:new(sx, sy, modalW, modalH)
    setmetatable(o, self)
    self.__index = self
    o.priceKey = priceKey or ""
    o.priceDef = priceDef
    o.isNew = isNew
    o.cb = cb
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 0.8}
    o:setTitle(titleText)
    return o
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
        local width = math.floor(420 * FONT_SCALE)
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
    self:addListColumn(getText("IGUI_PhunMart_Col_Kind"), 0.50)
    self:addListColumn(getText("IGUI_PhunMart_Col_Amount"), 0.72)

    self:addBottomButton(getText("IGUI_PhunMart_Btn_New"), self.onAddClick)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), self.onEditClick, true)
end

function UI:getFilterText(itemData)
    return itemData.key .. " " .. itemData.kind
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
    local modal = EditModal:new(nil, nil, true, function(key, def)
        savePriceDef(self, key, def)
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
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
    local modal = EditModal:new(data.key, data.def, false, function(key, def)
        savePriceDef(self, key, def)
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

function UI:onDoubleClick(item)
    local modal = EditModal:new(item.key, item.def, false, function(key, def)
        savePriceDef(self, key, def)
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
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
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    self:setStencilRect(col1X, clipY, col2X - col1X, clipY2 - clipY)
    self:drawText(data.key, xoffset, textY, 1, 1, 1, a, self.font)
    self:clearStencilRect()

    -- Kind column
    self:setStencilRect(col2X, clipY, col3X - col2X, clipY2 - clipY)
    self:drawText(data.kind, col2X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Amount column (right-aligned, accounting for scrollbar)
    local amountWidth = getTextManager():MeasureStringX(self.font, data.amount)
    self:drawText(data.amount, rightEdge - amountWidth - xoffset, textY, 1, 1, 1, a, self.font)

    self.itemsHeight = y + self.itemheight
    return self.itemsHeight
end
