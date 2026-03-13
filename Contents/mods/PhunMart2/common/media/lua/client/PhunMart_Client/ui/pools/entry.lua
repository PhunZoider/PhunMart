if isServer() then
    return
end

local tools = require "PhunMart_Client/ui/ui_utils"
local Core = PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_SCALE = FONT_HGT_SMALL / 14
local BUTTON_HGT = FONT_HGT_SMALL + 6

local profileName = "PhunMartUIPoolsEntry"

Core.ui.pools_entry = ISPanel:derive(profileName);
Core.ui.pools_entry.instances = {}
local UI = Core.ui.pools_entry

-- ---------------------------------------------------------------------------
-- A PoolSet entry holds an ordered list of {key, weight} pool references.
-- Data shape:
--   { keys = { {key="pool_foo", weight=1.0}, {key="pool_bar", weight=0.5} } }
-- ---------------------------------------------------------------------------

function UI:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    o.player = opts.player or getPlayer()
    o.playerIndex = o.player:getPlayerNum()
    o:setWantKeyEvents(true)
    o.keys = {}
    o.isDirtyValue = false
    self.instance = o
    return o
end

function UI:createChildren()
    ISPanel.createChildren(self)

    local pad = 10
    self.controls = {}

    local lbl = ISLabel:new(pad, pad, FONT_HGT_MEDIUM,
        "Pool references - each entry selects a pool to draw items from.", 1, 1, 1, 0.7, UIFont.Small, true)
    lbl:initialise();
    lbl:instantiate()
    self:addChild(lbl)
    self.controls.lbl = lbl

    local listY = lbl.y + lbl.height + pad
    local listH = self.height - listY - BUTTON_HGT - pad * 3
    local list = ISScrollingListBox:new(pad, listY, self.width - pad * 2, listH)
    list:initialise();
    list:instantiate()
    list.itemheight = FONT_HGT_SMALL + 8
    list.selected = 0
    list.joypadParent = self
    list.font = UIFont.NewSmall
    list.drawBorder = true
    list.doDrawItem = self.drawRow
    list:addColumn("Pool Key", 0)
    list:addColumn("Weight", 200)
    list.onMouseUp = function(l, x, y)
        local row = l:rowAt(x, y)
        if row and row > 0 then
            l.selected = row
        end
    end
    list:setOnMouseDoubleClick(self, self.onEditSelected)
    self.controls.list = list
    self:addChild(list)

    local btnY = listY + listH + pad

    local btnAdd = ISButton:new(pad, btnY, 80, BUTTON_HGT, "Add", self, self.onAdd)
    btnAdd:initialise();
    btnAdd:instantiate()
    if btnAdd.enableAcceptColor then
        btnAdd:enableAcceptColor()
    end
    self.controls.btnAdd = btnAdd
    self:addChild(btnAdd)

    local btnEdit = ISButton:new(pad + 90, btnY, 80, BUTTON_HGT, "Edit", self, self.onEditSelected)
    btnEdit:initialise();
    btnEdit:instantiate()
    self.controls.btnEdit = btnEdit
    self:addChild(btnEdit)

    local btnRemove = ISButton:new(pad + 180, btnY, 80, BUTTON_HGT, "Remove", self, self.onRemove)
    btnRemove:initialise();
    btnRemove:instantiate()
    if btnRemove.enableCancelColor then
        btnRemove:enableCancelColor()
    end
    self.controls.btnRemove = btnRemove
    self:addChild(btnRemove)

    local btnUp = ISButton:new(pad + 270, btnY, 60, BUTTON_HGT, "Up", self, self.onMoveUp)
    btnUp:initialise();
    btnUp:instantiate()
    self.controls.btnUp = btnUp
    self:addChild(btnUp)

    local btnDown = ISButton:new(pad + 340, btnY, 60, BUTTON_HGT, "Down", self, self.onMoveDown)
    btnDown:initialise();
    btnDown:instantiate()
    self.controls.btnDown = btnDown
    self:addChild(btnDown)
end

-- ---------------------------------------------------------------------------
-- Data in / out
-- ---------------------------------------------------------------------------

function UI:setData(data)
    data = data or {}
    self.keys = {}
    for _, ref in ipairs(data.keys or {}) do
        table.insert(self.keys, {
            key = ref.key or "",
            weight = ref.weight or 1.0
        })
    end
    self:refreshList()
    self.isDirtyValue = false
end

function UI:getData()
    local refs = {}
    for _, ref in ipairs(self.keys) do
        if ref.key and ref.key ~= "" then
            table.insert(refs, {
                key = ref.key,
                weight = tonumber(ref.weight) or 1.0
            })
        end
    end
    return {
        keys = refs
    }
end

function UI:isDirty()
    return self.isDirtyValue
end

-- ---------------------------------------------------------------------------
-- List rendering
-- ---------------------------------------------------------------------------

function UI:refreshList()
    local list = self.controls.list
    list:clear()
    for _, ref in ipairs(self.keys) do
        list:addItem(ref.key, ref)
    end
end

function UI:drawRow(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9
    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15)
    end
    if alt then
        self:drawRect(0, y, self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5)
    end
    self:drawRectBorder(0, y, self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    local xoff = 8
    local col2x = self.columns[2].size
    self:setStencilRect(0, math.max(0, y + self:getYScroll()), col2x,
        math.min(self.height, y + self:getYScroll() + self.itemheight))
    self:drawText(item.item.key or "", xoff, y + 3, 1, 1, 1, a, self.font)
    self:clearStencilRect()

    local weightStr = tostring(item.item.weight or 1.0)
    self:drawText(weightStr, col2x + xoff, y + 3, 0.8, 0.9, 0.6, a, self.font)

    self.itemsHeight = y + self.itemheight
    return self.itemsHeight
end

-- ---------------------------------------------------------------------------
-- Button handlers
-- ---------------------------------------------------------------------------

function UI:onAdd()
    self:openKeyWeightDialog(nil, nil, function(key, weight)
        table.insert(self.keys, {
            key = key,
            weight = weight
        })
        self:refreshList()
        self.isDirtyValue = true
    end)
end

function UI:onEditSelected()
    local list = self.controls.list
    if not (list.selected and list.selected > 0 and list.items[list.selected]) then
        return
    end
    local ref = list.items[list.selected].item
    local idx = list.selected
    self:openKeyWeightDialog(ref.key, ref.weight, function(key, weight)
        self.keys[idx] = {
            key = key,
            weight = weight
        }
        self:refreshList()
        self.isDirtyValue = true
    end)
end

function UI:onRemove()
    local list = self.controls.list
    if not (list.selected and list.selected > 0) then
        return
    end
    table.remove(self.keys, list.selected)
    list.selected = math.min(list.selected, #self.keys)
    self:refreshList()
    self.isDirtyValue = true
end

function UI:onMoveUp()
    local list = self.controls.list
    local i = list.selected
    if not (i and i > 1) then
        return
    end
    self.keys[i], self.keys[i - 1] = self.keys[i - 1], self.keys[i]
    self:refreshList()
    list.selected = i - 1
    self.isDirtyValue = true
end

function UI:onMoveDown()
    local list = self.controls.list
    local i = list.selected
    if not (i and i > 0 and i < #self.keys) then
        return
    end
    self.keys[i], self.keys[i + 1] = self.keys[i + 1], self.keys[i]
    self:refreshList()
    list.selected = i + 1
    self.isDirtyValue = true
end

-- ---------------------------------------------------------------------------
-- Key + Weight input dialog
-- ---------------------------------------------------------------------------

function UI:openKeyWeightDialog(existingKey, existingWeight, cb)
    local fs = FONT_SCALE
    local dw = math.floor(320 * fs)
    local dh = math.floor(160 * fs)
    local core = getCore()
    local dx = math.floor((core:getScreenWidth() - dw) / 2)
    local dy = math.floor((core:getScreenHeight() - dh) / 2)

    local dlg = ISPanel:new(dx, dy, dw, dh)
    dlg:initialise();
    dlg:instantiate()
    dlg.backgroundColor = {
        r = 0.1,
        g = 0.1,
        b = 0.1,
        a = 0.95
    }
    dlg.moveWithMouse = true
    dlg:addToUIManager()
    dlg:setAlwaysOnTop(true)

    local pad = 10

    local lblKey = ISLabel:new(pad, pad, FONT_HGT_SMALL, "Pool Key:", 1, 1, 1, 1, UIFont.Small, true)
    lblKey:initialise();
    lblKey:instantiate();
    dlg:addChild(lblKey)

    local txtKey = ISTextEntryBox:new(existingKey or "", pad + 80, pad, dw - pad * 2 - 80, FONT_HGT_SMALL + 4)
    txtKey:initialise();
    txtKey:instantiate();
    dlg:addChild(txtKey)

    local lblW = ISLabel:new(pad, pad * 2 + FONT_HGT_SMALL + 8, FONT_HGT_SMALL, "Weight:", 1, 1, 1, 1, UIFont.Small,
        true)
    lblW:initialise();
    lblW:instantiate();
    dlg:addChild(lblW)

    local txtW = ISTextEntryBox:new(tostring(existingWeight or 1.0), pad + 80, lblW.y, 100, FONT_HGT_SMALL + 4)
    txtW:initialise();
    txtW:instantiate();
    dlg:addChild(txtW)

    local hint = ISLabel:new(pad, lblW.y + FONT_HGT_SMALL + pad + 4, FONT_HGT_SMALL,
        "Weight: relative draw probability, e.g. 1.0 or 0.5", 0.65, 0.65, 0.65, 1, UIFont.Small, true)
    hint:initialise();
    hint:instantiate();
    dlg:addChild(hint)

    local btnOK = ISButton:new(dw - 90 - pad, dh - BUTTON_HGT - pad, 80, BUTTON_HGT, "OK", dlg, function()
        local key = txtKey:getText():match("^%s*(.-)%s*$")
        local weight = tonumber(txtW:getText()) or 1.0
        if key ~= "" then
            cb(key, weight)
        end
        dlg:removeFromUIManager()
    end)
    btnOK:initialise();
    btnOK:instantiate()
    if btnOK.enableAcceptColor then
        btnOK:enableAcceptColor()
    end
    dlg:addChild(btnOK)

    local btnCancel = ISButton:new(dw - 180 - pad, dh - BUTTON_HGT - pad, 80, BUTTON_HGT, "Cancel", dlg, function()
        dlg:removeFromUIManager()
    end)
    btnCancel:initialise();
    btnCancel:instantiate()
    if btnCancel.enableCancelColor then
        btnCancel:enableCancelColor()
    end
    dlg:addChild(btnCancel)
end

-- ---------------------------------------------------------------------------
-- Prerender: keep list filling available space as panel resizes
-- ---------------------------------------------------------------------------

function UI:prerender()
    ISPanel.prerender(self)
    local pad = 10
    local list = self.controls.list
    local btnY = self.height - BUTTON_HGT - pad * 2
    list:setWidth(self.width - pad * 2)
    list:setHeight(btnY - list.y - pad)
    list.columns[2].size = math.min(100, list.width / 3)

    self.controls.btnAdd:setY(btnY)
    self.controls.btnEdit:setY(btnY)
    self.controls.btnRemove:setY(btnY)
    self.controls.btnUp:setY(btnY)
    self.controls.btnDown:setY(btnY)

    local hasSelection = list.selected and list.selected > 0
    self.controls.btnEdit:setEnable(hasSelection == true)
    self.controls.btnRemove:setEnable(hasSelection == true)
    self.controls.btnUp:setEnable(hasSelection and list.selected > 1)
    self.controls.btnDown:setEnable(hasSelection and list.selected < #self.keys)
end
