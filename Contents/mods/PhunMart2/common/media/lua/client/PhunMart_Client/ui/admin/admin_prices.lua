if isServer() then
    return
end

require "ISUI/ISPanel"

local Core = PhunMart
local tools = require "PhunMart_Client/ui/ui_utils"
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_SCALE = FONT_HGT_SMALL / 14

local PAD = math.max(10, math.floor(10 * FONT_SCALE))
local ROW_H = FONT_HGT_SMALL + math.floor(6 * FONT_SCALE)
local SCROLLBAR_W = 13

local windowName = "PhunPricesAdminUI"

Core.ui.admin_prices = ISPanel:derive(windowName)
Core.ui.admin_prices.instances = {}
local UI = Core.ui.admin_prices

-- Format a price amount for display.
local function formatAmount(priceDef)
    if priceDef.kind == "free" then
        return ""
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

-- Format the kind column display.
local function formatKind(priceDef)
    if priceDef.kind == "free" then
        return "Free"
    end
    if priceDef.kind == "currency" then
        return priceDef.pool or "currency"
    end
    if priceDef.kind == "self" then
        return "self"
    end
    if priceDef.kind == "items" then
        return "items"
    end
    return priceDef.kind or "?"
end

---------------------------------------------------------------------------
-- Edit / Add Modal
---------------------------------------------------------------------------
local EditModal = ISPanel:derive("PhunPriceEditModal")

function EditModal:createChildren()
    ISPanel.createChildren(self)

    local x = PAD
    local y = PAD
    local w = self.width - PAD * 2
    local labelW = getTextManager():MeasureStringX(UIFont.Small, "Amount: ") + 8

    -- Title
    local titleText = self.isNew and "Add Price" or ("Edit: " .. self.priceKey)
    self.titleLabel = ISLabel:new(x, y, FONT_HGT_MEDIUM, titleText, 1, 1, 1, 1, UIFont.Medium, true)
    self.titleLabel:initialise()
    self:addChild(self.titleLabel)
    y = y + FONT_HGT_MEDIUM + PAD

    -- Key entry
    self.keyLabel = ISLabel:new(x, y, ROW_H, "Key:", 1, 1, 1, 1, UIFont.Small, true)
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
    self.kindLabel = ISLabel:new(x, y, ROW_H, "Kind:", 1, 1, 1, 1, UIFont.Small, true)
    self.kindLabel:initialise()
    self:addChild(self.kindLabel)

    self.kindCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H, self, EditModal.onKindChanged)
    self.kindCombo:initialise()
    self.kindCombo:addOption("free")
    self.kindCombo:addOption("currency")
    self.kindCombo:addOption("self")
    if self.priceDef then
        local kind = self.priceDef.kind or "free"
        if kind == "free" then
            self.kindCombo.selected = 1
        elseif kind == "currency" then
            self.kindCombo.selected = 2
        elseif kind == "self" then
            self.kindCombo.selected = 3
        end
    end
    self:addChild(self.kindCombo)
    y = y + ROW_H + PAD

    -- Pool combo (only for currency)
    self.poolLabel = ISLabel:new(x, y, ROW_H, "Pool:", 1, 1, 1, 1, UIFont.Small, true)
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
    self.amountLabel = ISLabel:new(x, y, ROW_H, "Amount:", 1, 1, 1, 1, UIFont.Small, true)
    self.amountLabel:initialise()
    self:addChild(self.amountLabel)

    local amountDefault = ""
    if self.priceDef and self.priceDef.amount then
        local amt = self.priceDef.amount
        if type(amt) == "table" then
            -- range — populate min field, max below
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

    local hint = "For change pool, enter as dollars (e.g. 5.00)"
    self.amountHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, hint, 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.amountHint:initialise()
    self:addChild(self.amountHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Max amount entry (for ranges)
    self.maxLabel = ISLabel:new(x, y, ROW_H, "Max:", 1, 1, 1, 1, UIFont.Small, true)
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

    self.maxHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, "Leave blank for fixed amount", 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.maxHint:initialise()
    self:addChild(self.maxHint)
    y = y + FONT_HGT_SMALL + PAD * 2

    -- Buttons
    local btnW = math.floor(80 * FONT_SCALE)
    local btnGap = PAD
    local totalBtnW = btnW * 2 + btnGap
    local btnX = (self.width - totalBtnW) / 2

    self.applyBtn = ISButton:new(btnX, y, btnW, ROW_H, "Apply", self, EditModal.onApply)
    self.applyBtn:initialise()
    self:addChild(self.applyBtn)

    self.cancelBtn = ISButton:new(btnX + btnW + btnGap, y, btnW, ROW_H, "Cancel", self, EditModal.onCancel)
    self.cancelBtn:initialise()
    self:addChild(self.cancelBtn)

    self:onKindChanged()
end

function EditModal:onKindChanged()
    local kind = self.kindCombo:getSelectedText()
    local isCurrency = kind == "currency"
    local isFree = kind == "free"

    self.poolLabel:setVisible(isCurrency)
    self.poolCombo:setVisible(isCurrency)
    self.amountLabel:setVisible(not isFree)
    self.amountEntry:setVisible(not isFree)
    self.amountHint:setVisible(isCurrency)
    self.maxLabel:setVisible(not isFree)
    self.maxEntry:setVisible(not isFree)
    self.maxHint:setVisible(not isFree)
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
    end

    if self.cb then
        self.cb(key, def)
    end

    self:close()
end

function EditModal:onCancel()
    self:close()
end

function EditModal:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function EditModal:new(priceKey, priceDef, isNew, cb)
    local modalW = math.floor(320 * FONT_SCALE)
    local modalH = PAD * 10 + FONT_HGT_MEDIUM + ROW_H * 6 + FONT_HGT_SMALL * 2 + PAD * 2
    local core = getCore()
    local sx = (core:getScreenWidth() - modalW) / 2
    local sy = (core:getScreenHeight() - modalH) / 2

    local o = ISPanel:new(sx, sy, modalW, modalH)
    setmetatable(o, self)
    self.__index = self
    o.priceKey = priceKey or ""
    o.priceDef = priceDef
    o.isNew = isNew
    o.cb = cb
    o.backgroundColor = {
        r = 0.1,
        g = 0.1,
        b = 0.1,
        a = 0.95
    }
    o.borderColor = {
        r = 0.6,
        g = 0.6,
        b = 0.6,
        a = 1
    }
    o.moveWithMouse = true
    return o
end

---------------------------------------------------------------------------
-- Main Prices Panel
---------------------------------------------------------------------------

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
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    instance:addToUIManager()
    instance:setVisible(true)
    instance:refreshPrices()
    return instance
end

function UI:refreshPrices()
    self.datas:clear()
    self.datas:setVisible(false)

    -- Load price definitions from defaults (shared code, always available)
    local prices = require "PhunMart/defaults/prices"

    -- Sort keys alphabetically for stable display
    local keys = {}
    for k in pairs(prices) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _, key in ipairs(keys) do
        local def = prices[key]
        self.datas:addItem(key, {
            key = key,
            kind = formatKind(def),
            amount = formatAmount(def),
            def = def
        })
    end
    self.datas:setVisible(true)
end

function UI:onAddClick()
    local modal = EditModal:new(nil, nil, true, function(key, def)
        -- TODO: send to server as price override
        print("[PhunMart] Price added: " .. key)
        self:refreshPrices()
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

function UI:onEditClick()
    if not self.datas.selected or self.datas.selected == 0 then
        return
    end
    local selectedItem = self.datas.items[self.datas.selected]
    if not selectedItem then
        return
    end
    local data = selectedItem.item
    local modal = EditModal:new(data.key, data.def, false, function(key, def)
        -- TODO: send to server as price override
        print("[PhunMart] Price updated: " .. key)
        self:refreshPrices()
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

function UI:GridDoubleClick(item)
    local data = item
    local modal = EditModal:new(data.key, data.def, false, function(key, def)
        print("[PhunMart] Price updated: " .. key)
        self:refreshPrices()
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

function UI:createChildren()
    ISPanel.createChildren(self)

    local x = PAD
    local y = PAD
    local w = self.width - PAD * 2

    -- Title
    self.title = ISLabel:new(x, y, FONT_HGT_MEDIUM, "Price Definitions", 1, 1, 1, 1, UIFont.Medium, true)
    self.title:initialise()
    self.title:instantiate()
    self:addChild(self.title)

    local closeSz = math.floor(25 * FONT_SCALE)
    self.closeButton = ISButton:new(self.width - closeSz - x, y, closeSz, closeSz, "X", self, function()
        self:close()
    end)
    self.closeButton:initialise()
    self:addChild(self.closeButton)

    y = y + FONT_HGT_MEDIUM + PAD

    -- Toolbar: Add / Edit buttons
    local btnW = math.floor(70 * FONT_SCALE)
    local gap = math.floor(5 * FONT_SCALE)

    self.addButton = ISButton:new(x, y, btnW, ROW_H, "Add", self, UI.onAddClick)
    self.addButton:initialise()
    self:addChild(self.addButton)

    self.editButton = ISButton:new(x + btnW + gap, y, btnW, ROW_H, "Edit", self, UI.onEditClick)
    self.editButton:initialise()
    self:addChild(self.editButton)

    y = y + ROW_H + PAD + tools.HEADER_HGT

    -- Data list
    local listH = self.height - y - PAD
    self.datas = ISScrollingListBox:new(x, y, w, listH)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas.itemheight = FONT_HGT_MEDIUM + math.floor(8 * FONT_SCALE)
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.font = UIFont.NewSmall
    self.datas.doDrawItem = self.drawDatas
    self.datas.drawBorder = true
    self.datas:setOnMouseDoubleClick(self, self.GridDoubleClick)

    local colKind = math.floor(w * 0.50)
    local colAmount = math.floor(w * 0.72)
    self.datas:addColumn("Key", 0)
    self.datas:addColumn("Kind", colKind)
    self.datas:addColumn("Amount", colAmount)
    self.datas:setVisible(false)
    self:addChild(self.datas)
end

function UI:drawDatas(y, item, alt)
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

function UI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    UI.instances[self.playerIndex] = nil
end

function UI:new(x, y, width, height, player)
    local o = ISPanel:new(x, y, width, height, player)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.playerIndex = player:getPlayerNum()
    o.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    }
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    }
    o.moveWithMouse = true
    return o
end
