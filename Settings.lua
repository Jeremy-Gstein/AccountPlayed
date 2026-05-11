--------------------------------------------------
-- Account Played - Settings Panel
--------------------------------------------------
local _, addonTable = ...
local L = addonTable.L

AccountPlayed = AccountPlayed or {}
local AP = AccountPlayed

local SETTINGS_DEFAULTS = {
    textScale = 1.0,
}

local function EnsureSettingsDefaults()
    for k, v in pairs(SETTINGS_DEFAULTS) do
        if AccountPlayedPopupDB[k] == nil then
            AccountPlayedPopupDB[k] = v
        end
    end
end

--------------------------------------------------
-- Helpers
--------------------------------------------------

local function GetFontData(fs)
    local path, _, flags = fs:GetFont()
    if not path then
        path, _, flags = GameFontNormalSmall:GetFont()
    end
    return path, flags or ""
end

local function ApplyScaleToRows(scale)
    if not AP.popupRows then return end
    for _, row in ipairs(AP.popupRows) do
        if row.classText then
            local path, flags = GetFontData(row.classText)
            row.classText:SetFont(path, 12 * scale, flags)
            row.classText:SetWordWrap(false)
        end
        if row.valueText then
            local path, flags = GetFontData(row.valueText)
            row.valueText:SetFont(path, 12 * scale, flags)
            row.valueText:SetWordWrap(false)
        end
    end
    if AP.popupFrame then
        if AP.popupFrame.title then
            local path, flags = GetFontData(AP.popupFrame.title)
            AP.popupFrame.title:SetFont(path, 14 * scale, flags)
            AP.popupFrame.title:SetWordWrap(false)
        end
        if AP.popupFrame.totalRow then
            local path, flags = GetFontData(AP.popupFrame.totalRow)
            AP.popupFrame.totalRow:SetFont(path, 13 * scale, flags)
            AP.popupFrame.totalRow:SetWordWrap(false)
        end
        -- Re-render value text so the % toggle takes effect immediately
        if AP.popupFrame.UpdateDisplay then
            AP.popupFrame:UpdateDisplay()
        end
    end
end


local function SetMinimapVisible(show)
    local btn = _G["AccountPlayed_MinimapButton"]
    if show then
        AccountPlayedMinimapDB.hidden = false
        if btn then
            btn:EnableMouse(true)
            btn:Show()
            btn:SetAlpha(1)
        elseif AP.CreateMinimapButton then
            AP.CreateMinimapButton()
        end
    else
        AccountPlayedMinimapDB.hidden = true
        if btn then
            UIFrameFadeRemoveFrame(btn)
            btn:SetAlpha(0)
            btn:EnableMouse(false)
            btn:Hide()
        end
    end
end

--------------------------------------------------
-- Settings Panel
--------------------------------------------------
local settingsPanel = nil

local function CreateSettingsPanel()
    if settingsPanel then return settingsPanel end

    EnsureSettingsDefaults()

    local PANEL_W = 220
    local PANEL_H = 155

    local p = CreateFrame("Frame", "AccountPlayedSettingsPanel", UIParent, "BackdropTemplate")
    p:SetSize(PANEL_W, PANEL_H)
    p:SetFrameStrata("TOOLTIP")
    p:SetFrameLevel(10)
    p:SetClampedToScreen(true)

    p:SetBackdrop({
        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    p:SetBackdropColor(0.06, 0.06, 0.06, 0.95)

    local title = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", p, "TOPLEFT", 14, -12)
    title:SetText(SETTINGS or L["ADDON_NAME"])
    title:SetTextColor(1, 0.82, 0)

    local closeBtn = CreateFrame("Button", nil, p, "UIPanelCloseButton")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", p, "TOPRIGHT", -1, -1)
    closeBtn:SetScript("OnClick", function() p:Hide() end)

    local div = p:CreateTexture(nil, "ARTWORK")
    div:SetHeight(1)
    div:SetPoint("TOPLEFT",  p, "TOPLEFT",  10, -28)
    div:SetPoint("TOPRIGHT", p, "TOPRIGHT", -10, -28)
    div:SetColorTexture(0.4, 0.4, 0.4, 0.7)

    local yOff = -36

    local scaleLabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    scaleLabel:SetPoint("TOPLEFT", p, "TOPLEFT", 14, yOff)
    scaleLabel:SetText(TEXT_SCALE or L["SETTINGS_TEXT_SCALE"])
    scaleLabel:SetTextColor(0.9, 0.9, 0.9)

    local scaleValueLabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    scaleValueLabel:SetPoint("TOPRIGHT", p, "TOPRIGHT", -14, yOff)
    scaleValueLabel:SetTextColor(1, 1, 1)

    yOff = yOff - 18

    local slider = CreateFrame("Slider", "AccountPlayedTextScaleSlider", p, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT",  p, "TOPLEFT",  16, yOff)
    slider:SetPoint("TOPRIGHT", p, "TOPRIGHT", -16, yOff)
    slider:SetHeight(16)
    slider:SetMinMaxValues(1.0, 2.0)
    slider:SetValueStep(0.05)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(AccountPlayedPopupDB.textScale or 1.0)

    _G[slider:GetName() .. "Low"]:SetText("100%")
    _G[slider:GetName() .. "High"]:SetText("200%")
    _G[slider:GetName() .. "Text"]:SetText("")

    local function RefreshScaleLabel()
        local v = slider:GetValue()
        scaleValueLabel:SetText(string.format("%d%%", math.floor(v * 100 + 0.5)))
    end
    RefreshScaleLabel()

    slider:SetScript("OnValueChanged", function(self, value)
        AccountPlayedPopupDB.textScale = value
        RefreshScaleLabel()
        ApplyScaleToRows(value)
        PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
    end)

    slider:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(TEXT_SCALE or L["SETTINGS_TEXT_SCALE"], 1, 1, 1)
        GameTooltip:AddLine(L["SETTINGS_SCALE_TIP"], 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    slider:SetScript("OnLeave", function() GameTooltip:Hide() end)

    yOff = yOff - 32

    local div2 = p:CreateTexture(nil, "ARTWORK")
    div2:SetHeight(1)
    div2:SetPoint("TOPLEFT",  p, "TOPLEFT",  10, yOff + 4)
    div2:SetPoint("TOPRIGHT", p, "TOPRIGHT", -10, yOff + 4)
    div2:SetColorTexture(0.3, 0.3, 0.3, 0.5)

    yOff = yOff - 6

    local mmCheck = CreateFrame("CheckButton", nil, p, "UICheckButtonTemplate")
    mmCheck:SetSize(24, 24)
    mmCheck:SetPoint("TOPLEFT", p, "TOPLEFT", 10, yOff)

    local mmLabel = mmCheck:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mmLabel:SetPoint("LEFT", mmCheck, "RIGHT", 2, 0)
    mmLabel:SetText(MINIMAP_LABEL or L["TOOLTIP_TITLE"])
    mmLabel:SetTextColor(0.9, 0.9, 0.9)

    mmCheck:SetChecked(not AccountPlayedMinimapDB.hidden)

    mmCheck:SetScript("OnClick", function(self)
        local show = self:GetChecked()
        PlaySound(show and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
                       or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        SetMinimapVisible(show)
    end)

    mmCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(
            (not AccountPlayedMinimapDB.hidden and HIDE or SHOW) .. " " .. (MINIMAP_LABEL or L["TOOLTIP_TITLE"]),
            1, 1, 1)
        GameTooltip:Show()
    end)
    mmCheck:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local resetBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
    resetBtn:SetSize(112, 22)
    resetBtn:SetPoint("BOTTOMLEFT", p, "BOTTOMLEFT", 12, 10)
    resetBtn:SetText(RESET_TO_DEFAULT and RESET_TO_DEFAULT or L["SETTINGS_RESET"])
    resetBtn:SetScript("OnClick", function()
        for k, v in pairs(SETTINGS_DEFAULTS) do
            AccountPlayedPopupDB[k] = v
        end
        slider:SetValue(SETTINGS_DEFAULTS.textScale)
        ApplyScaleToRows(SETTINGS_DEFAULTS.textScale)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    resetBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(L["SETTINGS_RESET_TIP"], 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    resetBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local okBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
    okBtn:SetSize(60, 22)
    okBtn:SetPoint("BOTTOMRIGHT", p, "BOTTOMRIGHT", -10, 10)
    okBtn:SetText(OKAY)
    okBtn:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
        p:Hide()
    end)

    table.insert(UISpecialFrames, "AccountPlayedSettingsPanel")

    p:Hide()
    settingsPanel = p
    return p
end

--------------------------------------------------
-- Gear Button
-- Parented to UIParent so it is never strata-clamped
-- by the popup. Manually synced to popup show/hide.
--------------------------------------------------

local function AttachGear(parentFrame)
    if parentFrame.settingsGear then return end

    local gear = CreateFrame("Button", "AccountPlayedSettingsGear", UIParent)
    gear:SetSize(20, 20)
    -- DIALOG strata level 150 — above the popup (100) but below TOOLTIP panels
    gear:SetFrameStrata("DIALOG")
    gear:SetFrameLevel(150)

    -- Anchor over the popup title bar top-left
    gear:ClearAllPoints()
    gear:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 8, -7)

    -- Use a solid colored square as a visible fallback icon, plus the real texture
    -- The texture path uses single backslashes (Lua escape = one actual backslash)
    gear:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    local nt = gear:GetNormalTexture()
    if nt then
        nt:SetVertexColor(0.8, 0.8, 0.8)
    end

    gear:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton")
    local ht = gear:GetHighlightTexture()
    if ht then
        ht:SetVertexColor(1, 1, 1)
        ht:SetBlendMode("ADD")
    end

    -- Show/hide gear in lockstep with the popup
    -- Show immediately if popup is already visible
    if parentFrame:IsShown() then
        gear:Show()
    else
        gear:Hide()
    end

    parentFrame:HookScript("OnShow", function()
        gear:ClearAllPoints()
        gear:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 8, -7)
        gear:Show()
    end)

    parentFrame:HookScript("OnHide", function()
        gear:Hide()
        if settingsPanel then
            settingsPanel:Hide()
        end
    end)

    gear:SetScript("OnEnter", function(self)
        local nt2 = self:GetNormalTexture()
        if nt2 then nt2:SetVertexColor(1, 1, 1) end
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:AddLine(SETTINGS or L["ADDON_NAME"], 1, 1, 1)
        GameTooltip:Show()
    end)

    gear:SetScript("OnLeave", function(self)
        local nt2 = self:GetNormalTexture()
        if nt2 then nt2:SetVertexColor(0.8, 0.8, 0.8) end
        GameTooltip:Hide()
    end)

    gear:SetScript("OnClick", function(self)
        local panel = CreateSettingsPanel()
        if panel:IsShown() then
            PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
            panel:Hide()
        else
            -- Sync minimap checkbox
            for _, child in next, { panel:GetChildren() } do
                if child.GetChecked then
                    child:SetChecked(not AccountPlayedMinimapDB.hidden)
                end
            end
            panel:ClearAllPoints()
            panel:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 4, -30)
            PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
            panel:Show()
        end
    end)

    parentFrame.settingsGear = gear
end

function AP.AttachSettingsGear(frame)
    AttachGear(frame)
end

--------------------------------------------------
-- Hook into popup creation
--------------------------------------------------

local hookFrame = CreateFrame("Frame")
hookFrame:RegisterEvent("PLAYER_LOGIN")

hookFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        self:UnregisterEvent("PLAYER_LOGIN")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        return
    end

    self:UnregisterEvent("PLAYER_ENTERING_WORLD")

    C_Timer.NewTicker(0.5, function(ticker)
        if AP.popupFrame then
            AP.AttachSettingsGear(AP.popupFrame)
            EnsureSettingsDefaults()
            ApplyScaleToRows(AccountPlayedPopupDB.textScale or 1.0)
            ticker:Cancel()
        end
    end, 20)
end)

--------------------------------------------------
-- Apply scale every time the popup shows
--------------------------------------------------

local function HookPopupShow()
    if not AP.popupFrame or AP.popupFrame._settingsHooked then return end
    AP.popupFrame._settingsHooked = true

    AP.AttachSettingsGear(AP.popupFrame)

    local origShow = AP.popupFrame:GetScript("OnShow")
    AP.popupFrame:SetScript("OnShow", function(self)
        if origShow then origShow(self) end
        EnsureSettingsDefaults()
        ApplyScaleToRows(AccountPlayedPopupDB.textScale or 1.0)
    end)
end

C_Timer.After(0, function()
    if AP.popupFrame then
        HookPopupShow()
    else
        local origToggle = AP.ToggleClassWindow
        AP.ToggleClassWindow = function(...)
            origToggle(...)
            HookPopupShow()
        end
    end
end)
