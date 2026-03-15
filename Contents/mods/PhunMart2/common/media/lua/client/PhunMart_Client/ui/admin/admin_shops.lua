if isServer() then
    return
end

require "ISUI/ISPanel"

local Core = PhunMart
local tools = require "PhunMart_Client/ui/ui_utils"
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_SCALE = FONT_HGT_SMALL / 14

local PAD = math.max(10, math.floor(10 * FONT_SCALE))
local ROW_H = FONT_HGT_SMALL + math.floor(6 * FONT_SCALE)

local windowName = "PhunShopEditModal"

Core.ui.admin_shops = {}
local AdminShops = Core.ui.admin_shops

---------------------------------------------------------------------------
-- Pool Set Entry Sub-panel (one row: pool key + weight)
---------------------------------------------------------------------------

-- Format poolSets for display: "[6,9] pool_a(1.0), pool_b(0.5) | pool_c(1.0)"
local function formatPoolSets(def)
    if not def.poolSets then
        return ""
    end
    local setParts = {}
    for _, set in ipairs(def.poolSets) do
        local prefix = ""
        if set.roll and set.roll.count then
            local c = set.roll.count
            prefix = "[" .. tostring(c.min) .. "," .. tostring(c.max) .. "] "
        end
        local keyParts = {}
        if set.keys then
            for _, entry in ipairs(set.keys) do
                table.insert(keyParts, entry.key .. "(" .. tostring(entry.weight or 1.0) .. ")")
            end
        end
        table.insert(setParts, prefix .. table.concat(keyParts, ", "))
    end
    return table.concat(setParts, " | ")
end

-- Parse pool sets from a text representation.
-- Format: "[6,9] pool_a:1.0, pool_b:0.5 | [3,5] pool_c:1.0"
-- Optional [min,max] prefix per set overrides shop-level roll.
-- Sets separated by |, keys separated by commas, key:weight pairs.
local function parsePoolSets(text)
    if not text or text == "" then
        return nil
    end
    local sets = {}
    for setPart in text:gmatch("[^|]+") do
        setPart = setPart:match("^%s*(.-)%s*$")
        -- check for optional [min,max] roll prefix
        local setRoll = nil
        local rollMin, rollMax, rest = setPart:match("^%[(%d+)%s*[,%-]%s*(%d+)%]%s*(.*)")
        if rollMin then
            setRoll = { mode = "weighted", count = { min = tonumber(rollMin), max = tonumber(rollMax) } }
            setPart = rest
        end
        local keys = {}
        for entry in setPart:gmatch("[^,]+") do
            entry = entry:match("^%s*(.-)%s*$")
            if entry ~= "" then
                local key, weight = entry:match("^(.-)%s*:%s*(.+)$")
                if key then
                    key = key:match("^%s*(.-)%s*$")
                    table.insert(keys, {
                        key = key,
                        weight = tonumber(weight) or 1.0
                    })
                else
                    table.insert(keys, {
                        key = entry,
                        weight = 1.0
                    })
                end
            end
        end
        if #keys > 0 then
            local set = { keys = keys }
            if setRoll then
                set.roll = setRoll
            end
            table.insert(sets, set)
        end
    end
    if #sets == 0 then
        return nil
    end
    return sets
end

-- Format poolSets for editing: "[6,9] pool_a:1.0, pool_b:0.5 | pool_c:1.0"
local function formatPoolSetsForEdit(def)
    if not def.poolSets then
        return ""
    end
    local setParts = {}
    for _, set in ipairs(def.poolSets) do
        local prefix = ""
        if set.roll and set.roll.count then
            local c = set.roll.count
            prefix = "[" .. tostring(c.min) .. "," .. tostring(c.max) .. "] "
        end
        local keyParts = {}
        if set.keys then
            for _, entry in ipairs(set.keys) do
                table.insert(keyParts, entry.key .. ":" .. tostring(entry.weight or 1.0))
            end
        end
        table.insert(setParts, prefix .. table.concat(keyParts, ", "))
    end
    return table.concat(setParts, " | ")
end

---------------------------------------------------------------------------
-- Edit Modal
---------------------------------------------------------------------------
local EditModal = ISPanel:derive(windowName)

function EditModal:createChildren()
    ISPanel.createChildren(self)

    local x = PAD
    local y = PAD
    local w = self.width - PAD * 2
    local labelW = getTextManager():MeasureStringX(UIFont.Small, "Restock Frequency: ") + 8

    -- Title
    local titleText = getText("IGUI_PhunMart_Title_EditX", self.shopKey)
    self.titleLabel = ISLabel:new(x, y, FONT_HGT_MEDIUM, titleText, 1, 1, 1, 1, UIFont.Medium, true)
    self.titleLabel:initialise()
    self:addChild(self.titleLabel)
    y = y + FONT_HGT_MEDIUM + PAD

    -- Enabled
    self.enabledLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Enabled"), 1, 1, 1, 1, UIFont.Small, true)
    self.enabledLabel:initialise()
    self:addChild(self.enabledLabel)

    self.enabledTick = ISTickBox:new(x + labelW, y, ROW_H, ROW_H, "")
    self.enabledTick:initialise()
    self.enabledTick:instantiate()
    self.enabledTick:addOption("")
    self.enabledTick:setSelected(1, self.shopDef.enabled ~= false)
    self:addChild(self.enabledTick)
    y = y + ROW_H + PAD

    -- Category
    self.catLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Category"), 1, 1, 1, 1, UIFont.Small, true)
    self.catLabel:initialise()
    self:addChild(self.catLabel)

    self.catEntry = ISTextEntryBox:new(self.shopDef.category or "", x + labelW, y, w - labelW, ROW_H)
    self.catEntry:initialise()
    self.catEntry:instantiate()
    self:addChild(self.catEntry)
    y = y + ROW_H + 2

    self.catHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_CategoryShown"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.catHint:initialise()
    self:addChild(self.catHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Probability
    self.probLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Probability"), 1, 1, 1, 1, UIFont.Small, true)
    self.probLabel:initialise()
    self:addChild(self.probLabel)

    local probDefault = tostring(self.shopDef.probability or 1)
    self.probEntry = ISTextEntryBox:new(probDefault, x + labelW, y, w - labelW, ROW_H)
    self.probEntry:initialise()
    self.probEntry:instantiate()
    self:addChild(self.probEntry)
    y = y + ROW_H + 2

    self.probHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_Probability"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.probHint:initialise()
    self:addChild(self.probHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Min Distance
    self.distLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_MinDistance"), 1, 1, 1, 1, UIFont.Small, true)
    self.distLabel:initialise()
    self:addChild(self.distLabel)

    local distDefault = self.shopDef.minDistance and tostring(self.shopDef.minDistance) or ""
    self.distEntry = ISTextEntryBox:new(distDefault, x + labelW, y, w - labelW, ROW_H)
    self.distEntry:initialise()
    self.distEntry:instantiate()
    self:addChild(self.distEntry)
    y = y + ROW_H + 2

    self.distHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_MinDistance"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.distHint:initialise()
    self:addChild(self.distHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Restock Frequency
    self.restockLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_RestockFrequency"), 1, 1, 1, 1, UIFont.Small, true)
    self.restockLabel:initialise()
    self:addChild(self.restockLabel)

    local restockDefault = self.shopDef.restockFrequency and tostring(self.shopDef.restockFrequency) or ""
    self.restockEntry = ISTextEntryBox:new(restockDefault, x + labelW, y, w - labelW, ROW_H)
    self.restockEntry:initialise()
    self.restockEntry:instantiate()
    self:addChild(self.restockEntry)
    y = y + ROW_H + 2

    self.restockHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_RestockFrequency"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.restockHint:initialise()
    self:addChild(self.restockHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Default View
    self.viewLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_DefaultView"), 1, 1, 1, 1, UIFont.Small, true)
    self.viewLabel:initialise()
    self:addChild(self.viewLabel)

    self.viewCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H)
    self.viewCombo:initialise()
    self.viewCombo:addOption("grid")
    self.viewCombo:addOption("list")
    self.viewCombo.selected = (self.shopDef.defaultView == "list") and 2 or 1
    self:addChild(self.viewCombo)
    y = y + ROW_H + 2

    self.viewHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_ViewMode"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.viewHint:initialise()
    self:addChild(self.viewHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Background
    self.bgLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Background"), 1, 1, 1, 1, UIFont.Small, true)
    self.bgLabel:initialise()
    self:addChild(self.bgLabel)

    self.bgEntry = ISTextEntryBox:new(self.shopDef.background or "", x + labelW, y, w - labelW, ROW_H)
    self.bgEntry:initialise()
    self.bgEntry:instantiate()
    self:addChild(self.bgEntry)
    y = y + ROW_H + 2

    self.bgHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_Background"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.bgHint:initialise()
    self:addChild(self.bgHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Sprites
    self.spritesLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Sprites"), 1, 1, 1, 1, UIFont.Small, true)
    self.spritesLabel:initialise()
    self:addChild(self.spritesLabel)

    local spritesDefault = self.shopDef.sprites and table.concat(self.shopDef.sprites, ", ") or ""
    self.spritesEntry = ISTextEntryBox:new(spritesDefault, x + labelW, y, w - labelW, ROW_H)
    self.spritesEntry:initialise()
    self.spritesEntry:instantiate()
    self:addChild(self.spritesEntry)
    y = y + ROW_H + 2

    self.spritesHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_Sprites"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.spritesHint:initialise()
    self:addChild(self.spritesHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Unpowered Sprites
    self.unpSpritesLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_UnpSprites"), 1, 1, 1, 1, UIFont.Small, true)
    self.unpSpritesLabel:initialise()
    self:addChild(self.unpSpritesLabel)

    local unpSpritesDefault = self.shopDef.unpoweredSprites and table.concat(self.shopDef.unpoweredSprites, ", ") or ""
    self.unpSpritesEntry = ISTextEntryBox:new(unpSpritesDefault, x + labelW, y, w - labelW, ROW_H)
    self.unpSpritesEntry:initialise()
    self.unpSpritesEntry:instantiate()
    self:addChild(self.unpSpritesEntry)
    y = y + ROW_H + 2

    self.unpSpritesHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_UnpSprites"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.unpSpritesHint:initialise()
    self:addChild(self.unpSpritesHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Roll Min (shop-level default for all poolSets)
    self.rollMinLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_RollMin"), 1, 1, 1, 1, UIFont.Small, true)
    self.rollMinLabel:initialise()
    self:addChild(self.rollMinLabel)

    local rollMinDefault = ""
    if self.shopDef.roll and self.shopDef.roll.count then
        rollMinDefault = tostring(self.shopDef.roll.count.min or "")
    end
    self.rollMinEntry = ISTextEntryBox:new(rollMinDefault, x + labelW, y, (w - labelW - PAD) / 2, ROW_H)
    self.rollMinEntry:initialise()
    self.rollMinEntry:instantiate()
    self:addChild(self.rollMinEntry)

    -- Roll Max (inline next to min)
    self.rollMaxLabel = ISLabel:new(x + labelW + (w - labelW - PAD) / 2 + PAD, y, ROW_H, "-", 1, 1, 1, 1, UIFont.Small, true)
    self.rollMaxLabel:initialise()
    self:addChild(self.rollMaxLabel)

    local rollMaxDefault = ""
    if self.shopDef.roll and self.shopDef.roll.count then
        rollMaxDefault = tostring(self.shopDef.roll.count.max or "")
    end
    local dashW = getTextManager():MeasureStringX(UIFont.Small, "- ") + 4
    self.rollMaxEntry = ISTextEntryBox:new(rollMaxDefault, x + labelW + (w - labelW - PAD) / 2 + PAD + dashW, y, (w - labelW - PAD) / 2 - dashW, ROW_H)
    self.rollMaxEntry:initialise()
    self.rollMaxEntry:instantiate()
    self:addChild(self.rollMaxEntry)
    y = y + ROW_H + 2

    self.rollHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_ShopRoll"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.rollHint:initialise()
    self:addChild(self.rollHint)
    y = y + FONT_HGT_SMALL + PAD

    -- Pool Sets
    self.poolSetsLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_PoolSets"), 1, 1, 1, 1, UIFont.Small, true)
    self.poolSetsLabel:initialise()
    self:addChild(self.poolSetsLabel)

    local poolSetsDefault = formatPoolSetsForEdit(self.shopDef)
    self.poolSetsEntry = ISTextEntryBox:new(poolSetsDefault, x + labelW, y, w - labelW, ROW_H)
    self.poolSetsEntry:initialise()
    self.poolSetsEntry:instantiate()
    self:addChild(self.poolSetsEntry)
    y = y + ROW_H + 2

    self.poolSetsHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, getText("IGUI_PhunMart_Hint_PoolSets"), 0.5, 0.5, 0.5, 1,
        UIFont.Small, true)
    self.poolSetsHint:initialise()
    self:addChild(self.poolSetsHint)
    y = y + FONT_HGT_SMALL + PAD * 2

    -- Buttons
    local btnW = math.floor(80 * FONT_SCALE)
    local btnGap = PAD
    local totalBtnW = btnW * 2 + btnGap
    local btnX = (self.width - totalBtnW) / 2

    self.applyBtn = ISButton:new(btnX, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Apply"), self, EditModal.onApply)
    self.applyBtn:initialise()
    self:addChild(self.applyBtn)

    self.cancelBtn = ISButton:new(btnX + btnW + btnGap, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Cancel"), self, EditModal.onCancel)
    self.cancelBtn:initialise()
    self:addChild(self.cancelBtn)
end

-- Parse a comma-separated string into a trimmed array. Returns nil for empty input.
local function parseCSV(text)
    if not text or text == "" then
        return nil
    end
    local result = {}
    for s in text:gmatch("[^,]+") do
        s = s:match("^%s*(.-)%s*$")
        if s ~= "" then
            table.insert(result, s)
        end
    end
    if #result == 0 then
        return nil
    end
    return result
end

function EditModal:onApply()
    local def = {}

    -- Enabled
    def.enabled = self.enabledTick:isSelected(1)

    -- Category
    local cat = self.catEntry:getText()
    if cat and cat ~= "" then
        def.category = cat
    end

    -- Probability
    local prob = tonumber(self.probEntry:getText())
    if prob then
        def.probability = prob
    end

    -- Min Distance (optional)
    local dist = tonumber(self.distEntry:getText())
    if dist then
        def.minDistance = dist
    end

    -- Restock Frequency (optional)
    local restock = tonumber(self.restockEntry:getText())
    if restock then
        def.restockFrequency = restock
    end

    -- Default View
    local view = self.viewCombo:getSelectedText()
    if view == "list" then
        def.defaultView = "list"
    end

    -- Background
    local bg = self.bgEntry:getText()
    if bg and bg ~= "" then
        def.background = bg
    end

    -- Sprites
    local sprites = parseCSV(self.spritesEntry:getText())
    if sprites then
        def.sprites = sprites
    end

    -- Unpowered Sprites
    local unpSprites = parseCSV(self.unpSpritesEntry:getText())
    if unpSprites then
        def.unpoweredSprites = unpSprites
    end

    -- Roll (shop-level default for all poolSets)
    local rollMin = tonumber(self.rollMinEntry:getText())
    local rollMax = tonumber(self.rollMaxEntry:getText())
    if rollMin and rollMax then
        def.roll = {
            mode = "weighted",
            count = { min = rollMin, max = rollMax }
        }
    end

    -- Pool Sets
    local poolSets = parsePoolSets(self.poolSetsEntry:getText())
    if poolSets then
        def.poolSets = poolSets
    end

    if self.cb then
        self.cb(self.shopKey, def)
    end

    self:close()
end

function EditModal:onCancel()
    self:close()
end

function EditModal:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function EditModal:new(shopKey, shopDef, cb)
    local modalW = math.floor(560 * FONT_SCALE)
    local modalH = PAD * 15 + FONT_HGT_MEDIUM + ROW_H * 12 + FONT_HGT_SMALL * 10 + PAD * 4
    local core = getCore()
    local sx = (core:getScreenWidth() - modalW) / 2
    local sy = (core:getScreenHeight() - modalH) / 2

    local o = ISPanel:new(sx, sy, modalW, modalH)
    setmetatable(o, self)
    self.__index = self
    o.shopKey = shopKey
    o.shopDef = shopDef or {}
    o.cb = cb
    o.backgroundColor = {
        r = 0.1,
        g = 0.1,
        b = 0.1,
        a = 0.95
    }
    o.borderColor = {
        r = 0.6,
        g = 0.6,
        b = 0.6,
        a = 1
    }
    o.moveWithMouse = true
    return o
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

function AdminShops.OnOpenPanel(player, shopKey)
    local shops = Core.runtime and Core.runtime.shops
    if not shops or not shops[shopKey] then
        return
    end
    local shopDef = shops[shopKey]

    local modal = EditModal:new(shopKey, shopDef, function(key, def)
        def.type = key
        sendClientCommand(Core.name, Core.commands.upsertShopDefinition, def)
        if Core.defs and Core.defs.shops then
            Core.defs.shops[key] = def
        end
        print("[PhunMart] Shop updated: " .. key)
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end
