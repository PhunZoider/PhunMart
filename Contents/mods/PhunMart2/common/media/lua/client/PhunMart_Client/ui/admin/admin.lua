if isServer() then
    return
end
require "DebugUIs/DebugMenu/ISDebugMenu"
local Core = PhunMart

--- The single way in. Both doors below route through here, so the access rule
--- can't differ depending on which one an admin happens to use, and a refusal
--- always says so rather than silently doing nothing.
local function openEditor()
    local player = getPlayer()
    if not Core.canEditConfig(player) then
        local w = 300
        local h = 150
        local modal = ISModalDialog:new((getCore():getScreenWidth() - w) / 2, (getCore():getScreenHeight() - h) / 2, w,
            h, getText("IGUI_PhunMart_Msg_NoEditorAccess"), false, nil, nil, nil, nil, nil)
        modal:initialise()
        modal:addToUIManager()
        return
    end
    Core.ClientSystem.instance:openShopList(player)
end

local ISDebugMenu_setupButtons = ISDebugMenu.setupButtons;
function ISDebugMenu:setupButtons()
    self:addButtonInfo("PhunMart", openEditor, "MAIN");
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

    self.showPhunMartConfigs = ISButton:new(x, y, btnWid, BUTTON_HGT, getText("IGUI_PhunMart_Admin_PanelBtn"), self,
        openEditor);
    self.showPhunMartConfigs.internal = "";
    self.showPhunMartConfigs:initialise();
    self.showPhunMartConfigs:instantiate();
    self.showPhunMartConfigs.borderColor = self.buttonBorderColor;
    self:addChild(self.showPhunMartConfigs);

    ISAdminPanelUI_create(self);

end
