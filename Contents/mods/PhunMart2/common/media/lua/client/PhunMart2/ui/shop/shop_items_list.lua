if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local Core = PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local BUTTON_HGT = FONT_HGT_SMALL + 6

local profileName = "PhunMartUIShopItemsList"
PhunMartUIShopItemsList = ISPanelJoypad:derive(profileName);
local UI = PhunMartUIShopItemsList
local instances = {}
Core.ui.client.shopItemsList = UI

function UI:setData(data)
    self.offersData = data and data.offers or {}
    local list = self.controls and self.controls.list
    if not list then return end
    list:clear()
    for offerId, offer in pairs(self.offersData) do
        local scriptItem = getScriptManager():getItem(offer.item)
        local displayName = scriptItem and scriptItem:getDisplayName() or offer.item
        local texture = scriptItem and scriptItem:getNormalTexture() or nil
        list:addItem(displayName, {
            offerId = offerId,
            offer = offer,
            texture = texture,
            displayName = displayName,
        })
    end
end

function UI:getData()
    return self.offersData
end

function UI:isValid()

end

function UI:isDirty()
    local isDirty = self.isDirtyValue

    return isDirty
end

function UI:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self);
    o.player = opts.player or getPlayer()
    o.playerIndex = o.player:getPlayerNum()
    o:setWantKeyEvents(true)
    self.instance = o;
    return o;
end

function UI:createChildren()
    ISPanelJoypad.createChildren(self)
    self.controls = {}
    self.controls.list = ISScrollingListBox:new(0, 0, self.width, self.height)
    self.controls.list:initialise()
    self.controls.list:instantiate()
    self.controls.list.itemheight = 46
    self.controls.list.doDrawItem = UI.doDrawItem
    self.controls.list:setAnchorRight(true)
    self.controls.list:setAnchorLeft(true)
    self.controls.list:setAnchorTop(true)
    self.controls.list:setAnchorBottom(true)
    self:addChild(self.controls.list)
end

function UI:doDrawItem(y, row, alt)
    local data = row.item
    if not data then return y + self.itemheight end

    local pad = 6
    local th = self.itemheight - 8

    if alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 0.5, 0.5, 0.5)
    end
    if self.selected == row.index then
        self:drawRect(0, y, self.width, self.itemheight, 0.3, 0.7, 0.35, 0.15)
    end

    -- item icon
    local x = pad
    if data.texture then
        self:drawTextureScaledAspect(data.texture, x, y + (self.itemheight - th) / 2, th, th, 1, 1, 1, 1)
        x = x + th + pad
    end

    -- item name
    self:drawText(data.displayName, x, y + (self.itemheight - FONT_HGT_MEDIUM) / 2, 1, 1, 1, 1, UIFont.Medium)

    -- price (right-aligned)
    local priceText
    local price = data.offer and data.offer.price
    if not price then
        priceText = "?"
    elseif price.kind == "free" then
        priceText = "Free"
    elseif price.items and price.items[1] then
        local p = price.items[1]
        local amt = type(p.amount) == "table"
            and (p.amount.min .. "-" .. p.amount.max)
            or tostring(p.amount or 1)
        local itemType = p.item or (p.itemAny and p.itemAny[1]) or "?"
        priceText = amt .. "x " .. itemType
    else
        priceText = "?"
    end

    local scrollW = self.vscroll and self.vscroll:isVisible() and self.vscroll.width or 0
    local tw = getTextManager():MeasureStringX(UIFont.Small, priceText)
    self:drawText(priceText, self.width - tw - pad - scrollW,
        y + (self.itemheight - FONT_HGT_SMALL) / 2, 0.7, 0.7, 0.7, 1, UIFont.Small)

    return y + self.itemheight
end

function UI:prerender()

    ISPanelJoypad.prerender(self)

end
