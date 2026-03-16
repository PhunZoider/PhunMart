if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
require "ISUI/ISButton"
require "ISUI/ISTextEntryBox"
require "ISUI/ISTickBox"
require "ISUI/ISComboBox"

local Core = PhunMart
local tools = require "PhunMart_Client/ui/ui_utils"
local Traits = require "PhunMart/traits"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_SCALE = FONT_HGT_SMALL / 14

local PAD = math.max(10, math.floor(10 * FONT_SCALE))
local ROW_H = FONT_HGT_SMALL + math.floor(6 * FONT_SCALE)
local BUTTON_HGT = FONT_HGT_SMALL + 6
local ICON_SZ = FONT_HGT_SMALL
local SCROLLBAR_W = 13

-- Column widths (pixels, left-to-right after left PAD)
local COL_ICON = ICON_SZ + 4
local COL_NAME = math.floor(190 * FONT_SCALE)
local COL_PRICE = math.floor(90 * FONT_SCALE)
local COL_WEIGHT = math.floor(44 * FONT_SCALE)
local COL_SOURCE = math.floor(100 * FONT_SCALE)
-- COL_COND fills remaining space

local BASE_W = math.floor(740 * FONT_SCALE)
local BASE_H = math.floor(500 * FONT_SCALE)

-- ---------------------------------------------------------------------------

Core.ui.client.poolViewer = ISCollapsableWindowJoypad:derive("PhunMartUIPoolViewer")
local UI = Core.ui.client.poolViewer
UI.instances = {}

-- --- helpers ----------------------------------------------------------------

local function formatCents(cents)
    if cents % 100 == 0 then
        return "$" .. tostring(cents / 100)
    else
        return string.format("$%.2f", cents / 100)
    end
end

local function formatPrice(price)
    if not price then
        return "-"
    end
    if price.kind == "free" then
        return getText("IGUI_PhunMart_Admin_FREE")
    end
    if price.kind == "currency" then
        local amt = price.amount
        if type(amt) == "table" then
            if amt.min and amt.max and amt.min ~= amt.max then
                if price.pool == "tokens" then
                    return amt.min .. "-" .. amt.max .. "t"
                else
                    return formatCents(amt.min) .. "-" .. formatCents(amt.max)
                end
            end
            amt = amt.min or amt.max or 0
        end
        if price.pool == "tokens" then
            return tostring(amt) .. "t"
        else
            return formatCents(amt)
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

-- Resolve the display category for an offer (used for category filter).
local function resolveCategory(offer)
    if offer.reward and offer.reward.category then
        return offer.reward.category
    end
    local scriptItem = offer.item and getScriptManager():getItem(offer.item)
    if scriptItem then
        local cat = scriptItem:getDisplayCategory()
        if cat then
            return cat
        end
    end
    return nil
end

-- --- open / lifecycle -------------------------------------------------------

function UI.open(player, poolKey, data)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if instance then
        instance:removeFromUIManager()
        UI.instances[playerIndex] = nil
    end
    local core = getCore()
    local x = math.floor((core:getScreenWidth() - BASE_W) / 2)
    local y = math.floor((core:getScreenHeight() - BASE_H) / 2)
    local inst = UI:new(x, y, BASE_W, BASE_H, player, poolKey, data)
    inst:initialise()
    inst:addToUIManager()
    UI.instances[playerIndex] = inst
end

-- Refresh data in-place after a weight edit
function UI.refreshData(poolKey, data)
    for _, inst in pairs(UI.instances) do
        if inst.poolKey == poolKey then
            inst.poolData = data
            inst:buildRows()
            inst:applyFilters()
        end
    end
end

function UI:new(x, y, w, h, player, poolKey, data)
    local o = ISCollapsableWindowJoypad:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.player = player or getPlayer()
    o.playerIndex = o.player:getPlayerNum()
    o.poolKey = poolKey or "?"
    o.poolData = data or {}
    o.rows = {}
    o.filteredRows = {}
    o.selected = {} -- map of row.id -> true for multi-select
    o.lastClickedIdx = nil
    o.showBlacklisted = false
    o.anchorRight = true
    o.anchorBottom = true
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    }
    o:setWantKeyEvents(true)
    o:setTitle(getText("IGUI_PhunMart_Admin_PoolTitle", poolKey or "?"))
    return o
end

function UI:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    local w = self.width
    local contentH = self.height - th - rh

    -- Main content panel (opaque so list rows don't bleed through)
    local mainPanel = ISPanel:new(0, th, w, contentH)
    mainPanel:initialise()
    mainPanel:instantiate()
    mainPanel.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    }
    self:addChild(mainPanel)
    self._mainPanel = mainPanel

    -- Bottom button bar (opaque to cover list overflow)
    local btnBarH = BUTTON_HGT + PAD * 2
    local btnBar = ISPanel:new(0, contentH - btnBarH, w, btnBarH)
    btnBar:initialise()
    btnBar:instantiate()
    btnBar.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    }
    self._mainPanel:addChild(btnBar)
    self._buttonBar = btnBar

    -- Close button (right side of button bar)
    local closeBtnW = math.max(math.floor(70 * FONT_SCALE), getTextManager():MeasureStringX(UIFont.Small, getText(
        "IGUI_PhunMart_Btn_Close")) + PAD * 2)
    local closeBtn = ISButton:new(0, PAD, closeBtnW, BUTTON_HGT, getText("IGUI_PhunMart_Btn_Close"), self, self.close)
    closeBtn:initialise()
    closeBtn:instantiate()
    if closeBtn.enableCancelColor then
        closeBtn:enableCancelColor()
    end
    self._buttonBar:addChild(closeBtn)
    self._closeBtn = closeBtn

    -- Edit Pool button (admin only, right side next to Close)
    if isAdmin() or isDebugEnabled() then
        local editBtnW = math.max(math.floor(70 * FONT_SCALE), getTextManager():MeasureStringX(UIFont.Small, getText(
            "IGUI_PhunMart_Admin_EditPool")) + PAD * 2)
        self.editPoolBtn = ISButton:new(0, PAD, editBtnW, BUTTON_HGT, getText("IGUI_PhunMart_Admin_EditPool"), self,
            UI.onEditPool)
        self.editPoolBtn:initialise()
        self.editPoolBtn:instantiate()
        self._buttonBar:addChild(self.editPoolBtn)
    end

    -- Filter controls in button bar (left side)
    local filterLblW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Lbl_Filter")) + 8
    local filterLbl = ISLabel:new(PAD, PAD, BUTTON_HGT, getText("IGUI_PhunMart_Lbl_Filter"), 0.8, 0.8, 0.8, 1,
        UIFont.Small, true)
    filterLbl:initialise()
    self._buttonBar:addChild(filterLbl)
    self._filterLabel = filterLbl

    self.filterEntry = ISTextEntryBox:new("", PAD + filterLblW, PAD, 100, BUTTON_HGT)
    self.filterEntry:initialise()
    self.filterEntry:instantiate()
    self.filterEntry:setClearButton(true)
    self.filterEntry.onTextChange = function()
        self:applyFilters()
    end
    self._buttonBar:addChild(self.filterEntry)

    local catLabelW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Admin_Category") .. " ") + 4
    self.catLabel = ISLabel:new(0, PAD, BUTTON_HGT, getText("IGUI_PhunMart_Admin_Category"), 0.8, 0.8, 0.8, 1,
        UIFont.Small, true)
    self.catLabel:initialise()
    self._buttonBar:addChild(self.catLabel)
    self._catLabelW = catLabelW

    local catComboW = math.floor(160 * FONT_SCALE)
    self.catCombo = ISComboBox:new(0, PAD, catComboW, BUTTON_HGT, self, function()
        self:applyFilters()
    end)
    self.catCombo:initialise()
    self._buttonBar:addChild(self.catCombo)
    self._catComboW = catComboW

    -- Show blacklisted tickbox (in button bar, between filters and buttons)
    self.showBlacklistedTick = ISTickBox:new(0, PAD, BUTTON_HGT, BUTTON_HGT, "")
    self.showBlacklistedTick:initialise()
    self.showBlacklistedTick:instantiate()
    self.showBlacklistedTick:addOption(getText("IGUI_PhunMart_Admin_ShowBlacklisted"), nil)
    self.showBlacklistedTick:setSelected(1, false)
    self.showBlacklistedTick.changeOptionMethod = UI.onBlacklistToggle
    self.showBlacklistedTick.changeOptionTarget = self
    self._buttonBar:addChild(self.showBlacklistedTick)

    local y = 0

    -- Column headers row
    local hdrY = y
    local hdrH = FONT_HGT_SMALL + math.floor(4 * FONT_SCALE)

    local cx = PAD + COL_ICON + 2
    self.hdrName = ISLabel:new(cx, hdrY, hdrH, getText("IGUI_PhunMart_Col_Name"), 0.55, 0.55, 0.55, 1, UIFont.Small,
        true)
    self.hdrName:initialise()
    self._mainPanel:addChild(self.hdrName)
    cx = cx + COL_NAME
    self.hdrPrice = ISLabel:new(cx, hdrY, hdrH, getText("IGUI_PhunMart_Col_Price"), 0.55, 0.55, 0.55, 1, UIFont.Small,
        true)
    self.hdrPrice:initialise()
    self._mainPanel:addChild(self.hdrPrice)
    cx = cx + COL_PRICE
    self.hdrWt = ISLabel:new(cx, hdrY, hdrH, getText("IGUI_PhunMart_Col_Wt"), 0.55, 0.55, 0.55, 1, UIFont.Small, true)
    self.hdrWt:initialise()
    self._mainPanel:addChild(self.hdrWt)
    cx = cx + COL_WEIGHT
    self.hdrSource = ISLabel:new(cx, hdrY, hdrH, getText("IGUI_PhunMart_Col_Source"), 0.55, 0.55, 0.55, 1, UIFont.Small,
        true)
    self.hdrSource:initialise()
    self._mainPanel:addChild(self.hdrSource)
    cx = cx + COL_SOURCE
    self.hdrCond = ISLabel:new(cx, hdrY, hdrH, getText("IGUI_PhunMart_Col_Conditions"), 0.55, 0.55, 0.55, 1,
        UIFont.Small, true)
    self.hdrCond:initialise()
    self._mainPanel:addChild(self.hdrCond)

    y = hdrY + hdrH + 2

    -- Separator line position (stored for render)
    self._dividerY = y - 1

    -- List
    local listH = contentH - y - btnBarH
    self.list = ISScrollingListBox:new(0, y, w, listH)
    self.list:initialise()
    self.list:instantiate()
    self.list.itemheight = ROW_H
    self.list.font = UIFont.Small
    self.list.selected = 0
    self.list.drawBorder = false
    self.list.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0
    }
    self.list.doDrawItem = UI.doDrawListItem
    self.list._viewer = self

    -- Left click: multi-select with ctrl/shift
    self.list.onMouseUp = function(listSelf, lx, ly)
        local idx = listSelf:rowAt(lx, ly)
        if not idx or idx < 1 or not listSelf.items[idx] then
            return
        end
        local row = listSelf.items[idx].item
        local v = listSelf._viewer

        if isShiftKeyDown() and v.lastClickedIdx then
            -- Range select
            local lo = math.min(idx, v.lastClickedIdx)
            local hi = math.max(idx, v.lastClickedIdx)
            for i = lo, hi do
                if listSelf.items[i] then
                    v.selected[listSelf.items[i].item.id] = true
                end
            end
        elseif isCtrlKeyDown() then
            -- Toggle single
            if v.selected[row.id] then
                v.selected[row.id] = nil
            else
                v.selected[row.id] = true
            end
        else
            -- Replace selection
            v.selected = {}
            v.selected[row.id] = true
        end
        v.lastClickedIdx = idx
    end

    local viewer = self
    self.list.onRightMouseUp = function(listSelf, lx, ly)
        local idx = listSelf:rowAt(lx, ly)
        local entry = listSelf.items[idx]
        if not entry then
            return
        end
        -- If right-clicked row isn't in selection, make it the sole selection
        if not viewer.selected[entry.item.id] then
            viewer.selected = {}
            viewer.selected[entry.item.id] = true
            viewer.lastClickedIdx = idx
        end
        viewer:showContextMenu(entry.item, listSelf:getMouseX() + listSelf:getAbsoluteX(),
            listSelf:getMouseY() + listSelf:getAbsoluteY())
    end

    self._mainPanel:addChild(self.list)

    self:buildRows()
    self:applyFilters()
end

-- --- data -------------------------------------------------------------------

function UI:buildRows()
    self.rows = {}
    local offers = self.poolData.offers or {}
    local condDefs = self.poolData.conditionsDefs
    local blacklisted = self.poolData.blacklisted or {}

    local catMap = {}

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
        local category = resolveCategory(offer) or ""

        if category ~= "" then
            catMap[category] = true
        end

        local meta = offer.meta or {}
        local sourceType = meta.sourceType or "group"
        local sourceLabel
        if sourceType == "group" and meta.sourceGroup then
            sourceLabel = meta.sourceGroup
        elseif sourceType == "reward" then
            sourceLabel = "reward"
        elseif sourceType == "item" then
            sourceLabel = "item"
        else
            sourceLabel = meta.sourceGroup or sourceType
        end

        table.insert(self.rows, {
            id = offerId,
            offer = offer,
            displayName = displayName or offer.item or "?",
            texture = texture,
            priceText = formatPrice(offer.price),
            weight = weight,
            sourceType = sourceType,
            sourceKey = meta.sourceGroup,
            sourceLabel = sourceLabel,
            condText = conditionsText(offer.conditions, condDefs),
            category = category,
            _blacklisted = blacklisted[offer.item] == true or false
        })
    end

    table.sort(self.rows, function(a, b)
        return a.displayName < b.displayName
    end)

    -- Rebuild category combo
    if self.catCombo then
        local prevCat = self.catCombo:getOptionText(self.catCombo.selected) or ""
        self.catCombo:clear()
        self.catCombo:addOption("")
        local cats = {}
        for c in pairs(catMap) do
            table.insert(cats, c)
        end
        table.sort(cats, function(a, b)
            return a:lower() < b:lower()
        end)
        local selectedIdx = 1
        for i, c in ipairs(cats) do
            self.catCombo:addOption(c)
            if c == prevCat then
                selectedIdx = i + 1
            end
        end
        self.catCombo.selected = selectedIdx
    end
end

function UI:applyFilters()
    local filterText = self.filterEntry and self.filterEntry:getInternalText():lower() or ""
    local catFilter = self.catCombo and self.catCombo:getOptionText(self.catCombo.selected) or ""

    self.filteredRows = {}
    for _, row in ipairs(self.rows) do
        local show = true

        -- Hide blacklisted unless toggled on
        if row._blacklisted and not self.showBlacklisted then
            show = false
        end

        -- Text filter
        if show and filterText ~= "" then
            if not string.find(row.displayName:lower(), filterText, 1, true) then
                show = false
            end
        end

        -- Category filter
        if show and catFilter ~= "" then
            if row.category ~= catFilter then
                show = false
            end
        end

        if show then
            table.insert(self.filteredRows, row)
        end
    end

    self.list:clear()
    for _, row in ipairs(self.filteredRows) do
        self.list:addItem(row.displayName, row)
    end
end

-- --- row renderer -----------------------------------------------------------

-- NOTE: called as a method on the ISScrollingListBox (self = list, not UI panel)
function UI.doDrawListItem(self, y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local row = item.item
    local font = UIFont.Small
    local fontH = FONT_HGT_SMALL

    -- row background
    local isSelected = self._viewer and self._viewer.selected[row.id]
    if row._blacklisted then
        self:drawRect(0, y, self:getWidth(), ROW_H, 0.3, 0.15, 0.08, 0.08)
    end
    if isSelected then
        self:drawRect(0, y, self:getWidth(), ROW_H, 0.3, 0.7, 0.35, 0.15)
    elseif not row._blacklisted and alt then
        self:drawRect(0, y, self:getWidth(), ROW_H, 0.3, 0.6, 0.5, 0.5)
    end

    local dimA = row._blacklisted and 0.35 or 0.9
    local rx = PAD

    if row.texture then
        self:drawTextureScaledAspect(row.texture, rx, y + math.floor((ROW_H - ICON_SZ) / 2), ICON_SZ, ICON_SZ, dimA, 1,
            1, 1)
    else
        self:drawRect(rx, y + math.floor((ROW_H - ICON_SZ) / 2), ICON_SZ, ICON_SZ, dimA, 0.20, 0.20, 0.20)
    end
    rx = rx + COL_ICON + 2

    local ty = y + math.floor((ROW_H - fontH) / 2)
    local nr = row._blacklisted and 0.5 or 1
    local ng = row._blacklisted and 0.5 or 1
    local nb = row._blacklisted and 0.5 or 1

    self:drawText(tools.truncate(row.displayName, COL_NAME - 4, font), rx, ty, nr, ng, nb, dimA, font)
    rx = rx + COL_NAME

    self:drawText(row.priceText, rx, ty, 0.6, 1.0, 0.6, dimA, font)
    rx = rx + COL_PRICE

    local wr = row._edited and 1.0 or 0.75
    local wg = row._edited and 0.85 or 0.75
    local wb = row._edited and 0.3 or 0.75
    self:drawText(string.format("%.1f", row.weight), rx, ty, wr, wg, wb, dimA, font)
    rx = rx + COL_WEIGHT

    -- source
    local sr, sg, sb
    if row.sourceType == "group" then
        sr, sg, sb = 0.55, 0.75, 0.55
    elseif row.sourceType == "reward" then
        sr, sg, sb = 0.75, 0.55, 0.75
    else
        sr, sg, sb = 0.55, 0.70, 0.85
    end
    self:drawText(tools.truncate(row.sourceLabel or "-", COL_SOURCE - 4, font), rx, ty, sr, sg, sb, dimA, font)
    rx = rx + COL_SOURCE

    local condW = self:getWidth() - rx - PAD - SCROLLBAR_W
    self:drawText(tools.truncate(row.condText, condW, font), rx, ty, 0.70, 0.70, 0.45, dimA, font)

    return y + ROW_H
end

-- --- toolbar actions --------------------------------------------------------

function UI:onEditPool()
    if Core.ui.admin_pools and Core.ui.admin_pools.OnEditPool then
        Core.ui.admin_pools.OnEditPool(self.player, self.poolKey)
    end
end

function UI:onBlacklistToggle()
    self.showBlacklisted = self.showBlacklistedTick:isSelected(1)
    self:applyFilters()
end

-- --- context menu -----------------------------------------------------------

-- Collect currently selected rows.
function UI:getSelectedRows()
    local result = {}
    for _, row in ipairs(self.filteredRows) do
        if self.selected[row.id] then
            table.insert(result, row)
        end
    end
    return result
end

function UI:showContextMenu(row, absX, absY)
    local playerNum = self.player:getPlayerNum()
    local context = ISContextMenu.get(playerNum, absX, absY)

    local sel = self:getSelectedRows()
    local count = #sel

    if count <= 1 then
        if not row._blacklisted then
            context:addOption(getText("IGUI_PhunMart_Admin_AddToBlacklist"), self, UI.onBlacklistRow, row)
        end
        context:addOption(getText("IGUI_PhunMart_Admin_EditWeight"), self, UI.onEditWeightRow, row)

        -- Edit source: open the appropriate admin editor
        if row.sourceType == "group" and row.sourceKey then
            context:addOption(getText("IGUI_PhunMart_Admin_EditGroupX", row.sourceKey), self, UI.onEditSource, row)
        elseif row.sourceType == "item" then
            context:addOption(getText("IGUI_PhunMart_Admin_EditItemDef"), self, UI.onEditSource, row)
        elseif row.sourceType == "reward" then
            context:addOption(getText("IGUI_PhunMart_Admin_EditItemDef"), self, UI.onEditSource, row)
        end
    else
        context:addOption(getText("IGUI_PhunMart_Admin_BlacklistNItems", tostring(count)), self, UI.onBlacklistSelected)
    end
    local moveLabel = count > 1 and getText("IGUI_PhunMart_Admin_MoveNToPool", tostring(count)) or
                          getText("IGUI_PhunMart_Admin_MoveToPool")
    context:addOption(moveLabel, self, UI.onMoveToPool)
end

function UI:onEditSource(row)
    if row.sourceType == "group" and row.sourceKey then
        if Core.ui.admin_groups and Core.ui.admin_groups.OnEditGroup then
            Core.ui.admin_groups.OnEditGroup(self.player, row.sourceKey)
        end
    elseif row.sourceType == "item" or row.sourceType == "reward" then
        local itemKey = row.offer and row.offer.item
        if itemKey and Core.ui.admin_items and Core.ui.admin_items.OnEditItem then
            Core.ui.admin_items.OnEditItem(self.player, itemKey)
        end
    end
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
    if not self.showBlacklisted then
        self:applyFilters()
    end
end

function UI:onBlacklistSelected()
    local sel = self:getSelectedRows()
    for _, row in ipairs(sel) do
        local itemKey = row.offer and row.offer.item
        if itemKey and not row._blacklisted then
            sendClientCommand(Core.name, Core.commands.quickBlacklist, {
                itemKey = itemKey
            })
            row._blacklisted = true
        end
    end
    self.selected = {}
    if not self.showBlacklisted then
        self:applyFilters()
    end
end

function UI:onEditWeightRow(row)
    WeightEditor.open(self.player, self.poolKey, row, self)
end

function UI:onMoveToPool()
    local sel = self:getSelectedRows()
    if #sel == 0 then
        return
    end
    MoveToPoolModal.open(self.player, self.poolKey, sel, self)
end

-- --- input ------------------------------------------------------------------

function UI:close()
    ISCollapsableWindowJoypad.close(self)
    UI.instances[self.playerIndex] = nil
end

function UI:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function UI:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
    end
end

-- Forward wheel events on the header / title bar area down to the list
function UI:onMouseWheel(del)
    if self.list then
        return self.list:onMouseWheel(del)
    end
end

-- --- render -----------------------------------------------------------------

function UI:prerender()
    ISCollapsableWindowJoypad.prerender(self)

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    local w = self.width
    local contentH = self.height - th - rh

    -- Main panel
    self._mainPanel:setX(0)
    self._mainPanel:setY(th)
    self._mainPanel:setWidth(w)
    self._mainPanel:setHeight(contentH)

    -- Button bar at bottom
    local btnBarH = BUTTON_HGT + PAD * 2
    self._buttonBar:setX(0)
    self._buttonBar:setY(contentH - btnBarH)
    self._buttonBar:setWidth(w)
    self._buttonBar:setHeight(btnBarH)

    -- Right side of button bar: Close, then Edit Pool right-to-left
    local rightX = w - PAD
    self._closeBtn:setX(rightX - self._closeBtn.width)
    rightX = rightX - self._closeBtn.width - PAD

    if self.editPoolBtn then
        self.editPoolBtn:setX(rightX - self.editPoolBtn.width)
        rightX = rightX - self.editPoolBtn.width - PAD
    end

    -- Left side of button bar: Filter label, filter entry, Cat label, Cat combo, Show BL tick
    local filterLblW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Lbl_Filter")) + 8
    self._filterLabel:setX(PAD)

    -- Category combo and label (fixed width, positioned after filter entry)
    -- Show blacklisted tickbox width
    local blTickW = math.floor(140 * FONT_SCALE)

    -- Filter entry fills remaining space between filter label and category label
    local fixedRight = self._catLabelW + self._catComboW + PAD + blTickW + PAD
    local filterEntryW = rightX - PAD - filterLblW - fixedRight
    if filterEntryW < 60 then
        filterEntryW = 60
    end

    self.filterEntry:setX(PAD + filterLblW)
    self.filterEntry:setWidth(filterEntryW)

    local catX = PAD + filterLblW + filterEntryW + PAD
    self.catLabel:setX(catX)
    self.catCombo:setX(catX + self._catLabelW)

    local blX = catX + self._catLabelW + self._catComboW + PAD
    self.showBlacklistedTick:setX(blX)

    -- List
    local listY = self.list:getY()
    local listH = contentH - listY - btnBarH
    self.list:setWidth(w)
    self.list:setHeight(listH)
end

function UI:render()
    ISCollapsableWindowJoypad.render(self)

    local th = self:titleBarHeight()

    -- Divider line below column headers
    if self._dividerY then
        self:drawRect(0, th + self._dividerY, self.width, 1, 1.0, 0.20, 0.20, 0.24)
    end

    -- Offer count (in title bar area, right side)
    local total = #self.rows
    local shown = #self.filteredRows
    local selCount = 0
    for _ in pairs(self.selected) do
        selCount = selCount + 1
    end
    local countText
    if selCount > 0 then
        countText = getText("IGUI_PhunMart_Admin_NSelected", tostring(selCount))
    elseif shown == total then
        countText = total == 1 and getText("IGUI_PhunMart_Admin_OfferCount", tostring(total)) or
                        getText("IGUI_PhunMart_Admin_OfferCountPlural", tostring(total))
    else
        countText = getText("IGUI_PhunMart_Admin_OfferCountFiltered", tostring(shown), tostring(total))
    end
    local cntW = getTextManager():MeasureStringX(UIFont.Small, countText)
    self:drawText(countText, self.width - cntW - PAD - SCROLLBAR_W, th + PAD, 0.55, 0.55, 0.55, 1, UIFont.Small)

    -- empty state
    if #self.filteredRows == 0 then
        local msg = #self.rows == 0 and getText("IGUI_PhunMart_Admin_NoOffers") or
                        getText("IGUI_PhunMart_Admin_NoMatching")
        local msgW = getTextManager():MeasureStringX(UIFont.Small, msg)
        local listY = th + self.list:getY()
        local listH = self.list:getHeight()
        self:drawText(msg, math.floor((self.width - msgW) / 2), listY + math.floor((listH - FONT_HGT_SMALL) / 2), 0.45,
            0.45, 0.45, 1, UIFont.Small)
    end
end

-- ===========================================================================
-- Weight editor dialog
-- ===========================================================================

WeightEditor = {}

local WE_W = math.floor(260 * FONT_SCALE)
local WE_PAD = PAD

function WeightEditor.open(player, poolKey, row, viewer)
    if WeightEditor._inst then
        WeightEditor._inst:removeFromUIManager()
        WeightEditor._inst = nil
    end
    local th = getTextManager():getFontHeight(UIFont.Medium) + 4
    local WE_H = th + WE_PAD + FONT_HGT_SMALL + 6 + ROW_H + WE_PAD + ROW_H + WE_PAD
    local core = getCore()
    local x = math.floor((core:getScreenWidth() - WE_W) / 2)
    local y = math.floor((core:getScreenHeight() - WE_H) / 2)
    local inst = WeightEditor._Panel:new(x, y, WE_W, WE_H, player, poolKey, row, viewer)
    inst:initialise()
    inst:addToUIManager()
    WeightEditor._inst = inst
end

WeightEditor._Panel = ISCollapsableWindowJoypad:derive("PhunMartWeightEditor")

function WeightEditor._Panel:new(x, y, w, h, player, poolKey, row, viewer)
    local o = ISCollapsableWindowJoypad:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.poolKey = poolKey
    o.row = row
    o.viewer = viewer
    o.resizable = false
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    }
    o:setTitle(getText("IGUI_PhunMart_Admin_WeightLabel", tools.truncate(row.displayName, w - WE_PAD * 4, UIFont.Small)))
    o:setWantKeyEvents(true)
    return o
end

function WeightEditor._Panel:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local th = self:titleBarHeight()
    local x = WE_PAD
    local entryY = th + WE_PAD
    local entryW = WE_W - WE_PAD * 2

    self.entry = ISTextEntryBox:new(string.format("%.2f", self.row.weight), x, entryY, entryW, ROW_H)
    self.entry:initialise()
    self.entry:instantiate()
    self.entry:setOnlyNumbers(true)
    self:addChild(self.entry)

    local btnW = math.floor((entryW - WE_PAD) / 2)
    local btnY = entryY + ROW_H + WE_PAD
    self.okBtn = ISButton:new(x, btnY, btnW, ROW_H, getText("IGUI_PhunMart_Btn_OK"), self, WeightEditor._Panel.onOK)
    self.cancelBtn = ISButton:new(x + btnW + WE_PAD, btnY, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Cancel"), self,
        WeightEditor._Panel.onCancel)
    self.okBtn:initialise()
    self.okBtn:instantiate()
    self:addChild(self.okBtn)
    self.cancelBtn:initialise()
    self.cancelBtn:instantiate()
    if self.cancelBtn.enableCancelColor then
        self.cancelBtn:enableCancelColor()
    end
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
    self:close()
    WeightEditor._inst = nil
end

function WeightEditor._Panel:onCancel()
    self:close()
    WeightEditor._inst = nil
end

function WeightEditor._Panel:close()
    ISCollapsableWindowJoypad.close(self)
end

function WeightEditor._Panel:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE or key == Keyboard.KEY_RETURN
end

function WeightEditor._Panel:onKeyRelease(key)
    if key == Keyboard.KEY_RETURN then
        self:onOK()
    elseif key == Keyboard.KEY_ESCAPE then
        self:onCancel()
    end
end

-- ===========================================================================
-- Move to Pool modal
-- ===========================================================================

MoveToPoolModal = {}

local MP_W = math.floor(340 * FONT_SCALE)
local MP_LIST_H = math.floor(220 * FONT_SCALE)

function MoveToPoolModal.open(player, fromPoolKey, rows, viewer)
    if MoveToPoolModal._inst then
        MoveToPoolModal._inst:removeFromUIManager()
        MoveToPoolModal._inst = nil
    end
    local th = getTextManager():getFontHeight(UIFont.Medium) + 4
    local MP_H = th + PAD + MP_LIST_H + PAD + ROW_H + PAD
    local core = getCore()
    local x = math.floor((core:getScreenWidth() - MP_W) / 2)
    local y = math.floor((core:getScreenHeight() - MP_H) / 2)
    local inst = MoveToPoolModal._Panel:new(x, y, MP_W, MP_H, player, fromPoolKey, rows, viewer)
    inst:initialise()
    inst:addToUIManager()
    inst:bringToTop()
    MoveToPoolModal._inst = inst
end

MoveToPoolModal._Panel = ISCollapsableWindowJoypad:derive("PhunMartMoveToPoolModal")

function MoveToPoolModal._Panel:new(x, y, w, h, player, fromPoolKey, rows, viewer)
    local o = ISCollapsableWindowJoypad:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.fromPoolKey = fromPoolKey
    o.rows = rows
    o.viewer = viewer
    o.resizable = false
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    }
    local count = #rows
    o:setTitle(getText("IGUI_PhunMart_Admin_MoveItemsToPool", tostring(count)))
    o:setWantKeyEvents(true)
    return o
end

function MoveToPoolModal._Panel:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local th = self:titleBarHeight()
    local x = PAD
    local y = th + PAD
    local w = self.width - PAD * 2

    -- Pool list
    self.poolList = ISScrollingListBox:new(x, y, w, MP_LIST_H)
    self.poolList:initialise()
    self.poolList:instantiate()
    self.poolList.itemheight = ROW_H
    self.poolList.font = UIFont.Small
    self.poolList.selected = 0
    self.poolList.drawBorder = true
    self.poolList.doDrawItem = MoveToPoolModal._Panel.drawPoolRow
    self:addChild(self.poolList)
    y = y + MP_LIST_H + PAD

    -- Buttons
    local btnW = math.floor(80 * FONT_SCALE)
    local btnGap = PAD
    local totalBtnW = btnW * 2 + btnGap
    local btnX = (self.width - totalBtnW) / 2

    self.okBtn =
        ISButton:new(btnX, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Move"), self, MoveToPoolModal._Panel.onOK)
    self.okBtn:initialise()
    self:addChild(self.okBtn)

    self.cancelBtn = ISButton:new(btnX + btnW + btnGap, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Cancel"), self,
        MoveToPoolModal._Panel.onCancel)
    self.cancelBtn:initialise()
    if self.cancelBtn.enableCancelColor then
        self.cancelBtn:enableCancelColor()
    end
    self:addChild(self.cancelBtn)

    self:populatePoolList()
end

function MoveToPoolModal._Panel:populatePoolList()
    self.poolList:clear()

    -- Get pool keys from runtime or defaults
    local poolKeys = {}
    local pools = Core.runtime and Core.runtime.pools
    if pools then
        for k in pairs(pools) do
            if k ~= self.fromPoolKey then
                table.insert(poolKeys, k)
            end
        end
    else
        local defaults = require "PhunMart/defaults/pools"
        for k in pairs(defaults) do
            if k ~= self.fromPoolKey then
                table.insert(poolKeys, k)
            end
        end
    end

    table.sort(poolKeys)

    for _, key in ipairs(poolKeys) do
        self.poolList:addItem(key, {
            key = key
        })
    end
end

function MoveToPoolModal._Panel:drawPoolRow(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15)
    elseif alt then
        self:drawRect(0, y, self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5)
    end

    local textY = y + math.floor((self.itemheight - FONT_HGT_SMALL) / 2)
    self:drawText(item.item.key, PAD, textY, 1, 1, 1, 0.9, UIFont.Small)

    return y + self.itemheight
end

function MoveToPoolModal._Panel:onOK()
    if not self.poolList.selected or self.poolList.selected < 1 then
        return
    end
    local selectedItem = self.poolList.items[self.poolList.selected]
    if not selectedItem then
        return
    end
    local targetPool = selectedItem.item.key

    -- Collect offer IDs to move
    local offerIds = {}
    for _, row in ipairs(self.rows) do
        table.insert(offerIds, row.id)
    end

    sendClientCommand(Core.name, Core.commands.moveOffers, {
        fromPool = self.fromPoolKey,
        toPool = targetPool,
        offerIds = offerIds
    })

    -- Optimistic local removal from viewer
    if self.viewer then
        local removeSet = {}
        for _, id in ipairs(offerIds) do
            removeSet[id] = true
        end
        local newRows = {}
        for _, row in ipairs(self.viewer.rows) do
            if not removeSet[row.id] then
                table.insert(newRows, row)
            end
        end
        self.viewer.rows = newRows
        self.viewer.selected = {}
        self.viewer:applyFilters()
    end

    self:close()
end

function MoveToPoolModal._Panel:onCancel()
    self:close()
end

function MoveToPoolModal._Panel:close()
    ISCollapsableWindowJoypad.close(self)
    MoveToPoolModal._inst = nil
end

function MoveToPoolModal._Panel:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE or key == Keyboard.KEY_RETURN
end

function MoveToPoolModal._Panel:onKeyRelease(key)
    if key == Keyboard.KEY_RETURN then
        self:onOK()
    elseif key == Keyboard.KEY_ESCAPE then
        self:onCancel()
    end
end
