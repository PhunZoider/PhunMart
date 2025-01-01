if isServer() then
    return
end
require "ISUI/ISPanel"
local PhunMart = PhunMart
PunMartUIPricePanel = ISPanelJoypad:derive("PunMartUIPricePanel");
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14

function PunMartUIPricePanel:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self);
    o.listHeaderColor = opts.listHeaderColor or {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 0.3
    };
    o.borderColor = opts.borderColor or {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 0
    };
    o.backgroundColor = opts.backgroundColor or {
        r = 0,
        g = 0,
        b = 0,
        a = 1
    };
    o.buttonBorderColor = opts.buttonBorderColor or {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 0.5
    };
    o.tabFont = opts.tabFont or UIFont.Small
    o.selectedItem = {}
    o.cachedItem = {}
    o.canBuy = {}
    o.cachedCanBuy = {}
    o.canBuyIssueText = ""
    o.cachedCanBuyIssueText = ""
    o.canBuyEvalIteration = 0
    o.toolTipText = ""
    o.toolTipData = {}
    o.richText = ""
    o.viewer = opts.viewer or getPlayer()
    PunMartUIPricePanel.instance = o;
    return o;
end

function PunMartUIPricePanel:initialise()
    ISPanel.initialise(self);
end

function PunMartUIPricePanel:setItem(item)
    self.selectedItem = item
end
function PunMartUIPricePanel:updateConditionResults()

    local groups = {
        price = {},
        skills = {},
        boostsRequired = {},
        boostsForbidden = {},
        traitsRequired = {},
        traitsForbidden = {},
        professionsRequired = {},
        professionsForbidden = {},
        limits = {},
        weight = {},
        inventory = {}
    }

    local item = self.selectedItem or nil
    if not item then
        return
    end
    if item and self.cachedItem == item and self.canBuyEvalIteration < 100 then
        -- nothings changed so don't re-evaulate every fucking render
        self.canBuyEvalIteration = self.canBuyEvalIteration + 1
        return self.canBuy
    end
    self.canBuy = PhunMart:canBuy(self.viewer, item)
    self.cachedItem = item
    self.canBuyEvalIteration = 0

    local richText = ""

    local allRichTexts = {}
    local allTooltips = {}

    for _, conditions in ipairs(self.canBuy.conditions) do

        local condition = {}
        local tooltips = {}
        local richTexts = {}

        -- assemble each confitions richText and tooltip
        for _, c in ipairs(conditions) do
            local key = c.type
            if c.type == "boosts" then
                if c.value == true then
                    key = "boostsRequired"
                else
                    key = "boostsForbidden"
                end
            elseif c.type == "traits" then
                if c.value == true then
                    key = "traitsRequired"
                else
                    key = "traitsForbidden"
                end
            elseif c.type == "professions" then
                if c.value == true then
                    key = "professionsRequired"
                else
                    key = "professionsForbidden"
                end
            elseif c.type == "maxLimit" or c.type == "maxCharLimit" or c.type == "minCharTime" or c.type == "minTime" then
                key = "limits"
            end

            if not richTexts[key] then
                richTexts[key] = {}
            end

            -- if c.type ~= c.key then
            if not condition[c.type] then
                condition[c.type] = {}
            end
            condition[c.type][c.key] = c
            local rt = c.richText
            local len = (rt and string.len(rt)) or 0
            if len > 0 then
                table.insert(richTexts[key], rt)
            end
            if c.tooltipText and string.len(c.tooltipText) > 0 then
                table.insert(tooltips, c.tooltipText)
            end

            -- else
            --     if not condition[key] then
            --         condition[key] = {}
            --     end
            --     local rt = c.richText
            --     local len = (rt and string.len(rt)) or 0
            --     if len > 0 then
            --         table.insert(richTexts[key], rt)
            --     end
            --     if c.tooltipText and string.len(c.tooltipText) > 0 then
            --         table.insert(tooltips, c.tooltipText)
            --     end
            --     condition[key][c.type] = c
            -- end
        end

        -- format the richText (leading with price)
        local price = ""
        local rest = ""
        for k, v in pairs(richTexts or {}) do
            local header = " <SIZE:medium> <INDENT:0> <RGB:1,1,1> " ..
                               (getTextOrNull("IGUI_PhunMart.ConditionCategory." .. k) or k) .. " "
            local details = table.concat(v, " ")
            if k == "price" then
                price = price .. header .. " <TEXT>  <LINE> " .. details .. " "
            elseif string.len(details) > 1 then
                if string.len(rest) > 0 then
                    rest = rest .. " <BR> "
                end
                rest = rest .. header .. " <TEXT> <LINE> " .. details .. " "
            end
        end

        if string.len(price) == 0 then
            price =
                " <SIZE:medium> <INDENT:0>  <RGB:1,1,1> " .. getText("IGUI_PhunMart.ConditionCategory.price") .. " " ..
                    getText("IGUI_PhunMart.ConditionCategory.Free") .. " "
        end

        if string.len(rest) > 0 then
            rest = " <BR> " .. rest
        end
        richText = price .. rest

        table.insert(allRichTexts, richText)
        table.insert(allTooltips, tooltips)
        break
        -- build richtext
        -- table.insert(textResults, condition)
        -- don't support multiple condition sets yet
        -- if iteration < conditionCount then
        --     txt = txt .. " -- OR -- \n"
        -- end
        -- iteration = iteration + 1
    end

    local receives = {}
    local toolTipReceives = ""
    local selectedItem = self.selectedItem
    -- what do they receive?
    for _, r in ipairs(selectedItem.receive or {}) do
        if r.type == "TRAIT" then
            if r.tag == "REMOVE" then
                table.insert(receives,
                    " - " .. getText("IGUI_PhunMart.Receives.traitRemoved", PhunMart:getLabelFromItem(r)))
            else
                table.insert(receives,
                    " - " .. getText("IGUI_PhunMart.Receives.traitAdded", PhunMart:getLabelFromItem(r)))
            end
        else
            table.insert(receives, " - " .. getText("IGUI_PhunMart.PriceDesc", r.quantity, PhunMart:getLabelFromItem(r)))
        end

    end
    toolTipReceives = getText("IGUI_PhunMart.YouWillReceive") .. "\n" .. table.concat(receives, "\n") .. "\n\n"
    allRichTexts[1] = " <SIZE:medium> <INDENT:0> " .. getText("IGUI_PhunMart.YouWillReceive") ..
                          " <LINE> <TEXT> <INDENT:4> " .. table.concat(receives, " <LINE> <INDENT:4> ") .. " <BR> " ..
                          allRichTexts[1]

    local desc = (#allTooltips[1] > 0 and ("\n\n" .. table.concat(allTooltips[1], "\n"))) or ""
    if item.description then
        desc = desc .. "\n\n" .. item.description
    end
    self.tooltip.description = toolTipReceives .. desc

    self.richText = allRichTexts[1]
    self.rich:setText(self.richText)
    self.rich.textDirty = true;

    return self.canBuy
end

function PunMartUIPricePanel:prerender()
    ISPanel.prerender(self);
    local selection = self.selectedItem
    if selection then
        self.panel:setVisible(true)
        self:updateConditionResults()

    else
        self.panel:setVisible(false)
    end
end

function PunMartUIPricePanel:doTooltip()

    if string.len(self.tooltip.description) > 0 then
        self.tooltip:setVisible(true)
    else
        self.tooltip:setVisible(false)
    end

end

function PunMartUIPricePanel:createChildren()
    ISPanel.createChildren(self);
    self.panel = ISPanelJoypad:new(0, 0, self.width, self.height);
    self.panel.background = false
    self.panel:initialise();
    self.panel:instantiate();
    self.panel:setAnchorRight(true)
    self.panel:setAnchorLeft(true)
    self.panel:setAnchorTop(true)
    self.panel:setAnchorBottom(true)
    self.panel:setScrollChildren(true)
    self:addChild(self.panel);

    self.rich = ISRichTextPanel:new(10, 10, self.width - 20, self.height - 20);
    self.rich:initialise();
    self.rich:instantiate();
    self.rich.marginLeft = 1
    self.rich.marginTop = 1
    self.rich.marginRight = 1
    self.rich.marginBottom = 1
    self.rich.background = false
    self.rich:setText("")
    self.rich.autosetheight = false
    self.rich.clip = true
    local topLevel = self
    self.rich.render = function(self)
        ISRichTextPanel.render(self)
        if self:isMouseOver() then
            if string.len(topLevel.tooltip.description) > 0 then
                if not self.tooltip:getIsVisible() then
                    self.tooltip:setVisible(true)
                    self.tooltip:addToUIManager()
                end
            elseif self.tooltip:getIsVisible() then
                self.tooltip:setVisible(false)
                self.tooltip:removeFromUIManager()
            end
        elseif self.tooltip:getIsVisible() then
            self.tooltip:setVisible(false)
            self.tooltip:removeFromUIManager()
        end
    end
    self.rich:paginate()
    self.panel:addChild(self.rich)
    self.panel:addScrollBars()

    self.tooltip = ISToolTip:new();
    self.tooltip:initialise();
    self.tooltip:setVisible(false);
    self.tooltip:setName("Summary");
    self.tooltip:setAlwaysOnTop(true)
    self.tooltip.description = "";
    self.tooltip:setOwner(self.rich)
    self.rich.tooltip = self.tooltip
end
