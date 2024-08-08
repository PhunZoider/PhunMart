if not isClient() then
    return
end
require "ISUI/ISPanel"
PhunMartUIItemPreviewPanel = ISPanelJoypad:derive("PhunMartUIItemPreviewPanel");
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14

function PhunMartUIItemPreviewPanel:new(x, y, width, height, options)
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
    o.tabFont = opts.tabFont or UIFont.Medium
    o.selectedItem = {}
    PhunMartUIItemPreviewPanel.instance = o;
    return o;
end

function PhunMartUIItemPreviewPanel:initialise()
    ISPanel.initialise(self);
end

function PhunMartUIItemPreviewPanel:createChildren()
    ISPanel.createChildren(self);
    self.panel = ISPanel:new(0, 0, self.width, self.height);
    -- self.panel.backgroundColor = self.backgroundColor;

    self.panel:initialise();
    self.panel:instantiate();
    self.panel.background = false
    self:addChild(self.panel);

    self.previewPanel = ISPanel:new(0, 0, self.width, self.height)
    self.previewPanel.background = false
    self.previewPanel:initialise()
    self.previewPanel.render = function(self)
        if self.texture then
            self:drawTextureScaledAspect(self.texture, 0, 0, self:getWidth(), self:getHeight(), 1)
        end
        if self.overlay then
            self:drawTextureScaledAspect(self.overlay, 0, 0, self:getWidth(), self:getHeight(), 1)
        end
    end
    self.panel:addChild(self.previewPanel)
    self.previewPanel.background = false
    self.previewPanel3d = ISUI3DScene:new(0, 0, self.width, self.height)
    self.previewPanel3d:initialise()
    self.previewPanel3d.onMouseMove = function(self, dx, dy)
        if self.mouseDown then
            local vector = self:getRotation()
            local x = vector:x() + dy
            x = x > 90 and 90 or x < -90 and -90 or x
            self:setRotation(x, vector:y() + dx)
        end
    end

    self.previewPanel3d.setRotation = function(self, x, y)
        self.javaObject:fromLua3("setViewRotation", x, y, 0)
    end
    self.previewPanel3d.getRotation = function(self)
        return self.javaObject:fromLua0("getViewRotation")
    end

    self.panel:addChild(self.previewPanel3d)

    -- self.previewPanel:setVisible(false)
    -- self.previewPanel3d:setVisible(false)

end

function PhunMartUIItemPreviewPanel:setItem(item, display)
    self.selectedItem = item
    if item then
        self.previewPanel3d:setVisible(item.display.type == "VEHICLE")
        self.previewPanel:setVisible(item.display.type ~= "VEHICLE")
        if display.textureVal then
            self.previewPanel.texture = display.textureVal
        else
            self.previewPanel.texture = nil
        end
        if display.overlayVal then
            self.previewPanel.overlay = display.overlayVal
        else
            self.previewPanel.overlay = nil
        end
        if item.display.type == "VEHICLE" then
            if self.previewPanel3d.vehicleName ~= item.display.label then
                if not self.previewPanel3d.initialized then
                    self.previewPanel3d.initialized = true
                    self.previewPanel3d.javaObject:fromLua1("setDrawGrid", false)
                    self.previewPanel3d.javaObject:fromLua1("createVehicle", "vehicle")
                    self.previewPanel3d.javaObject:fromLua3("setViewRotation", 45 / 2, 45, 0)
                    self.previewPanel3d.javaObject:fromLua1("setView", "UserDefined")
                    self.previewPanel3d.javaObject:fromLua2("dragView", 0, 30)
                    self.previewPanel3d.javaObject:fromLua1("setZoom", 6)
                end
                self.previewPanel3d.vehicleName = item.display.label
                self.previewPanel3d.javaObject:fromLua2("setVehicleScript", "vehicle", self.previewPanel3d.vehicleName)
            end
        end
    elseif self.previewPanel then
        self.previewPanel:setVisible(false)
        self.previewPanel3d:setVisible(false)
    end
end
