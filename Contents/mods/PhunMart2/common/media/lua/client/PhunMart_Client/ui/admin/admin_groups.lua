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

local windowName = "PhunGroupsAdminUI"

Core.ui.admin_groups = ISPanel:derive(windowName)
Core.ui.admin_groups.instances = {}
local UI = Core.ui.admin_groups

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
local EditModal = ISPanel:derive("PhunGroupEditModal")

function EditModal:createChildren()
    ISPanel.createChildren(self)

    local x = PAD
    local y = PAD
    local w = self.width - PAD * 2
    local labelW = getTextManager():MeasureStringX(UIFont.Small, "Blacklist Cats: ") + 8

    -- Title
    local titleText = self.isNew and getText("IGUI_PhunMart_Title_AddGroup") or getText("IGUI_PhunMart_Title_EditX", self.groupKey)
    self.titleLabel = ISLabel:new(x, y, FONT_HGT_MEDIUM, titleText, 1, 1, 1, 1, UIFont.Medium, true)
    self.titleLabel:initialise()
    self:addChild(self.titleLabel)
    y = y + FONT_HGT_MEDIUM + PAD

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

    -- Default Reward combo (optional — used by vehicle groups)
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

    -- Include Categories (comma-separated text entry)
    self.catsLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Categories"), 1, 1, 1, 1, UIFont.Small, true)
    self.catsLabel:initialise()
    self:addChild(self.catsLabel)

    local catsDefault = ""
    if self.groupDef and self.groupDef.include and self.groupDef.include.categories then
        catsDefault = table.concat(self.groupDef.include.categories, ", ")
    end
    self.catsEntry = ISTextEntryBox:new(catsDefault, x + labelW, y, w - labelW, ROW_H)
    self.catsEntry:initialise()
    self.catsEntry:instantiate()
    self:addChild(self.catsEntry)
    y = y + ROW_H + 2

    self.catsHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_DisplayCategories"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.catsHint:initialise()
    self:addChild(self.catsHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Include Items (comma-separated text entry)
    self.itemsLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Items"), 1, 1, 1, 1, UIFont.Small, true)
    self.itemsLabel:initialise()
    self:addChild(self.itemsLabel)

    local itemsDefault = ""
    if self.groupDef and self.groupDef.include and self.groupDef.include.items then
        itemsDefault = table.concat(self.groupDef.include.items, ", ")
    end
    self.itemsEntry = ISTextEntryBox:new(itemsDefault, x + labelW, y, w - labelW, ROW_H)
    self.itemsEntry:initialise()
    self.itemsEntry:instantiate()
    self:addChild(self.itemsEntry)
    y = y + ROW_H + 2

    local itemCount = 0
    if self.groupDef and self.groupDef.include and self.groupDef.include.items then
        itemCount = #self.groupDef.include.items
    end
    self.itemsHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL,
        getText("IGUI_PhunMart_Hint_ItemIDs", tostring(itemCount)), 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.itemsHint:initialise()
    self:addChild(self.itemsHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Blacklist items (comma-separated text entry)
    self.blLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_BlacklistItems"), 1, 1, 1, 1, UIFont.Small, true)
    self.blLabel:initialise()
    self:addChild(self.blLabel)

    local blDefault = ""
    if self.groupDef and self.groupDef.blacklist then
        blDefault = table.concat(self.groupDef.blacklist, ", ")
    end
    self.blEntry = ISTextEntryBox:new(blDefault, x + labelW, y, w - labelW, ROW_H)
    self.blEntry:initialise()
    self.blEntry:instantiate()
    self:addChild(self.blEntry)
    y = y + ROW_H + 2

    local blCount = self.groupDef and self.groupDef.blacklist and #self.groupDef.blacklist or 0
    self.blHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL,
        getText("IGUI_PhunMart_Hint_ItemIDs", tostring(blCount)), 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.blHint:initialise()
    self:addChild(self.blHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Blacklist Categories (comma-separated text entry)
    self.blCatsLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_BlacklistCats"), 1, 1, 1, 1, UIFont.Small, true)
    self.blCatsLabel:initialise()
    self:addChild(self.blCatsLabel)

    local blCatsDefault = ""
    if self.groupDef and self.groupDef.blacklistCategories then
        blCatsDefault = table.concat(self.groupDef.blacklistCategories, ", ")
    end
    self.blCatsEntry = ISTextEntryBox:new(blCatsDefault, x + labelW, y, w - labelW, ROW_H)
    self.blCatsEntry:initialise()
    self.blCatsEntry:instantiate()
    self:addChild(self.blCatsEntry)
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
    local cats = parseCSV(self.catsEntry:getText())
    local items = parseCSV(self.itemsEntry:getText())
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
    local bl = parseCSV(self.blEntry:getText())
    if bl then
        def.blacklist = bl
    end

    -- Blacklist categories
    local blCats = parseCSV(self.blCatsEntry:getText())
    if blCats then
        def.blacklistCategories = blCats
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

function EditModal:new(groupKey, groupDef, isNew, cb)
    local modalW = math.floor(480 * FONT_SCALE)
    local modalH = PAD * 14 + FONT_HGT_MEDIUM + ROW_H * 10 + FONT_HGT_SMALL * 8 + PAD * 4
    local core = getCore()
    local sx = (core:getScreenWidth() - modalW) / 2
    local sy = (core:getScreenHeight() - modalH) / 2

    local o = ISPanel:new(sx, sy, modalW, modalH)
    setmetatable(o, self)
    self.__index = self
    o.groupKey = groupKey or ""
    o.groupDef = groupDef
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
-- Main Groups Panel
---------------------------------------------------------------------------

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
        if Core.defs and Core.defs.groups then
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

function UI:refreshGroups()
    self.datas:clear()
    self.datas:setVisible(false)

    local groups = Core.defs and Core.defs.groups or require "PhunMart/defaults/groups"

    local keys = {}
    for k in pairs(groups) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _, key in ipairs(keys) do
        local def = groups[key]
        self.datas:addItem(key, {
            key = key,
            price = formatPrice(def),
            include = formatInclude(def),
            blacklist = formatBlacklist(def),
            weight = formatWeight(def),
            def = def
        })
    end
    self.datas:setVisible(true)
end

local function saveGroupDef(self, key, def)
    sendClientCommand(Core.name, Core.commands.upsertGroupDef, {key = key, def = def})
    if Core.defs and Core.defs.groups then
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
    if not self.datas.selected or self.datas.selected == 0 then
        return
    end
    local selectedItem = self.datas.items[self.datas.selected]
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

function UI:GridDoubleClick(item)
    local data = item
    local modal = EditModal:new(data.key, data.def, false, function(key, def)
        saveGroupDef(self, key, def)
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
    self.title = ISLabel:new(x, y, FONT_HGT_MEDIUM, getText("IGUI_PhunMart_Title_GroupDefs"), 1, 1, 1, 1, UIFont.Medium, true)
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

    local colPrice = math.floor(w * 0.25)
    local colInclude = math.floor(w * 0.42)
    local colBlacklist = math.floor(w * 0.75)
    local colWeight = math.floor(w * 0.87)
    self.datas:addColumn(getText("IGUI_PhunMart_Col_Key"), 0)
    self.datas:addColumn(getText("IGUI_PhunMart_Col_Price"), colPrice)
    self.datas:addColumn(getText("IGUI_PhunMart_Col_Include"), colInclude)
    self.datas:addColumn(getText("IGUI_PhunMart_Col_BL"), colBlacklist)
    self.datas:addColumn(getText("IGUI_PhunMart_Col_Weight"), colWeight)
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
    local rightEdge = self.width - SCROLLBAR_W
    self:drawText(data.weight, col5X + 4, textY, 0.8, 0.8, 0.8, a, self.font)

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
