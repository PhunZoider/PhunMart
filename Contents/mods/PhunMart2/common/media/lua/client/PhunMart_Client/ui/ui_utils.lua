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

-- Maps skill perk names to the PZ script item whose texture is used as the base icon.
-- Skills not listed here fall back to the reward's display.texture or no icon.
local SKILL_BOOK = {
    -- Ranged / combat
    Aiming = "Base.BookAiming1",
    Reloading = "Base.BookReloading1",
    Axe = "Base.BookAxe1",
    Blunt = "Base.BookBlunt1",
    SmallBlade = "Base.BookSmallBlade1",
    LongBlade = "Base.BookLongBlade1",
    SmallBlunt = "Base.BookSmallBlunt1",
    Spear = "Base.BookSpear1",
    -- Survival / nature
    Foraging = "Base.BasicForaging1",
    PlantScavenging = "Base.BasicForaging1",
    Tracking = "Base.BasicForaging1",
    Farming = "Base.BookFarming1",
    Fishing = "Base.BookFishing1",
    Trapping = "Base.BookTrapping1",
    -- Crafting / trade
    Cooking = "Base.BookCooking1",
    Tailoring = "Base.BookTailoring1",
    Woodwork = "Base.BookCarpentry1",
    Electricity = "Base.BookElectricity1",
    Mechanics = "Base.BookMechanics1",
    Maintenance = "Base.BookMaintenance1",
    MetalWelding = "Base.BookMetalWelding1",
    Blacksmith = "Base.BookBlacksmith1",
    Masonry = "Base.BookMasonry1",
    Butchering = "Base.BookButchering1",
    Husbandry = "Base.BookHusbandry1",
    FlintKnapping = "Base.BookFlintKnapping1",
    Pottery = "Base.BookPottery1",
    Carving = "Base.BookCarving1",
    Glassmaking = "Base.BookGlassmaking1",
    -- Medical
    Doctor = "Base.BookFirstAid1"
}

-- Resolve the icon for an offer, in the order the shop grid resolves it:
-- trait icon > script item icon > skill book cover > the reward's own texture
-- > the group or pool fallback texture. Rewards with no inventory item behind
-- them (vehicles, animals) reach the fallback, which is what it is for.
function tools.resolveOfferTexture(offer)
    if not offer then
        return nil
    end

    local traitKey = Traits.getOfferTraitKey(offer)
    if traitKey then
        local tex = Traits.getTexture(traitKey)
        if tex then
            return tex
        end
    end

    local scriptItem = getScriptManager():getItem(offer.item)
    if scriptItem then
        local tex = scriptItem:getNormalTexture()
        if tex then
            return tex
        end
    end

    local reward = offer.reward
    if reward then
        -- For skill/boost rewards, the corresponding PZ book is the base icon
        if reward.kind == "skill" or reward.kind == "boost" then
            local action = reward.actions and reward.actions[1]
            local bookKey = action and action.skill and SKILL_BOOK[action.skill]
            local bookItem = bookKey and getScriptManager():getItem(bookKey)
            if bookItem then
                local tex = bookItem:getNormalTexture()
                if tex then
                    return tex
                end
            end
        end

        local dt = reward.display and reward.display.texture
        if dt then
            local tex = getTexture(dt)
            if tex then
                return tex
            end
            -- allow display.texture to be a script item name (e.g. "Base.BookButchering1")
            local si = getScriptManager():getItem(dt)
            if si then
                return si:getNormalTexture()
            end
        end
    end

    if offer.meta and offer.meta.fallbackTexture then
        return getTexture(offer.meta.fallbackTexture)
    end

    return nil
end

--- What a collector or pawn offer hands back, in the shortest form that still
--- says which currency: "3t", "$1.50", or a count plus the texture of the item
--- being given. nil when the reward pays out nothing a badge can show.
local function payoutShort(offer)
    local actions = offer and offer.reward and offer.reward.actions
    if type(actions) ~= "table" then
        return nil
    end
    -- Repeated giveItem entries for the same item read as one total, the same
    -- way the tooltip's "Receive:" line adds them up.
    local giveItem, giveTotal = nil, 0
    for _, a in ipairs(actions) do
        if a.type == "grantBoundTokens" then
            return Core.utils.formatWholeNumber(a.amount or 1) .. getText("IGUI_PhunMart_TokenSuffix")
        elseif a.type == "adjustBalance" then
            -- Through the same conversion the payout itself goes through, or
            -- the tile promises dollars on a server that pays in tins.
            local amt, item = Core.currencyValueOf(a.amount or 0)
            if item then
                local si = getScriptManager():FindItem(item)
                return Core.utils.formatWholeNumber(amt), si and si:getNormalTexture()
            end
            return tools.formatCents(amt)
        elseif a.type == "giveItem" and a.item then
            giveItem = giveItem or a.item
            if a.item == giveItem then
                giveTotal = giveTotal + (tonumber(a.amount) or 1)
            end
        end
    end
    if giveItem then
        local si = getScriptManager():FindItem(giveItem)
        return Core.utils.formatWholeNumber(giveTotal), si and si:getNormalTexture()
    end
    return nil
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
            return Core.utils.formatWholeNumber(amt) .. getText("IGUI_PhunMart_TokenSuffix")
        end
        -- Through formatCents rather than a second copy of it. The two had
        -- already drifted: this one always drew two decimal places, so a badge
        -- read $2.00 where the panel beside it read $2.
        return tools.formatCents(amt)
    end
    if price.kind == "items" and price.items and price.items[1] then
        local pi = price.items[1]
        local amt = type(pi.amount) == "table" and pi.amount.min or (pi.amount or 1)
        -- A collector or pawn offer is paid for with the very item on the tile,
        -- so the icon beside the number was the picture directly above it, and
        -- the number read as the cost of something being handed over. Say what
        -- the trade actually is: how many to bring, and what comes back.
        if price.selfPay or pi.item == offer.item then
            local payout, payoutTex = payoutShort(offer)
            if payout then
                -- Only what comes back. How many to bring is returned
                -- separately and drawn in its own corner of the tile, because
                -- one badge saying "1>$5" makes the reader parse a sentence
                -- where two numbers in fixed places do not.
                --
                -- The list view has no corners, so it puts the two back
                -- together itself.
                return payout, payoutTex, amt
            end
            -- Nothing nameable coming back. The count still means something;
            -- the duplicate icon never did.
            return Core.utils.formatWholeNumber(amt)
        end
        local tex
        if pi.item then
            local si = getScriptManager():FindItem(pi.item)
            tex = si and si:getNormalTexture()
        end
        return Core.utils.formatWholeNumber(amt), tex
    end
    return nil
end

--- What to call an item when it is the money, rather than what the game calls
--- it.
---
--- Returns nil for anything that is not the configured currency, so a caller
--- reads it as "or the item's own display name" and a barter price naming some
--- other item is left alone.
---
--- Here rather than inline at the one place that first needed it, because a
--- server that has named its currency means it everywhere the currency is
--- named, and the alternative is finding out one screen at a time which ones
--- were wired up.
--- Whether this item is what the server currently uses as money.
---
--- Separate from currencyLabelFor because the two questions differ: a currency
--- with no label set still is the currency, and a caller deciding whether to
--- draw the name beside an icon has to know that.
function tools.isCurrencyItem(fullType)
    local def = Core.currencyDef and Core.currencyDef()
    return def ~= nil and def.kind == "items" and def.item == fullType
end

function tools.currencyLabelFor(fullType)
    local def = Core.currencyDef and Core.currencyDef()
    if def and def.kind == "items" and def.item == fullType then
        local label = def.label
        if label and label ~= "" then
            return label
        end
    end
    return nil
end

-- Format cents as a currency string ("$1.50", "$2", "$12,750").
--
-- Grouped, because the figures stopped being small. A vehicle at three thousand
-- seven hundred and eighty five drawn as 3785 is a number the eye has to count
-- the digits of, sitting in a list where everything else is loose change, and
-- misreading it by a factor of ten is the expensive direction to be wrong in.
-- `forcePence` keeps the .00 on a whole number of dollars. Only a range wants
-- that: "$2.50 - $6" reads as a mismatch where "$2.50 - $6.00" reads as a pair.
function tools.formatCents(n, forcePence)
    n = tonumber(n) or 0
    local sign = n < 0 and "-" or ""
    local abs = math.abs(math.floor(n))
    local whole = Core.utils.formatWholeNumber(math.floor(abs / 100))
    local rem = abs % 100
    if rem == 0 and not forcePence then
        return sign .. "$" .. whole
    end
    return sign .. "$" .. whole .. string.format(".%02d", rem)
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

    local group = Core.utils.formatWholeNumber
    local function amountText(amt, suffix)
        if type(amt) == "table" then
            return group(amt.min) .. " - " .. group(amt.max) .. (suffix or "")
        end
        return group(amt) .. (suffix or "")
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
        name = tools.currencyLabelFor(item) or name
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
        local pence = not (lo % 100 == 0 and hi % 100 == 0)
        return tools.formatCents(lo, pence) .. " - " .. tools.formatCents(hi, pence)
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

--- The texture behind whatever a display.texture field holds: a path under
--- media/, or a script item name, which is the other thing resolveOfferTexture
--- accepts there. nil when it names neither, so a preview showing nothing is
--- the honest answer to a path typed wrong. Guarded for the same reason
--- tileTexture is: the loaders are the game's, and a name from a mod that is
--- not loaded should draw an empty frame rather than end the form.
function tools.imageTexture(path)
    if not path or path == "" then
        return nil
    end
    local ok, tex = pcall(function()
        local t = getTexture(path)
        if t then
            return t
        end
        local si = getScriptManager():getItem(path)
        return si and si:getNormalTexture() or nil
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

--- Exported as well as local: the specials editor asks the same question about
--- an action it has just pruned, and was calling this name as a global, which
--- is nil there. Nothing shipped inherits actions from a template, so the call
--- has never been reached; it would have ended the save the day one did.
function tools.isEmptyTable(t)
    for _ in pairs(t) do
        return false
    end
    return true
end
local isEmptyTable = tools.isEmptyTable

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

--- A yes/no modal that calls back on yes, with the text wrapped to the box.
--- ISModalDialog reports which button through `internal`, which every caller
--- was unpacking for itself.
function tools.confirm(text, onYes, owner)
    local lines = tools.wrapText(text, math.floor(340 * tools.FONT_SCALE), UIFont.Small)
    local w = math.floor(380 * tools.FONT_SCALE)
    local h = math.max(math.floor(130 * tools.FONT_SCALE),
        #lines * tools.FONT_HGT_SMALL + math.floor(90 * tools.FONT_SCALE))
    local modal = ISModalDialog:new((getCore():getScreenWidth() - w) / 2, (getCore():getScreenHeight() - h) / 2, w, h,
        table.concat(lines, "\n"), true, owner, function(_, button)
            if button.internal == "YES" and onYes then
                onYes()
            end
        end)
    modal:initialise()
    modal:addToUIManager()
    return modal
end

---------------------------------------------------------------------------
-- Conditions
--
-- An authored `conditions` value is one of three shapes: a single key, an
-- array of keys, or a table of `all` / `any` / `notAny` buckets. The array is
-- the compiler's `all`, meaning every key must pass, and it is the shape every
-- shipped definition uses. The editors model that one and carry the other
-- buckets through untouched rather than flattening them into it.
---------------------------------------------------------------------------

--- A short description of what a condition tests, for a list that would
--- otherwise show only a key somebody invented.
--- Falls back to the key for a test this does not know, which includes anything
--- another mod registers.
function tools.conditionLabel(condKey, defs)
    if type(condKey) ~= "string" then
        return tostring(condKey)
    end
    defs = defs or (Core.defs and Core.defs.conditionsDefs)
    local def = defs and defs[condKey]
    if not def then
        return condKey
    end
    local t = def.test
    local a = def.args or {}
    if t == "worldAgeHoursBetween" then
        local min = a.min or 0
        local max = a.max
        return "Age:" .. min .. "h" .. (max and ("-" .. max .. "h") or "+")
    elseif t == "perkLevelBetween" then
        return (a.perk or "?") .. " lv" .. (a.min or 0) .. "+"
    elseif t == "perkBoostBetween" then
        return "Boost:" .. (a.perk or "?")
    elseif t == "purchaseCountMax" then
        return "Limit:" .. (a.max or "?")
    elseif t == "professionIn" then
        local profs = a.professions or {}
        local s = type(profs) == "table" and table.concat(profs, "/") or tostring(profs)
        return "Prof:" .. s
    elseif t == "hasItems" then
        return "Has items"
    elseif t == "canGrantTrait" then
        return "Trait avail"
    elseif t == "canRemoveTrait" then
        return "Has trait"
    else
        return condKey
    end
end

--- Condition keys for a picker, each labelled with what it tests. Sorted, so
--- the 75 generated perk gates sit together rather than wherever pairs() left
--- them.
function tools.conditionOptions()
    local defs = Core.defs and Core.defs.conditionsDefs or {}
    local options = {}
    for k in pairs(defs) do
        local label = tools.conditionLabel(k, defs)
        table.insert(options, {
            key = k,
            display = (label ~= k) and (k .. "  (" .. label .. ")") or k
        })
    end
    table.sort(options, function(a, b)
        return a.key < b.key
    end)
    return options
end

--- Split an authored `conditions` value into the `all` list a form edits and
--- whatever else it carried.
--- @return table allKeys, table|nil extras
function tools.splitConditions(cond)
    if type(cond) == "string" then
        return {cond}, nil
    end
    if type(cond) ~= "table" then
        return {}, nil
    end

    local all = {}
    local extras = nil

    if cond.all == nil and cond.any == nil and cond.notAny == nil then
        -- The array form. An empty table lands here too and yields nothing,
        -- which is the right answer for both readings of it.
        for _, k in ipairs(cond) do
            table.insert(all, k)
        end
        return all, nil
    end

    for _, k in ipairs(cond.all or {}) do
        table.insert(all, k)
    end
    if cond.any or cond.notAny then
        extras = {}
        if cond.any then
            extras.any = Core.utils.deepCopy(cond.any)
        end
        if cond.notAny then
            extras.notAny = Core.utils.deepCopy(cond.notAny)
        end
    end
    return all, extras
end

--- Put the two halves back together, in the simplest shape that holds them.
--- Returns nil when there is nothing to store, so clearing a picker tombstones
--- the key rather than writing an empty table.
function tools.joinConditions(allKeys, extras)
    local hasAll = allKeys and #allKeys > 0
    if not hasAll and not extras then
        return nil
    end

    if not extras then
        local out = {}
        for _, k in ipairs(allKeys) do
            table.insert(out, k)
        end
        return out
    end

    local out = {}
    if hasAll then
        out.all = {}
        for _, k in ipairs(allKeys) do
            table.insert(out.all, k)
        end
    end
    out.any = extras.any
    out.notAny = extras.notAny
    return out
end

--- What the picker field shows when it is closed.
function tools.formatConditionList(keys)
    if not keys or #keys == 0 then
        return getText("IGUI_PhunMart_Lbl_None")
    end
    local limit = math.min(#keys, 3)
    local names = {}
    for i = 1, limit do
        names[i] = keys[i]
    end
    local text = table.concat(names, ", ")
    if #keys > limit then
        text = text .. " +" .. tostring(#keys - limit) .. " more"
    end
    return text
end

return tools
