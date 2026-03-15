if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local tools = require "PhunMart_Client/ui/ui_utils"
local Core = PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local BUTTON_HGT = FONT_HGT_SMALL + 6
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

local profileName = "PhunMartUIConfigItem"
Core.ui.shop_config_item = ISCollapsableWindowJoypad:derive(profileName)
local UI = Core.ui.shop_config_item

-- ---------------------------------------------------------------------------
-- Offer item data shape (PhunMart_Items.lua):
--   price        = "coin_50"           (named price key)
--   reward       = "add_brave"         (named reward key)
--   offer = {
--     weight     = 1.0,
--     stock = { min=0, max=1, restockHours=168 }
--   }
--   conditions = {
--     all = {"condKey1", "condKey2"},  (ALL must pass)
--     any = {"condKey3"}               (ANY must pass)
--   }
-- ---------------------------------------------------------------------------

-- Props fields rendered as labelled text inputs
local offerProps = {{
    key = "price",
    label = "Price Key",
    tooltip = "Named price key (e.g. coin_5, coin_50, vehicle_common). Overrides pool and shop defaults."
}, {
    key = "reward",
    label = "Reward Key",
    tooltip = "Named reward key. Leave blank for standard item grant."
}, {
    key = "offer_weight",
    label = "Weight",
    tooltip = "Relative probability this item is drawn when the pool rolls. e.g. 1.0 (normal) or 0.5 (half as likely)."
}, {
    key = "stock_min",
    label = "Stock Min",
    tooltip = "Minimum stock quantity per restock. Leave blank for pool defaults."
}, {
    key = "stock_max",
    label = "Stock Max",
    tooltip = "Maximum stock quantity per restock. Leave blank for pool defaults."
}, {
    key = "stock_restockHours",
    label = "Restock Hours",
    tooltip = "Game hours before this item's stock refreshes. Leave blank for pool defaults."
}}

-- ---------------------------------------------------------------------------
-- open()
-- ---------------------------------------------------------------------------

function UI.open(player, item, cb)
    local playerIndex = player:getPlayerNum()
    local core = getCore()
    local width = math.floor(560 * FONT_SCALE)
    local height = math.floor(420 * FONT_SCALE)
    local x = math.floor((core:getScreenWidth() - width) / 2)
    local y = math.floor((core:getScreenHeight() - height) / 2)

    local instance = UI:new(x, y, width, height, player, playerIndex)
    instance.item = item
    instance.data = type(item) == "table" and Core.utils.deepCopy(item) or {}
    instance.cb = cb

    instance:initialise()
    ISLayoutManager.RegisterWindow(profileName, UI, instance)
    instance:addToUIManager()
    instance:setVisible(true)
    instance:ensureVisible()
    instance:bringToTop()
    instance:populate()
    return instance
end

-- ---------------------------------------------------------------------------
-- Constructor
-- ---------------------------------------------------------------------------

function UI:new(x, y, width, height, player, playerIndex)
    local o = ISCollapsableWindowJoypad:new(x, y, width, height, player)
    setmetatable(o, self)
    self.__index = self
    o.variableColor = {
        r = 0.9,
        g = 0.55,
        b = 0.1,
        a = 1
    }
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    }
    o.buttonBorderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 1
    }
    o.controls = {}
    o.data = {}
    o.moveWithMouse = false
    o.anchorRight = true
    o.anchorBottom = true
    o.player = player
    o.playerIndex = playerIndex
    o:setWantKeyEvents(true)
    o:setTitle(getText("IGUI_PhunMart_Title_ItemOfferProps"))
    return o
end

-- ---------------------------------------------------------------------------
-- Layout helpers
-- ---------------------------------------------------------------------------

function UI:RestoreLayout(name, layout)
    self:recalcSize()
end

function UI:SaveLayout(name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    layout.userPosition = self.userPosition and 'true' or 'false'
end

function UI:close()
    if not self.locked then
        ISCollapsableWindowJoypad.close(self)
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

-- ---------------------------------------------------------------------------
-- createChildren
-- ---------------------------------------------------------------------------

function UI:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    local pad = 10
    local w = self.width
    local h = self.height - rh - th

    self.controls = {}

    -- ---- Left panel: item info ----
    local infoW = 180
    local infoPanel = ISPanel:new(w - infoW, th, infoW, h)
    infoPanel:initialise();
    infoPanel:instantiate()
    infoPanel:setAnchorBottom(true)
    self:addChild(infoPanel)
    self.controls.infoPanel = infoPanel

    -- Preview (texture or 3D for vehicles)
    if self.item and self.item.source == "vehicles" then
        local preview = ISUI3DScene:new(10, 10, infoW - 20, infoW - 20)
        preview:initialise()
        infoPanel:addChild(preview)
        self.controls.previewPanel = preview
    elseif self.item and self.item.texture then
        local preview = ISPanel:new(10, 10, infoW - 20, infoW - 20)
        preview:initialise();
        preview:instantiate()
        preview.render = function(p)
            local it = p.parent.parent.item
            if it and it.texture then
                p:drawTextureScaledAspect(it.texture, 0, 0, p:getWidth(), p:getHeight(), 1)
            end
        end
        infoPanel:addChild(preview)
        self.controls.previewPanel = preview
    end

    local lblY =
        self.controls.previewPanel and (self.controls.previewPanel.y + self.controls.previewPanel.height + 6) or 10
    local nameStr = self.item and
                        getTextManager():WrapText(UIFont.Medium, self.item.label or self.item.key or "", infoW - 20) or
                        ""
    local nameLabel = ISLabel:new(10, lblY, FONT_HGT_MEDIUM, nameStr, 1, 1, 1, 1, UIFont.Medium, true)
    nameLabel:initialise();
    nameLabel:instantiate();
    infoPanel:addChild(nameLabel)
    self.controls.nameLabel = nameLabel

    local catLabel = ISLabel:new(10, nameLabel.y + nameLabel.height + 4, FONT_HGT_SMALL,
        (self.item and self.item.category) or "", 0.7, 0.7, 0.7, 1, UIFont.Small, true)
    catLabel:initialise();
    catLabel:instantiate();
    infoPanel:addChild(catLabel)
    self.controls.catLabel = catLabel

    local saveBtn = ISButton:new(pad, h - BUTTON_HGT - pad, infoW - pad * 2, BUTTON_HGT, "Save", self, UI.onSave)
    saveBtn:initialise();
    saveBtn:instantiate()
    if saveBtn.enableAcceptColor then
        saveBtn:enableAcceptColor()
    end
    saveBtn:setAnchorBottom(true)
    infoPanel:addChild(saveBtn)
    self.controls.saveBtn = saveBtn

    -- ---- Right panel: tabs ----
    local tabW = w - infoW - pad
    local tabPanel = ISTabPanel:new(pad, th, tabW, h - th)
    tabPanel:initialise();
    tabPanel:instantiate()
    tabPanel:setAnchorRight(true);
    tabPanel:setAnchorBottom(true)
    self:addChild(tabPanel)
    self.controls.tabPanel = tabPanel

    -- Props tab
    local propsPanel = ISPanel:new(0, 0, tabW, tabPanel.height - HEADER_HGT)
    propsPanel:initialise();
    propsPanel:instantiate()
    tabPanel:addView(getText("IGUI_PhunMart_Tab_Props"), propsPanel)
    self.controls.propsPanel = propsPanel

    local fy = pad
    local labelW = 110
    local inputX = labelW + pad * 2
    local inputW = tabW - inputX - pad

    for _, def in ipairs(offerProps) do
        local lbl = ISLabel:new(pad, fy, FONT_HGT_SMALL, def.label .. ":", 1, 1, 1, 0.85, UIFont.Small, true)
        lbl:initialise();
        lbl:instantiate();
        propsPanel:addChild(lbl)

        local txt = ISTextEntryBox:new("", inputX, fy, inputW, FONT_HGT_SMALL + 4)
        txt:initialise();
        txt:instantiate()
        txt:setTooltip(def.tooltip)
        propsPanel:addChild(txt)
        self.controls[def.key] = txt

        fy = fy + FONT_HGT_SMALL + pad
    end

    -- Conditions tab
    local condPanel = ISPanel:new(0, 0, tabW, tabPanel.height - HEADER_HGT)
    condPanel:initialise();
    condPanel:instantiate()
    tabPanel:addView(getText("IGUI_PhunMart_Tab_Conditions"), condPanel)
    self.controls.condPanel = condPanel

    self:buildConditionsTab(condPanel, tabW)
end

-- ---------------------------------------------------------------------------
-- Conditions tab: two lists (all / any) with add/remove per list
-- ---------------------------------------------------------------------------

function UI:buildConditionsTab(parent, tabW)
    local pad = 10
    local halfH = math.floor((parent.height - pad * 3) / 2)
    local listW = tabW - pad * 2

    -- "all" section
    local lblAll = ISLabel:new(pad, pad, FONT_HGT_SMALL, getText("IGUI_PhunMart_Lbl_AllConditions"), 1, 1, 1, 0.85,
        UIFont.Small, true)
    lblAll:initialise();
    lblAll:instantiate();
    parent:addChild(lblAll)

    local listAllH = halfH - FONT_HGT_SMALL - BUTTON_HGT - pad * 2
    local listAll = self:makeConditionList(pad, lblAll.y + lblAll.height + 4, listW, listAllH)
    parent:addChild(listAll)
    self.controls.listAll = listAll

    local btnAddAll = ISButton:new(pad, listAll.y + listAll.height + 4, 80, BUTTON_HGT, getText("IGUI_PhunMart_Btn_Add"), parent, function()
        self:promptConditionKey(function(key)
            self:addConditionKey("all", key)
        end)
    end)
    btnAddAll:initialise();
    btnAddAll:instantiate()
    if btnAddAll.enableAcceptColor then
        btnAddAll:enableAcceptColor()
    end
    parent:addChild(btnAddAll)

    local btnRemAll = ISButton:new(pad + 90, listAll.y + listAll.height + 4, 80, BUTTON_HGT, getText("IGUI_PhunMart_Btn_Remove"), parent,
        function()
            self:removeConditionKey("all")
        end)
    btnRemAll:initialise();
    btnRemAll:instantiate()
    if btnRemAll.enableCancelColor then
        btnRemAll:enableCancelColor()
    end
    parent:addChild(btnRemAll)
    self.controls.btnRemAll = btnRemAll

    -- "any" section
    local anyY = listAll.y + listAll.height + BUTTON_HGT + pad * 2
    local lblAny = ISLabel:new(pad, anyY, FONT_HGT_SMALL, getText("IGUI_PhunMart_Lbl_AnyConditions"), 1, 1, 1, 0.85,
        UIFont.Small, true)
    lblAny:initialise();
    lblAny:instantiate();
    parent:addChild(lblAny)

    local listAnyH = halfH - FONT_HGT_SMALL - BUTTON_HGT - pad * 2
    local listAny = self:makeConditionList(pad, lblAny.y + lblAny.height + 4, listW, listAnyH)
    parent:addChild(listAny)
    self.controls.listAny = listAny

    local btnAddAny = ISButton:new(pad, listAny.y + listAny.height + 4, 80, BUTTON_HGT, getText("IGUI_PhunMart_Btn_Add"), parent, function()
        self:promptConditionKey(function(key)
            self:addConditionKey("any", key)
        end)
    end)
    btnAddAny:initialise();
    btnAddAny:instantiate()
    if btnAddAny.enableAcceptColor then
        btnAddAny:enableAcceptColor()
    end
    parent:addChild(btnAddAny)

    local btnRemAny = ISButton:new(pad + 90, listAny.y + listAny.height + 4, 80, BUTTON_HGT, getText("IGUI_PhunMart_Btn_Remove"), parent,
        function()
            self:removeConditionKey("any")
        end)
    btnRemAny:initialise();
    btnRemAny:instantiate()
    if btnRemAny.enableCancelColor then
        btnRemAny:enableCancelColor()
    end
    parent:addChild(btnRemAny)
    self.controls.btnRemAny = btnRemAny
end

function UI:makeConditionList(x, y, w, h)
    local list = ISScrollingListBox:new(x, y, w, h)
    list:initialise();
    list:instantiate()
    list.itemheight = FONT_HGT_SMALL + 6
    list.selected = 0
    list.joypadParent = self
    list.font = UIFont.NewSmall
    list.drawBorder = true
    list.doDrawItem = self.drawConditionRow
    list:addColumn(getText("IGUI_PhunMart_Col_ConditionKey"), 0)
    return list
end

function UI:drawConditionRow(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end
    local a = 0.9
    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15)
    end
    if alt then
        self:drawRect(0, y, self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5)
    end
    self:drawRectBorder(0, y, self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
    self:drawText(item.item or "", 8, y + 3, 1, 1, 1, a, self.font)
    self.itemsHeight = y + self.itemheight
    return self.itemsHeight
end

function UI:addConditionKey(slot, key)
    if not self.data.conditions then
        self.data.conditions = {}
    end
    if not self.data.conditions[slot] then
        self.data.conditions[slot] = {}
    end
    table.insert(self.data.conditions[slot], key)
    self:refreshConditionList(slot)
end

function UI:removeConditionKey(slot)
    local list = slot == "all" and self.controls.listAll or self.controls.listAny
    if not (list.selected and list.selected > 0) then
        return
    end
    if self.data.conditions and self.data.conditions[slot] then
        table.remove(self.data.conditions[slot], list.selected)
        list.selected = math.min(list.selected, #self.data.conditions[slot])
    end
    self:refreshConditionList(slot)
end

function UI:refreshConditionList(slot)
    local list = slot == "all" and self.controls.listAll or self.controls.listAny
    list:clear()
    local keys = (self.data.conditions and self.data.conditions[slot]) or {}
    for _, k in ipairs(keys) do
        list:addItem(k, k)
    end
end

function UI:promptConditionKey(cb)
    local fs = FONT_SCALE
    local dw = math.floor(300 * fs)
    local dh = math.floor(110 * fs)
    local core = getCore()
    local dlg = ISPanel:new(math.floor((core:getScreenWidth() - dw) / 2), math.floor((core:getScreenHeight() - dh) / 2),
        dw, dh)
    dlg:initialise();
    dlg:instantiate()
    dlg.backgroundColor = {
        r = 0.1,
        g = 0.1,
        b = 0.1,
        a = 0.95
    }
    dlg.moveWithMouse = true
    dlg:addToUIManager();
    dlg:setAlwaysOnTop(true)

    local pad = 10
    local lbl = ISLabel:new(pad, pad, FONT_HGT_SMALL, getText("IGUI_PhunMart_Lbl_ConditionKey"), 1, 1, 1, 1, UIFont.Small, true)
    lbl:initialise();
    lbl:instantiate();
    dlg:addChild(lbl)

    local txt = ISTextEntryBox:new("", pad + 100, pad, dw - pad * 2 - 100, FONT_HGT_SMALL + 4)
    txt:initialise();
    txt:instantiate();
    dlg:addChild(txt)

    local btnOK = ISButton:new(dw - 90 - pad, dh - BUTTON_HGT - pad, 80, BUTTON_HGT, getText("IGUI_PhunMart_Btn_OK"), dlg, function()
        local key = txt:getText():match("^%s*(.-)%s*$")
        if key ~= "" then
            cb(key)
        end
        dlg:removeFromUIManager()
    end)
    btnOK:initialise();
    btnOK:instantiate()
    if btnOK.enableAcceptColor then
        btnOK:enableAcceptColor()
    end
    dlg:addChild(btnOK)

    local btnCancel = ISButton:new(dw - 180 - pad, dh - BUTTON_HGT - pad, 80, BUTTON_HGT, getText("IGUI_PhunMart_Btn_Cancel"), dlg, function()
        dlg:removeFromUIManager()
    end)
    btnCancel:initialise();
    btnCancel:instantiate()
    if btnCancel.enableCancelColor then
        btnCancel:enableCancelColor()
    end
    dlg:addChild(btnCancel)
end

-- ---------------------------------------------------------------------------
-- populate() — fill controls from self.data
-- ---------------------------------------------------------------------------

function UI:populate()
    local d = self.data or {}

    -- offer.* flattened into controls
    local offer = d.offer or {}
    local stock = offer.stock or {}

    local function setText(key, val)
        local ctrl = self.controls[key]
        if ctrl then
            ctrl:clear()
            if val ~= nil then
                ctrl:setText(tostring(val))
            end
        end
    end

    setText("price", d.price)
    setText("reward", d.reward)
    setText("offer_weight", offer.weight)
    setText("stock_min", stock.min)
    setText("stock_max", stock.max)
    setText("stock_restockHours", stock.restockHours)

    -- conditions lists
    self:refreshConditionList("all")
    self:refreshConditionList("any")

    -- vehicle 3D preview
    if self.item and self.item.source == "vehicles" and self.controls.previewPanel then
        local p = self.controls.previewPanel
        p.javaObject:fromLua1("setDrawGrid", false)
        p.javaObject:fromLua1("createVehicle", "vehicle")
        p.javaObject:fromLua3("setViewRotation", 22.5, 45, 0)
        p.javaObject:fromLua1("setView", "UserDefined")
        p.javaObject:fromLua2("dragView", 0, 30)
        p.javaObject:fromLua1("setZoom", 6)
        p.javaObject:fromLua2("setVehicleScript", "vehicle", self.item.type)
    end
end

-- ---------------------------------------------------------------------------
-- onSave() — collect controls back into structured data and call cb
-- ---------------------------------------------------------------------------

function UI:onSave()
    local data = {}

    local function getNum(key)
        local ctrl = self.controls[key]
        return ctrl and tonumber(ctrl:getText()) or nil
    end
    local function getStr(key)
        local ctrl = self.controls[key]
        if not ctrl then
            return nil
        end
        local s = ctrl:getText():match("^%s*(.-)%s*$")
        return s ~= "" and s or nil
    end

    data.price = getStr("price")
    data.reward = getStr("reward")

    local weight = tonumber((self.controls.offer_weight:getText() or ""):match("[%d%.]+"))
    local sMin = getNum("stock_min")
    local sMax = getNum("stock_max")
    local sHours = getNum("stock_restockHours")

    if weight or sMin or sMax or sHours then
        data.offer = {}
        if weight then
            data.offer.weight = weight
        end
        if sMin or sMax or sHours then
            data.offer.stock = {}
            if sMin then
                data.offer.stock.min = sMin
            end
            if sMax then
                data.offer.stock.max = sMax
            end
            if sHours then
                data.offer.stock.restockHours = sHours
            end
        end
    end

    -- conditions
    local cAll = self.data.conditions and self.data.conditions.all or {}
    local cAny = self.data.conditions and self.data.conditions.any or {}
    if #cAll > 0 or #cAny > 0 then
        data.conditions = {}
        if #cAll > 0 then
            data.conditions.all = cAll
        end
        if #cAny > 0 then
            data.conditions.any = cAny
        end
    end

    -- return nil if nothing was set
    local empty = true
    for _ in pairs(data) do
        empty = false;
        break
    end

    if self.cb then
        self.cb(empty and nil or data)
    end
    self:close()
end

-- ---------------------------------------------------------------------------
-- prerender: keep info panel pinned to the right
-- ---------------------------------------------------------------------------

function UI:prerender()
    ISCollapsableWindowJoypad.prerender(self)
    local rh = self:resizeWidgetHeight()
    local pad = 10
    local info = self.controls.infoPanel
    info:setX(self.width - info.width)
    info:setHeight(self.height - self:titleBarHeight() - rh)
    self.controls.saveBtn:setY(info.height - BUTTON_HGT - pad)

    local tabPanel = self.controls.tabPanel
    tabPanel:setWidth(self.width - info.width - pad)
    tabPanel:setHeight(self.height - self:titleBarHeight() - rh)
end
