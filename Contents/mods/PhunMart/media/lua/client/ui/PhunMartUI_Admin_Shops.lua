if isServer() then
    return
end
require "ISUI/ISCollapsableWindowJoypad"
local PM = PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

PhunMartUIAdminShops = ISCollapsableWindowJoypad:derive("PhunMartUIAdminShops");
PhunMartUIAdminShops.instances = {}
local UI = PhunMartUIAdminShops

function UI.OnOpenPanel(playerObj, playerIndex)

    playerIndex = playerIndex or playerObj:getPlayerNum()

    if not UI.instances[playerIndex] then
        local core = getCore()
        local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 14
        local width = 300 * FONT_SCALE
        local height = 590 * FONT_SCALE

        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2

        UI.instances[playerIndex] = UI:new(x, y, width, height, playerObj, playerIndex);
        UI.instances[playerIndex]:initialise();
        sendClientCommand(PM.name, PM.commands.requestShopDefs, {})
        sendClientCommand(PM.name, PM.commands.requestItemDefs, {})
        ISLayoutManager.RegisterWindow('PhunMartUIAdminShops', PhunMartUIAdminShops,
            PhunMartUIAdminShops.instances[playerIndex])
    end

    UI.instances[playerIndex]:addToUIManager();
    UI.instances[playerIndex]:setVisible(true);
    UI.instances[playerIndex]:ensureVisible()

    return UI.instances[playerIndex];

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
    o:setTitle("Machine Locations")
    return o;
end

function UI:RestoreLayout(name, layout)

    ISLayoutManager.DefaultRestoreWindow(self, layout)
    if name == "PhunMartUIAdminItem" then
        ISLayoutManager.DefaultRestoreWindow(self, layout)
        self.userPosition = layout.userPosition == 'true'
    end
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
    local x = padding
    local y = th + padding
    local w = self.width - padding * 2
    local h = self.height - y - rh - padding

    self.page = ISComboBox:new(x, y, self:getWidth() - (padding * 2), FONT_HGT_MEDIUM, self, function()
        local data = self.page.options[self.page.selected].data

        self.properties:setData(data)
        self.reservations:setData(data)
        self.sprites:setData(data)
        self.pools:setData(data)
        if data and data.key then
            sendClientCommand(PM.name, PM.commands.requestLocations, {
                playerIndex = self.playerIndex,
                key = data.key
            })
        end
    end);
    self.page:initialise()
    self:addChild(self.page)

    y = y + self.page.height + padding

    self.tabPanel = ISTabPanel:new(x, y, w, h - self.page.height - padding);
    self.tabPanel:initialise()
    self:addChild(self.tabPanel)

    self.properties = PhunMartUIShopProps:new(0, 100, self.tabPanel.width,
        self.tabPanel.height - self.tabPanel.tabHeight, {
            player = self.player
        });
    self.tabPanel:addView("Properties", self.properties)

    self.pools = PhunMartUIAdminPools:new(0, 100, self.tabPanel.width, self.tabPanel.height - self.tabPanel.tabHeight, {
        player = self.player
    });
    self.tabPanel:addView("Pools", self.pools)

    self.locations = PhunMartUIAdminLocations:new(0, 100, self.tabPanel.width,
        self.tabPanel.height - self.tabPanel.tabHeight, {
            player = self.player
        });

    self.tabPanel:addView("Locations", self.locations)

    self.reservations = PhunMartUIShopReservations:new(0, 100, self.tabPanel.width,
        self.tabPanel.height - self.tabPanel.tabHeight, {
            player = self.player
        });
    self.tabPanel:addView("Reservations", self.reservations)

    self.sprites = PhunMartUIShopSprites:new(0, 100, self.tabPanel.width,
        self.tabPanel.height - self.tabPanel.tabHeight, {
            player = self.player
        });
    self.tabPanel:addView("Sprites", self.sprites)

end

function UI:prerender()

    ISCollapsableWindowJoypad.prerender(self);

end

function UI:refreshShops(shops)
    self.page:clear()
    local data = {}
    for k, v in pairs(shops) do
        if v.abstract ~= true then
            table.insert(data, v)
        end
    end
    table.sort(data, function(a, b)
        return a.label < b.label
    end)
    self.page:addOption(" -- SHOP -- ")
    for _, v in ipairs(data) do
        if v.abstract ~= true then
            self.page:addOptionWithData(v.label .. " (" .. v.key .. ")", v)
        end
    end
end

local zones = nil

function UI:refreshLocations(instances)
    self.locations:setData(instances)
end

function UI:refreshItems(items)
    self.pools:setItems(items)
end

