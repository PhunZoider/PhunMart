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

local windowName = "PhunPoolsAdminUI"

Core.ui.admin_pools = ISPanel:derive(windowName)
Core.ui.admin_pools.instances = {}
local UI = Core.ui.admin_pools

-- Collect sorted keys from a table.
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

-- Format sources summary.
local function formatSources(def)
    local parts = {}
    if def.sources then
        if def.sources.groups then
            table.insert(parts, getText("IGUI_PhunMart_NGroups", tostring(#def.sources.groups)))
        end
        if def.sources.specials then
            table.insert(parts, getText("IGUI_PhunMart_NSpecials", tostring(#def.sources.specials)))
        end
    end
    if #parts == 0 then
        return ""
    end
    return table.concat(parts, " + ")
end

-- Format zones summary.
local function formatZones(def)
    if def.zones and def.zones.difficulty then
        local nums = {}
        for _, d in ipairs(def.zones.difficulty) do
            table.insert(nums, tostring(d))
        end
        return table.concat(nums, ",")
    end
    return ""
end

---------------------------------------------------------------------------
-- Edit / Add Modal
---------------------------------------------------------------------------
local EditModal = ISPanel:derive("PhunPoolEditModal")

function EditModal:createChildren()
    ISPanel.createChildren(self)

    local x = PAD
    local y = PAD
    local w = self.width - PAD * 2
    local labelW = getTextManager():MeasureStringX(UIFont.Small, "Fallback Category: ") + 8

    -- Title
    local titleText = self.isNew and getText("IGUI_PhunMart_Title_AddPool") or getText("IGUI_PhunMart_Title_EditX", self.poolKey)
    self.titleLabel = ISLabel:new(x, y, FONT_HGT_MEDIUM, titleText, 1, 1, 1, 1, UIFont.Medium, true)
    self.titleLabel:initialise()
    self:addChild(self.titleLabel)
    y = y + FONT_HGT_MEDIUM + PAD

    -- Key entry
    self.keyLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Key"), 1, 1, 1, 1, UIFont.Small, true)
    self.keyLabel:initialise()
    self:addChild(self.keyLabel)

    self.keyEntry = ISTextEntryBox:new(self.poolKey or "", x + labelW, y, w - labelW, ROW_H)
    self.keyEntry:initialise()
    self.keyEntry:instantiate()
    if not self.isNew then
        self.keyEntry:setEditable(false)
    end
    self:addChild(self.keyEntry)
    y = y + ROW_H + PAD

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
        if self.poolDef and self.poolDef.defaults and self.poolDef.defaults.price == pk then
            selectedPriceIdx = i + 1
        end
    end
    self.priceCombo.selected = selectedPriceIdx
    self:addChild(self.priceCombo)
    y = y + ROW_H + 2

    self.priceHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_FallbackPrice"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.priceHint:initialise()
    self:addChild(self.priceHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Source Groups (comma-separated)
    self.groupsLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Groups"), 1, 1, 1, 1, UIFont.Small, true)
    self.groupsLabel:initialise()
    self:addChild(self.groupsLabel)

    local groupsDefault = ""
    if self.poolDef and self.poolDef.sources and self.poolDef.sources.groups then
        groupsDefault = table.concat(self.poolDef.sources.groups, ", ")
    end
    self.groupsEntry = ISTextEntryBox:new(groupsDefault, x + labelW, y, w - labelW, ROW_H)
    self.groupsEntry:initialise()
    self.groupsEntry:instantiate()
    self:addChild(self.groupsEntry)
    y = y + ROW_H + 2

    self.groupsHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_Groups"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.groupsHint:initialise()
    self:addChild(self.groupsHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Source Specials (comma-separated)
    self.specialsLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Specials"), 1, 1, 1, 1, UIFont.Small, true)
    self.specialsLabel:initialise()
    self:addChild(self.specialsLabel)

    local specialsDefault = ""
    if self.poolDef and self.poolDef.sources and self.poolDef.sources.specials then
        specialsDefault = table.concat(self.poolDef.sources.specials, ", ")
    end
    self.specialsEntry = ISTextEntryBox:new(specialsDefault, x + labelW, y, w - labelW, ROW_H)
    self.specialsEntry:initialise()
    self.specialsEntry:instantiate()
    self:addChild(self.specialsEntry)
    y = y + ROW_H + 2

    self.specialsHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_Specials"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.specialsHint:initialise()
    self:addChild(self.rewardsHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Zones Difficulty (comma-separated numbers)
    self.zonesLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Zones"), 1, 1, 1, 1, UIFont.Small, true)
    self.zonesLabel:initialise()
    self:addChild(self.zonesLabel)

    local zonesDefault = ""
    if self.poolDef and self.poolDef.zones and self.poolDef.zones.difficulty then
        local nums = {}
        for _, d in ipairs(self.poolDef.zones.difficulty) do
            table.insert(nums, tostring(d))
        end
        zonesDefault = table.concat(nums, ", ")
    end
    self.zonesEntry = ISTextEntryBox:new(zonesDefault, x + labelW, y, w - labelW, ROW_H)
    self.zonesEntry:initialise()
    self.zonesEntry:instantiate()
    self:addChild(self.zonesEntry)
    y = y + ROW_H + 2

    self.zonesHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_Zones"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.zonesHint:initialise()
    self:addChild(self.zonesHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Fallback Texture
    self.fbTexLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_FallbackTexture"), 1, 1, 1, 1, UIFont.Small, true)
    self.fbTexLabel:initialise()
    self:addChild(self.fbTexLabel)

    local fbTexDefault = (self.poolDef and self.poolDef.fallbackTexture) or ""
    self.fbTexEntry = ISTextEntryBox:new(fbTexDefault, x + labelW, y, w - labelW, ROW_H)
    self.fbTexEntry:initialise()
    self.fbTexEntry:instantiate()
    self:addChild(self.fbTexEntry)
    y = y + ROW_H + PAD

    -- Fallback Category
    self.fbCatLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_FallbackCategory"), 1, 1, 1, 1, UIFont.Small, true)
    self.fbCatLabel:initialise()
    self:addChild(self.fbCatLabel)

    local fbCatDefault = (self.poolDef and self.poolDef.fallbackCategory) or ""
    self.fbCatEntry = ISTextEntryBox:new(fbCatDefault, x + labelW, y, w - labelW, ROW_H)
    self.fbCatEntry:initialise()
    self.fbCatEntry:instantiate()
    self:addChild(self.fbCatEntry)
    y = y + ROW_H + PAD * 2

    -- Buttons
    local btnW = math.floor(80 * FONT_SCALE)
    local btnGap = PAD
    local totalBtnW = btnW * 2 + btnGap
    local btnX = (self.width - totalBtnW) / 2

    self.applyBtn = ISButton:new(btnX, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Apply"), self, EditModal.onApply)
    self.applyBtn:initialise()
    self:addChild(self.applyBtn)

    self.cancelBtn = ISButton:new(btnX + btnW + btnGap, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Cancel"), self, EditModal.onCancel)
    self.cancelBtn:initialise()
    self:addChild(self.cancelBtn)
end

-- Parse a comma-separated string into a trimmed array. Returns nil for empty input.
local function parseCSV(text)
    if not text or text == "" then
        return nil
    end
    local result = {}
    for s in text:gmatch("[^,]+") do
        s = s:match("^%s*(.-)%s*$")
        if s ~= "" then
            table.insert(result, s)
        end
    end
    if #result == 0 then
        return nil
    end
    return result
end

-- Parse a comma-separated string of numbers into an integer array. Returns nil for empty input.
local function parseCSVNumbers(text)
    if not text or text == "" then
        return nil
    end
    local result = {}
    for s in text:gmatch("[^,]+") do
        s = s:match("^%s*(.-)%s*$")
        local n = tonumber(s)
        if n then
            table.insert(result, math.floor(n))
        end
    end
    if #result == 0 then
        return nil
    end
    return result
end

function EditModal:onApply()
    local key = self.keyEntry:getText()
    if not key or key == "" then
        return
    end

    local def = {}

    -- Price (optional)
    local priceText = self.priceCombo:getSelectedText()
    if priceText ~= "" then
        def.defaults = def.defaults or {}
        def.defaults.price = priceText
    end

    -- Sources
    local groups = parseCSV(self.groupsEntry:getText())
    local specials = parseCSV(self.specialsEntry:getText())
    if groups or specials then
        def.sources = {}
        if groups then
            def.sources.groups = groups
        end
        if specials then
            def.sources.specials = specials
        end
    end

    -- Zones (optional)
    local zones = parseCSVNumbers(self.zonesEntry:getText())
    if zones then
        def.zones = {
            difficulty = zones
        }
    end

    -- Fallback Texture (optional)
    local fbTex = self.fbTexEntry:getText()
    if fbTex and fbTex ~= "" then
        def.fallbackTexture = fbTex
    end

    -- Fallback Category (optional)
    local fbCat = self.fbCatEntry:getText()
    if fbCat and fbCat ~= "" then
        def.fallbackCategory = fbCat
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

function EditModal:new(poolKey, poolDef, isNew, cb)
    local modalW = math.floor(520 * FONT_SCALE)
    local modalH = PAD * 13 + FONT_HGT_MEDIUM + ROW_H * 8 + FONT_HGT_SMALL * 4 + PAD * 4
    local core = getCore()
    local sx = (core:getScreenWidth() - modalW) / 2
    local sy = (core:getScreenHeight() - modalH) / 2

    local o = ISPanel:new(sx, sy, modalW, modalH)
    setmetatable(o, self)
    self.__index = self
    o.poolKey = poolKey or ""
    o.poolDef = poolDef
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
-- Main Pools Panel
---------------------------------------------------------------------------

function UI.OnOpenPanel(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        local core = getCore()
        local width = math.floor(700 * FONT_SCALE)
        local height = math.floor(500 * FONT_SCALE)
        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2
        instance = UI:new(x, y, width, height, player)
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    instance:addToUIManager()
    instance:setVisible(true)
    instance:refreshPools()
    return instance
end

function UI:refreshPools()
    self.datas:clear()
    self.datas:setVisible(false)

    local pools = Core.defs and Core.defs.pools or require "PhunMart/defaults/pools"

    local keys = {}
    for k in pairs(pools) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _, key in ipairs(keys) do
        local def = pools[key]
        self.datas:addItem(key, {
            key = key,
            price = formatPrice(def),
            sources = formatSources(def),
            zones = formatZones(def),
            def = def
        })
    end
    self.datas:setVisible(true)
end

local function savePoolDef(key, def)
    sendClientCommand(Core.name, Core.commands.upsertPoolDef, {key = key, def = def})
    if not Core.isLocal and Core.defs and Core.defs.pools then
        Core.defs.pools[key] = def
    end
end

function UI:onAddClick()
    local modal = EditModal:new(nil, nil, true, function(key, def)
        savePoolDef(key, def)
        self:refreshPools()
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

function UI:onViewClick()
    if not self.datas.selected or self.datas.selected == 0 then
        return
    end
    local selectedItem = self.datas.items[self.datas.selected]
    if not selectedItem then
        return
    end
    local poolKey = selectedItem.item.key
    local poolData = Core.runtime and Core.runtime.pools and Core.runtime.pools[poolKey]
    if poolData then
        Core.ui.client.poolViewer.open(self.player, poolKey, poolData)
    end
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
        savePoolDef(key, def)
        self:refreshPools()
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

function UI:GridDoubleClick(item)
    local data = item
    local modal = EditModal:new(data.key, data.def, false, function(key, def)
        savePoolDef(key, def)
        self:refreshPools()
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
    self.title = ISLabel:new(x, y, FONT_HGT_MEDIUM, getText("IGUI_PhunMart_Title_PoolDefs"), 1, 1, 1, 1, UIFont.Medium, true)
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

    self.addButton = ISButton:new(x, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Add"), self, UI.onAddClick)
    self.addButton:initialise()
    self:addChild(self.addButton)

    self.editButton = ISButton:new(x + btnW + gap, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Edit"), self, UI.onEditClick)
    self.editButton:initialise()
    self:addChild(self.editButton)

    self.viewButton = ISButton:new(x + (btnW + gap) * 2, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_View"), self, UI.onViewClick)
    self.viewButton:initialise()
    self:addChild(self.viewButton)

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

    local colPrice = math.floor(w * 0.30)
    local colSources = math.floor(w * 0.50)
    local colZones = math.floor(w * 0.80)
    self.datas:addColumn(getText("IGUI_PhunMart_Col_Key"), 0)
    self.datas:addColumn(getText("IGUI_PhunMart_Col_Price"), colPrice)
    self.datas:addColumn(getText("IGUI_PhunMart_Col_Sources"), colSources)
    self.datas:addColumn(getText("IGUI_PhunMart_Col_Zones"), colZones)
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
    local col4X = self.columns[4].size
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

    -- Sources column
    self:setStencilRect(col3X, clipY, col4X - col3X, clipY2 - clipY)
    self:drawText(data.sources, col3X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Zones column
    if data.zones ~= "" then
        self:drawText(data.zones, col4X + 4, textY, 0.7, 0.9, 0.7, a, self.font)
    end

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

-- Open the edit modal directly for a specific pool key (used by shop_main context menu).
-- Pass nil poolKey to open in "Add" mode.
function UI.OnEditPool(player, poolKey)
    local poolDef = nil
    local isNew = true
    if poolKey then
        local pools = Core.defs and Core.defs.pools or require "PhunMart/defaults/pools"
        poolDef = pools[poolKey]
        if not poolDef then
            return
        end
        isNew = false
    end
    local modal = EditModal:new(poolKey, poolDef, isNew, function(key, def)
        savePoolDef(key, def)
        print("[PhunMart] Pool " .. (isNew and "added" or "updated") .. ": " .. key)
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end
