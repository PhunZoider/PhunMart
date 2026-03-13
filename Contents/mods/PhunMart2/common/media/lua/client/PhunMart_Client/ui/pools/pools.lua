if isServer() then
    return
end

local tools = require "PhunMart_Client/ui/ui_utils"
local Core = PhunMart
local profileName = "PhunMartUIPoolsPools"

Core.ui.pools = ISPanel:derive(profileName);
local UI = Core.ui.pools

function UI:setData(data)

    self.data = data or {}
    if not self.data.pools then
        self.data.pools = {}
    end

    local isNew = data.type == nil

    -- remove all tabviews
    if #self.controls.tabPanel.viewList > 0 then
        for i = #self.controls.tabPanel.viewList, 1, -1 do
            self.controls.tabPanel:removeView(self.controls.tabPanel.viewList[i].view)
        end
    end

    local pools = self.data.pools
    for i, v in ipairs(pools) do
        local p = Core.ui.pools_entry:new(0, 0, self.controls.tabPanel.width, self.controls.tabPanel.height, {
            player = self.player
        })
        p:initialise()
        p:instantiate()
        self.controls.tabPanel:addView(tostring(i), p)
        p:setData(v, isNew)
    end

    self.controls.tabPanel:setVisible(#self.controls.tabPanel.viewList > 0)
    self.isDirtyValue = false
end

function UI:getData()
    local pools = {}
    for i, v in ipairs(self.controls.tabPanel.viewList) do
        table.insert(pools, v.view:getData())
    end
    return pools
end

function UI:isDirty()
    local isDirty = self.isDirtyValue
    if not isDirty then
        for i, v in ipairs(self.controls.tabPanel.viewList) do
            if v.view:isDirty() then
                isDirty = true
                break
            end
        end
    end
    return isDirty
end

function UI:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    o.player = opts.player or getPlayer()
    o.playerIndex = o.player:getPlayerNum()
    o:setWantKeyEvents(true)
    self.instance = o;
    return o;
end

function UI:createChildren()

    ISPanel.createChildren(self)

    local offset = 10
    local x = offset
    local y = offset
    local h = tools.FONT_HGT_MEDIUM
    local w = self.width - offset * 2

    self.controls = {}

    self.controls.addPool = ISButton:new(10, 10, 100, tools.BUTTON_HGT, getText("UI_btn_add"), self, self.onAddPool);
    self.controls.addPool:initialise();
    self.controls.addPool:instantiate();
    self.controls.addPool.tooltip = getText("UI_btn_add_tooltip");
    if self.controls.addPool.enableAcceptColor then
        self.controls.addPool:enableAcceptColor()
    end
    self:addChild(self.controls.addPool);

    -- Duplicate pool button
    self.controls.duplicatePool = ISButton:new(230, 10, 100, tools.BUTTON_HGT, getText("UI_btn_duplicate"), self,
        self.onDuplicatePool);
    self.controls.duplicatePool:initialise();
    self.controls.duplicatePool:instantiate();
    self.controls.duplicatePool.tooltip = getText("UI_btn_duplicate_tooltip");
    if self.controls.duplicatePool.enableAcceptColor then
        self.controls.duplicatePool:enableAcceptColor()
    end
    self:addChild(self.controls.duplicatePool);

    self.controls.removePool = ISButton:new(120, 10, 100, tools.BUTTON_HGT, getText("UI_btn_remove"), self,
        self.onRemovePool);
    self.controls.removePool:initialise();
    self.controls.removePool:instantiate();
    self.controls.removePool.tooltip = getText("UI_btn_remove_tooltip");
    if self.controls.removePool.enableCancelColor then
        self.controls.removePool:enableCancelColor()
    end
    self:addChild(self.controls.removePool);

    local tabPanel = tools.getTabPanel(x, tools.BUTTON_HGT + 20, self.width - offset * 2,
        self.height - tools.HEADER_HGT - (tools.BUTTON_HGT + offset) - offset * 2, {})
    self.controls.tabPanel = tabPanel

    self:addChild(tabPanel)

end

-- Add pool
function UI:onAddPool()

    if not self.data then
        self.data = {}
    end
    if not self.data.pools then
        self.data.pools = {}
    end

    table.insert(self.data.pools, {
        keys = {}
    })

    self:setData(self.data)

    self.isDirtyValue = true
end

-- Remove pool
function UI:onRemovePool()
    local index = 0
    local view = self.controls.tabPanel.activeView
    for i, v in ipairs(self.controls.tabPanel.viewList) do
        if v == view then
            index = i
            break
        end
    end

    if index > 0 then

        table.remove(self.data.pools, index)

        self:setData(self.data)
        self.isDirtyValue = true
    end
end

-- Duplicate pool
function UI:onDuplicatePool()

    local index = 0
    local view = self.controls.tabPanel.activeView
    local data = view and view.view and view.view:getData() or nil
    if data then
        local copy = PL.table.deepCopy(data)
        table.insert(self.data.pools, copy)
        self:setData(self.data)
        self.isDirtyValue = true
    end

end

function UI:onResize()

    self.controls.removePool:setX(self.width - self.controls.removePool.width - 10)
    self.controls.duplicatePool:setX(self.controls.removePool.x - self.controls.duplicatePool.width - 10)
    self.controls.addPool:setX(self.controls.duplicatePool.x - self.controls.addPool.width - 10)

    for _, view in ipairs(self.controls.tabPanel.viewList) do
        view.view:setWidth(self.width - 10 * 2)
        view.view:setHeight(self.height - tools.HEADER_HGT - (tools.BUTTON_HGT + 10) - 10 * 2)
    end
end
