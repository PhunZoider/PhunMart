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

local windowName = "PhunRewardsAdminUI"

Core.ui.admin_rewards = ISPanel:derive(windowName)
Core.ui.admin_rewards.instances = {}
local UI = Core.ui.admin_rewards

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
local EditModal = ISPanel:derive("PhunRewardEditModal")

function EditModal:createChildren()
    ISPanel.createChildren(self)

    local x = PAD
    local y = PAD
    local w = self.width - PAD * 2
    local labelW = getTextManager():MeasureStringX(UIFont.Small, "Threshold: ") + 8

    -- Title
    local titleText = self.isNew and getText("IGUI_PhunMart_Title_AddReward") or
                          getText("IGUI_PhunMart_Title_EditReward")
    self.titleLabel = ISLabel:new(x, y, FONT_HGT_MEDIUM, titleText, 1, 1, 1, 1, UIFont.Medium, true)
    self.titleLabel:initialise()
    self:addChild(self.titleLabel)
    y = y + FONT_HGT_MEDIUM + PAD

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

    -- Item entry
    self.itemLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Item"), 1, 1, 1, 1, UIFont.Small, true)
    self.itemLabel:initialise()
    self:addChild(self.itemLabel)

    local itemDefault = ""
    if self.entry and self.entry.rewards and self.entry.rewards[1] then
        itemDefault = self.entry.rewards[1].item or ""
    end
    self.itemEntry = ISTextEntryBox:new(itemDefault, x + labelW, y, w - labelW, ROW_H)
    self.itemEntry:initialise()
    self.itemEntry:instantiate()
    self:addChild(self.itemEntry)
    y = y + ROW_H + 2

    self.itemHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_RewardItem"), 0.5, 0.5,
        0.5, 1, UIFont.Small, true)
    self.itemHint:initialise()
    self:addChild(self.itemHint)
    y = y + FONT_HGT_SMALL + PAD

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

function EditModal:onApply()
    local cat = self.categoryCombo:getSelectedText()
    local threshold = tonumber(self.thresholdEntry:getText())
    local item = self.itemEntry:getText()
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

function EditModal:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function EditModal:new(category, entry, editIndex, isNew, cb)
    local modalW = math.floor(380 * FONT_SCALE)
    local modalH = PAD * 9 + FONT_HGT_MEDIUM + ROW_H * 4 + FONT_HGT_SMALL * 3 + PAD * 2
    local core = getCore()
    local sx = (core:getScreenWidth() - modalW) / 2
    local sy = (core:getScreenHeight() - modalH) / 2

    local o = ISPanel:new(sx, sy, modalW, modalH)
    setmetatable(o, self)
    self.__index = self
    o.category = category or "playtime"
    o.entry = entry
    o.editIndex = editIndex
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
-- Main Rewards Panel
---------------------------------------------------------------------------

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

function UI:refreshList()
    self.datas:clear()
    self.datas:setVisible(false)

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
        self.datas:addItem(row.category .. "_" .. row.index, {
            flatIndex = i,
            category = row.category,
            entryIndex = row.index,
            threshold = formatThreshold(row.category, row.entry),
            rewards = formatRewards(row.entry),
            entry = row.entry
        })
    end
    self.datas:setVisible(true)
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
    if not self.datas.selected or self.datas.selected == 0 then
        return
    end
    local selectedItem = self.datas.items[self.datas.selected]
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
    if not self.datas.selected or self.datas.selected == 0 then
        return
    end
    local selectedItem = self.datas.items[self.datas.selected]
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

function UI:GridDoubleClick(item)
    local data = item
    local modal = EditModal:new(data.category, data.entry, data.entryIndex, false, function(cat, newEntry, editIndex)
        applyEdit(self, cat, newEntry, editIndex)
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
    self.title = ISLabel:new(x, y, FONT_HGT_MEDIUM, getText("IGUI_PhunMart_Title_RewardDefs"), 1, 1, 1, 1,
        UIFont.Medium, true)
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

    -- Toolbar: Add / Edit / Delete buttons
    local btnW = math.floor(70 * FONT_SCALE)
    local gap = math.floor(5 * FONT_SCALE)

    self.addButton = ISButton:new(x, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Add"), self, UI.onAddClick)
    self.addButton:initialise()
    self:addChild(self.addButton)

    self.editButton = ISButton:new(x + btnW + gap, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Edit"), self,
        UI.onEditClick)
    self.editButton:initialise()
    self:addChild(self.editButton)

    self.deleteButton = ISButton:new(x + (btnW + gap) * 2, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Delete"), self,
        UI.onDeleteClick)
    self.deleteButton:initialise()
    self:addChild(self.deleteButton)

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

    local colThreshold = math.floor(w * 0.30)
    local colItem = math.floor(w * 0.50)
    local colAmount = math.floor(w * 0.75)
    self.datas:addColumn(getText("IGUI_PhunMart_Col_Category"), 0)
    self.datas:addColumn(getText("IGUI_PhunMart_Col_Threshold"), colThreshold)
    self.datas:addColumn(getText("IGUI_PhunMart_Col_Item"), colItem)
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
    o.cfg = {}
    o.flatList = {}
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
