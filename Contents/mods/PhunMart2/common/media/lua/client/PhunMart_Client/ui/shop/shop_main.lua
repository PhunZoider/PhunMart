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
    -- 488 → 580: lower machine section — balance pane lives here

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
    adminBtnSize = 24
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
        end
    })
    self.controls.grid:initialise()
    self:addChild(self.controls.grid)

    -- ── buy button (green zone, bottom-right) ────────────────────────────────
    self.controls.buyBtn = ISButton:new(rightX, trayY, rightW, trayH, getText("IGUI_PhunMart_Buy"), self, UI.onBuy)
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
        -- NOTE: do NOT reset p3d.initialized here — the Java scene object persists
        -- across setData calls and "vehicle" already exists; calling createVehicle again crashes.
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
            if (adapter:countItem(pi.item) or 0) < need then
                return false
            end
        end
    end

    return true
end

function UI:onOfferSelected(id, offer, entry)
    self.selectedId = id
    self.selectedOffer = offer
    self.selectedEntry = entry
    self.controls.buyBtn:setEnable(id ~= nil and self:canPurchase(offer, id))

    -- Show 3D vehicle preview only for spawnVehicle reward actions.
    local p3d = self.controls.preview3d
    if p3d then
        local vehicleScript = nil
        if offer and offer.reward and offer.reward.actions then
            for _, action in ipairs(offer.reward.actions) do
                if action.type == "spawnVehicle" then
                    -- Use the offer's item key as the preview script — this IS the
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

    -- Re-evaluate buy button for the still-selected offer
    if self.selectedId == result.offerId then
        -- Record the purchase locally so purchaseCountMax evaluates correctly
        -- on repeated buys without waiting for the next playerSetup sync.
        Core.purchases:add(self.player, result.offerId, 1)
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
        self:showFeedback(getText("IGUI_PhunMart_Msg_NoLocationData"), 0.9, 0.3, 0.3)
        return
    end
    obj:restock(self.player)
    self:showFeedback(getText("IGUI_PhunMart_Msg_Restocking"), 0.9, 0.6, 0.2)
end

function UI:onAdminReroll()
    local obj = self:getClientObject()
    if not obj then
        self:showFeedback(getText("IGUI_PhunMart_Msg_NoLocationData"), 0.9, 0.3, 0.3)
        return
    end
    obj:reroll()
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
    context:addOption(getText("IGUI_PhunMart_Admin_EditShop"), self, UI.onEditShop)

    -- ── Pools (grouped by pool set; each pool → View / Edit submenu) ──────
    local poolSets = self.data and self.data.poolSets or {}
    if #poolSets > 0 then
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
        end
        poolsMenu:addOption(getText("IGUI_PhunMart_Admin_AddPool"), self, UI.onNewPool)
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

function UI:onNewPool()
    Core.ui.admin_pools.OnEditPool(self.player, nil)
end

function UI:onBlacklistSelected()
    self:onBlacklistOffer(self.selectedId, self.selectedOffer)
end

function UI:onBlacklistOffer(id, offer)
    local itemKey = offer and offer.item
    if not itemKey then
        return
    end
    sendClientCommand(Core.name, Core.commands.quickBlacklist, {
        itemKey = itemKey
    })
    self:showFeedback(getText("IGUI_PhunMart_Msg_GlobalBlacklisted", tostring(itemKey)), 0.9, 0.5, 0.2)
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
            else
                return tostring(amount)
            end
        end

        local pad = 6
        local iconSz = FONT_SM
        local rowH = iconSz + 4
        local poolOrder = {"change", "tokens"}
        local rows = {}
        for _, pool in ipairs(poolOrder) do
            local def = Core.wallet.pools[pool]
            if def then
                table.insert(rows, {
                    label = def.label,
                    amount = fmtBalance(pool, Core.wallet:getBalance(self.player, pool)),
                    tex = self._poolIcons[pool] and self._poolIcons[pool].tex
                })
            end
        end

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
    local priceText
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
                return tostring(n) .. "t"
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
        local amt = type(pi.amount) == "table" and (pi.amount.min .. "-" .. pi.amount.max) or tostring(pi.amount or 1)
        local itemName = pi.item or "?"
        local si = getScriptManager and getScriptManager():FindItem(itemName)
        if si then
            itemName = si:getDisplayName() or itemName
        end
        priceText = getText("IGUI_PhunMart_BringItems", amt, itemName)
    elseif price.items and price.items[1] then
        local pi = price.items[1]
        local amt = type(pi.amount) == "table" and (pi.amount.min .. "-" .. pi.amount.max) or tostring(pi.amount or 1)
        priceText = getText("IGUI_PhunMart_PriceItems", amt, pi.item or "?")
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
                if (adapter:countItem(pi.item) or 0) < need then
                    pr, pg, pb = 0.90, 0.30, 0.30
                    break
                end
            end
        end
    end
    if isCollector then
        pr, pg, pb = 0.30, 0.85, 0.85 -- cyan for collector "Bring:" line
    end
    self:drawText(truncate(priceText, maxW, UIFont.Small), x, y, pr, pg, pb, 1, UIFont.Small)
    y = y + lh + 4

    -- For collector offers, show what the player receives on the next line.
    if isCollector and offer.reward and offer.reward.actions then
        for _, action in ipairs(offer.reward.actions) do
            if action.type == "grantBoundTokens" then
                local receiveText = getText("IGUI_PhunMart_ReceiveTokens", tostring(action.amount or 1))
                self:drawText(truncate(receiveText, maxW, UIFont.Small), x, y, 0.85, 0.75, 0.20, 1, UIFont.Small)
                y = y + lh + 4
                break
            end
        end
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
        y = headerY -- reclaim the reserved line — all conditions pass
    end
end
