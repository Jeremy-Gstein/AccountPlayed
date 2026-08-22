-- Account Played
-- Lazy main window for account-wide played-time distributions and characters.

local _, AP = ...
local L = AP.L or {}

local MainWindow = AP.MainWindow or {}
AP.MainWindow = MainWindow
AP.modules = AP.modules or {}
AP.modules.MainWindow = MainWindow

local WINDOW_NAME = "AccountPlayedMainWindow"
local MIN_WIDTH = 500
local MIN_HEIGHT = 260
local MAX_WIDTH = 1400
local MAX_HEIGHT = 900
local BASE_DISTRIBUTION_ROW_HEIGHT = 26
local BASE_CHARACTER_ROW_HEIGHT = 26
local CONTENT_PADDING = 5
local PIE_GRID_RADIUS = 9
local TWO_PI = math.pi * 2

local TAB_ORDER = { "class", "characters", "race", "faction" }
local TAB_LABELS = {
    class = L["TAB_CLASS"] or CLASS or "Class",
    characters = L["TAB_CHARACTERS"] or CHARACTERS or "Characters",
    race = L["TAB_RACE"] or RACE or "Race",
    faction = L["TAB_FACTION"] or FACTION or "Faction",
}

local function SolidColor(texture, red, green, blue, alpha)
    if texture.SetColorTexture then
        texture:SetColorTexture(red, green, blue, alpha)
    else
        texture:SetTexture(red, green, blue, alpha)
    end
end

local function AddSpecialFrame(name)
    if type(UISpecialFrames) ~= "table" then return end
    for index = 1, #UISpecialFrames do
        if UISpecialFrames[index] == name then return end
    end
    UISpecialFrames[#UISpecialFrames + 1] = name
end

local function Clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function SetNoWrap(fontString)
    if fontString.SetWordWrap then fontString:SetWordWrap(false) end
    if fontString.SetNonSpaceWrap then fontString:SetNonSpaceWrap(false) end
end

local function SetFontSize(fontString, size)
    if not fontString or not fontString.GetFont or not fontString.SetFont then return end
    local path, _, flags = fontString:GetFont()
    if not path and GameFontNormal and GameFontNormal.GetFont then
        path, _, flags = GameFontNormal:GetFont()
    end
    if path then fontString:SetFont(path, size, flags or "") end
end

local function PopupSettings()
    if AP.Data and AP.Data.GetPopupSettings then
        return AP.Data:GetPopupSettings()
    end
    return {
        width = 640,
        height = 380,
        point = "CENTER",
        x = 0,
        y = 0,
        activeTab = "class",
        chartMode = "bar",
        valueMode = "both",
        useYears = false,
        textScale = 1,
    }
end

local function SetPopupSetting(key, value)
    if AP.Data and AP.Data.SetPopupSetting then
        return AP.Data:SetPopupSetting(key, value)
    end
    local settings = PopupSettings()
    settings[key] = value
    return value
end

local function PlaySoundKey(key)
    local sound = SOUNDKIT and SOUNDKIT[key]
    if AP.PlaySound then AP:PlaySound(sound) end
end

local function FormatDetailedTime(seconds)
    local settings = PopupSettings()
    if AP.Format and AP.Format.DetailedTime then
        return AP.Format:DetailedTime(seconds, settings.useYears)
    end
    return tostring(seconds or 0)
end

local function FormatTotalTime(seconds)
    local settings = PopupSettings()
    if AP.Format and AP.Format.TotalTime then
        return AP.Format:TotalTime(seconds, settings.useYears)
    end
    return tostring(seconds or 0)
end

local function DistributionValue(seconds, total)
    local settings = PopupSettings()
    if AP.Format and AP.Format.DistributionValue then
        return AP.Format:DistributionValue(seconds, total, settings.valueMode, settings.useYears)
    end
    local percent = total > 0 and seconds / total * 100 or 0
    return string.format("%.1f%%", percent)
end

local function GroupLabel(kind, entry)
    if AP.Format and AP.Format.GroupLabel then
        return AP.Format:GroupLabel(kind, entry)
    end
    return tostring(entry and entry.key or L["UNKNOWN"] or "Unknown")
end

local function GroupColor(kind, key)
    if AP.Format and AP.Format.GroupColor then
        return AP.Format:GroupColor(kind, key)
    end
    return { r = 1, g = 1, b = 1 }
end

local function CharacterColor(classFile)
    if AP.Format and AP.Format.CharacterColor then
        return AP.Format:CharacterColor(classFile)
    end
    return { r = 1, g = 1, b = 1 }
end

local function CharacterClassName(classFile)
    if AP.Format and AP.Format.ClassName then return AP.Format:ClassName(classFile) end
    return tostring(classFile or L["UNKNOWN"] or "Unknown")
end

local function CharacterRaceName(character)
    if AP.Format and AP.Format.RaceName then
        return AP.Format:RaceName(character.race, character.raceName)
    end
    return tostring(character.raceName or character.race or L["UNKNOWN"] or "Unknown")
end

local function CharacterFactionName(character)
    if AP.Format and AP.Format.FactionName then
        return AP.Format:FactionName(character.faction, character.factionName)
    end
    return tostring(character.factionName or character.faction or L["UNKNOWN"] or "Unknown")
end

local function ColorCode(color)
    if AP.Format and AP.Format.ColorCode then return AP.Format:ColorCode(color) end
    return "|cffffffff"
end

local function GetDistribution(kind)
    if AP.Data and AP.Data.GetDistribution then
        return AP.Data:GetDistribution(kind)
    end
    return {}, 0
end

local function GetCharacters(kind, key)
    if AP.Data and AP.Data.GetAllCharacters then
        return AP.Data:GetAllCharacters(kind, key)
    end
    return {}
end

local function GetAllCharacters()
    if AP.Data and AP.Data.GetAllCharacters then return AP.Data:GetAllCharacters() end
    return {}
end

local function GetAccountTotal()
    if AP.Data and AP.Data.GetAccountTotal then return AP.Data:GetAccountTotal() end
    return 0
end

local function GetCharacterCount()
    if AP.Data and AP.Data.GetCharacterCount then return AP.Data:GetCharacterCount() end
    return #GetAllCharacters()
end

local function AddChatMessage(message)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage(message)
    elseif print then
        print(message)
    end
end

local function PrintDistributionDetails(kind, entry)
    local characters = GetCharacters(kind, entry.key)
    if #characters == 0 then return end

    local color = GroupColor(kind, entry.key)
    local label = GroupLabel(kind, entry)
    if AP.Print then
        AP:Print(ColorCode(color) .. label .. "|r - " .. FormatDetailedTime(entry.time))
    else
        AddChatMessage(label .. " - " .. FormatDetailedTime(entry.time))
    end

    for index = 1, #characters do
        local character = characters[index]
        local characterColor = CharacterColor(character.class)
        AddChatMessage(string.format("  %s%s|r - %s - %s",
            ColorCode(characterColor),
            character.name or character.key,
            character.realm or "",
            FormatDetailedTime(character.time)))
    end
end

local function ShowDistributionTooltip(row)
    if not GameTooltip or not row.entry then return end
    local entry = row.entry
    local color = GroupColor(row.kind, entry.key)
    local characters = GetCharacters(row.kind, entry.key)

    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    if GameTooltip.ClearLines then GameTooltip:ClearLines() end
    GameTooltip:AddLine(GroupLabel(row.kind, entry), color.r or 1, color.g or 1, color.b or 1)
    GameTooltip:AddDoubleLine(L["TOTAL"] or TOTAL or "Total", FormatDetailedTime(entry.time), 0.8, 0.8, 0.8, 1, 1, 1)
    GameTooltip:AddLine(" ")

    for index = 1, #characters do
        local character = characters[index]
        local characterColor = CharacterColor(character.class)
        local identity = character.name or character.key
        if character.realm and character.realm ~= "" then
            identity = identity .. " - " .. character.realm
        end
        GameTooltip:AddDoubleLine(identity, FormatDetailedTime(character.time),
            characterColor.r or 1, characterColor.g or 1, characterColor.b or 1,
            1, 1, 1)
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["CLICK_TO_PRINT"] or "Left-click to print in chat", 0.55, 0.55, 0.55)
    GameTooltip:AddLine(L["CHAR_PANEL_RIGHT_CLICK"] or "Right-click to manage characters", 0.55, 0.55, 0.55)
    GameTooltip:Show()
end

local function RequestDelete(key)
    if AP.CharacterPanel and AP.CharacterPanel.ConfirmDelete then
        return AP.CharacterPanel:ConfirmDelete(key)
    end
    if AP.Commands and AP.Commands.ConfirmDelete then
        AP.Commands:ConfirmDelete(key)
        return true
    end
    return false
end

local function ScrollBarFor(scrollFrame)
    if not scrollFrame then return nil end
    if scrollFrame.ScrollBar then return scrollFrame.ScrollBar end
    if scrollFrame.scrollBar then return scrollFrame.scrollBar end
    local name = scrollFrame.GetName and scrollFrame:GetName()
    return name and _G[name .. "ScrollBar"] or nil
end

local function UpdateScrollRange(frame)
    if not frame or not frame.scrollFrame then return end
    local scrollFrame = frame.scrollFrame
    if scrollFrame.UpdateScrollChildRect then scrollFrame:UpdateScrollChildRect() end
    local range = scrollFrame.GetVerticalScrollRange and scrollFrame:GetVerticalScrollRange() or 0
    local scrollBar = ScrollBarFor(scrollFrame)
    if range > 0 then
        if scrollBar then scrollBar:Show() end
    else
        scrollFrame:SetVerticalScroll(0)
        if scrollBar then scrollBar:Hide() end
    end
end

local function ContentWidth(frame)
    local width = frame.scrollFrame and frame.scrollFrame:GetWidth() or 0
    if not width or width < 1 then width = (frame:GetWidth() or 640) - 50 end
    return math.max(1, width)
end

local function ResetDistributionRow(row)
    row.entry = nil
    row.kind = nil
    row.labelText:SetText("")
    row.valueText:SetText("")
    row.bar:SetValue(0)
    row.bar:Hide()
    row.swatch:Hide()
    row:Hide()
end

local function StyleDistributionRow(row, width, scale, pieMode)
    local height = math.floor(BASE_DISTRIBUTION_ROW_HEIGHT * scale + 0.5)
    local gap = math.floor(5 * scale + 0.5)
    local labelWidth = math.min(math.floor((112 + 28 * scale) + 0.5), math.floor(width * 0.40))
    local valueWidth = math.min(math.floor((78 + 22 * scale) + 0.5), math.floor(width * 0.30))

    row:SetSize(width, height)
    SetFontSize(row.labelText, 12 * scale)
    SetFontSize(row.valueText, 12 * scale)

    row.valueText:ClearAllPoints()
    row.valueText:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    row.valueText:SetWidth(valueWidth)

    row.labelText:ClearAllPoints()
    if pieMode then
        local swatchSize = math.max(9, height - math.floor(10 * scale + 0.5))
        row.swatch:SetSize(swatchSize, swatchSize)
        row.swatch:ClearAllPoints()
        row.swatch:SetPoint("LEFT", row, "LEFT", 4, 0)
        row.labelText:SetPoint("LEFT", row.swatch, "RIGHT", gap, 0)
        row.labelText:SetWidth(math.max(20, width - valueWidth - swatchSize - gap - 16))
        row.bar:Hide()
        row.swatch:Show()
    else
        row.labelText:SetPoint("LEFT", row, "LEFT", 2, 0)
        row.labelText:SetWidth(labelWidth)
        row.bar:ClearAllPoints()
        row.bar:SetPoint("LEFT", row.labelText, "RIGHT", gap, 0)
        row.bar:SetPoint("RIGHT", row.valueText, "LEFT", -gap, 0)
        row.bar:SetHeight(math.max(8, height - math.floor(8 * scale + 0.5)))
        row.swatch:Hide()
        row.bar:Show()
    end
end

local function CreateDistributionRow(frame)
    local row = CreateFrame("Button", nil, frame.content)
    row:EnableMouse(true)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    row.highlight = row:CreateTexture(nil, "BACKGROUND")
    row.highlight:SetAllPoints()
    SolidColor(row.highlight, 1, 1, 1, 0.09)
    row.highlight:Hide()

    row.labelText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.labelText:SetJustifyH("LEFT")
    SetNoWrap(row.labelText)
    row.classText = row.labelText -- Compatibility for integrations that inspected class rows.

    row.bar = CreateFrame("StatusBar", nil, row)
    row.bar:SetMinMaxValues(0, 1)
    row.bar:SetValue(0)
    row.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    row.barBackground = row.bar:CreateTexture(nil, "BACKGROUND")
    row.barBackground:SetAllPoints()
    SolidColor(row.barBackground, 0, 0, 0, 0.45)

    row.swatch = row:CreateTexture(nil, "ARTWORK")
    row.swatch:Hide()

    row.valueText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.valueText:SetJustifyH("RIGHT")
    SetNoWrap(row.valueText)

    row:SetScript("OnEnter", function(self)
        if not self.entry then return end
        self.highlight:Show()
        ShowDistributionTooltip(self)
    end)
    row:SetScript("OnLeave", function(self)
        self.highlight:Hide()
        if GameTooltip then GameTooltip:Hide() end
    end)
    row:SetScript("OnClick", function(self, button)
        if not self.entry then return end
        if button == "RightButton" then
            if GameTooltip then GameTooltip:Hide() end
            if AP.CharacterPanel and AP.CharacterPanel.Toggle then
                AP.CharacterPanel:Toggle(self.kind, self.entry.key, self.entry, self)
            end
        else
            PlaySoundKey("IG_MAINMENU_OPTION_CHECKBOX_ON")
            PrintDistributionDetails(self.kind, self.entry)
        end
    end)

    row:Hide()
    frame.distributionRows[#frame.distributionRows + 1] = row
    return row
end

local function AcquireDistributionRow(frame, index)
    while #frame.distributionRows < index do CreateDistributionRow(frame) end
    return frame.distributionRows[index]
end

local CHARACTER_FIELDS = { "nameText", "realmText", "classText", "raceText", "factionText", "timeText" }

local function CharacterColumnLayout(width, scale)
    local gap = math.floor(3 + 2 * (scale - 1) + 0.5)
    local deleteWidth = math.min(math.floor(60 + 20 * (scale - 1) + 0.5), math.floor(width * 0.15))
    local timeWidth = math.min(math.floor(88 + 32 * (scale - 1) + 0.5), math.floor(width * 0.19))
    local available = math.max(180, width - deleteWidth - timeWidth - gap * 7 - 4)
    local weights = { 1.22, 1.17, 1.0, 0.95, 0.86 }
    local weightTotal = 5.20
    local widths = {}
    local used = 0
    for index = 1, 4 do
        widths[index] = math.floor(available * weights[index] / weightTotal)
        used = used + widths[index]
    end
    widths[5] = available - used
    widths[6] = timeWidth
    widths[7] = deleteWidth
    widths.gap = gap
    return widths
end

local function StyleCharacterColumns(row, width, scale, isHeader)
    local widths = CharacterColumnLayout(width, scale)
    local gap = widths.gap
    local x = 2
    local fields = { "nameText", "realmText", "classText", "raceText", "factionText" }

    row:SetWidth(width)
    for index = 1, #fields do
        local fontString = row[fields[index]]
        fontString:ClearAllPoints()
        fontString:SetPoint("LEFT", row, "LEFT", x, 0)
        fontString:SetWidth(widths[index])
        SetFontSize(fontString, (isHeader and 10 or 11) * scale)
        x = x + widths[index] + gap
    end

    row.timeText:ClearAllPoints()
    row.timeText:SetPoint("LEFT", row, "LEFT", x, 0)
    row.timeText:SetWidth(widths[6])
    SetFontSize(row.timeText, (isHeader and 10 or 11) * scale)

    if row.deleteButton then
        row.deleteButton:ClearAllPoints()
        row.deleteButton:SetPoint("RIGHT", row, "RIGHT", -2, 0)
        row.deleteButton:SetWidth(widths[7])
        local buttonFont = row.deleteButton.GetFontString and row.deleteButton:GetFontString()
        SetFontSize(buttonFont, 10 * scale)
    end
end

local function ResetCharacterRow(row)
    row.character = nil
    for index = 1, #CHARACTER_FIELDS do row[CHARACTER_FIELDS[index]]:SetText("") end
    row:Hide()
end

local function CreateCharacterRow(frame)
    local row = CreateFrame("Frame", nil, frame.content)
    row:EnableMouse(true)

    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints()
    SolidColor(row.background, 1, 1, 1, 0.03)

    for index = 1, #CHARACTER_FIELDS do
        local field = CHARACTER_FIELDS[index]
        row[field] = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row[field]:SetJustifyH(field == "timeText" and "RIGHT" or "LEFT")
        SetNoWrap(row[field])
    end

    row.realmText:SetTextColor(0.70, 0.70, 0.70)
    row.raceText:SetTextColor(0.82, 0.82, 0.82)
    row.factionText:SetTextColor(0.82, 0.82, 0.82)
    row.timeText:SetTextColor(0.92, 0.92, 0.92)

    row.deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.deleteButton:SetText(DELETE or "Delete")
    row.deleteButton:SetScript("OnClick", function()
        if row.character then
            PlaySoundKey("IG_MAINMENU_OPTION_CHECKBOX_ON")
            RequestDelete(row.character.key)
        end
    end)
    row.deleteButton:SetScript("OnEnter", function(self)
        SolidColor(row.background, 1, 0.2, 0.2, 0.14)
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["CHAR_PANEL_REMOVE_TIP"] or "Remove from Account Played", 1, 0.35, 0.35)
            GameTooltip:Show()
        end
    end)
    row.deleteButton:SetScript("OnLeave", function()
        SolidColor(row.background, 1, 1, 1, 0.03)
        if GameTooltip then GameTooltip:Hide() end
    end)

    row:Hide()
    frame.characterRows[#frame.characterRows + 1] = row
    return row
end

local function AcquireCharacterRow(frame, index)
    while #frame.characterRows < index do CreateCharacterRow(frame) end
    return frame.characterRows[index]
end

local function Atan2(y, x)
    if x > 0 then return math.atan(y / x) end
    if x < 0 and y >= 0 then return math.atan(y / x) + math.pi end
    if x < 0 and y < 0 then return math.atan(y / x) - math.pi end
    if x == 0 and y > 0 then return math.pi / 2 end
    if x == 0 and y < 0 then return -math.pi / 2 end
    return math.pi / 2
end

local function HighlightPieEntry(frame, key)
    for index = 1, #frame.pieCells do
        local cell = frame.pieCells[index]
        if key and cell.entry and cell.entry.key ~= key then
            cell.texture:SetAlpha(0.42)
        else
            cell.texture:SetAlpha(1)
        end
    end
end

local function EnsurePieCells(frame)
    if #frame.pieCells > 0 then return end
    for y = PIE_GRID_RADIUS, -PIE_GRID_RADIUS, -1 do
        for x = -PIE_GRID_RADIUS, PIE_GRID_RADIUS do
            if x * x + y * y <= (PIE_GRID_RADIUS + 0.25) * (PIE_GRID_RADIUS + 0.25) then
                local angle = Atan2(y, x)
                local fraction = ((math.pi / 2 - angle) % TWO_PI) / TWO_PI
                local hitTarget = CreateFrame("Button", nil, frame.pieFrame)
                hitTarget:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                local texture = hitTarget:CreateTexture(nil, "ARTWORK")
                texture:SetAllPoints()
                local cell = {
                    hitTarget = hitTarget,
                    texture = texture,
                    x = x,
                    y = y,
                    fraction = fraction,
                }
                hitTarget.pieCell = cell
                hitTarget:SetScript("OnEnter", function(self)
                    if not self.entry then return end
                    HighlightPieEntry(frame, self.entry.key)
                    ShowDistributionTooltip(self)
                end)
                hitTarget:SetScript("OnLeave", function()
                    HighlightPieEntry(frame, nil)
                    if GameTooltip then GameTooltip:Hide() end
                end)
                hitTarget:SetScript("OnClick", function(self, button)
                    if not self.entry then return end
                    if button == "RightButton" then
                        if GameTooltip then GameTooltip:Hide() end
                        if AP.CharacterPanel and AP.CharacterPanel.Toggle then
                            AP.CharacterPanel:Toggle(self.kind, self.entry.key, self.entry, self)
                        end
                    else
                        PlaySoundKey("IG_MAINMENU_OPTION_CHECKBOX_ON")
                        PrintDistributionDetails(self.kind, self.entry)
                    end
                end)
                frame.pieCells[#frame.pieCells + 1] = cell
            end
        end
    end
end

local function LayoutPie(frame, entries, total, scale)
    EnsurePieCells(frame)
    local chartSize = math.floor(144 + 28 * (scale - 1) + 0.5)
    local cellSize = chartSize / (PIE_GRID_RADIUS * 2 + 1)
    local colors = {}
    local cumulative = {}
    local running = 0

    for index = 1, #entries do
        colors[index] = GroupColor(entries[index].kind, entries[index].key)
        running = running + (total > 0 and entries[index].time / total or 0)
        cumulative[index] = running
    end
    cumulative[#entries] = 1

    frame.pieFrame:SetSize(chartSize, chartSize)
    frame.pieFrame:ClearAllPoints()
    frame.pieFrame:SetPoint("TOP", frame.content, "TOP", 0, -CONTENT_PADDING)

    for index = 1, #frame.pieCells do
        local cell = frame.pieCells[index]
        local entryIndex = 1
        while entryIndex < #entries and cell.fraction >= cumulative[entryIndex] do
            entryIndex = entryIndex + 1
        end
        local color = colors[entryIndex] or { r = 0.5, g = 0.5, b = 0.5 }
        cell.entry = entries[entryIndex]
        cell.hitTarget.entry = cell.entry
        cell.hitTarget.kind = cell.entry and cell.entry.kind
        cell.hitTarget:ClearAllPoints()
        cell.hitTarget:SetPoint("CENTER", frame.pieFrame, "CENTER", cell.x * cellSize, cell.y * cellSize)
        cell.hitTarget:SetSize(math.ceil(cellSize + 0.35), math.ceil(cellSize + 0.35))
        SolidColor(cell.texture, color.r or 1, color.g or 1, color.b or 1, 1)
        cell.texture:SetAlpha(1)
        cell.hitTarget:Show()
    end
    frame.pieFrame:Show()
    return chartSize + CONTENT_PADDING * 2
end

local function CreateCharacterHeader(frame)
    local header = CreateFrame("Frame", nil, frame.content)
    for index = 1, #CHARACTER_FIELDS do
        local field = CHARACTER_FIELDS[index]
        header[field] = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        header[field]:SetJustifyH(field == "timeText" and "RIGHT" or "LEFT")
        header[field]:SetTextColor(1, 0.82, 0)
        SetNoWrap(header[field])
    end
    header.nameText:SetText(NAME or "Name")
    header.realmText:SetText(REALM or "Realm")
    header.classText:SetText(CLASS or "Class")
    header.raceText:SetText(RACE or "Race")
    header.factionText:SetText(FACTION or "Faction")
    header.timeText:SetText(TIME_PLAYED_TOTAL or "Time")
    header:Hide()
    frame.characterHeader = header
end

local function SetButtonActive(button, active)
    if not button then return end
    if active then
        button:Disable()
    else
        button:Enable()
    end
    local fontString = button.GetFontString and button:GetFontString()
    if fontString then
        if active then fontString:SetTextColor(1, 0.82, 0) else fontString:SetTextColor(1, 1, 1) end
    end
end

local function ResetContent(frame)
    if GameTooltip then GameTooltip:Hide() end
    for index = 1, #frame.distributionRows do ResetDistributionRow(frame.distributionRows[index]) end
    for index = 1, #frame.characterRows do ResetCharacterRow(frame.characterRows[index]) end
    for index = 1, #frame.pieCells do
        local cell = frame.pieCells[index]
        cell.entry = nil
        cell.hitTarget.entry = nil
        cell.hitTarget.kind = nil
        cell.hitTarget:Hide()
    end
    frame.pieFrame:Hide()
    frame.characterHeader:Hide()
    frame.emptyText:Hide()
end

local function RenderDistribution(frame, kind, chartMode)
    local entries, total = GetDistribution(kind)
    local width = ContentWidth(frame)
    local scale = frame.textScale or 1
    local rowHeight = math.floor(BASE_DISTRIBUTION_ROW_HEIGHT * scale + 0.5)

    if #entries == 0 then
        frame.emptyText:Show()
        frame.content:SetHeight(math.max(1, frame.scrollFrame:GetHeight()))
        frame.scrollFrame:SetVerticalScroll(0)
        return
    end

    local topOffset = CONTENT_PADDING
    if chartMode == "pie" then
        topOffset = LayoutPie(frame, entries, total, scale)
    end

    local topTime = entries[1].time > 0 and entries[1].time or 1
    for index = 1, #entries do
        local entry = entries[index]
        local row = AcquireDistributionRow(frame, index)
        local color = GroupColor(kind, entry.key)

        row.entry = entry
        row.kind = kind
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -topOffset - (index - 1) * rowHeight)
        StyleDistributionRow(row, width, scale, chartMode == "pie")
        row.labelText:SetText(GroupLabel(kind, entry))
        row.labelText:SetTextColor(color.r or 1, color.g or 1, color.b or 1)
        row.valueText:SetText(DistributionValue(entry.time, total))
        SolidColor(row.swatch, color.r or 1, color.g or 1, color.b or 1, 1)
        row.bar:SetValue(entry.time / topTime)
        row.bar:SetStatusBarColor(color.r or 1, color.g or 1, color.b or 1)
        row:Show()
    end

    frame.content:SetHeight(math.max(1, topOffset + #entries * rowHeight + CONTENT_PADDING))
end

local function RenderCharacters(frame)
    local characters = GetAllCharacters()
    local width = ContentWidth(frame)
    local scale = frame.textScale or 1
    local rowHeight = math.floor(BASE_CHARACTER_ROW_HEIGHT * scale + 0.5)
    local headerHeight = math.floor(22 * scale + 0.5)

    if #characters == 0 then
        frame.emptyText:Show()
        frame.content:SetHeight(math.max(1, frame.scrollFrame:GetHeight()))
        frame.scrollFrame:SetVerticalScroll(0)
        return
    end

    frame.characterHeader:ClearAllPoints()
    frame.characterHeader:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -CONTENT_PADDING)
    frame.characterHeader:SetSize(width, headerHeight)
    StyleCharacterColumns(frame.characterHeader, width, scale, true)
    frame.characterHeader:Show()

    for index = 1, #characters do
        local character = characters[index]
        local row = AcquireCharacterRow(frame, index)
        local color = CharacterColor(character.class)

        row.character = character
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0,
            -CONTENT_PADDING - headerHeight - (index - 1) * rowHeight)
        row:SetHeight(rowHeight)
        StyleCharacterColumns(row, width, scale, false)
        row.deleteButton:SetHeight(math.max(18, rowHeight - math.floor(5 * scale + 0.5)))

        row.nameText:SetText(character.name or character.key)
        row.nameText:SetTextColor(color.r or 1, color.g or 1, color.b or 1)
        row.realmText:SetText(character.realm or "")
        row.classText:SetText(CharacterClassName(character.class))
        row.classText:SetTextColor(color.r or 1, color.g or 1, color.b or 1)
        row.raceText:SetText(CharacterRaceName(character))
        row.factionText:SetText(CharacterFactionName(character))
        row.timeText:SetText(FormatDetailedTime(character.time))
        row:Show()
    end

    frame.content:SetHeight(math.max(1,
        CONTENT_PADDING * 2 + headerHeight + #characters * rowHeight))
end

local function UpdateFooter(frame)
    local total = GetAccountTotal()
    local count = GetCharacterCount()
    local tracked = string.format(L["TRACKED_COUNT"] or "%d characters tracked", count)
    frame.footerText:SetText(string.format("%s%s  |cff888888- |r%s",
        L["TOTAL"] or "Total: ", FormatTotalTime(total), tracked))
end

local function ViewportBounds()
    local width = UIParent and UIParent.GetWidth and UIParent:GetWidth() or MAX_WIDTH
    local height = UIParent and UIParent.GetHeight and UIParent:GetHeight() or MAX_HEIGHT
    return math.max(MIN_WIDTH, width - 24), math.max(MIN_HEIGHT, height - 24)
end

local function ApplyResizeBounds(frame)
    local viewportWidth, viewportHeight = ViewportBounds()
    local maxWidth = math.min(MAX_WIDTH, viewportWidth)
    local maxHeight = math.min(MAX_HEIGHT, viewportHeight)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, maxWidth, maxHeight)
    elseif frame.SetMinResize and frame.SetMaxResize then
        frame:SetMinResize(MIN_WIDTH, MIN_HEIGHT)
        frame:SetMaxResize(maxWidth, maxHeight)
    end
    return maxWidth, maxHeight
end

local function RestoreGeometry(frame)
    local settings = PopupSettings()
    local maxWidth, maxHeight = ApplyResizeBounds(frame)
    local width = Clamp(settings.width or 640, MIN_WIDTH, maxWidth)
    local height = Clamp(settings.height or 380, MIN_HEIGHT, maxHeight)

    frame._restoringGeometry = true
    frame:SetSize(width, height)
    frame:ClearAllPoints()
    frame:SetPoint(settings.point or "CENTER", UIParent, settings.point or "CENTER",
        tonumber(settings.x) or 0, tonumber(settings.y) or 0)
    frame._restoringGeometry = nil
end

local function PersistSize(frame)
    SetPopupSetting("width", frame:GetWidth())
    SetPopupSetting("height", frame:GetHeight())
end

local function PersistPosition(frame)
    local centerX, centerY = frame:GetCenter()
    local parentX, parentY = UIParent and UIParent:GetCenter()
    if centerX and centerY and parentX and parentY then
        local x, y = centerX - parentX, centerY - parentY
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
        SetPopupSetting("point", "CENTER")
        SetPopupSetting("x", x)
        SetPopupSetting("y", y)
        return
    end

    local point, _, _, x, y = frame:GetPoint(1)
    SetPopupSetting("point", point or "CENTER")
    SetPopupSetting("x", x or 0)
    SetPopupSetting("y", y or 0)
end

local function ClampWindow(frame, persist)
    local centerX, centerY = frame:GetCenter()
    local parentX, parentY = UIParent and UIParent:GetCenter()
    local parentWidth = UIParent and UIParent:GetWidth()
    local parentHeight = UIParent and UIParent:GetHeight()
    if not centerX or not centerY or not parentX or not parentY or not parentWidth or not parentHeight then return end

    local halfWidth = math.min(frame:GetWidth() / 2, parentWidth / 2 - 4)
    local halfHeight = math.min(frame:GetHeight() / 2, parentHeight / 2 - 4)
    local clampedX = Clamp(centerX, parentX - parentWidth / 2 + halfWidth, parentX + parentWidth / 2 - halfWidth)
    local clampedY = Clamp(centerY, parentY - parentHeight / 2 + halfHeight, parentY + parentHeight / 2 - halfHeight)
    if math.abs(clampedX - centerX) > 0.5 or math.abs(clampedY - centerY) > 0.5 then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", clampedX - parentX, clampedY - parentY)
        if persist then PersistPosition(frame) end
    end
end

local function AttachSettings(frame)
    if AP.Settings and type(AP.Settings.Attach) == "function" then
        AP.Settings:Attach(frame)
    end
end

function MainWindow:Refresh()
    local frame = self.frame
    if not frame or frame._refreshing then return end
    frame._refreshing = true

    local settings = PopupSettings()
    local activeTab = settings.activeTab
    if activeTab ~= "class" and activeTab ~= "characters" and activeTab ~= "race" and activeTab ~= "faction" then
        activeTab = "class"
    end
    local chartMode = settings.chartMode == "pie" and "pie" or "bar"
    local width = ContentWidth(frame)
    frame.content:SetWidth(width)

    if frame.renderedTab ~= activeTab or frame.renderedChartMode ~= chartMode then
        frame.scrollFrame:SetVerticalScroll(0)
    end
    frame.renderedTab = activeTab
    frame.renderedChartMode = chartMode

    ResetContent(frame)
    for index = 1, #TAB_ORDER do
        local tab = TAB_ORDER[index]
        SetButtonActive(frame.tabs[tab], activeTab == tab)
    end

    local distributionTab = activeTab ~= "characters"
    if distributionTab then
        frame.barButton:Show()
        frame.pieButton:Show()
        SetButtonActive(frame.barButton, chartMode == "bar")
        SetButtonActive(frame.pieButton, chartMode == "pie")
        RenderDistribution(frame, activeTab, chartMode)
    else
        frame.barButton:Hide()
        frame.pieButton:Hide()
        RenderCharacters(frame)
    end

    frame.formatCheckbox:SetChecked(settings.useYears == true)
    UpdateFooter(frame)
    UpdateScrollRange(frame)
    frame._refreshing = nil
end

function MainWindow:ApplySettings()
    local frame = self.frame
    if not frame then return end
    local settings = PopupSettings()
    local scale = Clamp(settings.textScale or 1, 1, 2)
    frame.textScale = scale

    SetFontSize(frame.title, 16 * scale)
    SetFontSize(frame.footerText, 12 * scale)
    SetFontSize(frame.formatCheckbox.text, 11 * scale)
    SetFontSize(frame.emptyText, 13 * scale)

    local frameWidth = frame:GetWidth() or 640
    local modeWidth = math.floor(54 + 14 * (scale - 1) + 0.5)
    local toolbarWidth = math.max(320, frameWidth - 42)
    local tabArea = toolbarWidth - modeWidth * 2 - 20
    local tabWidth = math.max(54, math.floor(tabArea / #TAB_ORDER))
    local tabHeight = math.floor(22 * scale + 0.5)
    local tabTop = math.floor(40 + 18 * (scale - 1) + 0.5)
    local x = 16

    for index = 1, #TAB_ORDER do
        local tabButton = frame.tabs[TAB_ORDER[index]]
        tabButton:ClearAllPoints()
        tabButton:SetPoint("TOPLEFT", frame, "TOPLEFT", x, -tabTop)
        tabButton:SetSize(tabWidth, tabHeight)
        SetFontSize(tabButton:GetFontString(), 11 * scale)
        x = x + tabWidth + 2
    end

    frame.pieButton:SetSize(modeWidth, tabHeight)
    frame.barButton:SetSize(modeWidth, tabHeight)
    frame.pieButton:ClearAllPoints()
    frame.pieButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -tabTop)
    frame.barButton:ClearAllPoints()
    frame.barButton:SetPoint("RIGHT", frame.pieButton, "LEFT", -3, 0)
    SetFontSize(frame.pieButton:GetFontString(), 10 * scale)
    SetFontSize(frame.barButton:GetFontString(), 10 * scale)

    local toolbarBottom = tabTop + tabHeight + 7
    local footerY = math.floor(17 + 5 * (scale - 1) + 0.5)
    local footerReserve = math.floor(48 + 20 * (scale - 1) + 0.5)
    local checkboxSize = math.floor(24 + 4 * (scale - 1) + 0.5)

    frame.footerText:ClearAllPoints()
    frame.footerText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 17, footerY)
    frame.footerText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -150, footerY)
    frame.formatCheckbox:ClearAllPoints()
    frame.formatCheckbox:SetSize(checkboxSize, checkboxSize)
    frame.formatCheckbox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -25, footerY - 3)

    frame.scrollFrame:ClearAllPoints()
    frame.scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -toolbarBottom)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -31, footerReserve)

    local contentWidth = ContentWidth(frame)
    frame.content:SetWidth(contentWidth)
    for index = 1, #frame.distributionRows do
        StyleDistributionRow(frame.distributionRows[index], contentWidth, scale,
            PopupSettings().chartMode == "pie")
    end
    for index = 1, #frame.characterRows do
        local row = frame.characterRows[index]
        row:SetHeight(math.floor(BASE_CHARACTER_ROW_HEIGHT * scale + 0.5))
        StyleCharacterColumns(row, contentWidth, scale, false)
    end
    StyleCharacterColumns(frame.characterHeader, contentWidth, scale, true)

    self:Refresh()
    if AP.CharacterPanel and AP.CharacterPanel.ApplySettings then
        AP.CharacterPanel:ApplySettings()
        if AP.CharacterPanel.frame and AP.CharacterPanel.frame:IsShown() and AP.CharacterPanel.Refresh then
            AP.CharacterPanel:Refresh()
        end
    end
end

function MainWindow:Create()
    if self.frame then return self.frame end

    local template = BackdropTemplateMixin and "BackdropTemplate" or nil
    local frame = CreateFrame("Frame", WINDOW_NAME, UIParent, template)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(100)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 28,
            insets = { left = 10, right = 10, top = 10, bottom = 10 },
        })
        frame:SetBackdropColor(0.02, 0.02, 0.02, 0.94)
    end

    frame.distributionRows = {}
    frame.characterRows = {}
    frame.pieCells = {}
    frame.tabs = {}

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 48, -14)
    frame.title:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -48, -14)
    frame.title:SetJustifyH("CENTER")
    frame.title:SetText(L["ADDON_NAME"] or "Account Played")
    SetNoWrap(frame.title)

    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, -7)
    frame.closeButton:SetScript("OnClick", function()
        PlaySoundKey("IG_MAINMENU_CLOSE")
        MainWindow:Hide()
    end)

    for index = 1, #TAB_ORDER do
        local tab = TAB_ORDER[index]
        local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        button:SetText(TAB_LABELS[tab])
        button:SetScript("OnClick", function()
            PlaySoundKey("IG_MAINMENU_OPTION_CHECKBOX_ON")
            SetPopupSetting("activeTab", tab)
        end)
        frame.tabs[tab] = button
    end

    frame.barButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.barButton:SetText(L["CHART_BAR"] or "Bars")
    frame.barButton:SetScript("OnClick", function()
        PlaySoundKey("IG_MAINMENU_OPTION_CHECKBOX_ON")
        SetPopupSetting("chartMode", "bar")
    end)

    frame.pieButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.pieButton:SetText(L["CHART_PIE"] or "Pie")
    frame.pieButton:SetScript("OnClick", function()
        PlaySoundKey("IG_MAINMENU_OPTION_CHECKBOX_ON")
        SetPopupSetting("chartMode", "pie")
    end)

    frame.scrollFrame = CreateFrame("ScrollFrame", WINDOW_NAME .. "ScrollFrame", frame, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:EnableMouseWheel(true)
    frame.content = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.content:SetSize(1, 1)
    frame.scrollFrame:SetScrollChild(frame.content)
    frame.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local rowHeight = math.floor(BASE_DISTRIBUTION_ROW_HEIGHT * (frame.textScale or 1) + 0.5)
        local current = self:GetVerticalScroll()
        local range = self:GetVerticalScrollRange()
        self:SetVerticalScroll(math.max(0, math.min(range, current - delta * rowHeight * 2)))
    end)

    frame.emptyText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontDisableLarge")
    frame.emptyText:SetPoint("TOP", frame.content, "TOP", 0, -24)
    frame.emptyText:SetText(L["NO_DATA"] or "No data yet")
    frame.emptyText:Hide()

    frame.pieFrame = CreateFrame("Frame", nil, frame.content)
    frame.pieFrame:Hide()
    CreateCharacterHeader(frame)

    frame.footerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.footerText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 17, 19)
    frame.footerText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -150, 19)
    frame.footerText:SetJustifyH("LEFT")
    frame.footerText:SetTextColor(1, 0.82, 0)
    SetNoWrap(frame.footerText)
    frame.totalRow = frame.footerText

    frame.formatCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.formatCheckbox:SetSize(24, 24)
    frame.formatCheckbox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -25, 15)
    frame.formatCheckbox.text = frame.formatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.formatCheckbox.text:SetPoint("RIGHT", frame.formatCheckbox, "LEFT", -3, 0)
    frame.formatCheckbox.text:SetText(L["USE_YEARS_LABEL"] or "Years / days")
    SetNoWrap(frame.formatCheckbox.text)
    frame.formatCheckbox:SetScript("OnClick", function(self)
        PlaySoundKey(self:GetChecked() and "IG_MAINMENU_OPTION_CHECKBOX_ON" or "IG_MAINMENU_OPTION_CHECKBOX_OFF")
        SetPopupSetting("useYears", not not self:GetChecked())
    end)
    frame.formatCheckbox:SetScript("OnEnter", function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(L["TIME_FORMAT_TITLE"] or "Time format", 1, 1, 1)
        GameTooltip:AddLine(L["TIME_FORMAT_YEARS"] or "Checked: years and days", 0.8, 0.8, 0.8)
        GameTooltip:AddLine(L["TIME_FORMAT_HOURS"] or "Unchecked: hours and minutes", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    frame.formatCheckbox:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)

    frame.resizeButton = CreateFrame("Button", nil, frame)
    frame.resizeButton:SetSize(18, 18)
    frame.resizeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)
    frame.resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    frame.resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    frame.resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    frame.resizeButton:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            frame._sizing = true
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)
    frame.resizeButton:SetScript("OnMouseUp", function()
        if not frame._sizing then return end
        frame:StopMovingOrSizing()
        frame._sizing = nil
        ClampWindow(frame, false)
        PersistSize(frame)
        PersistPosition(frame)
    end)

    frame:SetScript("OnDragStart", function(self)
        if not self._sizing then
            self._moving = true
            self:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self._moving = nil
        ClampWindow(self, false)
        PersistPosition(self)
    end)
    frame:SetScript("OnSizeChanged", function(self)
        if self._constructed and not self._restoringGeometry then
            MainWindow:ApplySettings()
        end
    end)
    frame:SetScript("OnShow", function(self)
        if AP.Data and AP.Data.RequestCurrentCharacterPlayedTime then
            AP.Data:RequestCurrentCharacterPlayedTime()
        end
        AttachSettings(self)
        MainWindow:ApplySettings()
        if AP.After then
            AP:After(0, function()
                if self:IsShown() then ClampWindow(self, true) end
            end)
        else
            ClampWindow(self, true)
        end
    end)
    frame:SetScript("OnHide", function(self)
        if self._sizing then
            self:StopMovingOrSizing()
            self._sizing = nil
            ClampWindow(self, false)
            PersistSize(self)
            PersistPosition(self)
        elseif self._moving then
            self:StopMovingOrSizing()
            self._moving = nil
            ClampWindow(self, false)
            PersistPosition(self)
        end
        if AP.CharacterPanel and AP.CharacterPanel.Hide then AP.CharacterPanel:Hide() end
        if GameTooltip then GameTooltip:Hide() end
    end)

    RestoreGeometry(frame)
    frame:Hide()
    frame._constructed = true
    self.frame = frame
    AP.popupFrame = frame
    AP.popupRows = frame.distributionRows
    AddSpecialFrame(WINDOW_NAME)
    self:ApplySettings()
    return frame
end

function MainWindow:Show()
    local frame = self:Create()
    if frame:IsShown() then
        if AP.Data and AP.Data.RequestCurrentCharacterPlayedTime then
            AP.Data:RequestCurrentCharacterPlayedTime()
        end
        self:ApplySettings()
    else
        frame:Show()
    end
    return frame
end

function MainWindow:Hide()
    if self.frame then self.frame:Hide() end
end

function MainWindow:Toggle()
    if self.frame and self.frame:IsShown() then
        PlaySoundKey("IG_MAINMENU_CLOSE")
        self:Hide()
        return false
    end
    PlaySoundKey("IG_MAINMENU_OPEN")
    self:Show()
    return true
end

AP.ToggleClassWindow = function()
    return MainWindow:Toggle()
end

if AP.RegisterMessage then
    AP:RegisterMessage("CHARACTER_UPDATED", function()
        if MainWindow.frame then MainWindow:Refresh() end
    end)

    AP:RegisterMessage("CHARACTER_REMOVED", function()
        if MainWindow.frame then MainWindow:Refresh() end
    end)

    AP:RegisterMessage("SETTINGS_CHANGED", function(scope, key)
        if not MainWindow.frame then return end
        if scope == "popup" and key == nil then RestoreGeometry(MainWindow.frame) end
        MainWindow:ApplySettings()
    end)
end
