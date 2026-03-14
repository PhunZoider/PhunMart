if isClient() then
    return
end
require "PhunMart/core"
local Core = PhunMart
local blacklistData = nil
local blacklistDefaults = nil

-- Union-merge two blacklist tables: { items = { exclude = { key=true } } }
-- All keys present in either base or override will be excluded.
local function mergeBlacklists(base, override)
    local baseEx = type(base) == "table" and type(base.items) == "table" and base.items.exclude or {}
    local overEx = type(override) == "table" and type(override.items) == "table" and override.items.exclude or {}
    local merged = {}
    for k, v in pairs(baseEx) do merged[k] = v end
    for k, v in pairs(overEx) do merged[k] = v end
    return { items = { exclude = merged } }
end

-- Load and cache the built-in defaults once.
local function getDefaults()
    if blacklistDefaults == nil then
        local ok, d = pcall(require, "PhunMart/defaults/blacklist")
        blacklistDefaults = (ok and type(d) == "table" and d) or {}
    end
    return blacklistDefaults
end

function Core.getBlacklist(refresh)
    if blacklistData == nil or refresh then
        local override = Core.fileUtils.loadTable("PhunMart_Blacklist.lua") or {}
        blacklistData = mergeBlacklists(getDefaults(), override)
    end
    return blacklistData
end

function Core.setBlacklist(data)
    blacklistData = data or {}
    Core.fileUtils.saveTable("PhunMart_Blacklist.lua", blacklistData)
end

