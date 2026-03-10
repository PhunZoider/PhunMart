if isServer() then
    return
end

require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISTextEntryBox"

local Core = PhunMart
local UI = ISPanel:derive("PhunMartShopEditor")
Core.ui.client.shopEditor = UI

local W = 380
local H = 250
local PAD = 12
local LH = 22   -- label/row height
local FH = 24   -- input field height
local FONT = UIFont.Small
local FONT_HGT = getTextManager():getFontHeight(FONT)

-- ─────────────────────────────────────────────────────────────────────────────

function UI.open(player, shopType, shopDef)
    local core = getCore()
    local x = math.floor((core:getScreenWidth() - W) / 2)
    local y = math.floor((core:getScreenHeight() - H) / 2)
    local inst = UI:new(x, y, W, H, player, shopType, shopDef)
    inst:initialise()
    inst:addToUIManager()
    inst:bringToTop()
end

-- ─────────────────────────────────────────────────────────────────────────────

function UI:new(x, y, w, h, player, shopType, shopDef)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.playerIndex = player:getPlayerNum()
    o.shopType = shopType
    o.shopDef = shopDef or {}
    o.moveWithMouse = true
    o.noBackground = true
    -- view toggle state: true = grid, false = list
    o.viewIsGrid = (shopDef and shopDef.defaultView ~= "list")
    return o
end

-- ─────────────────────────────────────────────────────────────────────────────

function UI:createChildren()
    ISPanel.createChildren(self)
    local y = 34 -- below title bar

    -- ── Background ──────────────────────────────────────────────────────────
    y = y + LH
    self.bgInput = ISTextEntryBox:new(self.shopDef.background or "", PAD, y, self.width - PAD * 2, FH)
    self.bgInput:initialise()
    self.bgInput:instantiate()
    self.bgInput:setFont(FONT, 0)
    self:addChild(self.bgInput)
    y = y + FH + PAD

    -- ── Category ────────────────────────────────────────────────────────────
    y = y + LH
    self.catInput = ISTextEntryBox:new(self.shopDef.category or "", PAD, y, self.width - PAD * 2, FH)
    self.catInput:initialise()
    self.catInput:instantiate()
    self.catInput:setFont(FONT, 0)
    self:addChild(self.catInput)
    y = y + FH + PAD

    -- ── Default view toggle ──────────────────────────────────────────────────
    y = y + LH
    local btnW = 70
    self.gridBtn = ISButton:new(PAD, y - 2, btnW, FH, "Grid", self, UI.onSetViewGrid)
    self.gridBtn:initialise()
    self.gridBtn:instantiate()
    self.gridBtn.font = FONT
    self:addChild(self.gridBtn)

    self.listBtn = ISButton:new(PAD + btnW + 6, y - 2, btnW, FH, "List", self, UI.onSetViewList)
    self.listBtn:initialise()
    self.listBtn:instantiate()
    self.listBtn.font = FONT
    self:addChild(self.listBtn)

    self:refreshViewButtons()
    y = y + FH + PAD

    -- ── Save / Cancel ────────────────────────────────────────────────────────
    local saveBtnW = 100
    local cancelBtnW = 80
    local btnH = 28
    local btnY = self.height - btnH - PAD

    self.saveBtn = ISButton:new(PAD, btnY, saveBtnW, btnH, "Save", self, UI.onSave)
    self.saveBtn:initialise()
    self.saveBtn:instantiate()
    self.saveBtn.font = FONT
    self.saveBtn.backgroundColor = {r = 0.04, g = 0.22, b = 0.04, a = 0.90}
    self.saveBtn.backgroundColorMouseOver = {r = 0.08, g = 0.38, b = 0.08, a = 0.95}
    self.saveBtn.borderColor = {r = 0.15, g = 0.65, b = 0.15, a = 1.0}
    self:addChild(self.saveBtn)

    self.cancelBtn = ISButton:new(PAD + saveBtnW + 8, btnY, cancelBtnW, btnH, "Cancel", self, UI.onCancel)
    self.cancelBtn:initialise()
    self.cancelBtn:instantiate()
    self.cancelBtn.font = FONT
    self.cancelBtn.backgroundColor = {r = 0.20, g = 0.04, b = 0.04, a = 0.85}
    self.cancelBtn.backgroundColorMouseOver = {r = 0.38, g = 0.07, b = 0.07, a = 0.95}
    self.cancelBtn.borderColor = {r = 0.55, g = 0.15, b = 0.15, a = 1.0}
    self:addChild(self.cancelBtn)
end

-- ─────────────────────────────────────────────────────────────────────────────

function UI:refreshViewButtons()
    local on  = {r = 0.08, g = 0.35, b = 0.08, a = 0.95}
    local off = {r = 0.08, g = 0.08, b = 0.12, a = 0.80}
    if self.gridBtn then
        self.gridBtn.backgroundColor = self.viewIsGrid and on or off
    end
    if self.listBtn then
        self.listBtn.backgroundColor = (not self.viewIsGrid) and on or off
    end
end

function UI:onSetViewGrid()
    self.viewIsGrid = true
    self:refreshViewButtons()
end

function UI:onSetViewList()
    self.viewIsGrid = false
    self:refreshViewButtons()
end

-- ─────────────────────────────────────────────────────────────────────────────

function UI:onSave()
    -- Build a complete definition so upsertShopDefinition has all required fields.
    -- Structural fields (sprites, poolSets) are preserved from the compiled def.
    local patch = {
        type              = self.shopType,
        category          = self.catInput:getText(),
        background        = self.bgInput:getText(),
        defaultView       = self.viewIsGrid and "grid" or "list",
        sprites           = self.shopDef.sprites,
        unpoweredSprites  = self.shopDef.unpoweredSprites,
        poolSets          = self.shopDef.poolSets,
        throttle          = self.shopDef.throttle,
    }
    sendClientCommand(Core.name, Core.commands.upsertShopDefinition, patch)
    self:close()
end

function UI:onCancel()
    self:close()
end

function UI:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function UI:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function UI:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
    end
end

-- ─────────────────────────────────────────────────────────────────────────────

function UI:prerender()
    ISPanel.prerender(self)
    self:drawRect(0, 0, self.width, self.height, 0.95, 0.05, 0.06, 0.08)
    self:drawRectBorder(0, 0, self.width, self.height, 1.0, 0.35, 0.25, 0.30)
    -- title bar
    self:drawRect(0, 0, self.width, 28, 0.90, 0.08, 0.05, 0.07)
    self:drawRect(0, 28, self.width, 1, 0.60, 0.35, 0.25, 0.40)
end

function UI:render()
    ISPanel.render(self)

    local title = "Edit Shop: " .. tostring(self.shopType)
    local tw = getTextManager():MeasureStringX(FONT, title)
    self:drawText(title, math.floor((self.width - tw) / 2), math.floor((28 - FONT_HGT) / 2), 0.90, 0.75, 0.35, 1, FONT)

    -- field labels (drawn above each input)
    local y = 34
    self:drawText("Background", PAD, y, 0.60, 0.60, 0.65, 1, FONT)
    y = y + LH + FH + PAD
    self:drawText("Category", PAD, y, 0.60, 0.60, 0.65, 1, FONT)
    y = y + LH + FH + PAD
    self:drawText("Default view", PAD, y, 0.60, 0.60, 0.65, 1, FONT)
end
