if isServer() then
    return
end
require "DebugUIs/DebugMenu/ISDebugMenu"
local Core = PhunMart

local function showPhunMartConfigs()
    Core.ClientSystem.instance:openShopList(getPlayer())
end

local ISDebugMenu_setupButtons = ISDebugMenu.setupButtons;
function ISDebugMenu:setupButtons()
    self:addButtonInfo("PhunMart", function()
        Core.ClientSystem.instance:prepareShopList(getPlayer())
    end, "MAIN");
    ISDebugMenu_setupButtons(self);
end

local ISAdminPanelUI_create = ISAdminPanelUI.create;
function ISAdminPanelUI:create()

    local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
    local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
    local UI_BORDER_SPACING = 10
    local BUTTON_HGT = FONT_HGT_SMALL + 6

    local btnWid = 200;
    local x = UI_BORDER_SPACING + 1;
    local y = FONT_HGT_MEDIUM + UI_BORDER_SPACING * 2 + 1;

    self.showPhunMartConfigs = ISButton:new(x, y, btnWid, BUTTON_HGT, getText("IGUI_PhunMart_Admin_PanelBtn"), self, showPhunMartConfigs);
    self.showPhunMartConfigs.internal = "";
    self.showPhunMartConfigs:initialise();
    self.showPhunMartConfigs:instantiate();
    self.showPhunMartConfigs.borderColor = self.buttonBorderColor;
    self:addChild(self.showPhunMartConfigs);

    ISAdminPanelUI_create(self);

end
