if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local Core = PhunMart
local tools = require "PhunMart_Client/ui/ui_utils"
require "PhunMart/references"

local FONT_HGT_SMALL = tools.FONT_HGT_SMALL
local FONT_SCALE = tools.FONT_SCALE
local PAD = math.max(10, math.floor(10 * FONT_SCALE))
local ROW_H = FONT_HGT_SMALL + math.floor(6 * FONT_SCALE)
local BUTTON_HGT = tools.BUTTON_HGT
local CHECK_SZ = FONT_HGT_SMALL

---------------------------------------------------------------------------
-- Pending restock tracker.
--
-- A definition edit recompiles immediately, but machines already standing in
-- the world keep the offers they rolled at their last restock. Without saying
-- so, an admin deletes an item, walks to the machine, still sees it, and
-- concludes the editor is broken.
--
-- Affected shop types accumulate here rather than interrupting after every
-- save, so a session of ten edits produces one running list. Closing the panel
-- hides it and keeps the list: the only things that empty it are restocking or
-- an explicit Clear. It sits bottom-left and never raises itself above the
-- editors, so it surfaces as the admin closes their windows rather than
-- fighting them for space.
---------------------------------------------------------------------------
local PendingRestock = {}
Core.ui.pending_restock = PendingRestock

local pending = {} -- shop type -> true
local checked = {} -- shop type -> true, defaults on when first added
local panel = nil

local function shopLabel(t)
    return getTextOrNull("IGUI_PhunMart_Shop_" .. t) or t
end

local function pendingList()
    local out = {}
    for t in pairs(pending) do
        table.insert(out, t)
    end
    table.sort(out, function(a, b)
        return shopLabel(a):lower() < shopLabel(b):lower()
    end)
    return out
end

function PendingRestock.count()
    local n = 0
    for _ in pairs(pending) do
        n = n + 1
    end
    return n
end

function PendingRestock.checkedCount()
    local n = 0
    for t in pairs(pending) do
        if checked[t] then
            n = n + 1
        end
    end
    return n
end

---------------------------------------------------------------------------
-- Panel
---------------------------------------------------------------------------

local Panel = ISCollapsableWindowJoypad:derive("PhunMartPendingRestockPanel")

function Panel:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local list = ISScrollingListBox:new(PAD, 0, self.width - PAD * 2, 100)
    list:initialise()
    list:instantiate()
    list.itemheight = ROW_H
    list.selected = 0
    list.font = UIFont.Small
    list.drawBorder = true
    list.backgroundColor = {
        r = 0.05,
        g = 0.05,
        b = 0.05,
        a = 0.8
    }
    list.doDrawItem = function(listSelf, y, item, alt)
        return self:drawRow(listSelf, y, item, alt)
    end
    list.onMouseUp = function(listSelf, x, y)
        local row = listSelf:rowAt(x, y)
        if row and row > 0 and row <= #listSelf.items then
            local key = listSelf.items[row].item.key
            checked[key] = not checked[key] or nil
        end
        return true
    end
    self:addChild(list)
    self.list = list

    self.toggleBtn = ISButton:new(0, 0, math.floor(70 * FONT_SCALE), BUTTON_HGT,
        getText("IGUI_PhunMart_Btn_AllNone"), self, Panel.onToggleAll)
    self.toggleBtn:initialise()
    self:addChild(self.toggleBtn)

    self.restockBtn = ISButton:new(0, 0, math.floor(130 * FONT_SCALE), BUTTON_HGT, "", self, Panel.onRestock)
    self.restockBtn:initialise()
    self:addChild(self.restockBtn)

    self.clearBtn = ISButton:new(0, 0, math.floor(70 * FONT_SCALE), BUTTON_HGT, getText("IGUI_PhunMart_Btn_Clear"),
        self, Panel.onClear)
    self.clearBtn:initialise()
    if self.clearBtn.enableCancelColor then
        self.clearBtn:enableCancelColor()
    end
    self:addChild(self.clearBtn)
end

function Panel:drawRow(listSelf, y, item, alt)
    if y + listSelf:getYScroll() + listSelf.itemheight < 0 or y + listSelf:getYScroll() >= listSelf.height then
        return y + listSelf.itemheight
    end

    local entry = item.item
    local isOn = checked[entry.key]

    if isOn then
        listSelf:drawRect(0, y, listSelf:getWidth(), ROW_H, 0.25, 0.2, 0.5, 0.2)
    elseif alt then
        listSelf:drawRect(0, y, listSelf:getWidth(), ROW_H, 0.15, 0.5, 0.5, 0.5)
    end

    local cx = PAD
    local cy = y + math.floor((ROW_H - CHECK_SZ) / 2)
    listSelf:drawRectBorder(cx, cy, CHECK_SZ, CHECK_SZ, 0.8, 0.7, 0.7, 0.7)
    if isOn then
        listSelf:drawRect(cx + 2, cy + 2, CHECK_SZ - 4, CHECK_SZ - 4, 0.9, 0.3, 0.8, 0.3)
    end

    local ty = y + math.floor((ROW_H - FONT_HGT_SMALL) / 2)
    local r, g, b = 1, 1, 1
    if not isOn then
        r, g, b = 0.6, 0.6, 0.6
    end
    listSelf:drawText(entry.display, cx + CHECK_SZ + PAD, ty, r, g, b, 0.9, UIFont.Small)

    return y + ROW_H
end

function Panel:refreshList()
    self.list:clear()
    for _, t in ipairs(pendingList()) do
        self.list:addItem(shopLabel(t), {
            key = t,
            display = shopLabel(t)
        })
    end
end

function Panel:onToggleAll()
    local allOn = PendingRestock.checkedCount() == PendingRestock.count()
    for t in pairs(pending) do
        checked[t] = (not allOn) or nil
    end
end

function Panel:onRestock()
    PendingRestock.restockChecked()
end

function Panel:onClear()
    PendingRestock.clear()
end

function Panel:prerender()
    ISCollapsableWindowJoypad.prerender(self)

    local th = self:titleBarHeight()
    local y = th + PAD

    self._descLines = tools.wrapText(getText("IGUI_PhunMart_Desc_PendingRestock"), self.width - PAD * 2, UIFont.Small)
    for _, line in ipairs(self._descLines) do
        self:drawText(line, PAD, y, 0.7, 0.7, 0.7, 1, UIFont.Small)
        y = y + FONT_HGT_SMALL
    end
    y = y + PAD

    local btnRowH = BUTTON_HGT + PAD
    local listH = self.height - y - btnRowH - PAD - self:resizeWidgetHeight()
    self.list:setX(PAD)
    self.list:setY(y)
    self.list:setWidth(self.width - PAD * 2)
    self.list:setHeight(math.max(ROW_H, listH))

    local by = self.height - self:resizeWidgetHeight() - BUTTON_HGT - PAD
    self.toggleBtn:setX(PAD)
    self.toggleBtn:setY(by)

    self.restockBtn:setTitle(getText("IGUI_PhunMart_Btn_RestockN", tostring(PendingRestock.checkedCount())))
    self.restockBtn:setEnable(PendingRestock.checkedCount() > 0)
    self.clearBtn:setX(self.width - PAD - self.clearBtn.width)
    self.clearBtn:setY(by)
    self.restockBtn:setX(self.clearBtn.x - PAD - self.restockBtn.width)
    self.restockBtn:setY(by)
end

-- Closing keeps the list. Only restocking or Clear empties it, so an admin can
-- get the panel out of the way mid-session without losing the running total.
function Panel:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function Panel:new()
    local w = math.floor(320 * FONT_SCALE)
    local h = math.floor(280 * FONT_SCALE)
    local core = getCore()
    -- Bottom-left, clear of the centred editor windows.
    local x = math.floor(20 * FONT_SCALE)
    local y = core:getScreenHeight() - h - math.floor(120 * FONT_SCALE)
    local o = ISCollapsableWindowJoypad:new(x, math.max(20, y), w, h)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.85
    }
    o.borderColor = {
        r = 0.9,
        g = 0.7,
        b = 0.25,
        a = 1
    }
    o:setTitle(getText("IGUI_PhunMart_Title_PendingRestock"))
    o.resizable = true
    return o
end

---------------------------------------------------------------------------
-- API
---------------------------------------------------------------------------

--- Show the panel. Deliberately does not call bringToTop: the editors are
--- opened after it and should stay above, so it reveals itself as they close.
function PendingRestock.show()
    if PendingRestock.count() == 0 then
        return
    end
    if not panel then
        panel = Panel:new()
        panel:initialise()
    end
    panel:addToUIManager()
    panel:setVisible(true)
    panel:refreshList()
end

function PendingRestock.hide()
    if panel then
        panel:close()
    end
end

--- Record that a definition changed, and surface the shops it feeds.
-- A change that reaches no shop type (an unused price, say) adds nothing,
-- which is correct: nothing in the world is stale.
function PendingRestock.note(kind, key)
    if not key then
        return
    end
    local added = false
    for _, t in ipairs(Core.references.findShops(kind, key)) do
        if not pending[t] then
            pending[t] = true
            checked[t] = true
            added = true
        end
    end
    if added then
        PendingRestock.show()
    elseif panel and panel:isVisible() then
        panel:refreshList()
    end
end

--- For changes with no single owning definition, such as the global blacklist,
--- which every shop draws through.
function PendingRestock.noteAllShops()
    local shops = Core.defs and Core.defs.shops or {}
    local added = false
    for t in pairs(shops) do
        if not pending[t] then
            pending[t] = true
            checked[t] = true
            added = true
        end
    end
    if added then
        PendingRestock.show()
    end
end

--- Forget the list without restocking anything.
function PendingRestock.clear()
    pending = {}
    checked = {}
    PendingRestock.hide()
end

function PendingRestock.restockChecked()
    local types = {}
    for _, t in ipairs(pendingList()) do
        if checked[t] then
            table.insert(types, t)
        end
    end
    if #types == 0 then
        return
    end

    sendClientCommand(Core.name, Core.commands.restockShopTypes, {
        types = types
    })

    -- Drop only what was restocked, so anything left unticked stays on the list.
    for _, t in ipairs(types) do
        pending[t] = nil
        checked[t] = nil
    end

    if PendingRestock.count() == 0 then
        PendingRestock.hide()
    elseif panel and panel:isVisible() then
        panel:refreshList()
    end
end

return PendingRestock
