require("PhunMart2/core")
local Core = PhunMart

Core.purchases = {}

local function getCharname(player)
    return tostring(player:getDescriptor():getForename() .. " " .. player:getDescriptor():getSurname())
end

function Core.purchases:get(player)

    if not player then
        return nil
    end
    local username = player:getUsername()
    if not self.histories then
        self.histories = {}
    end
    if not self.histories[username] then
        self.histories[username] = {}
    end
    return self.histories[username]

end

function Core.purchases:add(player, key, value)
    local purchases = self:get(player)
    local charname = getCharname(player)
    if not purchases[charname] then
        purchases[charname] = {}
    end
    if not purchases[charname][key] then
        purchases[charname][key] = {}
    end
    table.insert(purchases[charname][key], {
        value = value or 1,
        timestamp = getTimestamp(),
        age = GameTime:getInstance():getWorldAgeHours()
    })
end

-- Returns purchase counts for a player keyed by username + charId.
-- scope: "character" counts only entries for charId; anything else counts all chars on the account.
-- Called by conditions runtime as: getCount(scope, username, charId, key, windowSeconds)
function Core.purchases:getCount(scope, username, charId, key, windowSeconds)
    if not self.histories then
        return 0
    end
    local playerHistory = self.histories[username]
    if not playerHistory then
        return 0
    end

    local now = getTimestamp()
    local byChar = (scope == "character")
    local total = 0

    for charName, charHistory in pairs(playerHistory) do
        if not byChar or charName == charId then
            local entries = charHistory[key]
            if entries then
                for _, e in ipairs(entries) do
                    if not windowSeconds or (now - e.timestamp <= windowSeconds) then
                        total = total + (e.value or 1)
                    end
                end
            end
        end
    end

    return total
end

function Core.purchases:load()
    self.histories = Core.tools.loadTable("PhunMart2_Purchases.lua")
end

function Core.purchases:save()
    Core.tools.saveTable("PhunMart2_Purchases.lua", self.histories or {})
end
