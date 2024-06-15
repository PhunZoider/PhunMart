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
UI.layout = {
    window = {
        width = 537,
        height = 903
    },
    tabs = {
        x = 45,
        y = 232,
        width = 299,
        height = 523,
        backgroundColor = {
            r = 0,
            g = 0,
            b = 0,
            a = 0.7
        }
    },
    previewPanel = {
        x = 378,
        y = 232,
        width = 150,
        height = 150,
        backgroundColor = {
            r = 0,
            g = 0,
            b = 0,
            a = 0.7
        }
    },
    pricePanel = {
        x = 378,
        y = 388,
        width = 150,
        height = 370,
        backgroundColor = {
            r = 0,
            g = 0,
            b = 0,
            a = 0.7
        }
    },
    detailsPanel = {
        x = 378,
        y = 552,
        width = 150,
        height = 150,
        backgroundColor = {
            r = 0,
            g = 0,
            b = 0,
            a = 0.7
        }
    },
    buyButton = {
        x = 30,
        y = 803,
        width = 315,
        height = 62
    },
    close = {
        x = 505,
        y = 10,
        width = 25,
        height = 25
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


function UI.OnOpenPanel(playerObj, key)

    local pNum = playerObj:getPlayerNum()
    local recycle = false

    if UI.instances[pNum] then
        if UI.instances[pNum].data.key == key then
            triggerEvent(PhunMart.events.OnWindowOpened, UI.instances[pNum].player)
            if UI.instances[pNum] and UI.instances[pNum].rebuild then
                UI.instances[pNum]:rebuild()
            end
            return UI.instances[pNum]
        else 
            return UI.instances[pNum]
        end
    end

    local core = getCore()
    local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 14
    local core = getCore()
    local width = UI.layout.window.width * FONT_SCALE
    local height = 903 * FONT_SCALE
    local x = (core:getScreenWidth() - width) / 2
    local y = (core:getScreenHeight() - height) / 2

    local instance = UI:new(x, y, width, height, playerObj);
    instance:initialise();
    instance:instantiate();
    instance.data = {
        key = key,
        location = PhunMart:xyzFromKey(key)
    }
    instance.player = playerObj
    instance:addToUIManager();
    instance:setVisible(false);
    if instance.rebuild then
        instance:rebuild()
    end
    triggerEvent(PhunMart.events.OnWindowOpened, instance.player)
    UI.instances[pNum] = instance
    if pNum == 0 then
        ISLayoutManager.RegisterWindow('PhunMartShopWindow', PhunMartShopWindow, UI.instances[pNum])
    end
    return UI.instances[pNum]
end

function UI:initialise()
    ISPanelJoypad.initialise(self);
end

function UI:createChildren()
    ISPanelJoypad.createChildren(self);
    -- Close button
    local layout = self.layout.close
    self.closeButton = ISButton:new(layout.x, layout.y, layout.width, layout.height, "X", self, self.close)
    self.closeButton:initialise()
    self:addChild(self.closeButton)

    if isAdmin() then
        self.restockButton = ISButton:new(layout.x - 110, layout.y, 100, layout.height, "Restock", self, self.restock)
        self.restockButton:initialise()
        self:addChild(self.restockButton)

        self.rerollButton = ISButton:new(layout.x - 220, layout.y, 100, layout.height, "Reroll", self, self.reroll)
        self.rerollButton:initialise()
        self:addChild(self.rerollButton)

        self.adminButton = ISButton:new(layout.x - 330, layout.y, 100, layout.height, "Admin", self, function()
            PhunMartAdminUI.OnOpenPanel()
        end)
        self.adminButton:initialise()
        self:addChild(self.adminButton)

    end

    layout = self.layout.tabs
    self.tabPanel = PhunMartUIItemsPanel:new(layout.x, layout.y, layout.width, layout.height, {
        viewer = self.player,
        backgroundColor = layout.backgroundColor
    })
    self:addChild(self.tabPanel)

    layout = self.layout.previewPanel
    self.preview = PhunMartUIItemPreviewPanel:new(layout.x, layout.y, layout.width, layout.height, {
        viewer = self.player,
        backgroundColor = layout.backgroundColor
    })
    self:addChild(self.preview)

    layout = self.layout.pricePanel
    self.pricePanel = PunMartUIPricePanel:new(layout.x, layout.y, layout.width, layout.height, {
        viewer = self.player,
        backgroundColor = layout.backgroundColor
    })
    self:addChild(self.pricePanel)

    layout = self.layout.buyButton
    self.buyButton = ISButton:new(layout.x, layout.y, layout.width, layout.height, "BUY", self, self.onBuy)
    self.buyButton.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.1
    }

    self.buyButton:initialise()
    self:addChild(self.buyButton)

    self.disabledBuyButton = ISPanel:new(layout.x, layout.y, layout.width, layout.height)
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
    local item = self.pricePanel.selectedItem
    local visible = self.disabledBuyButton:getIsVisible()
    if item and not visible then
        PhunMart:purchase(self.player, self.data.key, item.item)
    end
end

local cache = {}

function UI:rebuild(data)

    if not data or type(data) ~= "table" then
        return
    end
    local result = {
        tabs = {}
    }
    local tabKeys = {}

    for k, v in pairs(data) do
        if k == "items" then
            for i, item in pairs(v) do
                if not item.tab then
                    item.tab = "Misc"
                end
                if result.tabs[item.tab] == nil then
                    result.tabs[item.tab] = {
                        items = {}
                    }
                    table.insert(tabKeys, item.tab)
                end

                PhunMart:setDisplayValues(item)

                table.insert(result.tabs[item.tab].items, item)
            end
        else
            result[k] = v
        end
    end

    table.sort(tabKeys, function(a, b)
        return a < b
    end)
    result.tabKeys = tabKeys
    local unplugged = result.requiresPower == true and sandbox.PhunMart.PoweredMachinesEnabled == true
    if unplugged then
        if not self.data.location and self.data.key then
            self.data.location = PhunMart:xyzFromKey(self.data.key)
        end
        if self.data.location then
            unplugged = not PhunTools:isPowered(self.data.location)
        end
    end
    result.isUnplugged = unplugged
    self.data.shop = result
    self.tabPanel:setShop(result)
end

function UI:reroll()
    if isAdmin() then
        UI.data = {
            key = self.data.key
        }
        self:rebuild()
        sendClientCommand(PhunMart.name, PhunMart.commands.requestShopGenerate, {
            key = self.data.key
        })
    end
end

function UI:restock()
    if isAdmin() then
        UI.data = {
            key = self.data.key
        }
        self:rebuild()
        sendClientCommand(PhunMart.name, PhunMart.commands.requestRestock, {
            key = self.data.key
        })
    end
end

function UI:setData(data)

    -- get current selected state
    local activeView = self.tabPanel.activeView
    local currentTab = nil
    local currentSelection = nil
    if activeView then
        local selected = activeView.view.selected
        currentTab = activeView.name
        currentSelection = activeView.view.items[selected]
    end
    local doRebuild = false
    if self.data == nil or self.data.shop == nil and data.shop then
        doRebuild = true
    end
    self.data = data
    if doRebuild then
        self:rebuild(data.shop)
    end
    if currentTab and currentSelection and currentSelection.index then
        local activeView
        for _, view in ipairs(self.tabPanel.viewList) do
            if view.name == currentTab then
                activeView = view.view
                break
            end
        end
        if activeView then
            activeView.selected = currentSelection.index
            self.tabPanel:activateView(currentTab)
        end
    end
end

function UI:getShop()
    if self.data and self.data.shop then
        if not self.data.shop.tabs then
            self:rebuild(self.data.shop)
        end
        return self.data.shop
    end
end

function UI:prerender()
    ISPanelJoypad.prerender(self);

    local shop = self:getShop()
    if shop then
        if not self.backgroundTexture or self.backgroundTexture ~= shop.backgroundImage then
            if shop.backgroundImage then
                self.backgroundTexture = getTexture("media/textures/" .. shop.backgroundImage .. ".png")
            else
                self.backgroundTexture = getTexture("media/textures/machine-none.png")
            end
        end
        if self.backgroundTexture then
            self:drawTexture(self.backgroundTexture, 0, 0, 1, 1, 1, 1)
        end
    end
    local selected = self.tabPanel:getSelected()
    self.preview:setItem(selected)
    self.pricePanel:setItem(selected)
    self.disabledBuyButton:setVisible(self.pricePanel.canBuy.passed ~= true)
end

function UI:render()
    ISPanelJoypad.render(self);

    if self.data then
        self:drawText(self.data.key or "key", 10, 10, 1, 1, 1, 1, UIFont.Small);
    else
        self:drawText("No data", 10, 10, 1, 1, 1, 1, UIFont.Small);
    end
    if isAdmin() then
        if self.data and self.data.shop then
            local diff = PhunTools:formatWholeNumber(self.data.shop.nextRestock -
                                                         GameTime:getInstance():getWorldAgeHours())
            -- when is next restocking?
            local txt = tonumber(diff) == 1 and getText("IGUI_PhunMart.HourTillRestock") or
                            getText("IGUI_PhunMart.HoursTillRestock", diff)
            self:drawText(txt, 10, self.height - 20, 0.7, 0.7, 0.7, 1.0, UIFont.Small)

        end
    end
    if self.data.shop and self.data.shop.requiresPower then
        local text = getText("IGUI_PhunMart.isPowered")
        if self.data.shop.isUnplugged then
            text = getText("IGUI_PhunMart.isNotPowered")
        end
        local width = getTextManager():MeasureStringX(UIFont.Small, text)
        self:drawText(text, self.width - width - 10, self.height - 20, 0.7 , 0.7, 0.7, 1, UIFont.Small)    
    end
end

function UI:close()
    triggerEvent(PhunMart.events.OnWindowClosed, self.player)
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