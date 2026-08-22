-- Account Played
-- Saved-variable migration, validation, and character data access.

local _, AP = ...
local L = AP.L

local Data = {}
AP.Data = Data
AP.modules.Data = Data

local UNKNOWN = "UNKNOWN"
local REQUEST_COOLDOWN = 10
local lastPlayedRequest

local POPUP_DEFAULTS = {
    width = 640,
    height = 380,
    point = "CENTER",
    x = 0,
    y = 0,
    useYears = false,
    activeTab = "class",
    chartMode = "bar",
    valueMode = "both",
    textScale = 1,
}

local MINIMAP_DEFAULTS = {
    x = math.cos(math.rad(225)) * 105,
    y = math.sin(math.rad(225)) * 105,
    locked = false,
    hidden = false,
}

local VALID_POINTS = {
    TOPLEFT = true,
    TOP = true,
    TOPRIGHT = true,
    LEFT = true,
    CENTER = true,
    RIGHT = true,
    BOTTOMLEFT = true,
    BOTTOM = true,
    BOTTOMRIGHT = true,
}

local VALID_TABS = {
    class = true,
    characters = true,
    race = true,
    faction = true,
}

local VALID_CHART_MODES = { bar = true, pie = true }
local VALID_VALUE_MODES = { both = true, days = true, percent = true }
local VALID_GROUP_FIELDS = { class = true, race = true, faction = true }

AP.defaults = AP.defaults or {}
AP.defaults.popup = POPUP_DEFAULTS
AP.defaults.minimap = MINIMAP_DEFAULTS

local function IsFiniteNumber(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function Clamp(value, minimum, maximum, fallback)
    if not IsFiniteNumber(value) then return fallback end
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function NormalizeToken(value)
    if type(value) ~= "string" or value == "" then
        return UNKNOWN
    end
    return value
end

local function NormalizeOptionalLabel(value)
    if type(value) == "string" and value ~= "" then
        return value
    end
    return nil
end

local function IsCharacterData(value)
    return type(value) == "table" and IsFiniteNumber(value.time) and value.time >= 0
end

local function CopyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            target[key] = value
        end
    end
end

local function NormalizeCharacterData(value)
    if type(value) == "number" and IsFiniteNumber(value) and value >= 0 then
        value = { time = value }
    end

    if not IsCharacterData(value) then
        return nil
    end

    value.class = NormalizeToken(value.class)
    value.race = NormalizeToken(value.race)
    value.raceName = NormalizeOptionalLabel(value.raceName)
    value.faction = NormalizeToken(value.faction)
    value.factionName = NormalizeOptionalLabel(value.factionName)
    return value
end

local function NormalizeCharacterDatabase(database)
    if database == nil then
        database = {}
    elseif type(database) ~= "table" then
        print("|cffff0000" .. (L["DB_CORRUPTED"] or "Account Played: SavedVariables corrupted, resetting!") .. "|r")
        database = {}
    end

    for key, value in pairs(database) do
        if type(key) ~= "string" then
            database[key] = nil
        else
            database[key] = NormalizeCharacterData(value)
        end
    end

    return database
end

local function NormalizePopupDatabase(database)
    if type(database) ~= "table" then
        database = {}
    end
    CopyDefaults(database, POPUP_DEFAULTS)

    database.width = Clamp(database.width, 500, 1400, POPUP_DEFAULTS.width)
    database.height = Clamp(database.height, 260, 900, POPUP_DEFAULTS.height)
    database.x = Clamp(database.x, -100000, 100000, POPUP_DEFAULTS.x)
    database.y = Clamp(database.y, -100000, 100000, POPUP_DEFAULTS.y)
    database.textScale = Clamp(database.textScale, 1, 2, POPUP_DEFAULTS.textScale)
    database.point = VALID_POINTS[database.point] and database.point or POPUP_DEFAULTS.point
    database.activeTab = VALID_TABS[database.activeTab] and database.activeTab or POPUP_DEFAULTS.activeTab
    database.chartMode = VALID_CHART_MODES[database.chartMode] and database.chartMode or POPUP_DEFAULTS.chartMode
    database.valueMode = VALID_VALUE_MODES[database.valueMode] and database.valueMode or POPUP_DEFAULTS.valueMode
    database.useYears = database.useYears == true
    return database
end

local function NormalizeMinimapDatabase(database)
    if type(database) ~= "table" then
        database = {}
    end

    if IsFiniteNumber(database.angle) and not IsFiniteNumber(database.x) then
        local angle = math.rad(database.angle)
        database.x = math.cos(angle) * 105
        database.y = math.sin(angle) * 105
    end
    database.angle = nil

    CopyDefaults(database, MINIMAP_DEFAULTS)
    database.x = Clamp(database.x, -100000, 100000, MINIMAP_DEFAULTS.x)
    database.y = Clamp(database.y, -100000, 100000, MINIMAP_DEFAULTS.y)
    database.locked = database.locked == true
    database.hidden = database.hidden == true
    return database
end

function Data:Initialize()
    AccountPlayedDB = NormalizeCharacterDatabase(AccountPlayedDB)
    AccountPlayedPopupDB = NormalizePopupDatabase(AccountPlayedPopupDB)
    AccountPlayedMinimapDB = NormalizeMinimapDatabase(AccountPlayedMinimapDB)

    self.database = AccountPlayedDB
    self.popup = AccountPlayedPopupDB
    self.minimap = AccountPlayedMinimapDB
    self.initialized = true
end

function Data:GetDatabase()
    if type(self.database) == "table" then return self.database end
    if type(AccountPlayedDB) == "table" then return AccountPlayedDB end
    return {}
end

function Data:GetPopupSettings()
    if type(self.popup) == "table" then return self.popup end
    if type(AccountPlayedPopupDB) == "table" then return AccountPlayedPopupDB end
    return POPUP_DEFAULTS
end

function Data:GetMinimapSettings()
    if type(self.minimap) == "table" then return self.minimap end
    if type(AccountPlayedMinimapDB) == "table" then return AccountPlayedMinimapDB end
    return MINIMAP_DEFAULTS
end

function Data:ResetPopupSettings()
    local settings = self:GetPopupSettings()
    for key, value in pairs(POPUP_DEFAULTS) do
        settings[key] = value
    end
    AP:SendMessage("SETTINGS_CHANGED", "popup", nil)
end

function Data:ResetMinimapSettings()
    local settings = self:GetMinimapSettings()
    for key, value in pairs(MINIMAP_DEFAULTS) do
        settings[key] = value
    end
    AP:SendMessage("SETTINGS_CHANGED", "minimap", nil)
end

function Data:SetPopupSetting(key, value)
    local settings = self:GetPopupSettings()
    settings[key] = value
    NormalizePopupDatabase(settings)
    AP:SendMessage("SETTINGS_CHANGED", "popup", key)
    return settings[key]
end

function Data:SetMinimapSetting(key, value)
    local settings = self:GetMinimapSettings()
    settings[key] = value
    NormalizeMinimapDatabase(settings)
    AP:SendMessage("SETTINGS_CHANGED", "minimap", key)
    return settings[key]
end

function Data:MakeCharacterKey(realm, name)
    if type(realm) ~= "string" or realm == "" or type(name) ~= "string" or name == "" then
        return nil
    end
    return realm .. "-" .. name
end

function Data:ParseCharacterKey(key)
    if type(key) ~= "string" then return nil, nil end
    local realm = key:match("^(.+)%-[^%-]+$")
    local name = key:match("%-([^%-]+)$")
    return realm or key, name or key
end

function Data:BuildCharacterRecord(key, value)
    if not IsCharacterData(value) then return nil end
    local realm, name = self:ParseCharacterKey(key)
    return {
        key = key,
        name = name,
        realm = realm,
        time = value.time,
        class = NormalizeToken(value.class),
        race = NormalizeToken(value.race),
        raceName = NormalizeOptionalLabel(value.raceName),
        faction = NormalizeToken(value.faction),
        factionName = NormalizeOptionalLabel(value.factionName),
    }
end

local function SortCharacters(left, right)
    if left.time ~= right.time then
        return left.time > right.time
    end
    local leftKey, rightKey = left.key:lower(), right.key:lower()
    if leftKey ~= rightKey then return leftKey < rightKey end
    return left.key < right.key
end

function Data:GetAllCharacters(field, value)
    local characters = {}
    if field and not VALID_GROUP_FIELDS[field] then return characters end

    for key, data in pairs(self:GetDatabase()) do
        if IsCharacterData(data) and (not field or NormalizeToken(data[field]) == value) then
            characters[#characters + 1] = self:BuildCharacterRecord(key, data)
        end
    end

    table.sort(characters, SortCharacters)
    return characters
end

function Data:GetCharactersByClass(classFile)
    return self:GetAllCharacters("class", classFile)
end

function Data:GetCharactersByRace(raceFile)
    return self:GetAllCharacters("race", raceFile)
end

function Data:GetCharactersByFaction(factionFile)
    return self:GetAllCharacters("faction", factionFile)
end

function Data:GetCharacterCount()
    return #self:GetAllCharacters()
end

function Data:GetCharacterData(realm, name)
    local key = self:MakeCharacterKey(realm, name)
    if not key then return nil end
    return self:BuildCharacterRecord(key, self:GetDatabase()[key])
end

function Data:GetAccountTotal()
    local total = 0
    for _, value in pairs(self:GetDatabase()) do
        if IsCharacterData(value) then
            total = total + value.time
        end
    end
    return total
end

function Data:GetTotals(field)
    local totals = {}
    local accountTotal = 0
    if not VALID_GROUP_FIELDS[field] then return totals, accountTotal end

    for _, value in pairs(self:GetDatabase()) do
        if IsCharacterData(value) then
            local key = NormalizeToken(value[field])
            totals[key] = (totals[key] or 0) + value.time
            accountTotal = accountTotal + value.time
        end
    end
    return totals, accountTotal
end

function Data:GetClassTotals()
    return self:GetTotals("class")
end

function Data:GetRaceTotals()
    return self:GetTotals("race")
end

function Data:GetFactionTotals()
    return self:GetTotals("faction")
end

function Data:GetDistribution(field)
    local entries = {}
    local byKey = {}
    local total = 0
    if not VALID_GROUP_FIELDS[field] then return entries, total end

    for _, character in ipairs(self:GetAllCharacters()) do
        local key = NormalizeToken(character[field])
        local entry = byKey[key]
        if not entry then
            entry = {
                key = key,
                kind = field,
                time = 0,
                count = 0,
                raceName = character.raceName,
                factionName = character.factionName,
            }
            byKey[key] = entry
            entries[#entries + 1] = entry
        end
        entry.time = entry.time + character.time
        entry.count = entry.count + 1
        entry.raceName = entry.raceName or character.raceName
        entry.factionName = entry.factionName or character.factionName
        total = total + character.time
    end

    table.sort(entries, function(left, right)
        if left.time ~= right.time then return left.time > right.time end
        local leftKey, rightKey = left.key:lower(), right.key:lower()
        if leftKey ~= rightKey then return leftKey < rightKey end
        return left.key < right.key
    end)
    return entries, total
end

function Data:FindCharacterKey(name, realm)
    local target = self:MakeCharacterKey(realm, name)
    if not target then return nil end
    target = target:lower()

    for key in pairs(self:GetDatabase()) do
        if type(key) == "string" and key:lower() == target then
            return key
        end
    end
    return nil
end

function Data:DeleteCharacter(key)
    local database = self:GetDatabase()
    if type(key) ~= "string" or database[key] == nil then return false end
    database[key] = nil
    AP:SendMessage("CHARACTER_REMOVED", key)
    return true
end

function Data:GetCurrentCharacterIdentity()
    local name = UnitName and UnitName("player")
    local realm = GetNormalizedRealmName and GetNormalizedRealmName()
    if (not realm or realm == "") and GetRealmName then realm = GetRealmName() end
    return realm, name
end

function Data:GetCurrentCharacterMetadata()
    local _, classFile
    local raceName, raceFile
    local factionFile, factionName
    if UnitClass then _, classFile = UnitClass("player") end
    if UnitRace then raceName, raceFile = UnitRace("player") end
    if UnitFactionGroup then factionFile, factionName = UnitFactionGroup("player") end
    return {
        class = NormalizeToken(classFile),
        race = NormalizeToken(raceFile),
        raceName = NormalizeOptionalLabel(raceName),
        faction = NormalizeToken(factionFile),
        factionName = NormalizeOptionalLabel(factionName or factionFile),
    }
end

function Data:UpdateCurrentCharacter(totalTimePlayed)
    if not IsFiniteNumber(totalTimePlayed) or totalTimePlayed < 0 then return nil, false end

    local realm, name = self:GetCurrentCharacterIdentity()
    local key = self:MakeCharacterKey(realm, name)
    if not key then return nil, false end

    local database = self:GetDatabase()
    local existing = NormalizeCharacterData(database[key]) or { time = 0 }
    local metadata = self:GetCurrentCharacterMetadata()
    local changed = database[key] ~= existing

    -- Unit metadata can be briefly unavailable during transitions. A valid
    -- /played response must not erase identity data captured on an earlier
    -- login; real non-UNKNOWN changes are still accepted below.
    if metadata.class == UNKNOWN and existing.class then
        metadata.class = existing.class
    end
    if metadata.race == UNKNOWN and existing.race then
        metadata.race = existing.race
        metadata.raceName = existing.raceName
    elseif metadata.race == existing.race and not metadata.raceName then
        metadata.raceName = existing.raceName
    end
    if metadata.faction == UNKNOWN and existing.faction then
        metadata.faction = existing.faction
        metadata.factionName = existing.factionName
    elseif metadata.faction == existing.faction and not metadata.factionName then
        metadata.factionName = existing.factionName
    end

    local storedTime = math.max(existing.time or 0, totalTimePlayed)
    if existing.time ~= storedTime then changed = true end
    if existing.class ~= metadata.class then changed = true end
    if existing.race ~= metadata.race then changed = true end
    if existing.raceName ~= metadata.raceName then changed = true end
    if existing.faction ~= metadata.faction then changed = true end
    if existing.factionName ~= metadata.factionName then changed = true end

    existing.time = storedTime
    existing.class = metadata.class
    existing.race = metadata.race
    existing.raceName = metadata.raceName
    existing.faction = metadata.faction
    existing.factionName = metadata.factionName
    database[key] = existing

    local record = self:BuildCharacterRecord(key, existing)
    AP:SendMessage("CHARACTER_UPDATED", record, changed)
    return record, changed
end

function Data:RequestCurrentCharacterPlayedTime()
    if not RequestTimePlayed then return false end
    local now = GetTime and GetTime() or 0
    if lastPlayedRequest and now - lastPlayedRequest < REQUEST_COOLDOWN then
        return false
    end

    RequestTimePlayed()
    lastPlayedRequest = now
    return true
end

AP:RegisterMessage("PLAYER_LOGIN", function()
    Data:RequestCurrentCharacterPlayedTime()
end)

AP:RegisterMessage("TIME_PLAYED_MSG", function(totalTimePlayed)
    Data:UpdateCurrentCharacter(totalTimePlayed)
end)
