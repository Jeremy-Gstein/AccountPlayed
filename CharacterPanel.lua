-- Account Played
-- Lazy, scrollable character management panel used by distribution rows.

local _, AP = ...
local L = AP.L or {}

local CharacterPanel = AP.CharacterPanel or {}
AP.CharacterPanel = CharacterPanel
AP.modules = AP.modules or {}
AP.modules.CharacterPanel = CharacterPanel

local PANEL_NAME = "AccountPlayedCharacterPanel"
local PANEL_WIDTH = 440
local PANEL_HEIGHT = 340
local HEADER_HEIGHT = 42
local FOOTER_HEIGHT = 14
local BASE_ROW_HEIGHT = 24
local CONTENT_PADDING = 6

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
    if path then
        fontString:SetFont(path, size, flags or "")
    end
end

local function PlayClick()
    local sound = SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
    if AP.PlaySound then AP:PlaySound(sound) end
end

local function PopupSettings()
    if AP.Data and AP.Data.GetPopupSettings then
        return AP.Data:GetPopupSettings()
    end
    return {}
end

local function CharactersFor(kind, key)
    if AP.Data and AP.Data.GetAllCharacters then
        return AP.Data:GetAllCharacters(kind, key)
    end
    return {}
end

local function CharacterTime(seconds)
    local settings = PopupSettings()
    if AP.Format and AP.Format.DetailedTime then
        return AP.Format:DetailedTime(seconds, settings.useYears)
    end
    return tostring(seconds or 0)
end

local function GroupLabel(kind, key, entry)
    entry = entry or { key = key }
    if AP.Format and AP.Format.GroupLabel then
        return AP.Format:GroupLabel(kind, entry)
    end
    return tostring(key or L["UNKNOWN"] or "Unknown")
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

local function ScrollBarFor(scrollFrame)
    if not scrollFrame then return nil end
    if scrollFrame.ScrollBar then return scrollFrame.ScrollBar end
    if scrollFrame.scrollBar then return scrollFrame.scrollBar end
    local name = scrollFrame.GetName and scrollFrame:GetName()
    return name and _G[name .. "ScrollBar"] or nil
end

local function UpdateScrollRange(panel)
    local scrollFrame = panel and panel.scrollFrame
    if not scrollFrame then return end
    if scrollFrame.UpdateScrollChildRect then scrollFrame:UpdateScrollChildRect() end

    local range = scrollFrame.GetVerticalScrollRange and scrollFrame:GetVerticalScrollRange() or 0
    local scrollBar = ScrollBarFor(scrollFrame)
    if range > 0 then
        if scrollBar then scrollBar:Show() end
    else
        if scrollFrame.SetVerticalScroll then scrollFrame:SetVerticalScroll(0) end
        if scrollBar then scrollBar:Hide() end
    end
end

local function LayoutColumns(row, availableWidth, scale)
    if not row then return end
    availableWidth = math.max(180, availableWidth or PANEL_WIDTH - 42)

    local gap = math.floor(4 + 2 * (scale - 1) + 0.5)
    local deleteWidth = math.min(math.floor(62 + 20 * (scale - 1) + 0.5), math.floor(availableWidth * 0.22))
    local timeWidth = math.min(math.floor(94 + 30 * (scale - 1) + 0.5), math.floor(availableWidth * 0.30))
    local remaining = math.max(80, availableWidth - deleteWidth - timeWidth - gap * 3 - 4)
    local nameWidth = math.floor(remaining * 0.54)
    local realmWidth = remaining - nameWidth

    row.nameText:ClearAllPoints()
    row.nameText:SetPoint("LEFT", row, "LEFT", 2, 0)
    row.nameText:SetWidth(nameWidth)

    row.realmText:ClearAllPoints()
    row.realmText:SetPoint("LEFT", row.nameText, "RIGHT", gap, 0)
    row.realmText:SetWidth(realmWidth)

    row.timeText:ClearAllPoints()
    row.timeText:SetPoint("LEFT", row.realmText, "RIGHT", gap, 0)
    row.timeText:SetWidth(timeWidth)

    row.deleteButton:ClearAllPoints()
    row.deleteButton:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    row.deleteButton:SetWidth(deleteWidth)
end

local function ResetRow(row)
    row.character = nil
    row.nameText:SetText("")
    row.realmText:SetText("")
    row.timeText:SetText("")
    row:Hide()
end

local function ConfirmDeleteFallback(key)
    if type(StaticPopupDialogs) ~= "table" or not StaticPopup_Show then
        if AP.Print then
            AP:Print(L["CMD_DELETE_CONFIRM"] or "Delete confirmation is unavailable.")
        end
        return false
    end

    if not StaticPopupDialogs.ACCOUNTPLAYED_UI_CONFIRM_DELETE then
        StaticPopupDialogs.ACCOUNTPLAYED_UI_CONFIRM_DELETE = {
            text = "%s",
            button1 = DELETE or "Delete",
            button2 = CANCEL or "Cancel",
            OnAccept = function(_, data)
                if data and AP.Data and AP.Data.DeleteCharacter then
                    AP.Data:DeleteCharacter(data)
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
    end

    local question = string.format(
        L["CMD_DELETE_CONFIRM"] or "Are you sure you want to remove %s from Account Played?",
        key)
    StaticPopup_Show("ACCOUNTPLAYED_UI_CONFIRM_DELETE", question, nil, key)
    return true
end

function CharacterPanel:ConfirmDelete(key)
    if type(key) ~= "string" or key == "" then return false end
    if AP.Commands and type(AP.Commands.ConfirmDelete) == "function" then
        AP.Commands:ConfirmDelete(key)
        return true
    end
    return ConfirmDeleteFallback(key)
end

local function CreateRow(panel)
    local row = CreateFrame("Frame", nil, panel.content)
    row:EnableMouse(true)

    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints()
    SolidColor(row.background, 1, 1, 1, 0.035)

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.nameText:SetJustifyH("LEFT")
    SetNoWrap(row.nameText)

    row.realmText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.realmText:SetJustifyH("LEFT")
    row.realmText:SetTextColor(0.68, 0.68, 0.68)
    SetNoWrap(row.realmText)

    row.timeText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.timeText:SetJustifyH("RIGHT")
    row.timeText:SetTextColor(0.82, 0.82, 0.82)
    SetNoWrap(row.timeText)

    row.deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.deleteButton:SetText(DELETE or "Delete")
    row.deleteButton:SetScript("OnClick", function()
        if row.character then
            PlayClick()
            CharacterPanel:ConfirmDelete(row.character.key)
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
        SolidColor(row.background, 1, 1, 1, 0.035)
        if GameTooltip then GameTooltip:Hide() end
    end)

    row:Hide()
    panel.rows[#panel.rows + 1] = row
    return row
end

local function AcquireRow(panel, index)
    while #panel.rows < index do
        CreateRow(panel)
    end
    return panel.rows[index]
end

function CharacterPanel:Create()
    if self.frame then return self.frame end

    local template = BackdropTemplateMixin and "BackdropTemplate" or nil
    local panel = CreateFrame("Frame", PANEL_NAME, UIParent, template)
    panel:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    panel:SetFrameStrata("DIALOG")
    panel:SetFrameLevel(120)
    panel:SetClampedToScreen(true)
    panel:EnableMouse(true)

    if panel.SetBackdrop then
        panel:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 24,
            insets = { left = 8, right = 8, top = 8, bottom = 8 },
        })
        panel:SetBackdropColor(0.04, 0.04, 0.04, 0.96)
    end

    panel.rows = {}

    panel.titleText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.titleText:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -12)
    panel.titleText:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -34, -12)
    panel.titleText:SetJustifyH("LEFT")
    SetNoWrap(panel.titleText)

    panel.closeButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    panel.closeButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -4, -4)
    panel.closeButton:SetScript("OnClick", function() CharacterPanel:Hide() end)

    panel.divider = panel:CreateTexture(nil, "ARTWORK")
    panel.divider:SetHeight(1)
    panel.divider:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -HEADER_HEIGHT + 7)
    panel.divider:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -HEADER_HEIGHT + 7)
    SolidColor(panel.divider, 0.4, 0.4, 0.4, 0.75)

    panel.scrollFrame = CreateFrame("ScrollFrame", PANEL_NAME .. "ScrollFrame", panel, "UIPanelScrollFrameTemplate")
    panel.scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -HEADER_HEIGHT)
    panel.scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, FOOTER_HEIGHT)
    panel.scrollFrame:EnableMouseWheel(true)

    panel.content = CreateFrame("Frame", nil, panel.scrollFrame)
    panel.content:SetSize(1, 1)
    panel.scrollFrame:SetScrollChild(panel.content)

    panel.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local rowHeight = panel.rowHeight or BASE_ROW_HEIGHT
        local current = self:GetVerticalScroll()
        local range = self:GetVerticalScrollRange()
        self:SetVerticalScroll(math.max(0, math.min(range, current - delta * rowHeight * 2)))
    end)

    panel.emptyText = panel.content:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    panel.emptyText:SetPoint("TOP", panel.content, "TOP", 0, -18)
    panel.emptyText:SetText(L["NO_DATA"] or "No data yet")
    panel.emptyText:Hide()

    panel:SetScript("OnHide", function()
        if GameTooltip and GameTooltip.GetOwner and GameTooltip:GetOwner() then
            GameTooltip:Hide()
        end
        CharacterPanel.kind = nil
        CharacterPanel.key = nil
        CharacterPanel.entry = nil
        CharacterPanel.anchor = nil
    end)

    panel:Hide()
    self.frame = panel
    AP.charPanel = panel
    AddSpecialFrame(PANEL_NAME)
    return panel
end

function CharacterPanel:ApplySettings()
    local panel = self.frame
    if not panel then return end

    local settings = PopupSettings()
    local scale = tonumber(settings.textScale) or 1
    scale = math.max(1, math.min(2, scale))
    panel.textScale = scale
    panel.rowHeight = math.floor(BASE_ROW_HEIGHT * scale + 0.5)

    SetFontSize(panel.titleText, 14 * scale)
    SetFontSize(panel.emptyText, 12 * scale)

    local contentWidth = math.max(1, panel.scrollFrame:GetWidth())
    panel.content:SetWidth(contentWidth)

    for index = 1, #panel.rows do
        local row = panel.rows[index]
        row:SetHeight(panel.rowHeight)
        SetFontSize(row.nameText, 11 * scale)
        SetFontSize(row.realmText, 11 * scale)
        SetFontSize(row.timeText, 11 * scale)
        local buttonFont = row.deleteButton.GetFontString and row.deleteButton:GetFontString()
        SetFontSize(buttonFont, 10 * scale)
        row.deleteButton:SetHeight(math.max(18, panel.rowHeight - math.floor(4 * scale)))
        LayoutColumns(row, contentWidth, scale)
    end
end

function CharacterPanel:Refresh()
    local panel = self.frame
    if not panel or not panel:IsShown() or not self.kind or not self.key then return end

    local characters = CharactersFor(self.kind, self.key)
    -- Grow the pool before applying the scale so rows created for this refresh
    -- receive the same font, button, height, and column layout as older rows.
    for index = #panel.rows + 1, #characters do
        AcquireRow(panel, index)
    end
    self:ApplySettings()
    local scale = panel.textScale or 1
    local rowHeight = panel.rowHeight or BASE_ROW_HEIGHT
    local contentWidth = math.max(1, panel.scrollFrame:GetWidth())

    panel.titleText:SetText(GroupLabel(self.kind, self.key, self.entry))
    local titleColor = GroupColor(self.kind, self.key)
    panel.titleText:SetTextColor(titleColor.r or 1, titleColor.g or 1, titleColor.b or 1)

    for index = 1, #panel.rows do
        ResetRow(panel.rows[index])
    end

    if #characters == 0 then
        panel.emptyText:Show()
        panel.content:SetHeight(math.max(1, panel.scrollFrame:GetHeight()))
        panel.scrollFrame:SetVerticalScroll(0)
        UpdateScrollRange(panel)
        return
    end

    panel.emptyText:Hide()
    for index = 1, #characters do
        local character = characters[index]
        local row = AcquireRow(panel, index)
        local color = CharacterColor(character.class)

        row.character = character
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -CONTENT_PADDING - (index - 1) * rowHeight)
        row:SetWidth(contentWidth)
        row:SetHeight(rowHeight)
        LayoutColumns(row, contentWidth, scale)

        row.nameText:SetText(character.name or character.key)
        row.nameText:SetTextColor(color.r or 1, color.g or 1, color.b or 1)
        row.realmText:SetText(character.realm or "")
        row.timeText:SetText(CharacterTime(character.time))
        row:Show()
    end

    panel.content:SetHeight(math.max(1, CONTENT_PADDING * 2 + #characters * rowHeight))
    UpdateScrollRange(panel)
end

function CharacterPanel:ShowGroup(kind, key, entry, anchor)
    if kind ~= "class" and kind ~= "race" and kind ~= "faction" then return false end
    if type(key) ~= "string" or key == "" then return false end

    local panel = self:Create()
    self.kind = kind
    self.key = key
    self.entry = entry or { key = key }
    self.anchor = anchor

    panel:ClearAllPoints()
    if anchor then
        panel:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 6, 0)
    elseif AP.popupFrame and AP.popupFrame:IsShown() then
        panel:SetPoint("TOPLEFT", AP.popupFrame, "TOPRIGHT", 6, 0)
    else
        panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end

    panel:Show()
    self:Refresh()
    return true
end

function CharacterPanel:Toggle(kind, key, entry, anchor)
    if self.frame and self.frame:IsShown() and self.kind == kind and self.key == key then
        self:Hide()
        return false
    end
    PlayClick()
    return self:ShowGroup(kind, key, entry, anchor)
end

function CharacterPanel:Hide()
    if self.frame then self.frame:Hide() end
end

if AP.RegisterMessage then
    AP:RegisterMessage("CHARACTER_UPDATED", function()
        if CharacterPanel.frame and CharacterPanel.frame:IsShown() then
            CharacterPanel:Refresh()
        end
    end)

    AP:RegisterMessage("CHARACTER_REMOVED", function()
        if CharacterPanel.frame and CharacterPanel.frame:IsShown() then
            CharacterPanel:Refresh()
        end
    end)

    AP:RegisterMessage("SETTINGS_CHANGED", function(scope)
        if scope == "popup" and CharacterPanel.frame and CharacterPanel.frame:IsShown() then
            CharacterPanel:Refresh()
        end
    end)
end
