if isServer() then
    return
end

require "ISUI/ISPanel"
require "ISUI/ISButton"
local Core = PhunMart
local tools = require "PhunMart2/ux/tools"

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

require "PhunMart2/conditions"
require "PhunMart2/playerAdapter"
local Traits = require "PhunMart2/traits"

local FS = tools.FONT_SCALE
local FONT_SM = tools.FONT_HGT_SMALL
local FONT_MD = tools.FONT_HGT_MEDIUM

-- Base window size before font scaling (portrait, matches machine image ratio ~0.73)
local BASE_W = 480
local BASE_H = 660

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
    -- 478 → 571: lower machine section deliberately left un-overlaid

    -- Bottom strip: dispenser tray (feedback left, buy right)
    trayY = 580,
    trayH = 71,

    -- Close button sits inside the banner, top-right corner
    closeX = 448,
    closeY = 5,
    closeSize = 24,

    -- Admin buttons: stacked in the un-overlaid band (right col, 488-575)
    adminY1 = 495, -- Restock
    adminY2 = 536, -- Reroll
    adminBtnH = 34
}

-- ─────────────────────────────────────────────────────────────────────────────
-- text helpers
-- ─────────────────────────────────────────────────────────────────────────────

-- Returns a table of lines fitting within maxWidth.  Splits on spaces.
local function wrapText(text, maxWidth, font)
    local lines = {}
    local current = ""
    for word in text:gmatch("%S+") do
        local test = current == "" and word or (current .. " " .. word)
        if getTextManager():MeasureStringX(font, test) <= maxWidth then
            current = test
        else
            if current ~= "" then
                table.insert(lines, current)
            end
            current = word
        end
    end
    if current ~= "" then
        table.insert(lines, current)
    end
    return lines
end

-- Truncates text with "…" if it exceeds maxWidth.
local function truncate(text, maxWidth, font)
    if getTextManager():MeasureStringX(font, text) <= maxWidth then
        return text
    end
    local t = text
    while #t > 0 and getTextManager():MeasureStringX(font, t .. "...") > maxWidth do
        t = t:sub(1, -2)
    end
    return t .. "..."
end

-- Human-readable label for a condition key, using the compiled def when available.
local function conditionLabel(condKey, conditionsDefs)
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
        return "World age: " .. min .. "h" .. (max and (" - " .. max .. "h") or "+")
    elseif t == "perkLevelBetween" then
        return "Perk: " .. (a.perk or "?") .. " lv." .. (a.min or 0) .. "+"
    elseif t == "perkBoostBetween" then
        return "Trait boost: " .. (a.perk or "?")
    elseif t == "purchaseCountMax" then
        return "Purchase limit: " .. (a.max or "?")
    elseif t == "professionIn" then
        local profs = a.professions or {}
        return "Profession: " .. (type(profs) == "table" and table.concat(profs, "/") or tostring(profs))
    elseif t == "hasItems" then
        return "Requires items"
    elseif t == "canGrantTrait" then
        return "Already owned: " .. Traits.getLabel(a.trait or "?")
    else
        return condKey
    end
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
        end
    })
    self.controls.grid:initialise()
    self:addChild(self.controls.grid)

    -- ── buy button (green zone, bottom-right) ────────────────────────────────
    self.controls.buyBtn = ISButton:new(rightX, trayY, rightW, trayH, "BUY", self, UI.onBuy)
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

    -- ── admin buttons (only for privileged players) ───────────────────────────
    if Core.tools.isAdmin(self.player) then
        self.controls.restockBtn = ISButton:new(rightX, px(L.adminY1), rightW, px(L.adminBtnH), "RESTOCK", self,
            UI.onAdminRestock)
        self.controls.restockBtn:initialise()
        self.controls.restockBtn:instantiate()
        self.controls.restockBtn.font = UIFont.Small
        self.controls.restockBtn.backgroundColor = {
            r = 0.15,
            g = 0.09,
            b = 0.02,
            a = 0.90
        }
        self.controls.restockBtn.backgroundColorMouseOver = {
            r = 0.30,
            g = 0.18,
            b = 0.03,
            a = 0.95
        }
        self.controls.restockBtn.borderColor = {
            r = 0.70,
            g = 0.45,
            b = 0.10,
            a = 1.00
        }
        self:addChild(self.controls.restockBtn)

        self.controls.rerollBtn = ISButton:new(rightX, px(L.adminY2), rightW, px(L.adminBtnH), "REROLL", self,
            UI.onAdminReroll)
        self.controls.rerollBtn:initialise()
        self.controls.rerollBtn:instantiate()
        self.controls.rerollBtn.font = UIFont.Small
        self.controls.rerollBtn.backgroundColor = {
            r = 0.02,
            g = 0.05,
            b = 0.15,
            a = 0.90
        }
        self.controls.rerollBtn.backgroundColorMouseOver = {
            r = 0.04,
            g = 0.10,
            b = 0.30,
            a = 0.95
        }
        self.controls.rerollBtn.borderColor = {
            r = 0.20,
            g = 0.35,
            b = 0.70,
            a = 1.00
        }
        self:addChild(self.controls.rerollBtn)
    end

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

function UI:setData(data)
    self.data = data or {}
    self.shopKey = data and data.key
    self.selectedId = nil
    self.selectedOffer = nil
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
        p3d.rotX = 22;
        p3d.rotY = 45
        p3d._dragX = nil
        p3d:setVisible(false)
    end

    self.controls.grid:setData(data)
    self.controls.buyBtn:setEnable(false)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- selection / buy
-- ─────────────────────────────────────────────────────────────────────────────

function UI:canPurchase(offer)
    if not offer then
        return false
    end
    local condDefs = self.data and self.data.conditionsDefs
    local adapter = Core.getPlayerAdapter and Core.getPlayerAdapter(self.player)
    local R = Core.conditionsRuntime

    -- conditions
    if R and adapter and condDefs and offer.conditions then
        local result = R.evaluate(offer.conditions, condDefs, adapter, nil, nil)
        if not result.ok then
            return false
        end
    end

    -- price affordability
    local price = offer.price
    if adapter and price and price.items then
        for _, pi in ipairs(price.items) do
            local need = type(pi.amount) == "table" and pi.amount.min or (pi.amount or 1)
            if (adapter:countItem(pi.item) or 0) < need then
                return false
            end
        end
    end

    return true
end

function UI:onOfferSelected(id, offer)
    self.selectedId = id
    self.selectedOffer = offer
    self.controls.buyBtn:setEnable(id ~= nil and self:canPurchase(offer))

    -- Show 3D vehicle preview when the offer item has no game-item entry (vehicles have no ".").
    local p3d = self.controls.preview3d
    if p3d then
        local isVehicle =
            offer and offer.item and not offer.item:find("%.") and getScriptManager():getItem(offer.item) == nil and
                Traits.getOfferTraitKey(offer) == nil
        if isVehicle then
            if not p3d.initialized then
                p3d.initialized = true
                p3d.javaObject:fromLua1("setDrawGrid", false)
                p3d.javaObject:fromLua1("createVehicle", "vehicle")
            end
            -- Always reset rotation, pan and drag state on new selection
            p3d.rotX = 22;
            p3d.rotY = 45
            p3d._dragX = nil
            p3d.javaObject:fromLua3("setViewRotation", p3d.rotX, p3d.rotY, 0)
            p3d.javaObject:fromLua1("setView", "UserDefined")
            p3d.javaObject:fromLua1("setZoom", 3)
            p3d.vehicleName = offer.item
            p3d.javaObject:fromLua2("setVehicleScript", "vehicle", offer.item)
            p3d:setVisible(true)
        else
            p3d.vehicleName = nil
            p3d:setVisible(false)
        end
    end
end

function UI:onBuy()
    if not self.selectedId then
        return
    end
    -- TODO: sendClientCommand("PhunMart2", "purchase", { offerId = self.selectedId })
    self:showFeedback("Purchasing...", 0.9, 0.9, 0.3)
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
        self:showFeedback("Rerolled", 0.3, 0.5, 0.9)
    else
        self:showFeedback("Restocked", 0.4, 0.9, 0.4)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- admin actions
-- ─────────────────────────────────────────────────────────────────────────────

function UI:getClientObject()
    local loc = self.data and self.data.location
    if not loc then
        return nil
    end
    return Core.ClientSystem.instance:getLuaObjectAt(loc.x, loc.y, loc.z)
end

function UI:onAdminRestock()
    local obj = self:getClientObject()
    if not obj then
        self:showFeedback("No location data", 0.9, 0.3, 0.3)
        return
    end
    obj:restock(self.player)
    self:showFeedback("Restocking...", 0.9, 0.6, 0.2)
end

function UI:onAdminReroll()
    local c = Core
    local obj = self:getClientObject()
    if not obj then
        self:showFeedback("No location data", 0.9, 0.3, 0.3)
        return
    end
    obj:reroll()
    self:showFeedback("Rerolling shop...", 0.3, 0.5, 0.9)
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
    if fz then
        -- feedback tray: always visible as a recessed slot
        self:drawRect(fz.x, fz.y, fz.w, fz.h, 0.70, 0.03, 0.03, 0.04)
        self:drawRectBorder(fz.x, fz.y, fz.w, fz.h, 0.40, 0.25, 0.25, 0.28)
    end
end

function UI:render()
    ISPanel.render(self)

    local pz = self.zones.preview
    local dz = self.zones.details
    local fz = self.zones.feedback

    -- ── preview zone ─────────────────────────────────────────────────────────
    if self.selectedOffer then
        local p3d = self.controls.preview3d
        if not (p3d and p3d:isVisible()) then
            -- 2D icon for normal items; 3D scene handles its own rendering for vehicles
            local scriptItem = getScriptManager():getItem(self.selectedOffer.item)
            local tex = scriptItem and scriptItem:getNormalTexture()
            if not tex then
                local tk = Traits.getOfferTraitKey(self.selectedOffer)
                if tk then
                    tex = Traits.getTexture(tk)
                end
            end
            if tex then
                local iconSize = math.floor(math.min(pz.w, pz.h) * 0.78)
                local ix = pz.x + (pz.w - iconSize) / 2
                local iy = pz.y + (pz.h - iconSize) / 2
                self:drawTextureScaledAspect(tex, ix, iy, iconSize, iconSize, 1, 1, 1, 1)
            end
        end
        self:renderDetails(dz)
    else
        local hint = "Select an item"
        local tw = getTextManager():MeasureStringX(UIFont.Small, hint)
        self:drawText(hint, math.floor(pz.x + (pz.w - tw) / 2), math.floor(pz.y + (pz.h - FONT_SM) / 2), 0.38, 0.38,
            0.38, 1, UIFont.Small)
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
    local scriptItem = getScriptManager():getItem(offer.item)
    local name
    local traitKey = Traits.getOfferTraitKey(offer)
    if traitKey then
        name = Traits.getLabel(traitKey)
    elseif scriptItem then
        name = scriptItem:getDisplayName()
    elseif Core.getVehicleLabel then
        name = Core.getVehicleLabel(offer.item)
    else
        name = offer.item
    end
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
    local function fmtCents(n)
        if n % 100 == 0 then
            return "$" .. tostring(n / 100)
        else
            return string.format("$%.2f", n / 100)
        end
    end
    local priceText
    if not price then
        priceText = "Price: ?"
    elseif price.kind == "free" then
        priceText = "Price: FREE"
    elseif price.kind == "currency" then
        local amt = price.amount
        if type(amt) == "table" and amt.min and amt.max then
            priceText = "Price: " .. fmtCents(amt.min) .. " - " .. fmtCents(amt.max)
        elseif type(amt) == "number" then
            priceText = "Price: " .. fmtCents(amt)
        else
            priceText = "Price: ?"
        end
    elseif price.items and price.items[1] then
        local pi = price.items[1]
        local amt = type(pi.amount) == "table" and (pi.amount.min .. "-" .. pi.amount.max) or tostring(pi.amount or 1)
        priceText = "Price: " .. amt .. "x " .. (pi.item or "?")
    else
        priceText = "Price: ?"
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
                if (adapter:countItem(pi.item) or 0) < need then
                    pr, pg, pb = 0.90, 0.30, 0.30
                    break
                end
            end
        end
    end
    self:drawText(truncate(priceText, maxW, UIFont.Small), x, y, pr, pg, pb, 1, UIFont.Small)
    y = y + lh + 4

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
    local headerY = y -- reserve space; header drawn on first visible condition
    local headerDrawn = false
    y = y + lh

    for _, condKey in ipairs(condList) do
        if y > maxY then
            self:drawText("...", x + 4, y, 0.35, 0.35, 0.35, 1, UIFont.Small)
            break
        end

        -- evaluate this single condition to get pass/fail colour
        local cr, cg, cb = 0.52, 0.52, 0.58 -- default: grey (unknown)
        local passed = false
        if R and adapter and condDefs then
            local result = R.evaluate({
                all = {condKey}
            }, condDefs, adapter, nil, nil)
            if result.ok then
                cr, cg, cb = 0.30, 0.90, 0.30 -- green: passes
                passed = true
            else
                cr, cg, cb = 0.90, 0.30, 0.30 -- red: fails
            end
        end

        -- Skip internal (__) conditions when they pass — only show them when blocking a purchase
        if not (passed and condKey:sub(1, 2) == "__") then
            if not headerDrawn then
                self:drawText("Requirements:", x, headerY, 0.50, 0.50, 0.55, 1, UIFont.Small)
                headerDrawn = true
            end
            local label = truncate("- " .. conditionLabel(condKey, condDefs), maxW - 4, UIFont.Small)
            self:drawText(label, x + 4, y, cr, cg, cb, 1, UIFont.Small)
            y = y + lh
        end
    end
    if not headerDrawn then
        y = headerY -- reclaim the reserved line if nothing was shown
    end
end
