if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
require "ISUI/ISButton"
require "ISUI/ISTextEntryBox"
local Core = PhunMart
local Traits = require "PhunMart/traits"

local FONT_SM = getTextManager():getFontHeight(UIFont.Small)
local PAD = 8
local ROW_H = FONT_SM + 6
local ICON_SZ = FONT_SM

-- Column widths (pixels, left-to-right after left PAD)
local COL_ICON = ICON_SZ + 4
local COL_NAME = 190
local COL_PRICE = 72
local COL_WEIGHT = 44
-- COL_COND fills remaining space

local BASE_W = 580
local BASE_H = 420

-- ─────────────────────────────────────────────────────────────────────────────

Core.ui.client.poolViewer = ISCollapsableWindowJoypad:derive("PhunMartUIPoolViewer")
local UI = Core.ui.client.poolViewer

-- ─── helpers ─────────────────────────────────────────────────────────────────

local function formatPrice(price)
    if not price then
        return "-"
    end
    if price.kind == "free" then
        return "FREE"
    end
    if price.kind == "currency" then
        local amt = price.amount
        if type(amt) == "table" then
            amt = amt.min
        end
        if price.pool == "tokens" then
            return tostring(amt) .. "t"
        else
            if amt % 100 == 0 then
                return "$" .. tostring(amt / 100)
            else
                return string.format("$%.2f", amt / 100)
            end
        end
    end
    if price.kind == "items" and price.items and price.items[1] then
        local pi = price.items[1]
        local amt = type(pi.amount) == "table" and pi.amount.min or (pi.amount or 1)
        local nm = pi.item and pi.item:match("[^.]+$") or "item"
        return tostring(amt) .. "x " .. nm
    end
    return tostring(price.kind or "-")
end

local function condLabel(condKey, conditionsDefs)
    if type(condKey) ~= "string" then
        return tostring(condKey)
    end
    local def = conditionsDefs and conditionsDefs[condKey]
    if not def then
        return condKey
    end
    local t = def.test
    local a = def.args or {}
    if t == "worldAgeHoursBetween" then
        local min = a.min or 0
        local max = a.max
        return "Age:" .. min .. "h" .. (max and ("-" .. max .. "h") or "+")
    elseif t == "perkLevelBetween" then
        return (a.perk or "?") .. " lv" .. (a.min or 0) .. "+"
    elseif t == "perkBoostBetween" then
        return "Boost:" .. (a.perk or "?")
    elseif t == "purchaseCountMax" then
        return "Limit:" .. (a.max or "?")
    elseif t == "professionIn" then
        local profs = a.professions or {}
        local s = type(profs) == "table" and table.concat(profs, "/") or tostring(profs)
        return "Prof:" .. s
    elseif t == "hasItems" then
        return "Has items"
    elseif t == "canGrantTrait" then
        return "Trait avail"
    elseif t == "canRemoveTrait" then
        return "Has trait"
    else
        return condKey
    end
end

local function conditionsText(conditions, conditionsDefs)
    if not conditions then
        return "-"
    end
    local parts = {}
    for _, k in ipairs(conditions.all or {}) do
        table.insert(parts, condLabel(k, conditionsDefs))
    end
    for _, k in ipairs(conditions.any or {}) do
        table.insert(parts, condLabel(k, conditionsDefs) .. "?")
    end
    return #parts > 0 and table.concat(parts, ", ") or "-"
end

local function fitText(text, maxW, font)
    if getTextManager():MeasureStringX(font, text) <= maxW then
        return text
    end
    local t = text
    while #t > 0 and getTextManager():MeasureStringX(font, t .. ".") > maxW do
        t = t:sub(1, -2)
    end
    return t .. "."
end

-- ─── open / lifecycle ─────────────────────────────────────────────────────────

function UI.open(player, poolKey, data)
    if UI._instance then
        UI._instance:removeFromUIManager()
        UI._instance = nil
    end
    local core = getCore()
    local x = math.floor((core:getScreenWidth() - BASE_W) / 2)
    local y = math.floor((core:getScreenHeight() - BASE_H) / 2)
    local inst = UI:new(x, y, BASE_W, BASE_H, player, poolKey, data)
    inst:initialise()
    inst:addToUIManager()
    UI._instance = inst
end

-- Refresh data in-place after a weight edit
function UI.refreshData(poolKey, data)
    local inst = UI._instance
    if not inst or inst.poolKey ~= poolKey then
        return
    end
    inst.poolData = data
    inst:buildRows()
end

function UI:new(x, y, w, h, player, poolKey, data)
    local o = ISCollapsableWindowJoypad:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.player = player or getPlayer()
    o.poolKey = poolKey or "?"
    o.poolData = data or {}
    o.rows = {}
    o.resizable = false
    o.backgroundColor = {
        r = 0.06,
        g = 0.06,
        b = 0.09,
        a = 0.95
    }
    o:setTitle("Pool: " .. (poolKey or "?"))
    return o
end

function UI:initialise()
    ISCollapsableWindowJoypad.initialise(self)
end

function UI:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local HDR_H = ROW_H + PAD
    local listY = self:titleBarHeight() + HDR_H
    local listH = self.height - listY - PAD

    self.list = ISScrollingListBox:new(0, listY, self.width, listH)
    self.list:initialise()
    self.list:instantiate()
    self.list.itemheight = ROW_H
    self.list.font = UIFont.Small
    self.list.selected = 0
    self.list.drawBorder = false
    self.list.altBgColor = nil -- handled manually in doDrawListItem
    self.list.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0
    }
    self.list.doDrawItem = UI.doDrawListItem

    local viewer = self
    self.list.onRightMouseUp = function(listSelf, x, y)
        local idx = listSelf:rowAt(x, y)
        local entry = listSelf.items[idx]
        if not entry then
            return
        end
        viewer:showContextMenu(entry.item, x + listSelf:getAbsoluteX(), y + listSelf:getAbsoluteY())
    end

    self:addChild(self.list)
    self:buildRows()
end

-- ─── data ─────────────────────────────────────────────────────────────────────

function UI:buildRows()
    self.rows = {}
    local offers = self.poolData.offers or {}
    local condDefs = self.poolData.conditionsDefs
    local blacklisted = self.poolData.blacklisted or {}

    for offerId, offer in pairs(offers) do
        local scriptItem = getScriptManager():getItem(offer.item)
        local displayName, texture

        local traitKey = Traits.getOfferTraitKey and Traits.getOfferTraitKey(offer)
        if traitKey then
            displayName = Traits.getLabel(traitKey)
            texture = Traits.getTexture(traitKey)
        end
        if not displayName then
            if scriptItem then
                displayName = scriptItem:getDisplayName()
            elseif offer.reward and offer.reward.display and offer.reward.display.text then
                displayName = offer.reward.display.text
            else
                displayName = offer.item or offerId
            end
        end
        if not texture then
            texture = scriptItem and scriptItem:getNormalTexture()
        end
        if not texture and offer.meta and offer.meta.fallbackTexture then
            texture = getTexture(offer.meta.fallbackTexture)
        end

        local weight = (offer.offer and offer.offer.weight) or offer.weight or 1

        table.insert(self.rows, {
            id = offerId,
            offer = offer,
            displayName = displayName or offer.item or "?",
            texture = texture,
            priceText = formatPrice(offer.price),
            weight = weight,
            condText = conditionsText(offer.conditions, condDefs),
            _blacklisted = blacklisted[offer.item] == true or false
        })
    end

    table.sort(self.rows, function(a, b)
        return a.displayName < b.displayName
    end)

    self.list:clear()
    for _, row in ipairs(self.rows) do
        self.list:addItem(row.displayName, row)
    end
end

-- ─── row renderer ─────────────────────────────────────────────────────────────

-- NOTE: called as a method on the ISScrollingListBox (self = list, not UI panel)
function UI.doDrawListItem(self, y, item, alt)
    local row = item.item
    local font = UIFont.Small
    local fontH = FONT_SM

    -- row background
    if row._blacklisted then
        self:drawRect(0, y, self:getWidth(), ROW_H, 1.0, 0.04, 0.04, 0.04)
    elseif self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), ROW_H, 0.5, 0.20, 0.20, 0.45)
    elseif alt then
        self:drawRect(0, y, self:getWidth(), ROW_H, 1.0, 0.09, 0.09, 0.13)
    end

    local dimA = row._blacklisted and 0.35 or 1.0
    local rx = PAD

    if row.texture then
        self:drawTextureScaledAspect(row.texture, rx, y + math.floor((ROW_H - ICON_SZ) / 2), ICON_SZ, ICON_SZ, dimA, 1,
            1, 1)
    else
        self:drawRect(rx, y + math.floor((ROW_H - ICON_SZ) / 2), ICON_SZ, ICON_SZ, dimA, 0.20, 0.20, 0.20)
    end
    rx = rx + COL_ICON + 2

    local ty = y + math.floor((ROW_H - fontH) / 2)
    local nr = row._blacklisted and 0.4 or 1
    local ng = row._blacklisted and 0.4 or 1
    local nb = row._blacklisted and 0.4 or 1

    self:drawText(fitText(row.displayName, COL_NAME - 4, font), rx, ty, nr, ng, nb, dimA, font)
    rx = rx + COL_NAME

    self:drawText(row.priceText, rx, ty, 0.6, 1.0, 0.6, dimA, font)
    rx = rx + COL_PRICE

    local wr = row._edited and 1.0 or 0.75
    local wg = row._edited and 0.85 or 0.75
    local wb = row._edited and 0.3 or 0.75
    self:drawText(string.format("%.1f", row.weight), rx, ty, wr, wg, wb, dimA, font)
    rx = rx + COL_WEIGHT

    local condW = self:getWidth() - rx - PAD - 6
    self:drawText(fitText(row.condText, condW, font), rx, ty, 0.70, 0.70, 0.45, dimA, font)

    return y + ROW_H
end

-- ─── context menu ─────────────────────────────────────────────────────────────

function UI:showContextMenu(row, absX, absY)
    local playerNum = self.player:getPlayerNum()
    local context = ISContextMenu.get(playerNum, absX, absY)
    context:addOption("Add to blacklist", self, UI.onBlacklistRow, row)
    context:addOption("Edit weight", self, UI.onEditWeightRow, row)
end

function UI:onBlacklistRow(row)
    local itemKey = row.offer and row.offer.item
    if not itemKey then
        return
    end
    sendClientCommand(Core.name, Core.commands.quickBlacklist, {
        itemKey = itemKey
    })
    row._blacklisted = true
end

function UI:onEditWeightRow(row)
    WeightEditor.open(self.player, self.poolKey, row, self)
end

-- ─── input ───────────────────────────────────────────────────────────────────

function UI:close()
    ISCollapsableWindowJoypad.close(self)
    if UI._instance == self then
        UI._instance = nil
    end
end

function UI:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function UI:onKeyPressed(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
        return true
    end
end

-- Forward wheel events on the header / title bar area down to the list
function UI:onMouseWheel(del)
    if self.list then
        return self.list:onMouseWheel(del)
    end
end

-- ─── render ──────────────────────────────────────────────────────────────────

function UI:prerender()
    ISCollapsableWindowJoypad.prerender(self)
end

function UI:render()
    ISCollapsableWindowJoypad.render(self)

    local font = UIFont.Small
    local fontH = FONT_SM
    local w = self.width
    local tbH = self:titleBarHeight()
    local HDR_H = ROW_H + PAD
    local hdrY = tbH + math.floor((HDR_H - fontH) / 2)

    -- offer count in title bar (right side, before collapse/close buttons)
    local cnt = tostring(#self.rows) .. " offer" .. (#self.rows == 1 and "" or "s")
    local cntW = getTextManager():MeasureStringX(font, cnt)
    self:drawText(cnt, w - cntW - tbH * 3 - PAD, math.floor((tbH - fontH) / 2), 0.55, 0.55, 0.55, 1, font)

    -- column headers
    local cx = PAD
    self:drawText("Name", cx + COL_ICON + 2, hdrY, 0.55, 0.55, 0.55, 1, font)
    cx = cx + COL_ICON + COL_NAME
    self:drawText("Price", cx, hdrY, 0.55, 0.55, 0.55, 1, font)
    cx = cx + COL_PRICE
    self:drawText("Wt", cx, hdrY, 0.55, 0.55, 0.55, 1, font)
    cx = cx + COL_WEIGHT
    self:drawText("Conditions", cx, hdrY, 0.55, 0.55, 0.55, 1, font)

    self:drawRect(0, tbH + HDR_H - 1, w, 1, 1.0, 0.20, 0.20, 0.24)

    -- empty state
    if #self.rows == 0 then
        local msg = "No offers in this pool"
        local msgW = getTextManager():MeasureStringX(font, msg)
        local listY = tbH + HDR_H
        local viewH = self.height - listY - PAD
        self:drawText(msg, math.floor((w - msgW) / 2), listY + math.floor((viewH - fontH) / 2), 0.45, 0.45, 0.45, 1,
            font)
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- Weight editor dialog (small floating ISPanel)
-- ═════════════════════════════════════════════════════════════════════════════

WeightEditor = {}

local WE_W = 260
local WE_H = 108
local WE_PAD = 10
local WE_FH = getTextManager():getFontHeight(UIFont.Small)
local WE_BTN_H = WE_FH + 6

function WeightEditor.open(player, poolKey, row, viewer)
    if WeightEditor._inst then
        WeightEditor._inst:removeFromUIManager()
        WeightEditor._inst = nil
    end
    local core = getCore()
    local x = math.floor((core:getScreenWidth() - WE_W) / 2)
    local y = math.floor((core:getScreenHeight() - WE_H) / 2)
    local inst = WeightEditor._Panel:new(x, y, WE_W, WE_H, player, poolKey, row, viewer)
    inst:initialise()
    inst:instantiate()
    inst:addToUIManager()
    WeightEditor._inst = inst
end

WeightEditor._Panel = ISPanel:derive("PhunMartWeightEditor")

function WeightEditor._Panel:new(x, y, w, h, player, poolKey, row, viewer)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.poolKey = poolKey
    o.row = row
    o.viewer = viewer
    o.moveWithMouse = true
    return o
end

function WeightEditor._Panel:initialise()
    ISPanel.initialise(self)
end

function WeightEditor._Panel:createChildren()
    ISPanel.createChildren(self)

    local x = WE_PAD
    local entryY = WE_PAD + WE_FH + 6
    local entryW = WE_W - WE_PAD * 2

    self.entry = ISTextEntryBox:new(string.format("%.2f", self.row.weight), x, entryY, entryW, WE_FH + 6)
    self.entry:initialise()
    self.entry:instantiate()
    self.entry:setOnlyNumbers(true)
    self:addChild(self.entry)

    local btnW = math.floor((entryW - WE_PAD) / 2)
    local btnY = entryY + WE_FH + 6 + WE_PAD
    self.okBtn = ISButton:new(x, btnY, btnW, WE_BTN_H, "OK", self, WeightEditor._Panel.onOK)
    self.cancelBtn = ISButton:new(x + btnW + WE_PAD, btnY, btnW, WE_BTN_H, "Cancel", self, WeightEditor._Panel.onCancel)
    self.okBtn:initialise();
    self.okBtn:instantiate();
    self:addChild(self.okBtn)
    self.cancelBtn:initialise();
    self.cancelBtn:instantiate();
    self:addChild(self.cancelBtn)
end

function WeightEditor._Panel:onOK()
    local val = tonumber(self.entry:getText())
    if val and val >= 0 then
        sendClientCommand(Core.name, Core.commands.updateOfferWeight, {
            poolKey = self.poolKey,
            offerId = self.row.id,
            weight = val
        })
        -- optimistic local update
        self.row.weight = val
        self.row._edited = true
    end
    self:removeFromUIManager()
    WeightEditor._inst = nil
end

function WeightEditor._Panel:onCancel()
    self:removeFromUIManager()
    WeightEditor._inst = nil
end

function WeightEditor._Panel:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE or key == Keyboard.KEY_RETURN
end

function WeightEditor._Panel:onKeyPressed(key)
    if key == Keyboard.KEY_RETURN then
        self:onOK();
        return true
    end
    if key == Keyboard.KEY_ESCAPE then
        self:onCancel();
        return true
    end
end

function WeightEditor._Panel:prerender()
    self:drawRect(0, 0, self.width, self.height, 0.95, 0.07, 0.07, 0.10)
    self:drawRectBorder(0, 0, self.width, self.height, 0.9, 0.40, 0.40, 0.45)
end

function WeightEditor._Panel:render()
    ISPanel.render(self)
    local label = "Weight: " .. fitText(self.row.displayName, self.width - WE_PAD * 4, UIFont.Small)
    self:drawText(label, WE_PAD, WE_PAD, 0.9, 0.8, 0.3, 1, UIFont.Small)
end
