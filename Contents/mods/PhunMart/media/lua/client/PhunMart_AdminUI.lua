PhunMartAdminUI = ISPanel:derive("PhunMartAdminUI");
PhunMartAdminUI.instance = nil;
local PhunMart = PhunMart
local PhunTools = PhunTools

function PhunMartAdminUI.OnOpenPanel()
    if getCore():getDebug() then
        if PhunMartAdminUI.instance == nil then
            PhunMartAdminUI.instance = PhunMartAdminUI:new(100, 100, 200, 400, getPlayer());
            PhunMartAdminUI.instance:initialise();
            PhunMartAdminUI.instance:instantiate();
        end

        PhunMartAdminUI.instance:addToUIManager();
        PhunMartAdminUI.instance:setVisible(true);

        return PhunMartAdminUI.instance;
    end
end

function PhunMartAdminUI:initialise()
    ISPanel.initialise(self);
end

function PhunMartAdminUI:createChildren()
    ISPanel.createChildren(self);
    local FONT_HGT = getTextManager():getFontHeight(UIFont.Medium);

    local x = 10
    local y = 10
    local h = 20;
    local w = self.width - 20;
    self.title = ISLabel:new(x, y, FONT_HGT, "Tools", 1, 1, 1, 1, UIFont.Medium, true);
    self.title:initialise();
    self.title:instantiate();
    self:addChild(self.title);

    y = y + h + x

    self.exportItemsButton = ISButton:new(x, y, w, h, "Export items", self, function()
        local p = getPlayer()
        local name = PhunMart.name
        local command = PhunMart.commands.rebuildExportItems
        sendClientCommand(p, name, command, {})
        PhunMartAdminUI.instance:close()
    end);
    self.exportItemsButton:initialise();
    self:addChild(self.exportItemsButton);

    y = y + h + x

    self.exportTraitsButton = ISButton:new(x, y, w, h, "Rebuild Vehicles Export", self, function()
        sendClientCommand(getPlayer(), PhunMart.name, PhunMart.commands.rebuildVehicles, {})
        PhunMartAdminUI.instance:close()
    end);
    self.exportTraitsButton:initialise();
    self:addChild(self.exportTraitsButton);

    y = y + h + x

    self.exportPerksButton = ISButton:new(x, y, w, h, "Rebuild Perks Export", self, function()
        sendClientCommand(getPlayer(), PhunMart.name, PhunMart.commands.rebuildPerks, {})
        PhunMartAdminUI.instance:close()
    end);
    self.exportPerksButton:initialise();
    self:addChild(self.exportPerksButton);

    y = y + h + x

    self.closeButton = ISButton:new(x, y, w, h, "Close", self, function()
        PhunMartAdminUI.instance:close()
    end);
    self.closeButton:initialise();
    self:addChild(self.closeButton);

end

function PhunMartAdminUI:close()
    self:setVisible(false);
    self:removeFromUIManager();
    PhunMartAdminUI.instance = nil
end

function PhunMartAdminUI:new(x, y, width, height, player)
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
    o.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
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
        a = 0.5
    };
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    return o;
end

local Commands = {}

Commands["RebuildResults"] = function(arguments)
    PhunMart:debug("Rebuilding results", arguments)
end

-- Listen for commands from the server
Events.OnServerCommand.Add(function(module, command, arguments)
    if module == PhunMart.name and Commands[command] then
        Commands[command](arguments)
    end
end)
