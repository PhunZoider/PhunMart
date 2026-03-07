if isServer() then
    return
end

require "ISUI/ISPanel"
local Core = PhunMart

local FONT_SM = getTextManager():getFontHeight(UIFont.Small)
local FONT_SCALE = FONT_SM / 14

local COLS = 5
local PAD_EDGE = 6
local PAD_GAP = 3

PhunMartUIShopItemsList = ISPanel:derive("PhunMartUIShopItemsList")
local UI = PhunMartUIShopItemsList
Core.ui.client.shopItemsList = UI

function UI:new(x, y, w, h, opts)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.player = (opts and opts.player) or getPlayer()
    o.onSelectFn = opts and opts.onSelect -- fn(id, offer)
    o.offers = {} -- array of {id, offer, displayName, texture}
    o.selected = nil -- index into offers
    o.hovered = nil
    o.scrollY = 0
    o.noBackground = true
    return o
end

function UI:setData(data)
    self.offers = {}
    self.selected = nil
    self.scrollY = 0
    if not (data and data.offers) then
        return
    end
    for id, offer in pairs(data.offers) do
        local scriptItem = getScriptManager():getItem(offer.item)
        local displayName = scriptItem and scriptItem:getDisplayName() or offer.item
        local texture = scriptItem and scriptItem:getNormalTexture()
        table.insert(self.offers, {
            id = id,
            offer = offer,
            displayName = displayName,
            texture = texture
        })
    end
end

-- ── helpers ──────────────────────────────────────────────────────────────────

function UI:cellSize()
    return math.floor((self.width - 2 * PAD_EDGE - (COLS - 1) * PAD_GAP) / COLS)
end

function UI:totalContentH()
    local cs = self:cellSize()
    local rows = math.ceil(#self.offers / COLS)
    return 2 * PAD_EDGE + rows * cs + math.max(0, rows - 1) * PAD_GAP
end

function UI:indexAt(mx, my)
    local cs = self:cellSize()
    local relX = mx - PAD_EDGE
    local relY = my - PAD_EDGE + self.scrollY
    if relX < 0 or relY < 0 then
        return nil
    end
    local col = math.floor(relX / (cs + PAD_GAP))
    local row = math.floor(relY / (cs + PAD_GAP))
    if col >= COLS then
        return nil
    end
    -- reject clicks inside the gap between cells
    local cx = relX - col * (cs + PAD_GAP)
    local cy = relY - row * (cs + PAD_GAP)
    if cx > cs or cy > cs then
        return nil
    end
    local idx = row * COLS + col + 1
    if idx < 1 or idx > #self.offers then
        return nil
    end
    return idx
end

-- ── input ─────────────────────────────────────────────────────────────────────

function UI:onMouseMove(dx, dy)
    self.hovered = self:indexAt(self:getMouseX(), self:getMouseY())
end

function UI:onMouseMoveOutside(dx, dy)
    self.hovered = nil
end

function UI:onMouseUp(x, y)
    local idx = self:indexAt(x, y)
    if not idx then
        return
    end
    self.selected = idx
    local e = self.offers[idx]
    if self.onSelectFn then
        self.onSelectFn(e.id, e.offer)
    end
end

function UI:onMouseWheel(del)
    local cs = self:cellSize()
    local maxScroll = math.max(0, self:totalContentH() - self.height)
    self.scrollY = math.max(0, math.min(maxScroll, self.scrollY - del * (cs + PAD_GAP)))
    return true
end

-- ── rendering ─────────────────────────────────────────────────────────────────

function UI:render()
    ISPanel.render(self)

    if #self.offers == 0 then
        local msg = "No items available"
        local tw = getTextManager():MeasureStringX(UIFont.Small, msg)
        self:drawText(msg, (self.width - tw) / 2, self.height / 2 - FONT_SM / 2, 0.5, 0.5, 0.5, 0.8, UIFont.Small)
        return
    end

    local cs = self:cellSize()
    local iconSize = math.floor(cs * 0.60)

    self:setStencilRect(0, 0, self.width, self.height)

    for i, e in ipairs(self.offers) do
        local row = math.floor((i - 1) / COLS)
        local col = (i - 1) % COLS
        local cx = PAD_EDGE + col * (cs + PAD_GAP)
        local cy = PAD_EDGE + row * (cs + PAD_GAP) - self.scrollY

        -- skip fully off-screen cells
        if cy + cs > 0 and cy < self.height then

            -- cell background
            local bg_a, bg_r, bg_g, bg_b
            if i == self.selected then
                bg_a, bg_r, bg_g, bg_b = 0.88, 0.08, 0.22, 0.08
            elseif i == self.hovered then
                bg_a, bg_r, bg_g, bg_b = 0.75, 0.08, 0.08, 0.14
            else
                bg_a, bg_r, bg_g, bg_b = 0.60, 0.04, 0.04, 0.06
            end
            self:drawRect(cx, cy, cs, cs, bg_a, bg_r, bg_g, bg_b)

            -- cell border
            if i == self.selected then
                self:drawRectBorder(cx, cy, cs, cs, 1.0, 0.35, 0.80, 0.35)
            elseif i == self.hovered then
                self:drawRectBorder(cx, cy, cs, cs, 0.6, 0.30, 0.30, 0.45)
            else
                self:drawRectBorder(cx, cy, cs, cs, 0.35, 0.20, 0.20, 0.25)
            end

            -- item icon (centred, shifted up slightly to leave room for price)
            local ix = cx + (cs - iconSize) / 2
            local iy = cy + (cs - iconSize) / 2 - 3
            if e.texture then
                self:drawTextureScaledAspect(e.texture, ix, iy, iconSize, iconSize, 1, 1, 1, 1)
            else
                local abbr = e.displayName:sub(1, 2):upper()
                local tw = getTextManager():MeasureStringX(UIFont.Small, abbr)
                self:drawText(abbr, cx + (cs - tw) / 2, cy + (cs - FONT_SM) / 2, 0.5, 0.5, 0.5, 1, UIFont.Small)
            end

            -- slot code top-left  (A1, A2 …)
            local code = string.char(65 + row) .. tostring(col + 1)
            self:drawText(code, cx + 2, cy + 1, 0.35, 0.35, 0.35, 1, UIFont.Small)

            -- price badge bottom-right
            local price = e.offer and e.offer.price
            local badge
            if price and price.kind == "free" then
                badge = "FREE"
            elseif price and price.items and price.items[1] then
                local pi = price.items[1]
                local amt = type(pi.amount) == "table" and pi.amount.min or (pi.amount or 1)
                badge = tostring(amt) .. "x"
            end
            if badge then
                local bw = getTextManager():MeasureStringX(UIFont.Small, badge)
                local bx = cx + cs - bw - 3
                local by = cy + cs - FONT_SM - 2
                self:drawRect(bx - 1, by - 1, bw + 2, FONT_SM + 2, 0.75, 0, 0, 0)
                self:drawText(badge, bx, by, 0.65, 0.85, 0.35, 1, UIFont.Small)
            end
        end
    end

    self:clearStencilRect()

    -- hover tooltip: item display name above (or below) the hovered cell
    if self.hovered then
        local e = self.offers[self.hovered]
        if e then
            local row = math.floor((self.hovered - 1) / COLS)
            local col = (self.hovered - 1) % COLS
            local cx = PAD_EDGE + col * (cs + PAD_GAP)
            local cy = PAD_EDGE + row * (cs + PAD_GAP) - self.scrollY
            local name = e.displayName
            local tw = getTextManager():MeasureStringX(UIFont.Small, name)
            local th = FONT_SM + 6
            local tx = math.min(cx, self.width - tw - 10)
            local ty = cy - th - 3
            if ty < 0 then ty = cy + cs + 3 end
            self:drawRect(tx, ty, tw + 8, th, 0.92, 0.06, 0.06, 0.08)
            self:drawRectBorder(tx, ty, tw + 8, th, 0.80, 0.35, 0.35, 0.45)
            self:drawText(name, tx + 4, ty + 3, 1, 1, 1, 1, UIFont.Small)
        end
    end

    -- scroll indicator dot row at right edge if content overflows
    if self:totalContentH() > self.height then
        local totalRows = math.ceil(#self.offers / COLS)
        local visRows = math.floor(self.height / (cs + PAD_GAP))
        local dotH = math.max(20, math.floor(self.height * visRows / totalRows))
        local maxScroll = self:totalContentH() - self.height
        local dotY = math.floor((self.height - dotH) * self.scrollY / maxScroll)
        self:drawRect(self.width - 3, dotY, 2, dotH, 0.5, 0.5, 0.5, 0.5)
    end
end
