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

    -- Admin button: top-left corner of banner (mirrors close button top-right)
    adminBtnX = 5,
    adminBtnY = 5,
    adminBtnSize = 24
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

    -- ── admin button (only for privileged players) ────────────────────────────
    if Core.tools.isAdmin(self.player) then
        local adminSize = px(L.adminBtnSize)
        self.controls.adminBtn = ISButton:new(px(L.adminBtnX), px(L.adminBtnY), adminSize, adminSize, "⚙", self,
            UI.onAdminMenu)
        self.controls.adminBtn:initialise()
        self.controls.adminBtn:instantiate()
        self.controls.adminBtn.font = UIFont.Small
        self.controls.adminBtn.backgroundColor = {r = 0.10, g = 0.10, b = 0.12, a = 0.70}
        self.controls.adminBtn.backgroundColorMouseOver = {r = 0.20, g = 0.20, b = 0.25, a = 0.90}
        self.controls.adminBtn.borderColor = {r = 0.35, g = 0.35, b = 0.40, a = 0.80}
        self:addChild(self.controls.adminBtn)
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

    -- Show 3D vehicle preview only for spawnVehicle reward actions.
    local p3d = self.controls.preview3d
    if p3d then
        local vehicleScript = nil
        if offer and offer.reward and offer.reward.actions then
            for _, action in ipairs(offer.reward.actions) do
                if action.type == "spawnVehicle" then
                    -- Use first script in the list for the preview
                    local scripts = action.scripts or (action.script and {action.script})
                    vehicleScript = scripts and scripts[1]
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

function UI:onBuy()
    if not self.selectedId then
        return
    end
    local loc = self.data and self.data.location
    if not loc then
        self:showFeedback("No location data", 0.9, 0.3, 0.3)
        return
    end
    -- Disable button immediately to prevent double-click
    self.controls.buyBtn:setEnable(false)
    self:showFeedback("Purchasing...", 0.9, 0.9, 0.3)
    sendClientCommand(Core.name, Core.commands.buy, {
        offerId  = self.selectedId,
        location = loc,
        qty      = 1
    })
end

function UI:onPurchaseComplete(result)
    if result.failed then
        local msgs = {
            OutOfStock       = "Out of stock",
            InsufficientFunds = "Not enough funds",
            ConditionsFailed = "Requirements not met",
            ShopNotFound     = "Shop not found",
            OfferNotFound    = "Offer not found",
        }
        local msg = msgs[result.message] or ("Purchase failed: " .. tostring(result.message))
        self:showFeedback(msg, 0.9, 0.3, 0.3)
        -- Re-enable buy button so the player can try again or choose another
        if self.selectedId then
            self.controls.buyBtn:setEnable(self:canPurchase(self.selectedOffer))
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

    -- Re-evaluate buy button for the still-selected offer
    if self.selectedId == result.offerId then
        self.controls.buyBtn:setEnable(self:canPurchase(self.selectedOffer))
    end

    self:showFeedback("Purchased!", 0.35, 0.90, 0.35)
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
    local obj = self:getClientObject()
    if not obj then
        self:showFeedback("No location data", 0.9, 0.3, 0.3)
        return
    end
    obj:reroll()
    self:showFeedback("Rerolling shop...", 0.3, 0.5, 0.9)
end

function UI:onAdminMenu(btn)
    local screenX = self:getAbsoluteX() + btn:getX()
    local screenY = self:getAbsoluteY() + btn:getY() + btn.height

    local context = ISContextMenu.get(self.playerIndex, screenX, screenY)
    context:clear()

    -- ── Change To (replaces Reroll) ───────────────────────────────────────
    local changeMenu = context:getNew(context)
    changeMenu:addOption("Random", self, UI.onAdminReroll)
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
    local changeOpt = context:addOption("Change To")
    context:addSubMenu(changeOpt, changeMenu)

    -- ── Restock ───────────────────────────────────────────────────────────
    context:addOption("Restock", self, UI.onAdminRestock)

    -- ── Edit Shop ─────────────────────────────────────────────────────────
    context:addOption("Edit Shop", self, UI.onEditShop)

    -- ── Pools (grouped by pool set; each pool → View / Edit submenu) ──────
    local poolSets = self.data and self.data.poolSets or {}
    if #poolSets > 0 then
        local poolsMenu = context:getNew(context)
        for si, poolSet in ipairs(poolSets) do
            local setLabel = #poolSets > 1 and ("Set " .. si) or "Active pools"
            poolsMenu:addOption("-- " .. setLabel .. " --")
            for _, poolRef in ipairs(poolSet.keys or {}) do
                local key = type(poolRef) == "table" and poolRef.key or poolRef
                local poolSub = poolsMenu:getNew(poolsMenu)
                poolSub:addOption("View", self, UI.onViewPool, key)
                poolSub:addOption("Edit", self, UI.onEditPool, key)
                local poolOpt = poolsMenu:addOption("* " .. key)
                poolsMenu:addSubMenu(poolOpt, poolSub)
            end
        end
        poolsMenu:addOption("+ Add Pool", self, UI.onNewPool)
        local poolsOpt = context:addOption("Pools")
        context:addSubMenu(poolsOpt, poolsMenu)
    end

    -- ── Blacklist (only when an offer is selected) ────────────────────────
    if self.selectedOffer then
        context:addOption("Blacklist in pool", self, UI.onBlacklistSelected)
    end
end

-- ── Item right-click (admin only) ─────────────────────────────────────────

function UI:onItemRightClick(id, offer, screenX, screenY)
    if not Core.tools.isAdmin(self.player) then
        return
    end
    local context = ISContextMenu.get(self.playerIndex, screenX, screenY)
    context:clear()
    context:addOption("Blacklist in pool", self, UI.onBlacklistOffer, id, offer)
    context:addOption("Edit offer", self, UI.onEditOffer, id, offer)
end

-- ── Action stubs (each will become a panel) ───────────────────────────────

function UI:onChangeTo(shopType)
    local loc = self.data and self.data.location
    if not loc then
        self:showFeedback("No location data", 0.9, 0.3, 0.3)
        return
    end
    sendClientCommand(Core.name, Core.commands.changeTo, {to = shopType, location = loc})
    self:showFeedback("Changing to " .. shopType .. "...", 0.5, 0.7, 0.9)
end

function UI:onEditShop()
    local shopDefs = (Core.defs and Core.defs.shops) or (Core.runtime and Core.runtime.shops) or {}
    local shopDef = shopDefs[self.data.shopType] or {}
    -- Merge in fields already available from the open-shop payload
    shopDef.background  = shopDef.background  or self.data.background
    shopDef.defaultView = shopDef.defaultView or self.data.defaultView
    shopDef.poolSets    = shopDef.poolSets    or self.data.poolSets
    Core.ui.client.shopEditor.open(self.player, self.data.shopType, shopDef)
end

function UI:onViewPool(poolKey)
    -- TODO: open Pool Viewer panel
    self:showFeedback("Pool Viewer: " .. poolKey, 0.7, 0.7, 0.3)
end

function UI:onEditPool(poolKey)
    -- TODO: open Pool Editor panel
    self:showFeedback("Pool Editor: " .. poolKey, 0.7, 0.7, 0.3)
end

function UI:onNewPool()
    -- TODO: open Pool Editor with blank pool
    self:showFeedback("Add Pool coming soon", 0.7, 0.7, 0.3)
end

function UI:onBlacklistSelected()
    self:onBlacklistOffer(self.selectedId, self.selectedOffer)
end

function UI:onBlacklistOffer(id, offer)
    -- TODO: send blacklist command to server
    local item = offer and offer.item
    self:showFeedback("Blacklist coming soon: " .. tostring(item), 0.9, 0.4, 0.1)
end

function UI:onEditOffer(id, offer)
    -- TODO: open Offer Editor modal
    self:showFeedback("Offer Editor coming soon", 0.7, 0.7, 0.3)
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
                tex = Traits.getTexture(tk or self.selectedOffer.item)
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

    -- Wallet balance — right-aligned, always visible
    if Core.wallet then
        local function fmtChange(n)
            if n % 100 == 0 then return "$" .. tostring(n / 100)
            else return string.format("$%.2f", n / 100) end
        end
        local change = Core.wallet:getBalance(self.player, "change")
        local tokens = Core.wallet:getBalance(self.player, "tokens")
        local balTxt
        if change > 0 and tokens > 0 then
            balTxt = fmtChange(change) .. "  " .. tokens .. "t"
        elseif tokens > 0 then
            balTxt = tokens .. "t"
        else
            balTxt = fmtChange(change)
        end
        local bw = getTextManager():MeasureStringX(UIFont.Small, balTxt)
        self:drawText(balTxt, fz.x + fz.w - bw - 6,
            math.floor(fz.y + (fz.h - FONT_SM) / 2), 0.72, 0.88, 0.28, 0.85, UIFont.Small)
    end

    if self.feedbackText then
        local fc = self.feedbackColor
        local txt = truncate(self.feedbackText, fz.w - 12, UIFont.Small)
        local tw = getTextManager():MeasureStringX(UIFont.Small, txt)
        self:drawText(txt, math.floor(fz.x + (fz.w - tw) / 2), math.floor(fz.y + (fz.h - FONT_SM) / 2), fc.r, fc.g,
            fc.b, fc.a, UIFont.Small)
    elseif not (Core.settings and Core.settings.ShowRestockStatus == false) then
        -- Subtle restock timer — only shown when no feedback message is active
        local lastRestock = self.data and self.data.lastRestock
        local freq = self.data and self.data.restockFrequency or 24
        if lastRestock then
            local now = GameTime.getInstance():getWorldAgeHours()
            local hoursLeft = math.max(0, (lastRestock + freq) - now)
            local statusText
            if hoursLeft < 0.1 then
                statusText = "Restock ready"
            elseif hoursLeft < 1 then
                statusText = string.format("Restocks in %dm", math.floor(hoursLeft * 60))
            else
                statusText = string.format("Restocks in %.1fh", hoursLeft)
            end
            self:drawText(statusText, fz.x + 6,
                math.floor(fz.y + (fz.h - FONT_SM) / 2), 0.32, 0.32, 0.35, 0.75, UIFont.Small)
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
    local scriptItem = getScriptManager():getItem(offer.item)
    local name
    local traitKey = Traits.getOfferTraitKey(offer)
    if traitKey then
        name = Traits.getLabel(traitKey)
    elseif scriptItem then
        name = scriptItem:getDisplayName()
    elseif offer.reward and offer.reward.display and offer.reward.display.text then
        name = offer.reward.display.text
    elseif Core.getVehicleLabel and Core.getVehicleLabel(offer.item) ~= offer.item then
        name = Core.getVehicleLabel(offer.item)
    else
        -- Last resort: try the item key directly as a trait/display label (covers boost/xp offer types)
        name = Traits.getLabel(offer.item) or offer.item
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
