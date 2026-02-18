--------------------------------------------------
-- Account Played - Main Module
--------------------------------------------------
local _, addonTable = ...
local L = addonTable.L

AccountPlayed = AccountPlayed or {}
local AP = AccountPlayed

-- SavedVariables (must NOT be local)
AccountPlayedDB = AccountPlayedDB or {}
AccountPlayedPopupDB = AccountPlayedPopupDB or {
    width = 520,
    height = 300,
    point = "CENTER",
    x = 0,
    y = 0,
    useYears = false,
}

-- Throttle tracking
local lastPlayedRequest = 0

-- Frame references
AP.mainFrame = CreateFrame("Frame")
AP.popupFrame = nil
AP.popupRows = {}

--------------------------------------------------
-- Validation & Migration
--------------------------------------------------

if type(AccountPlayedDB) ~= "table" then
    print("|cffff0000" .. L["DB_CORRUPTED"] .. "|r")
    AccountPlayedDB = {}
end

local function MigrateOldData()
    for charKey, data in pairs(AccountPlayedDB) do
        if type(data) == "number" then
            AccountPlayedDB[charKey] = { time = data, class = "UNKNOWN" }
        end
    end
end

--------------------------------------------------
-- Core Helpers
--------------------------------------------------

local function GetCharInfo()
    local name = UnitName("player")
    local realm = GetNormalizedRealmName and GetNormalizedRealmName() or GetRealmName()
    return realm, name
end

local function GetCharKey(realm, name)
    return realm .. "-" .. name
end

local function GetLocalizedClass(classFile)
    if not classFile or classFile == "UNKNOWN" then 
        return L["UNKNOWN"] or "Unknown"
    end
    return LOCALIZED_CLASS_NAMES_MALE[classFile] or classFile
end

local function SafeRequestTimePlayed()
    local now = GetTime()
    if now - lastPlayedRequest >= 10 then
        RequestTimePlayed()
        lastPlayedRequest = now
        return true
    end
    return false
end

--------------------------------------------------
-- Time Formatting
--------------------------------------------------

local function FormatTime(seconds)
    seconds = tonumber(seconds) or 0
    local hours = math.floor(seconds / 3600)
    local days = math.floor(hours / 24)
    local remHours = hours % 24
    return string.format("%d%s %d%s", days, L["TIME_UNIT_DAY"], remHours, L["TIME_UNIT_HOUR"])
end

local function FormatTimeSmart(seconds, useYears)
    seconds = tonumber(seconds) or 0
    local hours = seconds / 3600

    if useYears then
        local totalHours = math.floor(hours)
        local days = math.floor(totalHours / 24)
        return days > 0 and string.format("%d%s", days, L["TIME_UNIT_DAY"]) or string.format("%d%s", totalHours, L["TIME_UNIT_HOUR"])
    else
        return string.format("%d%s", math.floor(hours), L["TIME_UNIT_HOUR"])
    end
end

local function FormatTimeDetailed(seconds, useYears)
    seconds = tonumber(seconds) or 0
    local hours = seconds / 3600

    if useYears then
        local totalHours = math.floor(hours)
        local days = math.floor(totalHours / 24)
        local remHours = totalHours % 24
        return days > 0 and string.format("%d%s %d%s", days, L["TIME_UNIT_DAY"], remHours, L["TIME_UNIT_HOUR"]) or string.format("%d%s", totalHours, L["TIME_UNIT_HOUR"])
    else
        local h = math.floor(hours)
        local m = math.floor((seconds % 3600) / 60)
        return string.format("%d%s %d%s", h, L["TIME_UNIT_HOUR"], m, L["TIME_UNIT_MINUTE"])
    end
end

local function FormatTimeTotal(seconds, useYears)
    seconds = tonumber(seconds) or 0
    local hours = seconds / 3600

    if useYears and hours >= 9000 then
        local days = math.floor(hours / 24)
        local years = math.floor(days / 365)
        local remDays = days % 365
        return years > 0 and string.format("%d%s %d%s", years, L["TIME_UNIT_YEAR"], remDays, L["TIME_UNIT_DAY"]) or string.format("%d%s", days, L["TIME_UNIT_DAY"])
    end
    return FormatTimeSmart(seconds, useYears)
end

--------------------------------------------------
-- Data Aggregation
--------------------------------------------------

local function GetAccountTotal()
    local total = 0
    for _, data in pairs(AccountPlayedDB) do
        if type(data) == "table" and data.time then
            total = total + data.time
        end
    end
    return total
end

local function GetClassTotals()
    local totals, accountTotal = {}, 0
    for _, data in pairs(AccountPlayedDB) do
        if type(data) == "table" and data.time and data.class then
            totals[data.class] = (totals[data.class] or 0) + data.time
            accountTotal = accountTotal + data.time
        end
    end
    return totals, accountTotal
end

local function GetCharactersByClass(className)
    local chars = {}
    for charKey, data in pairs(AccountPlayedDB) do
        if type(data) == "table" and data.class == className and data.time then
            table.insert(chars, { key = charKey, time = data.time, class = data.class })
        end
    end
    table.sort(chars, function(a, b) return a.time > b.time end)
    return chars
end

--------------------------------------------------
-- Debug
--------------------------------------------------

local function DebugListCharacters()
    print("|cffff0000" .. L["DEBUG_HEADER"] .. "|r")
    for charKey, data in pairs(AccountPlayedDB) do
        local time, class
        if type(data) == "table" then
            time, class = data.time or 0, data.class or "UNKNOWN"
        else
            time, class = data, "UNKNOWN"
        end
        local displayName = GetLocalizedClass(class)
        print(string.format(" |cffffff00 - %s : %s (%s)|r", charKey, FormatTime(time), class))
    end
end

SLASH_ACCOUNTPLAYEDDEBUG1 = "/apdebug"
SlashCmdList.ACCOUNTPLAYEDDEBUG = DebugListCharacters

--------------------------------------------------
-- Delete Character Command
--------------------------------------------------

-- Confirmation dialog (uses the game's own DELETE / CANCEL globals so every
-- client locale gets properly translated button labels for free).
StaticPopupDialogs["ACCOUNTPLAYED_CONFIRM_DELETE"] = {
    -- %s is replaced by the DB key (e.g. "Area52-Thrall") at show-time.
    text          = "",          -- overwritten dynamically; see DeleteCharacter below
    button1       = DELETE,      -- game global: "Delete" / "删除" / etc.
    button2       = CANCEL,      -- game global: "Cancel" / "取消" / etc.
    OnAccept      = function(self, data)
        if not data or not data.foundKey then return end
        AccountPlayedDB[data.foundKey] = nil
        print("|cff00ff00" .. string.format(L["CMD_DELETE_SUCCESS"], data.foundKey) .. "|r")
        if AP.popupFrame and AP.popupFrame:IsShown() then
            AP.popupFrame:UpdateDisplay()
        end
    end,
    timeout       = 0,
    whileDead     = true,
    hideOnEscape  = true,
    preferredIndex = 3,
}

-- Shared helper: show the confirm dialog for a known DB key.
-- Called by both the slash command and the GUI trash buttons.
local function ConfirmDeleteKey(foundKey)
    StaticPopupDialogs["ACCOUNTPLAYED_CONFIRM_DELETE"].text =
        string.format(L["CMD_DELETE_CONFIRM"], foundKey)
    StaticPopup_Show("ACCOUNTPLAYED_CONFIRM_DELETE", nil, nil, { foundKey = foundKey })
end

-- Accepts "CharName-RealmName" (armory-style).
-- The DB stores keys as "RealmName-CharName", so we flip the two parts.
-- Splitting on the FIRST hyphen handles realm names that themselves contain
-- hyphens (e.g. "Azjol-Nerub"): everything after the first "-" is the realm.
-- Matching is case-insensitive so players don't have to nail the exact casing.
local function DeleteCharacter(input)
    input = input and input:match("^%s*(.-)%s*$") or ""  -- trim whitespace

    if input == "" then
        print("|cffff9900" .. L["CMD_DELETE_USAGE"] .. "|r")
        return
    end

    -- Split "CharName-RealmName" on the first hyphen
    local charName, realmName = input:match("^([^%-]+)%-(.+)$")
    if not charName or not realmName then
        print("|cffff9900" .. L["CMD_DELETE_USAGE"] .. "|r")
        return
    end

    -- Rebuild in the DB's "Realm-Name" order
    local targetKey = realmName .. "-" .. charName

    -- Case-insensitive search so players don't have to worry about capitalisation
    local foundKey = nil
    local lowerTarget = targetKey:lower()
    for dbKey in pairs(AccountPlayedDB) do
        if dbKey:lower() == lowerTarget then
            foundKey = dbKey
            break
        end
    end

    if not foundKey then
        print("|cffff0000" .. string.format(L["CMD_DELETE_NOT_FOUND"], input) .. "|r")
        return
    end

    ConfirmDeleteKey(foundKey)
end

SLASH_ACCOUNTPLAYEDDELETE1 = "/apdelete"
SlashCmdList.ACCOUNTPLAYEDDELETE = DeleteCharacter

--------------------------------------------------
-- Character Management Panel
-- A pinned flyout that anchors to the right of the
-- main popup, showing each character with a trash btn.
--------------------------------------------------

AP.charPanelClass = nil   -- which class is currently pinned

local CPANEL_W        = 230
local CPANEL_ROW_H    = 22
local CPANEL_HEADER_H = 28
local CPANEL_PAD      = 6

local function CreateCharPanel()
    if AP.charPanel then return AP.charPanel end

    local p = CreateFrame("Frame", "AccountPlayedCharPanel", UIParent, "BackdropTemplate")
    p:SetWidth(CPANEL_W)
    p:SetHeight(CPANEL_HEADER_H + CPANEL_PAD)
    p:SetFrameStrata("DIALOG")
    p:SetFrameLevel(110)
    p:SetClampedToScreen(true)

    p:SetBackdrop({
        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    p:SetBackdropColor(0.05, 0.05, 0.05, 0.92)

    -- Class name title
    p.titleText = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    p.titleText:SetPoint("TOPLEFT",  p, "TOPLEFT",  12, -10)
    p.titleText:SetPoint("TOPRIGHT", p, "TOPRIGHT", -26, -10)
    p.titleText:SetJustifyH("LEFT")

    -- Close button (uses WoW's native styled button)
    local closeBtn = CreateFrame("Button", nil, p, "UIPanelCloseButton")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", p, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        p:Hide()
        AP.charPanelClass = nil
    end)

    -- Divider
    local div = p:CreateTexture(nil, "ARTWORK")
    div:SetHeight(1)
    div:SetPoint("TOPLEFT",  p, "TOPLEFT",  10, -(CPANEL_HEADER_H - 2))
    div:SetPoint("TOPRIGHT", p, "TOPRIGHT", -10, -(CPANEL_HEADER_H - 2))
    div:SetColorTexture(0.4, 0.4, 0.4, 0.8)

    -- Reusable character rows (pool of 20)
    p.charRows = {}
    for i = 1, 20 do
        local yOff = -(CPANEL_HEADER_H + CPANEL_PAD + (i - 1) * CPANEL_ROW_H)
        local row  = CreateFrame("Frame", nil, p)
        row:SetHeight(CPANEL_ROW_H)
        row:SetPoint("TOPLEFT",  p, "TOPLEFT",  10, yOff)
        row:SetPoint("TOPRIGHT", p, "TOPRIGHT", -10, yOff)

        -- Subtle hover glow (revealed by trash btn hover)
        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints()
        row.bg:SetColorTexture(1, 1, 1, 0)

        -- Character name
        row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.nameText:SetPoint("LEFT", row, "LEFT", 0, 0)
        row.nameText:SetPoint("RIGHT", row, "RIGHT", -110, 0)
        row.nameText:SetJustifyH("LEFT")
        row.nameText:SetWordWrap(false)

        -- Play time (sits between name and delete button)
        row.timeText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.timeText:SetPoint("RIGHT", row, "RIGHT", -52, 0)
        row.timeText:SetWidth(72)
        row.timeText:SetJustifyH("RIGHT")
        row.timeText:SetTextColor(0.75, 0.75, 0.75)

        -- Delete button
        local trashBtn = CreateFrame("Button", nil, row)
        trashBtn:SetSize(44, 18)
        trashBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)

        local trashLabel = trashBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        trashLabel:SetAllPoints()
        trashLabel:SetText("|cffff4040" .. DELETE .. "|r")
        trashLabel:SetJustifyH("CENTER")

        -- Size the button to fit the DELETE text width
        trashBtn:SetWidth(trashLabel:GetStringWidth() + 8)

        trashBtn:SetScript("OnEnter", function()
            row.bg:SetColorTexture(1, 0.25, 0.25, 0.15)
            GameTooltip:SetOwner(trashBtn, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["CHAR_PANEL_REMOVE_TIP"], 1, 0.35, 0.35)
            GameTooltip:Show()
        end)
        trashBtn:SetScript("OnLeave", function()
            row.bg:SetColorTexture(1, 1, 1, 0)
            GameTooltip:Hide()
        end)
        trashBtn:SetScript("OnClick", function()
            if row.charKey then
                ConfirmDeleteKey(row.charKey)
            end
        end)

        row.trashBtn = trashBtn
        row:Hide()
        p.charRows[i] = row
    end

    p:Hide()
    AP.charPanel = p

    -- Register so Escape closes the panel (same as any standard WoW window)
    table.insert(UISpecialFrames, "AccountPlayedCharPanel")

    return p
end

-- Show (or toggle off) the character panel for the given class.
-- anchorRow : the class row frame to anchor next to (where the tooltip was).
--             Omit when forceShow=true (panel keeps its current position).
-- forceShow : repopulate without toggling (used by UpdateDisplay after a delete).
function AP.ShowCharPanel(className, forceShow, anchorRow)
    local p = CreateCharPanel()

    -- Toggle off when right-clicking the same class a second time
    if not forceShow and AP.charPanelClass == className and p:IsShown() then
        p:Hide()
        AP.charPanelClass = nil
        return
    end

    local chars = GetCharactersByClass(className)
    if #chars == 0 then
        p:Hide()
        AP.charPanelClass = nil
        return
    end

    AP.charPanelClass = className

    -- Re-anchor only when we have a fresh row reference (i.e. not a forced
    -- repopulate after a delete, where the panel is already in the right place).
    if anchorRow then
        p:ClearAllPoints()
        p:SetPoint("TOPLEFT", anchorRow, "TOPRIGHT", 6, 0)
    elseif not p:IsShown() then
        -- Fallback: anchor to the main popup's right edge if no row given
        p:ClearAllPoints()
        if AP.popupFrame and AP.popupFrame:IsShown() then
            p:SetPoint("TOPLEFT", AP.popupFrame, "TOPRIGHT", 4, 0)
        else
            p:SetPoint("CENTER")
        end
    end

    -- Title (class-coloured)
    local color = RAID_CLASS_COLORS[className] or { r = 1, g = 1, b = 1 }
    p.titleText:SetText(GetLocalizedClass(className))
    p.titleText:SetTextColor(color.r, color.g, color.b)

    -- Populate rows
    for i, row in ipairs(p.charRows) do
        local char = chars[i]
        if char then
            local name    = char.key:match("%-(.+)$") or char.key
            local timeStr = FormatTimeDetailed(char.time, AccountPlayedPopupDB.useYears)
            row.nameText:SetText(name)
            row.nameText:SetTextColor(color.r, color.g, color.b)
            row.timeText:SetText(timeStr)
            row.charKey = char.key
            row:Show()
        else
            row.charKey = nil
            row:Hide()
        end
    end

    -- Resize to fit the number of characters
    p:SetHeight(CPANEL_HEADER_H + CPANEL_PAD + #chars * CPANEL_ROW_H + CPANEL_PAD)
    p:Show()
end

--------------------------------------------------
-- UI Components
--------------------------------------------------

local function CreateRow(parent, width, height)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(width, height)
    row:EnableMouse(true)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    row.highlight = row:CreateTexture(nil, "BACKGROUND")
    row.highlight:SetAllPoints()
    row.highlight:SetColorTexture(1, 1, 1, 0.1)
    row.highlight:Hide()

    row.classText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.classText:SetPoint("LEFT", 0, 0)
    row.classText:SetWidth(120)
    row.classText:SetJustifyH("LEFT")

    row.bar = CreateFrame("StatusBar", nil, row)
    row.bar:SetPoint("LEFT", row.classText, "RIGHT", 8, 0)
    row.bar:SetPoint("RIGHT", row, "RIGHT", -140, 0) -- -20px
    row.bar:SetHeight(height - 4)
    row.bar:SetMinMaxValues(0, 1)
    row.bar:SetValue(0)
    row.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

    row.bar.bg = row.bar:CreateTexture(nil, "BACKGROUND")
    row.bar.bg:SetAllPoints()
    row.bar.bg:SetColorTexture(0, 0, 0, 0.4)

    row.valueText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.valueText:SetPoint("LEFT", row.bar, "RIGHT", 8, 0)
    row.valueText:SetWidth(170) -- +20px
    row.valueText:SetJustifyH("LEFT")

    row:SetScript("OnEnter", function(self)
        self.highlight:Show()
        if self.className then
            local chars = GetCharactersByClass(self.className)
            if #chars > 0 then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                local localizedName = GetLocalizedClass(self.className)
                GameTooltip:AddLine(localizedName, 1, 1, 1)
                GameTooltip:AddLine(" ")
                for _, char in ipairs(chars) do
                    local name = char.key:match("%-(.+)$") or char.key
                    local timeStr = FormatTimeDetailed(char.time, AccountPlayedPopupDB.useYears)
                    local color = RAID_CLASS_COLORS[char.class] or { r = 1, g = 1, b = 1 }
                    GameTooltip:AddDoubleLine(name, timeStr, color.r, color.g, color.b, 1, 1, 1)
                end
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(L["CLICK_TO_PRINT"],       0.5, 0.5, 0.5)
                GameTooltip:AddLine(L["CHAR_PANEL_RIGHT_CLICK"], 0.5, 0.5, 0.5)
                GameTooltip:Show()
            end
        end
    end)

    row:SetScript("OnLeave", function(self)
        self.highlight:Hide()
        GameTooltip:Hide()
    end)

    row:SetScript("OnClick", function(self, button)
        if not self.className then return end

        if button == "RightButton" then
            -- Hide the hover tooltip — the panel takes its place
            GameTooltip:Hide()
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            -- Pass self so the panel anchors right next to this row
            AP.ShowCharPanel(self.className, false, self)

        else
            -- Left-click: print class breakdown to chat (existing behaviour)
            local chars = GetCharactersByClass(self.className)
            if #chars > 0 then
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                local localizedName = GetLocalizedClass(self.className)
                print("|cff00ff00" .. localizedName .. ":|r")
                for _, char in ipairs(chars) do
                    local name = char.key:match("%-(.+)$") or char.key
                    local timeStr = FormatTimeDetailed(char.time, AccountPlayedPopupDB.useYears)
                    local color = RAID_CLASS_COLORS[char.class] or { r = 1, g = 1, b = 1 }
                    print(string.format("  |cff%02x%02x%02x%s|r - %s",
                        color.r * 255, color.g * 255, color.b * 255, name, timeStr))
                end
            end
        end
    end)

    return row
end

local function UpdateScrollBarVisibility(frame)
    local sf = frame.scrollFrame
    local sb = sf and (sf.ScrollBar or sf.scrollBar)
    if not sb then return end

    if sf:GetVerticalScrollRange() > 0 then
        sb:Show()
    else
        sb:Hide()
        sf:SetVerticalScroll(0)
    end
end

--------------------------------------------------
-- Main Popup Window
--------------------------------------------------

local function CreatePopup()
    if AP.popupFrame then return AP.popupFrame end

    -- Load saved size or use defaults
    local START_W = AccountPlayedPopupDB.width or 540 -- +20px
    local START_H = AccountPlayedPopupDB.height or 300
    local MIN_W, MIN_H = 420, 200
    local MAX_W, MAX_H = 720, 400

    local f = CreateFrame("Frame", "AccountPlayedPopup", UIParent, "BackdropTemplate")
    f:SetSize(START_W, START_H)
    
    if AccountPlayedPopupDB.point then
        f:SetPoint(AccountPlayedPopupDB.point, UIParent, AccountPlayedPopupDB.point, 
                   AccountPlayedPopupDB.x or 0, AccountPlayedPopupDB.y or 0)
    else
        f:SetPoint("CENTER")
    end
    
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(100)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        AccountPlayedPopupDB.point = point
        AccountPlayedPopupDB.x = x
        AccountPlayedPopupDB.y = y
    end)

    f:SetResizable(true)
    if f.SetResizeBounds then
        f:SetResizeBounds(MIN_W, MIN_H, MAX_W, MAX_H)
    elseif f.SetMinResize then
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

    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:SetBackdropColor(0, 0, 0, 0.5)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.title:SetPoint("TOP", f, "TOP", 0, -12)
    f.title:SetText(L["WINDOW_TITLE"])

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -10, -10)
    close:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
        f:Hide()  -- OnHide handles charPanel cleanup
    end)
    
    table.insert(UISpecialFrames, "AccountPlayedPopup")

    -- Close the char panel whenever this window hides for ANY reason
    -- (X button, Escape key, /apclasswin toggle, etc.)
    f:SetScript("OnHide", function()
        if AP.charPanel then AP.charPanel:Hide() end
        AP.charPanelClass = nil
    end)

    -- ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 15, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)
    f.scrollFrame = scrollFrame

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    f.content = content

    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local step = 20
        local new = self:GetVerticalScroll() - delta * step
        new = math.max(0, math.min(new, self:GetVerticalScrollRange()))
        self:SetVerticalScroll(new)
    end)

    f.totalRow = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.totalRow:SetPoint("BOTTOMLEFT", 15, 18)
    f.totalRow:SetTextColor(1, 0.82, 0)

    -- Create rows
    local rowHeight = 22
    for i = 1, 20 do
        local row = CreateRow(content, START_W - 60, rowHeight)
        row:SetPoint("TOPLEFT", 0, -(i - 1) * rowHeight)
        row:Hide()
        AP.popupRows[i] = row
    end

    f:SetScript("OnSizeChanged", function(self, w, h)
        if w < MIN_W then self:SetWidth(MIN_W) end
        if h < MIN_H then self:SetHeight(MIN_H) end
        if w > MAX_W then self:SetWidth(MAX_W) end
        if h > MAX_H then self:SetHeight(MAX_H) end

        AccountPlayedPopupDB.width = self:GetWidth()
        AccountPlayedPopupDB.height = self:GetHeight()

        local cw = self.scrollFrame:GetWidth()
        self.content:SetWidth(cw)
        for _, row in ipairs(AP.popupRows) do
            row:SetWidth(cw)
        end

        UpdateScrollBarVisibility(self)
    end)

    -- Format toggle checkbox
    local checkBox = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
    checkBox:SetSize(24, 24)
    checkBox:SetPoint("BOTTOMRIGHT", -28, 20)
    checkBox:SetChecked(AccountPlayedPopupDB.useYears)
    
    checkBox.text = checkBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    checkBox.text:SetPoint("RIGHT", checkBox, "LEFT", -4, 0)
    checkBox.text:SetText(L["USE_YEARS_LABEL"])
    checkBox.text:SetTextColor(0.9, 0.9, 0.9)
    
    checkBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(L["TIME_FORMAT_TITLE"], 1, 1, 1)
        GameTooltip:AddLine(L["TIME_FORMAT_YEARS"], 0.8, 0.8, 0.8)
        GameTooltip:AddLine(L["TIME_FORMAT_HOURS"], 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    
    checkBox:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    checkBox:SetScript("OnClick", function(self)
        AccountPlayedPopupDB.useYears = self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if AP.popupFrame and AP.popupFrame.UpdateDisplay then
            AP.popupFrame:UpdateDisplay()
        end
    end)
    
    f.formatCheckbox = checkBox

    -- Display update method
    f.UpdateDisplay = function(self)
        local totals = GetClassTotals()
        local accountTotal = GetAccountTotal()

        if accountTotal == 0 then
            AP.popupRows[1].classText:SetText(L["NO_DATA"])
            AP.popupRows[1].bar:SetValue(0)
            AP.popupRows[1].valueText:SetText("")
            AP.popupRows[1]:Show()
            self.totalRow:SetText(L["TOTAL"] .. FormatTimeTotal(0, AccountPlayedPopupDB.useYears))
            return
        end

        local sorted = {}
        for class, time in pairs(totals) do
            table.insert(sorted, { class = class, time = time })
        end
        table.sort(sorted, function(a, b) return a.time > b.time end)

        local topTime = sorted[1].time

        for i, row in ipairs(AP.popupRows) do
            local entry = sorted[i]
            if entry then
                local percent = entry.time / accountTotal
                local barPercent = entry.time / topTime
                local color = RAID_CLASS_COLORS[entry.class] or { r = 1, g = 1, b = 1 }

                row.className = entry.class
                row.classText:SetText(GetLocalizedClass(entry.class))
                row.classText:SetTextColor(color.r, color.g, color.b)
                row.bar:SetValue(barPercent)
                row.bar:SetStatusBarColor(color.r, color.g, color.b)
                row.valueText:SetText(string.format("%5.1f%% - %s", percent * 100, 
                    FormatTimeSmart(entry.time, AccountPlayedPopupDB.useYears)))
                row:Show()
            else
                row.className = nil
                row:Hide()
            end
        end

        self.content:SetHeight(#sorted * 22)
        UpdateScrollBarVisibility(self)
        self.totalRow:SetText(L["TOTAL"] .. FormatTimeTotal(accountTotal, AccountPlayedPopupDB.useYears))

        -- If the character panel is pinned open, repopulate it in place so
        -- deleted entries vanish immediately without the user having to re-open.
        if AP.charPanel and AP.charPanel:IsShown() and AP.charPanelClass then
            AP.ShowCharPanel(AP.charPanelClass, true)  -- forceShow = no toggle
        end
    end

    f:Hide()
    AP.popupFrame = f
    return f
end

local function UpdatePopup()
    local f = CreatePopup()
    if f.formatCheckbox then
        f.formatCheckbox:SetChecked(AccountPlayedPopupDB.useYears)
    end
    f:UpdateDisplay()
    f:Show()
end

--------------------------------------------------
-- Slash Commands
--------------------------------------------------

SLASH_ACCOUNTPLAYEDPOPUP1 = "/apclasswin"
SlashCmdList.ACCOUNTPLAYEDPOPUP = function()
    if AP.popupFrame and AP.popupFrame:IsShown() then
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
        AP.popupFrame:Hide()
    else
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
        UpdatePopup()
    end
end

--------------------------------------------------
-- Events
--------------------------------------------------

AP.mainFrame:RegisterEvent("PLAYER_LOGIN")
AP.mainFrame:RegisterEvent("TIME_PLAYED_MSG")

AP.mainFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        MigrateOldData()
        SafeRequestTimePlayed()
    elseif event == "TIME_PLAYED_MSG" then
        local totalTimePlayed = ...
        local realm, name = GetCharInfo()
        local charKey = GetCharKey(realm, name)
        local _, classFile = UnitClass("player")
        classFile = classFile or "UNKNOWN"

        local existing = AccountPlayedDB[charKey]
        if not existing or not existing.time or totalTimePlayed > existing.time then
            AccountPlayedDB[charKey] = {
                time = totalTimePlayed,
                class = classFile,
            }
        end
    end
end)

--------------------------------------------------
-- Minimap Toggle Slash Command  /aplayed minimap
--------------------------------------------------

SLASH_ACCOUNTPLAYED1 = "/aplayed"
SlashCmdList.ACCOUNTPLAYED = function(input)
    input = (input or ""):match("^%s*(.-)%s*$"):lower()
    if input == "minimap" then
        local btn = _G["AccountPlayed_MinimapButton"]
        if btn then
            if btn:IsShown() then
                btn:Hide()
                AccountPlayedMinimapDB.hidden = true
                print("|cff00ff00Account Played:|r Minimap icon hidden. Use /aplayed minimap to show it again.")
            else
                btn:Show()
                AccountPlayedMinimapDB.hidden = false
                print("|cff00ff00Account Played:|r Minimap icon shown.")
            end
        end
    else
        print("AccountPlayed commands: /aplayed minimap")
    end
end

--------------------------------------------------
-- Persist minimap hidden state across sessions
--------------------------------------------------

local persistFrame = CreateFrame("Frame")
persistFrame:RegisterEvent("PLAYER_LOGIN")
persistFrame:SetScript("OnEvent", function(self)
    C_Timer.After(0, function()
        if AccountPlayedMinimapDB and AccountPlayedMinimapDB.hidden then
            local btn = _G["AccountPlayed_MinimapButton"]
            if btn then btn:Hide() end
        end
    end)
    self:UnregisterEvent("PLAYER_LOGIN")
end)

--------------------------------------------------
-- LibDataBroker plugin
--   Allows LDB display addons (Bazooka, Titan Panel, etc.)
--   to show an AccountPlayed data source.
--------------------------------------------------

local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("AccountPlayed", {
    type = "data source",
    text = "AccountPlayed",
    icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("|cffffffffAccount Played|r")
        tooltip:AddLine("Click to toggle the played time window")
    end,
    OnClick = function(_, button)
        if button == "LeftButton" then
            SlashCmdList.ACCOUNTPLAYEDPOPUP()
        end
    end,
})
