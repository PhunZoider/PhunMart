require "ui/PhunMartUI_Core"
local pickle = PhunMartShopUI

if not isClient() then
    return
end

PhunMartAtmUI = PhunMartShopUI:derive("PhunMartAtmWindow");
local PhunMart = PhunMart;
local sandbox = SandboxVars.PhunMart
local window = PhunMartAtmUI
window.name = "PhunMartAtmUI"
