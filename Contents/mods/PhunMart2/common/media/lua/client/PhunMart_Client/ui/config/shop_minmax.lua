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

local profileName = "PhunMartUIMinMax"
Core.ui.minmax = ISPanel:derive(profileName);
local UI = Core.ui.minmax

function UI:setData(data)

end

function UI.open(player, data, acceptableRanges, cb)

    local playerIndex = player:getPlayerNum()

    local core = getCore()
    local width = 200 * FONT_SCALE
    local height = 100 * FONT_SCALE

    local x = (core:getScreenWidth() - width) / 2
    local y = (core:getScreenHeight() - height) / 2

    local instance = UI:new(x, y, width, height, player, playerIndex);
    instance:initialise();

    ISLayoutManager.RegisterWindow(profileName, UI, instance)

    instance:addToUIManager();
    instance:setVisible(true);
    instance.acceptableRanges = acceptableRanges
    data = data or {}
    instance.data = {
        min = tostring(data.min) or "",
        max = tostring(data.max) or ""
    }
    instance.cb = cb
    instance:setAlwaysOnTop(true);
    return instance;

end

function UI:new(x, y, width, height, player, playerIndex)
    local o = {};
    o = ISPanel:new(x, y, width, height, player);
    setmetatable(o, self);
    self.__index = self;

    o.variableColor = {
        r = 0.9,
        g = 0.55,
        b = 0.1,
        a = 1
    };
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    };
    o.buttonBorderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 1
    };
    o.controls = {}
    o.data = {}
    o.moveWithMouse = false;
    o.anchorRight = true
    o.anchorBottom = true
    o.player = player
    o.playerIndex = playerIndex
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o:setWantKeyEvents(true)
    return o;
end

function UI:RestoreLayout(name, layout)

    -- ISLayoutManager.DefaultRestoreWindow(self, layout)
    -- if name == profileName then
    --     ISLayoutManager.DefaultRestoreWindow(self, layout)
    --     self.userPosition = layout.userPosition == 'true'
    -- end
    self:recalcSize();
end

function UI:SaveLayout(name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    if self.userPosition then
        layout.userPosition = 'true'
    else
        layout.userPosition = 'false'
    end
end

function UI:close()
    if not self.locked then
        ISCollapsableWindowJoypad.close(self);
    end
end

function UI:addLabel(text, parent, y)
    local label = ISLabel:new(10, y, FONT_HGT_SMALL, text, 1, 1, 1, 1, UIFont.Small, true);
    label:initialise();
    label:instantiate();
    parent:addChild(label);
    return label;
end

function UI:addTextbox(name, text, tooltip, parent, y)
    local textbox = ISTextEntryBox:new("", 100, y, 100, FONT_HGT_SMALL + 4);
    textbox:initialise();
    textbox:instantiate();
    textbox:setTooltip(tooltip)
    parent:addChild(textbox);
    self.controls[name] = textbox
    return textbox;
end

function UI:addLabeledTextbox(name, text, tooltip, parent, y)
    self:addLabel(text, parent, y)
    return self:addTextbox(name, text, tooltip, parent, y)
end

function UI:createChildren()
    ISPanel:createChildren(self);

    local min = self:addLabeledTextbox("min", "Min", "Minimum value", self, 20)
    local max = self:addLabeledTextbox("max", "Max", "Maximum value", self, 20 + FONT_HGT_SMALL + 4 + 10)

    local accept = ISButton:new(10, self.height - 10 - FONT_HGT_SMALL - 4, 100, FONT_HGT_SMALL + 4, "Accept", self,
        UI.onAccept);
    accept:initialise();
    accept:instantiate();
    if accept.enableAcceptColor then
        accept:enableAcceptColor()
    end
    self:addChild(accept);

    local cancel = ISButton:new(self.width - 10 - 100, self.height - 10 - FONT_HGT_SMALL - 4, 100, FONT_HGT_SMALL + 4,
        "Cancel", self, UI.onCancel);
    cancel:initialise();
    cancel:instantiate();
    if cancel.enableCancelColor then
        cancel:enableCancelColor()
    end
    self:addChild(cancel);
end

function UI:onAccept()

    local min = tonumber(string.match(self.controls.min:getText(), "%d+") or 0)
    local max = tonumber(string.match(self.controls.max:getText(), "%d+") or 0)

    if min == 0 then
        min = nil
    end
    if max == 0 then
        max = nil
    end
    if max ~= nil and max > self.acceptableRanges.maxMax then
        max = self.acceptableRanges.maxMax
    end

    self.cb({
        min = min,
        max = max
    })
    self:close()

end

function UI:onCancel()
    self:close()
end
