if isServer() then
    return
end

-- What every player is holding, as a grid.
--
-- This was a standalone window with a dropdown at the top: pick a player, wait
-- for their wallet to come back, read two rows, pick the next player. Comparing
-- two people meant switching back and forth and remembering the numbers, and
-- there was no way to see at a glance who had nothing and who had thousands.
--
-- The data is small enough to fetch whole, so it is now a row per player and a
-- column per currency pool, which is the shape the question was always in.

local Core = PhunMart
require "PhunMart/wallet"
local ListPanel = require "PhunMart_Client/ui/base/list_panel"

local FONT_HGT_SMALL = ListPanel.FONT_HGT_SMALL
local FONT_HGT_MEDIUM = ListPanel.FONT_HGT_MEDIUM
local FONT_SCALE = ListPanel.FONT_SCALE
local PAD = ListPanel.PAD
local ROW_H = FONT_HGT_SMALL + math.floor(6 * FONT_SCALE)

Core.ui.admin_wallet = ListPanel:derive("PhunMartAdminWallet")
Core.ui.admin_wallet.instances = {}
local UI = Core.ui.admin_wallet

---------------------------------------------------------------------------
-- Formatting
---------------------------------------------------------------------------

-- Format a pool balance for display based on its format type.
local function formatBalance(amount, format)
    amount = amount or 0
    if format == "cents" then
        local dollars = math.floor(amount / 100)
        local cents = amount % 100
        return string.format("$%d.%02d", dollars, cents)
    else
        -- Integer count with thousand separators. Parenthesised because gsub
        -- returns the replacement count alongside the string, and a bare
        -- `return s:gsub(...)` hands both back to the caller.
        local s = tostring(math.floor(amount + 0.5)):reverse():gsub("(%d%d%d)", "%1,")
        return (s:reverse():gsub("^,", ""))
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

--- One entry per balance a player can hold: every pool, plus a second entry
--- for each pool that also keeps a bound total. Derived from the pool table
--- rather than hardcoded to change and tokens, so a third pool appears as a
--- column without touching this file.
local function balanceColumns()
    local pools = Core.wallet.pools or {}
    local keys = {}
    for pool in pairs(pools) do
        table.insert(keys, pool)
    end
    -- pairs() order is undefined and these are columns; without sorting they
    -- would swap places between sessions.
    table.sort(keys)

    local cols = {}
    for _, pool in ipairs(keys) do
        local def = pools[pool]
        local label = getTextOrNull(def.label or pool) or def.label or pool
        table.insert(cols, {
            pool = pool,
            label = label,
            format = def.format,
            walletType = "current"
        })
        if def.bound then
            table.insert(cols, {
                pool = pool,
                label = getText("IGUI_PhunMart_Col_BoundOf", label),
                format = def.format,
                walletType = "bound"
            })
        end
    end
    return cols
end

--- What to show in the player column. Singleplayer files every wallet under
--- the key 0 (see Core.wallet:get), so the grid would otherwise have a single
--- row labelled "0".
local function displayName(key)
    if Core.isLocal and tostring(key) == "0" then
        local player = getSpecificPlayer(0)
        local name = player and player:getUsername()
        if name and name ~= "" then
            return name
        end
        return getText("IGUI_PhunMart_Lbl_ThisPlayer")
    end
    return tostring(key)
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
    local titleText = self.poolLabel .. ": " .. self.displayName
    self.titleLabel = ISLabel:new(x, y, FONT_HGT_MEDIUM, titleText, 1, 1, 1, 1, UIFont.Medium, true)
    self.titleLabel:initialise()
    self:addChild(self.titleLabel)
    y = y + FONT_HGT_MEDIUM + PAD

    -- Current balance
    self.currentLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Current", self.currentFormatted), 0.8, 0.8,
        0.8, 1, UIFont.Small, true)
    self.currentLabel:initialise()
    self:addChild(self.currentLabel)
    y = y + ROW_H + PAD

    -- Action combo
    local labelW = getTextManager():MeasureStringX(UIFont.Small, "Amount: ") + 8
    self.actionLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Action"), 1, 1, 1, 1, UIFont.Small, true)
    self.actionLabel:initialise()
    self:addChild(self.actionLabel)

    self.actionCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H)
    self.actionCombo:initialise()
    self.actionCombo:addOption(getText("IGUI_PhunMart_Lbl_ActionAdd"))
    self.actionCombo:addOption(getText("IGUI_PhunMart_Lbl_ActionSubtract"))
    self.actionCombo:addOption(getText("IGUI_PhunMart_Lbl_ActionSetTo"))
    self:addChild(self.actionCombo)
    y = y + ROW_H + PAD

    -- Amount entry
    self.amountLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Amount"), 1, 1, 1, 1, UIFont.Small, true)
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
    local hint = self.format == "cents" and getText("IGUI_PhunMart_Hint_EnterDollars") or
                     getText("IGUI_PhunMart_Hint_EnterWholeNumber")
    self.hintLabel = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, hint, 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.hintLabel:initialise()
    self:addChild(self.hintLabel)
    y = y + FONT_HGT_SMALL + PAD * 2

    -- Buttons
    local btnW = math.floor(80 * FONT_SCALE)
    local btnGap = PAD
    local totalBtnW = btnW * 2 + btnGap
    local btnX = (self.width - totalBtnW) / 2

    self.applyBtn = ISButton:new(btnX, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Apply"), self, EditModal.onApply)
    self.applyBtn:initialise()
    if self.applyBtn.enableAcceptColor then
        self.applyBtn:enableAcceptColor()
    end
    self:addChild(self.applyBtn)

    self.cancelBtn = ISButton:new(btnX + btnW + btnGap, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Cancel"), self,
        EditModal.onCancel)
    self.cancelBtn:initialise()
    -- This pair had neither colour, so the only thing telling Apply from Cancel
    -- was the word on it. Matching the rest of the editors.
    if self.cancelBtn.enableCancelColor then
        self.cancelBtn:enableCancelColor()
    end
    self:addChild(self.cancelBtn)
end

function EditModal:onApply()
    local raw = parseAmount(self.amountEntry:getText(), self.format)
    if not raw then
        -- Reuse the format hint as the error slot so the modal doesn't resize.
        self.hintLabel:setName(getText("IGUI_PhunMart_Err_Amount"))
        self.hintLabel.r, self.hintLabel.g, self.hintLabel.b = 0.95, 0.45, 0.4
        return
    end

    local opIdx = self.actionCombo.selected
    local value
    if opIdx == 1 then
        value = raw
    elseif opIdx == 2 then
        value = -raw
    elseif opIdx == 3 then
        value = raw - self.rawAmount
    end

    sendClientCommand(Core.name, Core.commands.adjustPlayerWallet, {
        playername = self.playerKey,
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

--- @param playerKey the wallet's key, which is what the server indexes by
--- @param name      what to call them on screen, which in singleplayer is not
---                  the same string
function EditModal:new(playerKey, name, walletType, pool, poolLabel, rawAmount, format)
    local modalW = math.floor(300 * FONT_SCALE)
    local modalH = PAD * 7 + FONT_HGT_MEDIUM + ROW_H * 3 + FONT_HGT_SMALL + PAD + 25
    local core = getCore()
    local sx = (core:getScreenWidth() - modalW) / 2
    local sy = (core:getScreenHeight() - modalH) / 2

    local o = ISPanel:new(sx, sy, modalW, modalH)
    setmetatable(o, self)
    self.__index = self
    o.playerKey = playerKey
    o.displayName = name
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
-- Tab
---------------------------------------------------------------------------

function UI.createTab(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        instance = UI:new(0, 0, 100, 100, player)
        instance.description = getText("IGUI_PhunMart_Desc_Wallets")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    return instance
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self._cols = balanceColumns()

    self.list.doDrawItem = ListPanel.defaultDrawRow

    -- Double-click acts on the cell rather than the row. The base list only
    -- hands the callback the row's data, so the x offset is caught on the way
    -- through the widget's own handler and read back in the callback.
    local baseDoubleClick = ISScrollingListBox.onMouseDoubleClick
    self.list.onMouseDoubleClick = function(listSelf, x, y)
        self._lastClickX = x
        baseDoubleClick(listSelf, x, y)
    end
    self.list:setOnMouseDoubleClick(self, self.onCellDoubleClick)

    self.list.onRightMouseUp = function(target, x, y)
        local row = target:rowAt(x, y)
        if row == -1 then
            return
        end
        target.selected = row
        target:ensureVisible(row)
        self:openPoolMenu(target.items[row].item, getMouseX(), getMouseY())
    end

    self:addListColumn(getText("IGUI_PhunMart_Col_Player"), 0, {
        field = "name",
        sort = true
    })

    -- The player column takes a fixed share and the balances split what is
    -- left, so two pools or four both lay out without a table of magic numbers.
    local first = 0.4
    local step = (1 - first) / math.max(1, #self._cols)
    for i, col in ipairs(self._cols) do
        self:addListColumn(col.label, first + step * (i - 1), {
            text = function(d)
                return formatBalance(d.balances[i], col.format)
            end,
            -- On the raw amount, not the formatted string: "$9.00" sorts after
            -- "$100.00" as text, and finding who is richest is most of why you
            -- would click a balance header.
            sort = function(d)
                return d.balances[i] or 0
            end,
            color = function(d)
                -- A zero is worth reading past rather than reading, and dimming
                -- it makes the players who actually hold something stand out in
                -- a long list.
                if (d.balances[i] or 0) == 0 then
                    return 0.45, 0.45, 0.45
                end
                return 1, 1, 1
            end,
            align = "right"
        })
    end

    self._editBtn = self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), self.onEditClick, true)
    -- A button rather than a right-click entry. Reset is the one thing here
    -- that destroys something, and burying the only destructive action in a
    -- menu you have to already know about is backwards.
    self._resetBtn = self:addBottomButton(getText("IGUI_PhunMart_Btn_ResetWallet"), self.onResetClick, true)
    self._refreshBtn = self:addBottomButton(getText("IGUI_PhunMart_Btn_Refresh"), self.refresh)

    self:refresh()
end

---------------------------------------------------------------------------
-- Data
---------------------------------------------------------------------------

--- Ask for every wallet. The reply lands in setWallets, so the rows already on
--- screen stay put until it does rather than blanking on every tab switch.
function UI:refresh()
    sendClientCommand(Core.name, Core.commands.getAllWallets, {})
end

function UI:setWallets(wallets)
    -- A reply can only be in flight for a tab that has been built, but the
    -- columns are what every row is flattened against, so refuse rather than
    -- fill the list with nil.
    if not self._cols then
        return
    end
    self:clearList()

    local keys = {}
    for key in pairs(wallets or {}) do
        table.insert(keys, key)
    end
    table.sort(keys, function(a, b)
        return displayName(a):lower() < displayName(b):lower()
    end)

    for _, key in ipairs(keys) do
        local w = wallets[key]
        -- Flattened against the column list at build time, so drawing a row is
        -- an array lookup rather than two table walks per cell per frame.
        local balances = {}
        for i, col in ipairs(self._cols) do
            balances[i] = (w[col.walletType] or {})[col.pool] or 0
        end
        self:addListItem(displayName(key), {
            key = tostring(key),
            name = displayName(key),
            balances = balances
        })
    end
end

--- Push a fresh set into every open tab. Called from the command handlers.
function UI.updateAll(wallets)
    for _, instance in pairs(UI.instances or {}) do
        if instance.setWallets then
            instance:setWallets(wallets)
        end
    end
end

function UI:getFilterText(itemData)
    return itemData.name or itemData.key or ""
end

---------------------------------------------------------------------------
-- Editing
---------------------------------------------------------------------------

function UI:openEditModal(row, colIndex)
    local col = self._cols[colIndex]
    if not row or not col then
        return
    end
    local label = col.label
    local modal = EditModal:new(row.key, row.name, col.walletType, col.pool, label, row.balances[colIndex] or 0,
        col.format)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

--- Which balance did you mean? Only asked when the click did not already say,
--- which is when it landed on the player's name rather than on a number.
function UI:openPoolMenu(row, screenX, screenY)
    if not row then
        return
    end
    local context = ISContextMenu.get(self.playerIndex, screenX, screenY)
    for i, col in ipairs(self._cols) do
        -- The balance in the option text, so the menu answers the obvious
        -- question without having to be dismissed first.
        context:addOption(col.label .. ": " .. formatBalance(row.balances[i], col.format), self, function()
            self:openEditModal(row, i)
        end)
    end
end

function UI:selectedRow()
    local sel = self.list.selected
    local entry = sel and sel > 0 and self.list.items[sel]
    return entry and entry.item or nil
end

function UI:onCellDoubleClick()
    local row = self:selectedRow()
    if not row then
        return
    end
    -- Column 1 is the player's name, so a double-click there has not picked a
    -- balance. Columns 2 upwards line up with _cols one for one.
    local colIndex = self:columnAt(self._lastClickX or 0) - 1
    if colIndex >= 1 and colIndex <= #self._cols then
        self:openEditModal(row, colIndex)
    else
        self:openPoolMenu(row, getMouseX(), getMouseY())
    end
end

function UI:onEditClick()
    local row = self:selectedRow()
    if not row then
        return
    end
    -- The button cannot know which cell was meant, so it always asks.
    self:openPoolMenu(row, self._editBtn:getAbsoluteX(), self._editBtn:getAbsoluteY())
end

--- Clear a player's unbound balances and restore the bound ones.
---
--- The confirmation spells out what survives, because "reset" on its own
--- reads as "set everything to zero" and the bound total staying put would
--- otherwise look like the reset failing.
function UI:onResetClick()
    local row = self:selectedRow()
    if not row then
        return
    end
    local w = math.floor(400 * FONT_SCALE)
    local h = math.floor(200 * FONT_SCALE)
    local modal = ISModalDialog:new((getCore():getScreenWidth() - w) / 2, (getCore():getScreenHeight() - h) / 2, w, h,
        getText("IGUI_PhunMart_Confirm_ResetWallet", row.name), true, self, function(_, button)
            if button.internal == "YES" then
                sendClientCommand(Core.name, Core.commands.resetWallet, {
                    username = row.key
                })
            end
        end)
    modal:initialise()
    modal:addToUIManager()
end

---------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------

local Commands = {}

if Core.isLocal then

    -- Singleplayer reads the wallet table straight out of ModData rather than
    -- round-tripping through the server handler, which shares this Lua state.
    local function localWallets()
        local out = {}
        for key, w in pairs(Core.wallet.data or {}) do
            out[tostring(key)] = {
                current = w.current or {},
                bound = w.bound or {}
            }
        end
        return out
    end

    Commands[Core.commands.getAllWallets] = function(player, args)
        UI.updateAll(localWallets())
    end

    -- This is the singleplayer path for the adjustment. The server-side handler
    -- deliberately bails out under Core.isLocal so the increment isn't applied
    -- twice. Don't restore it there without removing it here.
    Commands[Core.commands.adjustPlayerWallet] = function(player, args)
        Core.wallet:adjustByPool(args.playername, args.walletType, args.pool, tonumber(args.value or 0))
        UI.updateAll(localWallets())
    end

    -- Same split: the server handler bails out under Core.isLocal so the reset
    -- does not run twice.
    Commands[Core.commands.resetWallet] = function(player, args)
        Core.wallet:reset(args.username)
        UI.updateAll(localWallets())
    end

    Events.OnClientCommand.Add(function(module, command, playerObj, arguments)
        if module == Core.name and Commands[command] then
            Commands[command](playerObj, arguments)
        end
    end)

else

    Commands[Core.commands.getAllWallets] = function(args)
        UI.updateAll(args.wallets)
    end

    Events.OnServerCommand.Add(function(module, command, arguments)
        if module == Core.name and Commands[command] then
            Commands[command](arguments)
        end
    end)

end

return UI
