if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local CategoryPicker = require "PhunMart_Client/ui/base/category_picker"
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

local function getSortedKeys(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

-- Format the price column.
local function formatPrice(def)
    if def.defaults and def.defaults.price then
        return def.defaults.price
    end
    return ""
end

-- Format the include summary: categories + item count.
local function formatInclude(def)
    local parts = {}
    if def.include then
        if def.include.categories then
            table.insert(parts, table.concat(def.include.categories, ", "))
        end
        if def.include.items then
            table.insert(parts, getText("IGUI_PhunMart_NItems", tostring(#def.include.items)))
        end
    end
    if #parts == 0 then
        return ""
    end
    return table.concat(parts, " + ")
end

-- Format the blacklist summary.
local function formatBlacklist(def)
    local count = 0
    if def.blacklist then
        count = count + #def.blacklist
    end
    if def.blacklistCategories then
        count = count + #def.blacklistCategories
    end
    if count == 0 then
        return ""
    end
    return tostring(count)
end

-- Format weight for display.
local function formatWeight(def)
    if def.defaults and def.defaults.offer and def.defaults.offer.weight then
        return tostring(def.defaults.offer.weight)
    end
    return ""
end

---------------------------------------------------------------------------
-- Edit / Add Modal
---------------------------------------------------------------------------
local EditModal = ISCollapsableWindowJoypad:derive("PhunGroupEditModal")

function EditModal:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local th = self:titleBarHeight()
    local x = PAD
    local y = th + PAD
    local w = self.width - PAD * 2
    local labelW = getTextManager():MeasureStringX(UIFont.Small, "Blacklist Cats: ") + 8

    -- Key entry
    self.keyLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Key"), 1, 1, 1, 1, UIFont.Small, true)
    self.keyLabel:initialise()
    self:addChild(self.keyLabel)

    self.keyEntry = ISTextEntryBox:new(self.groupKey or "", x + labelW, y, w - labelW, ROW_H)
    self.keyEntry:initialise()
    self.keyEntry:instantiate()
    if not self.isNew then
        self.keyEntry:setEditable(false)
    end
    self:addChild(self.keyEntry)
    y = y + ROW_H + PAD

    -- Label entry (optional display label)
    self.labelLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Label"), 1, 1, 1, 1, UIFont.Small, true)
    self.labelLabel:initialise()
    self:addChild(self.labelLabel)

    local labelDefault = (self.groupDef and self.groupDef.label) or ""
    self.labelEntry = ISTextEntryBox:new(labelDefault, x + labelW, y, w - labelW, ROW_H)
    self.labelEntry:initialise()
    self.labelEntry:instantiate()
    self:addChild(self.labelEntry)
    y = y + ROW_H + 2

    self.labelHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_OptionalDefault"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.labelHint:initialise()
    self:addChild(self.labelHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Default Price combo
    self.priceLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Price"), 1, 1, 1, 1, UIFont.Small, true)
    self.priceLabel:initialise()
    self:addChild(self.priceLabel)

    self.priceCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H)
    self.priceCombo:initialise()
    self.priceCombo:addOption("")
    local prices = Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"
    local priceKeys = getSortedKeys(prices)
    local selectedPriceIdx = 1
    for i, pk in ipairs(priceKeys) do
        self.priceCombo:addOption(pk)
        if self.groupDef and self.groupDef.defaults and self.groupDef.defaults.price == pk then
            selectedPriceIdx = i + 1 -- +1 for blank
        end
    end
    self.priceCombo.selected = selectedPriceIdx
    self:addChild(self.priceCombo)
    y = y + ROW_H + 2

    self.priceHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_OptionalDefault"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.priceHint:initialise()
    self:addChild(self.priceHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Default Reward combo (optional -- used by vehicle groups)
    self.specialLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Special"), 1, 1, 1, 1, UIFont.Small, true)
    self.specialLabel:initialise()
    self:addChild(self.specialLabel)

    self.specialCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H)
    self.specialCombo:initialise()
    self.specialCombo:addOption("")
    local specials = Core.defs and Core.defs.specials or require "PhunMart/defaults/specials"
    local specialKeys = getSortedKeys(specials)
    local selectedSpecialIdx = 1
    for i, rk in ipairs(specialKeys) do
        self.specialCombo:addOption(rk)
        if self.groupDef and self.groupDef.defaults and self.groupDef.defaults.reward == rk then
            selectedSpecialIdx = i + 1 -- +1 for blank
        end
    end
    self.specialCombo.selected = selectedSpecialIdx
    self:addChild(self.specialCombo)
    y = y + ROW_H + 2

    self.specialHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_OptionalDefault"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.specialHint:initialise()
    self:addChild(self.specialHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Default Weight entry
    self.weightLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Weight"), 1, 1, 1, 1, UIFont.Small, true)
    self.weightLabel:initialise()
    self:addChild(self.weightLabel)

    local weightDefault = "1.0"
    if self.groupDef and self.groupDef.defaults and self.groupDef.defaults.offer and self.groupDef.defaults.offer.weight then
        weightDefault = tostring(self.groupDef.defaults.offer.weight)
    end
    self.weightEntry = ISTextEntryBox:new(weightDefault, x + labelW, y, w - labelW, ROW_H)
    self.weightEntry:initialise()
    self.weightEntry:instantiate()
    self:addChild(self.weightEntry)
    y = y + ROW_H + 2

    self.weightHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL,
        getText("IGUI_PhunMart_Hint_WeightOverride"), 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.weightHint:initialise()
    self:addChild(self.weightHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Include Categories (picker)
    self.catsLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Categories"), 1, 1, 1, 1, UIFont.Small, true)
    self.catsLabel:initialise()
    self:addChild(self.catsLabel)

    self._selectedCats = {}
    if self.groupDef and self.groupDef.include and self.groupDef.include.categories then
        for _, c in ipairs(self.groupDef.include.categories) do
            table.insert(self._selectedCats, c)
        end
    end

    local pickBtnW = math.max(math.floor(60 * FONT_SCALE),
        getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Btn_Pick")) + PAD * 2)
    self.catsPickBtn = ISButton:new(x + w - pickBtnW, y, pickBtnW, ROW_H, getText("IGUI_PhunMart_Btn_Pick"), self, EditModal.onPickCats)
    self.catsPickBtn:initialise()
    self:addChild(self.catsPickBtn)

    self.catsDisplay = ISLabel:new(x + labelW, y, ROW_H, "", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self.catsDisplay:initialise()
    self:addChild(self.catsDisplay)
    self:refreshCatsDisplay()
    y = y + ROW_H + PAD

    -- Include Items (picker)
    self.itemsLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Items"), 1, 1, 1, 1, UIFont.Small, true)
    self.itemsLabel:initialise()
    self:addChild(self.itemsLabel)

    self._selectedItems = {}
    if self.groupDef and self.groupDef.include and self.groupDef.include.items then
        for _, item in ipairs(self.groupDef.include.items) do
            table.insert(self._selectedItems, item)
        end
    end

    local itemPickBtnW = math.max(math.floor(60 * FONT_SCALE),
        getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Btn_Pick")) + PAD * 2)
    self.itemsPickBtn = ISButton:new(x + w - itemPickBtnW, y, itemPickBtnW, ROW_H, getText("IGUI_PhunMart_Btn_Pick"), self, EditModal.onPickItems)
    self.itemsPickBtn:initialise()
    self:addChild(self.itemsPickBtn)

    self.itemsDisplay = ISLabel:new(x + labelW, y, ROW_H, "", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self.itemsDisplay:initialise()
    self:addChild(self.itemsDisplay)
    self:refreshItemsDisplay()
    y = y + ROW_H + PAD

    -- Blacklist items (picker)
    self.blLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_BlacklistItems"), 1, 1, 1, 1, UIFont.Small, true)
    self.blLabel:initialise()
    self:addChild(self.blLabel)

    self._selectedBlItems = {}
    if self.groupDef and self.groupDef.blacklist then
        for _, item in ipairs(self.groupDef.blacklist) do
            table.insert(self._selectedBlItems, item)
        end
    end

    local blItemPickBtnW = math.max(math.floor(60 * FONT_SCALE),
        getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Btn_Pick")) + PAD * 2)
    self.blPickBtn = ISButton:new(x + w - blItemPickBtnW, y, blItemPickBtnW, ROW_H, getText("IGUI_PhunMart_Btn_Pick"), self, EditModal.onPickBlItems)
    self.blPickBtn:initialise()
    self:addChild(self.blPickBtn)

    self.blDisplay = ISLabel:new(x + labelW, y, ROW_H, "", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self.blDisplay:initialise()
    self:addChild(self.blDisplay)
    self:refreshBlItemsDisplay()
    y = y + ROW_H + PAD

    -- Blacklist Categories (picker)
    self.blCatsLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_BlacklistCats"), 1, 1, 1, 1, UIFont.Small, true)
    self.blCatsLabel:initialise()
    self:addChild(self.blCatsLabel)

    self._selectedBlCats = {}
    if self.groupDef and self.groupDef.blacklistCategories then
        for _, c in ipairs(self.groupDef.blacklistCategories) do
            table.insert(self._selectedBlCats, c)
        end
    end

    local blPickBtnW = math.max(math.floor(60 * FONT_SCALE),
        getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Btn_Pick")) + PAD * 2)
    self.blCatsPickBtn = ISButton:new(x + w - blPickBtnW, y, blPickBtnW, ROW_H, getText("IGUI_PhunMart_Btn_Pick"), self, EditModal.onPickBlCats)
    self.blCatsPickBtn:initialise()
    self:addChild(self.blCatsPickBtn)

    self.blCatsDisplay = ISLabel:new(x + labelW, y, ROW_H, "", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self.blCatsDisplay:initialise()
    self:addChild(self.blCatsDisplay)
    self:refreshBlCatsDisplay()
    y = y + ROW_H + PAD * 2

    -- Buttons
    local btnW = math.floor(80 * FONT_SCALE)
    local btnGap = PAD
    local totalBtnW = btnW * 2 + btnGap
    local btnX = (self.width - totalBtnW) / 2

    self.applyBtn = ISButton:new(btnX, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Apply"), self, EditModal.onApply)
    self.applyBtn:initialise()
    self:addChild(self.applyBtn)

    self.cancelBtn = ISButton:new(btnX + btnW + btnGap, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Cancel"), self,
        EditModal.onCancel)
    self.cancelBtn:initialise()
    if self.cancelBtn.enableCancelColor then
        self.cancelBtn:enableCancelColor()
    end
    self:addChild(self.cancelBtn)
end

function EditModal:refreshCatsDisplay()
    local text = #self._selectedCats > 0 and table.concat(self._selectedCats, ", ") or getText("IGUI_PhunMart_Lbl_None")
    self.catsDisplay:setName(text)
end

function EditModal:refreshBlCatsDisplay()
    local text = #self._selectedBlCats > 0 and table.concat(self._selectedBlCats, ", ") or getText("IGUI_PhunMart_Lbl_None")
    self.blCatsDisplay:setName(text)
end

function EditModal:onPickCats()
    local modal = self
    CategoryPicker.open(getSpecificPlayer(0), self._selectedCats, function(keys)
        modal._selectedCats = keys or {}
        modal:refreshCatsDisplay()
    end)
end

-- Format a list of item keys as "Name1, Name2, Name3 and X others" or "(none)".
local function formatItemList(keys)
    local count = #keys
    if count == 0 then
        return getText("IGUI_PhunMart_Lbl_None")
    end
    local names = {}
    local limit = math.min(count, 3)
    for i = 1, limit do
        local si = getScriptManager():getItem(keys[i])
        names[i] = si and si:getDisplayName() or keys[i]
    end
    local text = table.concat(names, ", ")
    if count > 3 then
        text = text .. " +" .. tostring(count - 3) .. " more"
    end
    return text
end

function EditModal:refreshItemsDisplay()
    self.itemsDisplay:setName(formatItemList(self._selectedItems))
end

function EditModal:refreshBlItemsDisplay()
    self.blDisplay:setName(formatItemList(self._selectedBlItems))
end

function EditModal:onPickItems()
    local modal = self
    ItemPicker.open(getSpecificPlayer(0), self._selectedItems, function(keys)
        modal._selectedItems = keys or {}
        modal:refreshItemsDisplay()
    end)
end

function EditModal:onPickBlItems()
    local modal = self
    ItemPicker.open(getSpecificPlayer(0), self._selectedBlItems, function(keys)
        modal._selectedBlItems = keys or {}
        modal:refreshBlItemsDisplay()
    end)
end

function EditModal:onPickBlCats()
    local modal = self
    CategoryPicker.open(getSpecificPlayer(0), self._selectedBlCats, function(keys)
        modal._selectedBlCats = keys or {}
        modal:refreshBlCatsDisplay()
    end)
end

function EditModal:onApply()
    local key = self.keyEntry:getText()
    if not key or key == "" then
        return
    end

    local def = {
        defaults = {
            offer = {}
        }
    }

    -- Price (optional)
    local priceText = self.priceCombo:getSelectedText()
    if priceText ~= "" then
        def.defaults.price = priceText
    end

    -- Special (optional)
    local specialText = self.specialCombo:getSelectedText()
    if specialText ~= "" then
        def.defaults.reward = specialText
    end

    -- Weight
    local weight = tonumber(self.weightEntry:getText())
    def.defaults.offer.weight = weight or 1.0

    -- Label (optional)
    local labelText = self.labelEntry:getText()
    if labelText ~= "" then
        def.label = labelText
    end

    -- Include
    local cats = #self._selectedCats > 0 and self._selectedCats or nil
    local items = #self._selectedItems > 0 and self._selectedItems or nil
    if cats or items then
        def.include = {}
        if cats then
            def.include.categories = cats
        end
        if items then
            def.include.items = items
        end
    end

    -- Blacklist
    if #self._selectedBlItems > 0 then
        def.blacklist = self._selectedBlItems
    end

    -- Blacklist categories
    if #self._selectedBlCats > 0 then
        def.blacklistCategories = self._selectedBlCats
    end

    if self.cb then
        self.cb(key, def)
    end

    self:close()
end

function EditModal:onCancel()
    self:close()
end

function EditModal:new(groupKey, groupDef, isNew, cb)
    local modalW = math.floor(480 * FONT_SCALE)
    local modalH = PAD * 14 + FONT_HGT_MEDIUM + ROW_H * 10 + FONT_HGT_SMALL * 8 + PAD * 4
    local core = getCore()
    local sx = (core:getScreenWidth() - modalW) / 2
    local sy = (core:getScreenHeight() - modalH) / 2

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddGroup") or getText("IGUI_PhunMart_Title_EditX", groupKey or "")

    local o = ISCollapsableWindowJoypad:new(sx, sy, modalW, modalH)
    setmetatable(o, self)
    self.__index = self
    o.groupKey = groupKey or ""
    o.groupDef = groupDef
    o.isNew = isNew
    o.cb = cb
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 0.8}
    o:setTitle(titleText)
    return o
end

---------------------------------------------------------------------------
-- Main Groups Panel (ListPanel subclass)
---------------------------------------------------------------------------

Core.ui.admin_groups = ListPanel:derive("PhunGroupsAdminUI")
Core.ui.admin_groups.instances = {}
local UI = Core.ui.admin_groups

function UI.OnOpenPanel(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        local core = getCore()
        local width = math.floor(620 * FONT_SCALE)
        local height = math.floor(500 * FONT_SCALE)
        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2
        instance = UI:new(x, y, width, height, player)
        instance:setTitle(getText("IGUI_PhunMart_Title_GroupDefs"))
        instance.description = getText("IGUI_PhunMart_Desc_GroupDefs")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    instance:addToUIManager()
    instance:setVisible(true)
    instance:refreshGroups()
    return instance
end

function UI.OnEditGroup(player, groupKey)
    local groups = Core.defs and Core.defs.groups or require "PhunMart/defaults/groups"
    local def = groups[groupKey]
    if not def then return end
    local modal = EditModal:new(groupKey, def, false, function(key, editedDef)
        sendClientCommand(Core.name, Core.commands.upsertGroupDef, {key = key, def = editedDef})
        if not Core.isLocal and Core.defs and Core.defs.groups then
            Core.defs.groups[key] = editedDef
        end
        -- Refresh open list panel if any
        local inst = UI.instances[player:getPlayerNum()]
        if inst and inst:isVisible() then
            inst:refreshGroups()
        end
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self.list.doDrawItem = self.drawRow
    self.list:setOnMouseDoubleClick(self, self.onDoubleClick)

    self:addListColumn(getText("IGUI_PhunMart_Col_Key"), 0)
    self:addListColumn(getText("IGUI_PhunMart_Col_Price"), 0.25)
    self:addListColumn(getText("IGUI_PhunMart_Col_Include"), 0.42)
    self:addListColumn(getText("IGUI_PhunMart_Col_BL"), 0.75)
    self:addListColumn(getText("IGUI_PhunMart_Col_Weight"), 0.87)

    self:addBottomButton(getText("IGUI_PhunMart_Btn_New"), self.onAddClick)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), self.onEditClick, true)
end

function UI:getFilterText(itemData)
    return itemData.key .. " " .. itemData.price .. " " .. itemData.include
end

function UI:refreshGroups()
    self:clearList()

    local groups = Core.defs and Core.defs.groups or require "PhunMart/defaults/groups"

    local keys = {}
    for k in pairs(groups) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _, key in ipairs(keys) do
        local def = groups[key]
        self:addListItem(key, {
            key = key,
            price = formatPrice(def),
            include = formatInclude(def),
            blacklist = formatBlacklist(def),
            weight = formatWeight(def),
            def = def
        })
    end
end

local function saveGroupDef(self, key, def)
    sendClientCommand(Core.name, Core.commands.upsertGroupDef, {key = key, def = def})
    if not Core.isLocal and Core.defs and Core.defs.groups then
        Core.defs.groups[key] = def
    end
    self:refreshGroups()
end

function UI:onAddClick()
    local modal = EditModal:new(nil, nil, true, function(key, def)
        saveGroupDef(self, key, def)
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
        saveGroupDef(self, key, def)
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

function UI:onDoubleClick(item)
    local modal = EditModal:new(item.key, item.def, false, function(key, def)
        saveGroupDef(self, key, def)
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

    -- Include column
    self:setStencilRect(col3X, clipY, col4X - col3X, clipY2 - clipY)
    self:drawText(data.include, col3X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Blacklist column
    self:setStencilRect(col4X, clipY, col5X - col4X, clipY2 - clipY)
    if data.blacklist ~= "" then
        self:drawText(data.blacklist, col4X + 4, textY, 0.9, 0.5, 0.5, a, self.font)
    end
    self:clearStencilRect()

    -- Weight column
    self:drawText(data.weight, col5X + 4, textY, 0.8, 0.8, 0.8, a, self.font)

    self.itemsHeight = y + self.itemheight
    return self.itemsHeight
end
