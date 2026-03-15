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

local windowName = "PhunWalletAdminUI"

Core.ui.admin = ISPanel:derive(windowName);
Core.ui.admin.instances = {}
local UI = Core.ui.admin

local function refreshPlayers()
    sendClientCommand(Core.name, Core.commands.getPlayerList, {})
end

local function refreshPlayerWallet(playername)
    sendClientCommand(Core.name, Core.commands.getPlayersWallet, {
        playername = playername
    })
end

-- Format a pool balance for display based on its format type.
local function formatBalance(amount, format)
    amount = amount or 0
    if format == "cents" then
        local dollars = math.floor(amount / 100)
        local cents = amount % 100
        return string.format("$%d.%02d", dollars, cents)
    else
        -- Integer count with thousand separators
        local s = tostring(math.floor(amount + 0.5)):reverse():gsub("(%d%d%d)", "%1,")
        return s:reverse():gsub("^,", "")
    end
end

-- Parse user-entered amount text into raw internal value.
local function parseAmount(text, format)
    local num = tonumber(text)
    if not num or num < 0 then
        return nil
    end
    if format == "cents" then
        return math.floor(num * 100 + 0.5)
    end
    return math.floor(num + 0.5)
end

---------------------------------------------------------------------------
-- Edit Modal
---------------------------------------------------------------------------
local EditModal = ISPanel:derive("PhunWalletEditModal")

function EditModal:createChildren()
    ISPanel.createChildren(self)

    local x = PAD
    local y = PAD
    local w = self.width - PAD * 2

    -- Title
    local titleText = self.poolLabel .. " — " .. self.playerName
    self.titleLabel = ISLabel:new(x, y, FONT_HGT_MEDIUM, titleText, 1, 1, 1, 1, UIFont.Medium, true)
    self.titleLabel:initialise()
    self:addChild(self.titleLabel)
    y = y + FONT_HGT_MEDIUM + PAD

    -- Current balance
    self.currentLabel = ISLabel:new(x, y, ROW_H, "Current: " .. self.currentFormatted, 0.8, 0.8, 0.8, 1, UIFont.Small,
        true)
    self.currentLabel:initialise()
    self:addChild(self.currentLabel)
    y = y + ROW_H + PAD

    -- Action combo
    local labelW = getTextManager():MeasureStringX(UIFont.Small, "Amount: ") + 8
    self.actionLabel = ISLabel:new(x, y, ROW_H, "Action:", 1, 1, 1, 1, UIFont.Small, true)
    self.actionLabel:initialise()
    self:addChild(self.actionLabel)

    self.actionCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H)
    self.actionCombo:initialise()
    self.actionCombo:addOption("Add")
    self.actionCombo:addOption("Subtract")
    self.actionCombo:addOption("Set to")
    self:addChild(self.actionCombo)
    y = y + ROW_H + PAD

    -- Amount entry
    self.amountLabel = ISLabel:new(x, y, ROW_H, "Amount:", 1, 1, 1, 1, UIFont.Small, true)
    self.amountLabel:initialise()
    self:addChild(self.amountLabel)

    self.amountEntry = ISTextEntryBox:new("0", x + labelW, y, w - labelW, ROW_H)
    self.amountEntry:initialise()
    self.amountEntry:instantiate()
    if self.format ~= "cents" then
        self.amountEntry:setOnlyNumbers(true)
    end
    self:addChild(self.amountEntry)
    y = y + ROW_H + 2

    -- Format hint
    local hint = self.format == "cents" and "Enter as dollars (e.g. 5.00)" or "Enter whole number"
    self.hintLabel = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, hint, 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.hintLabel:initialise()
    self:addChild(self.hintLabel)
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
end

function EditModal:onApply()
    local raw = parseAmount(self.amountEntry:getText(), self.format)
    if not raw then
        return
    end

    local op = self.actionCombo:getSelectedText()
    local value
    if op == "Add" then
        value = raw
    elseif op == "Subtract" then
        value = -raw
    elseif op == "Set to" then
        value = raw - self.rawAmount
    end

    sendClientCommand(Core.name, Core.commands.adjustPlayerWallet, {
        playername = self.playerName,
        walletType = self.walletType,
        pool = self.pool,
        value = tostring(value)
    })

    self:close()
end

function EditModal:onCancel()
    self:close()
end

function EditModal:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function EditModal:new(playerName, walletType, pool, poolLabel, rawAmount, format)
    local modalW = math.floor(300 * FONT_SCALE)
    local modalH = PAD * 7 + FONT_HGT_MEDIUM + ROW_H * 3 + FONT_HGT_SMALL + PAD + 25
    local core = getCore()
    local sx = (core:getScreenWidth() - modalW) / 2
    local sy = (core:getScreenHeight() - modalH) / 2

    local o = ISPanel:new(sx, sy, modalW, modalH)
    setmetatable(o, self)
    self.__index = self
    o.playerName = playerName
    o.walletType = walletType
    o.pool = pool
    o.poolLabel = poolLabel
    o.rawAmount = rawAmount
    o.format = format
    o.currentFormatted = formatBalance(rawAmount, format)
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
-- Main Admin Panel
---------------------------------------------------------------------------

function UI.OnOpenPanel(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        local core = getCore()
        local width = math.floor(350 * FONT_SCALE)
        local height = math.floor(400 * FONT_SCALE)
        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2
        instance = UI:new(x, y, width, height, player)
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    instance:addToUIManager()
    instance:setVisible(true)
    refreshPlayers()
    return instance
end

function UI:setPlayers(players)
    self.box:clear()
    table.sort(players, function(a, b)
        return a < b
    end)
    for _, player in ipairs(players) do
        self.box:addOption(player)
    end
    refreshPlayerWallet(self.box:getSelectedText())
end

-- Populate the list with one row per pool (plus a bound row for bound pools).
function UI:setWallet(wallet)
    self.datas:clear()
    self.datas:setVisible(false)

    local pools = Core.wallet.pools or {}
    for pool, def in pairs(pools) do
        local current = (wallet.current or {})[pool] or 0
        self.datas:addItem(pool, {
            label = def.label or pool,
            value = formatBalance(current, def.format),
            rawAmount = current,
            pool = pool,
            format = def.format
        })
        if def.bound then
            local boundAmt = (wallet.bound or {})[pool] or 0
            self.datas:addItem("BOA:" .. pool, {
                label = def.label or pool,
                value = formatBalance(boundAmt, def.format),
                rawAmount = boundAmt,
                pool = pool,
                format = def.format,
                isBound = true
            })
        end
    end
    self.datas:setVisible(true)
end

function UI:openEditModal(item)
    local player = self.box:getSelectedText()
    if not player then
        return
    end
    local walletType = item.isBound and "bound" or "current"
    local label = item.label
    if item.isBound then
        label = label .. " (bound)"
    end
    local modal = EditModal:new(player, walletType, item.pool, label, item.rawAmount, item.format)
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
    self:openEditModal(selectedItem.item)
end

function UI:GridDoubleClick(item)
    self:openEditModal(item)
end

function UI:createChildren()
    ISPanel.createChildren(self)

    local x = PAD
    local y = PAD
    local w = self.width - PAD * 2

    -- Title
    self.title = ISLabel:new(x, y, FONT_HGT_MEDIUM, "Wallet Admin", 1, 1, 1, 1, UIFont.Medium, true)
    self.title:initialise()
    self.title:instantiate()
    self:addChild(self.title)

    local closeSz = math.floor(25 * FONT_SCALE)
    self.closeButton = ISButton:new(self.width - closeSz - x, y, closeSz, closeSz, "X", self, function()
        UI.OnOpenPanel(self.player):close()
    end)
    self.closeButton:initialise()
    self:addChild(self.closeButton)

    y = y + FONT_HGT_MEDIUM + PAD

    -- Toolbar row: combo + refresh + edit
    local btnW = math.floor(70 * FONT_SCALE)
    local gap = math.floor(5 * FONT_SCALE)
    local comboW = w - (btnW + gap) * 2

    self.box = ISComboBox:new(x, y, comboW, ROW_H, self, function()
        refreshPlayerWallet(self.box:getSelectedText())
    end)
    self.box:initialise()
    self:addChild(self.box)

    self.refreshPlayersButton = ISButton:new(x + comboW + gap, y, btnW, ROW_H, "Refresh", self, function()
        refreshPlayerWallet(self.box:getSelectedText())
    end)
    self.refreshPlayersButton:initialise()
    self:addChild(self.refreshPlayersButton)

    self.editButton = ISButton:new(x + comboW + gap + btnW + gap, y, btnW, ROW_H, "Edit", self, UI.onEditClick)
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
    self.datas:addColumn("Pool", 0)
    self.datas:addColumn("Balance", math.floor(w * 0.6))
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
    local label = item.item.label or item.text or ""
    if item.item.isBound then
        label = label .. " (bound)"
    end

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)
    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(label, xoffset, textY, 1, 1, 1, a, self.font)
    self:clearStencilRect()

    local valueWidth = getTextManager():MeasureStringX(self.font, item.item.value)
    self:drawText(item.item.value, self.width - valueWidth - 10, textY, 1, 1, 1, a, self.font)

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

local Commands = {}

if Core.isLocal then

    Commands[Core.commands.getPlayerList] = function(player, args)
        local players = {}
        for k, v in pairs(Core.wallet.data or {}) do
            table.insert(players, tostring(k))
        end
        for _, instance in pairs(UI.instances or {}) do
            instance:setPlayers(players)
        end
    end

    Commands[Core.commands.getPlayersWallet] = function(player, args)
        for _, instance in pairs(UI.instances or {}) do
            instance:setWallet(Core.wallet:get(args.playername))
        end
    end

    Events.OnClientCommand.Add(function(module, command, playerObj, arguments)
        if module == Core.name and Commands[command] then
            Commands[command](playerObj, arguments)
        end
    end)

else

    Commands[Core.commands.getPlayerList] = function(args)
        for _, instance in pairs(UI.instances or {}) do
            instance:setPlayers(args.players)
        end
    end

    Commands[Core.commands.getPlayersWallet] = function(args)
        for _, instance in pairs(UI.instances or {}) do
            instance:setWallet(args.wallet)
        end
    end

    Events.OnServerCommand.Add(function(module, command, arguments)
        if module == Core.name and Commands[command] then
            Commands[command](arguments)
        end
    end)

end
