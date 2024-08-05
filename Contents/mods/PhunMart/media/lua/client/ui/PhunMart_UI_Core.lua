require "ui/PhunMartUI_ItemsPanel"
require "ui/PhunMart_ItemPreviewPanel"
local PhunMart = PhunMart;
local sandbox = SandboxVars.PhunMart
PhunMartShopUI = ISPanelJoypad:derive("PhunMartShopWindow");
local window = PhunMartShopUI
if not isClient() then
    return
end
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14
