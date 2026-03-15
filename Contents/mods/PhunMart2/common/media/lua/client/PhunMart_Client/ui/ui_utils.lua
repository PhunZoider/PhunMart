if isServer() then
    return
end

local Core = PhunMart
local tools = {}
local getTextManager = getTextManager
local UIFont = UIFont
local ISLabel = ISLabel
local ISTextEntryBox = ISTextEntryBox
local ISPanel = ISPanel
local ISScrollingListBox = ISScrollingListBox
local ipairs = ipairs

tools.FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
tools.FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
tools.FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
tools.BUTTON_HGT = tools.FONT_HGT_SMALL + 6

tools.FONT_SCALE = tools.FONT_HGT_SMALL / 14
tools.HEADER_HGT = tools.FONT_HGT_MEDIUM + 2 * 2
tools.BUTTON_WID = 100 * tools.FONT_SCALE

function tools.getLabel(text, x, y)
    local label = ISLabel:new(x, y, tools.FONT_HGT_SMALL, text, 1, 1, 1, 1, UIFont.Small, true);
    label:initialise();
    label:instantiate();
    return label;
end

function tools.getTextbox(value, tooltip, x, y, width)
    local textbox = ISTextEntryBox:new(value and tostring(value) or "", x, y, width or 200, tools.FONT_HGT_SMALL + 4);
    textbox:initialise();
    -- textbox:instantiate();
    if tooltip then
        textbox:setTooltip(tooltip)
    end
    textbox:setAnchorRight(true);
    return textbox;
end

function tools.getLabeledTextbox(label, tooltip, value, x, y, xOffset, boxWidth)
    local lbl = tools.getLabel(label, x, y)
    local text = tools.getTextbox(value, tooltip, x + (xOffset or 150), y, boxWidth)
    return lbl, text
end

function tools.getBool(txt, tooltip, x, y)

    local checkbox = ISTickBox:new(x, y, tools.BUTTON_HGT, tools.BUTTON_HGT, getTextOrNull(txt) or txt)
    checkbox:initialise();
    checkbox:instantiate();
    checkbox:addOption(getTextOrNull(txt) or txt, nil)
    checkbox:setSelected(1, true)
    checkbox:setWidthToFit()
    if tooltip then
        checkbox.tooltip = tooltip
    end
    return checkbox

end

function tools.getContainerPanel(x, y, w, h, fns)
    local panel = ISPanel:new(x, y, w, h);
    panel:initialise();
    panel:instantiate();
    panel:setAnchorRight(true);
    panel:setAnchorBottom(true);
    panel:setAnchorTop(true);
    panel:setAnchorLeft(true);
    panel:addScrollBars();
    panel.vscroll:setVisible(true)
    panel:setScrollChildren(true)
    panel.prerender = fns.prerender or panel.prerender;
    panel.render = fns.render or panel.render;
    panel.onMouseWheel = fns.onMouseWheel or panel.onMouseWheel;
    return panel;

end

function tools.getTabPanel(x, y, w, h, fns)
    local f = fns or {}
    local panel = ISTabPanel:new(x, y, w, h);
    panel:initialise();
    panel:instantiate();
    panel:setAnchorRight(true);
    panel:setAnchorBottom(true);
    panel:setAnchorTop(true);
    panel:setAnchorLeft(true);
    panel.prerender = f.prerender or panel.prerender;
    panel.render = f.render or panel.render;
    panel.onMouseWheel = f.onMouseWheel or panel.onMouseWheel;
    return panel;
end

function tools.getListbox(x, y, w, h, columns, fns)

    local y = y + tools.HEADER_HGT
    local f = fns or {}

    local box = ISScrollingListBox:new(x, y, w, h);
    box:initialise();
    box:instantiate();
    box.doDrawItem = f.draw or box.doDrawItem;
    box.onMouseUp = f.click or box.onMouseUp;
    box.onRightMouseUp = f.rightClick or box.onRightMouseUp;
    box.itemheight = tools.FONT_HGT_SMALL + 6 * 2
    box.selected = 0;
    box.joypadParent = self;
    box.font = UIFont.NewSmall;
    box:setAnchorRight(true);
    box:setAnchorBottom(true);
    box:setAnchorTop(true);
    box:setAnchorLeft(true);

    for i, v in ipairs(columns) do
        box:addColumn(v, (i - 1) * 200);
    end

    -- box.prerender = function()
    --     -- ISScrollingListBox.prerender(box);
    -- end

    return box;
end

-- ── Shared display helpers ──────────────────────────────────────────────────

local Traits = require "PhunMart/traits"

-- Resolve a human-readable display name for an offer.
-- Returns the best available label: trait name > script item name > vehicle label > reward text > raw key.
function tools.resolveOfferDisplayName(offer)
    if not offer then return "?" end
    local traitKey = Traits.getOfferTraitKey(offer)
    if traitKey then
        return Traits.getLabel(traitKey)
    end
    local scriptItem = getScriptManager():getItem(offer.item)
    if scriptItem then
        return scriptItem:getDisplayName()
    end
    if Core.getVehicleLabel and offer.reward and offer.reward.kind == "vehicle" then
        return Core.getVehicleLabel(offer.item)
    end
    if offer.reward and offer.reward.display and offer.reward.display.text then
        return offer.reward.display.text
    end
    return Traits.getLabel(offer.item) or offer.item
end

-- Format a price for compact display (grid badges, list rows).
-- Returns a short string like "FREE", "$1.50", "3t", "2x", or nil.
function tools.formatPriceShort(offer)
    local price = offer and offer.price
    if not price then return nil end
    if price.kind == "free" then return "FREE" end
    if price.kind == "currency" then
        local amt = price.amount
        if type(amt) == "table" then amt = amt.min end
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

-- Format cents as a currency string ("$1.50" or "$2").
function tools.formatCents(n)
    if n % 100 == 0 then
        return "$" .. tostring(n / 100)
    else
        return string.format("$%.2f", n / 100)
    end
end

-- Truncate text with "..." if it exceeds maxWidth.
function tools.truncate(text, maxWidth, font)
    if getTextManager():MeasureStringX(font, text) <= maxWidth then
        return text
    end
    local t = text
    while #t > 0 and getTextManager():MeasureStringX(font, t .. "...") > maxWidth do
        t = t:sub(1, -2)
    end
    return t .. "..."
end

-- Word-wrap text into lines fitting within maxWidth.
function tools.wrapText(text, maxWidth, font)
    local lines = {}
    local current = ""
    for word in text:gmatch("%S+") do
        local test = current == "" and word or (current .. " " .. word)
        if getTextManager():MeasureStringX(font, test) <= maxWidth then
            current = test
        else
            if current ~= "" then table.insert(lines, current) end
            current = word
        end
    end
    if current ~= "" then table.insert(lines, current) end
    return lines
end

return tools
