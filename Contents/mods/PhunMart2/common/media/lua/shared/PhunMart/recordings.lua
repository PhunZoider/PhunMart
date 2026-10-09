-- Recorded media: VHS tapes, CDs and anything else that carries a recording.
--
-- In the game these are one item each (Base.VHS_Retail, Base.VHS_Home,
-- Base.Disc_Retail) with the title attached afterwards. Only the loot spawner
-- attaches one, so an item a shop hands over by type alone arrives blank.
--
-- A group with `recordings` set sells each title as its own offer instead. The
-- offer's key is the item and the recording joined by SEP, which keeps every
-- title distinct through the pool, the dedupe in buildOffers and the offer id,
-- while offer.item stays the real item so icons and tooltips still work.
--
-- Titles are read from vanilla's RecMedia table, which is what the engine
-- registers its recordings from. It is plain shared Lua, so it is there on
-- both sides before anything compiles, and a mod adding tapes adds them to it.

local Recordings = {}

Recordings.SEP = "#"

-- Line codes that teach a skill, as ISRadioInteractions reads them, mapped to
-- the IGUI_perks_ key that names the skill. Everything else in a code (BOR,
-- STS and the rest) moves a stat and is not worth a label.
local SKILLS = {
    SPR = "Sprinting",
    LFT = "Lightfooted",
    NIM = "Nimble",
    SNE = "Sneaking",
    BAA = "Axe",
    BUA = "Blunt",
    CRP = "Carpentry",
    COO = "Cooking",
    FRM = "Farming",
    DOC = "Doctor",
    ELC = "Electricity",
    MTL = "MetalWelding",
    FKN = "FlintKnapping",
    CRV = "Carving",
    AIM = "Aiming",
    REL = "Reloading",
    FIS = "Fishing",
    TRA = "Trapping",
    FOR = "Foraging",
    TAI = "Tailoring",
    MEC = "Mechanics",
    CMB = "Combat",
    SPE = "Spear",
    SBU = "SmallBlunt",
    LBA = "LongBlade",
    SBA = "SmallBlade",
    MAS = "Masonry",
    POT = "Pottery",
    BLA = "Blacksmith",
    GLA = "Glassmaking",
    HUS = "Husbandry",
    BUT = "Butchering",
    TRK = "Tracking"
}

--- The offer key for one recording on one item.
function Recordings.key(itemType, mediaId)
    return itemType .. Recordings.SEP .. mediaId
end

--- Split an offer key back into item and recording. A key with no recording
--- comes back as itself and nil.
function Recordings.split(key)
    if type(key) ~= "string" then
        return key, nil
    end
    local itemType, mediaId = key:match("^(.-)" .. Recordings.SEP .. "(.+)$")
    if itemType then
        return itemType, mediaId
    end
    return key, nil
end

--- The recording category an item holds ("Retail-VHS"), or nil if it holds none.
function Recordings.categoryOf(itemType)
    local sm = getScriptManager and getScriptManager()
    local scriptItem = sm and sm:FindItem(itemType)
    if not scriptItem or not scriptItem.getRecordedMediaCat then
        return nil
    end
    local cat = scriptItem:getRecordedMediaCat()
    if cat == nil or cat == "" then
        return nil
    end
    return tostring(cat)
end

--- Skill names a recording teaches, as IGUI_perks_ suffixes, sorted. Empty if none.
function Recordings.skillsOf(mediaId)
    local entry = RecMedia and RecMedia[mediaId]
    local found, out = {}, {}
    for _, line in ipairs(entry and entry.lines or {}) do
        for code in tostring(line.codes or ""):gmatch("(%u%u%u)%+") do
            local skill = SKILLS[code]
            if skill and not found[skill] then
                found[skill] = true
                table.insert(out, skill)
            end
        end
    end
    table.sort(out)
    return out
end

--- Every recording in a category, as sorted ids.
function Recordings.idsFor(category)
    local out = {}
    for id, entry in pairs(RecMedia or {}) do
        if entry.category == category then
            table.insert(out, id)
        end
    end
    table.sort(out)
    return out
end

--- Does this recording exist?
function Recordings.exists(mediaId)
    return RecMedia ~= nil and RecMedia[mediaId] ~= nil
end

--- What to call an offer for this recording: its title, plus the skills it
--- teaches. "VHS: Woodcraft E4 (Carpentry)".
function Recordings.label(mediaId)
    local entry = RecMedia and RecMedia[mediaId]
    if not entry then
        return nil
    end
    local label = entry.itemDisplayName and getText(entry.itemDisplayName) or mediaId
    local skills = Recordings.skillsOf(mediaId)
    if #skills > 0 then
        local names = {}
        for i, skill in ipairs(skills) do
            names[i] = getText("IGUI_perks_" .. skill)
        end
        label = label .. " (" .. table.concat(names, ", ") .. ")"
    end
    return label
end

--- Put a recording on an item. Returns true if it took.
function Recordings.apply(item, mediaId)
    if not (item and mediaId and getZomboidRadio) then
        return false
    end
    local radio = getZomboidRadio()
    local media = radio and radio:getRecordedMedia()
    local data = media and media:getMediaData(mediaId)
    if not data then
        return false
    end
    item:setRecordedMediaData(data)
    return true
end

return Recordings
