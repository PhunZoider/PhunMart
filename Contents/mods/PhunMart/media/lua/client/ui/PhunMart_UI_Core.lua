require "ui/PhunMartUI_ItemsPanel"
require "ui/PhunMartUI_ItemPreviewPanel"
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

-- function window:open(playerObj, key)
--     if ISPanelJoypad.open then
--         ISPanelJoypad.open(self)
--     end

--     local pIndex = playerObj:getPlayerNum()
--     local data = {
--         key = key
--     }

--     local instance
--     if window.instances[pIndex] then
--         instance = window.instances[pIndex]
--     else
--         local core = getCore()
--         local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 14
--         local core = getCore()
--         local width = self.layout.window.width * FONT_SCALE
--         local height = self.layout.window.height * FONT_SCALE
--         local x = (core:getScreenWidth() - width) / 2
--         local y = (core:getScreenHeight() - height) / 2
--         instance = window:new(x, y, width, height, playerObj)
--         ISLayoutManager.RegisterWindow(self.name or "PhunMartShopUI", PhunMartShopUI, instance)
--         window.instances[pIndex] = instance
--     end

--     instance:setData(data)
--     instance:addToUIManager()
--     instance:setVisible(true)
--     return instance

-- end

-- function window:close()

--     if ISPanelJoypad.open then
--         ISPanelJoypad.open(self)
--     end
--     self:highlight(true)
--     self:setVisible(false);
--     self:removeFromUIManager();
--     window.instances[self.pIndex] = nil
-- end

-- function window:onBuy()
--     local item = self.pricePanel.selectedItem
--     local tab = self.tabs[self.tabPanel.selected]
--     local visible = self.disabledBuyButton:getIsVisible()
--     if item and not visible then
--         PhunMart:purchase(self.player, self.data.key, item.item)
--     end
-- end

-- function window:reroll()
--     if isAdmin() then
--         UI.data = {
--             key = self.data.key
--         }
--         self:rebuild()
--         sendClientCommand(PhunMart.name, PhunMart.commands.requestShopGenerate, {
--             key = self.data.key
--         })
--     end
-- end

-- function window:restock()
--     if isAdmin() then
--         UI.data = {
--             key = self.data.key
--         }
--         self:rebuild()
--         sendClientCommand(PhunMart.name, PhunMart.commands.requestRestock, {
--             key = self.data.key
--         })
--     end
-- end

-- function window:getSprites()
--     if self.sprites then
--         return self.sprites
--     end
--     return PhunMart.shopSprites
-- end

-- function window:highlight(removeHighlight)

--     local square = getSquare(self.data.location.x, self.data.location.y, self.data.location.z)
--     local sprites = self:getSprites()
--     local objects = square:getObjects();

--     for j = 0, objects:size() - 1 do
--         local obj = objects:get(j);
--         local sprite = obj:getSprite();
--         for i, v in ipairs(sprites) do
--             if v == sprite:getName() then
--                 obj:setHighlighted(removeHighlight == true or removeHighlight == nil, false);
--                 break
--             end
--         end
--     end
-- end

-- function window:setData(data)
--     self.data = data
--     self.data.location = PhunMart:xyzFromKey(data.key)
--     self.data.shop = PhunMart:getShop(data.key)

-- end

-- function window:isKeyConsumed(key)
--     return key == Keyboard.KEY_ESCAPE
-- end

-- function window:onKeyRelease(key)
--     if key == Keyboard.KEY_ESCAPE then
--         self:close()
--     end
-- end

-- function window:new(x, y, w, h, playerObj)
--     local o = {}
--     o = ISPanel:new(x, y, width, height)
--     setmetatable(o, self)
--     self.__index = self
--     o.backgroundColor = {
--         r = 0,
--         g = 0,
--         b = 0,
--         a = 0.8
--     };
--     o.borderColor = {
--         r = 0.4,
--         g = 0.4,
--         b = 0.4,
--         a = 1
--     };
--     o.altBgColor = {
--         r = 0.2,
--         g = 0.3,
--         b = 0.2,
--         a = 0.1
--     }
--     o.playerObj = playerObj
--     o.pIndex = playerObj:getPlayerNum()
--     o.userPosition = false
--     o.zOffsetLargeFont = 25;
--     o.zOffsetMediumFont = 20;
--     o.zOffsetSmallFont = 6;
--     o.moveWithMouse = true;
--     o:setWantKeyEvents(true)
--     o.initialise()
--     window.instances[o.pIndex] = o
--     return o
-- end

-- -- default layout
-- window.layout = {
--     window = {
--         width = 537,
--         height = 728
--     },
--     tabs = {
--         x = 45,
--         y = 145,
--         width = 299,
--         height = 476,
--         backgroundColor = {
--             r = 0,
--             g = 0,
--             b = 0,
--             a = 0.7
--         }
--     },
--     previewPanel = {
--         x = 378,
--         y = 145,
--         width = 150,
--         height = 150,
--         backgroundColor = {
--             r = 0,
--             g = 0,
--             b = 0,
--             a = 0.7
--         }
--     },
--     pricePanel = {
--         x = 378,
--         y = 305,
--         width = 150,
--         height = 316,
--         backgroundColor = {
--             r = 0,
--             g = 0,
--             b = 0,
--             a = 0.7
--         }
--     },
--     detailsPanel = {
--         x = 378,
--         y = 305,
--         width = 150,
--         height = 316,
--         backgroundColor = {
--             r = 0,
--             g = 0,
--             b = 0,
--             a = 0.7
--         }
--     },
--     buyButton = {
--         x = 30,
--         y = 645,
--         width = 315,
--         height = 62
--     },
--     close = {
--         x = 505,
--         y = 10,
--         width = 25,
--         height = 25
--     },
--     restock = {
--         x = 378,
--         y = 643,
--         width = 70,
--         height = 25
--     },
--     reroll = {
--         x = 458,
--         y = 643,
--         width = 70,
--         height = 25
--     },
--     admin = {
--         x = 378,
--         y = 678,
--         width = 150,
--         height = 25
--     }
-- }
