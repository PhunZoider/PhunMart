if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local tools = require "PhunMart_Client/ui/ui_utils"

local FONT_HGT_SMALL = tools.FONT_HGT_SMALL
local FONT_SCALE = tools.FONT_SCALE
local PAD = math.max(10, math.floor(10 * FONT_SCALE))
local ROW_H = FONT_HGT_SMALL + math.floor(6 * FONT_SCALE)
local BUTTON_HGT = tools.BUTTON_HGT
local CHECK_SZ = FONT_HGT_SMALL

---------------------------------------------------------------------------
-- PickerPanel: filterable multi-select modal for choosing keys.
--
-- Usage from a subclass:
--   1. Derive:  local MyPicker = PickerPanel:derive("MyPicker")
--   2. Override :populateItems() to call self:addPickerItem(key, display, extra)
--   3. Open via MyPicker.open(player, selectedKeys, callback)
--      callback(keys) receives an array of selected key strings, or nil on cancel.
--
-- Optional overrides:
--   :getFilterText(itemData)  returns a searchable string for an item
--   :doDrawItem(y, item, alt) does custom row rendering
---------------------------------------------------------------------------
local PickerPanel = ISCollapsableWindowJoypad:derive("PhunMartPickerPanel")

PickerPanel.PAD = PAD
PickerPanel.ROW_H = ROW_H
PickerPanel.FONT_HGT_SMALL = FONT_HGT_SMALL
PickerPanel.FONT_SCALE = FONT_SCALE
PickerPanel.BUTTON_HGT = BUTTON_HGT
PickerPanel.CHECK_SZ = CHECK_SZ

---------------------------------------------------------------------------
-- Sizing
---------------------------------------------------------------------------

--- The size a picker should open at, given its base size at a default UI font.
---
--- Every picker used to carry a raw pixel constant, so at a large UI font the
--- text grew and the window did not: the button bar ran out of room and Apply
--- printed over the count label. Scaled by the font for that reason, and
--- clamped to the screen so the scaling cannot push the window off the edge.
---
--- The bases are set for the current bar of four buttons. Adding a fifth means
--- revisiting them, which prerender will survive but not flatter.
function PickerPanel.sizeFor(baseW, baseH)
    local core = getCore()
    local w = math.min(math.floor(baseW * FONT_SCALE), core:getScreenWidth() - 40)
    local h = math.min(math.floor(baseH * FONT_SCALE), core:getScreenHeight() - 40)
    return w, h
end

---------------------------------------------------------------------------
-- Construction
---------------------------------------------------------------------------

function PickerPanel:new(x, y, width, height, player, selectedKeys, callback)
    local o = ISCollapsableWindowJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.playerIndex = player:getPlayerNum()
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 0.85}
    o.resizable = true
    o.moveWithMouse = true
    o:setWantKeyEvents(true)

    -- Build a lookup set from the initial selection
    o._selectedSet = {}
    if selectedKeys then
        for _, k in ipairs(selectedKeys) do
            o._selectedSet[k] = true
        end
    end
    o._callback = callback
    o._allItems = {}    -- {key, display, extra, ...}
    o._lastFilterText = ""
    o.singleSelect = false  -- set true for single-item pick mode
    return o
end

---------------------------------------------------------------------------
-- Children
---------------------------------------------------------------------------

function PickerPanel:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    local w = self.width
    local contentH = self.height - th - rh

    -- Main content panel
    local mainPanel = ISPanel:new(0, th, w, contentH)
    mainPanel:initialise()
    mainPanel:instantiate()
    self:addChild(mainPanel)
    self._mainPanel = mainPanel

    -- Button bar at bottom
    local btnBarH = BUTTON_HGT + PAD * 2
    local btnBar = ISPanel:new(0, contentH - btnBarH, w, btnBarH)
    btnBar:initialise()
    btnBar:instantiate()
    btnBar.backgroundColor = {r = 0, g = 0, b = 0, a = 0.9}
    self._mainPanel:addChild(btnBar)
    self._buttonBar = btnBar

    -- Filter entry (top of content)
    local filterLblW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Lbl_Filter")) + 8
    local filterLbl = ISLabel:new(PAD, PAD, BUTTON_HGT, getText("IGUI_PhunMart_Lbl_Filter"), 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    filterLbl:initialise()
    self._mainPanel:addChild(filterLbl)
    self._filterLabel = filterLbl

    local filterEntry = ISTextEntryBox:new("", PAD + filterLblW, PAD, w - PAD * 2 - filterLblW, BUTTON_HGT)
    filterEntry:initialise()
    filterEntry:instantiate()
    filterEntry:setClearButton(true)
    self._mainPanel:addChild(filterEntry)
    self._filterEntry = filterEntry

    -- Scrolling list (between filter and button bar)
    local listY = PAD + BUTTON_HGT + PAD
    local listH = contentH - listY - btnBarH
    local list = ISScrollingListBox:new(PAD, listY, w - PAD * 2, listH)
    list:initialise()
    list:instantiate()
    list.itemheight = ROW_H
    list.selected = 0
    list.joypadParent = self
    list.font = UIFont.Small
    list.drawBorder = true
    list.doDrawItem = function(listSelf, y, item, alt)
        return self:doDrawItem(y, item, alt, listSelf)
    end
    list.onMouseUp = function(listSelf, x, y)
        local row = listSelf:rowAt(x, y)
        if row and row > 0 and row <= #listSelf.items then
            local entry = listSelf.items[row]
            local key = entry.item.key
            if self.singleSelect then
                local wasSelected = self._selectedSet[key]
                self._selectedSet = {}
                if not wasSelected then
                    self._selectedSet[key] = true
                end
            else
                if self._selectedSet[key] then
                    self._selectedSet[key] = nil
                else
                    self._selectedSet[key] = true
                end
            end
        end
        return true
    end
    self._mainPanel:addChild(list)
    self._list = list

    -- Count label (left side of button bar)
    self._countLabel = ISLabel:new(PAD, PAD, BUTTON_HGT, "", 0.7, 0.7, 0.7, 1, UIFont.Small, true)
    self._countLabel:initialise()
    self._buttonBar:addChild(self._countLabel)

    -- OK button
    local btnW = math.max(math.floor(70 * FONT_SCALE),
        getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Btn_Apply")) + PAD * 2)
    self._okBtn = ISButton:new(0, PAD, btnW, BUTTON_HGT, getText("IGUI_PhunMart_Btn_Apply"), self, self.onOK)
    self._okBtn:initialise()
    self._okBtn:instantiate()
    if self._okBtn.enableAcceptColor then
        self._okBtn:enableAcceptColor()
    end
    self._buttonBar:addChild(self._okBtn)

    -- Cancel button
    local cancelW = math.max(math.floor(70 * FONT_SCALE),
        getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Btn_Cancel")) + PAD * 2)
    self._cancelBtn = ISButton:new(0, PAD, cancelW, BUTTON_HGT, getText("IGUI_PhunMart_Btn_Cancel"), self, self.onCancel)
    self._cancelBtn:initialise()
    self._cancelBtn:instantiate()
    if self._cancelBtn.enableCancelColor then
        self._cancelBtn:enableCancelColor()
    end
    self._buttonBar:addChild(self._cancelBtn)

    -- All / None, which act on the rows the filter is currently showing rather
    -- than on everything. Filter to "saw", press All: that is the useful
    -- gesture, and it is also the safe one. On the item picker the unfiltered
    -- list is the entire game item database, and a button that selected all of
    -- it would be a trap rather than a convenience.
    if not self.singleSelect then
        local allW = math.max(math.floor(52 * FONT_SCALE),
            getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Btn_All")) + PAD)
        self._allBtn = ISButton:new(0, PAD, allW, BUTTON_HGT, getText("IGUI_PhunMart_Btn_All"), self, self.onSelectAll)
        self._allBtn:initialise()
        self._allBtn:instantiate()
        self._buttonBar:addChild(self._allBtn)

        local noneW = math.max(math.floor(52 * FONT_SCALE),
            getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Btn_None")) + PAD)
        self._noneBtn = ISButton:new(0, PAD, noneW, BUTTON_HGT, getText("IGUI_PhunMart_Btn_None"), self,
            self.onSelectNone)
        self._noneBtn:initialise()
        self._noneBtn:instantiate()
        self._buttonBar:addChild(self._noneBtn)
    end

    -- Populate
    self:populateItems()
    self:applyFilter()
end

---------------------------------------------------------------------------
-- Item population: override in subclass
---------------------------------------------------------------------------

--- Override this to add items via self:addPickerItem(key, display, extra).
function PickerPanel:populateItems()
    -- subclass responsibility
end

--- Add an item to the picker.
-- @param key      Unique string key (returned in the selection result)
-- @param display  Display text shown in the list
-- @param extra    Optional table of extra data for custom rendering
function PickerPanel:addPickerItem(key, display, extra)
    table.insert(self._allItems, {key = key, display = display or key, extra = extra})
end

---------------------------------------------------------------------------
-- Filtering
---------------------------------------------------------------------------

--- Override to provide custom filter text for an item.
-- Receives {key, display, extra}. Default: key .. display.
function PickerPanel:getFilterText(itemData)
    return (itemData.key .. " " .. itemData.display):lower()
end

function PickerPanel:applyFilter()
    local filterText = self._filterEntry:getText():lower()
    self._lastFilterText = filterText

    self._list:clear()
    for _, entry in ipairs(self._allItems) do
        if filterText == "" then
            self._list:addItem(entry.display, entry)
        else
            local searchable = self:getFilterText(entry)
            if searchable:find(filterText, 1, true) then
                self._list:addItem(entry.display, entry)
            end
        end
    end
end

--- Tick every row the filter is showing. Rows the filter is hiding keep
--- whatever they had: this adds to the selection rather than replacing it, so
--- narrowing the filter twice and pressing All twice collects both sets.
function PickerPanel:onSelectAll()
    for i = 1, #self._list.items do
        local entry = self._list.items[i].item
        if entry and entry.key then
            self._selectedSet[entry.key] = true
        end
    end
end

--- Untick the rows the filter is showing, on the same principle. With no
--- filter that is everything, which is the clear-it-all case.
function PickerPanel:onSelectNone()
    for i = 1, #self._list.items do
        local entry = self._list.items[i].item
        if entry and entry.key then
            self._selectedSet[entry.key] = nil
        end
    end
end

---------------------------------------------------------------------------
-- Row rendering
---------------------------------------------------------------------------

function PickerPanel:doDrawItem(y, item, alt, listSelf)
    if y + listSelf:getYScroll() + listSelf.itemheight < 0
        or y + listSelf:getYScroll() >= listSelf.height then
        return y + listSelf.itemheight
    end

    local entry = item.item
    local isChecked = self._selectedSet[entry.key]

    -- Alternating row background
    if isChecked then
        listSelf:drawRect(0, y, listSelf:getWidth(), ROW_H, 0.25, 0.2, 0.5, 0.2)
    elseif alt then
        listSelf:drawRect(0, y, listSelf:getWidth(), ROW_H, 0.15, 0.5, 0.5, 0.5)
    end

    local cx = PAD
    local cy = y + math.floor((ROW_H - CHECK_SZ) / 2)

    -- Checkbox outline
    listSelf:drawRectBorder(cx, cy, CHECK_SZ, CHECK_SZ, 0.8, 0.7, 0.7, 0.7)
    if isChecked then
        -- Filled check indicator
        listSelf:drawRect(cx + 2, cy + 2, CHECK_SZ - 4, CHECK_SZ - 4, 0.9, 0.3, 0.8, 0.3)
    end

    -- Display text
    local tx = cx + CHECK_SZ + PAD
    local ty = y + math.floor((ROW_H - FONT_HGT_SMALL) / 2)
    local r, g, b = 1, 1, 1
    if isChecked then
        r, g, b = 0.7, 1.0, 0.7
    end
    listSelf:drawText(entry.display, tx, ty, r, g, b, 0.9, UIFont.Small)

    return y + ROW_H
end

---------------------------------------------------------------------------
-- Layout
---------------------------------------------------------------------------

function PickerPanel:prerender()
    ISCollapsableWindowJoypad.prerender(self)

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    local w = self.width
    local contentH = self.height - th - rh

    self._mainPanel:setX(0)
    self._mainPanel:setY(th)
    self._mainPanel:setWidth(w)
    self._mainPanel:setHeight(contentH)

    -- Filter row
    local filterLblW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Lbl_Filter")) + 8
    self._filterLabel:setX(PAD)
    self._filterEntry:setX(PAD + filterLblW)
    self._filterEntry:setWidth(w - PAD * 2 - filterLblW)

    -- Button bar
    local btnBarH = BUTTON_HGT + PAD * 2
    self._buttonBar:setX(0)
    self._buttonBar:setY(contentH - btnBarH)
    self._buttonBar:setWidth(w)
    self._buttonBar:setHeight(btnBarH)

    -- Button positions (right-aligned)
    local rightX = w - PAD
    self._cancelBtn:setX(rightX - self._cancelBtn.width)
    rightX = rightX - self._cancelBtn.width - PAD
    self._okBtn:setX(rightX - self._okBtn.width)

    -- All / None sit left of Apply, in the order they read.
    if self._allBtn then
        rightX = rightX - self._okBtn.width - PAD
        self._noneBtn:setX(rightX - self._noneBtn.width)
        rightX = rightX - self._noneBtn.width - PAD
        self._allBtn:setX(rightX - self._allBtn.width)
        rightX = rightX - self._allBtn.width
    else
        rightX = rightX - self._okBtn.width
    end

    -- Count label, in whatever room the buttons left.
    --
    -- The buttons are placed first and this yields, rather than the two being
    -- laid out independently and trusted not to meet. A window narrow enough
    -- for them to collide is always reachable: the width is clamped to the
    -- screen, so a wide enough font eventually wins.
    local count = 0
    for _ in pairs(self._selectedSet) do
        count = count + 1
    end
    local countText = getText("IGUI_PhunMart_Admin_NSelected", tostring(count))
    local room = rightX - PAD * 2
    if getTextManager():MeasureStringX(UIFont.Small, countText) <= room then
        self._countLabel:setName(countText)
    else
        -- Just the number, then nothing. Losing the word is better than
        -- printing it underneath a button.
        local bare = tostring(count)
        self._countLabel:setName(getTextManager():MeasureStringX(UIFont.Small, bare) <= room and bare or "")
    end

    -- List
    local listY = PAD + BUTTON_HGT + PAD
    local listH = contentH - listY - btnBarH
    self._list:setX(PAD)
    self._list:setY(listY)
    self._list:setWidth(w - PAD * 2)
    self._list:setHeight(listH)

    -- Reapply filter when text changes
    local currentFilter = self._filterEntry:getText()
    if currentFilter ~= self._lastFilterText then
        self:applyFilter()
    end
end

---------------------------------------------------------------------------
-- Actions
---------------------------------------------------------------------------

function PickerPanel:onOK()
    if self._callback then
        if self.singleSelect then
            local picked = nil
            for k in pairs(self._selectedSet) do
                picked = k
                break
            end
            self._callback(picked)
        else
            local keys = {}
            for _, entry in ipairs(self._allItems) do
                if self._selectedSet[entry.key] then
                    table.insert(keys, entry.key)
                end
            end
            self._callback(keys)
        end
    end
    self:close()
end

function PickerPanel:onCancel()
    self:close()
end

function PickerPanel:close()
    ISCollapsableWindowJoypad.close(self)
end

---------------------------------------------------------------------------
-- Keyboard
---------------------------------------------------------------------------

function PickerPanel:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function PickerPanel:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:onCancel()
    end
end

return PickerPanel
