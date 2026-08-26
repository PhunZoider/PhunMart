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
    if not offer then
        return "?"
    end
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
    if Core.getAnimalLabel and offer.reward and offer.reward.kind == "animal" then
        local action = offer.reward.actions and offer.reward.actions[1]
        if action and action.animal and action.breed then
            return Core.getAnimalLabel(action.animal, action.breed)
        end
    end
    if offer.reward and offer.reward.display and offer.reward.display.text then
        return offer.reward.display.text
    end
    return Traits.getLabel(offer.item) or offer.item
end

-- Format a price for compact display (grid badges, list rows).
-- Returns (text, texture) where text is a short string like "FREE", "$1.50", "3t", "25";
-- texture is the item icon for kind="items" (nil otherwise).
function tools.formatPriceShort(offer)
    local price = offer and offer.price
    if not price then
        return nil
    end
    if price.kind == "free" then
        return getText("IGUI_PhunMart_Admin_FREE")
    end
    if price.kind == "currency" then
        local amt = price.amount
        if type(amt) == "table" then
            amt = amt.min
        end
        if price.pool == "tokens" then
            return tostring(amt) .. getText("IGUI_PhunMart_TokenSuffix")
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
        local tex
        if pi.item then
            local si = getScriptManager():FindItem(pi.item)
            tex = si and si:getNormalTexture()
        end
        return tostring(amt), tex
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

--- What a price key actually costs, in words, resolved through its inherit
--- chain: "$2.50 - $6.00", "3 tokens", "10x Base.Nails", "free".
---
--- Every editor with a price dropdown shows only the key, and a key is a name
--- somebody invented. `currency_low` says nothing about whether that is pennies
--- or a fortune, so choosing between two of them meant leaving the form and
--- opening the price list. Now the hint under the dropdown answers it.
---
--- Reports the amount as stored, without applying `factor`, so a scaled child
--- reads as its own base figure rather than a number that appears nowhere in
--- its definition.
function tools.formatPriceAmount(priceDef)
    if not priceDef then
        return ""
    end
    local kind = tools.resolvePriceField(priceDef, "kind")
    if kind == "free" then
        return getText("IGUI_PhunMart_Free")
    end

    local function amountText(amt, suffix)
        if type(amt) == "table" then
            return tostring(amt.min) .. " - " .. tostring(amt.max) .. (suffix or "")
        end
        return tostring(amt) .. (suffix or "")
    end

    if kind == "items" then
        local items = tools.resolvePriceField(priceDef, "items")
        local item = tools.resolvePriceField(priceDef, "item")
        if not item and items and items[1] then
            item = items[1].item
        end
        -- The entry's own amount wins over the line's: a child that overrides
        -- only `amount` is the common shape, and reading the line would report
        -- the parent's figure.
        local amt = priceDef.amount or (items and items[1] and items[1].amount) or 1
        local name = item or "?"
        local si = item and getScriptManager():getItem(item)
        if si then
            name = si:getDisplayName()
        end
        return amountText(amt, "x ") .. name
    end

    if kind == "self" then
        -- No item to name: the thing being sold is the thing being paid.
        return getText("IGUI_PhunMart_Price_Self",
            amountText(tools.resolvePriceField(priceDef, "amount") or 1))
    end

    local amount = tools.resolvePriceField(priceDef, "amount")
    if amount == nil then
        return ""
    end
    local pool = tools.resolvePriceField(priceDef, "pool")

    if pool == "change" then
        if type(amount) ~= "table" then
            return tools.formatCents(amount)
        end
        -- Both ends in the same shape. formatCents drops the pence on a whole
        -- number of dollars, which reads fine alone and mismatched in a range:
        -- currency_low came out "$2.50 - $6". If either end wants pence, both
        -- get them.
        local lo, hi = tonumber(amount.min) or 0, tonumber(amount.max) or 0
        if lo % 100 == 0 and hi % 100 == 0 then
            return tools.formatCents(lo) .. " - " .. tools.formatCents(hi)
        end
        return string.format("$%.2f - $%.2f", lo / 100, hi / 100)
    end

    if pool == "tokens" then
        -- Spelled out rather than the "t" suffix the shop grid uses: that is
        -- compressed for a tile with no room, and there is room here.
        if type(amount) ~= "table" and tonumber(amount) == 1 then
            return getText("IGUI_PhunMart_Price_Token", tostring(amount))
        end
        return getText("IGUI_PhunMart_Price_Tokens", amountText(amount))
    end

    return amountText(amount, " " .. tostring(pool or "currency"))
end

--- The same thing, from a price key rather than a definition. Returns "" for a
--- key that names nothing, so a caller can print it without checking.
function tools.priceHint(key)
    if not key or key == "" then
        return ""
    end
    local prices = Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"
    local def = prices[key]
    if not def then
        return ""
    end
    return tools.formatPriceAmount(def)
end

--- The order the four machine tiles are read in. ServerObject:getSpriteIndex
--- maps E to 1, S to 2, W to 3 and anything else to 4, so the list is not the
--- compass order anyone would guess and a preview has to say which is which.
tools.TILE_FACINGS = {"IGUI_PhunMart_Wiz_East", "IGUI_PhunMart_Wiz_South", "IGUI_PhunMart_Wiz_West",
                      "IGUI_PhunMart_Wiz_North"}

--- The texture for one tile name, or nil when nothing matches. Guarded because
--- the sprite manager is the game's, not ours, and an unknown name from a mod
--- that is not loaded should show an empty frame rather than end whatever was
--- drawing it.
function tools.tileTexture(name)
    if not name or name == "" then
        return nil
    end
    local ok, tex = pcall(function()
        local spr = IsoSpriteManager.instance:getSprite(name)
        return spr and spr:getTextureForCurrentFrame(IsoDirections.S) or nil
    end)
    return ok and tex or nil
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

--- Read a field off a price definition, following `inherit` when the
--- definition does not set it itself.
---
--- Most shipped prices carry only an amount and lean on currency_base for the
--- rest, so reading a field directly gets nil far more often than not. Two
--- copies of this walk drifting apart is how the prices list came to show
--- "change" under Kind and a raw cent count under Amount on the same row.
---
--- Depth-limited: an override file can name a parent that names it back, and
--- this runs while drawing.
function tools.resolvePriceField(priceDef, field, depth)
    if not priceDef or priceDef[field] ~= nil then
        return priceDef and priceDef[field]
    end
    if not priceDef.inherit or (depth or 0) >= 10 then
        return nil
    end
    local prices = Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"
    local parent = prices[priceDef.inherit]
    if not parent then
        return nil
    end
    return tools.resolvePriceField(parent, field, (depth or 0) + 1)
end

--- Resolve a definition through its `inherit` chain, the way the compiler
--- does, so an editor can show what a row actually resolves to rather than
--- only what it stores.
---
--- This matters because a child may store almost nothing. After the XP and
--- boost templates took on what their variants share, a child holds a skill
--- name and little else, and a form reading the raw table sees blanks where
--- there are real values. Worse, a combo cannot show a blank: it falls to its
--- first option, and saving then writes that over the inherited answer.
---
--- Actions merge per element, matching mergeActions in compiler.lua, so a base
--- carrying `type` and a child carrying `skill` come back as one whole action.
function tools.resolveInherited(defs, key, depth)
    local def = defs and defs[key]
    if type(def) ~= "table" then
        return nil
    end
    if not def.inherit or (depth or 0) >= 20 then
        return Core.utils.deepCopy(def)
    end
    local parent = tools.resolveInherited(defs, def.inherit, (depth or 0) + 1)
    if not parent then
        return Core.utils.deepCopy(def)
    end

    local merged = Core.utils.deepMerge(parent, def)
    if type(parent.actions) == "table" and type(def.actions) == "table" then
        local acts = {}
        for i = 1, #def.actions do
            local c, p = def.actions[i], parent.actions[i]
            if type(c) == "table" and type(p) == "table" then
                acts[i] = Core.utils.deepMerge(p, c)
            else
                acts[i] = Core.utils.deepCopy(c)
            end
        end
        merged.actions = acts
    end
    -- template is never inherited; only what the child itself declares.
    merged.template = (def.template == true)
    return merged
end

local function sameValue(a, b)
    if type(a) ~= type(b) then
        return false
    end
    if type(a) ~= "table" then
        return a == b
    end
    for k, v in pairs(a) do
        if not sameValue(v, b[k]) then
            return false
        end
    end
    for k in pairs(b) do
        if a[k] == nil then
            return false
        end
    end
    return true
end

local function isEmptyTable(t)
    for _ in pairs(t) do
        return false
    end
    return true
end

--- Strip from `node` anything `parentNode` already provides, so a child keeps
--- only what makes it different.
---
--- An edit form shows resolved values, which means it hands back inherited ones
--- too. Writing those onto the child would freeze them: change the parent later
--- and this one entry would stop following it, which is the opposite of why
--- inheritance exists.
---
--- Maps are walked key by key. Comparing a whole `display` would never match,
--- since the parent holds a texture and the child a text, and the child would
--- come away with a copy of the parent's texture.
---
--- Lives here rather than in one editor because both the editors that support
--- inheritance need it, and two copies of a rule this fiddly would drift.
function tools.pruneInherited(node, parentNode)
    if type(node) ~= "table" or type(parentNode) ~= "table" then
        return
    end
    for k, v in pairs(node) do
        local pv = parentNode[k]
        if pv ~= nil then
            if type(v) == "table" and type(pv) == "table" and not Core.utils.isSequence(v) and
                not Core.utils.isSequence(pv) then
                tools.pruneInherited(v, pv)
                if isEmptyTable(v) then
                    node[k] = nil
                end
            elseif sameValue(v, pv) then
                node[k] = nil
            end
        end
    end
end

--- The resolved parent of `def`, or nil when it has none. What a child would
--- be if it declared nothing at all, which is the yardstick for telling
--- whether a value on a form is the child's own or borrowed.
function tools.resolveParent(defs, def)
    if not def or not def.inherit then
        return nil
    end
    return tools.resolveInherited(defs, def.inherit)
end

return tools
