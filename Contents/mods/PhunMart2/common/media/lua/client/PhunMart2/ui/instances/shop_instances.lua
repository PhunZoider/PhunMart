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

local profileName = "PhunMartUIShopInstances"

Core.ui.shop_instances = ISCollapsableWindowJoypad:derive(profileName);
local UI = Core.ui.shop_instances
local instances = {}

local pz = nil

function UI:refreshAll()

    if pz == nil then
        pz = PhunZones or false
    end
    self.controls.list:clear()

    local px, py = self.player:getX(), self.player:getY()
    local data = {}
    for k, v in pairs(Core.instances or {}) do

        if self.shopKey == nil or self.shopKey == v.key then
            table.insert(data, {
                key = k,
                group = ((Core.defs and Core.defs.shops or Core.shops)[v.key] or {}).category or "NONE",
                -- texture = v.sprites and v.sprites[1] or nil,
                location = {
                    x = v.x,
                    y = v.y,
                    z = v.z
                },
                label = (pz and (pz:getLocation(v.x, v.y).title .. " ") or "") .. "(" .. v.x .. ", " .. v.y .. ")",
                distance = math.sqrt((v.x - px) ^ 2 + (v.y - py) ^ 2)
            })
        end

    end

    table.sort(data, function(a, b)
        return a.distance < b.distance
    end)

    for _, v in ipairs(data) do
        self.controls.list:addItem(v.label, v)
    end
end

function UI.open(player, shopKey)

    local playerIndex = player:getPlayerNum()

    local core = getCore()
    local width = 300 * FONT_SCALE
    local height = 300 * FONT_SCALE

    local x = (core:getScreenWidth() - width) / 2
    local y = (core:getScreenHeight() - height) / 2

    local instance = UI:new(x, y, width, height, player, playerIndex, shopKey);
    instance:initialise();

    ISLayoutManager.RegisterWindow(profileName, UI, instance)

    instance.shopKey = shopKey or nil
    instance:addToUIManager();
    instance:setVisible(true);
    instance:ensureVisible()
    instance:refreshAll()
    return instance;
end

function UI:new(x, y, width, height, player, playerIndex, shopKey)
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
    o.shopKey = shopKey
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o:setWantKeyEvents(true)
    local title = getTextOrNull("IGUI_PhunMart_Shop_" .. shopKey) or shopKey or "Locations"
    o:setTitle(title)
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

function UI:createChildren()

    ISCollapsableWindowJoypad.createChildren(self);

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()

    local padding = 10
    local x = 0
    local y = th
    local w = self.width
    local h = self.height - rh - th

    self.controls = {}

    local panel = ISPanel:new(x, y, w, h);
    panel:initialise();
    panel:instantiate();
    self:addChild(panel);
    self.controls._panel = panel;

    local listPanel = ISPanel:new(0, 0, w, h - BUTTON_HGT + 20);
    listPanel:initialise();
    listPanel:instantiate();
    self.controls._panel:addChild(listPanel);
    self.controls._listPanel = listPanel;

    local controlPanel = ISPanel:new(0, listPanel:getHeight() - BUTTON_HGT + 20, w, BUTTON_HGT + 20);
    controlPanel:initialise();
    controlPanel:instantiate();
    controlPanel:setAnchorRight(true)
    controlPanel:setAnchorLeft(true)
    controlPanel:setAnchorTop(true)
    controlPanel:setAnchorBottom(true)
    self.controls._panel:addChild(controlPanel);
    self.controls._controlPanel = controlPanel;

    local list = ISScrollingListBox:new(0, HEADER_HGT, w, h);
    list:initialise();
    list:instantiate();
    list.itemheight = FONT_HGT_SMALL + 6 * 2
    list.selected = 0;
    list.joypadParent = self;
    list.font = UIFont.NewSmall;
    list.doDrawItem = self.drawDatas;
    list.onMouseUp = function(list, x, y)
        local row = list:rowAt(x, y)
        if row == nil or row == -1 then
            return
        end
        list:ensureVisible(row)
        local item = list.items[row].item
        list.selected = row
    end

    list.onRightMouseUp = function(target, x, y, a, b)
        local row = target:rowAt(x, y)
        if row == -1 then
            return
        end
        if self.selected ~= row then
            self.selected = row
            target.selected = row
            target:ensureVisible(target.selected)
        end
        local item = target.items[target.selected].item

    end
    list.drawBorder = true;
    list.onMouseMove = self.doOnMouseMove
    list.onMouseMoveOutside = self.doOnMouseMoveOutside

    list.onMouseDoubleClick = function()
        if self.controls.list.selected and self.controls.list.selected > 0 and
            self.controls.list.items[self.controls.list.selected] then
            local item = self.controls.list.items[self.controls.list.selected].item
            self:doPort(item.location.x, item.location.y, item.location.z or 0)
        end
    end

    list:addColumn("Shop", 0);
    list:addColumn("Group", 150);
    self.controls.list = list;
    self.controls._listPanel:addChild(list);

    local btnPort = ISButton:new(0, 10, 100, BUTTON_HGT, "Port", self, function()
        if self.controls.list.selected and self.controls.list.selected > 0 and
            self.controls.list.items[self.controls.list.selected] then
            local item = self.controls.list.items[self.controls.list.selected].item
            self:doPort(item.location.x, item.location.y, item.location.z or 0)
        end
    end);
    btnPort.internal = "EDIT";
    btnPort:initialise();
    btnPort:instantiate();
    btnPort:setEnable(false);
    self.controls.btnPort = btnPort;
    self.controls._controlPanel:addChild(btnPort);

    self:refreshAll()
end

function UI:prerender()
    ISCollapsableWindowJoypad.prerender(self)

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()

    -- container
    self.controls._panel:setWidth(self.width)
    self.controls._panel:setHeight(self.height - rh - th)

    -- list container
    self.controls._listPanel:setWidth(self.controls._listPanel.parent.width)
    self.controls._listPanel:setHeight(self.controls._listPanel.parent.height - self.controls._controlPanel.height)

    -- list
    self.controls.list:setWidth(self.controls.list.parent.width)
    self.controls.list:setHeight(self.controls.list.parent.height - HEADER_HGT)
    self.controls.list.columns[2].size = self.controls.list.width / 2

    -- control container
    self.controls._controlPanel:setWidth(self.controls._controlPanel.parent.width)
    self.controls._controlPanel:setHeight(BUTTON_HGT + 20)
    self.controls._controlPanel:setY(self.controls._controlPanel.parent.height - self.controls._controlPanel.height)

    -- port button
    self.controls.btnPort:setX(self.controls.btnPort.parent.width - self.controls.btnPort.width - 10)
    self.controls.btnPort:setEnable(self.controls.list.selected > 0)

end

function UI:drawDatas(y, item, alt)

    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15);
    end

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
        local textured = self:drawTextureScaledAspect(item.item.texture, xoffset, y, self.itemheight - 4,
            self.itemheight - 4, 1, 1, 1, 1)
        xoffset = xoffset + self.itemheight + 4
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.text, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local value = Core.tools.formatWholeNumber(item.item.distance) .. "m"

    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:doPort(destinationX, destinationY, destinationZ)

    local player = self.player
    player:setX(destinationX)
    player:setY(destinationY)
    player:setZ(destinationZ)
    if player.setLx then
        player:setLx(destinationX)
        player:setLy(destinationY)
        player:setLz(destinationZ)
    else
        player:setLastX(destinationX)
        player:setLastY(destinationY)
        player:setLastZ(destinationZ)
        getWorld():update()
    end
    local retries = 100
    local playerPorting
    playerPorting = function()
        -- wait for square to load
        local square = player:getCurrentSquare()
        if square == nil then
            return
        end
        retries = retries - 1
        if retries <= 0 then
            player:Say("Failed to port")
            Events.OnPlayerUpdate.Remove(playerPorting)
            return
        end

        local free = AdjacentFreeTileFinder.FindClosest(square, player)
        if free then
            Events.OnPlayerUpdate.Remove(playerPorting)
            player:setX(destinationX)
            player:setY(destinationY)
            player:setZ(destinationZ)
            if player.setLx then
                player:setLx(destinationX)
                player:setLy(destinationY)
                player:setLz(destinationZ)
            else
                player:setLastX(destinationX)
                player:setLastY(destinationY)
                player:setLastZ(destinationZ)
                getWorld():update()
            end

        end

    end
    Events.OnPlayerUpdate.Add(playerPorting)
end
