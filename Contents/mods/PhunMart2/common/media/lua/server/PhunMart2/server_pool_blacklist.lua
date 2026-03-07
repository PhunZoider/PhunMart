if isClient() then
    return
end
require "PhunMart2/core"
local blacklistData = require "PhunMart2/data/blacklist"
local Core = PhunMart

function Core.getBlacklist(refresh)
    if refresh then
        blacklistData = Core.tools.loadTable("blacklist.lua")
    end
    return blacklistData
end

function Core.setBlacklist(data)
    blacklistData = data or {}
    Core.tools.saveTable("blacklist.lua", blacklistData)
end

