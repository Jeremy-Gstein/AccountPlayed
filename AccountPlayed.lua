-- SavedVariables (must NOT be local)
AccountPlayedDB = AccountPlayedDB or {}

local ADDON_NAME = "Account Played"

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("TIME_PLAYED_MSG")

--------------------------------------------------
-- Helpers
--------------------------------------------------

local function GetCharInfo()
    local name = UnitName("player")
    local realm = GetNormalizedRealmName()
    return realm, name
end

local function GetCharKey(realm, name)
    return realm .. "-" .. name
end

local function FormatTime(seconds)
    seconds = tonumber(seconds) or 0
    local hours = math.floor(seconds / 3600)
    local days = math.floor(hours / 24)
    local remHours = hours % 24
    return string.format("%dd %dh", days, remHours)
end

local function FormatTimeSmart(seconds, useYears)
    seconds = tonumber(seconds) or 0
    local hours = seconds / 3600

    if useYears then
        local days = math.floor(hours / 24)
        local years = math.floor(days / 365)
        local remDays = days % 365

        if years > 0 then
            return string.format("%dy %dd", years, remDays)
        else
            return string.format("%dd", remDays)
        end
    else
        local h = math.floor(hours)
        local m = math.floor((seconds % 3600) / 60)
        return string.format("%dh %dm", h, m)
    end
end

local function GetAccountTotal()
    local total = 0
    for _, data in pairs(AccountPlayedDB) do
        if type(data) == "table" and data.time then
            total = total + data.time
        elseif type(data) == "number" then
            total = total + data
        end
    end
    return total
end

local function GetClassTotals()
    local totals = {}
    local accountTotal = 0

    for _, data in pairs(AccountPlayedDB) do
        if type(data) == "table" and data.time and data.class then
            totals[data.class] = (totals[data.class] or 0) + data.time
            accountTotal = accountTotal + data.time
        elseif type(data) == "number" then
            totals["IDK"] = (totals["IDK"] or 0) + data
            accountTotal = accountTotal + data
        end
    end

    return totals, accountTotal
end

--------------------------------------------------
-- Debug helpers
--------------------------------------------------

local function DebugListCharacters()
    print("|cffff0000[AccountPlayed Debug] Known characters:|r")
    for charKey, data in pairs(AccountPlayedDB) do
        local time, class
        if type(data) == "table" then
            time = data.time or 0
            class = data.class or "IDK"
        else
            time = data
            class = "IDK"
        end
        print(string.format(" |cffffff00 - %s : %s (%s)|r", charKey, FormatTime(time), class))
    end
end

SLASH_ACCOUNTPLAYEDDEBUG1 = "/apdebug"
SlashCmdList.ACCOUNTPLAYEDDEBUG = DebugListCharacters

--------------------------------------------------
-- Popup Window + Rows
--------------------------------------------------

local popupFrame
local popupRows = {}

-- Create a single row (class name + bar + value text)
local function CreateRow(parent, width, height)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(width, height)

    -- Class name
    row.classText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.classText:SetPoint("LEFT", 0, 0)
    row.classText:SetWidth(100)
    row.classText:SetJustifyH("LEFT")

    -- Status bar (dynamic width via anchors)
    row.bar = CreateFrame("StatusBar", nil, row)
    row.bar:SetPoint("LEFT", row.classText, "RIGHT", 8, 0)
    row.bar:SetPoint("RIGHT", row, "RIGHT", -120, 0)
    row.bar:SetHeight(height - 4)
    row.bar:SetMinMaxValues(0, 1)
    row.bar:SetValue(0)
    row.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

    row.bar.bg = row.bar:CreateTexture(nil, "BACKGROUND")
    row.bar.bg:SetAllPoints()
    row.bar.bg:SetColorTexture(0, 0, 0, 0.4)

    -- Right-side value text
    row.valueText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.valueText:SetPoint("LEFT", row.bar, "RIGHT", 8, 0)
    row.valueText:SetWidth(150)
    row.valueText:SetJustifyH("LEFT")

    return row
end

--------------------------------------------------
-- Scrollbar visibility helper (NEW)
--------------------------------------------------

local function UpdateScrollBarVisibility(frame)
    local sf = frame.scrollFrame
    local sb = sf and sf.ScrollBar
    if not sb then return end

    if sf:GetVerticalScrollRange() > 0 then
        sb:Show()
    else
        sb:Hide()
        sf:SetVerticalScroll(0)
    end
end

--------------------------------------------------
-- Popup creation
--------------------------------------------------

local function CreatePopup()
    if popupFrame then return popupFrame end

    local START_W, START_H = 520, 300
    local MIN_W, MIN_H = 420, 200
    local MAX_W, MAX_H = 720, 400

    local f = CreateFrame("Frame", "AccountPlayedPopup", UIParent, "BackdropTemplate")
    f:SetSize(START_W, START_H)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")

    -- Dragging
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    -- Resizing
    f:SetResizable(true)
    if f.SetMinResize then
        f:SetMinResize(MIN_W, MIN_H)
        f:SetMaxResize(MAX_W, MAX_H)
    end
    f:SetClampedToScreen(true)

    -- Resize grabber
    local br = CreateFrame("Button", nil, f)
    br:SetSize(16, 16)
    br:SetPoint("BOTTOMRIGHT", -6, 6)
    br:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    br:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    br:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    br:SetScript("OnMouseDown", function(self) self:GetParent():StartSizing("BOTTOMRIGHT") end)
    br:SetScript("OnMouseUp", function(self) self:GetParent():StopMovingOrSizing() end)

    -- Backdrop
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:SetBackdropColor(0, 0, 0, 0.5)

    -- Title
    --f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    --f.title:SetPoint("TOPLEFT", 15, -12)
    --f.title:SetText("Account Played - Time by Class")


    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.title:SetPoint("TOP", f, "TOP", 0, -12)
    f.title:SetText("Account Played - Time by Class")
    -- Close button
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -10, -10)

    --------------------------------------------------
    -- ScrollFrame
    --------------------------------------------------

    local scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 15, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)
    f.scrollFrame = scrollFrame

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    f.content = content

    -- Mouse wheel scrolling
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local step = 20
        local new = self:GetVerticalScroll() - delta * step
        new = math.max(0, math.min(new, self:GetVerticalScrollRange()))
        self:SetVerticalScroll(new)
    end)

    -- Total row (fixed)
    f.totalRow = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.totalRow:SetPoint("BOTTOMLEFT", 15, 18)
    f.totalRow:SetTextColor(1, 0.82, 0)

    -- Rows
    popupRows = {}
    local rowHeight = 22
    local maxRows = 20

    for i = 1, maxRows do
        local row = CreateRow(content, START_W - 60, rowHeight)
        row:SetPoint("TOPLEFT", 0, -(i - 1) * rowHeight)
        row:Hide()
        popupRows[i] = row
    end

    -- Hard clamp + layout sync on resize (NEW)
    f:SetScript("OnSizeChanged", function(self, w, h)
        if w < MIN_W then self:SetWidth(MIN_W) end
        if h < MIN_H then self:SetHeight(MIN_H) end
        if w > MAX_W then self:SetWidth(MAX_W) end
        if h > MAX_H then self:SetHeight(MAX_H) end

        local cw = self.scrollFrame:GetWidth()
        self.content:SetWidth(cw)
        for _, row in ipairs(popupRows) do
            row:SetWidth(cw)
        end

        UpdateScrollBarVisibility(self)
    end)

    f:Hide()
    popupFrame = f
    return f
end

--------------------------------------------------
-- Popup update
--------------------------------------------------

local function UpdatePopup()
    local f = CreatePopup()
    local totals = GetClassTotals()
    local accountTotal = GetAccountTotal()

    if accountTotal == 0 then
        popupRows[1].classText:SetText("No data yet")
        popupRows[1].bar:SetValue(0)
        popupRows[1].valueText:SetText("")
        popupRows[1]:Show()
        f.totalRow:SetText("TOTAL: 0h")
        return
    end

    local sorted = {}
    for class, time in pairs(totals) do
        table.insert(sorted, { class = class, time = time })
    end
    table.sort(sorted, function(a, b) return a.time > b.time end)

    local topTime = sorted[1].time

    for i, row in ipairs(popupRows) do
        local entry = sorted[i]
        if entry then
            local percent = entry.time / accountTotal
            local barPercent = entry.time / topTime
            local color = RAID_CLASS_COLORS[entry.class] or { r = 1, g = 1, b = 1 }

            row.classText:SetText(entry.class)
            row.classText:SetTextColor(color.r, color.g, color.b)
            row.bar:SetValue(barPercent)
            row.bar:SetStatusBarColor(color.r, color.g, color.b)
            row.valueText:SetText(string.format("%5.1f%% - %s", percent * 100, FormatTime(entry.time)))
            row:Show()
        else
            row:Hide()
        end
    end

    -- Update scroll content height
    f.content:SetHeight(#sorted * 22)
    UpdateScrollBarVisibility(f)

    -- Total row
    local useYears = (accountTotal / 3600) >= 9000
    f.totalRow:SetText("TOTAL: " .. FormatTimeSmart(accountTotal, useYears))

    f:Show()
end

--------------------------------------------------
-- Slash command
--------------------------------------------------

SLASH_ACCOUNTPLAYEDPOPUP1 = "/apclasswin"
SlashCmdList.ACCOUNTPLAYEDPOPUP = function()
    if popupFrame and popupFrame:IsShown() then
        popupFrame:Hide()
    else
        UpdatePopup()
    end
end

--------------------------------------------------
-- Event handler
--------------------------------------------------

f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        RequestTimePlayed()
    elseif event == "TIME_PLAYED_MSG" then
        local totalTimePlayed = ...
        local realm, name = GetCharInfo()
        local charKey = GetCharKey(realm, name)
        local _, classFile = UnitClass("player")

        AccountPlayedDB[charKey] = {
            time = totalTimePlayed,
            class = classFile,
        }
    end
end)
