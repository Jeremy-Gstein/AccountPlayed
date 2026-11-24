--[[
    AccountPlayed-1.0  –  Public API
    ================================
    Need /played data for your addon?? Save time by checking if the user HAS this data via AccountPlayed.

    Currently Blizzard has no way of tracking or serching other characters on given WoW account.
    AccountPlayed helps bridge this gap by populating a database ( or SavedVariable in lua ).
    Over 100,000 players have installed, shared, and use AccountPlayed across Curse, Wago, Reddit, X, Bluesky, etc..

    The major pain point of AccountPlayed and most requested fix by far has been removing the need to log into each character once.
    To help the community, if your addon uses or relies on populating a database with similar information.. 
    you may find this API to be helpful!

    for any help implementing feel free to send a PR/Issue or for a fast response email: jeremy51b5@pm.me

    USAGE
    --------------
    -- Grab the library anywhere (even before PLAYER_LOGIN):
    local AP = LibStub("AccountPlayed-1.0")

    -- Read data:
    local total = AP:GetAccountTotal()
    local chars = AP:GetAllCharacters()

    -- Subscribe to live updates:
    AP:RegisterCallback("CharacterUpdated", "MyAddon",
        function(event, realm, name, seconds, classFile) ... end)

    EVENTS
    ------
    "CharacterUpdated"  ( realm, name, seconds, classFile )
        Fires after AccountPlayedDB is written for the current character
        (i.e. after every TIME_PLAYED_MSG that changes the stored value).

    DATABASE KEYS
    -------------
    Entries are keyed by character GUID, NOT by "Realm-Name".  Each entry
    returned by this API has { key, guid, name, realm, class, time }.
    Use name/realm for display and key/guid for identity.  Entries saved by
    older versions are keyed "Realm-Name" (guid = nil) until that character
    next logs in.

    API VERSION
    -----------
    1  –  initial release
    2  –  entries keyed by GUID; results include guid; name/realm come from
          stored fields (legacy "Realm-Name" keys still resolve)
--]]

------------------------------------------------------------------------
-- Library registration
------------------------------------------------------------------------


-- Both LibStub and CallbackHandler-1.0 are already loaded by AccountPlayed.
local MAJOR, MINOR = "AccountPlayed-1.0", 2
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end  -- already up-to-date; nothing to do

-- CallbackHandler:New() embeds Register/Unregister on `lib` AND returns
-- the registry object.  We must store that return value ourselves as
-- lib.callbacks — CallbackHandler does NOT assign it automatically.
-- (Same pattern BigWigs uses: BigWigs.callbacks = CH:New(BigWigs))
lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)

lib.API_VERSION = 2

------------------------------------------------------------------------
-- Private helpers
------------------------------------------------------------------------

-- Legacy DB key format is "RealmName-CharName" (current entries are keyed by
-- GUID and carry name/realm fields).  Character names never contain a hyphen,
-- so legacy keys are split on the LAST hyphen.
local function ParseKey(key)
    local realm = key:match("^(.+)%-[^%-]+$")
    local name  = key:match("%-([^%-]+)$")
    return realm or key, name or key
end

-- Realm and name for any entry, preferring the stored fields.
local function ResolveIdentity(key, data)
    local realm, name = data.realm, data.name
    if not realm or not name then
        local pRealm, pName = ParseKey(tostring(key))
        realm = realm or pRealm
        name  = name or pName
    end
    return realm, name
end

local function CurrentRealmName()
    return (GetNormalizedRealmName and GetNormalizedRealmName()) or GetRealmName()
end

------------------------------------------------------------------------
-- Version helpers
------------------------------------------------------------------------

function lib:GetAPIVersion()
    return self.API_VERSION
end

--- Returns true when the caller's minimum required version is satisfied.
function lib:IsAPICompatible(required)
    return (tonumber(required) or 0) <= self.API_VERSION
end

------------------------------------------------------------------------
-- Account-wide aggregates
------------------------------------------------------------------------

--- Total played time across all tracked characters, in seconds.
function lib:GetAccountTotal()
    local total = 0
    if type(AccountPlayedDB) ~= "table" then return total end
    for _, data in pairs(AccountPlayedDB) do
        if type(data) == "table" and type(data.time) == "number" then
            total = total + data.time
        end
    end
    return total
end

--- Per-class totals.
-- @return classTotals table (classFile → seconds), accountTotal number
function lib:GetClassTotals()
    local totals, accountTotal = {}, 0
    if type(AccountPlayedDB) ~= "table" then return totals, 0 end
    for _, data in pairs(AccountPlayedDB) do
        if type(data) == "table" and data.time and data.class then
            totals[data.class] = (totals[data.class] or 0) + data.time
            accountTotal = accountTotal + data.time
        end
    end
    return totals, accountTotal
end

--- All tracked characters, sorted descending by time.
-- Each entry: { key, guid, name, realm, class, time }
function lib:GetAllCharacters()
    local out = {}
    if type(AccountPlayedDB) ~= "table" then return out end
    for key, data in pairs(AccountPlayedDB) do
        if type(data) == "table" and data.time then
            local realm, name = ResolveIdentity(key, data)
            out[#out + 1] = {
                key   = key,
                guid  = data.guid,
                name  = name,
                realm = realm,
                class = data.class or "UNKNOWN",
                time  = data.time,
            }
        end
    end
    table.sort(out, function(a, b) return a.time > b.time end)
    return out
end

--- Characters of a specific class, sorted descending by time.
-- @param classFile  string  e.g. "WARRIOR", "MAGE"
-- Each entry: { key, guid, name, realm, class, time }
function lib:GetCharactersByClass(classFile)
    local out = {}
    if type(AccountPlayedDB) ~= "table" then return out end
    for key, data in pairs(AccountPlayedDB) do
        if type(data) == "table" and data.class == classFile and data.time then
            local realm, name = ResolveIdentity(key, data)
            out[#out + 1] = {
                key   = key,
                guid  = data.guid,
                name  = name,
                realm = realm,
                class = data.class,
                time  = data.time,
            }
        end
    end
    table.sort(out, function(a, b) return a.time > b.time end)
    return out
end

--- Number of tracked characters.
function lib:GetCharacterCount()
    local n = 0
    if type(AccountPlayedDB) ~= "table" then return n end
    for _, data in pairs(AccountPlayedDB) do
        if type(data) == "table" and data.time then
            n = n + 1
        end
    end
    return n
end

------------------------------------------------------------------------
-- Single-character queries
------------------------------------------------------------------------

--- Data for a specific character, or nil if not tracked.
-- Matched on stored name + realm.  If several tracked characters share both
-- (e.g. a deleted and re-created character), the one with the most time wins.
-- Returns { key, guid, name, realm, class, time }
function lib:GetCharacterData(realm, name)
    if type(AccountPlayedDB) ~= "table" then return nil end
    local best
    for key, data in pairs(AccountPlayedDB) do
        if type(data) == "table" and data.time then
            local r, n = ResolveIdentity(key, data)
            if r == realm and n == name and (not best or data.time > best.time) then
                best = { key = key, guid = data.guid, name = n, realm = r,
                         class = data.class or "UNKNOWN", time = data.time }
            end
        end
    end
    return best
end

--- True when the character has a tracked entry.
function lib:HasCharacter(realm, name)
    return self:GetCharacterData(realm, name) ~= nil
end

--- Played time for the currently logged-in character, or nil.
function lib:GetCurrentCharacterTime()
    if not UnitName then return nil end
    local guid = UnitGUID and UnitGUID("player")
    local entry = guid and type(AccountPlayedDB) == "table" and AccountPlayedDB[guid]
    if type(entry) == "table" and entry.time then
        return entry.time
    end
    local name  = UnitName("player")
    local realm = CurrentRealmName()
    if not name or not realm then return nil end
    local data = self:GetCharacterData(realm, name)
    return data and data.time or nil
end

------------------------------------------------------------------------
-- Time formatting
------------------------------------------------------------------------

--- "Xd Yh"
function lib:FormatTime(seconds)
    seconds = tonumber(seconds) or 0
    local h = math.floor(seconds / 3600)
    return string.format("%dd %dh", math.floor(h / 24), h % 24)
end

--- "Xh" (total hours)
function lib:FormatTimeHours(seconds)
    return string.format("%dh", math.floor((tonumber(seconds) or 0) / 3600))
end

--- "Xd Yh" for ≥1 day, otherwise "Xh Ym"
function lib:FormatTimeDetailed(seconds)
    seconds = tonumber(seconds) or 0
    local totalH = math.floor(seconds / 3600)
    local days   = math.floor(totalH / 24)
    if days > 0 then
        return string.format("%dd %dh", days, totalH % 24)
    end
    return string.format("%dh %dm", totalH, math.floor((seconds % 3600) / 60))
end

------------------------------------------------------------------------
-- Friendly callback wrappers
--
-- CallbackHandler-1.0 has a sharp edge: RegisterCallback must be called
-- with a *consumer-owned* table as `self` (using `.` not `:`).  Calling
-- it as a method on the library (`lib:RegisterCallback(...)`) passes
-- `lib` as self, which CallbackHandler explicitly rejects.
--
-- These wrappers hide that entirely.  Consumers only need a unique name
-- and a function; we manage the per-consumer handler table internally.
--
--   USAGE
--   -----
--   local AP = LibStub("AccountPlayed-1.0")
--
--   -- Subscribe:
--   AP:OnCharacterUpdated("MyAddon", function(realm, name, seconds, class)
--       print(realm, name, seconds, class)
--   end)
--
--   -- Unsubscribe:
--   AP:OffCharacterUpdated("MyAddon")
------------------------------------------------------------------------

-- Internal registry: consumerName → { _handler table used with CallbackHandler }
lib._consumers = lib._consumers or {}

--- Subscribe to CharacterUpdated.
-- @param name  string  A unique key for your addon (used to unsubscribe later).
-- @param fn    function  Called as fn(realm, name, seconds, classFile).
function lib:OnCharacterUpdated(name, fn)
    assert(type(name) == "string" and name ~= "", "OnCharacterUpdated: 'name' must be a non-empty string")
    assert(type(fn)   == "function",              "OnCharacterUpdated: 'fn' must be a function")

    -- Unregister any previous handler for this name so re-registering is safe.
    self:OffCharacterUpdated(name)

    -- Each consumer gets its own handler table (CallbackHandler requirement).
    local handler = {
        _fn = function(event, realm, charName, seconds, classFile)
            fn(realm, charName, seconds, classFile)
        end,
    }
    self._consumers[name] = handler

    -- Register using . notation so CallbackHandler sees `handler` as self.
    lib.RegisterCallback(handler, "CharacterUpdated", handler._fn)
end

--- Unsubscribe from CharacterUpdated.
-- @param name  string  The same key passed to OnCharacterUpdated.
function lib:OffCharacterUpdated(name)
    local handler = self._consumers[name]
    if handler then
        lib.UnregisterCallback(handler, "CharacterUpdated")
        self._consumers[name] = nil
    end
end

------------------------------------------------------------------------
-- Hook the main addon's event frame to fire "CharacterUpdated"
--
-- We wrap SetScript *once* (MINOR-guarded by LibStub above) so that
-- the library can emit the callback after the DB has been written.
-- We deliberately do NOT replace the original handler and instead, chain it.
------------------------------------------------------------------------

local mainFrame = AccountPlayed and AccountPlayed.mainFrame
if mainFrame then
    local orig = mainFrame:GetScript("OnEvent")

    mainFrame:SetScript("OnEvent", function(self, event, ...)
        -- Run the original handler first so the DB is already updated.
        if orig then orig(self, event, ...) end

        if event == "TIME_PLAYED_MSG" then
            local seconds = ...
            local _, cls  = UnitClass("player")

            -- Only fire when the DB actually accepted the new value
            -- (the main addon skips values that are not newer).
            local key  = AccountPlayed.GetCurrentKey and AccountPlayed.GetCurrentKey()
            local data = key and AccountPlayedDB and AccountPlayedDB[key]
            if data and type(data) == "table" and data.time == seconds then
                local realm, name = ResolveIdentity(key, data)
                lib.callbacks:Fire("CharacterUpdated", realm, name, seconds, data.class or cls or "UNKNOWN")
            end
        end
    end)
end
