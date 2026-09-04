if isServer() then
    return
end

require "ISUI/ISPanel"
require "ISUI/ISButton"
local Core = PhunMart
local tools = require "PhunMart_Client/ui/ui_utils"

-- ─────────────────────────────────────────────────────────────────────────────
-- PhunMart shop window
--
-- Layout (% of window, matched to machine-hard-wear.png proportions):
--
--   ┌─────────────────────────────────────────┐
--   │  [X]                                    │  ← close btn overlay
--   │  ┌──────────────────┐  ┌─────────────┐  │
--   │  │                  │  │  PREVIEW     │  │  yellow
--   │  │   ITEM GRID      │  ├─────────────┤  │
--   │  │   (5 col icon)   │  │  DETAILS     │  │  purple
--   │  │                  │  │  price/desc  │  │
--   │  │                  │  └─────────────┘  │
--   │  ├──────────────────┤  ┌─────────────┐  │
--   │  │  FEEDBACK        │  │    BUY       │  │  orange / green
--   │  └──────────────────┘  └─────────────┘  │
--   └─────────────────────────────────────────┘
-- ─────────────────────────────────────────────────────────────────────────────

local profileName = "PhunMartUIShop"
Core.ui.client.shop = ISPanel:derive(profileName)
local UI = Core.ui.client.shop
local instances = {}

require "PhunMart/conditions"
require "PhunMart/player_adapter"
local Traits = require "PhunMart/traits"

local FS = tools.FONT_SCALE
local FONT_SM = tools.FONT_HGT_SMALL
local FONT_MD = tools.FONT_HGT_MEDIUM

-- Base window size before font scaling (portrait, matches machine image ratio ~0.73)
local BASE_W = 480
local BASE_H = 660

-- Auto-close when the player leaves the machine or takes a hit (tiles²).
-- Player stands on the front square (~1 tile); ~3 tiles covers a step away without
-- closing on tiny movement, matching typical loot-window range.
local CLOSE_DIST_SQ = 3 * 3

-- ─────────────────────────────────────────────────────────────────────────────
-- Layout: all positions in BASE pixel coordinates (window = 480 × 660).
-- Measured against machine-hard-wear.png stretched to fill that canvas.
-- Every value is multiplied by FS at runtime → px().
-- Tune these numbers to realign zones with any background image.
-- ─────────────────────────────────────────────────────────────────────────────
local L = {
    bannerH = 135, -- bottom of the top Hard-Wear banner

    -- Left column: items grid (glass door area)
    glassX = 40,
    glassW = 270,
    glassH = 410, -- from bannerH down to top of tray, minus a small gap

    -- Right column: control panel
    panelX = 335,
    panelW = 140,

    -- Right column rows
    screenY = 130,
    screenH = 140, -- display screen  (preview)
    keypadY = 278,
    keypadH = 210, -- keypad area     (details)
    -- 488 → 580: lower machine section, balance pane lives here

    -- Balance zone: between keypad bottom (488) and tray (580)
    balanceY = 493,
    balanceH = 80,

    -- Bottom strip: dispenser tray (feedback left, buy right)
    trayY = 580,
    trayH = 71,

    -- Close button sits inside the banner, top-right corner
    closeX = 448,
    closeY = 5,
    closeSize = 24,

    -- Admin button: top-left corner of banner (mirrors close button top-right)
    adminBtnX = 5,
    adminBtnY = 5,
    adminBtnSize = 24,

    -- Mode strip: sits along the bottom of the banner, directly above the glass
    -- and clear of the branding higher up. Drawn only when a machine offers
    -- more than one mode, so every shop that only sells looks as it always has.
    --
    -- Anchored by its BOTTOM edge, five above the glass at bannerH: the gap to
    -- the door is what the eye reads, and a taller strip should grow up into
    -- the banner rather than push down into the machine. Change the height and
    -- move the Y by the same amount in the opposite direction.
    --
    -- There is only about 28px between the header border the machine art draws
    -- and the top of the glass, so the strip has to live inside that. Height is
    -- what pays for clearing the border, since the gap below is the part worth
    -- keeping.
    modeStripY = 110,
    modeStripH = 20,

    -- A strip a mode may own, between the glass and the grid inside it. Only
    -- reserved when the active mode asks for one, so a machine that just sells
    -- keeps the full height of its door for stock.
    filterStripH = 26,
    filterStripGap = 4,

    -- Inset left and right by the margin the preview box leaves against the
    -- right edge of the window: panelX + panelW is 475 on a 480 canvas, so 5.
    -- Not written down here as a number, because both edges are floored
    -- independently at the current font scale and the gap that actually shows
    -- is not always that 5 scaled. buildModeStrip derives it from the same
    -- arithmetic instead, so the strip stays flush with the panel below it.
    --
    -- Starting at glassX aligned the strip with the item grid but hung it
    -- off-centre against a banner spanning the whole machine, so it read as a
    -- floating control rather than part of the cabinet.
}

-- ─────────────────────────────────────────────────────────────────────────────
-- text helpers
-- ─────────────────────────────────────────────────────────────────────────────

local wrapText = tools.wrapText
local truncate = tools.truncate

-- Human-readable label for a condition key, using the compiled def when available.
-- Maps a failure object from R.evaluate (has textKey + args) to a player-readable string.
local function failureLabel(failure)
    local tk = failure.textKey or ""
    local a = failure.args or {}

    if tk == "IGUI_PhunMart_Cond_HasItem" then
        local short = tostring(a[1] or "?"):match("%.(.+)$") or tostring(a[1] or "?")
        return getText(tk, short, tostring(a[2] or 1))
    elseif tk == "IGUI_PhunMart_Cond_PurchaseMax" then
        if (a[3] or 0) == 1 then
            return getText("IGUI_PhunMart_Cond_PurchaseMaxOnce")
        end
        return getText(tk, tostring(a[2] or "?"), tostring(a[3] or "?"))
    elseif tk == "IGUI_PhunMart_Cond_PurchaseCooldown" then
        return getText(tk, tostring(math.ceil(a[2] or 0)))
    elseif tk == "IGUI_PhunMart_Cond_AlreadyHasTrait" or tk == "IGUI_PhunMart_Cond_DoesNotHaveTrait" then
        return getText(tk, Traits.getLabel(tostring(a[1] or "?")))
    elseif tk == "IGUI_PhunMart_Cond_TraitMutex" then
        return getText(tk, Traits.getLabel(tostring(a[2] or "?")))
    elseif tk == "IGUI_PhunMart_Cond_TraitKeyMissing" or tk == "IGUI_PhunMart_Cond_TraitDisabledMP" then
        return getText(tk)
    elseif tk == "IGUI_PhunMart_Cond_BoundTokensBelowMax" then
        return getText(tk, tostring(a[2] or "?"), tostring(a[1] or "?"))
    elseif tk ~= "" then
        return getText(tk, tostring(a[1] or ""), tostring(a[2] or ""), tostring(a[3] or ""))
    end
    return getText("IGUI_PhunMart_Cond_Failed", failure.condKey or "?")
end

-- ─────────────────────────────────────────────────────────────────────────────
-- open / lifecycle
-- ─────────────────────────────────────────────────────────────────────────────

function UI.open(player, data)
    local idx = player:getPlayerNum()
    local instance = instances[idx]

    if instance and instance.player ~= player then
        instance:removeFromUIManager()
        instance = nil
    end

    if not instance then
        local w = math.floor(BASE_W * FS)
        local h = math.floor(BASE_H * FS)
        local core = getCore()
        local x = math.floor((core:getScreenWidth() - w) / 2)
        local y = math.floor((core:getScreenHeight() - h) / 2)

        instance = UI:new(x, y, w, h, player, idx)
        instance:initialise()
        instance:addToUIManager()
        instances[idx] = instance
    end

    instance:setVisible(true)
    instance:bringToTop()
    instance:setData(data)

    if not instance._shopChangeBound then
        instance._shopChangeFn = function(key, d, replaced)
            instance:onShopChange(key, d, replaced)
        end
        Events[Core.events.OnShopChange].Add(instance._shopChangeFn)
        instance._shopChangeBound = true
    end

    if not instance._purchaseBound then
        instance._purchaseFn = function(result)
            instance:onPurchaseComplete(result)
        end
        Events[Core.events.OnPurchaseComplete].Add(instance._purchaseFn)
        instance._purchaseBound = true
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- constructor
-- ─────────────────────────────────────────────────────────────────────────────

function UI:new(x, y, w, h, player, playerIndex)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self

    o.player = player
    o.playerIndex = playerIndex
    o.moveWithMouse = true
    o.noBackground = true

    o.bgTexture = nil
    o.selectedId = nil
    o.selectedOffer = nil
    o.selectedEntry = nil
    o.feedbackText = nil
    o.feedbackColor = {
        r = 1,
        g = 1,
        b = 1,
        a = 1
    }
    o.feedbackTimer = 0

    o:setWantKeyEvents(true)
    return o
end

-- ─────────────────────────────────────────────────────────────────────────────
-- createChildren
-- ─────────────────────────────────────────────────────────────────────────────

function UI:createChildren()
    ISPanel.createChildren(self)

    -- Scale a base-pixel value to the actual (font-scaled) window size.
    local function px(n)
        return math.floor(n * FS)
    end

    local gridX = px(L.glassX)
    local gridY = px(L.bannerH)
    local gridW = px(L.glassW)
    local gridH = px(L.glassH)

    local rightX = px(L.panelX)
    local rightW = px(L.panelW)

    local previewY = px(L.screenY)
    local previewH = px(L.screenH)
    local detailY = px(L.keypadY)
    local detailH = px(L.keypadH)

    local trayY = px(L.trayY)
    local trayH = px(L.trayH)

    -- ── item grid ────────────────────────────────────────────────────────────
    self.controls = {}
    self.controls.grid = Core.ui.client.shopItemsList:new(gridX, gridY, gridW, gridH, {
        player = self.player,
        onSelect = function(id, offer)
            self:onOfferSelected(id, offer)
        end,
        onRightClick = function(id, offer, screenX, screenY)
            self:onItemRightClick(id, offer, screenX, screenY)
        end,
        onActivate = function(id, offer, entry)
            self:onOfferActivated(id, offer, entry)
        end
    })
    self.controls.grid:initialise()
    self:addChild(self.controls.grid)

    -- Mode strip buttons are built per shop in setData, since which modes apply
    -- depends on the machine and one window serves them all. The filter strip
    -- goes the same way, per mode rather than per machine.
    self.controls.modeBtns = {}
    self.controls.filterWidgets = {}

    -- ── action button (green zone, bottom-right) ─────────────────────────────
    -- Says BUY on every machine that only sells, which is all of them until a
    -- mod registers a second mode. The active mode owns its title and handler.
    self.controls.buyBtn = ISButton:new(rightX, trayY, rightW, trayH, getText("IGUI_PhunMart_Buy"), self, UI.onAction)
    self.controls.buyBtn:initialise()
    self.controls.buyBtn:instantiate()
    self.controls.buyBtn:setEnable(false)
    self.controls.buyBtn.font = UIFont.Medium
    self.controls.buyBtn.backgroundColor = {
        r = 0.04,
        g = 0.22,
        b = 0.04,
        a = 0.90
    }
    self.controls.buyBtn.backgroundColorMouseOver = {
        r = 0.08,
        g = 0.42,
        b = 0.08,
        a = 0.95
    }
    self.controls.buyBtn.borderColor = {
        r = 0.15,
        g = 0.70,
        b = 0.15,
        a = 1.00
    }
    self:addChild(self.controls.buyBtn)

    -- ── close button ─────────────────────────────────────────────────────────
    local closeSize = px(L.closeSize)
    self.controls.closeBtn = ISButton:new(px(L.closeX), px(L.closeY), closeSize, closeSize, "X", self, UI.close)
    self.controls.closeBtn:initialise()
    self.controls.closeBtn:instantiate()
    self.controls.closeBtn.backgroundColor = {
        r = 0.28,
        g = 0.04,
        b = 0.04,
        a = 0.85
    }
    self.controls.closeBtn.backgroundColorMouseOver = {
        r = 0.60,
        g = 0.08,
        b = 0.08,
        a = 0.95
    }
    self.controls.closeBtn.borderColor = {
        r = 0.50,
        g = 0.15,
        b = 0.15,
        a = 1.00
    }
    self:addChild(self.controls.closeBtn)

    -- ── admin button (always created; visibility toggled each frame in prerender) ─
    local adminSize = px(L.adminBtnSize)
    self.controls.adminBtn = ISButton:new(px(L.adminBtnX), px(L.adminBtnY), adminSize, adminSize, "", self,
        UI.onAdminMenu)
    self.controls.adminBtn:initialise()
    self.controls.adminBtn:instantiate()
    self.controls.adminBtn.font = UIFont.Small
    self.controls.adminBtn.backgroundColor = {
        r = 0.10,
        g = 0.10,
        b = 0.12,
        a = 0.70
    }
    self.controls.adminBtn.backgroundColorMouseOver = {
        r = 0.20,
        g = 0.20,
        b = 0.25,
        a = 0.90
    }
    self.controls.adminBtn.borderColor = {
        r = 0.35,
        g = 0.35,
        b = 0.40,
        a = 0.80
    }
    self.controls.adminBtn:setVisible(false) -- prerender updates this each frame
    self:addChild(self.controls.adminBtn)

    -- ── 3D vehicle preview (fills the preview zone; hidden until a vehicle offer is selected) ──
    local p3d = ISUI3DScene:new(rightX, previewY, rightW, previewH)
    p3d:initialise()
    p3d.rotX = 22
    p3d.rotY = 45
    p3d.initialized = false
    p3d.vehicleName = nil
    p3d:setVisible(false)

    -- Left drag: rotate
    p3d.onMouseDown = function(p, mx, my)
        p._dragX = mx;
        p._dragY = my
        p._rotX0 = p.rotX;
        p._rotY0 = p.rotY
    end
    p3d.onMouseUp = function(p, mx, my)
        p._dragX = nil
    end
    p3d.onMouseMove = function(p, dx, dy)
        if not p._dragX then
            return
        end
        local mx, my = p:getMouseX(), p:getMouseY()
        p.rotY = p._rotY0 + (mx - p._dragX) * 0.5
        p.rotX = p._rotX0 - (my - p._dragY) * 0.5
        p.javaObject:fromLua3("setViewRotation", p.rotX, p.rotY, 0)
    end
    -- Release drag state when cursor leaves the panel
    p3d.onMouseMoveOutside = function(p, dx, dy)
        p._dragX = nil
    end

    self.controls.preview3d = p3d
    self:addChild(p3d)

    -- ── zone rects stored for prerender + render ──────────────────────────────
    self.zones = {
        preview = {
            x = rightX,
            y = previewY,
            w = rightW,
            h = previewH
        },
        details = {
            x = rightX,
            y = detailY,
            w = rightW,
            h = detailH
        },
        balance = {
            x = rightX,
            y = px(L.balanceY),
            w = rightW,
            h = px(L.balanceH)
        },
        feedback = {
            x = px(L.glassX),
            y = trayY,
            w = px(L.glassW),
            h = trayH
        }
    }

    self.bgTexture = getTexture("media/textures/machine-none.png")
end

-- ─────────────────────────────────────────────────────────────────────────────
-- data
-- ─────────────────────────────────────────────────────────────────────────────

-- ─────────────────────────────────────────────────────────────────────────────
-- modes
--
-- One window serves every machine, and which modes a machine offers is a
-- property of the machine, so the strip is rebuilt each time the window is
-- handed new data rather than once when it is built.
-- ─────────────────────────────────────────────────────────────────────────────

--- Buying, which is what a vending machine did before any of this existed.
---
--- Registered rather than special-cased so there is exactly one path through
--- the window: if Buy went around the registry, every hook below would need a
--- "unless we are buying" branch and the first mode a mod wrote would be the
--- first to find the parts that were never really general.
Core.registerShopMode({
    key = "buy",
    label = "IGUI_PhunMart_Buy",
    order = 10,
    --- Every machine that stocks anything, which is every machine PhunMart
    --- ships. A shop whose shelves are filled from somewhere else entirely has
    --- no offers of its own, so this mode would draw an empty grid and sit
    --- there being the only thing on the strip. Whatever fills that machine is
    --- expected to register a mode that knows how to show it.
    applies = function(data)
        return not (data and data.stocksNothing)
    end,
    getGridData = function(ui)
        return ui.data
    end,
    actionLabel = function(ui, offer)
        -- price.selfPay is set by bakePrice() for kind="self" offers: the price
        -- IS the displayed item, so the player is selling to the shop rather
        -- than buying from it, as Collectors and PrawnStars do.
        local isSell = offer and offer.price and offer.price.selfPay == true
        return getText(isSell and "IGUI_PhunMart_Sell" or "IGUI_PhunMart_Buy")
    end,
    canAction = function(ui, offer, id)
        return id ~= nil and ui:canPurchase(offer, id)
    end,
    onAction = function(ui)
        ui:onBuy()
    end
})

--- Rebuild the strip for the machine now on screen.
---
--- Buttons are destroyed and remade rather than hidden, because the set is
--- different per machine and a stale button that is merely invisible is still
--- in the child list and still takes clicks.
function UI:buildModeStrip()
    for _, btn in ipairs(self.controls.modeBtns or {}) do
        self:removeChild(btn)
    end
    self.controls.modeBtns = {}

    self.modes = Core.shopModesFor(self.data)

    -- One mode needs no chooser. Every shipped machine lands here, and the
    -- window looks exactly as it did before modes existed.
    if #self.modes < 2 then
        return
    end

    local function px(n)
        return math.floor(n * FS)
    end
    -- Mirror the preview box's margin on both sides. Read off the panel's own
    -- right edge rather than scaling a constant, so the strip lines up with
    -- what is actually drawn below it however the two floors land, and stays
    -- lined up if the panel ever moves.
    --
    -- Measured against self.width rather than the base canvas for the same
    -- reason: the last segment then finishes exactly on the intended edge.
    local inset = self.width - (px(L.panelX) + px(L.panelW))
    if inset < 0 then
        inset = 0
    end
    local x0 = inset
    local x1 = self.width - inset
    local h = px(L.modeStripH)
    local y = px(L.modeStripY)
    local span = x1 - x0
    local count = #self.modes

    for i, mode in ipairs(self.modes) do
        -- Edges divided proportionally rather than each segment taking a fixed
        -- width: the remainder of an uneven division is spread across the strip
        -- instead of being left as a gap at the right end, so the last segment
        -- finishes exactly on the panel edge at every font scale.
        --
        -- Segments butt together with no gap, which is what makes the strip
        -- read as one control on the machine rather than three buttons that
        -- happen to be in a row.
        local bx = x0 + math.floor(span * (i - 1) / count)
        local bw = x0 + math.floor(span * i / count) - bx

        -- Upper-cased here rather than left to each label, because the strip
        -- sits beside a BUY button that is already shouting and a mode reading
        -- "Sell" next to one reading "BUY" looks like a mistake. Non-ASCII is
        -- untouched by string.upper, so a translated label is no worse off.
        -- Falls back to the key rather than calling getText(nil), which throws,
        -- so a mode registered without a label is merely ugly and not fatal.
        local title = (mode.label and getText(mode.label)) or mode.key
        title = tostring(title):upper()

        local btn = ISButton:new(bx, y, bw, h, title, self, UI.onModeButton)
        btn.internal = mode.key
        btn:initialise()
        btn:instantiate()
        btn.font = UIFont.Small
        self:addChild(btn)
        table.insert(self.controls.modeBtns, btn)
    end
end

function UI:onModeButton(btn)
    self:setMode(btn.internal)
end

--- Give the active mode its strip above the grid, or take it away again.
---
--- A mode showing hundreds of rows needs somewhere to put the controls that
--- narrow them down, and there is nowhere in this window to put anything: it is
--- drawn against a photograph and every region is spoken for. So a mode may
--- claim a strip along the top of the glass, and the grid gives up the height.
---
--- The mode builds its own widgets and this only places and owns them, because
--- what belongs in that strip is entirely the mode's business -- a dropdown and
--- a search box for one, possibly nothing at all for the next.
---
--- Rebuilt on every mode change rather than hidden, for the same reason the
--- mode buttons are: a stale widget that is merely invisible is still in the
--- child list and still takes clicks.
function UI:buildModeFilter()
    for _, widget in ipairs(self.controls.filterWidgets or {}) do
        self:removeChild(widget)
    end
    self.controls.filterWidgets = {}

    local function px(n)
        return math.floor(n * FS)
    end
    local gridX, gridW = px(L.glassX), px(L.glassW)
    local top = px(L.bannerH)
    local stripH = px(L.filterStripH)

    local mode = self:currentMode()
    local widgets = mode and mode.createFilter and
                        mode.createFilter(self, gridX, top, gridW, stripH - px(L.filterStripGap))

    if widgets and #widgets > 0 then
        for _, widget in ipairs(widgets) do
            self:addChild(widget)
            table.insert(self.controls.filterWidgets, widget)
        end
        self.controls.grid:setY(top + stripH)
        self.controls.grid:setHeight(px(L.glassH) - stripH)
    else
        self.controls.grid:setY(top)
        self.controls.grid:setHeight(px(L.glassH))
    end
end

--- Tint the strip so the active mode reads as pressed rather than merely last
--- clicked.
---
--- Greens are the buy button's family, so the strip belongs to the same
--- machine. The inactive segments are deliberately quiet in all three of
--- background, border and text: with the segments butted together, a bright
--- border on every one of them turns the strip into a grid of boxes and the
--- active segment stops standing out at a glance, which is the only job it has.
function UI:paintModeStrip()
    for _, btn in ipairs(self.controls.modeBtns or {}) do
        local on = (btn.internal == self.modeKey)
        if on then
            btn.backgroundColor = {
                r = 0.09,
                g = 0.28,
                b = 0.10,
                a = 0.95
            }
            btn.backgroundColorMouseOver = {
                r = 0.13,
                g = 0.38,
                b = 0.14,
                a = 0.97
            }
            btn.borderColor = {
                r = 0.22,
                g = 0.72,
                b = 0.24,
                a = 1.00
            }
            btn.textColor = {
                r = 1.00,
                g = 1.00,
                b = 1.00,
                a = 1.00
            }
        else
            btn.backgroundColor = {
                r = 0.05,
                g = 0.05,
                b = 0.06,
                a = 0.88
            }
            btn.backgroundColorMouseOver = {
                r = 0.10,
                g = 0.17,
                b = 0.11,
                a = 0.92
            }
            btn.borderColor = {
                r = 0.20,
                g = 0.21,
                b = 0.24,
                a = 1.00
            }
            btn.textColor = {
                r = 0.62,
                g = 0.65,
                b = 0.63,
                a = 1.00
            }
        end
    end
end

--- The mode to land on for the data just loaded: the one already showing if
--- this machine still offers it, otherwise the first.
---
--- Worth the lookup because setData runs again on every restock and reroll
--- broadcast, not only when the window opens. Without it, a machine restocking
--- while the player was part-way through something on another mode would throw
--- them back to Buy with no explanation.
function UI:preferredModeKey()
    for _, mode in ipairs(self.modes or {}) do
        if mode.key == self.modeKey then
            return self.modeKey
        end
    end
    return self.modes and self.modes[1] and self.modes[1].key
end

function UI:currentMode()
    if self.modes then
        for _, mode in ipairs(self.modes) do
            if mode.key == self.modeKey then
                return mode
            end
        end
    end
    return self.modes and self.modes[1]
end

--- Switch modes, clearing the selection on the way.
---
--- The selection is an offer id belonging to whatever the previous mode was
--- showing, so carrying it across would leave the details pane describing a row
--- the grid no longer holds and the action button live on it.
function UI:setMode(key, force)
    if not force and key == self.modeKey then
        return
    end
    local previous = self:currentMode()
    if previous and previous.key ~= key and previous.onExit then
        previous.onExit(self)
    end

    self.modeKey = key
    self.selectedId = nil
    self.selectedOffer = nil
    self.selectedEntry = nil

    local mode = self:currentMode()
    if mode and mode.onEnter then
        mode.onEnter(self)
    end

    self:paintModeStrip()
    -- Before the grid is filled, because this is what decides how tall it is.
    self:buildModeFilter()
    self:refreshGrid()
    self.controls.buyBtn:setEnable(false)
    self:updateBuyButtonTitle(nil)
end

--- Hand the grid whatever the active mode wants shown. A mode that does not
--- care gets the payload, which is what buying has always used.
function UI:refreshGrid()
    local mode = self:currentMode()
    local data = self.data
    if mode and mode.getGridData then
        data = mode.getGridData(self)
    end
    self.controls.grid:setData(data or self.data)
end

function UI:setData(data)
    self.data = data or {}
    self.shopKey = data and data.key
    self.selectedId = nil
    self.selectedOffer = nil
    self.selectedEntry = nil
    self.feedbackText = nil

    local bg = data and data.background
    if bg then
        local tex = getTexture("media/textures/" .. bg)
        if tex then
            self.bgTexture = tex
        end
    end

    -- Reset 3D preview so it doesn't show a stale vehicle on reopen
    local p3d = self.controls.preview3d
    if p3d then
        p3d.vehicleName = nil
        -- NOTE: do NOT reset p3d.initialized here: the Java scene object persists
        -- across setData calls and "vehicle" already exists; calling createVehicle again crashes.
        p3d.rotX = 22;
        p3d.rotY = 45
        p3d._dragX = nil
        p3d:setVisible(false)
    end

    -- Rebuild the strip before choosing a mode: which modes exist depends on
    -- the machine this payload came from, and setMode reads that list.
    self:buildModeStrip()
    self:setMode(self:preferredModeKey(), true)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- selection / buy
-- ─────────────────────────────────────────────────────────────────────────────

function UI:canPurchase(offer, offerId)
    if not offer then
        return false
    end

    -- stock check: -1 = unlimited, 0 = out of stock
    local stockQty = offer.offer and offer.offer.stockQty
    if stockQty ~= nil and stockQty ~= -1 and stockQty <= 0 then
        return false
    end
    local condDefs = self.data and self.data.conditionsDefs
    local adapter = Core.getPlayerAdapter and Core.getPlayerAdapter(self.player)
    local R = Core.conditionsRuntime

    -- conditions
    if R and adapter and condDefs and offer.conditions then
        local result = R.evaluate(offer.conditions, condDefs, adapter, Core.purchases, {
            offerId = offerId
        })
        if not result.ok then
            return false
        end
    end

    -- price affordability
    local price = offer.price
    if price and price.kind == "currency" and Core.wallet then
        local balance = Core.wallet:getBalance(self.player, price.pool)
        local need = type(price.amount) == "table" and price.amount.min or (price.amount or 0)
        if balance < need then
            return false
        end
    elseif adapter and price and price.items then
        for _, pi in ipairs(price.items) do
            local need = type(pi.amount) == "table" and pi.amount.min or (pi.amount or 1)
            local count = adapter:countItem(pi.item) or 0
            if pi.substitutes then
                for _, sub in ipairs(pi.substitutes) do
                    count = count + (adapter:countItem(sub) or 0)
                end
            end
            if count < need then
                return false
            end
        end
    end

    return true
end

--- Title the action button, asking the active mode what it is about to do.
--- A mode that does not say gets BUY, which is what the button said when it was
--- the only thing the window could do.
function UI:updateBuyButtonTitle(offer)
    local mode = self:currentMode()
    local title = mode and mode.actionLabel and mode.actionLabel(self, offer)
    self.controls.buyBtn:setTitle(title or getText("IGUI_PhunMart_Buy"))
end

function UI:onOfferSelected(id, offer, entry)
    self.selectedId = id
    self.selectedOffer = offer
    self.selectedEntry = entry
    local mode = self:currentMode()
    if mode and mode.canAction then
        self.controls.buyBtn:setEnable(mode.canAction(self, offer, id) == true)
    else
        self.controls.buyBtn:setEnable(id ~= nil and self:canPurchase(offer, id))
    end
    -- Collector/pawn offers hand the displayed item over for currency, so that's a sale,
    -- so label the button SELL instead of BUY.
    self:updateBuyButtonTitle(offer)

    -- Show 3D vehicle preview only for spawnVehicle reward actions.
    local p3d = self.controls.preview3d
    if p3d then
        local vehicleScript = nil
        if offer and offer.reward and offer.reward.actions then
            for _, action in ipairs(offer.reward.actions) do
                if action.type == "spawnVehicle" then
                    -- Use the offer's item key as the preview script: this IS the
                    -- vehicle script name (e.g. "ModernCarLightsCityLouisvillePD"),
                    -- which matches exactly what the player sees in the list.
                    vehicleScript = offer.item
                    break
                end
            end
        end
        if vehicleScript then
            if not p3d.initialized then
                p3d.initialized = true
                p3d.javaObject:fromLua1("setDrawGrid", false)
                p3d.javaObject:fromLua1("createVehicle", "vehicle")
            end
            p3d.rotX = 22;
            p3d.rotY = 45
            p3d._dragX = nil
            p3d.javaObject:fromLua3("setViewRotation", p3d.rotX, p3d.rotY, 0)
            p3d.javaObject:fromLua1("setView", "UserDefined")
            p3d.javaObject:fromLua1("setZoom", 3)
            p3d.vehicleName = vehicleScript
            p3d.javaObject:fromLua2("setVehicleScript", "vehicle", vehicleScript)
            p3d:setVisible(true)
        else
            p3d.vehicleName = nil
            p3d:setVisible(false)
        end
    end
end

--- A tile was double-clicked.
---
--- Offered to the active mode and nothing more. There is deliberately no
--- default: making a double-click buy would turn a slip of the hand into a
--- purchase, and every machine PhunMart ships is a machine where that would be
--- somebody's money. A mode that has somewhere to go says so.
function UI:onOfferActivated(id, offer, entry)
    local mode = self:currentMode()
    if mode and mode.onActivate then
        mode.onActivate(self, id, offer, entry)
    end
end

--- The action button was pressed. Hand it to the active mode, which for every
--- shipped machine is Buy.
function UI:onAction()
    local mode = self:currentMode()
    if mode and mode.onAction then
        mode.onAction(self)
    else
        self:onBuy()
    end
end

function UI:onBuy()
    if not self.selectedId then
        return
    end
    local loc = self.data and self.data.location
    if not loc then
        self:showFeedback(getText("IGUI_PhunMart_Msg_NoLocationData"), 0.9, 0.3, 0.3)
        return
    end
    -- Disable button immediately to prevent double-click
    self.controls.buyBtn:setEnable(false)
    self:showFeedback(getText("IGUI_PhunMart_Msg_Purchasing"), 0.9, 0.9, 0.3)
    sendClientCommand(Core.name, Core.commands.buy, {
        offerId = self.selectedId,
        location = loc,
        qty = 1
    })
end

function UI:onPurchaseComplete(result)
    if result.failed then
        local msgs = {
            OutOfStock = getText("IGUI_PhunMart_Msg_OutOfStock"),
            InsufficientFunds = getText("IGUI_PhunMart_Msg_NotEnoughFunds"),
            ConditionsFailed = getText("IGUI_PhunMart_Msg_RequirementsNotMet"),
            ShopNotFound = getText("IGUI_PhunMart_Msg_ShopNotFound"),
            OfferNotFound = getText("IGUI_PhunMart_Msg_OfferNotFound")
        }
        local msg = msgs[result.message] or getText("IGUI_PhunMart_Msg_PurchaseFailed", tostring(result.message))
        self:showFeedback(msg, 0.9, 0.3, 0.3)
        -- Re-enable buy button so the player can try again or choose another
        if self.selectedId then
            self.controls.buyBtn:setEnable(self:canPurchase(self.selectedOffer, self.selectedId))
        end
        return
    end

    -- Update stock count in the local offer data (grid re-reads this on next render)
    if result.offerId and self.data and self.data.offers then
        local offer = self.data.offers[result.offerId]
        if offer and offer.offer then
            offer.offer.stockQty = result.stockQty
        end
    end

    -- Item-based prices are removed authoritatively by the buy command handler,
    -- which also runs in SP (OnClientCommand fires locally there). Do NOT remove
    -- them again here: that charged the player twice the displayed amount.
    if result.price and result.price.kind == "items" then
        ISInventoryPage.dirtyUI()
    end

    -- Re-evaluate buy button for the still-selected offer
    if self.selectedId == result.offerId then
        -- Record the purchase locally so purchaseCountMax evaluates correctly
        -- on repeated buys without waiting for the next playerSetup sync.
        -- In SP the buy command handler already added it to the same table.
        if not Core.isLocal then
            Core.purchases:add(self.player, result.offerId, 1)
        end
        self.controls.buyBtn:setEnable(self:canPurchase(self.selectedOffer, self.selectedId))
    end

    self:showFeedback(getText("IGUI_PhunMart_Msg_Purchased"), 0.35, 0.90, 0.35)
end

function UI:showFeedback(msg, r, g, b)
    self.feedbackText = msg
    self.feedbackColor = {
        r = r or 1,
        g = g or 1,
        b = b or 1,
        a = 1
    }
    self.feedbackTimer = 180
end

-- ─────────────────────────────────────────────────────────────────────────────
-- shop change event
-- ─────────────────────────────────────────────────────────────────────────────

function UI:onShopChange(key, data, replaced)
    if key ~= self.shopKey then
        return
    end
    self:setData(data)
    if replaced then
        self:showFeedback(getText("IGUI_PhunMart_Msg_Rerolled"), 0.3, 0.5, 0.9)
    else
        self:showFeedback(getText("IGUI_PhunMart_Msg_Restocked"), 0.4, 0.9, 0.4)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- admin actions
-- ─────────────────────────────────────────────────────────────────────────────

-- Restock and reroll used to look up the client-side Lua object at this shop's
-- coordinates, then hand it to ClientSystem, which read x, y and z back off it
-- and sent them to the server. A whole round trip to recover the coordinates
-- the panel was already holding, and it failed whenever the client's global
-- object registry had no entry at that spot, reporting "no location data" about
-- a location it knew perfectly well.
--
-- They send the command straight from self.data.location now, which is what
-- onBuy and onChangeTo have always done.

function UI:onAdminRestock()
    local loc = self.data and self.data.location
    if not loc then
        self:showFeedback(getText("IGUI_PhunMart_Msg_NoLocationData"), 0.9, 0.3, 0.3)
        return
    end
    -- Flat x/y/z: what the restock handler reads.
    sendClientCommand(Core.name, Core.commands.restock, {
        x = loc.x,
        y = loc.y,
        z = loc.z
    })
    self:showFeedback(getText("IGUI_PhunMart_Msg_Restocking"), 0.9, 0.6, 0.2)
end

function UI:onAdminReroll()
    local loc = self.data and self.data.location
    if not loc then
        self:showFeedback(getText("IGUI_PhunMart_Msg_NoLocationData"), 0.9, 0.3, 0.3)
        return
    end
    -- Nested under `location`: what the reroll handler reads. The two commands
    -- disagree on shape, which is why this is not one helper.
    sendClientCommand(Core.name, Core.commands.reroll, {
        location = loc
    })
    self:showFeedback(getText("IGUI_PhunMart_Msg_Rerolling"), 0.3, 0.5, 0.9)
end

function UI:onAdminMenu(btn)
    local screenX = self:getAbsoluteX() + btn:getX()
    local screenY = self:getAbsoluteY() + btn:getY() + btn.height

    local context = ISContextMenu.get(self.playerIndex, screenX, screenY)
    context:clear()

    -- ── Change To (replaces Reroll) ───────────────────────────────────────
    local changeMenu = context:getNew(context)
    changeMenu:addOption(getText("IGUI_PhunMart_Admin_Random"), self, UI.onAdminReroll)
    -- Fall back to Core.runtime.shops in SP (same Lua state; Core.defs.shops
    -- may not be populated yet if sendServerCommand is still queued).
    local shopDefs = (Core.defs and Core.defs.shops) or (Core.runtime and Core.runtime.shops)
    if shopDefs then
        local types = {}
        for k in pairs(shopDefs) do
            if k ~= self.data.shopType then
                table.insert(types, k)
            end
        end
        table.sort(types)
        for _, shopType in ipairs(types) do
            changeMenu:addOption(shopType, self, UI.onChangeTo, shopType)
        end
    end
    local changeOpt = context:addOption(getText("IGUI_PhunMart_Admin_ChangeTo"))
    context:addSubMenu(changeOpt, changeMenu)

    -- ── Restock ───────────────────────────────────────────────────────────
    context:addOption(getText("IGUI_PhunMart_Admin_Restock"), self, UI.onAdminRestock)

    -- ── Edit Shop ─────────────────────────────────────────────────────────
    -- The options that open a definition editor honour EditorRole, the same as
    -- the three ways into the editor from outside a shop. Restock, reroll and
    -- blacklist stay on plain admin: they are maintenance on this machine, not
    -- config authoring, and the server enforces isAdmin on them regardless.
    local canEdit = Core.canEditConfig(self.player)

    if canEdit then
        context:addOption(getText("IGUI_PhunMart_Admin_EditShop"), self, UI.onEditShop)
    end

    -- ── Pools (grouped by pool set; each pool → View / Edit submenu) ──────
    local poolSets = self.data and self.data.poolSets or {}
    if #poolSets > 0 and canEdit then
        local poolsMenu = context:getNew(context)
        for si, poolSet in ipairs(poolSets) do
            local setLabel = #poolSets > 1 and getText("IGUI_PhunMart_Admin_SetN", tostring(si)) or
                                 getText("IGUI_PhunMart_Admin_ActivePools")
            poolsMenu:addOption("-- " .. setLabel .. " --")
            for _, poolRef in ipairs(poolSet.keys or {}) do
                local key = type(poolRef) == "table" and poolRef.key or poolRef
                local poolSub = poolsMenu:getNew(poolsMenu)
                poolSub:addOption(getText("IGUI_PhunMart_Btn_View"), self, UI.onViewPool, key)
                poolSub:addOption(getText("IGUI_PhunMart_Btn_Edit"), self, UI.onEditPool, key)
                local poolOpt = poolsMenu:addOption("* " .. key)
                poolsMenu:addSubMenu(poolOpt, poolSub)
            end
            -- Inside the set rather than once at the bottom, so which set the
            -- new pool joins is answered by which Add was clicked and no dialog
            -- has to ask. Adding a pool from in here used to create it and leave
            -- it unattached, which reads as the machine ignoring the request.
            poolsMenu:addOption(getText("IGUI_PhunMart_Admin_AddPool"), self, UI.onNewPool, si)
        end
        local poolsOpt = context:addOption(getText("IGUI_PhunMart_Admin_Pools"))
        context:addSubMenu(poolsOpt, poolsMenu)
    end

    -- ── Blacklist (only when an offer is selected) ────────────────────────
    if self.selectedOffer then
        context:addOption(getText("IGUI_PhunMart_Admin_GlobalBlacklist"), self, UI.onBlacklistSelected)
    end
end

-- ── Item right-click (admin only) ─────────────────────────────────────────

function UI:onItemRightClick(id, offer, screenX, screenY)
    if not Core.utils.isAdmin(self.player) then
        return
    end
    local context = ISContextMenu.get(self.playerIndex, screenX, screenY)
    context:clear()
    context:addOption(getText("IGUI_PhunMart_Admin_BlacklistInPool"), self, UI.onBlacklistInPool, id, offer)
    context:addOption(getText("IGUI_PhunMart_Admin_GlobalBlacklist"), self, UI.onBlacklistOffer, id, offer)
    context:addOption(getText("IGUI_PhunMart_Admin_MoveToPool"), self, UI.onMoveOfferToPool, id, offer)
end

-- ── Action stubs (each will become a panel) ───────────────────────────────

function UI:onChangeTo(shopType)
    local loc = self.data and self.data.location
    if not loc then
        self:showFeedback(getText("IGUI_PhunMart_Msg_NoLocationData"), 0.9, 0.3, 0.3)
        return
    end
    sendClientCommand(Core.name, Core.commands.changeTo, {
        to = shopType,
        location = loc
    })
    self:showFeedback(getText("IGUI_PhunMart_Msg_ChangingTo", shopType), 0.5, 0.7, 0.9)
end

function UI:onEditShop()
    Core.ui.admin_shops.OnOpenPanel(self.player, self.data.shopType)
end

function UI:onViewPool(poolKey)
    sendClientCommand(Core.name, Core.commands.requestPool, {
        poolKey = poolKey
    })
end

function UI:onEditPool(poolKey)
    Core.ui.admin_pools.OnEditPool(self.player, poolKey)
end

--- Create a pool and put it in this machine's pool set.
---
--- The shop definition is read from Core.defs rather than from self.data:
--- the payload carries the compiled pool sets, where a price is already an
--- expanded table, and writing those back would freeze the resolved price into
--- the shop as if someone had typed it there.
function UI:onNewPool(setIndex)
    Core.ui.admin_pools.OnEditPool(self.player, nil, function(poolKey)
        local shopType = self.data and self.data.shopType
        local shopDef = shopType and Core.defs and Core.defs.shops and Core.defs.shops[shopType]
        if not shopDef then
            self:showFeedback(getText("IGUI_PhunMart_Msg_PoolNotAdded", poolKey), 0.9, 0.5, 0.2)
            return
        end

        local def = Core.utils.deepCopy(shopDef)
        def.poolSets = def.poolSets or {}
        local set = def.poolSets[setIndex or 1]
        if not set then
            set = {
                keys = {}
            }
            def.poolSets[setIndex or 1] = set
        end
        set.keys = set.keys or {}
        for _, ref in ipairs(set.keys) do
            local existing = type(ref) == "table" and ref.key or ref
            if existing == poolKey then
                return
            end
        end
        table.insert(set.keys, {
            key = poolKey,
            weight = 1.0
        })

        def.type = shopType
        sendClientCommand(Core.name, Core.commands.upsertShopDefinition, def)
        if Core.ui.pending_restock then
            Core.ui.pending_restock.note("shops", shopType)
        end
        if not Core.isLocal and Core.defs and Core.defs.shops then
            Core.defs.shops[shopType] = def
        end
        self:showFeedback(getText("IGUI_PhunMart_Msg_PoolAdded", poolKey), 0.4, 0.9, 0.4)
    end)
end

function UI:onBlacklistSelected()
    self:onBlacklistOffer(self.selectedId, self.selectedOffer)
end

-- Asks first, the same as the pool viewer's copy and for the same reason: this
-- is one click away from an ordinary right-click on an item, and it takes the
-- item out of every shop on the server.
function UI:onBlacklistOffer(id, offer)
    local itemKey = offer and offer.item
    if not itemKey then
        return
    end
    local name = tools.resolveOfferDisplayName(offer) or itemKey
    tools.confirm(getText("IGUI_PhunMart_Confirm_Blacklist", name), function()
        sendClientCommand(Core.name, Core.commands.quickBlacklist, {
            itemKey = itemKey
        })
        -- This machine can be restocked from the gear menu, but every other
        -- machine keeps the item until it rolls again, so track it like any
        -- other edit.
        if Core.ui.pending_restock then
            Core.ui.pending_restock.noteAllShops()
        end
        self:showFeedback(getText("IGUI_PhunMart_Msg_GlobalBlacklisted", tostring(itemKey)), 0.9, 0.5, 0.2)
    end, self)
end

function UI:onBlacklistInPool(id, offer)
    local itemKey = offer and offer.item
    if not itemKey then
        return
    end
    -- Extract pool key from offer ID (format: poolKey|itemType)
    local poolKey = id and id:match("^(.+)|")
    if not poolKey then
        self:showFeedback(getText("IGUI_PhunMart_Msg_PoolNotFound"), 0.9, 0.3, 0.3)
        return
    end
    sendClientCommand(Core.name, Core.commands.blacklistInPool, {
        poolKey = poolKey,
        itemKey = itemKey
    })
    if Core.ui.pending_restock then
        Core.ui.pending_restock.note("pools", poolKey)
    end
    self:showFeedback(getText("IGUI_PhunMart_Msg_BlacklistedInPool", poolKey, tostring(itemKey)), 0.9, 0.5, 0.2)
end

function UI:onMoveOfferToPool(id, offer)
    -- Extract pool key from offer ID (format: poolKey|itemType)
    local poolKey = id and id:match("^(.+)|")
    if not poolKey then
        self:showFeedback(getText("IGUI_PhunMart_Msg_PoolNotFound"), 0.9, 0.3, 0.3)
        return
    end
    local displayName = tools.resolveOfferDisplayName(offer)
    MoveToPoolModal.open(self.player, poolKey, {{
        id = id,
        displayName = displayName,
        offer = offer
    }}, nil)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- input
-- ─────────────────────────────────────────────────────────────────────────────

function UI:close()
    if self._shopChangeBound then
        Events[Core.events.OnShopChange].Remove(self._shopChangeFn)
        self._shopChangeBound = false
        self._shopChangeFn = nil
    end
    if self._purchaseBound then
        Events[Core.events.OnPurchaseComplete].Remove(self._purchaseFn)
        self._purchaseBound = false
        self._purchaseFn = nil
    end
    self:setVisible(false)
end

function UI:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function UI:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
    end
end

-- Close if the player walks away from the machine, dies, or gets hit.
function UI:update()
    ISPanel.update(self)
    if not self:isVisible() then
        return
    end

    local player = self.player
    if not player or player:isDead() then
        self:close()
        return
    end

    local hit = player:getHitReaction()
    if (hit and hit ~= "") or player:isKnockedDown() then
        self:close()
        return
    end

    local loc = self.data and self.data.location
    if not loc then
        return
    end
    if math.floor(player:getZ() + 0.5) ~= loc.z then
        self:close()
        return
    end
    if player:DistToSquared(loc.x + 0.5, loc.y + 0.5) > CLOSE_DIST_SQ then
        self:close()
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- rendering
-- ─────────────────────────────────────────────────────────────────────────────

function UI:prerender()
    ISPanel.prerender(self)

    -- 1. machine background image (fully opaque)
    if self.bgTexture then
        self:drawTextureScaled(self.bgTexture, 0, 0, self.width, self.height, 1)
    else
        self:drawRect(0, 0, self.width, self.height, 1, 0.08, 0.08, 0.10)
    end

    -- 2. dark wash to increase overall contrast
    self:drawRect(0, 0, self.width, self.height, 0.30, 0, 0, 0)

    -- 3. opaque panel backgrounds for the right-column zones
    --    drawn here so they sit behind both children and the render() overlays
    local pz = self.zones and self.zones.preview
    local dz = self.zones and self.zones.details
    local fz = self.zones and self.zones.feedback
    if pz then
        self:drawRect(pz.x, pz.y, pz.w, pz.h, 0.82, 0.04, 0.04, 0.06)
        self:drawRectBorder(pz.x, pz.y, pz.w, pz.h, 0.50, 0.30, 0.30, 0.35)
    end
    if dz then
        self:drawRect(dz.x, dz.y, dz.w, dz.h, 0.82, 0.04, 0.04, 0.06)
        self:drawRectBorder(dz.x, dz.y, dz.w, dz.h, 0.50, 0.30, 0.30, 0.35)
    end
    local bz = self.zones and self.zones.balance
    if bz then
        self:drawRect(bz.x, bz.y, bz.w, bz.h, 0.82, 0.04, 0.04, 0.06)
        self:drawRectBorder(bz.x, bz.y, bz.w, bz.h, 0.50, 0.30, 0.30, 0.35)
    end
    if fz then
        -- feedback tray: always visible as a recessed slot
        self:drawRect(fz.x, fz.y, fz.w, fz.h, 0.70, 0.03, 0.03, 0.04)
        self:drawRectBorder(fz.x, fz.y, fz.w, fz.h, 0.40, 0.25, 0.25, 0.28)
    end

    -- Toggle admin button each frame so mid-game admin promotion works
    if self.controls.adminBtn then
        self.controls.adminBtn:setVisible(Core.utils.isAdmin(self.player))
    end
end

function UI:render()
    ISPanel.render(self)

    local pz = self.zones.preview
    local dz = self.zones.details
    local bz = self.zones.balance
    local fz = self.zones.feedback

    -- ── preview zone ─────────────────────────────────────────────────────────
    if self.selectedOffer then
        local p3d = self.controls.preview3d
        if not (p3d and p3d:isVisible()) then
            -- 2D icon for normal items; 3D scene handles its own rendering for vehicles.
            -- Prefer pre-resolved texture/overlay from the items list entry.
            local tex = self.selectedEntry and self.selectedEntry.texture
            local overlay = self.selectedEntry and self.selectedEntry.overlay
            if not tex then
                local scriptItem = getScriptManager():getItem(self.selectedOffer.item)
                tex = scriptItem and scriptItem:getNormalTexture()
            end
            if not tex then
                local tk = Traits.getOfferTraitKey(self.selectedOffer)
                tex = Traits.getTexture(tk or self.selectedOffer.item)
            end
            if not tex and self.selectedOffer.reward and self.selectedOffer.reward.display and
                self.selectedOffer.reward.display.texture then
                tex = getTexture(self.selectedOffer.reward.display.texture)
            end
            if tex then
                local iconSize = math.floor(math.min(pz.w, pz.h) * 0.78)
                local ix = pz.x + (pz.w - iconSize) / 2
                local iy = pz.y + (pz.h - iconSize) / 2
                self:drawTextureScaledAspect(tex, ix, iy, iconSize, iconSize, 1, 1, 1, 1)
                if overlay then
                    self:drawTextureScaledAspect(overlay, ix, iy, iconSize, iconSize, 1, 1, 1, 1)
                end
            end
        end
        self:renderDetails(dz)
    else
        local hint = getText("IGUI_PhunMart_SelectAnItem")
        local tw = getTextManager():MeasureStringX(UIFont.Small, hint)
        self:drawText(hint, math.floor(pz.x + (pz.w - tw) / 2), math.floor(pz.y + (pz.h - FONT_SM) / 2), 0.38, 0.38,
            0.38, 1, UIFont.Small)
    end

    -- ── balance zone ──────────────────────────────────────────────────────────
    if bz and Core.wallet then
        -- Build icon cache once: highest-value coin texture per pool
        if not self._poolIcons then
            self._poolIcons = {}
            for item, def in pairs(Core.wallet.currencies) do
                local cur = self._poolIcons[def.pool]
                if not cur or def.value > cur.value then
                    local si = getScriptManager():getItem(item)
                    self._poolIcons[def.pool] = {
                        value = def.value,
                        tex = si and si:getNormalTexture()
                    }
                end
            end
        end

        local function fmtBalance(pool, amount)
            local fmt = Core.wallet.pools[pool] and Core.wallet.pools[pool].format
            if fmt == "cents" then
                return tools.formatCents(amount)
            end
            return Core.utils.formatWholeNumber(amount)
        end

        local pad = 6
        local iconSz = FONT_SM
        local rowH = iconSz + 4
        local s = Core.settings
        local poolOrder = {"change", "tokens"}
        local rows = {}
        for _, pool in ipairs(poolOrder) do
            -- skip disabled pools
            if (pool == "change" and s.EnableChangePool == false)
            or (pool == "tokens" and s.EnableTokenPool == false) then
                -- skip
            else
                local def = Core.wallet.pools[pool]
                if def then
                    table.insert(rows, {
                        label = def.label,
                        amount = fmtBalance(pool, Core.wallet:getBalance(self.player, pool)),
                        tex = self._poolIcons[pool] and self._poolIcons[pool].tex
                    })
                end
            end
        end

        if #rows > 0 then
            -- "Balance" header + divider
            self:drawText(getText("IGUI_PhunMart_Balance"), bz.x + pad, bz.y + pad, 0.52, 0.52, 0.58, 0.90, UIFont.Small)
            local divY = bz.y + pad + FONT_SM + 2
            self:drawRect(bz.x + pad, divY, bz.w - pad * 2, 1, 0.35, 0.30, 0.30, 0.40)

            -- Rows: [icon] label ... amount
            local headerH = pad + FONT_SM + 2 + 1 + 2 -- pad + text + gap + divider + gap
            local contentH = #rows * rowH + math.max(0, #rows - 1) * 3
            local startY = math.floor(bz.y + headerH + (bz.h - headerH - contentH) / 2) - 6
            for _, row in ipairs(rows) do
                local ry = startY
                local mid = ry + math.floor((iconSz - FONT_SM) / 2)
                if row.tex then
                    self:drawTextureScaledAspect(row.tex, bz.x + pad, ry, iconSz, iconSz, 0.85, 1, 1, 1)
                end
                self:drawText(row.label, bz.x + pad + iconSz + 4, mid, 0.72, 0.72, 0.76, 0.90, UIFont.Small)
                local aw = getTextManager():MeasureStringX(UIFont.Small, row.amount)
                self:drawText(row.amount, bz.x + bz.w - aw - pad, mid, 0.88, 0.88, 0.50, 1, UIFont.Small)
                startY = startY + rowH + 3
            end
        end
    end

    -- ── feedback zone ─────────────────────────────────────────────────────────
    if self.feedbackText then
        if self.feedbackTimer > 0 then
            self.feedbackTimer = self.feedbackTimer - 1
        else
            self.feedbackText = nil
        end
    end

    if self.feedbackText then
        local fc = self.feedbackColor
        local txt = truncate(self.feedbackText, fz.w - 12, UIFont.Small)
        local tw = getTextManager():MeasureStringX(UIFont.Small, txt)
        self:drawText(txt, math.floor(fz.x + (fz.w - tw) / 2), math.floor(fz.y + (fz.h - FONT_SM) / 2), fc.r, fc.g,
            fc.b, fc.a, UIFont.Small)
    end

    -- ── admin button gear icon ────────────────────────────────────────────────
    -- ISButton doesn't reliably render textures in all PZ versions; draw manually.
    local adminBtn = self.controls.adminBtn
    if adminBtn and adminBtn:isVisible() then
        local gearTex = getTexture("media/ui/inventoryPanes/Button_Gear.png")
        if gearTex then
            local pad = 3
            self:drawTextureScaled(gearTex, adminBtn.x + pad, adminBtn.y + pad, adminBtn.width - pad * 2,
                adminBtn.height - pad * 2, 1)
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- details panel content
-- ─────────────────────────────────────────────────────────────────────────────

function UI:renderDetails(z)
    local offer = self.selectedOffer
    if not offer then
        return
    end

    local pad = 8
    local x = z.x + pad
    local maxW = z.w - pad * 2
    local y = z.y + pad
    local lh = FONT_SM + 3
    local maxY = z.y + z.h - lh - 4
    local adapter = Core.getPlayerAdapter and Core.getPlayerAdapter(self.player)

    -- item name (word-wrapped, max 2 lines)
    local name = tools.resolveOfferDisplayName(offer)
    local nameLines = wrapText(name, maxW, UIFont.Small)
    for i = 1, math.min(2, #nameLines) do
        local line = (i == 2 and #nameLines > 2) and truncate(nameLines[i], maxW, UIFont.Small) or nameLines[i]
        self:drawText(line, x, y, 1.0, 0.88, 0.45, 1, UIFont.Small)
        y = y + lh
    end
    y = y + 2

    -- divider
    self:drawRect(x, y, maxW, 1, 0.40, 0.45, 0.45, 0.50)
    y = y + 5

    -- price
    local price = offer.price
    local fmtCents = tools.formatCents
    -- Grouped here as well as on the tile badge. The detail panel is where the
    -- big numbers actually live, and a vehicle at 3824 was the one place still
    -- printing them a digit at a time.
    local group = Core.utils.formatWholeNumber
    local priceText
    local priceItemTex
    local isCollector = price and price.selfPay == true
    if not price then
        priceText = getText("IGUI_PhunMart_PriceUnknown")
    elseif price.kind == "free" then
        priceText = getText("IGUI_PhunMart_PriceFree")
    elseif price.kind == "currency" then
        local amt = price.amount
        local isTokens = price.pool == "tokens"
        local function fmtAmt(n)
            if isTokens then
                return group(n) .. "t"
            end
            return fmtCents(n)
        end
        if type(amt) == "table" and amt.min and amt.max then
            priceText = getText("IGUI_PhunMart_PriceRange", fmtAmt(amt.min), fmtAmt(amt.max))
        elseif type(amt) == "number" then
            priceText = getText("IGUI_PhunMart_PriceAmount", fmtAmt(amt))
        else
            priceText = getText("IGUI_PhunMart_PriceUnknown")
        end
    elseif isCollector and price.items and price.items[1] then
        -- Collector offer: the displayed item IS the price. Show "Bring: Nx item".
        local pi = price.items[1]
        local amt = type(pi.amount) == "table" and (group(pi.amount.min) .. "-" .. group(pi.amount.max)) or
                        group(pi.amount or 1)
        local itemName = pi.item or "?"
        local si = getScriptManager and getScriptManager():FindItem(itemName)
        if si then
            itemName = si:getDisplayName() or itemName
            priceItemTex = si:getNormalTexture()
        end
        priceText = getText("IGUI_PhunMart_BringItems", amt, itemName)
    elseif price.items and price.items[1] then
        local pi = price.items[1]
        local amt = type(pi.amount) == "table" and (group(pi.amount.min) .. "-" .. group(pi.amount.max)) or
                        group(pi.amount or 1)
        local itemName = pi.item or "?"
        local si = getScriptManager and getScriptManager():FindItem(itemName)
        if si then
            itemName = si:getDisplayName() or itemName
            priceItemTex = si:getNormalTexture()
        end
        -- Money needs no naming when its picture is right there. "275x Dollars"
        -- beside a picture of the money says it twice; the icon is doing the
        -- same job the dollar sign does on a change server.
        --
        -- Only for the currency, and only when there is an icon to carry it. A
        -- barter price naming some other item still says which item, because
        -- nothing else on the tile would.
        if priceItemTex and tools.isCurrencyItem(pi.item) then
            priceText = getText("IGUI_PhunMart_PriceItemsBare", amt)
        else
            priceText = getText("IGUI_PhunMart_PriceItems", amt, itemName)
        end
    else
        priceText = getText("IGUI_PhunMart_PriceUnknown")
    end
    local pr, pg, pb = 0.72, 0.88, 0.28 -- green: affordable
    if adapter and price then
        if price.kind == "currency" and adapter.player and Core.wallet then
            local balance = Core.wallet:getBalance(adapter.player, price.pool)
            if balance < (price.amount or 0) then
                pr, pg, pb = 0.90, 0.30, 0.30
            end
        elseif price.kind == "items" and price.items then
            for _, pi in ipairs(price.items) do
                local need = type(pi.amount) == "table" and pi.amount.min or (pi.amount or 1)
                local count = adapter:countItem(pi.item) or 0
                if pi.substitutes then
                    for _, sub in ipairs(pi.substitutes) do
                        count = count + (adapter:countItem(sub) or 0)
                    end
                end
                if count < need then
                    pr, pg, pb = 0.90, 0.30, 0.30
                    break
                end
            end
        end
    end
    if isCollector then
        pr, pg, pb = 0.30, 0.85, 0.85 -- cyan for collector "Bring:" line
    end
    local priceIconSz = lh - 3
    local priceIconRoom = priceItemTex and (priceIconSz + 4) or 0
    local truncatedPrice = truncate(priceText, maxW - priceIconRoom, UIFont.Small)
    self:drawText(truncatedPrice, x, y, pr, pg, pb, 1, UIFont.Small)
    if priceItemTex then
        local textW = getTextManager():MeasureStringX(UIFont.Small, truncatedPrice)
        self:drawTextureScaledAspect(priceItemTex, x + textW + 2, y, priceIconSz, priceIconSz, 1, 1, 1, 1)
    end
    y = y + lh + 4

    -- For collector/pawn offers, show what the player receives on the next line.
    if isCollector and offer.reward and offer.reward.actions then
        local receiveText, receiveTex
        -- Aggregate giveItem payouts of the same item so a single amount=N entry
        -- (or several repeated entries) renders as one "Receive: Nx Item" line.
        local giveItemName, giveItemTotal = nil, 0
        for _, action in ipairs(offer.reward.actions) do
            if action.type == "grantBoundTokens" then
                receiveText = getText("IGUI_PhunMart_ReceiveTokens", tostring(action.amount or 1))
                break
            elseif action.type == "adjustBalance" then
                -- Through the same conversion the payout goes through. On an
                -- item currency the icon says what it is, so the figure stands
                -- alone the way a cash amount does.
                local amt, item = Core.currencyValueOf(action.amount or 0)
                if item then
                    local si = getScriptManager and getScriptManager():FindItem(item)
                    receiveTex = si and si:getNormalTexture()
                    receiveText = getText("IGUI_PhunMart_ReceiveChange", group(amt))
                else
                    receiveText = getText("IGUI_PhunMart_ReceiveChange", fmtCents(amt))
                end
                break
            elseif action.type == "giveItem" and action.item then
                giveItemName = giveItemName or action.item
                if action.item == giveItemName then
                    giveItemTotal = giveItemTotal + (tonumber(action.amount) or 1)
                end
            end
        end
        if not receiveText and giveItemName then
            local itemName = giveItemName
            local si = getScriptManager and getScriptManager():FindItem(giveItemName)
            if si then
                itemName = si:getDisplayName() or itemName
                receiveTex = si:getNormalTexture()
            end
            receiveText = getText("IGUI_PhunMart_ReceiveItems", tostring(giveItemTotal), itemName)
        end
        if receiveText then
            local iconSz = lh - 3
            local iconRoom = receiveTex and (iconSz + 4) or 0
            local truncated = truncate(receiveText, maxW - iconRoom, UIFont.Small)
            self:drawText(truncated, x, y, 0.85, 0.75, 0.20, 1, UIFont.Small)
            if receiveTex then
                local textW = getTextManager():MeasureStringX(UIFont.Small, truncated)
                self:drawTextureScaledAspect(receiveTex, x + textW + 2, y, iconSz, iconSz, 1, 1, 1, 1)
            end
            y = y + lh + 4
        end
    end

    -- Stock, always, including when there is no limit.
    --
    -- Only the sold-out state was visible before, so a machine with two left
    -- looked exactly like one with two hundred, and the first sign of a limit
    -- was the offer greying out after the purchase that emptied it. Said in
    -- words here rather than only as the count on the tile, because "unlimited"
    -- is a real answer and an absent badge is not.
    local stockQty = offer.offer and offer.offer.stockQty
    local stockText, sr, sg, sb
    if stockQty == nil or stockQty == -1 then
        stockText, sr, sg, sb = getText("IGUI_PhunMart_StockUnlimited"), 0.60, 0.64, 0.68
    elseif stockQty <= 0 then
        stockText, sr, sg, sb = getText("IGUI_PhunMart_StockOut"), 0.90, 0.30, 0.30
    else
        stockText, sr, sg, sb = getText("IGUI_PhunMart_StockLeft", tostring(stockQty)), 0.72, 0.76, 0.80
        if stockQty <= 2 then
            sr, sg, sb = 0.95, 0.72, 0.30
        end
    end
    self:drawText(truncate(stockText, maxW, UIFont.Small), x, y, sr, sg, sb, 1, UIFont.Small)
    y = y + lh + 4

    -- Anything the active mode wants said about this offer.
    --
    -- Placed here, among the price and the stock, rather than appended at the
    -- end: everything below this point is conditions, and every branch of it
    -- returns early, so the end of this function is somewhere a line would
    -- sometimes be drawn and sometimes not.
    --
    -- A mode needs this when the numbers above are true but incomplete -- a tile
    -- standing for several listings has a lowest price rather than a price, and
    -- saying so is the difference between a figure and a misleading one.
    local mode = self:currentMode()
    local extra = mode and mode.detailLines and mode.detailLines(self, offer)
    if extra and #extra > 0 then
        for _, line in ipairs(extra) do
            if y > maxY then
                break
            end
            self:drawText(truncate(tostring(line.text or ""), maxW, UIFont.Small), x, y, line.r or 0.72,
                line.g or 0.76, line.b or 0.85, 1, UIFont.Small)
            y = y + lh
        end
        y = y + 4
    end

    -- conditions
    if not offer.conditions then
        return
    end

    -- conditions.all / any are arrays of string keys referencing named condition defs.
    local condList = offer.conditions.all or offer.conditions.any or
                         (type(offer.conditions) == "table" and offer.conditions)
    if not condList then
        return
    end

    local condDefs = self.data and self.data.conditionsDefs
    local R = Core.conditionsRuntime
    local headerY = y -- reserve space; header drawn on first blocking condition
    local headerDrawn = false
    y = y + lh

    for _, condKey in ipairs(condList) do
        if y > maxY then
            self:drawText("...", x + 4, y, 0.35, 0.35, 0.35, 1, UIFont.Small)
            break
        end

        -- Only show conditions that are currently blocking the purchase
        local failure = nil
        if R and adapter and condDefs then
            local result = R.evaluate({
                all = {condKey}
            }, condDefs, adapter, Core.purchases, {
                offerId = self.selectedId
            })
            if not result.ok then
                failure = result.failures[1] or {
                    condKey = condKey,
                    textKey = "",
                    args = {}
                }
            end
        end

        if failure then
            if not headerDrawn then
                self:drawText(getText("IGUI_PhunMart_Requires"), x, headerY, 0.75, 0.55, 0.25, 1, UIFont.Small)
                headerDrawn = true
            end
            local label = truncate("- " .. failureLabel(failure), maxW - 4, UIFont.Small)
            self:drawText(label, x + 4, y, 0.90, 0.30, 0.30, 1, UIFont.Small)
            y = y + lh
        end
    end
    if not headerDrawn then
        y = headerY -- reclaim the reserved line, all conditions pass
    end
end
