-- PhunMart2/traits.lua
-- Shared trait definition cache. Lazy-built on first access.
-- Keyed by trait type string (e.g. "base:blacksmith").
--
-- Each entry: { def, label, cost, description, texture, disabledMP, mutex }
--
-- Usage:
--   local Traits = require "PhunMart2/traits"
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
        print("[PhunMart2] Traits cache build error: " .. tostring(err))
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
-- Uses player:getCharacterTraits():getKnownTraits() — mirrors vanilla B42 pattern.
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
    print("[PhunMart2] Traits.playerHas: getCharacterTraits() failed for '" .. traitKey .. "'")
    return false
end

return Traits
