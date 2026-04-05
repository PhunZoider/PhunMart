if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
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

-- Return whether an entry is a recurring reward.
local function isRecurring(category, entry)
    if category == "playtime" then
        return entry.everyMinutes ~= nil
    end
    return entry.everyKills ~= nil
end

-- Return the threshold field name for a given category and recurring flag.
local function thresholdKey(category, recurring)
    if category == "playtime" then
        return recurring and "everyMinutes" or "atMinutes"
    end
    return recurring and "everyKills" or "kills"
end

-- Format a threshold value for display.
local function formatThreshold(category, entry)
    local recurring = isRecurring(category, entry)
    local prefix = recurring and "every " or "at "
    if category == "playtime" then
        local mins = (recurring and entry.everyMinutes or entry.atMinutes) or 0
        local timeStr
        if mins >= 60 then
            timeStr = string.format("%dh %dm", math.floor(mins / 60), mins % 60)
        else
            timeStr = tostring(mins) .. "m"
        end
        return prefix .. timeStr
    end
    local count = (recurring and entry.everyKills or entry.kills) or 0
    return prefix .. tostring(count)
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

local function updateThresholdHint(form, cat)
    if cat == "playtime" then
        form:setHintText("threshold", getText("IGUI_PhunMart_Hint_PlaytimeMinutes"))
    else
        form:setHintText("threshold", getText("IGUI_PhunMart_Hint_KillCount"))
    end
end

local function createEditModal(category, entry, editIndex, isNew, cb)
    category = category or "playtime"

    -- Pre-compute defaults from entry
    local recurringDefault = entry and isRecurring(category, entry) or false
    local threshDefault = ""
    if entry then
        threshDefault = tostring(entry[thresholdKey(category, recurringDefault)] or "")
    end

    -- Collect selected items from existing rewards
    local selectedItems = {}
    if entry and entry.rewards then
        for _, r in ipairs(entry.rewards) do
            if r.item then table.insert(selectedItems, r.item) end
        end
    end

    local amountDefault = ""
    if entry and entry.rewards and entry.rewards[1] then
        amountDefault = tostring(entry.rewards[1].amount or 1)
    end

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddReward") or
                          getText("IGUI_PhunMart_Title_EditReward")

    local form = FormPanel:new({
        width = math.floor(380 * FONT_SCALE),
        title = titleText,
        onApply = function(f)
            local cat = f:getFieldValue("category")
            local recurring = f:getFieldValue("recurring")
            local threshold = f:getFieldNumber("threshold")
            local items = f:getFieldValue("items")
            local amount = f:getFieldNumber("amount")

            if not threshold or threshold <= 0 or not items or #items == 0 or not amount or amount <= 0 then
                return
            end

            local rewards = {}
            for _, item in ipairs(items) do
                table.insert(rewards, { item = item, amount = math.floor(amount) })
            end

            local newEntry = { rewards = rewards }
            newEntry[thresholdKey(cat, recurring)] = math.floor(threshold)

            if cb then
                cb(cat, newEntry, editIndex)
            end

            f:close()
        end,
    })

    form:addComboField("category", getText("IGUI_PhunMart_Lbl_Category"), {
        options = CATEGORIES,
        selected = category,
        editable = isNew,
        onChange = function(f)
            local cat = f:getFieldValue("category")
            updateThresholdHint(f, cat)
        end,
    })
    form:addCheckField("recurring", getText("IGUI_PhunMart_Lbl_Recurring"), {
        checked = recurringDefault,
    })
    form:addTextField("threshold", getText("IGUI_PhunMart_Lbl_Threshold"), {
        default = threshDefault,
        numbersOnly = true,
        hint = " ",  -- placeholder; updated after initialise
    })
    form:addPickerField("items", getText("IGUI_PhunMart_Lbl_Item"), {
        value = selectedItems,
        display = formatItemList(selectedItems),
        onPick = function(f, field)
            ItemPicker.open(getSpecificPlayer(0), selectedItems, function(keys)
                selectedItems = keys or {}
                f:setPickerValue("items", selectedItems, formatItemList(selectedItems))
            end)
        end,
    })
    form:addTextField("amount", getText("IGUI_PhunMart_Lbl_RewardAmount"), {
        default = amountDefault,
        numbersOnly = true,
        hint = getText("IGUI_PhunMart_Hint_RewardAmount"),
    })

    form:initialise()

    -- Set initial threshold hint based on category
    updateThresholdHint(form, category)

    -- If editing, disable the category combo
    if not isNew then
        local catField = form._fieldsByKey["category"]
        if catField and catField._combo then
            catField._combo:setEditable(false)
        end
    end

    form:addToUIManager()
    form:bringToTop()
    return form
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
        local aKey = thresholdKey(a.category, isRecurring(a.category, a.entry))
        local bKey = thresholdKey(b.category, isRecurring(b.category, b.entry))
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
    createEditModal(nil, nil, nil, true, function(cat, newEntry, _editIndex)
        applyEdit(self, cat, newEntry, nil)
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
    createEditModal(data.category, data.entry, data.entryIndex, false, function(cat, newEntry, editIndex)
        applyEdit(self, cat, newEntry, editIndex)
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
    local data = selectedItem.item
    local cat = data.category
    local idx = data.entryIndex
    if self.cfg[cat] then
        table.remove(self.cfg[cat], idx)
    end
    saveCfg(self)
end

function UI:onDoubleClick(item)
    createEditModal(item.category, item.entry, item.entryIndex, false, function(cat, newEntry, editIndex)
        applyEdit(self, cat, newEntry, editIndex)
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
