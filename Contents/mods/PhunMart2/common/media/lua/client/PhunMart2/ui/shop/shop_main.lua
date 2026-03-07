if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local Core = PhunMart
local tools = require "PhunMart2/ux/tools"

local profileName = "PhunMartUIShop"
Core.ui.client.shop = ISCollapsableWindowJoypad:derive(profileName);
local UI = Core.ui.client.shop
local instances = {}

UI.layouts = {
    default = {
        window = {
            width = 369, -- 537,
            height = 500 -- 728
        },
        tabs = {
            x = 31, -- 45,
            y = 100, -- 145,
            width = 206, -- 299,
            height = 326, -- 476,
            backgroundColor = {
                r = 0,
                g = 0,
                b = 0,
                a = 0.7
            }
        },
        previewPanel = {
            x = 261, -- 378,
            y = 100, -- 145,
            width = 104, -- 150,
            height = 100, -- 150,
            backgroundColor = {
                r = 0,
                g = 0,
                b = 0,
                a = 0.7
            }
        },
        pricePanel = {
            x = 261, -- 378,
            y = 210, -- 305,
            width = 104, -- 150,
            height = 218, -- 316,
            backgroundColor = {
                r = 0,
                g = 0,
                b = 0,
                a = 0.7
            }
        },
        detailsPanel = {
            x = 261, -- 378,
            y = 210, -- 305,
            width = 104, -- 150,
            height = 218, -- 316,
            backgroundColor = {
                r = 0,
                g = 0,
                b = 0,
                a = 0.7
            }
        },
        buyButton = {
            x = 21, -- 30,
            y = 445, -- 645,
            width = 217, -- 315,
            height = 43 -- 62
        },
        close = {
            x = 348, -- 505,
            y = 5,
            width = 25,
            height = 25
        },
        restock = {
            x = 261, -- 378,
            y = 444, -- 643,
            width = 48, -- 70,
            height = 25
        },
        reroll = {
            x = 316, -- 458,
            y = 444, -- 643,
            width = 48, -- 70,
            height = 25
        },
        admin = {
            x = 261, -- 378,
            y = 468, -- 678,
            width = 104, -- 150,
            height = 25
        }
    }
}

-- obj = Core.ClientSystem.instance:getLuaObjectOnSquare
function UI.open(player, data)

    local playerIndex = player:getPlayerNum()
    local instance = instances[playerIndex]

    if instance and instance.player ~= player then
        instance:close()
        instance = nil
    end

    if not instance then
        local core = getCore()
        local width = 450 * tools.FONT_SCALE
        local height = 590 * tools.FONT_SCALE

        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2

        instances[playerIndex] = UI:new(x, y, width, height, player, playerIndex, data);
        instance = instances[playerIndex]
        instance:initialise();

        ISLayoutManager.RegisterWindow(profileName, UI, instance)
    end

    instance:addToUIManager();
    instance:setVisible(true);
    instance:ensureVisible()
    instance.controls.items:setData(data)

    return instance;

end

function UI:new(x, y, width, height, player, playerIndex, data)
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
    o.data = data or nil
    o.items = {}
    o.moveWithMouse = false;
    o.anchorRight = true
    o.anchorBottom = true
    o.player = player
    o.playerIndex = playerIndex
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o:setWantKeyEvents(true)
    o:setTitle("PhunMart")
    return o;
end

function UI:RestoreLayout(name, layout)

    ISLayoutManager.DefaultRestoreWindow(self, layout)
    if name == profileName then
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

function UI:setSelected(item)
    self.controls.list.selected = item
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

    self.controls = {}

    local layout = self.layouts.default.tabs
    self.controls.items = Core.ui.client.shopItemsList:new(layout.x * tools.FONT_SCALE, layout.y * tools.FONT_SCALE,
        layout.width * tools.FONT_SCALE, layout.height * tools.FONT_SCALE, {
            viewer = self.player,
            backgroundColor = layout.backgroundColor
        })

    self:addChild(self.controls.items)

end

function UI:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function UI:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
    end
end

function UI:prerender()

    ISCollapsableWindowJoypad.prerender(self);

    local shop = self.shopObj

    if shop then
        updateShopIterations = updateShopIterations + 1
        if updateShopIterations > 10 then
            updateShopIterations = 0
            shop:updateFromIsoObject()
        end
        if not self.backgroundTexture or self.backgroundTexture ~= shop.backgroundImage then
            if shop.backgroundImage then
                self.backgroundTexture = getTexture("media/textures/" .. shop.backgroundImage .. ".png")
            else
                self.backgroundTexture = getTexture("media/textures/machine-none.png")
            end
        end
        if self.backgroundTexture then
            self:drawTextureScaledAspect(self.backgroundTexture, 0, 0, self.width, self.height, 1);
        end
    end
end
