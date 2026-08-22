-- Account Played dependency-free integration tests.
-- Run from the repository root with: lua tests/run.lua

local unpack = unpack or table.unpack

local tests = {}
local failures = 0

local function test(name, callback)
    tests[#tests + 1] = { name = name, callback = callback }
end

local function fail(message, level)
    error(message or "assertion failed", (level or 1) + 1)
end

local function assertEqual(actual, expected, message)
    if actual ~= expected then
        fail(string.format("%s: expected %s, got %s",
            message or "values differ", tostring(expected), tostring(actual)), 2)
    end
end

local function assertClose(actual, expected, tolerance, message)
    if type(actual) ~= "number" or math.abs(actual - expected) > tolerance then
        fail(string.format("%s: expected %.6f (+/- %.6f), got %s",
            message or "numbers differ", expected, tolerance, tostring(actual)), 2)
    end
end

local function assertTrue(value, message)
    if not value then fail(message or "expected a truthy value", 2) end
end

local function assertFalse(value, message)
    if value then fail(message or "expected a falsy value", 2) end
end

local function readTOC()
    local file, openError = io.open("AccountPlayed.toc", "r")
    assert(file, "open AccountPlayed.toc: " .. tostring(openError))

    local paths = {}
    for rawLine in file:lines() do
        local line = rawLine:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" and not line:match("^##") and not line:match("^#") then
            paths[#paths + 1] = line:gsub("\\", "/")
        end
    end
    file:close()
    return paths
end

local tocPaths = readTOC()

local expectedOrder = {
    "Libs/LibStub.lua",
    "Libs/CallbackHandler-1.0.lua",
    "Libs/LibDataBroker-1.1.lua",
    "AccountPlayed.lua",
    "Localization.lua",
    "Data.lua",
    "Formatting.lua",
    "CharacterPanel.lua",
    "MainWindow.lua",
    "MinimapButton.lua",
    "Settings.lua",
    "Commands.lua",
    "Broker.lua",
    "API.lua",
}

test("TOC paths exist and rewritten modules load in dependency order", function()
    assertEqual(#tocPaths, #expectedOrder, "TOC Lua file count")
    for index, expected in ipairs(expectedOrder) do
        assertEqual(tocPaths[index], expected, "TOC entry " .. index)
        local file = io.open(expected, "rb")
        assertTrue(file, "TOC entry does not exist: " .. expected)
        file:close()
    end
end)

-- Minimal WoW runtime. It deliberately models stateful frame methods used by
-- the add-on while leaving rendering to the game client.
local objectMethods = {}
local frames = {}
local anonymousFrameCount = 0

local function newObject(kind, name, parent)
    local object = {
        kind = kind,
        name = name,
        parent = parent,
        shown = true,
        enabled = true,
        mouseEnabled = false,
        alpha = 1,
        width = 0,
        height = 0,
        frameLevel = 1,
        checked = false,
        value = 0,
        verticalScroll = 0,
        scripts = {},
        hooks = {},
        points = {},
        children = {},
    }
    setmetatable(object, { __index = objectMethods })
    if parent and parent.children then
        parent.children[#parent.children + 1] = object
    end
    return object
end

function objectMethods:GetName() return self.name end
function objectMethods:GetParent() return self.parent end
function objectMethods:SetParent(parent) self.parent = parent end
function objectMethods:SetSize(width, height) self.width, self.height = width or 0, height or 0 end
function objectMethods:SetWidth(width) self.width = width or 0 end
function objectMethods:SetHeight(height) self.height = height or 0 end
function objectMethods:GetWidth() return self.width or 0 end
function objectMethods:GetHeight() return self.height or 0 end
function objectMethods:SetAlpha(alpha) self.alpha = alpha end
function objectMethods:GetAlpha() return self.alpha end
function objectMethods:SetFrameLevel(level) self.frameLevel = level or 1 end
function objectMethods:GetFrameLevel() return self.frameLevel or 1 end
function objectMethods:SetFrameStrata(strata) self.frameStrata = strata end
function objectMethods:GetFrameStrata() return self.frameStrata end
function objectMethods:EnableMouse(enabled) self.mouseEnabled = enabled == true end
function objectMethods:IsMouseEnabled() return self.mouseEnabled end
function objectMethods:EnableMouseWheel(enabled) self.mouseWheelEnabled = enabled == true end
function objectMethods:Enable() self.enabled = true end
function objectMethods:Disable() self.enabled = false end
function objectMethods:IsEnabled() return self.enabled end
function objectMethods:SetChecked(checked) self.checked = checked == true end
function objectMethods:GetChecked() return self.checked end
function objectMethods:SetMinMaxValues(minimum, maximum) self.minimum, self.maximum = minimum, maximum end
function objectMethods:GetMinMaxValues() return self.minimum, self.maximum end
function objectMethods:SetValue(value)
    self.value = value
    local handler = self.scripts.OnValueChanged
    if handler then handler(self, value) end
end
function objectMethods:GetValue() return self.value end
function objectMethods:SetVerticalScroll(value) self.verticalScroll = value or 0 end
function objectMethods:GetVerticalScroll() return self.verticalScroll or 0 end
function objectMethods:GetVerticalScrollRange()
    if not self.scrollChild then return 0 end
    return math.max(0, self.scrollChild:GetHeight() - self:GetHeight())
end
function objectMethods:SetScrollChild(child) self.scrollChild = child end
function objectMethods:GetScrollChild() return self.scrollChild end
function objectMethods:GetEffectiveScale() return self.effectiveScale or 1 end
function objectMethods:GetCenter() return self.centerX or 0, self.centerY or 0 end
function objectMethods:GetLeft() return (self.centerX or 0) - self:GetWidth() / 2 end
function objectMethods:GetRight() return (self.centerX or 0) + self:GetWidth() / 2 end
function objectMethods:GetTop() return (self.centerY or 0) + self:GetHeight() / 2 end
function objectMethods:GetBottom() return (self.centerY or 0) - self:GetHeight() / 2 end
function objectMethods:IsMouseOver() return false end
function objectMethods:SetPoint(...)
    local point = { ... }
    self.points[#self.points + 1] = point
    local count = select("#", ...)
    if count >= 4 and type(point[count - 1]) == "number" and type(point[count]) == "number" then
        self.centerX, self.centerY = point[count - 1], point[count]
    end
end
function objectMethods:GetPoint(index)
    local point = self.points[index or 1]
    if not point then return nil end
    return unpack(point)
end
function objectMethods:GetNumPoints() return #self.points end
function objectMethods:ClearAllPoints() self.points = {} end
function objectMethods:SetAllPoints(target)
    self.allPoints = target or self.parent
    if self.allPoints then
        self.width, self.height = self.allPoints:GetWidth(), self.allPoints:GetHeight()
    end
end
function objectMethods:SetScript(script, callback) self.scripts[script] = callback end
function objectMethods:GetScript(script) return self.scripts[script] end
function objectMethods:HookScript(script, callback)
    local hooks = self.hooks[script]
    if not hooks then
        hooks = {}
        self.hooks[script] = hooks
    end
    hooks[#hooks + 1] = callback
end

local function runFrameScript(frame, script, ...)
    local callback = frame.scripts[script]
    if callback then callback(frame, ...) end
    local hooks = frame.hooks[script]
    if hooks then
        for _, hook in ipairs(hooks) do hook(frame, ...) end
    end
end

function objectMethods:Show()
    local wasShown = self.shown
    self.shown = true
    if not wasShown then runFrameScript(self, "OnShow") end
end
function objectMethods:Hide()
    local wasShown = self.shown
    self.shown = false
    if wasShown then runFrameScript(self, "OnHide") end
end
function objectMethods:IsShown() return self.shown == true end
function objectMethods:IsVisible() return self:IsShown() end
function objectMethods:RegisterEvent(event) self.registeredEvents = self.registeredEvents or {}; self.registeredEvents[event] = true end
function objectMethods:UnregisterEvent(event) if self.registeredEvents then self.registeredEvents[event] = nil end end
function objectMethods:UnregisterAllEvents() self.registeredEvents = {} end
function objectMethods:SetText(text) self.text = tostring(text or "") end
function objectMethods:GetText() return self.text or "" end
function objectMethods:GetStringWidth() return #(self.text or "") * 6 end
function objectMethods:GetStringHeight() return self.fontSize or 12 end
function objectMethods:SetFont(path, size, flags) self.fontPath, self.fontSize, self.fontFlags = path, size, flags; return true end
function objectMethods:GetFont() return self.fontPath or "Fonts/FRIZQT__.TTF", self.fontSize or 12, self.fontFlags or "" end
function objectMethods:GetFontString()
    if not self.fontString then self.fontString = newObject("FontString", nil, self) end
    return self.fontString
end
function objectMethods:SetNormalTexture(texture)
    self.normalTexture = type(texture) == "table" and texture or newObject("Texture", nil, self)
    self.normalTexture.texture = texture
end
function objectMethods:GetNormalTexture() return self.normalTexture end
function objectMethods:SetHighlightTexture(texture)
    self.highlightTexture = type(texture) == "table" and texture or newObject("Texture", nil, self)
    self.highlightTexture.texture = texture
end
function objectMethods:GetHighlightTexture() return self.highlightTexture end
function objectMethods:SetStatusBarTexture(texture) self.statusBarTexture = texture end
function objectMethods:GetStatusBarTexture() return self.statusBarTexture end
function objectMethods:SetColorTexture(red, green, blue, alpha) self.color = { red, green, blue, alpha } end
function objectMethods:SetVertexColor(red, green, blue, alpha) self.vertexColor = { red, green, blue, alpha } end
function objectMethods:SetTexture(texture) self.texture = texture end
function objectMethods:SetTexCoord(...) self.texCoord = { ... } end
function objectMethods:SetRotation(rotation) self.rotation = rotation end
function objectMethods:SetOwner(owner) self.owner = owner end
function objectMethods:GetOwner() return self.owner end
function objectMethods:CreateTexture(name, layer)
    local texture = newObject("Texture", name, self)
    texture.layer = layer
    if name then _G[name] = texture end
    return texture
end
function objectMethods:CreateFontString(name, layer, template)
    local fontString = newObject("FontString", name, self)
    fontString.layer, fontString.template = layer, template
    if name then _G[name] = fontString end
    return fontString
end

local noopMethods = [[
    AddDoubleLine AddLine ClearLines SetBackdrop SetBackdropColor SetBackdropBorderColor
    SetBlendMode SetClampedToScreen SetDesaturated SetDrawLayer SetHitRectInsets
    SetJustifyH SetJustifyV SetMask SetMovable SetNonSpaceWrap SetObeyStepOnDrag
    SetResizable SetResizeBounds SetMaxResize SetMinResize SetScale SetShown SetSnapToPixelGrid SetSpacing
    SetTextColor SetValueStep SetWordWrap SetShadowColor SetShadowOffset SetGradient
    SetOrientation SetReverseFill SetStatusBarColor SetToplevel SetUserPlaced
    SetPushedTexture RegisterForClicks RegisterForDrag StartMoving StartSizing StopMovingOrSizing
    UpdateScrollChildRect LockHighlight UnlockHighlight Raise Lower
]]
for method in noopMethods:gmatch("%S+") do
    if not objectMethods[method] then objectMethods[method] = function() end end
end

function CreateFrame(kind, name, parent, template)
    anonymousFrameCount = anonymousFrameCount + 1
    local frame = newObject(kind, name or ("AnonymousFrame" .. anonymousFrameCount), parent)
    frame.template = template
    frames[#frames + 1] = frame
    if name then _G[name] = frame end

    if template == "UIPanelScrollFrameTemplate" then
        local scrollName = (name or frame.name) .. "ScrollBar"
        frame.ScrollBar = newObject("Slider", scrollName, frame)
        _G[scrollName] = frame.ScrollBar
    elseif template == "OptionsSliderTemplate" and name then
        _G[name .. "Low"] = newObject("FontString", name .. "Low", frame)
        _G[name .. "High"] = newObject("FontString", name .. "High", frame)
        _G[name .. "Text"] = newObject("FontString", name .. "Text", frame)
    end
    return frame
end

UIParent = newObject("Frame", "UIParent", nil)
UIParent:SetSize(1920, 1080)
Minimap = newObject("Frame", "Minimap", UIParent)
Minimap:SetSize(140, 140)
Minimap.centerX, Minimap.centerY = 500, 500
GameTooltip = newObject("Tooltip", "GameTooltip", UIParent)
GameFontNormal = newObject("Font", "GameFontNormal", UIParent)
GameFontNormalSmall = newObject("Font", "GameFontNormalSmall", UIParent)

BackdropTemplateMixin = {}
UISpecialFrames = {}
StaticPopupDialogs = {}
SlashCmdList = {}
SOUNDKIT = {
    IG_MAINMENU_OPTION_CHECKBOX_ON = 1,
    IG_MAINMENU_OPTION_CHECKBOX_OFF = 2,
    IG_MAINMENU_OPEN = 3,
    IG_MAINMENU_CLOSE = 4,
    U_CHAT_SCROLL_BUTTON = 5,
}
RAID_CLASS_COLORS = {
    MAGE = { r = 0.25, g = 0.78, b = 0.92 },
    WARRIOR = { r = 0.78, g = 0.61, b = 0.43 },
    DRUID = { r = 1, g = 0.49, b = 0.04 },
}
LOCALIZED_CLASS_NAMES_MALE = { MAGE = "Mage", WARRIOR = "Warrior", DRUID = "Druid" }

DELETE = "Delete"
CANCEL = "Cancel"
SETTINGS = "Settings"
TEXT_SCALE = "Text Scale"
MINIMAP_LABEL = "Minimap Button"
RESET_TO_DEFAULT = "Reset"
OKAY = "Okay"

local popupCalls = {}
function StaticPopup_Show(which, textArg1, textArg2, data)
    local popup = { which = which, textArg1 = textArg1, textArg2 = textArg2, data = data }
    popupCalls[#popupCalls + 1] = popup
    return popup
end

function UIFrameFadeRemoveFrame() end
function UIFrameFadeIn(frame, _, _, target) frame:SetAlpha(target) end
function UIFrameFadeOut(frame, _, _, target) frame:SetAlpha(target) end
function PlaySound() end
function GetCursorPosition() return 500, 500 end
function GetLocale() return "enUS" end
strmatch = string.match
function strsplit(delimiter, value)
    local first, second = value:match("^(.-)" .. delimiter .. "(.*)$")
    return first or value, second
end
function securecallfunction(callback, ...) return callback(...) end

C_Timer = { After = function(_, callback) callback() end }

local now = 0
local requestCount = 0
local player = {
    name = "LivePlayer",
    realm = "Test-Realm",
    className = "Mage",
    classFile = "MAGE",
    raceName = "Human",
    raceFile = "Human",
    factionFile = "Alliance",
    factionName = "Alliance",
}

function GetTime() return now end
function RequestTimePlayed() requestCount = requestCount + 1 end
function UnitName(unit) if unit == "player" then return player.name end end
function GetNormalizedRealmName() return player.realm end
function GetRealmName() return player.realm end
function UnitClass(unit) if unit == "player" then return player.className, player.classFile end end
function UnitRace(unit) if unit == "player" then return player.raceName, player.raceFile end end
function UnitFactionGroup(unit) if unit == "player" then return player.factionFile, player.factionName end end

-- Initial SavedVariables exercise all three migration paths during ADDON_LOADED.
AccountPlayedDB = {
    [17] = { time = 20 },
    ["Azjol-Nerub-Alice"] = 3600,
    ["Tie-Realm-Zulu"] = { time = 600, class = "MAGE", race = "Human", faction = "Alliance" },
    ["Tie-Realm-alpha"] = { time = 600, class = "MAGE", race = "Human", faction = "Alliance" },
    ["Broken-Realm-Entry"] = { time = "not a number" },
}
AccountPlayedPopupDB = "corrupt"
AccountPlayedMinimapDB = { angle = 90, hidden = true, locked = "yes" }

local addonName = "AccountPlayed"
local AP = {}
for _, path in ipairs(tocPaths) do
    local chunk, loadError = loadfile(path)
    assert(chunk, path .. ": " .. tostring(loadError))
    chunk(addonName, AP)
end

local function fireEvent(event, ...)
    local frame = assert(AP.eventFrame, "core event frame was not created")
    local callback = assert(frame:GetScript("OnEvent"), "core OnEvent handler was not installed")
    callback(frame, event, ...)
end

fireEvent("ADDON_LOADED", addonName)

local function replaceDatabase(entries)
    local database = AP.Data:GetDatabase()
    for key in pairs(database) do database[key] = nil end
    for key, value in pairs(entries or {}) do database[key] = value end
    AccountPlayedDB = database
    AP.Data.database = database
    return database
end

test("legacy data and corrupt SavedVariables are normalized", function()
    assertEqual(type(AccountPlayedDB["Azjol-Nerub-Alice"]), "table", "numeric legacy record migration")
    assertEqual(AccountPlayedDB["Azjol-Nerub-Alice"].time, 3600, "legacy played time")
    assertEqual(AccountPlayedDB["Azjol-Nerub-Alice"].class, "UNKNOWN", "legacy class fallback")
    assertEqual(AccountPlayedDB[17], nil, "non-string character key removal")
    assertEqual(AccountPlayedDB["Broken-Realm-Entry"], nil, "invalid character removal")

    assertEqual(type(AccountPlayedPopupDB), "table", "corrupt popup settings reset")
    assertEqual(AccountPlayedPopupDB.width, 640, "popup width default")
    assertEqual(AccountPlayedPopupDB.activeTab, "class", "popup tab default")

    assertEqual(AccountPlayedMinimapDB.angle, nil, "legacy minimap angle removal")
    assertClose(AccountPlayedMinimapDB.x, 0, 0.000001, "legacy minimap x")
    assertClose(AccountPlayedMinimapDB.y, 105, 0.000001, "legacy minimap y")
    assertFalse(AccountPlayedMinimapDB.locked, "invalid boolean reset")
    assertTrue(AccountPlayedMinimapDB.hidden, "valid hidden setting retained")

    assertEqual(AP.Data:SetPopupSetting("width", math.huge), 640, "non-finite width fallback")
    assertEqual(AP.Data:SetPopupSetting("height", -100), 260, "height lower clamp")
    assertEqual(AP.Data:SetPopupSetting("textScale", 9), 2, "text scale upper clamp")
    assertEqual(AP.Data:SetPopupSetting("activeTab", "bogus"), "class", "invalid tab fallback")

    AccountPlayedDB = "corrupt"
    AP.Data:Initialize()
    assertEqual(type(AccountPlayedDB), "table", "corrupt character database reset")
    assertEqual(AP.Data:GetCharacterCount(), 0, "reset database is empty")
end)

test("hyphenated realm keys parse at the final separator", function()
    replaceDatabase({
        ["Azjol-Nerub-Alice"] = {
            time = 123,
            class = "MAGE",
            race = "Human",
            faction = "Alliance",
        },
    })
    local realm, name = AP.Data:ParseCharacterKey("Azjol-Nerub-Alice")
    assertEqual(realm, "Azjol-Nerub", "parsed realm")
    assertEqual(name, "Alice", "parsed character")
    assertEqual(AP.Data:MakeCharacterKey(realm, name), "Azjol-Nerub-Alice", "round-trip key")
    local character = assert(AP.Data:GetCharacterData(realm, name))
    assertEqual(character.realm, "Azjol-Nerub", "record realm")
    assertEqual(character.name, "Alice", "record character")
end)

test("internal messages preserve nil-bearing argument lists", function()
    local received
    local callback = AP:RegisterMessage("ACCOUNTPLAYED_TEST_NIL_ARGS", function(...)
        received = { count = select("#", ...), ... }
    end)
    AP:SendMessage("ACCOUNTPLAYED_TEST_NIL_ARGS", "first", nil, "third")
    AP:UnregisterMessage("ACCOUNTPLAYED_TEST_NIL_ARGS", callback)

    assertEqual(received.count, 3, "message argument count")
    assertEqual(received[1], "first", "first message argument")
    assertEqual(received[2], nil, "nil middle message argument")
    assertEqual(received[3], "third", "third message argument")
end)

test("totals and tied sorts are deterministic", function()
    replaceDatabase({
        ["Realm-Zulu"] = { time = 100, class = "MAGE", race = "Human", faction = "Alliance" },
        ["Realm-alpha"] = { time = 100, class = "MAGE", race = "Human", faction = "Alliance" },
        ["Realm-Middle"] = { time = 400, class = "DRUID", race = "NightElf", faction = "Alliance" },
        ["Realm-Low"] = { time = 10, class = "WARRIOR", race = "Orc", faction = "Horde" },
    })
    assertEqual(AP.Data:GetAccountTotal(), 610, "account total")
    local characters = AP.Data:GetAllCharacters()
    assertEqual(characters[1].key, "Realm-Middle", "descending time sort")
    assertEqual(characters[2].key, "Realm-alpha", "case-insensitive tie sort first")
    assertEqual(characters[3].key, "Realm-Zulu", "case-insensitive tie sort second")

    local classes, total = AP.Data:GetDistribution("class")
    assertEqual(total, 610, "distribution total")
    assertEqual(classes[1].key, "DRUID", "distribution descending sort")
    assertEqual(classes[1].time, 400, "distribution aggregate")
    assertEqual(classes[2].key, "MAGE", "distribution second aggregate")
    assertEqual(classes[2].time, 200, "distribution tied class total")
end)

test("queries return every character beyond the historical 20-row limit", function()
    local entries = {}
    local expectedTotal = 0
    for index = 1, 25 do
        local seconds = 1000 + index
        entries[string.format("Large-Realm-Mage%02d", index)] = {
            time = seconds,
            class = "MAGE",
            race = "Human",
            faction = "Alliance",
        }
        expectedTotal = expectedTotal + seconds
    end
    entries["Large-Realm-Druid"] = { time = 50, class = "DRUID", race = "NightElf", faction = "Alliance" }
    replaceDatabase(entries)

    local mages = AP.Data:GetCharactersByClass("MAGE")
    assertEqual(#mages, 25, "class query count")
    assertEqual(mages[1].name, "Mage25", "class query order")
    assertEqual(mages[25].name, "Mage01", "class query final row")
    local distribution, total = AP.Data:GetDistribution("class")
    assertEqual(#distribution, 2, "class distribution count")
    assertEqual(distribution[1].count, 25, "class distribution character count")
    assertEqual(distribution[1].time, expectedTotal, "class distribution time")
    assertEqual(total, expectedTotal + 50, "large dataset total")

    local Played = LibStub("AccountPlayed-1.0")
    assertEqual(#Played:GetCharactersByClass("MAGE"), 25, "public API class query count")
end)

test("time formatting honors hour, day, and year thresholds", function()
    local hour, day, year = 3600, 86400, 365 * 86400
    assertEqual(AP.Format:CompactTime(23 * hour, true), "23h", "under one day")
    assertEqual(AP.Format:CompactTime(day, true), "1d", "one day")
    assertEqual(AP.Format:DetailedTime(day + 2 * hour + 30 * 60, true), "1d 2h", "day detail")
    assertEqual(AP.Format:DetailedTime(2 * hour + 30 * 60, false), "2h 30m", "hour detail")
    assertEqual(AP.Format:TotalTime(year - day, true), "364d", "under one year")
    assertEqual(AP.Format:TotalTime(year, true), "1y 0d", "one year")
    assertEqual(AP.Format:TotalTime(year + day, true), "1y 1d", "over one year")
    assertEqual(AP.Format:DistributionValue(25, 100, "percent", false), "25.0%", "percentage")
    assertEqual(AP.Format:DistributionValue(25, 0, "percent", false), "0.0%", "zero total")
end)

test("API v1 time helpers retain fixed English compatibility", function()
    local keys = { "TIME_UNIT_YEAR", "TIME_UNIT_DAY", "TIME_UNIT_HOUR", "TIME_UNIT_MINUTE" }
    local originals = {}
    for _, key in ipairs(keys) do originals[key] = AP.L[key] end
    AP.L.TIME_UNIT_YEAR = " J"
    AP.L.TIME_UNIT_DAY = " T"
    AP.L.TIME_UNIT_HOUR = " Std"
    AP.L.TIME_UNIT_MINUTE = " Min"

    local Played = LibStub("AccountPlayed-1.0")
    local legacy = Played:FormatTime(25 * 3600)
    local hours = Played:FormatTimeHours(25 * 3600)
    local detailed = Played:FormatTimeDetailed(2 * 3600 + 30 * 60)

    for _, key in ipairs(keys) do AP.L[key] = originals[key] end
    assertEqual(legacy, "1d 1h", "legacy day/hour format")
    assertEqual(hours, "25h", "legacy hours-only format")
    assertEqual(detailed, "2h 30m", "legacy detailed format")
end)

test("initial played-time request works at GetTime zero and is throttled", function()
    requestCount = 0
    now = 0
    fireEvent("PLAYER_LOGIN")
    assertEqual(requestCount, 1, "initial request")
    assertFalse(AP.Data:RequestCurrentCharacterPlayedTime(), "same-tick request throttled")
    now = 9.999
    assertFalse(AP.Data:RequestCurrentCharacterPlayedTime(), "request before cooldown throttled")
    assertEqual(requestCount, 1, "no request before cooldown")
    now = 10
    assertTrue(AP.Data:RequestCurrentCharacterPlayedTime(), "request at cooldown accepted")
    assertEqual(requestCount, 2, "request after cooldown")
end)

test("public API callbacks fire only for stored record changes", function()
    replaceDatabase({})
    player.name = "CallbackPlayer"
    player.realm = "Hyphenated-Realm"
    player.className, player.classFile = "Mage", "MAGE"
    player.raceName, player.raceFile = "Human", "Human"
    player.factionFile, player.factionName = "Alliance", "Alliance"

    local Played = LibStub("AccountPlayed-1.0")
    local friendlyCalls = {}
    Played:OnCharacterUpdated("AccountPlayedTests", function(...)
        friendlyCalls[#friendlyCalls + 1] = { ... }
    end)

    local advanced = { calls = {} }
    function advanced:OnUpdated(event, ...)
        self.calls[#self.calls + 1] = { event, ... }
    end
    Played.RegisterCallback(advanced, "CharacterUpdated", "OnUpdated")

    fireEvent("TIME_PLAYED_MSG", 7200, 0)
    assertEqual(#friendlyCalls, 1, "friendly callback first change")
    assertEqual(friendlyCalls[1][1], "Hyphenated-Realm", "callback realm")
    assertEqual(friendlyCalls[1][2], "CallbackPlayer", "callback character")
    assertEqual(friendlyCalls[1][3], 7200, "callback played time")
    assertEqual(friendlyCalls[1][4], "MAGE", "callback class")
    assertEqual(#advanced.calls, 1, "advanced callback first change")
    assertEqual(advanced.calls[1][1], "CharacterUpdated", "advanced callback event")

    fireEvent("TIME_PLAYED_MSG", 7200, 0)
    assertEqual(#friendlyCalls, 1, "unchanged record suppressed")
    assertEqual(#advanced.calls, 1, "advanced unchanged record suppressed")

    player.className, player.classFile = "Warrior", "WARRIOR"
    fireEvent("TIME_PLAYED_MSG", 7100, 0)
    assertEqual(#friendlyCalls, 2, "metadata change fires callback")
    assertEqual(friendlyCalls[2][3], 7200, "played time never regresses")
    assertEqual(friendlyCalls[2][4], "WARRIOR", "metadata refresh")

    player.className, player.classFile = nil, nil
    player.raceName, player.raceFile = nil, nil
    player.factionFile, player.factionName = nil, nil
    fireEvent("TIME_PLAYED_MSG", 7100, 0)
    local preserved = Played:GetCharacterData("Hyphenated-Realm", "CallbackPlayer")
    assertEqual(preserved.class, "WARRIOR", "transient class lookup preserves known metadata")
    assertEqual(preserved.race, "Human", "transient race lookup preserves known metadata")
    assertEqual(preserved.faction, "Alliance", "transient faction lookup preserves known metadata")
    assertEqual(#friendlyCalls, 2, "transient metadata gap is not a stored change")

    Played:OffCharacterUpdated("AccountPlayedTests")
    Played.UnregisterCallback(advanced, "CharacterUpdated")
    fireEvent("TIME_PLAYED_MSG", 8000, 0)
    assertEqual(#friendlyCalls, 2, "friendly callback unregistered")
    assertEqual(#advanced.calls, 2, "advanced callback unregistered")
end)

test("hidden minimap state and reset remain usable", function()
    local button = assert(AP.minimapButton, "PLAYER_LOGIN did not create the minimap button")
    assertTrue(AP.Data:GetMinimapSettings().hidden, "hidden setting retained through login")
    assertFalse(button:IsShown(), "hidden minimap button")
    assertFalse(button:IsMouseEnabled(), "hidden minimap mouse input")

    AP.MinimapButton:Reset()
    local settings = AP.Data:GetMinimapSettings()
    assertFalse(settings.hidden, "reset unhides minimap setting")
    assertTrue(button:IsShown(), "reset shows minimap button")
    assertTrue(button:IsMouseEnabled(), "reset enables minimap mouse input")
    assertClose(settings.x, AP.defaults.minimap.x, 0.000001, "reset minimap x")
    assertClose(settings.y, AP.defaults.minimap.y, 0.000001, "reset minimap y")
end)

test("lazy main and character windows survive a large-data UI smoke test", function()
    local entries = {}
    for index = 1, 25 do
        entries[string.format("Smoke-Realm-Mage%02d", index)] = {
            time = index * 100,
            class = "MAGE",
            race = "Human",
            raceName = "Human",
            faction = "Alliance",
            factionName = "Alliance",
        }
    end
    replaceDatabase(entries)
    AP.Data:SetPopupSetting("activeTab", "characters")

    AP.MainWindow:Show()
    assertTrue(AP.popupFrame and AP.popupFrame:IsShown(), "main window shown")
    assertTrue(type(AP.popupFrame.characterRows) == "table" and #AP.popupFrame.characterRows >= 25,
        "main window allocated every visible character row")

    AP.CharacterPanel:ShowGroup("class", "MAGE", { key = "MAGE", kind = "class" }, AP.popupFrame)
    assertTrue(AP.CharacterPanel.frame:IsShown(), "character panel shown")
    assertTrue(#AP.CharacterPanel.frame.rows >= 25, "character panel allocated every row")
    AP.CharacterPanel:Hide()
    AP.MainWindow:Hide()
    assertFalse(AP.popupFrame:IsShown(), "main window hidden")
end)

for index, specification in ipairs(tests) do
    local ok, testError = pcall(specification.callback)
    if ok then
        io.write(string.format("ok %d - %s\n", index, specification.name))
    else
        failures = failures + 1
        io.write(string.format("not ok %d - %s\n  %s\n",
            index, specification.name, tostring(testError):gsub("\n", "\n  ")))
    end
end

io.write(string.format("1..%d\n", #tests))
if failures > 0 then
    io.stderr:write(string.format("%d test(s) failed\n", failures))
    os.exit(1)
end
io.write(string.format("All %d tests passed\n", #tests))
