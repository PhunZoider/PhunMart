-- PhunMart/traits.lua
-- Shared trait definition cache. Lazy-built on first access.
-- Keyed by trait type string (e.g. "base:blacksmith").
--
-- Each entry: { def, label, cost, description, texture, disabledMP, mutex }
--
-- Usage:
--   local Traits = require "PhunMart/traits"
--   Traits.get("base:blacksmith")       → entry or nil
--   Traits.getLabel("base:blacksmith")  → display name or key fallback
--   Traits.playerHas(player, key)       → boolean
local Traits = {}
local _cache = nil

local function build()
    _cache = {}
    if not CharacterTraitDefinition then
        return
    end
    local ok, err = pcall(function()
        local all = CharacterTraitDefinition.getTraits()
        for i = 0, all:size() - 1 do
            local t = all:get(i)
            if t then
                local key = tostring(t:getType())
                local mutex = {}
                local disabledMP = false
                pcall(function()
                    local mlist = t:getMutuallyExclusiveTraits()
                    if mlist then
                        for j = 0, mlist:size() - 1 do
                            local m = mlist:get(j)
                            if m then
                                mutex[#mutex + 1] = tostring(m)
                            end
                        end
                    end
                    disabledMP = t.isRemoveInMP and t:isRemoveInMP()
                end)
                local tex = t:getTexture()
                _cache[key] = {
                    def = t,
                    label = tostring(t:getLabel()),
                    cost = t:getCost(),
                    description = tostring(t:getDescription() or ""),
                    texture = tex and tostring(tex:getName()) or "",
                    disabledMP = disabledMP,
                    mutex = mutex
                }
            end
        end
    end)
    if not ok then
        Core.debugLn("Traits cache build error: " .. tostring(err))
    end
end

-- Returns the full cache table (built on first call).
function Traits.cache()
    if not _cache then
        build()
    end
    return _cache
end

-- Returns the cache entry for a trait key, or nil if unknown.
function Traits.get(key)
    return Traits.cache()[key]
end

-- Returns the display label for a trait key, or the key itself as fallback.
function Traits.getLabel(key)
    local entry = Traits.get(key)
    return entry and entry.label or key
end

-- Returns the Texture object for a trait key, or nil. Client-side only.
function Traits.getTexture(key)
    local entry = Traits.get(key)
    if not entry or entry.texture == "" then
        return nil
    end
    return getTexture and getTexture(entry.texture) or nil
end

-- Returns the trait key from an offer's reward actions (addTrait/removeTrait), or nil.
function Traits.getOfferTraitKey(offer)
    if not offer or not offer.reward or not offer.reward.actions then
        return nil
    end
    for _, action in ipairs(offer.reward.actions) do
        if (action.type == "addTrait" or action.type == "removeTrait") and action.trait then
            return action.trait
        end
    end
    return nil
end

-- Returns true if the player currently has the trait.
-- traitKey: string type key (e.g. "base:blacksmith")
-- Uses player:getCharacterTraits():getKnownTraits(), mirroring the vanilla B42 pattern.
function Traits.playerHas(player, traitKey)
    if not player or traitKey == nil then
        return false
    end
    local ok, result = pcall(function()
        local known = player:getCharacterTraits():getKnownTraits()
        if not known then
            return false
        end
        for i = 0, known:size() - 1 do
            local def = CharacterTraitDefinition.getCharacterTraitDefinition(known:get(i))
            if def and tostring(def:getType()) == traitKey then
                return true
            end
        end
        return false
    end)
    if ok then
        return result == true
    end
    Core.debugLn("Traits.playerHas: getCharacterTraits() failed for '" .. traitKey .. "'")
    return false
end


-- Stats a trait keeps topped up, which nothing brings back down once the trait
-- is gone.
--
-- Smoker is the one that bites. It feeds CharacterStat.NICOTINE_WITHDRAWAL,
-- which BodyDamage.UpdateBoredom only raises while the trait is held, and which
-- only ever falls when tobacco is smoked. The stress moodle does not read
-- CharacterStat.STRESS -- it reads Stats.getNicotineStress(), which is STRESS
-- plus NICOTINE_WITHDRAWAL, and neither the moodle nor that sum asks whether
-- the character still smokes. So a player who bought "Remove: Smoker" while
-- withdrawing kept the stress moodle for good: the trait that could have spent
-- the stat was the very thing they just sold back. Smoking with the trait
-- re-added and then removing it again cleared it, which is the manual version
-- of what this table does.
--
-- Each entry names the trait, the stat it strands, and anything else that
-- wants resetting alongside it.
local REMOVAL_CLEANUP = {{
    trait = "base:smoker",
    stat = function()
        return CharacterStat.NICOTINE_WITHDRAWAL
    end,
    also = function(player)
        -- Vanilla resets this whenever a cigarette is smoked. Leaving it high
        -- means the withdrawal starts climbing again the instant the trait
        -- comes back, which is not what a fresh removal should leave behind.
        player:setTimeSinceLastSmoke(0)
    end
}}

local function applyCleanup(entry, player)
    local stat = entry.stat()
    player:getStats():set(stat, 0)
    if entry.also then
        entry.also(player)
    end
    return stat
end

-- Clears what a trait removal strands. Call it on whichever side is holding the
-- character: the stats are the client's in MP, so the server clears its own
-- copy and asks the owning client to do the same.
-- Returns the CharacterStat that was cleared, or nil if the trait strands none.
function Traits.clearRemovalSideEffects(player, traitKey)
    if not player or traitKey == nil then
        return nil
    end
    local key = string.lower(tostring(traitKey))
    for _, entry in ipairs(REMOVAL_CLEANUP) do
        if entry.trait == key then
            local ok, result = pcall(applyCleanup, entry, player)
            if ok then
                return result
            end
            Core.debugLn("Traits.clearRemovalSideEffects: failed for '" .. key .. "': " .. tostring(result))
            return nil
        end
    end
    return nil
end

-- Repairs a character carrying leftovers from a removal that happened before
-- the cleanup above existed. Nothing in vanilla can raise these stats on a
-- character who does not hold the trait, so a non-zero reading is always
-- stranded and always safe to clear.
-- Returns the list of stats cleared, empty when there was nothing to do.
function Traits.repairOrphanedStats(player)
    local cleared = {}
    if not player then
        return cleared
    end
    for _, entry in ipairs(REMOVAL_CLEANUP) do
        if not Traits.playerHas(player, entry.trait) then
            local ok, result = pcall(function()
                local stat = entry.stat()
                if player:getStats():get(stat) > 0 then
                    return applyCleanup(entry, player)
                end
            end)
            if ok then
                if result then
                    cleared[#cleared + 1] = result
                end
            else
                Core.debugLn("Traits.repairOrphanedStats: failed for '" .. entry.trait .. "': " .. tostring(result))
            end
        end
    end
    return cleared
end

return Traits
