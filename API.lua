--[[
AccountPlayed-1.0 public API

local Played = LibStub("AccountPlayed-1.0")

local total = Played:GetAccountTotal()
local characters = Played:GetAllCharacters()

Played:OnCharacterUpdated("MyAddon", function(realm, name, seconds, classFile, raceFile, factionFile)
    -- The stored record changed.
end)

Played:OffCharacterUpdated("MyAddon")

Advanced CallbackHandler consumers may instead register with their own object:
Played.RegisterCallback(myObject, "CharacterUpdated", "OnCharacterUpdated")

API versions:
  1 - original class/time queries
  2 - race/faction metadata and totals
--]]

local _, AP = ...

local MAJOR, MINOR = "AccountPlayed-1.0", 2
local library = LibStub:NewLibrary(MAJOR, MINOR)
if not library then return end

library.callbacks = library.callbacks or LibStub("CallbackHandler-1.0"):New(library)
library.API_VERSION = 2
library._consumers = library._consumers or {}

function library:GetAPIVersion()
    return self.API_VERSION
end

function library:IsAPICompatible(required)
    return (tonumber(required) or 0) <= self.API_VERSION
end

function library:GetAccountTotal()
    return AP.Data:GetAccountTotal()
end

function library:GetClassTotals()
    return AP.Data:GetClassTotals()
end

function library:GetRaceTotals()
    return AP.Data:GetRaceTotals()
end

function library:GetFactionTotals()
    return AP.Data:GetFactionTotals()
end

function library:GetAllCharacters()
    return AP.Data:GetAllCharacters()
end

function library:GetCharactersByClass(classFile)
    return AP.Data:GetCharactersByClass(classFile)
end

function library:GetCharacterCount()
    return AP.Data:GetCharacterCount()
end

function library:GetCharacterData(realm, name)
    return AP.Data:GetCharacterData(realm, name)
end

function library:HasCharacter(realm, name)
    return self:GetCharacterData(realm, name) ~= nil
end

function library:GetCurrentCharacterTime()
    local realm, name = AP.Data:GetCurrentCharacterIdentity()
    if not realm or not name then return nil end
    local character = AP.Data:GetCharacterData(realm, name)
    return character and character.time or nil
end

function library:FormatTime(seconds)
    seconds = tonumber(seconds) or 0
    local hours = math.floor(seconds / 3600)
    return string.format("%dd %dh", math.floor(hours / 24), hours % 24)
end

function library:FormatTimeHours(seconds)
    return string.format("%dh", math.floor((tonumber(seconds) or 0) / 3600))
end

function library:FormatTimeDetailed(seconds)
    seconds = tonumber(seconds) or 0
    local totalHours = math.floor(seconds / 3600)
    local days = math.floor(totalHours / 24)
    if days > 0 then
        return string.format("%dd %dh", days, totalHours % 24)
    end
    return string.format("%dh %dm", totalHours, math.floor((seconds % 3600) / 60))
end

function library:OnCharacterUpdated(consumerName, callback)
    assert(type(consumerName) == "string" and consumerName ~= "",
        "OnCharacterUpdated: 'consumerName' must be a non-empty string")
    assert(type(callback) == "function", "OnCharacterUpdated: 'callback' must be a function")

    self:OffCharacterUpdated(consumerName)
    local handler = {
        callback = function(_, realm, name, seconds, classFile, raceFile, factionFile)
            callback(realm, name, seconds, classFile, raceFile, factionFile)
        end,
    }
    self._consumers[consumerName] = handler
    library.RegisterCallback(handler, "CharacterUpdated", handler.callback)
end

function library:OffCharacterUpdated(consumerName)
    local handler = self._consumers[consumerName]
    if not handler then return end
    library.UnregisterCallback(handler, "CharacterUpdated")
    self._consumers[consumerName] = nil
end

AP:RegisterMessage("CHARACTER_UPDATED", function(character, changed)
    if not changed or not character then return end
    library.callbacks:Fire(
        "CharacterUpdated",
        character.realm,
        character.name,
        character.time,
        character.class,
        character.race,
        character.faction)
end)

AP.API = library
