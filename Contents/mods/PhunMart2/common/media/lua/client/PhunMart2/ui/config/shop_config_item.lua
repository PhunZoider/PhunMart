if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local tools = require "PhunMart2/ux/tools"
local Core = PhunMart
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local BUTTON_HGT = FONT_HGT_SMALL + 6
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

local profileName = "PhunMartUIConfigItem"
Core.ui.shop_config_item = ISCollapsableWindowJoypad:derive(profileName);
local UI = Core.ui.shop_config_item
local instances = {}

local itemProperties = {
    probability = {
        type = "int",
        label = "Probability",
        tooltip = "The probability that this item will be picked when restocking. Leave blank for defaults."
    },
    currency = {
        type = "string",
        label = "Currency",
        tooltip = "Override pool, shop and global currency values for this item."
    },
    minPrice = {
        type = "int",
        label = "Min Price",
        tooltip = "Overrides pool, shop and global min price for this item.",
        default = ""
    },
    maxPrice = {
        type = "int",
        label = "Max Price",
        tooltip = "Overrides pool, shop and global max price values for this item.",
        default = ""
    },
    minInventory = {
        type = "int",
        label = "Min Inventory",
        tooltip = "Overrides the pool, shop and global min inventory values for this item.",
        default = ""
    },
    maxInventory = {
        type = "int",
        label = "Max Inventory",
        tooltip = "Overrides the pool, shop and global max inventory values for this item.",
        default = ""
    }
}

local itemLimits = {
    maxCharPurchases = {
        type = "int",
        label = "Max Purchases",
        tooltip = "Maximum times this item can be purchased by a character.",
        default = ""
    },
    maxActPurchases = {
        type = "int",
        label = "Max Act Purchases",
        tooltip = "Maximum times this item can be purchased by an account.",
        default = ""
    },
    minCharTime = {
        type = "int",
        label = "Min Time",
        tooltip = "Minimum amount of time played before character can purchase item.",
        default = ""
    },
    minActTime = {
        type = "int",
        label = "Min Act Time",
        tooltip = "Minimum amount of time user must have played before character can purchase item.",
        default = ""
    }
}

function UI.open(player, item, cb)

    local playerIndex = player:getPlayerNum()

    local core = getCore()
    local width = 600 * FONT_SCALE
    local height = 400 * FONT_SCALE

    local x = (core:getScreenWidth() - width) / 2
    local y = (core:getScreenHeight() - height) / 2

    local instance = UI:new(x, y, width, height, player, playerIndex);
    instance.item = item
    if type(item) == "table" then
        instance.data = Core.tools.deepCopy(item)
    else
        instance.data = {}
    end

    instance:initialise();

    ISLayoutManager.RegisterWindow(profileName, UI, instance)

    instance.cb = cb
    instance:addToUIManager();
    instance:setVisible(true);
    instance:ensureVisible()
    instance:bringToTop()
    return instance;

end

function UI:new(x, y, width, height, player, playerIndex)
    local o = {};
    o = ISCollapsableWindowJoypad:new(x, y, width, height, player);
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
    o:setTitle("shop_config_item")
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

function UI:refreshAll()
    self.controls.propsSkills:clear()
    for _, v in ipairs(Core.getAllSkills()) do
        self.controls.propsSkills:addItem(v.label, v)
    end

    self.controls.propsBoosts:clear()
    for _, v in ipairs(Core.getAllSkills()) do
        self.controls.propsBoosts:addItem(v.label, v)
    end

    self.controls.propsTraits:clear()
    for _, v in ipairs(Core.getAllTraits()) do
        self.controls.propsTraits:addItem(v.label, v)
    end

    self.controls.propsProf:clear()
    for _, v in ipairs(Core.getAllProfessions()) do
        self.controls.propsProf:addItem(v.label, v)
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
    local textbox = ISTextEntryBox:new("", 120, y, 100, FONT_HGT_SMALL + 4);
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

function UI:addPropTabListbox(label, drawFn, columns)

    local y = HEADER_HGT
    local panel = ISPanel:new(0, y, self.controls.itemPropsTabs.width,
        self.controls.itemPropsTabs.height - y - self:resizeWidgetHeight());
    panel:initialise();
    panel:instantiate();
    panel:setAnchorRight(true);
    panel:setAnchorBottom(true);

    local box = ISScrollingListBox:new(0, y, panel.width, panel.height - y);
    box:initialise();
    box:instantiate();
    box.doDrawItem = drawFn;
    box.itemheight = FONT_HGT_SMALL + 6 * 2
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

    panel:addChild(box);
    self.controls.itemPropsTabs:addView(label, panel);
    local view = self.controls.itemPropsTabs.viewList[#self.controls.itemPropsTabs.viewList].view

    return box
end

function UI:createChildren()

    ISCollapsableWindowJoypad.createChildren(self);
    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()

    local padding = 10
    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    local w = self.width - 200
    local h = self.height - rh - th
    local x = padding
    local y = th

    self.controls = {}

    local panel = ISPanel:new(x, y, w, h);
    panel:initialise();
    panel:instantiate();
    panel:setAnchorRight(true);
    panel:setAnchorBottom(true);
    self:addChild(panel);
    self.controls._panel = panel;

    self.controls.itemPropsTabs = ISTabPanel:new(0, y, panel.width, panel.height);
    self.controls.itemPropsTabs:initialise();
    self.controls.itemPropsTabs:instantiate();
    self.controls.itemPropsTabs:setAnchorRight(true);
    self.controls.itemPropsTabs:setAnchorBottom(true);
    panel:addChild(self.controls.itemPropsTabs);

    local propsPanel = ISPanel:new(0, 0, self.controls.itemPropsTabs.width, self.controls.itemPropsTabs.height);
    propsPanel:initialise();
    propsPanel:instantiate();
    propsPanel:setAnchorRight(true);
    propsPanel:setAnchorBottom(true);

    self.controls.itemPropsTabs:addView("Props", propsPanel);

    local lbl, txt

    for k, v in pairs(itemProperties) do
        lbl, txt = tools.getLabeledTextbox(v.label, v.tooltip, "", x, y, 100, 300)
        self.controls[k] = txt
        propsPanel:addChild(lbl)
        propsPanel:addChild(txt)
        y = y + txt.height + 10
    end

    y = 100

    -- Skills
    local skills = self:addPropTabListbox("Skills", self.drawSkillDatas, {"Skill", "Requires"})
    skills:setOnMouseDoubleClick(self, function()
        local item = self.controls.propsSkills.items[self.controls.propsSkills.selected].item
        self:promptMinMaxSkills(item)
    end)
    self.controls.propsSkills = skills

    -- Boosts
    local boosts = self:addPropTabListbox("Boosts", self.drawBoostsDatas, {"Boost", "Requires"})
    boosts:setOnMouseDoubleClick(self, function()
        local item = self.controls.propsBoosts.items[self.controls.propsBoosts.selected].item
        self:promptMinMaxBoosts(item)
    end)
    self.controls.propsBoosts = boosts

    -- Traits
    local traits = self:addPropTabListbox("Traits", self.drawTraitDatas, {"Trait", "Requires"})
    traits:setOnMouseDoubleClick(self, self.toggleTraitRequirement)
    traits.onRightMouseUp = function(target, x, y, a, b)
        local row = target:rowAt(x, y)
        if row == -1 then
            return
        end
        if target.selected ~= row then
            target.selected = row
            target:ensureVisible(target.selected)
        end
        local item = target.items[target.selected].item

        if item then
            local context = ISContextMenu.get(self.playerIndex, target:getAbsoluteX() + x,
                target:getAbsoluteY() + y + target:getYScroll())
            context:removeFromUIManager()
            context:addToUIManager()

            context:addOption("Required", self, function()
                if self.data.traits == nil then
                    self.data.traits = {}
                end
                self.data.traits[item.type] = true
            end, item)
            context:addOption("Forbidden", self, function()
                if self.data.traits == nil then
                    self.data.traits = {}
                end
                self.data.traits[item.type] = false
            end, item)
            context:addOption("No restriction", self, function()
                if self.data.traits == nil then
                    self.data.traits = {}
                end
                self.data.traits[item.type] = nil
            end, item)
        end
    end
    self.controls.propsTraits = traits

    -- Professions
    local profs = self:addPropTabListbox("Professions", self.drawProfDatas, {"Profession", "Requires"})
    profs:setOnMouseDoubleClick(self, self.toggleProfRequirement)
    profs.onRightMouseUp = function(target, x, y, a, b)
        local row = target:rowAt(x, y)
        if row == -1 then
            return
        end
        if target.selected ~= row then
            target.selected = row
            target:ensureVisible(target.selected)
        end
        local item = target.items[target.selected].item

        if item then
            local context = ISContextMenu.get(self.playerIndex, target:getAbsoluteX() + x,
                target:getAbsoluteY() + y + target:getYScroll())
            context:removeFromUIManager()
            context:addToUIManager()

            context:addOption("Required", self, function()
                if self.data.professions == nil then
                    self.data.professions = {}
                end
                self.data.professions[item.type] = true
            end, item)
            context:addOption("Forbidden", self, function()
                if self.data.professions == nil then
                    self.data.professions = {}
                end
                self.data.professions[item.type] = false
            end, item)
            context:addOption("No restriction", self, function()
                if self.data.professions == nil then
                    self.data.professions = {}
                end
                self.data.professions[item.type] = nil
            end, item)
        end
    end
    self.controls.propsProf = profs

    -- Limits
    self.controls.purchaseLimitsPanel = ISPanel:new(0, 0, self.controls.itemPropsTabs.width,
        self.controls.itemPropsTabs.height);
    self.controls.purchaseLimitsPanel:initialise();
    self.controls.purchaseLimitsPanel:instantiate();
    self.controls.purchaseLimitsPanel:setAnchorRight(true);
    self.controls.purchaseLimitsPanel:setAnchorBottom(true);
    self.controls.itemPropsTabs:addView("Purchase Limits", self.controls.purchaseLimitsPanel);

    y = 20
    for k, v in pairs(itemLimits) do
        lbl, txt = tools.getLabeledTextbox(v.label, v.tooltip, "", x, y, 100, 300)
        self.controls[k] = txt
        self.controls.purchaseLimitsPanel:addChild(lbl)
        self.controls.purchaseLimitsPanel:addChild(txt)
        y = y + txt.height + 10
    end

    x = self.controls._panel.width + padding
    y = th
    local infoPanel = ISPanel:new(x, y, 200, h);
    infoPanel:initialise();
    infoPanel:instantiate();
    infoPanel:setAnchorBottom(true);
    self:addChild(infoPanel);
    self.controls.infoPanel = infoPanel;

    local previewPanel = nil
    local lblY = 200

    if self.item.source == "vehicles" then
        previewPanel = ISUI3DScene:new(10, 10, 180, 180)
        previewPanel:initialise()
        previewPanel.onMouseMove = function(self, dx, dy)
            if self.mouseDown then
                local vector = self:getRotation()
                local x = vector:x() + dy
                x = x > 90 and 90 or x < -90 and -90 or x
                self:setRotation(x, vector:y() + dx)
            end
        end
        previewPanel.setRotation = function(self, x, y)
            self.javaObject:fromLua3("setViewRotation", x, y, 0)
        end
        previewPanel.getRotation = function(self)
            return self.javaObject:fromLua0("getViewRotation")
        end
        infoPanel:addChild(previewPanel);
        self.controls.previewPanel = previewPanel;
    elseif self.item.texture then
        previewPanel = ISPanel:new(10, 10, 180, 180);
        previewPanel:initialise();
        previewPanel:instantiate();

        previewPanel.render = function(self)
            local item = self.parent.parent.item
            if item.texture then
                self:drawTextureScaledAspect(item.texture, 0, 0, self:getWidth(), self:getHeight(), 1)
            end
        end
        infoPanel:addChild(previewPanel);
        self.controls.previewPanel = previewPanel;
    else
        lblY = 10
    end

    local label = getTextManager():WrapText(UIFont.Medium, self.item.label, infoPanel.width - 20)

    local name = ISLabel:new(10, lblY, FONT_HGT_MEDIUM, label, 1, 1, 1, 1, UIFont.Medium, true);
    name:initialise();
    name:instantiate();
    infoPanel:addChild(name);
    self.controls.name = name;

    local category = ISLabel:new(10, name.y + name.height + 10, FONT_HGT_SMALL, self.item.category, 1, 1, 1, 1,
        UIFont.Small, true);
    category:initialise();
    category:instantiate();
    infoPanel:addChild(category);
    self.controls.category = category;

    local save = ISButton:new(padding, infoPanel.height - BUTTON_HGT, infoPanel.width - (padding * 2), BUTTON_HGT,
        "Save", self, UI.onSave);
    save:initialise();
    save:instantiate();
    if save.enableAcceptColor then
        save:enableAcceptColor()
    end
    save:setAnchorRight(true);
    save:setAnchorBottom(true);
    infoPanel:addChild(save);
    self.controls.save = save;

    local y = category.y + category.height + 10
    local description = ISRichTextPanel:new(padding, y, infoPanel.width - (padding * 2), save.y - y - 20);
    description:initialise();
    description:instantiate();
    description.borderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 1
    };
    description.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    };
    description:setMargins(10, 10, 10, 10);
    description:setAnchorRight(true);
    description:setAnchorBottom(true);
    description.autosetheight = false
    description:setText("")
    description:paginate()
    infoPanel:addChild(description);
    self.controls.description = description;

    self:refreshAll()
end

function UI:onSave()
    print("Saving item config")

    local data = {}
    for k, v in pairs(itemProperties) do
        local value = self.controls[k]:getText()
        if value ~= "" then
            if v.type == "int" then
                value = tonumber(value)
            elseif v.type == "string" then
                value = value:match("^%s*(.-)%s*$")
            end
            data[k] = value
        end
    end

    for k, v in pairs(itemLimits) do
        local value = self.controls[k]:getText()
        if value ~= "" then
            if v.type == "int" then
                value = tonumber(value)
            elseif v.type == "string" then
                value = value:match("^%s*(.-)%s*$")
            end
            data[k] = value
        end
    end

    -- skills
    if self.data.skills then
        local d = {}
        local add = false
        for k, v in pairs(self.data.skills) do
            if v.min and v.max then
                d[k] = v
                add = true
            elseif v.min then
                d[k] = {
                    min = v.min,
                    max = v.max
                }
                add = true
            elseif v.max then
                d[k] = {
                    min = 0,
                    max = v.max
                }
                add = true
            end
        end
        if add then
            data.skills = d
        end
    end

    -- boosts
    if self.data.boosts then
        local d = {}
        local add = false
        for k, v in pairs(self.data.boosts) do
            if v.min and v.max then
                d[k] = v
                add = true
            elseif v.min then
                d[k] = {
                    min = v.min,
                    max = v.max
                }
                add = true
            elseif v.max then
                d[k] = {
                    min = 0,
                    max = v.max
                }
                add = true
            end
        end
        if add then
            data.boosts = d
        end
    end

    -- boosts
    if self.data.traits then
        local d = {}
        local add = false
        for k, v in pairs(self.data.traits) do
            if v == true then
                d[k] = true
                add = true
            elseif v == false then
                d[k] = false
                add = true
            end
        end
        if add then
            data.traits = d
        end
    end

    -- boosts
    if self.data.professions then
        local d = {}
        local add = false
        for k, v in pairs(self.data.professions) do
            if v == true then
                d[k] = true
                add = true
            elseif v == false then
                d[k] = false
                add = true
            end
        end
        if add then
            data.professions = d
        end
    end

    -- if there are no properties set, return nil
    if next(data) == nil then
        self.cb(nil)
    else
        self.cb(data)
    end
    self:close()

end

function UI:instantiate()
    ISCollapsableWindowJoypad.instantiate(self);
    if self.item.source == "vehicles" then
        local previewPanel = self.controls.previewPanel
        previewPanel.initialized = true
        previewPanel.javaObject:fromLua1("setDrawGrid", false)
        previewPanel.javaObject:fromLua1("createVehicle", "vehicle")
        previewPanel.javaObject:fromLua3("setViewRotation", 45 / 2, 45, 0)
        previewPanel.javaObject:fromLua1("setView", "UserDefined")
        previewPanel.javaObject:fromLua2("dragView", 0, 30)
        previewPanel.javaObject:fromLua1("setZoom", 6)
        previewPanel.vehicleName = self.item.type
        previewPanel.javaObject:fromLua2("setVehicleScript", "vehicle", previewPanel.vehicleName)
    end

end

function UI:setSelectedItem()

    local item = self.list.items[self.list.selected].item
    local data = self.data[self.list.selected]

    self.controls.propsSkills:clear()
    for _, v in ipairs(Core.getAllSkills()) do
        self.controls.propsSkills:addItem(v.label, v)
    end

    self.controls.propsBoosts:clear()
    for _, v in ipairs(Core.getAllSkills()) do
        self.controls.propsBoosts:addItem(v.label, v)
    end

    self.controls.propsTraits:clear()
    for _, v in ipairs(Core.getAllTraits()) do
        self.controls.propsTraits:addItem(v.label, v)
    end

    self.controls.propsProf:clear()
    for _, v in ipairs(Core.getAllProfessions()) do
        self.controls.propsProf:addItem(v.label, v)
    end

end

function UI:promptMinMaxSkills(item)

    local list = self.controls.propsSkills
    if self.data.skills == nil then
        self.data.skills = {}
    end
    local data = {}
    if self.data.skills[item.type] then
        data = self.data.skills[item.type]
    end
    Core.ui.minmax.open(self.player, item, {
        minMin = 0,
        maxMax = 10
    }, function(data)
        local s = self
        if self.data.skills == nil then
            self.data.skills = {}
        end
        if data.min or data.max then
            self.data.skills[item.type] = data
        else
            self.data.skills[item.type] = nil
        end
    end)
end

function UI:promptMinMaxBoosts(item)

    local list = self.controls.propsboosts
    if self.data.boosts == nil then
        self.data.boosts = {}
    end
    local data = {}
    if self.data.boosts[item.type] then
        data = self.data.boosts[item.type]
    end
    Core.ui.minmax.open(self.player, data, {
        minMin = 0,
        maxMax = 3
    }, function(data)
        local s = self
        if self.data.boosts == nil then
            self.data.boosts = {}
        end
        if data.min or data.max then
            self.data.boosts[item.type] = data
        else
            self.data.boosts[item.type] = nil
        end
    end)
end

function UI:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    if item.item.texture then
        local textured = self:drawTextureScaledAspect2(item.item.texture, xoffset, y, self.itemheight - 4,
            self.itemheight - 4, 1, 1, 1, 1)
        xoffset = xoffset + self.itemheight + 4
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.text, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local value = item.item.category

    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:drawSkillDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    if item.item.texture then
        local textured = self:drawTextureScaledAspect2(item.item.texture, xoffset, y, self.itemheight - 4,
            self.itemheight - 4, 1, 1, 1, 1)
        xoffset = xoffset + self.itemheight + 4
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item.label or item.item.type, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local value = ""
    local data = self.parent.parent.parent.parent.data
    if data.skills and data.skills[item.item.type] then
        if data.skills[item.item.type].min and data.skills[item.item.type].max then
            value = "Min: " .. data.skills[item.item.type].min .. " Max: " .. data.skills[item.item.type].max
        elseif data.skills[item.item.type].min then
            value = "Min: " .. data.skills[item.item.type].min
        elseif data.skills[item.item.type].max then
            value = "Max: " .. data.skills[item.item.type].max
        end
    end

    local cw = self.columns[2].size
    self:drawText(value, cw + 10, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:drawBoostsDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    if item.item.texture then
        local textured = self:drawTextureScaledAspect2(item.item.texture, xoffset, y, self.itemheight - 4,
            self.itemheight - 4, 1, 1, 1, 1)
        xoffset = xoffset + self.itemheight + 4
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item.label or item.item.type, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local value = ""
    local data = self.parent.parent.parent.parent.data
    if data.boosts and data.boosts[item.item.type] then
        if data.boosts[item.item.type].min and data.boosts[item.item.type].max then
            value = "Min: " .. data.boosts[item.item.type].min .. " Max: " .. data.boosts[item.item.type].max
        elseif data.boosts[item.item.type].min then
            value = "Min: " .. data.boosts[item.item.type].min
        elseif data.boosts[item.item.type].max then
            value = "Max: " .. data.boosts[item.item.type].max
        end
    end

    local cw = self.columns[2].size
    self:drawText(value, cw + 10, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:drawTraitDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local value = nil
    local data = self.parent.parent.parent.parent.data.traits
    if data and data[item.item.type] ~= nil then
        if data[item.item.type] then
            value = "Required"
            self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.4, 0, 0.7, 0.15);
        else
            value = "Forbidden"
            self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.4, 1, 0, 0.15);
        end
    end

    local a = 0.9;

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    if item.item.texture then
        local textured = self:drawTextureScaledAspect2(item.item.texture, xoffset, y, self.itemheight - 4,
            self.itemheight - 4, 1, 1, 1, 1)
        xoffset = xoffset + self.itemheight + 4
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item.label or item.item.type, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local cw = self.columns[2].size
    self:drawText(value or "", cw + 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:drawProfDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local value = nil
    local data = self.parent.parent.parent.parent.data.professions
    if data and data[item.item.type] ~= nil then
        if data[item.item.type] then
            value = "Required"
            self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.4, 0, 0.7, 0.15);
        else
            value = "Forbidden"
            self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.4, 1, 0, 0.15);
        end
    end

    local a = 0.9;

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    if item.item.texture then
        local textured = self:drawTextureScaledAspect2(item.item.texture, xoffset, y, self.itemheight - 4,
            self.itemheight - 4, 1, 1, 1, 1)
        xoffset = xoffset + self.itemheight + 4
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item.label or item.item.type, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local cw = self.columns[2].size
    self:drawText(value or "", cw + 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:prerender()

    ISCollapsableWindowJoypad.prerender(self);

    self.controls.infoPanel:setX(self.width - self.controls.infoPanel.width)
    self.controls.save:setHeight(BUTTON_HGT)
    self.controls.save:setY(self.controls.infoPanel.height - BUTTON_HGT - 10)

    -- self.controls.propsSkills:setY(30)
    if self.lastActiveViewName ~= self.controls.itemPropsTabs.activeView.name then

        self.lastActiveViewName = self.controls.itemPropsTabs.activeView.name
        local txt = ""
        if self.controls.itemPropsTabs.activeView.name == "Skills" then
            txt =
                "Skills: Double click to set min/max levels required to purchase this item. Leave the value blank to ignore."
        elseif self.controls.itemPropsTabs.activeView.name == "Boosts" then
            txt =
                "Boosts: Double click to set min/max levels required to purchase this item. Leave the value blank to ignore."
        elseif self.controls.itemPropsTabs.activeView.name == "Traits" then
            txt =
                "Traits: Right click to set if the trait is required, forbidden or no restriction. You can also toggle between states by double clicking"
        elseif self.controls.itemPropsTabs.activeView.name == "Professions" then
            txt =
                "Professions: Right click to set if the profession is required, forbidden or no restriction. You can also toggle between states by double clicking"
        elseif self.controls.itemPropsTabs.activeView.name == "Purchase Limits" then
            txt =
                "Purchase Limits: Set the limits to how many times this item can be purchased. Leave the value blank to ignore."
        elseif self.controls.itemPropsTabs.activeView.name == "Props" then
            txt =
                "Props: Set the min/max price, currency, inventory and probability of this item. Leave blank to use defaults"
        end

        self.controls.description:setText(txt)
        self.controls.description:paginate()
        self.controls.description.textDirty = true;

    end

end

function UI:toggleTraitRequirement(item)
    self:toggleRequirement("traits", item)
end

function UI:toggleProfRequirement(item)
    self:toggleRequirement("professions", item)
end

function UI:toggleRequirement(source, item)

    if not self.data[source] then
        self.data[source] = {}
    end

    if self.data[source][item.type] == nil then
        self.data[source][item.type] = true
    elseif self.data[source][item.type] == true then
        self.data[source][item.type] = false
    else
        self.data[source][item.type] = nil
    end
end
