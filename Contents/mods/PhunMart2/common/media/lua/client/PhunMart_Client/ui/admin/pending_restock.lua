if isServer() then
    return
end

require "ISUI/ISPanel"
local Core = PhunMart
local tools = require "PhunMart_Client/ui/ui_utils"
require "PhunMart/references"

local FONT_HGT_SMALL = tools.FONT_HGT_SMALL
local FONT_HGT_MEDIUM = tools.FONT_HGT_MEDIUM
local FONT_SCALE = tools.FONT_SCALE
local PAD = math.max(10, math.floor(10 * FONT_SCALE))
local ROW_H = FONT_HGT_SMALL + math.floor(6 * FONT_SCALE)

---------------------------------------------------------------------------
-- Pending restock tracker.
--
-- A definition edit recompiles immediately, but machines already standing in
-- the world keep the offers they rolled at their last restock. Without saying
-- so, an admin deletes an item, walks to the machine, still sees it, and
-- concludes the editor is broken.
--
-- Rather than interrupt after every save, affected shop types accumulate here
-- and a single non-blocking bar reports them. An admin making ten edits gets
-- one bar that grows, and restocks once at the end.
---------------------------------------------------------------------------
local PendingRestock = {}
Core.ui.pending_restock = PendingRestock

local pending = {} -- set of shop type keys
local barInstance = nil

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

--- "Good Phoods, Pitty The Tool, CarAParts +2 more"
function PendingRestock.summary()
    local list = pendingList()
    if #list == 0 then
        return ""
    end
    local limit = math.min(#list, 3)
    local names = {}
    for i = 1, limit do
        names[i] = shopLabel(list[i])
    end
    local text = table.concat(names, ", ")
    if #list > limit then
        text = text .. " +" .. tostring(#list - limit) .. " more"
    end
    return text
end

---------------------------------------------------------------------------
-- The bar
---------------------------------------------------------------------------

local Bar = ISPanel:derive("PhunMartPendingRestockBar")

function Bar:createChildren()
    ISPanel.createChildren(self)

    local btnW = math.max(math.floor(110 * FONT_SCALE),
        getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Btn_RestockThese")) + PAD * 2)

    self.restockBtn = ISButton:new(0, 0, btnW, ROW_H, getText("IGUI_PhunMart_Btn_RestockThese"), self, function()
        PendingRestock.restockNow()
    end)
    self.restockBtn:initialise()
    self:addChild(self.restockBtn)

    local dismissW = math.max(math.floor(70 * FONT_SCALE),
        getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Btn_Dismiss")) + PAD * 2)
    self.dismissBtn = ISButton:new(0, 0, dismissW, ROW_H, getText("IGUI_PhunMart_Btn_Dismiss"), self, function()
        PendingRestock.clear()
    end)
    self.dismissBtn:initialise()
    if self.dismissBtn.enableCancelColor then
        self.dismissBtn:enableCancelColor()
    end
    self:addChild(self.dismissBtn)
end

function Bar:prerender()
    -- Size to the wrapped summary so a long shop list doesn't overflow.
    local textW = self.width - PAD * 2
    self._lines = tools.wrapText(PendingRestock.summary(), textW, UIFont.Small)
    local needed = PAD + FONT_HGT_MEDIUM + 4 + (#self._lines * FONT_HGT_SMALL) + PAD + ROW_H + PAD
    if needed ~= self.height then
        self:setHeight(needed)
    end

    ISPanel.prerender(self)

    local y = PAD
    self:drawText(getText("IGUI_PhunMart_Msg_ChangesPending", tostring(PendingRestock.count())), PAD, y, 1, 0.85, 0.4,
        1, UIFont.Medium)
    y = y + FONT_HGT_MEDIUM + 4

    for _, line in ipairs(self._lines) do
        self:drawText(line, PAD, y, 0.85, 0.85, 0.85, 1, UIFont.Small)
        y = y + FONT_HGT_SMALL
    end
    y = y + PAD

    self.restockBtn:setX(PAD)
    self.restockBtn:setY(y)
    self.dismissBtn:setX(PAD + self.restockBtn.width + PAD)
    self.dismissBtn:setY(y)
end

function Bar:new()
    local w = math.floor(420 * FONT_SCALE)
    local h = math.floor(110 * FONT_SCALE)
    local core = getCore()
    local o = ISPanel:new((core:getScreenWidth() - w) / 2, math.floor(60 * FONT_SCALE), w, h)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {
        r = 0.08,
        g = 0.08,
        b = 0.08,
        a = 0.92
    }
    o.borderColor = {
        r = 0.9,
        g = 0.7,
        b = 0.25,
        a = 1
    }
    o.moveWithMouse = true
    return o
end

---------------------------------------------------------------------------
-- API
---------------------------------------------------------------------------

local function showBar()
    if not barInstance then
        barInstance = Bar:new()
        barInstance:initialise()
    end
    barInstance:addToUIManager()
    barInstance:setVisible(true)
    barInstance:bringToTop()
end

--- Record that a definition changed, and surface the shops it feeds.
-- A change that reaches no shop type (an unused price, say) shows nothing,
-- which is correct: nothing in the world is stale.
function PendingRestock.note(kind, key)
    if not key then
        return
    end
    local added = false
    for _, t in ipairs(Core.references.findShops(kind, key)) do
        if not pending[t] then
            pending[t] = true
            added = true
        end
    end
    if added then
        showBar()
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
            added = true
        end
    end
    if added then
        showBar()
    end
end

function PendingRestock.clear()
    pending = {}
    if barInstance then
        barInstance:setVisible(false)
        barInstance:removeFromUIManager()
    end
end

function PendingRestock.restockNow()
    local list = pendingList()
    if #list == 0 then
        PendingRestock.clear()
        return
    end
    sendClientCommand(Core.name, Core.commands.restockShopTypes, {
        types = list
    })
    PendingRestock.clear()
end

return PendingRestock
