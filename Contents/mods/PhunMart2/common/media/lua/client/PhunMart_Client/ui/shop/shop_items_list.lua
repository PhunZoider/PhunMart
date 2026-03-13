if isServer() then
    return
end

require "ISUI/ISPanel"
require "ISUI/ISToolTipInv"
require "ISUI/ISToolTip"
local Core = PhunMart
local Traits = require "PhunMart/traits"

local FONT_SM = getTextManager():getFontHeight(UIFont.Small)
local FONT_TINY = getTextManager():getFontHeight(UIFont.Tiny)
local FONT_SCALE = FONT_SM / 14

local COLS = 5
local PAD_EDGE = 6
local PAD_GAP = 3
local HEADER_H = FONT_SM + 8
local GROUP_GAP = 6
local TOGGLE_H = FONT_SM + 8 -- fixed strip at top for grid/list toggle

local VIEW_GRID = "grid"
local VIEW_LIST = "list"
local LIST_ROW_H = FONT_SM + 8
local LIST_ICON = FONT_SM + 4
local LIST_ROW_H_COMP = FONT_TINY + 6
local LIST_ICON_COMP = FONT_TINY + 2

PhunMartUIShopItemsList = ISPanel:derive("PhunMartUIShopItemsList")
local UI = PhunMartUIShopItemsList
Core.ui.client.shopItemsList = UI

-- Maps skill perk names to the PZ script item whose texture is used as the base icon.
-- Skills not listed here fall back to the reward's display.texture or no icon.
local SKILL_BOOK = {
    -- Ranged / combat
    Aiming          = "Base.BookAiming1",
    Reloading       = "Base.BookReloading1",
    Axe             = "Base.BookAxe1",
    Blunt           = "Base.BookBlunt1",
    SmallBlade      = "Base.BookSmallBlade1",
    LongBlade       = "Base.BookLongBlade1",
    SmallBlunt      = "Base.BookSmallBlunt1",
    Spear           = "Base.BookSpear1",
    -- Survival / nature
    Foraging        = "Base.BasicForaging1",
    PlantScavenging = "Base.BasicForaging1",
    Tracking        = "Base.BasicForaging1",
    Farming         = "Base.BookFarming1",
    Fishing         = "Base.BookFishing1",
    Trapping        = "Base.BookTrapping1",
    -- Crafting / trade
    Cooking         = "Base.BookCooking1",
    Tailoring       = "Base.BookTailoring1",
    Woodwork        = "Base.BookCarpentry1",
    Electricity     = "Base.BookElectricity1",
    Mechanics       = "Base.BookMechanics1",
    Maintenance     = "Base.BookMaintenance1",
    MetalWelding    = "Base.BookMetalWelding1",
    Blacksmith      = "Base.BookBlacksmith1",
    Masonry         = "Base.BookMasonry1",
    Butchering      = "Base.BookButchering1",
    Husbandry       = "Base.BookHusbandry1",
    FlintKnapping   = "Base.BookFlintKnapping1",
    Pottery         = "Base.BookPottery1",
    Carving         = "Base.BookCarving1",
    Glassmaking     = "Base.BookGlassmaking1",
    -- Medical
    Doctor          = "Base.BookFirstAid1",
}

local function formatPrice(offer)
    local price = offer and offer.price
    if not price then
        return nil
    end
    if price.kind == "free" then
        return "FREE"
    end
    if price.kind == "currency" then
        local amt = price.amount
        if type(amt) == "table" then
            amt = amt.min
        end
        if price.pool == "tokens" then
            return tostring(amt) .. "t"
        else
            if amt % 100 == 0 then
                return "$" .. tostring(amt / 100)
            else
                return string.format("$%.2f", amt / 100)
            end
        end
    end
    if price.kind == "items" and price.items and price.items[1] then
        local pi = price.items[1]
        local amt = type(pi.amount) == "table" and pi.amount.min or (pi.amount or 1)
        return tostring(amt) .. "x"
    end
    return nil
end

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

function UI:new(x, y, w, h, opts)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.player = (opts and opts.player) or getPlayer()
    o.onSelectFn = opts and opts.onSelect
    o.onRightClickFn = opts and opts.onRightClick
    o.groups = {}
    o.selected = nil
    o.hovered = nil
    o.toggleHov = false
    o.scrollY = 0
    o.viewMode = VIEW_GRID
    o.compactList = false
    o.noBackground = true
    o.iconList = getTexture("media/ui/craftingMenus/Icon_List.png");
    o.iconGrid = getTexture("media/ui/craftingMenus/Icon_Grid.png");
    return o
end

function UI:initialise()
    ISPanel.initialise(self)

    -- Tooltips are NOT added to UIManager here — added/removed dynamically so
    -- render() is never called when hidden (avoids DoTooltip crashes on hidden panels).
    self.invTooltip = ISToolTipInv:new()
    self.invTooltip:initialise()
    self.invTooltip:setAlwaysOnTop(true)
    self.invTooltip.followMouse = true
    -- B42 requires a character reference for DoTooltip to render correctly
    self.invTooltip:setCharacter(self.player)
    self._invInUI = false

    self.txtTooltip = ISToolTip:new()
    self.txtTooltip:initialise()
    self.txtTooltip:setAlwaysOnTop(true)
    self._txtInUI = false
end

function UI:hideTooltips()
    if self._invInUI then
        self.invTooltip:setVisible(false)
        self.invTooltip:removeFromUIManager()
        self._invInUI = false
    end
    if self._txtInUI then
        self.txtTooltip:setVisible(false)
        self.txtTooltip:removeFromUIManager()
        self._txtInUI = false
    end
end

-- Show the appropriate tooltip for the currently hovered entry, or hide both.
function UI:updateTooltip()
    if not self.hovered then
        self:hideTooltips()
        return
    end

    local gi, idx = self.hovered[1], self.hovered[2]
    local e = self.groups[gi] and self.groups[gi].items[idx]
    if not e then
        self:hideTooltips()
        return
    end

    -- Try inventory item tooltip first (real items only, not traits/vehicles/boosts)
    local itemName = e.offer and e.offer.item
    if itemName and getScriptManager():getItem(itemName) then
        -- Cache InventoryItem per key — instanceItem is a Java call, avoid per-frame
        if self._tipItemKey ~= itemName then
            self._tipItemKey = itemName
            self._tipItem = instanceItem(itemName)
        end
        if self._tipItem then
            if self._txtInUI then
                self.txtTooltip:setVisible(false)
                self.txtTooltip:removeFromUIManager()
                self._txtInUI = false
            end
            self.invTooltip:setItem(self._tipItem)
            if not self._invInUI then
                self.invTooltip:addToUIManager()
                self._invInUI = true
            end
            self.invTooltip:setVisible(true)
            return
        end
    end

    -- Fall back: plain text tooltip (traits, vehicles, boosts, unknown types)
    if self._invInUI then
        self.invTooltip:setVisible(false)
        self.invTooltip:removeFromUIManager()
        self._invInUI = false
    end
    self.txtTooltip.description = e.displayName or ""
    if not self._txtInUI then
        self.txtTooltip:addToUIManager()
        self._txtInUI = true
    end
    self.txtTooltip:setVisible(true)
end

function UI:listRowH()
    return self.compactList and LIST_ROW_H_COMP or LIST_ROW_H
end

function UI:listIconH()
    return self.compactList and LIST_ICON_COMP or LIST_ICON
end

function UI:listFont()
    return self.compactList and UIFont.Tiny or UIFont.Small
end

function UI:listFontH()
    return self.compactList and FONT_TINY or FONT_SM
end

function UI:setData(data)
    self.groups = {}
    self.selected = nil
    self.hovered = nil
    self.scrollY = 0
    self._tipItemKey = nil
    self._tipItem = nil
    self.lastRestock = data and data.lastRestock
    self.restockFrequency = (data and data.restockFrequency) or 24
    self:hideTooltips()
    if not (data and data.offers) then
        return
    end

    local byCategory = {}
    local order = {}
    for id, offer in pairs(data.offers) do
        local scriptItem = getScriptManager():getItem(offer.item)
        local displayName
        local texture
        -- Resolve display name and texture from reward trait action if present
        local traitKey = Traits.getOfferTraitKey(offer)
        if traitKey then
            displayName = Traits.getLabel(traitKey)
            texture = Traits.getTexture(traitKey)
        end
        if not displayName then
            if scriptItem then
                displayName = scriptItem:getDisplayName()
            elseif Core.getVehicleLabel and offer.reward and offer.reward.kind == "vehicle" then
                displayName = Core.getVehicleLabel(offer.item)
            elseif offer.reward and offer.reward.display and offer.reward.display.text then
                displayName = offer.reward.display.text
            else
                displayName = Traits.getLabel(offer.item)
            end
        end
        if not texture then
            texture = scriptItem and scriptItem:getNormalTexture()
        end
        -- For skill/boost rewards, try the corresponding PZ book item as the base icon
        if not texture and offer.reward then
            local kind = offer.reward.kind
            if kind == "skill" or kind == "boost" then
                local action = offer.reward.actions and offer.reward.actions[1]
                if action and action.skill then
                    local bookKey = SKILL_BOOK[action.skill]
                    if bookKey then
                        local bookItem = getScriptManager():getItem(bookKey)
                        if bookItem then texture = bookItem:getNormalTexture() end
                    end
                end
            end
        end
        if not texture and offer.reward and offer.reward.display and offer.reward.display.texture then
            local dt = offer.reward.display.texture
            texture = getTexture(dt)
            if not texture then
                -- allow display.texture to be a script item name (e.g. "Base.BookButchering1")
                local si = getScriptManager():getItem(dt)
                if si then texture = si:getNormalTexture() end
            end
        end
        if not texture and offer.meta and offer.meta.fallbackTexture then
            texture = getTexture(offer.meta.fallbackTexture)
        end
        -- Overlay (e.g. plus-1/2/3 for xp tier, boost-1/2/3 for boost tier)
        local overlay = nil
        if offer.reward and offer.reward.display and offer.reward.display.overlay then
            overlay = getTexture(offer.reward.display.overlay)
        end
        local cat = (offer.meta and offer.meta.category) or (scriptItem and scriptItem:getDisplayCategory()) or "Other"
        if cat == "" then
            cat = "Other"
        end
        local key = "IGUI_ItemCat_" .. cat
        local translated = getText(key)
        if translated ~= key then
            cat = translated
        end
        if not byCategory[cat] then
            byCategory[cat] = {}
            table.insert(order, cat)
        end
        table.insert(byCategory[cat], {
            id = id,
            offer = offer,
            displayName = displayName,
            texture = texture,
            overlay = overlay
        })
    end

    table.sort(order, function(a, b)
        if a == "Other" then
            return false
        end
        if b == "Other" then
            return true
        end
        return a < b
    end)

    for _, cat in ipairs(order) do
        local items = byCategory[cat]
        table.sort(items, function(a, b)
            return a.displayName < b.displayName
        end)
        table.insert(self.groups, {
            name = cat,
            items = items
        })
    end

    -- apply shop's default view; compact list mode uses tiny font + no icon column
    if data.defaultView then
        self.viewMode = data.defaultView == "list" and VIEW_LIST or VIEW_GRID
    end
    self.compactList = (self.viewMode == VIEW_LIST)
end

-- ── layout helpers ────────────────────────────────────────────────────────────

function UI:cellSize()
    return math.floor((self.width - 2 * PAD_EDGE - (COLS - 1) * PAD_GAP) / COLS)
end

-- Grid layout. Each group entry includes rowOffset so slot codes are globally unique.
function UI:groupLayout(cs)
    local layout = {}
    local y = TOGGLE_H + PAD_EDGE
    local rowOffset = 0
    for gi, g in ipairs(self.groups) do
        local rows = math.ceil(#g.items / COLS)
        local itemsH = rows * cs + math.max(0, rows - 1) * PAD_GAP
        table.insert(layout, {
            y = y,
            name = g.name,
            items = g.items,
            rows = rows,
            itemsH = itemsH,
            rowOffset = rowOffset
        })
        y = y + HEADER_H + PAD_GAP + itemsH
        if gi < #self.groups then
            y = y + GROUP_GAP
        end
        rowOffset = rowOffset + rows
    end
    return layout, y + PAD_EDGE
end

-- List layout.
function UI:listGroupLayout()
    local rowH = self:listRowH()
    local layout = {}
    local y = TOGGLE_H + PAD_EDGE
    for gi, g in ipairs(self.groups) do
        local itemsH = #g.items * (rowH + PAD_GAP) - PAD_GAP
        table.insert(layout, {
            y = y,
            name = g.name,
            items = g.items,
            rows = #g.items,
            itemsH = itemsH
        })
        y = y + HEADER_H + PAD_GAP + itemsH
        if gi < #self.groups then
            y = y + GROUP_GAP
        end
    end
    return layout, y + PAD_EDGE
end

function UI:totalContentH()
    if self.viewMode == VIEW_LIST then
        local _, h = self:listGroupLayout()
        return h
    end
    local _, h = self:groupLayout(self:cellSize())
    return h
end

function UI:totalItems()
    local n = 0
    for _, g in ipairs(self.groups) do
        n = n + #g.items
    end
    return n
end

-- ── hit testing ───────────────────────────────────────────────────────────────

function UI:gridIndexAt(mx, my)
    local cs = self:cellSize()
    local layout = self:groupLayout(cs)
    local absY = my + self.scrollY
    local relX = mx - PAD_EDGE
    if relX < 0 then
        return nil, nil
    end
    for gi, gl in ipairs(layout) do
        local itemsY = gl.y + HEADER_H + PAD_GAP
        if absY >= itemsY and absY < itemsY + gl.itemsH then
            local localY = absY - itemsY
            local col = math.floor(relX / (cs + PAD_GAP))
            local row = math.floor(localY / (cs + PAD_GAP))
            if col >= COLS then
                return nil, nil
            end
            local cx = relX - col * (cs + PAD_GAP)
            local cy = localY - row * (cs + PAD_GAP)
            if cx > cs or cy > cs then
                return nil, nil
            end
            local idx = row * COLS + col + 1
            if idx < 1 or idx > #gl.items then
                return nil, nil
            end
            return gi, idx
        end
    end
    return nil, nil
end

function UI:listIndexAt(mx, my)
    local rowH = self:listRowH()
    local layout = self:listGroupLayout()
    local absY = my + self.scrollY
    for gi, gl in ipairs(layout) do
        local itemsY = gl.y + HEADER_H + PAD_GAP
        if absY >= itemsY and absY < itemsY + gl.itemsH then
            local localY = absY - itemsY
            local row = math.floor(localY / (rowH + PAD_GAP))
            local ry = localY - row * (rowH + PAD_GAP)
            if ry > rowH then
                return nil, nil
            end
            local idx = row + 1
            if idx < 1 or idx > #gl.items then
                return nil, nil
            end
            return gi, idx
        end
    end
    return nil, nil
end

function UI:indexAt(mx, my)
    if my < TOGGLE_H then
        return nil, nil
    end
    if self.viewMode == VIEW_LIST then
        return self:listIndexAt(mx, my)
    end
    return self:gridIndexAt(mx, my)
end

-- Toggle button rect (right side of the toggle bar).
function UI:toggleBtnRect()
    local label = self.viewMode == VIEW_GRID and "List" or "Grid"
    local lw = getTextManager():MeasureStringX(UIFont.Small, label)
    local bw = lw + PAD_EDGE * 2
    bw = TOGGLE_H - 2
    local bh = TOGGLE_H - 2
    return self.width - bw - PAD_EDGE, 1, bw, bh, label
end

function UI:isInToggleBtn(mx, my)
    local bx, by, bw, bh = self:toggleBtnRect()
    return mx >= bx and mx <= bx + bw and my >= by and my <= by + bh
end

-- ── input ─────────────────────────────────────────────────────────────────────

function UI:onMouseMove(dx, dy)
    local mx, my = self:getMouseX(), self:getMouseY()
    self.toggleHov = my < TOGGLE_H and self:isInToggleBtn(mx, my)
    local prev = self.hovered
    if my < TOGGLE_H then
        self.hovered = nil
    else
        local gi, idx = self:indexAt(mx, my)
        self.hovered = gi and {gi, idx} or nil
    end
    -- Only update tooltip when the hovered cell actually changes
    local changed = (prev == nil) ~= (self.hovered == nil) or
                        (prev and self.hovered and (prev[1] ~= self.hovered[1] or prev[2] ~= self.hovered[2]))
    if changed then
        self:updateTooltip()
    end
end

function UI:onMouseMoveOutside(dx, dy)
    self.hovered = nil
    self.toggleHov = false
    self:updateTooltip()
end

function UI:onMouseUp(x, y)
    if y < TOGGLE_H then
        if self:isInToggleBtn(x, y) then
            self.viewMode = self.viewMode == VIEW_GRID and VIEW_LIST or VIEW_GRID
            self.selected = nil
            self.scrollY = 0
            if self.onSelectFn then
                self.onSelectFn(nil, nil)
            end
        end
        return
    end
    local gi, idx = self:indexAt(x, y)
    if not gi then
        return
    end
    self.selected = {gi, idx}
    local e = self.groups[gi].items[idx]
    if self.onSelectFn then
        self.onSelectFn(e.id, e.offer, e)
    end
    -- Re-assert tooltip after the callback — the UI state change from onSelectFn
    -- (enabling buy button, 3D preview, etc.) can trigger a stray mouse event that
    -- clears the tooltip even though the mouse hasn't moved.
    self:updateTooltip()
end

function UI:onRightMouseUp(x, y)
    if not self.onRightClickFn then
        return
    end
    local gi, idx = self:indexAt(x, y)
    if not gi then
        return
    end
    local e = self.groups[gi].items[idx]
    self.onRightClickFn(e.id, e.offer, self:getAbsoluteX() + x, self:getAbsoluteY() + y)
end

function UI:onMouseWheel(del)
    local viewH = self.height - TOGGLE_H
    local maxScroll = math.max(0, self:totalContentH() - viewH)
    local step = self.viewMode == VIEW_GRID and (self:cellSize() + PAD_GAP) or (self:listRowH() + PAD_GAP)
    self.scrollY = math.max(0, math.min(maxScroll, self.scrollY - del * step))
    return true
end

-- ── rendering ─────────────────────────────────────────────────────────────────

function UI:renderGrid()
    local cs = self:cellSize()
    local iconSize = math.floor(cs * 0.60)
    local layout = self:groupLayout(cs)

    for gi, gl in ipairs(layout) do
        local hy = gl.y - self.scrollY
        if hy + HEADER_H > TOGGLE_H and hy < self.height then
            self:drawText(gl.name, PAD_EDGE, hy, 0.55, 0.75, 0.55, 1, UIFont.Small)
            self:drawRect(PAD_EDGE, hy + FONT_SM + 3, self.width - PAD_EDGE * 2, 1, 0.4, 0.35, 0.45, 0.35)
        end

        local itemsY = gl.y + HEADER_H + PAD_GAP
        for i, e in ipairs(gl.items) do
            local row = math.floor((i - 1) / COLS)
            local col = (i - 1) % COLS
            local cx = PAD_EDGE + col * (cs + PAD_GAP)
            local cy = itemsY + row * (cs + PAD_GAP) - self.scrollY

            if cy + cs > TOGGLE_H and cy < self.height then
                local isSel = self.selected and self.selected[1] == gi and self.selected[2] == i
                local isHov = self.hovered and self.hovered[1] == gi and self.hovered[2] == i

                local bg_a, bg_r, bg_g, bg_b
                if isSel then
                    bg_a, bg_r, bg_g, bg_b = 0.88, 0.08, 0.22, 0.08
                elseif isHov then
                    bg_a, bg_r, bg_g, bg_b = 0.75, 0.08, 0.08, 0.14
                else
                    bg_a, bg_r, bg_g, bg_b = 0.60, 0.04, 0.04, 0.06
                end
                local stockQty = e.offer and e.offer.offer and e.offer.offer.stockQty
                local isOOS = stockQty ~= nil and stockQty ~= -1 and stockQty <= 0

                self:drawRect(cx, cy, cs, cs, bg_a, bg_r, bg_g, bg_b)
                if isOOS then
                    self:drawRect(cx, cy, cs, cs, 0.45, 0.20, 0.04, 0.04) -- red dim overlay
                end

                if isSel then
                    self:drawRectBorder(cx, cy, cs, cs, 1.0, 0.35, 0.80, 0.35)
                elseif isHov then
                    self:drawRectBorder(cx, cy, cs, cs, 0.6, 0.30, 0.30, 0.45)
                else
                    self:drawRectBorder(cx, cy, cs, cs, 0.35, 0.20, 0.20, 0.25)
                end

                -- icon (centred, shifted up to leave room for badge)
                local iconA = isOOS and 0.30 or 1
                local ix = cx + (cs - iconSize) / 2
                local iy = cy + (cs - iconSize) / 2 - 3
                if e.texture then
                    self:drawTextureScaledAspect(e.texture, ix, iy, iconSize, iconSize, iconA, 1, 1, 1)
                else
                    local abbr = e.displayName:sub(1, 2):upper()
                    local tw = getTextManager():MeasureStringX(UIFont.Small, abbr)
                    self:drawText(abbr, cx + (cs - tw) / 2, cy + (cs - FONT_SM) / 2, 0.5 * iconA, 0.5 * iconA,
                        0.5 * iconA, 1, UIFont.Small)
                end
                if e.overlay then
                    self:drawTextureScaledAspect(e.overlay, ix, iy, iconSize, iconSize, iconA, 1, 1, 1)
                end

                -- slot code top-left
                local globalRow = gl.rowOffset + row
                local code = string.char(65 + globalRow) .. tostring(col + 1)
                self:drawText(code, cx + 2, cy + 1, 0.35, 0.35, 0.35, 1, UIFont.Small)

                -- price/OOS badge bottom-right
                local badge = isOOS and "OUT" or formatPrice(e.offer)
                if badge then
                    local bw = getTextManager():MeasureStringX(UIFont.Small, badge)
                    local bx = cx + cs - bw - 3
                    local by = cy + cs - FONT_SM - 2
                    self:drawRect(bx - 1, by - 1, bw + 2, FONT_SM + 2, 0.75, 0, 0, 0)
                    local tr, tg, tb
                    if isOOS then
                        tr, tg, tb = 0.85, 0.25, 0.25
                    elseif e.offer.price and e.offer.price.selfPay then
                        tr, tg, tb = 0.30, 0.85, 0.85 -- cyan: "bring this item"
                    elseif e.offer.price and e.offer.price.kind == "free" then
                        tr, tg, tb = 0.30, 0.90, 0.30
                    else
                        tr, tg, tb = 0.92, 0.88, 0.30
                    end
                    self:drawText(badge, bx, by, tr, tg, tb, 1, UIFont.Small)
                end
            end
        end
    end
end

function UI:renderList()
    local rowH = self:listRowH()
    local iconH = self:listIconH()
    local font = self:listFont()
    local fontH = self:listFontH()
    local layout = self:listGroupLayout()
    local rowW = self.width - PAD_EDGE * 2

    for gi, gl in ipairs(layout) do
        local hy = gl.y - self.scrollY
        if hy + HEADER_H > TOGGLE_H and hy < self.height then
            self:drawText(gl.name, PAD_EDGE, hy, 0.55, 0.75, 0.55, 1, UIFont.Small)
            self:drawRect(PAD_EDGE, hy + FONT_SM + 3, self.width - PAD_EDGE * 2, 1, 0.4, 0.35, 0.45, 0.35)
        end

        local itemsY = gl.y + HEADER_H + PAD_GAP
        for i, e in ipairs(gl.items) do
            local ry = itemsY + (i - 1) * (rowH + PAD_GAP) - self.scrollY
            if ry + rowH > TOGGLE_H and ry < self.height then
                local isSel = self.selected and self.selected[1] == gi and self.selected[2] == i
                local isHov = self.hovered and self.hovered[1] == gi and self.hovered[2] == i

                local bg_a, bg_r, bg_g, bg_b
                if isSel then
                    bg_a, bg_r, bg_g, bg_b = 0.88, 0.08, 0.22, 0.08
                elseif isHov then
                    bg_a, bg_r, bg_g, bg_b = 0.75, 0.08, 0.08, 0.14
                else
                    bg_a, bg_r, bg_g, bg_b = 0.60, 0.04, 0.04, 0.06
                end
                local stockQty = e.offer and e.offer.offer and e.offer.offer.stockQty
                local isOOS = stockQty ~= nil and stockQty ~= -1 and stockQty <= 0

                self:drawRect(PAD_EDGE, ry, rowW, rowH, bg_a, bg_r, bg_g, bg_b)
                if isOOS then
                    self:drawRect(PAD_EDGE, ry, rowW, rowH, 0.35, 0.20, 0.04, 0.04)
                end

                if isSel then
                    self:drawRectBorder(PAD_EDGE, ry, rowW, rowH, 1.0, 0.35, 0.80, 0.35)
                elseif isHov then
                    self:drawRectBorder(PAD_EDGE, ry, rowW, rowH, 0.6, 0.30, 0.30, 0.45)
                else
                    self:drawRectBorder(PAD_EDGE, ry, rowW, rowH, 0.35, 0.20, 0.20, 0.25)
                end

                -- icon
                local iconA = isOOS and 0.30 or 1
                local nameX = PAD_EDGE + 2
                if e.texture then
                    local iconX = nameX
                    local iconY = ry + math.floor((rowH - iconH) / 2)
                    self:drawTextureScaledAspect(e.texture, iconX, iconY, iconH, iconH, iconA, 1, 1, 1)
                    if e.overlay then
                        self:drawTextureScaledAspect(e.overlay, iconX, iconY, iconH, iconH, iconA, 1, 1, 1)
                    end
                    nameX = nameX + iconH + 4
                end

                -- price/OOS badge (compute width first so name can avoid it)
                local badge = isOOS and "OUT" or formatPrice(e.offer)
                local badgeW = badge and (getTextManager():MeasureStringX(font, badge) + PAD_EDGE) or 0

                -- name (truncated to avoid badge)
                local availW = (PAD_EDGE + rowW) - nameX - badgeW - PAD_EDGE
                local nameStr = truncate(e.displayName, availW, font)
                local na = isOOS and 0.45 or 1
                local nr, ng, nb = isSel and 1.0 or 0.85, isSel and 1.0 or 0.85, isSel and 1.0 or 0.85
                self:drawText(nameStr, nameX, ry + math.floor((rowH - fontH) / 2), nr * na, ng * na, nb * na, 1, font)

                if badge then
                    local bx = PAD_EDGE + rowW - badgeW + 2
                    local by = ry + math.floor((rowH - fontH) / 2)
                    local tr, tg, tb
                    if isOOS then
                        tr, tg, tb = 0.85, 0.25, 0.25
                    elseif e.offer.price and e.offer.price.selfPay then
                        tr, tg, tb = 0.30, 0.85, 0.85 -- cyan: "bring this item"
                    elseif e.offer.price and e.offer.price.kind == "free" then
                        tr, tg, tb = 0.30, 0.90, 0.30
                    else
                        tr, tg, tb = 0.92, 0.88, 0.30
                    end
                    self:drawText(badge, bx, by, tr, tg, tb, 1, font)
                end
            end
        end
    end
end

function UI:render()
    ISPanel.render(self)

    -- ── toggle bar (fixed, not clipped by stencil) ────────────────────────────
    self:drawRect(0, 0, self.width, TOGGLE_H, 0.70, 0.03, 0.03, 0.05)
    self:drawRect(0, TOGGLE_H - 1, self.width, 1, 0.35, 0.25, 0.25, 0.40)

    local bx, by, bw, bh, label = self:toggleBtnRect()
    local hovBg = self.toggleHov and 0.55 or 0.30
    self:drawRect(bx, by, bw, bh, hovBg, 0.05, 0.10, 0.05)
    self:drawRectBorder(bx, by, bw, bh, 0.60, 0.25, 0.45, 0.25)
    self:drawTextureScaledAspect(self.viewMode == VIEW_GRID and self.iconList or self.iconGrid, bx + 4, by + 4, FONT_SM,
        FONT_SM, 1, 1, 1, 1)

    -- Restock timer: left side of toggle bar
    if self.lastRestock then
        local now = GameTime.getInstance():getWorldAgeHours()
        local hoursLeft = math.max(0, (self.lastRestock + self.restockFrequency) - now)
        local statusText
        if hoursLeft < 0.1 then
            statusText = "Restock ready"
        elseif hoursLeft < 1 then
            statusText = string.format("Restocks in %dm", math.floor(hoursLeft * 60))
        else
            statusText = string.format("Restocks in %.1fh", hoursLeft)
        end
        local ty = math.floor((TOGGLE_H - FONT_SM) / 2)
        local ready = hoursLeft < 0.1
        self:drawText(statusText, PAD_EDGE, ty, ready and 0.40 or 0.62, ready and 0.92 or 0.62, ready and 0.40 or 0.66,
            1, UIFont.Small)
    end

    -- ── empty state ───────────────────────────────────────────────────────────
    if self:totalItems() == 0 then
        local msg = "No items available"
        local tw = getTextManager():MeasureStringX(UIFont.Small, msg)
        local viewH = self.height - TOGGLE_H
        self:drawText(msg, (self.width - tw) / 2, TOGGLE_H + (viewH - FONT_SM) / 2, 0.5, 0.5, 0.5, 0.8, UIFont.Small)
        return
    end

    -- ── scrollable content (clipped below toggle bar) ─────────────────────────
    self:setStencilRect(0, TOGGLE_H, self.width, self.height - TOGGLE_H)
    if self.viewMode == VIEW_LIST then
        self:renderList()
    else
        self:renderGrid()
    end
    self:clearStencilRect()

    -- ── scroll indicator ──────────────────────────────────────────────────────
    local totalH = self:totalContentH()
    local viewH = self.height - TOGGLE_H
    if totalH > viewH then
        local dotH = math.max(20, math.floor(viewH * viewH / totalH))
        local maxSc = totalH - viewH
        local dotY = TOGGLE_H + math.floor((viewH - dotH) * self.scrollY / maxSc)
        self:drawRect(self.width - 3, dotY, 2, dotH, 0.5, 0.5, 0.5, 0.5)
    end

end
