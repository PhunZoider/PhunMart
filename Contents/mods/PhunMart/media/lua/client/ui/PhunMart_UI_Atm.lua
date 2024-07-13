require "ui/PhunMart_UI_Core"
local pickle = PhunMartShopUI
print("ooooooooooooooo\n\n", tostring(pickle))
if not isClient() then
    return
end

PhunMartAtmUI = PhunMartShopUI:derive("PhunMartAtmWindow");
local PhunMart = PhunMart;
local sandbox = SandboxVars.PhunMart
local window = PhunMartAtmUI
window.name = "PhunMartAtmUI"
