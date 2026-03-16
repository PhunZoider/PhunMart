if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local tools = require "PhunMart_Client/ui/ui_utils"

local FONT_HGT_SMALL = tools.FONT_HGT_SMALL
local FONT_HGT_MEDIUM = tools.FONT_HGT_MEDIUM
local FONT_SCALE = tools.FONT_SCALE
local PAD = math.max(10, math.floor(10 * FONT_SCALE))
local ROW_H = FONT_HGT_SMALL + math.floor(6 * FONT_SCALE)
local BUTTON_HGT = tools.BUTTON_HGT
local HEADER_HGT = tools.HEADER_HGT
local SCROLLBAR_W = 13

local ListPanel = ISCollapsableWindowJoypad:derive("PhunMartListPanel")

-- Export constants for subclasses
ListPanel.PAD = PAD
ListPanel.ROW_H = ROW_H
ListPanel.FONT_SCALE = FONT_SCALE
ListPanel.FONT_HGT_SMALL = FONT_HGT_SMALL
ListPanel.FONT_HGT_MEDIUM = FONT_HGT_MEDIUM
ListPanel.HEADER_HGT = HEADER_HGT
ListPanel.SCROLLBAR_W = SCROLLBAR_W

---------------------------------------------------------------------------
-- Construction
---------------------------------------------------------------------------

function ListPanel:new(x, y, width, height, player)
    local o = ISCollapsableWindowJoypad:new(x, y, width, height, player)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.playerIndex = player:getPlayerNum()
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 0.8}
    o.moveWithMouse = false
    o.anchorRight = true
    o.anchorBottom = true
    o:setWantKeyEvents(true)
    return o
end

---------------------------------------------------------------------------
-- Skeleton: title bar (from ISCollapsableWindowJoypad), description area,
-- scrolling list, and bottom button bar.
---------------------------------------------------------------------------

function ListPanel:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    local w = self.width
    local h = self.height - th - rh

    -- Main content panel (everything below title bar)
    local mainPanel = ISPanel:new(0, th, w, h)
    mainPanel:initialise()
    mainPanel:instantiate()
    self:addChild(mainPanel)
    self._mainPanel = mainPanel

    -- Button bar at bottom
    local btnBarH = BUTTON_HGT + PAD * 2
    local btnBar = ISPanel:new(0, h - btnBarH, w, btnBarH)
    btnBar:initialise()
    btnBar:instantiate()
    self._mainPanel:addChild(btnBar)
    self._buttonBar = btnBar
    self._bottomButtons = {}

    -- Scrolling list (fills the space between description and button bar)
    local list = ISScrollingListBox:new(PAD, HEADER_HGT, w - PAD * 2, 100)
    list:initialise()
    list:instantiate()
    list.itemheight = FONT_HGT_SMALL + 6 * 2
    list.selected = 0
    list.joypadParent = self
    list.font = UIFont.NewSmall
    list.drawBorder = true
    self._mainPanel:addChild(list)
    self.list = list
    self._columnDefs = {}
    self._allItems = {}

    -- Filter entry (in button bar, left side)
    local filterLblW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Lbl_Filter")) + 8
    local filterLbl = ISLabel:new(PAD, PAD, BUTTON_HGT, getText("IGUI_PhunMart_Lbl_Filter"), 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    filterLbl:initialise()
    self._buttonBar:addChild(filterLbl)
    self._filterLabel = filterLbl

    local filterEntry = ISTextEntryBox:new("", PAD + filterLblW, PAD, 100, BUTTON_HGT)
    filterEntry:initialise()
    filterEntry:instantiate()
    filterEntry:setClearButton(true)
    self._buttonBar:addChild(filterEntry)
    self._filterEntry = filterEntry
    self._lastFilterText = ""

    -- Close button (right-aligned in button bar)
    local closeBtnW = math.max(math.floor(70 * FONT_SCALE),
        getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Btn_Close")) + PAD * 2)
    local closeBtn = ISButton:new(0, PAD, closeBtnW, BUTTON_HGT, getText("IGUI_PhunMart_Btn_Close"), self, self.close)
    closeBtn:initialise()
    closeBtn:instantiate()
    if closeBtn.enableCancelColor then
        closeBtn:enableCancelColor()
    end
    self._buttonBar:addChild(closeBtn)
    self._closeBtn = closeBtn
end

---------------------------------------------------------------------------
-- Column / button helpers (called by subclass in createChildren)
---------------------------------------------------------------------------

--- Add a column to the list.
-- @param name  Column header text
-- @param size  If 0, starts at left edge. If < 1, treated as a fraction of
--              list width (recalculated on resize). If >= 1, absolute pixels.
function ListPanel:addListColumn(name, size)
    table.insert(self._columnDefs, {name = name, size = size})
    -- Set initial position; fractional values are recalculated in prerender
    local pos = size
    if size > 0 and size < 1 then
        pos = math.floor(self.list.width * size)
    end
    self.list:addColumn(name, pos)
end

--- Add a button to the bottom bar (left-aligned).
-- @param text            Button label
-- @param callback        Click handler
-- @param requiresSelection  If true, button is disabled when no list row is selected
function ListPanel:addBottomButton(text, callback, requiresSelection)
    local btnW = math.max(math.floor(70 * FONT_SCALE),
        getTextManager():MeasureStringX(UIFont.Small, text) + PAD * 2)
    local btn = ISButton:new(0, PAD, btnW, BUTTON_HGT, text, self, callback)
    btn:initialise()
    btn:instantiate()
    btn._requiresSelection = requiresSelection
    self._buttonBar:addChild(btn)
    table.insert(self._bottomButtons, btn)
    return btn
end

---------------------------------------------------------------------------
-- Keyboard
---------------------------------------------------------------------------

function ListPanel:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function ListPanel:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
    end
end

function ListPanel:close()
    ISCollapsableWindowJoypad.close(self)
end

---------------------------------------------------------------------------
-- Filtering
---------------------------------------------------------------------------

--- Override in subclass to return the searchable text for a list item.
-- Receives the item data (the second arg passed to list:addItem).
-- Default: uses the display text (first arg to addItem).
function ListPanel:getFilterText(itemData)
    return nil
end

--- Call this instead of self.list:addItem() so the base can track all items
--- for filtering. Arguments match ISScrollingListBox:addItem(text, data).
function ListPanel:addListItem(text, data)
    table.insert(self._allItems, {text = text, data = data})
    self.list:addItem(text, data)
end

--- Clear all items (call at start of refresh).
function ListPanel:clearList()
    self._allItems = {}
    self.list:clear()
    self._lastFilterText = ""
end

--- Reapply the current filter against _allItems.
function ListPanel:applyFilter()
    local filterText = self._filterEntry:getText():lower()
    self._lastFilterText = filterText

    self.list:clear()
    for _, entry in ipairs(self._allItems) do
        if filterText == "" then
            self.list:addItem(entry.text, entry.data)
        else
            local searchable = self:getFilterText(entry.data)
            if not searchable then
                searchable = entry.text
            end
            if searchable:lower():find(filterText, 1, true) then
                self.list:addItem(entry.text, entry.data)
            end
        end
    end
end

---------------------------------------------------------------------------
-- Layout (prerender)
---------------------------------------------------------------------------

function ListPanel:prerender()
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

    -- Description area height
    local descH = 0
    if self.description and self.description ~= "" then
        local maxW = w - PAD * 2
        self._descLines = tools.wrapText(self.description, maxW, UIFont.Small)
        descH = #self._descLines * FONT_HGT_SMALL + PAD
    end

    -- Button bar at bottom
    local btnBarH = BUTTON_HGT + PAD * 2
    self._buttonBar:setX(0)
    self._buttonBar:setY(contentH - btnBarH)
    self._buttonBar:setWidth(w)
    self._buttonBar:setHeight(btnBarH)

    -- Right side of button bar: Close, then action buttons right-to-left
    local hasSelection = self.list.selected and self.list.selected > 0
    local rightX = w - PAD
    self._closeBtn:setX(rightX - self._closeBtn.width)
    rightX = rightX - self._closeBtn.width - PAD

    for i = #self._bottomButtons, 1, -1 do
        local btn = self._bottomButtons[i]
        if btn:isVisible() then
            rightX = rightX - btn.width
            btn:setX(rightX)
            if btn._requiresSelection then
                btn:setEnable(hasSelection)
            end
            rightX = rightX - PAD
        end
    end

    -- Left side of button bar: filter fills remaining space
    local filterLblW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Lbl_Filter")) + 8
    self._filterLabel:setX(PAD)
    self._filterEntry:setX(PAD + filterLblW)
    self._filterEntry:setWidth(rightX - PAD - filterLblW)

    -- Reapply filter when text changes
    local currentFilter = self._filterEntry:getText()
    if currentFilter ~= self._lastFilterText then
        self:applyFilter()
    end

    -- List: fills space between description and button bar
    local listY = PAD + descH + HEADER_HGT
    local listH = contentH - listY - btnBarH
    self.list:setX(PAD)
    self.list:setY(listY)
    self.list:setWidth(w - PAD * 2)
    self.list:setHeight(listH)

    -- Recalculate fractional column positions
    local listW = self.list.width
    for i, colDef in ipairs(self._columnDefs) do
        if colDef.size > 0 and colDef.size < 1 then
            self.list.columns[i].size = math.floor(listW * colDef.size)
        end
    end

    -- Draw description text (over the main panel area)
    if self._descLines then
        local dy = th + PAD
        for _, line in ipairs(self._descLines) do
            self:drawText(line, PAD, dy, 0.6, 0.6, 0.6, 1, UIFont.Small)
            dy = dy + FONT_HGT_SMALL
        end
        -- Subtle separator line below description
        self:drawRect(PAD, dy + 2, w - PAD * 2, 1, 0.3, 0.4, 0.4, 0.4)
    end
end

return ListPanel
