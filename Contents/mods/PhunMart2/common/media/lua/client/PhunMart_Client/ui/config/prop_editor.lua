if isServer() then
    return
end
local tools = require "PhunMart_Client/ui/ui_utils"
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local BUTTON_HGT = FONT_HGT_SMALL + 6
local LABEL_HGT = FONT_HGT_MEDIUM + 6

local Core = PhunMart
local profileName = "PhunMartUIPropEditor"

Core.ui.propEditor = ISPanel:derive(profileName);
Core.ui.propEditor.instances = {}
local UI = Core.ui.propEditor

local shopProperties = {
    enabled = {
        type = "boolean",
        label = "Enabled",
        tooltip = "Untick to disable this shop from spawning. This will not remove existing shops that have already been created.",
        default = true
    },
    type = {
        type = "string",
        label = "Type",
        tooltip = "A unique type that defines this shop. Cannot be edited.",
        disableOnEdit = true,
        default = ""
    },
    label = {
        type = "string",
        label = "Label",
        tooltip = "Display name of the shop. Leave blank for default.",
        default = ""
    },
    category = {
        type = "string",
        label = "Category",
        tooltip = "Category grouping for this shop (e.g. Food, Weapon, Vehicle). Used to prevent similar shops spawning too close together.",
        default = ""
    },
    defaultView = {
        type = "string",
        label = "Default View",
        tooltip = "The default display layout when a player opens this shop. Use 'grid' or 'list'. Leave blank for default (grid).",
        default = ""
    },
    probability = {
        type = "int",
        label = "Probability",
        tooltip = "The probability of this shop spawning relative to other shops. Leave blank for global defaults.",
        default = ""
    },
    minDistance = {
        type = "int",
        label = "Min Distance",
        tooltip = "Minimum tile distance between this shop and others sharing the same category. Leave blank for global defaults.",
        default = ""
    },
    currency = {
        type = "string",
        label = "Currency",
        tooltip = "Default currency for this shop. Can be overridden at pool or item level. Leave blank for global defaults.",
        default = ""
    },
    requiresPower = {
        type = "boolean",
        label = "Requires Power",
        tooltip = "Tick to require that this shop is powered in order to function.",
        default = false
    }
}

function UI:setData(data)
    data = data or {}
    local isNew = data.key == nil

    for k, v in pairs(shopProperties) do
        if v.type == "string" or v.type == "int" then
            self.controls[k]:clear()
            if data[k] == nil then
                if v.default ~= nil then
                    self.controls[k]:setText(tostring(v.default))
                end
            else
                self.controls[k]:setText(tostring(data[k]))
            end

        elseif v.type == "boolean" then
            if data[k] == nil then
                self.controls[k]:setSelected(1, v.default == true)
            else
                self.controls[k]:setSelected(1, data[k] == true)
            end

        end
        if v.disableOnEdit then
            self.controls[k]:setEditable(not isNew)
        end
    end
    self.isDirtyValue = false
end

function UI:getData()

    local data = {}
    for k, v in pairs(shopProperties) do

        if v.type == "string" then

            local str = self.controls[k]:getText():match("^%s*(.-)%s*$")

            if str ~= v.default then
                if v.isCsv then
                    data[k] = {}
                    for i in string.gmatch(str, "([^,]+)") do
                        table.insert(data[k], i)
                    end
                else

                    data[k] = str

                end
            end

        elseif v.type == "int" then
            local str = self.controls[k]:getText():gsub("%D", "")
            if str ~= "" and str ~= v.default then
                data[k] = tonumber(str)
            end
        elseif v.type == "boolean" and v.default ~= self.controls[k]:isSelected(1) then
            data[k] = self.controls[k]:isSelected(1)
        end

    end

    return data
end

function UI:isDirty()
    return self.isDirtyValue
end

function UI:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    o.player = opts.player or getPlayer()
    o.playerIndex = o.player:getPlayerNum()
    o.listType = options.type or nil
    o:setWantKeyEvents(true)
    self.instance = o;
    return o;
end

function UI:addTextInput(txt, key, tooltip, disableOnEdit)

    local y = self.lastControlY or HEADER_HGT
    local h = FONT_HGT_MEDIUM
    local x = 10

    local label = ISLabel:new(x, y, h, getTextOrNull(txt) or txt or key, 1, 1, 1, 1, UIFont.Small, true);
    label:initialise();
    label:instantiate();
    self.controls["label_" .. key] = label
    self.controls._panel:addChild(label);

    self.controls[key] = ISTextEntryBox:new("", x + 100, y, 200, h);
    self.controls[key]:initialise();
    self.controls[key].tooltip = getTextOrNull(tooltip) or tooltip or ""
    self.controls._panel:addChild(self.controls[key]);

    self.lastControlY = self.controls[key].y + self.controls[key].height + 10
end

function UI:addBool(txt, key, tooltip, disableOnEdit)

    local y = self.lastControlY or HEADER_HGT
    local h = FONT_HGT_MEDIUM
    local x = 10

    self.controls[key] = ISTickBox:new(x, y, BUTTON_HGT, BUTTON_HGT, getTextOrNull(txt) or txt or key, self)
    self.controls[key]:addOption(getTextOrNull(txt) or txt or key, nil)
    self.controls[key]:setSelected(1, true)
    self.controls[key]:setWidthToFit()
    self.controls[key]:setY(y)
    self.controls[key].tooltip = getTextOrNull(tooltip) or tooltip or ""
    self.controls._panel:addChild(self.controls[key])
    self.lastControlY = (self.lastControlY or 0) + h + 10
end

function UI:createChildren()

    ISPanel.createChildren(self)

    local offset = 10
    local x = offset
    local y = tools.HEADER_HGT
    local h = tools.FONT_HGT_MEDIUM

    self.controls = {}
    local panel = tools.getContainerPanel(0, 0, self.width - self.scrollwidth, self.height, {
        prerender = function(s)
            s:setStencilRect(0, 0, s.width, s.height);
            ISPanel.prerender(s)
        end,
        render = function(s)
            ISPanel.render(s)
            s:clearStencilRect()
        end,
        onMouseWheel = function(s, del)
            if s:getScrollHeight() > 0 then
                s:setYScroll(s:getYScroll() - (del * 40))
                return true
            end
            return false
        end
    })
    self.controls._panel = panel
    self:addChild(self.controls._panel);

    for k, v in pairs(shopProperties) do

        if v.type == "string" or v.type == "int" then
            local lbl, input = tools.getLabeledTextbox(v.label, v.tooltip, v.default, x, y)
            self.controls[k] = input
            self.controls._panel:addChild(lbl)
            self.controls._panel:addChild(input)
        elseif v.type == "boolean" then
            local chk = tools.getBool(v.label, v.tooltip, x, y)
            self.controls[k] = chk
            self.controls._panel:addChild(chk)
        end

        y = y + h + 10

    end

    panel:setScrollHeight(y + h + 10);

end

function UI:resize()
    ISPanel.resize(self)
    self.controls._panel:updateScrollbars();
end

function UI:prerender()
    ISPanel.prerender(self)

    local offset = 0
    local w = self.parent.width
    local h = self.parent.height
    local x = offset
    local y = offset

    -- self.controls._panel:setX(x)
    -- self.controls._panel:setY(y)
    -- self.controls._panel:setWidth(w)
    -- self.controls._panel:setHeight(h)
    -- self.controls._panel:updateScrollbars();

end
