if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
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

local CATEGORIES = {"playtime", "zombieKills", "sprinterKills"}

-- Return the threshold field name for a given category.
local function thresholdKey(category)
    if category == "playtime" then
        return "atMinutes"
    end
    return "kills"
end

-- Format a threshold value for display.
local function formatThreshold(category, entry)
    if category == "playtime" then
        local mins = entry.atMinutes or 0
        if mins >= 60 then
            return string.format("%dh %dm", math.floor(mins / 60), mins % 60)
        end
        return tostring(mins) .. "m"
    end
    return tostring(entry.kills or 0)
end

-- Summarise rewards for a milestone row.
local function formatRewards(entry)
    local parts = {}
    for _, r in ipairs(entry.rewards or {}) do
        local name = (r.item or ""):match("%.(.+)$") or r.item or "?"
        table.insert(parts, tostring(r.amount or 1) .. "x " .. name)
    end
    return table.concat(parts, ", ")
end

---------------------------------------------------------------------------
-- Edit / Add Modal
---------------------------------------------------------------------------
local EditModal = ISCollapsableWindowJoypad:derive("PhunRewardEditModal")

function EditModal:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local th = self:titleBarHeight()
    local x = PAD
    local y = th + PAD
    local w = self.width - PAD * 2
    local labelW = getTextManager():MeasureStringX(UIFont.Small, "Threshold: ") + 8

    -- Category combo
    self.categoryLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Category"), 1, 1, 1, 1, UIFont.Small, true)
    self.categoryLabel:initialise()
    self:addChild(self.categoryLabel)

    self.categoryCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H, self, EditModal.onCategoryChanged)
    self.categoryCombo:initialise()
    local selectedCat = 1
    for i, cat in ipairs(CATEGORIES) do
        self.categoryCombo:addOption(cat)
        if self.category == cat then
            selectedCat = i
        end
    end
    self.categoryCombo.selected = selectedCat
    if not self.isNew then
        self.categoryCombo:setEditable(false)
    end
    self:addChild(self.categoryCombo)
    y = y + ROW_H + PAD

    -- Threshold entry
    self.thresholdLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Threshold"), 1, 1, 1, 1, UIFont.Small,
        true)
    self.thresholdLabel:initialise()
    self:addChild(self.thresholdLabel)

    local threshDefault = ""
    if self.entry then
        threshDefault = tostring(self.entry[thresholdKey(self.category)] or "")
    end
    self.thresholdEntry = ISTextEntryBox:new(threshDefault, x + labelW, y, w - labelW, ROW_H)
    self.thresholdEntry:initialise()
    self.thresholdEntry:instantiate()
    self.thresholdEntry:setOnlyNumbers(true)
    self:addChild(self.thresholdEntry)
    y = y + ROW_H + 2

    self.thresholdHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, "", 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.thresholdHint:initialise()
    self:addChild(self.thresholdHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Item (picker)
    self.itemLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Item"), 1, 1, 1, 1, UIFont.Small, true)
    self.itemLabel:initialise()
    self:addChild(self.itemLabel)

    self._selectedItem = nil
    if self.entry and self.entry.rewards and self.entry.rewards[1] then
        self._selectedItem = self.entry.rewards[1].item
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

    -- Amount entry
    self.amountLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_RewardAmount"), 1, 1, 1, 1, UIFont.Small,
        true)
    self.amountLabel:initialise()
    self:addChild(self.amountLabel)

    local amountDefault = ""
    if self.entry and self.entry.rewards and self.entry.rewards[1] then
        amountDefault = tostring(self.entry.rewards[1].amount or 1)
    end
    self.amountEntry = ISTextEntryBox:new(amountDefault, x + labelW, y, w - labelW, ROW_H)
    self.amountEntry:initialise()
    self.amountEntry:instantiate()
    self.amountEntry:setOnlyNumbers(true)
    self:addChild(self.amountEntry)
    y = y + ROW_H + 2

    self.amountHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_RewardAmount"), 0.5, 0.5,
        0.5, 1, UIFont.Small, true)
    self.amountHint:initialise()
    self:addChild(self.amountHint)
    y = y + FONT_HGT_SMALL + PAD * 2

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

    self:onCategoryChanged()
end

function EditModal:onCategoryChanged()
    local cat = self.categoryCombo:getSelectedText()
    if cat == "playtime" then
        self.thresholdHint:setName(getText("IGUI_PhunMart_Hint_PlaytimeMinutes"))
    else
        self.thresholdHint:setName(getText("IGUI_PhunMart_Hint_KillCount"))
    end
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

function EditModal:onApply()
    local cat = self.categoryCombo:getSelectedText()
    local threshold = tonumber(self.thresholdEntry:getText())
    local item = self._selectedItem
    local amount = tonumber(self.amountEntry:getText())

    if not threshold or threshold <= 0 or not item or item == "" or not amount or amount <= 0 then
        return
    end

    local newEntry = {
        rewards = {{
            item = item,
            amount = math.floor(amount)
        }}
    }
    if cat == "playtime" then
        newEntry.atMinutes = math.floor(threshold)
    else
        newEntry.kills = math.floor(threshold)
    end

    if self.cb then
        self.cb(cat, newEntry, self.editIndex)
    end

    self:close()
end

function EditModal:onCancel()
    self:close()
end

function EditModal:new(category, entry, editIndex, isNew, cb)
    local modalW = math.floor(380 * FONT_SCALE)
    local modalH = PAD * 9 + FONT_HGT_MEDIUM + ROW_H * 4 + FONT_HGT_SMALL * 3 + PAD * 2
    local core = getCore()
    local sx = (core:getScreenWidth() - modalW) / 2
    local sy = (core:getScreenHeight() - modalH) / 2

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddReward") or
                          getText("IGUI_PhunMart_Title_EditReward")

    local o = ISCollapsableWindowJoypad:new(sx, sy, modalW, modalH)
    setmetatable(o, self)
    self.__index = self
    o.category = category or "playtime"
    o.entry = entry
    o.editIndex = editIndex
    o.isNew = isNew
    o.cb = cb
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 0.8}
    o:setTitle(titleText)
    return o
end

---------------------------------------------------------------------------
-- Main Rewards Panel (ListPanel subclass)
---------------------------------------------------------------------------

Core.ui.admin_rewards = ListPanel:derive("PhunRewardsAdminUI")
Core.ui.admin_rewards.instances = {}
local UI = Core.ui.admin_rewards

function UI.OnOpenPanel(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        local core = getCore()
        local width = math.floor(520 * FONT_SCALE)
        local height = math.floor(500 * FONT_SCALE)
        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2
        instance = UI:new(x, y, width, height, player)
        instance:setTitle(getText("IGUI_PhunMart_Title_RewardDefs"))
        instance.description = getText("IGUI_PhunMart_Desc_RewardDefs")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    instance:addToUIManager()
    instance:setVisible(true)
    instance:requestData()
    return instance
end

function UI:requestData()
    sendClientCommand(Core.name, Core.commands.getTokenRewards, {})
end

function UI:setData(cfg)
    self.cfg = cfg or {}
    self:refreshList()
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self.list.doDrawItem = self.drawRow
    self.list:setOnMouseDoubleClick(self, self.onDoubleClick)

    self:addListColumn(getText("IGUI_PhunMart_Col_Category"), 0)
    self:addListColumn(getText("IGUI_PhunMart_Col_Threshold"), 0.30)
    self:addListColumn(getText("IGUI_PhunMart_Col_Item"), 0.50)

    self:addBottomButton(getText("IGUI_PhunMart_Btn_New"), self.onAddClick)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), self.onEditClick, true)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Delete"), self.onDeleteClick, true)
end

function UI:getFilterText(itemData)
    return itemData.category .. " " .. itemData.threshold .. " " .. itemData.rewards
end

function UI:refreshList()
    self:clearList()

    local cfg = self.cfg or {}

    -- Build a flat list of all milestones with their category + index.
    self.flatList = {}
    for _, cat in ipairs(CATEGORIES) do
        local entries = cfg[cat] or {}
        for idx, entry in ipairs(entries) do
            table.insert(self.flatList, {
                category = cat,
                index = idx,
                entry = entry
            })
        end
    end

    -- Sort by category then threshold.
    table.sort(self.flatList, function(a, b)
        if a.category ~= b.category then
            return a.category < b.category
        end
        local aKey = thresholdKey(a.category)
        local bKey = thresholdKey(b.category)
        return (a.entry[aKey] or 0) < (b.entry[bKey] or 0)
    end)

    for i, row in ipairs(self.flatList) do
        self:addListItem(row.category .. "_" .. row.index, {
            flatIndex = i,
            category = row.category,
            entryIndex = row.index,
            threshold = formatThreshold(row.category, row.entry),
            rewards = formatRewards(row.entry),
            entry = row.entry
        })
    end
end

local function saveCfg(self)
    sendClientCommand(Core.name, Core.commands.saveTokenRewards, {
        cfg = self.cfg
    })
end

local function applyEdit(self, cat, newEntry, editIndex)
    self.cfg[cat] = self.cfg[cat] or {}
    if editIndex then
        self.cfg[cat][editIndex] = newEntry
    else
        table.insert(self.cfg[cat], newEntry)
    end
    saveCfg(self)
end

function UI:onAddClick()
    local modal = EditModal:new(nil, nil, nil, true, function(cat, newEntry, _editIndex)
        applyEdit(self, cat, newEntry, nil)
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
    local modal = EditModal:new(data.category, data.entry, data.entryIndex, false, function(cat, newEntry, editIndex)
        applyEdit(self, cat, newEntry, editIndex)
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

function UI:onDeleteClick()
    if not self.list.selected or self.list.selected == 0 then
        return
    end
    local selectedItem = self.list.items[self.list.selected]
    if not selectedItem then
        return
    end
    local data = selectedItem.item
    local cat = data.category
    local idx = data.entryIndex
    if self.cfg[cat] then
        table.remove(self.cfg[cat], idx)
    end
    saveCfg(self)
end

function UI:onDoubleClick(item)
    local modal = EditModal:new(item.category, item.entry, item.entryIndex, false, function(cat, newEntry, editIndex)
        applyEdit(self, cat, newEntry, editIndex)
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
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    -- Category column
    local catR, catG, catB = 1, 1, 1
    if data.category == "playtime" then
        catR, catG, catB = 0.5, 0.8, 1
    elseif data.category == "zombieKills" then
        catR, catG, catB = 1, 0.6, 0.6
    elseif data.category == "sprinterKills" then
        catR, catG, catB = 1, 0.4, 0.4
    end
    self:setStencilRect(col1X, clipY, col2X - col1X, clipY2 - clipY)
    self:drawText(data.category, xoffset, textY, catR, catG, catB, a, self.font)
    self:clearStencilRect()

    -- Threshold column
    self:setStencilRect(col2X, clipY, col3X - col2X, clipY2 - clipY)
    self:drawText(data.threshold, col2X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Rewards column
    local rightEdge = self.width - SCROLLBAR_W
    self:setStencilRect(col3X, clipY, rightEdge - col3X, clipY2 - clipY)
    self:drawText(data.rewards, col3X + 4, textY, 0.7, 0.7, 0.7, a, self.font)
    self:clearStencilRect()

    self.itemsHeight = y + self.itemheight
    return self.itemsHeight
end

---------------------------------------------------------------------------
-- Command handlers
---------------------------------------------------------------------------
local Commands = {}

if Core.isLocal then

    Commands[Core.commands.getTokenRewards] = function(player, args)
        local ok, tokenDefaults = pcall(require, "PhunMart/defaults/token_rewards")
        local cfg = Core.tokenRewardsCfg or (ok and tokenDefaults) or {}
        for _, instance in pairs(UI.instances or {}) do
            instance:setData(cfg)
        end
    end

    Commands[Core.commands.saveTokenRewards] = function(player, args)
        Core.tokenRewardsCfg = args.cfg or {}
        -- In SP, also persist via fileUtils if available on the server side.
        if Core.fileUtils and Core.fileUtils.saveTable then
            Core.fileUtils.saveTable("PhunMart_TokenRewards.lua", Core.tokenRewardsCfg)
        end
        if Core.playtimeRewards then Core.playtimeRewards:load() end
        if Core.killRewards then Core.killRewards:load() end
        for _, instance in pairs(UI.instances or {}) do
            instance:setData(Core.tokenRewardsCfg)
        end
    end

    Events.OnClientCommand.Add(function(module, command, playerObj, arguments)
        if module == Core.name and Commands[command] then
            Commands[command](playerObj, arguments)
        end
    end)

else

    Commands[Core.commands.getTokenRewards] = function(args)
        for _, instance in pairs(UI.instances or {}) do
            instance:setData(args.cfg)
        end
    end

    Events.OnServerCommand.Add(function(module, command, arguments)
        if module == Core.name and Commands[command] then
            Commands[command](arguments)
        end
    end)

end
