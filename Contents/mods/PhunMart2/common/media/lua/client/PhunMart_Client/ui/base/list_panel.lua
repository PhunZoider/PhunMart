if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local Core = PhunMart
local tools = require "PhunMart_Client/ui/ui_utils"
require "PhunMart/references"

local FONT_HGT_SMALL = tools.FONT_HGT_SMALL
local FONT_HGT_MEDIUM = tools.FONT_HGT_MEDIUM
local FONT_SCALE = tools.FONT_SCALE
local PAD = math.max(10, math.floor(10 * FONT_SCALE))
local ROW_H = FONT_HGT_SMALL + math.floor(6 * FONT_SCALE)
local BUTTON_HGT = tools.BUTTON_HGT
local HEADER_HGT = tools.HEADER_HGT
local SCROLLBAR_W = 13

local ListPanel = ISCollapsableWindowJoypad:derive("PhunMartListPanel")

-- Open panels, weakly held so closed ones fall out on their own.
local liveInstances = setmetatable({}, {
    __mode = "k"
})

-- Re-read whenever the definitions recompile, so a change made anywhere (a
-- different panel, the in-shop menu, another admin in multiplayer) shows up
-- without reopening the window. Subclasses opt in by setting UI.refresh.
Events[Core.events.OnDefsUpdated].Add(function()
    for inst in pairs(liveInstances) do
        if inst.refresh and inst.isVisible and inst:isVisible() then
            inst:refresh()
        end
    end
end)

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
    liveInstances[o] = true
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
    -- Back-reference: doDrawItem runs with the list box as self, so a row
    -- renderer has no other route to the panel that owns it.
    list.panel = self
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

    -- Only shown on panels that declare a definition kind, since the other
    -- lists (token rewards, the global blacklist) are not override-backed and
    -- have nothing to compare against.
    if self._defKind then
        local tick = ISTickBox:new(0, PAD, BUTTON_HGT, BUTTON_HGT, "")
        tick:initialise()
        tick:instantiate()
        tick:addOption(getText("IGUI_PhunMart_Lbl_OnlyChanged"), nil)
        tick:setSelected(1, false)
        -- The stripe colours mean nothing on their own, and this is the only
        -- control that sits next to them.
        tick.tooltip = getText("IGUI_PhunMart_Tip_OnlyChanged")
        tick.changeOptionMethod = function()
            self:applyFilter()
        end
        tick.changeOptionTarget = self
        self._buttonBar:addChild(tick)
        self._onlyChangedTick = tick
        self._onlyChangedW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Lbl_OnlyChanged")) +
                                 BUTTON_HGT + PAD
    end

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
-- @param opts  How defaultDrawRow should render this column:
--   field  key into the row's data table
--   text   function(data) -> string, when the cell isn't a plain field
--   color  {r,g,b} or function(data) -> r,g,b; defaults to white for the first
--          column and grey for the rest
--   align  "right" to right-align against the list edge
function ListPanel:addListColumn(name, size, opts)
    opts = opts or {}
    table.insert(self._columnDefs, {
        name = name,
        size = size,
        field = opts.field,
        text = opts.text,
        color = opts.color,
        align = opts.align
    })
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

---------------------------------------------------------------------------
-- Customisation state
---------------------------------------------------------------------------

-- A subclass declares which definition category it edits by setting _defKind
-- on the class table, e.g. `UI._defKind = "pools"`. That enables the row
-- markers and the "only my changes" filter. It is a field rather than a setter
-- because createChildren reads it, so a setter would have to be called before
-- initialise and could be forgotten. Panels backed by something other than the
-- override files simply leave it unset.

---------------------------------------------------------------------------
-- "Used by" line
--
-- The definition tables only ever store the forward direction, so until now
-- nothing could answer "what breaks if I change this?". The edit form already
-- shows what a definition points at, via its own pickers; this is the opposite
-- direction, which was not available anywhere.
--
-- Recomputed only when the selection changes or the definitions recompile:
-- references.find scans every table, which is fine on a click and wasteful at
-- sixty frames a second.
---------------------------------------------------------------------------

--- True when this panel's category is one something else can point at.
function ListPanel:showsReferences()
    return self._defKind ~= nil and Core.references.canBeReferenced(self._defKind)
end

function ListPanel:updateReferenceLine()
    if not self:showsReferences() then
        return
    end

    local key
    local sel = self.list.selected
    if sel and sel > 0 and self.list.items[sel] then
        key = self:getRowKey(self.list.items[sel].item)
    end

    if key == self._refsKey and not self._refsDirty then
        return
    end
    self._refsKey = key
    self._refsDirty = false

    if not key then
        self._refsText = ""
        self._refsOrphan = false
        return
    end

    local found = Core.references.find(self._defKind, key)
    self._refsOrphan = #found == 0
    if self._refsOrphan then
        -- Worth saying out loud: an unreferenced definition is dead weight, and
        -- there was previously no way to notice.
        self._refsText = getText("IGUI_PhunMart_Lbl_UsedByNothing")
    else
        self._refsText = getText("IGUI_PhunMart_Lbl_UsedBy", Core.references.summarise(found))
    end
end

--- Where the key lives in a row's data. Every definition panel stores it as
--- `key`; override if one ever doesn't.
function ListPanel:getRowKey(itemData)
    return itemData and itemData.key
end

--- "custom" for an admin-created definition, "modified" for a shipped one that
--- has been edited, "stock" for one nobody has touched. nil when the panel has
--- no definition kind to ask about.
function ListPanel:rowState(key)
    if not self._defKind or not key then
        return nil
    end
    if not Core.isShippedKey(self._defKind, key) then
        return "custom"
    end
    if Core.isOverriddenKey(self._defKind, key) then
        return "modified"
    end
    return "stock"
end

--- Draw the state marker for a row. Called from a subclass's doDrawItem, so
--- `listSelf` is the list box rather than the panel.
--- A stripe down the left edge rather than a text colour, because the row
--- renderers already use text colour for other things (sticky pools, disabled
--- entries) and the two meanings would collide.
function ListPanel.drawStateStripe(listSelf, y, key)
    local panel = listSelf.panel
    if not panel then
        return
    end
    local state = panel:rowState(key)
    if state == "custom" then
        listSelf:drawRect(0, y, 3, listSelf.itemheight, 0.9, 0.35, 0.7, 1)
    elseif state == "modified" then
        listSelf:drawRect(0, y, 3, listSelf.itemheight, 0.9, 0.9, 0.7, 0.25)
    end
end

---------------------------------------------------------------------------
-- Row rendering
---------------------------------------------------------------------------

--- Generic row renderer driven by the column definitions.
--- Every panel used to carry its own copy of this: identical cull check,
--- selection highlight, alternating shade, border and stencilled column loop,
--- differing only in which field each column read and what colour it drew in.
--- Those differences are declared on the column now, so a change to row
--- styling is one edit rather than six, and the lists cannot drift apart.
--- Runs with the list box as `listSelf`, which is why it reaches the owning
--- panel through the back-reference rather than through self.
function ListPanel.defaultDrawRow(listSelf, y, item, alt)
    local h = listSelf.itemheight
    if y + listSelf:getYScroll() + h < 0 or y + listSelf:getYScroll() >= listSelf.height then
        return y + h
    end

    local panel = listSelf.panel
    local data = item.item
    local a = 0.9

    if listSelf.selected == item.index then
        listSelf:drawRect(0, y, listSelf:getWidth(), h, 0.3, 0.7, 0.35, 0.15)
    end
    if alt then
        listSelf:drawRect(0, y, listSelf:getWidth(), h, 0.3, 0.6, 0.5, 0.5)
    end
    listSelf:drawRectBorder(0, y, listSelf:getWidth(), h, a, listSelf.borderColor.r, listSelf.borderColor.g,
        listSelf.borderColor.b)

    ListPanel.drawStateStripe(listSelf, y, panel and panel:getRowKey(data))

    local cols = (panel and panel._columnDefs) or {}
    local textY = y + (h - FONT_HGT_SMALL) / 2
    local rightEdge = listSelf.width - SCROLLBAR_W
    local clipY = math.max(0, y + listSelf:getYScroll())
    local clipY2 = math.min(listSelf.height, y + listSelf:getYScroll() + h)

    for i, col in ipairs(cols) do
        local x = listSelf.columns[i] and listSelf.columns[i].size or 0
        local nextX = (listSelf.columns[i + 1] and listSelf.columns[i + 1].size) or rightEdge

        local text = ""
        if col.text then
            text = col.text(data) or ""
        elseif col.field then
            text = data[col.field] or ""
        end
        if type(text) ~= "string" then
            text = tostring(text)
        end

        if text ~= "" then
            -- First column reads as the row's identity, so it gets full white.
            local r, g, b = 0.8, 0.8, 0.8
            if i == 1 then
                r, g, b = 1, 1, 1
            end
            if type(col.color) == "function" then
                local cr, cg, cb = col.color(data)
                if cr then
                    r, g, b = cr, cg, cb
                end
            elseif type(col.color) == "table" then
                r, g, b = col.color[1], col.color[2], col.color[3]
            end

            local tx
            if col.align == "right" then
                tx = rightEdge - getTextManager():MeasureStringX(listSelf.font, text) - 10
            elseif i == 1 then
                tx = 10
            else
                tx = x + 4
            end

            listSelf:setStencilRect(x, clipY, math.max(0, nextX - x), clipY2 - clipY)
            listSelf:drawText(text, tx, textY, r, g, b, a, listSelf.font)
            listSelf:clearStencilRect()
        end
    end

    listSelf.itemsHeight = y + h
    return listSelf.itemsHeight
end

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
    -- The reference counts may have moved with the data.
    self._refsDirty = true
    -- Clear the box too, not just the cached text. Otherwise a refresh (which
    -- every save triggers) leaves a filter showing that isn't being applied.
    if self._filterEntry then
        self._filterEntry:setText("")
    end
    self._lastFilterText = ""
end

--- Reapply the current filter against _allItems.
function ListPanel:applyFilter()
    local filterText = self._filterEntry:getText():lower()
    self._lastFilterText = filterText

    local onlyChanged = self._onlyChangedTick and self._onlyChangedTick:isSelected(1)

    self.list:clear()
    for _, entry in ipairs(self._allItems) do
        local include = true

        if onlyChanged then
            local state = self:rowState(self:getRowKey(entry.data))
            include = state == "custom" or state == "modified"
        end

        if include and filterText ~= "" then
            local searchable = self:getFilterText(entry.data) or entry.text
            include = searchable:lower():find(filterText, 1, true) ~= nil
        end

        if include then
            self.list:addItem(entry.text, entry.data)
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

    -- Left side of button bar: filter fills whatever the buttons and the
    -- only-my-changes tickbox leave behind.
    local filterLblW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Lbl_Filter")) + 8
    if self._onlyChangedTick then
        local tickX = rightX - self._onlyChangedW
        self._onlyChangedTick:setX(tickX)
        self._onlyChangedTick:setY(PAD)
        rightX = tickX - PAD
    end
    self._filterLabel:setX(PAD)
    self._filterEntry:setX(PAD + filterLblW)
    self._filterEntry:setWidth(math.max(math.floor(60 * FONT_SCALE), rightX - PAD - filterLblW))

    -- Reapply filter when text changes
    local currentFilter = self._filterEntry:getText()
    if currentFilter ~= self._lastFilterText then
        self:applyFilter()
    end

    -- List: fills space between description and button bar, less the "used by"
    -- line when this panel has one. Reserved whether or not there is a
    -- selection, so the list doesn't resize as rows are clicked.
    local refsH = self:showsReferences() and (FONT_HGT_SMALL + PAD) or 0
    local listY = PAD + descH + HEADER_HGT
    local listH = contentH - listY - btnBarH - refsH
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

    -- "Used by" line, sitting between the list and the buttons.
    if refsH > 0 then
        self:updateReferenceLine()
        if self._refsText and self._refsText ~= "" then
            local r, g, b = 0.75, 0.75, 0.75
            if self._refsOrphan then
                r, g, b = 0.55, 0.55, 0.55
            end
            self:drawText(self._refsText, PAD, th + listY + listH + math.floor(PAD / 2), r, g, b, 1, UIFont.Small)
        end
    end
end

return ListPanel
