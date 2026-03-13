if isServer() then
    return
end

require "ISUI/ISPanel"

local Core = PhunMart
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_SCALE = FONT_HGT_SMALL / 14

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

function UI.OnOpenPanel(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        local core = getCore()
        local width = 350
        local height = 400
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
            pool = pool,
            format = def.format
        })
        if def.bound then
            local boundAmt = (wallet.bound or {})[pool] or 0
            self.datas:addItem("BOA:" .. pool, {
                label = def.label or pool,
                value = formatBalance(boundAmt, def.format),
                pool = pool,
                format = def.format,
                isBound = true
            })
        end
    end
    self.datas:setVisible(true)
end

function UI:promptForValue(playerName, walletType, pool, format, currentValue)
    local title = pool .. " (" .. walletType .. ") for " .. playerName
    local modal = ISTextBox:new(0, 0, 280, 180, title, tostring(currentValue), nil, function(target, button, obj)
        if button.internal == "OK" then
            sendClientCommand(Core.name, Core.commands.adjustPlayerWallet, {
                playername = playerName,
                walletType = walletType,
                pool = pool,
                value = button.parent.entry:getText()
            })
        end
    end, self.playerIndex)
    modal:initialise()
    modal:addToUIManager()
end

function UI:GridDoubleClick(item)
    local player = self.box:getSelectedText()
    if not player then
        return
    end
    local walletType = item.isBound and "bound" or "current"
    self:promptForValue(player, walletType, item.pool, item.format, -1)
end

function UI:createChildren()
    ISPanel.createChildren(self)

    local x = 10
    local y = 10
    local h = FONT_HGT_MEDIUM
    local w = self.width - 20

    self.title = ISLabel:new(x, y, h, "Wallet Admin", 1, 1, 1, 1, UIFont.Medium, true)
    self.title:initialise()
    self.title:instantiate()
    self:addChild(self.title)

    self.closeButton = ISButton:new(self.width - 25 - x, y, 25, 25, "X", self, function()
        UI.OnOpenPanel(self.player):close()
    end)
    self.closeButton:initialise()
    self:addChild(self.closeButton)

    y = y + h + x + 20

    self.box = ISComboBox:new(x, y, 200, h, self, function()
        refreshPlayerWallet(self.box:getSelectedText())
    end)
    self.box:initialise()
    self:addChild(self.box)

    self.refreshPlayersButton = ISButton:new(x + 210, y, 100, h, "Refresh", self, function()
        refreshPlayerWallet(self.box:getSelectedText())
    end)
    self.refreshPlayersButton:initialise()
    self:addChild(self.refreshPlayersButton)

    y = y + h + x + 20

    self.datas = ISScrollingListBox:new(x, y, self.width - (x * 2), self.height - y - h)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas.itemheight = FONT_HGT_MEDIUM + 8
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.font = UIFont.NewSmall
    self.datas.doDrawItem = self.drawDatas
    self.datas.drawBorder = true
    self.datas:setOnMouseDoubleClick(self, self.GridDoubleClick)
    self.datas:addColumn("Pool", 0)
    self.datas:addColumn("Balance", 200)
    self.datas:setVisible(false)
    self:addChild(self.datas)
end

function UI:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9

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
    self:drawText(label, xoffset, y + 4, 1, 1, 1, a, self.font)
    self:clearStencilRect()

    local valueWidth = getTextManager():MeasureStringX(self.font, item.item.value)
    self:drawText(item.item.value, self.width - valueWidth - 10, y + 4, 1, 1, 1, a, self.font)

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
