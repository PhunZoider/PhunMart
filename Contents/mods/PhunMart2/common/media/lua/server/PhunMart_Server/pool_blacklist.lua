if isClient() then
    return
end
require "PhunMart/core"
local blacklistData = nil
local Core = PhunMart

function Core.getBlacklist(refresh)
    if refresh then
        blacklistData = Core.fileUtils.loadTable("blacklist.lua")
    end
    return blacklistData or {}
end

function Core.setBlacklist(data)
    blacklistData = data or {}
    Core.fileUtils.saveTable("blacklist.lua", blacklistData)
end

