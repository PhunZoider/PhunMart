if isServer() then
    return
end
require "DebugUIs/DebugMenu/ISDebugMenu"
local Core = PhunMart

local function showPhunMartConfigs()
    Core.showLoadingModal()
    sendClientCommand(Core.name, Core.commands.requestNames, {})
end

local ISDebugMenu_setupButtons = ISDebugMenu.setupButtons;
function ISDebugMenu:setupButtons()
    self:addButtonInfo("PhunMart", function()
        Core.ClientSystem.instance:prepareShopList(playerObj)
    end, "MAIN");
    ISDebugMenu_setupButtons(self);
end

local ISAdminPanelUI_create = ISAdminPanelUI.create;
function ISAdminPanelUI:create()

    local fontHeight = getTextManager():getFontHeight(UIFont.Small);
    local btnWid = 150;
    local btnHgt = math.max(25, fontHeight + 3 * 2);
    local btnGapY = 5;

    local lastButton = self.children[self.IDMax - 1];
    lastButton = lastButton.internal == "CANCEL" and self.children[self.IDMax - 2] or lastButton;

    self.showPhunMartConfigs = ISButton:new(lastButton.x, lastButton.y + 5 + lastButton.height,
        self.sandboxOptionsBtn.width, self.sandboxOptionsBtn.height, "PhunMart", self, showPhunMartConfigs);
    self.showPhunMartConfigs.internal = "";
    self.showPhunMartConfigs:initialise();
    self.showPhunMartConfigs:instantiate();
    self.showPhunMartConfigs.borderColor = self.buttonBorderColor;
    self:addChild(self.showPhunMartConfigs);

    ISAdminPanelUI_create(self);
end
