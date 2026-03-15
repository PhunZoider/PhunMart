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

local windowName = "PhunItemsAdminUI"

Core.ui.admin_items = ISPanel:derive(windowName)
Core.ui.admin_items.instances = {}
local UI = Core.ui.admin_items

-- Collect sorted keys from a defaults table for combo population.
local function getSortedKeys(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

-- Format the price column: show the price key string.
local function formatPrice(itemDef)
    return itemDef.price or ""
end

-- Format the reward column: show the reward key string.
local function formatReward(itemDef)
    return itemDef.reward or ""
end

-- Format weight for display.
local function formatWeight(itemDef)
    if itemDef.offer and itemDef.offer.weight then
        return tostring(itemDef.offer.weight)
    end
    return ""
end

-- Format enabled status.
local function formatEnabled(itemDef)
    if itemDef.enabled == false then
        return "No"
    end
    return "Yes"
end

---------------------------------------------------------------------------
-- Edit / Add Modal
---------------------------------------------------------------------------
local EditModal = ISPanel:derive("PhunItemEditModal")

function EditModal:createChildren()
    ISPanel.createChildren(self)

    local x = PAD
    local y = PAD
    local w = self.width - PAD * 2
    local labelW = getTextManager():MeasureStringX(UIFont.Small, "Reward: ") + 8

    -- Title
    local titleText = self.isNew and "Add Item" or ("Edit: " .. self.itemKey)
    self.titleLabel = ISLabel:new(x, y, FONT_HGT_MEDIUM, titleText, 1, 1, 1, 1, UIFont.Medium, true)
    self.titleLabel:initialise()
    self:addChild(self.titleLabel)
    y = y + FONT_HGT_MEDIUM + PAD

    -- Key entry
    self.keyLabel = ISLabel:new(x, y, ROW_H, "Key:", 1, 1, 1, 1, UIFont.Small, true)
    self.keyLabel:initialise()
    self:addChild(self.keyLabel)

    self.keyEntry = ISTextEntryBox:new(self.itemKey or "", x + labelW, y, w - labelW, ROW_H)
    self.keyEntry:initialise()
    self.keyEntry:instantiate()
    if not self.isNew then
        self.keyEntry:setEditable(false)
    end
    self:addChild(self.keyEntry)
    y = y + ROW_H + PAD

    -- Price combo
    self.priceLabel = ISLabel:new(x, y, ROW_H, "Price:", 1, 1, 1, 1, UIFont.Small, true)
    self.priceLabel:initialise()
    self:addChild(self.priceLabel)

    self.priceCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H)
    self.priceCombo:initialise()
    local prices = Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"
    local priceKeys = getSortedKeys(prices)
    local selectedPriceIdx = 1
    for i, pk in ipairs(priceKeys) do
        self.priceCombo:addOption(pk)
        if self.itemDef and self.itemDef.price == pk then
            selectedPriceIdx = i
        end
    end
    self.priceCombo.selected = selectedPriceIdx
    self:addChild(self.priceCombo)
    y = y + ROW_H + PAD

    -- Reward combo
    self.rewardLabel = ISLabel:new(x, y, ROW_H, "Reward:", 1, 1, 1, 1, UIFont.Small, true)
    self.rewardLabel:initialise()
    self:addChild(self.rewardLabel)

    self.rewardCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H)
    self.rewardCombo:initialise()
    local rewards = Core.defs and Core.defs.rewards or require "PhunMart/defaults/rewards"
    local rewardKeys = getSortedKeys(rewards)
    local selectedRewardIdx = 1
    for i, rk in ipairs(rewardKeys) do
        self.rewardCombo:addOption(rk)
        if self.itemDef and self.itemDef.reward == rk then
            selectedRewardIdx = i
        end
    end
    self.rewardCombo.selected = selectedRewardIdx
    self:addChild(self.rewardCombo)
    y = y + ROW_H + PAD

    -- Weight entry
    self.weightLabel = ISLabel:new(x, y, ROW_H, "Weight:", 1, 1, 1, 1, UIFont.Small, true)
    self.weightLabel:initialise()
    self:addChild(self.weightLabel)

    local weightDefault = "1.0"
    if self.itemDef and self.itemDef.offer and self.itemDef.offer.weight then
        weightDefault = tostring(self.itemDef.offer.weight)
    end
    self.weightEntry = ISTextEntryBox:new(weightDefault, x + labelW, y, w - labelW, ROW_H)
    self.weightEntry:initialise()
    self.weightEntry:instantiate()
    self:addChild(self.weightEntry)
    y = y + ROW_H + PAD

    -- Stock min entry
    self.stockMinLabel = ISLabel:new(x, y, ROW_H, "Stock Min:", 1, 1, 1, 1, UIFont.Small, true)
    self.stockMinLabel:initialise()
    self:addChild(self.stockMinLabel)

    local stockMinDefault = ""
    if self.itemDef and self.itemDef.offer and self.itemDef.offer.stock then
        stockMinDefault = tostring(self.itemDef.offer.stock.min or "")
    end
    self.stockMinEntry = ISTextEntryBox:new(stockMinDefault, x + labelW, y, w - labelW, ROW_H)
    self.stockMinEntry:initialise()
    self.stockMinEntry:instantiate()
    self:addChild(self.stockMinEntry)
    y = y + ROW_H + PAD

    -- Stock max entry
    self.stockMaxLabel = ISLabel:new(x, y, ROW_H, "Stock Max:", 1, 1, 1, 1, UIFont.Small, true)
    self.stockMaxLabel:initialise()
    self:addChild(self.stockMaxLabel)

    local stockMaxDefault = ""
    if self.itemDef and self.itemDef.offer and self.itemDef.offer.stock then
        stockMaxDefault = tostring(self.itemDef.offer.stock.max or "")
    end
    self.stockMaxEntry = ISTextEntryBox:new(stockMaxDefault, x + labelW, y, w - labelW, ROW_H)
    self.stockMaxEntry:initialise()
    self.stockMaxEntry:instantiate()
    self:addChild(self.stockMaxEntry)
    y = y + ROW_H + 2

    self.stockHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, "Leave blank for unlimited stock", 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.stockHint:initialise()
    self:addChild(self.stockHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Enabled checkbox
    self.enabledCheck = ISTickBox:new(x, y, w, ROW_H, "")
    self.enabledCheck:initialise()
    self.enabledCheck:instantiate()
    self.enabledCheck:addOption("Enabled", nil)
    local isEnabled = not self.itemDef or self.itemDef.enabled ~= false
    self.enabledCheck:setSelected(1, isEnabled)
    self:addChild(self.enabledCheck)
    y = y + ROW_H + PAD * 2

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
end

function EditModal:onApply()
    local key = self.keyEntry:getText()
    if not key or key == "" then
        return
    end

    local def = {
        price = self.priceCombo:getSelectedText(),
        reward = self.rewardCombo:getSelectedText(),
        offer = {}
    }

    local weight = tonumber(self.weightEntry:getText())
    if weight then
        def.offer.weight = weight
    else
        def.offer.weight = 1.0
    end

    local stockMin = tonumber(self.stockMinEntry:getText())
    local stockMax = tonumber(self.stockMaxEntry:getText())
    if stockMin and stockMax then
        def.offer.stock = {
            min = math.floor(stockMin),
            max = math.floor(stockMax)
        }
    end

    if not self.enabledCheck:isSelected(1) then
        def.enabled = false
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

function EditModal:new(itemKey, itemDef, isNew, cb)
    local modalW = math.floor(380 * FONT_SCALE)
    local modalH = PAD * 12 + FONT_HGT_MEDIUM + ROW_H * 8 + FONT_HGT_SMALL + PAD * 2
    local core = getCore()
    local sx = (core:getScreenWidth() - modalW) / 2
    local sy = (core:getScreenHeight() - modalH) / 2

    local o = ISPanel:new(sx, sy, modalW, modalH)
    setmetatable(o, self)
    self.__index = self
    o.itemKey = itemKey or ""
    o.itemDef = itemDef
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
-- Main Items Panel
---------------------------------------------------------------------------

function UI.OnOpenPanel(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        local core = getCore()
        local width = math.floor(560 * FONT_SCALE)
        local height = math.floor(500 * FONT_SCALE)
        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2
        instance = UI:new(x, y, width, height, player)
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    instance:addToUIManager()
    instance:setVisible(true)
    instance:refreshItems()
    return instance
end

function UI.OnEditItem(player, itemKey)
    local items = Core.defs and Core.defs.items or require "PhunMart/defaults/items"
    local def = items[itemKey]
    if not def then return end
    local modal = EditModal:new(itemKey, def, false, function(key, editedDef)
        sendClientCommand(Core.name, Core.commands.upsertItemDef, {key = key, def = editedDef})
        if Core.defs and Core.defs.items then
            Core.defs.items[key] = editedDef
        end
        local inst = UI.instances[player:getPlayerNum()]
        if inst and inst:isVisible() then
            inst:refreshItems()
        end
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

function UI:refreshItems()
    self.datas:clear()
    self.datas:setVisible(false)

    local items = Core.defs and Core.defs.items or require "PhunMart/defaults/items"

    -- Sort keys alphabetically for stable display
    local keys = {}
    for k in pairs(items) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _, key in ipairs(keys) do
        local def = items[key]
        self.datas:addItem(key, {
            key = key,
            price = formatPrice(def),
            reward = formatReward(def),
            weight = formatWeight(def),
            enabled = formatEnabled(def),
            def = def
        })
    end
    self.datas:setVisible(true)
end

local function saveItemDef(self, key, def)
    sendClientCommand(Core.name, Core.commands.upsertItemDef, {key = key, def = def})
    if Core.defs and Core.defs.items then
        Core.defs.items[key] = def
    end
    self:refreshItems()
end

function UI:onAddClick()
    local modal = EditModal:new(nil, nil, true, function(key, def)
        saveItemDef(self, key, def)
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
        saveItemDef(self, key, def)
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

function UI:GridDoubleClick(item)
    local data = item
    local modal = EditModal:new(data.key, data.def, false, function(key, def)
        saveItemDef(self, key, def)
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
    self.title = ISLabel:new(x, y, FONT_HGT_MEDIUM, "Item Definitions", 1, 1, 1, 1, UIFont.Medium, true)
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

    local colPrice = math.floor(w * 0.38)
    local colReward = math.floor(w * 0.55)
    local colWeight = math.floor(w * 0.72)
    local colEnabled = math.floor(w * 0.85)
    self.datas:addColumn("Key", 0)
    self.datas:addColumn("Price", colPrice)
    self.datas:addColumn("Reward", colReward)
    self.datas:addColumn("Weight", colWeight)
    self.datas:addColumn("Enabled", colEnabled)
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

    local col1X = self.columns[1].size
    local col2X = self.columns[2].size
    local col3X = self.columns[3].size
    local col4X = self.columns[4].size
    local col5X = self.columns[5].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    -- Key column
    self:setStencilRect(col1X, clipY, col2X - col1X, clipY2 - clipY)
    self:drawText(data.key, xoffset, textY, 1, 1, 1, a, self.font)
    self:clearStencilRect()

    -- Price column
    self:setStencilRect(col2X, clipY, col3X - col2X, clipY2 - clipY)
    self:drawText(data.price, col2X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Reward column
    self:setStencilRect(col3X, clipY, col4X - col3X, clipY2 - clipY)
    self:drawText(data.reward, col3X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Weight column
    self:setStencilRect(col4X, clipY, col5X - col4X, clipY2 - clipY)
    self:drawText(data.weight, col4X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Enabled column
    local enabledColor = data.enabled == "Yes" and {0.4, 0.9, 0.4} or {0.9, 0.4, 0.4}
    self:drawText(data.enabled, col5X + 4, textY, enabledColor[1], enabledColor[2], enabledColor[3], a, self.font)

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
