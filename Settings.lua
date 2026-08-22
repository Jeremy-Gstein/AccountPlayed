-- Account Played
-- Popup settings controller. The panel is created only when requested.

local _, AP = ...
local L = AP.L

local Settings = {}
AP.Settings = Settings
AP.modules.Settings = Settings

local panel
local attachedWindow

local function PopupSettings()
    return AP.Data:GetPopupSettings()
end

local function SetTooltip(owner, title, text)
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    if title then GameTooltip:AddLine(title, 1, 1, 1) end
    if text then GameTooltip:AddLine(text, 0.8, 0.8, 0.8, true) end
    GameTooltip:Show()
end

function Settings:SetValueMode(mode)
    AP.Data:SetPopupSetting("valueMode", mode)
end

function Settings:Sync()
    if not panel then return end
    local settings = PopupSettings()

    panel.syncing = true
    panel.scaleSlider:SetValue(settings.textScale)
    panel.scaleValue:SetText(string.format("%d%%", math.floor(settings.textScale * 100 + 0.5)))
    panel.minimapCheck:SetChecked(not AP.Data:GetMinimapSettings().hidden)
    panel.timeOnlyCheck:SetChecked(settings.valueMode == "days")
    panel.percentOnlyCheck:SetChecked(settings.valueMode == "percent")
    panel.syncing = false
end

function Settings:CreatePanel(window)
    if panel then return panel end
    window = window or attachedWindow or UIParent

    panel = CreateFrame("Frame", "AccountPlayedSettingsPanel", UIParent, "BackdropTemplate")
    panel:SetSize(244, 190)
    panel:SetFrameStrata("DIALOG")
    panel:SetFrameLevel(160)
    panel:SetClampedToScreen(true)
    panel:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    panel:SetBackdropColor(0.06, 0.06, 0.07, 0.97)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.title:SetPoint("TOPLEFT", 14, -12)
    panel.title:SetText(SETTINGS or L["ADDON_NAME"] or "Account Played")
    panel.title:SetTextColor(1, 0.82, 0)

    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    close:SetSize(20, 20)
    close:SetPoint("TOPRIGHT", -2, -2)
    close:SetScript("OnClick", function() panel:Hide() end)

    local divider = panel:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", 10, -30)
    divider:SetPoint("TOPRIGHT", -10, -30)
    divider:SetColorTexture(1, 1, 1, 0.14)

    local scaleLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    scaleLabel:SetPoint("TOPLEFT", 14, -40)
    scaleLabel:SetText(TEXT_SCALE or L["SETTINGS_TEXT_SCALE"] or "Text Scale")

    panel.scaleValue = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    panel.scaleValue:SetPoint("TOPRIGHT", -14, -40)
    panel.scaleValue:SetTextColor(1, 1, 1)

    panel.scaleSlider = CreateFrame("Slider", "AccountPlayedTextScaleSlider", panel, "OptionsSliderTemplate")
    panel.scaleSlider:SetPoint("TOPLEFT", 18, -58)
    panel.scaleSlider:SetPoint("TOPRIGHT", -18, -58)
    panel.scaleSlider:SetHeight(16)
    panel.scaleSlider:SetMinMaxValues(1, 2)
    panel.scaleSlider:SetValueStep(0.05)
    panel.scaleSlider:SetObeyStepOnDrag(true)

    local low = _G[panel.scaleSlider:GetName() .. "Low"]
    local high = _G[panel.scaleSlider:GetName() .. "High"]
    local text = _G[panel.scaleSlider:GetName() .. "Text"]
    if low then low:SetText("100%") end
    if high then high:SetText("200%") end
    if text then text:SetText("") end

    panel.scaleSlider:SetScript("OnValueChanged", function(self, value)
        panel.scaleValue:SetText(string.format("%d%%", math.floor(value * 100 + 0.5)))
        if panel.syncing then return end
        AP.Data:SetPopupSetting("textScale", value)
        AP:PlaySound(SOUNDKIT and SOUNDKIT.U_CHAT_SCROLL_BUTTON)
    end)
    panel.scaleSlider:SetScript("OnEnter", function(self)
        SetTooltip(self, TEXT_SCALE or L["SETTINGS_TEXT_SCALE"],
            L["SETTINGS_SCALE_TIP"] or "Adjust the size of text in the character list.")
    end)
    panel.scaleSlider:SetScript("OnLeave", function() GameTooltip:Hide() end)

    panel.minimapCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    panel.minimapCheck:SetSize(24, 24)
    panel.minimapCheck:SetPoint("TOPLEFT", 10, -91)
    panel.minimapCheck.label = panel.minimapCheck:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    panel.minimapCheck.label:SetPoint("LEFT", panel.minimapCheck, "RIGHT", 2, 0)
    panel.minimapCheck.label:SetText(MINIMAP_LABEL or L["TOOLTIP_TITLE"] or "Minimap button")
    panel.minimapCheck:SetScript("OnClick", function(self)
        if panel.syncing then return end
        AP.MinimapButton:SetVisible(self:GetChecked(), true)
        AP:PlaySound(SOUNDKIT and (self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
            or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF))
    end)

    panel.timeOnlyCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    panel.timeOnlyCheck:SetSize(24, 24)
    panel.timeOnlyCheck:SetPoint("TOPLEFT", 10, -119)
    panel.timeOnlyCheck.label = panel.timeOnlyCheck:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    panel.timeOnlyCheck.label:SetPoint("LEFT", panel.timeOnlyCheck, "RIGHT", 2, 0)
    panel.timeOnlyCheck.label:SetText(L["SETTINGS_DAYS_ONLY"] or "Time Only")
    panel.timeOnlyCheck:SetScript("OnClick", function(self)
        if panel.syncing then return end
        Settings:SetValueMode(self:GetChecked() and "days" or "both")
        AP:PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    panel.timeOnlyCheck:SetScript("OnEnter", function(self)
        SetTooltip(self, nil, L["SETTINGS_DAYS_ONLY_TIP"])
    end)
    panel.timeOnlyCheck:SetScript("OnLeave", function() GameTooltip:Hide() end)

    panel.percentOnlyCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    panel.percentOnlyCheck:SetSize(24, 24)
    panel.percentOnlyCheck:SetPoint("TOPLEFT", 126, -119)
    panel.percentOnlyCheck.label = panel.percentOnlyCheck:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    panel.percentOnlyCheck.label:SetPoint("LEFT", panel.percentOnlyCheck, "RIGHT", 2, 0)
    panel.percentOnlyCheck.label:SetText(L["SETTINGS_PERCENT_ONLY"] or "% Only")
    panel.percentOnlyCheck:SetScript("OnClick", function(self)
        if panel.syncing then return end
        Settings:SetValueMode(self:GetChecked() and "percent" or "both")
        AP:PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    panel.percentOnlyCheck:SetScript("OnEnter", function(self)
        SetTooltip(self, nil, L["SETTINGS_PERCENT_ONLY_TIP"])
    end)
    panel.percentOnlyCheck:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local reset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    reset:SetSize(128, 22)
    reset:SetPoint("BOTTOMLEFT", 12, 12)
    reset:SetText(RESET_TO_DEFAULT or L["SETTINGS_RESET"] or "Reset")
    reset:SetScript("OnClick", function()
        AP.Data:ResetPopupSettings()
        AP:PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    reset:SetScript("OnEnter", function(self)
        SetTooltip(self, nil, L["SETTINGS_RESET_TIP"] or "Restore all window settings to their defaults.")
    end)
    reset:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local okay = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    okay:SetSize(72, 22)
    okay:SetPoint("BOTTOMRIGHT", -12, 12)
    okay:SetText(OKAY or "Okay")
    okay:SetScript("OnClick", function()
        AP:PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_CLOSE)
        panel:Hide()
    end)

    table.insert(UISpecialFrames, "AccountPlayedSettingsPanel")
    panel:Hide()
    self:Sync()
    return panel
end

function Settings:Toggle(window)
    window = window or attachedWindow
    local current = self:CreatePanel(window)
    if current:IsShown() then
        AP:PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_CLOSE)
        current:Hide()
        return
    end

    self:Sync()
    current:ClearAllPoints()
    current:SetPoint("TOPLEFT", window or UIParent, "TOPLEFT", 4, -32)
    AP:PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPEN)
    current:Show()
end

function Settings:Attach(window)
    if not window or window.settingsGear then return end
    attachedWindow = window

    local gear = CreateFrame("Button", "AccountPlayedSettingsGear", window)
    gear:SetSize(18, 18)
    gear:SetPoint("TOPLEFT", 14, -12)
    gear:SetFrameLevel(window:GetFrameLevel() + 10)
    gear:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    gear:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton", "ADD")
    gear:SetScript("OnEnter", function(self)
        SetTooltip(self, SETTINGS or L["ADDON_NAME"] or "Settings")
    end)
    gear:SetScript("OnLeave", function() GameTooltip:Hide() end)
    gear:SetScript("OnClick", function()
        Settings:Toggle(window)
    end)

    window:HookScript("OnHide", function()
        if panel then panel:Hide() end
    end)
    window.settingsGear = gear
end

AP.AttachSettingsGear = function(frame)
    Settings:Attach(frame)
end

AP:RegisterMessage("SETTINGS_CHANGED", function()
    Settings:Sync()
end)
