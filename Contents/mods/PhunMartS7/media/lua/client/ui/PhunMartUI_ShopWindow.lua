if not isClient() then
    return
end
require "ui/PhunMartUI_ItemsPanel"
require "ui/PhunMartUI_ItemPreviewPanel"
PhunMartShopWindow = ISPanelJoypad:derive("PhunMartShopWindow");
PhunMartShopWindow.instances = {}
local sandbox = SandboxVars
local UI = PhunMartShopWindow
local PhunMart = PhunMart
UI.DrawType = {}
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
UI.cache = {
    textures = {},
    labels = {
        traits = {},
        skills = {},
        professions = {},
        perks = {}
    },
    lastTab = nil,
    lastItem = nil
}

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14

function UI.OnOpenPanel(playerObj, obj)

    if not obj then
        return
    end

    local core = getCore()
    local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 14
    local width = UI.layouts.default.window.width * FONT_SCALE
    local height = UI.layouts.default.window.height * FONT_SCALE
    local x = (core:getScreenWidth() - width) / 2
    local y = (core:getScreenHeight() - height) / 2

    local pIndex = playerObj:getPlayerNum()
    local instances = PhunMartShopWindow.instances
    if instances[pIndex] then
        instances[pIndex]:close()
    end

    local instance = UI:new(x, y, width, height, playerObj);
    instance:initialise();
    instance:instantiate();
    instance.shopObj = obj
    instance.tabPanel.shop = instance.shopObj

    instance.data = {}
    instance.player = playerObj
    instance:addToUIManager();
    instance:setVisible(false);

    local pNum = playerObj:getPlayerNum()
    instance:setVisible(true)
    return instance
end

function UI:highlight()
    local xyz = PhunMart:xyzFromKey(self.data.key)
    local square = getSquare(xyz.x, xyz.y, xyz.z)
    local sprites = {}

    local objects = square:getObjects();
    for j = 0, objects:size() - 1 do
        local obj = objects:get(j);
        local sprite = obj:getSprite();
        for i, v in ipairs(PhunMart.shopSprites) do
            if v == sprite:getName() then
                obj:setHighlighted(true, false);
                break
            end
        end
    end

end

function UI:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function UI:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
    end
end

function UI:removeHighlight()
    local square = getSquare(self.shopObj.x, self.shopObj.y, self.shopObj.z)
    PhunTools:removeHighlightedSquares({square})

end

function UI:initialise()
    ISPanelJoypad.initialise(self);
end

function UI:createChildren()
    ISPanelJoypad.createChildren(self);
    -- Close button
    local layout = self.layouts.default.close
    self.closeButton = ISButton:new(layout.x * FONT_SCALE, layout.y * FONT_SCALE, layout.width, layout.height, "X",
        self, self.close)
    self.closeButton:initialise()
    self:addChild(self.closeButton)

    if isAdmin() then
        layout = self.layouts.default.restock
        self.restockButton = ISButton:new(layout.x * FONT_SCALE, layout.y * FONT_SCALE, layout.width * FONT_SCALE,
            layout.height * FONT_SCALE, "Restock", self, self.restock)
        self.restockButton:initialise()
        self:addChild(self.restockButton)

        layout = self.layouts.default.reroll
        self.rerollButton = ISButton:new(layout.x * FONT_SCALE, layout.y * FONT_SCALE, layout.width * FONT_SCALE,
            layout.height * FONT_SCALE, "Reroll", self, self.reroll)
        self.rerollButton:initialise()
        self:addChild(self.rerollButton)

        layout = self.layouts.default.admin
        self.adminButton = ISButton:new(layout.x * FONT_SCALE, layout.y * FONT_SCALE, layout.width * FONT_SCALE,
            layout.height * FONT_SCALE, "Admin", self, function()
                PhunMartUIShopAdmin.OnOpenPanel(self.player, self.data.location)
                -- PhunMartAdminUI.OnOpenPanel()
            end)
        self.adminButton:initialise()
        self:addChild(self.adminButton)

    end

    layout = self.layouts.default.tabs
    self.tabPanel = PhunMartUIItemsPanel:new(layout.x * FONT_SCALE, layout.y * FONT_SCALE, layout.width * FONT_SCALE,
        layout.height * FONT_SCALE, {
            viewer = self.player,
            backgroundColor = layout.backgroundColor
        })
    -- self.tabPanel:setShop(self.shopObj)
    self:addChild(self.tabPanel)

    layout = self.layouts.default.previewPanel
    self.preview = PhunMartUIItemPreviewPanel:new(layout.x * FONT_SCALE, layout.y * FONT_SCALE,
        layout.width * FONT_SCALE, layout.height * FONT_SCALE, {
            viewer = self.player,
            backgroundColor = layout.backgroundColor
        })
    self:addChild(self.preview)

    layout = self.layouts.default.pricePanel
    self.pricePanel = PunMartUIPricePanel:new(layout.x * FONT_SCALE, layout.y * FONT_SCALE, layout.width * FONT_SCALE,
        layout.height * FONT_SCALE, {
            viewer = self.player,
            backgroundColor = layout.backgroundColor
        })
    self:addChild(self.pricePanel)

    layout = self.layouts.default.buyButton
    self.buyButton = ISButton:new(layout.x * FONT_SCALE, layout.y * FONT_SCALE, layout.width * FONT_SCALE,
        layout.height * FONT_SCALE, "BUY", self, self.onBuy)
    self.buyButton.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.1
    }

    self.buyButton:initialise()
    self:addChild(self.buyButton)

    self.disabledBuyButton = ISPanel:new(layout.x * FONT_SCALE, layout.y * FONT_SCALE, layout.width * FONT_SCALE,
        layout.height * FONT_SCALE)
    self.disabledBuyButton.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    }
    self.disabledBuyButton.borderColor = {
        r = 1,
        g = 0.4,
        b = 0.4,
        a = 1
    };
    self.disabledBuyButton:initialise()
    self:addChild(self.disabledBuyButton)
    self.disabledBuyButton:setVisible(false)

end

function UI:onGainJoypadFocus(joypadData)
    ISPanelJoypad.onGainJoypadFocus(self, joypadData);
    self.joypadIndex = nil
    self.barWithTooltip = nil
end

function UI:onMouseDown(x, y)
    self.downX = self:getMouseX()
    self.downY = self:getMouseY()
    return true
end
function UI:onMouseUp(x, y)
    self.downY = nil
    self.downX = nil
    if not self.dragging then
        if self.onClick then
            self:onClick()
        end
    else
        self.dragging = false
        self:setCapture(false)
    end
    return true
end

function UI:onMouseMove(dx, dy)

    if self.downY and self.downX and not self.dragging then
        if math.abs(self.downX - dx) > 4 or math.abs(self.downY - dy) > 4 then
            self.dragging = true
            self:setCapture(true)
        end
    end

    if self.dragging then
        local dx = self:getMouseX() - self.downX
        local dy = self:getMouseY() - self.downY
        self.userPosition = true
        self:setX(self.x + dx)
        self:setY(self.y + dy)
    end
end

function UI:onLoseJoypadFocus(joypadData)
    ISPanelJoypad.onLoseJoypadFocus(self, joypadData);
end

function UI:onJoypadDown(button)
    if button == Joypad.AButton then
    end
    if button == Joypad.YButton then
    end
    if button == Joypad.BButton then
    end
    if button == Joypad.LBumper then
        getPlayerInfoPanel(self.playerNum):onJoypadDown(button)
    end
    if button == Joypad.RBumper then
        getPlayerInfoPanel(self.playerNum):onJoypadDown(button)
    end
end

function UI:onJoypadDirDown()
    self.joypadIndex = self.joypadIndex + 1
    self:ensureVisible()
    self:updateTooltipForJoypad()
end

function UI:onJoypadDirLeft()
end

function UI:onJoypadDirRight()
end

function UI:onBuy()

    if self.disabledBuyButton:getIsVisible() then
        -- buy is disabled
        return
    end

    local selected = self.pricePanel.selectedItem
    if not selected then
        return
    end

    CPhunMartSystem.instance:requestPurchase(self.shopObj, selected.key, self.player)
end

local cache = {}

function UI:rebuild()

end

function UI:reroll()
    if isAdmin() then
        self.shopObj:reroll()
    end
end

function UI:restock()
    if isAdmin() then
        self.shopObj:restock()
    end
end

local updateShopIterations = 0

function UI:prerender()
    ISPanelJoypad.prerender(self);

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
            -- self:drawTexture(self.backgroundTexture, 0, 0, 1, 1, 1, 1)
            self:drawTextureScaledAspect(self.backgroundTexture, 0, 0, self.width, self.height, 1);
        end
    end
    local selected = self.tabPanel:getSelected()
    if selected then
        local item = shop.items[selected.text]
        if not item then
            self.disabledBuyButton:setVisible(true)
            return
        end
        self.preview:setItem(item, selected.item)
        self.pricePanel:setItem(item, selected.item)
        local canBuy = self.pricePanel.canBuy.passed == true
        if canBuy then
            -- is there inventory?
            if item.inventory ~= false and item.inventory < 1 then
                canBuy = false
            end
        end
        self.disabledBuyButton:setVisible(not canBuy)
    else
        self.disabledBuyButton:setVisible(true)
    end
end

function UI:render()
    ISPanelJoypad.render(self);

    local sb = sandbox

    if self.shopObj and (isAdmin() or sandbox.PhunMart.PhunMartShowNextRestockDate) then
        local hoursTillNextRestock = self.shopObj.nextRestock - GameTime:getInstance():getWorldAgeHours();
        local txt = "";
        if hoursTillNextRestock > 36 then
            txt = getText("IGUI_PhunMart.HoursTillRestock.Days", math.ceil(hoursTillNextRestock / 24))
        elseif hoursTillNextRestock >= 22 then
            txt = getText("IGUI_PhunMart.HoursTillRestock.Day")
        elseif hoursTillNextRestock >= 6 then
            txt = getText("IGUI_PhunMart.HoursTillRestock.HalfADay")
        else
            txt = getText("IGUI_PhunMart.HoursTillRestock.Soon")
        end
        self:drawText(txt, self.layouts.default.buyButton.x, self.height - 12, 0.7, 0.7, 0.7, 1.0, UIFont.Small)
    end

    if self.shopObj and self.shopObj.requiresPower then
        local text = getText("IGUI_PhunMart.isPowered")
        if self.shopObj:insufficientPower() then
            text = getText("IGUI_PhunMart.isNotPowered")
        end
        local width = getTextManager():MeasureStringX(UIFont.Small, text)
        self:drawText(text, self.width - width - 10, self.height - 20, 0.7, 0.7, 0.7, 1, UIFont.Small)
    end
end

function UI:setVisible(visible)
    local current = self:getIsVisible()
    ISPanelJoypad.setVisible(self, visible)
    if visible and not current then
        self.tabPanel:rebuildTabs(true)
        self:bringToTop()
    end
end

function UI:close()
    triggerEvent(PhunMart.events.OnWindowClosed, self.player, self.shopObj)
    CPhunMartSystem.instance:close(self.shopObj, self.player)
    self:removeHighlight()
    self:setVisible(false);
    self:removeFromUIManager();
    UI.instances[self.pIndex] = nil
end

function UI:new(x, y, width, height, player)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    };
    o.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    };
    o.altBgColor = {
        r = 0.2,
        g = 0.3,
        b = 0.2,
        a = 0.1
    }
    o.player = player
    o.pIndex = player:getPlayerNum()
    o.userPosition = false
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o.moveWithMouse = true;
    o:setWantKeyEvents(true)
    return o
end

function UI:RestoreLayout(name, layout)
    if name == "PhunMartShopWindow" then
        ISLayoutManager.DefaultRestoreWindow(self, layout)
        self.userPosition = layout.userPosition == 'true'
    end
end

function UI:SaveLayout(name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    layout.width = nil
    layout.height = nil
    if self.userPosition then
        layout.userPosition = 'true'
    else
        layout.userPosition = 'false'
    end
end
