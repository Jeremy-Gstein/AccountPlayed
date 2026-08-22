-- Account Played
-- Minimap button controller.

local _, AP = ...
local L = AP.L

local MinimapButton = {}
AP.MinimapButton = MinimapButton
AP.modules.MinimapButton = MinimapButton

local BUTTON_NAME = "AccountPlayed_MinimapButton"
local SNAP_ADJUSTMENT = -5
local FADED_ALPHA = 0.05
local button

local function Settings()
    return AP.Data:GetMinimapSettings()
end

local function Fade(targetAlpha)
    if not button or not button:IsShown() then return end
    if UIFrameFadeRemoveFrame then
        UIFrameFadeRemoveFrame(button)
    end

    local currentAlpha = button:GetAlpha() or 1
    if math.abs(targetAlpha - currentAlpha) < 0.01 then
        button:SetAlpha(targetAlpha)
    elseif targetAlpha > currentAlpha and UIFrameFadeIn then
        UIFrameFadeIn(button, 0.15, currentAlpha, targetAlpha)
    elseif UIFrameFadeOut then
        UIFrameFadeOut(button, 0.15, currentAlpha, targetAlpha)
    else
        button:SetAlpha(targetAlpha)
    end
end

local function EdgeRadius()
    return ((Minimap and Minimap:GetWidth() or 140) + (button and button:GetWidth() or 31)) / 2
end

local function RefreshSnapState()
    if not button then return end
    local settings = Settings()
    local distance = math.sqrt(settings.x * settings.x + settings.y * settings.y)
    button.snapped = distance <= EdgeRadius() + button:GetWidth() * 0.3
end

function MinimapButton:UpdatePosition()
    if not button or not Minimap then return end
    local settings = Settings()
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", settings.x, settings.y)
    RefreshSnapState()
end

function MinimapButton:ApplyVisibility()
    if not button then return end
    if Settings().hidden then
        if UIFrameFadeRemoveFrame then UIFrameFadeRemoveFrame(button) end
        button:SetScript("OnUpdate", nil)
        button.isDragging = false
        button:EnableMouse(false)
        button:Hide()
        return
    end

    button:EnableMouse(true)
    button:Show()
    local hovered = button.IsMouseOver and button:IsMouseOver()
    button:SetAlpha(button.snapped and not hovered and FADED_ALPHA or 1)
end

function MinimapButton:SetVisible(visible, quiet)
    AP.Data:SetMinimapSetting("hidden", not visible)
    self:Create()
    self:ApplyVisibility()
    if not quiet then
        AP:Print(visible and (L["MSG_MINIMAP_SHOWN"] or "Minimap icon shown.")
            or (L["MSG_MINIMAP_HIDDEN"] or "Minimap icon hidden."))
    end
end

function MinimapButton:ToggleVisibility()
    self:SetVisible(Settings().hidden)
end

function MinimapButton:Reset()
    local defaults = AP.defaults.minimap
    local settings = Settings()
    settings.x = defaults.x
    settings.y = defaults.y
    settings.hidden = false

    self:Create()
    self:UpdatePosition()
    self:ApplyVisibility()
    AP:SendMessage("SETTINGS_CHANGED", "minimap", nil)
    AP:Print(L["MSG_RESET_SUCCESS"] or "Minimap button position reset to default.")
end

local function ShowTooltip(self)
    if Settings().hidden then return end
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine(L["TOOLTIP_TITLE"] or "Account Played", 0.4, 0.78, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(
        "|cffffffff" .. (L["TOOLTIP_LEFT_CLICK"] or "Left Click:") .. "|r",
        "|cff00ff00" .. (L["TOOLTIP_TOGGLE_WINDOW"] or "Toggle window") .. "|r")
    if not Settings().locked then
        GameTooltip:AddDoubleLine(
            "|cffffffff" .. (L["TOOLTIP_DRAG_MOVE"] or "Drag:") .. "|r",
            "|cffffff00" .. (L["TOOLTIP_MOVE_ICON"] or "Move icon") .. "|r")
    end
    GameTooltip:AddDoubleLine(
        "|cffffffff" .. (L["TOOLTIP_RIGHT_CLICK"] or "Right Click:") .. "|r",
        "|cffff8800" .. (L["TOOLTIP_LOCK_UNLOCK"] or "Lock/Unlock position") .. "|r")
    GameTooltip:AddLine(" ")
    local status = Settings().locked and
        "|cffff4040[" .. (L["STATUS_LOCKED"] or "LOCKED") .. "]|r" or
        "|cff40ff40[" .. (L["STATUS_UNLOCKED"] or "UNLOCKED") .. "]|r"
    GameTooltip:AddLine(status)
    GameTooltip:Show()
end

local function BeginDrag(self)
    if Settings().locked then
        AP:Print(L["MSG_BUTTON_LOCKED"] or "Button is locked. Right-click to unlock.")
        return
    end

    local scale = Minimap:GetEffectiveScale() or 1
    local centerX, centerY = Minimap:GetCenter()
    if not centerX or not centerY then return end

    local snapRadius = EdgeRadius() + SNAP_ADJUSTMENT
    local pullRadius = snapRadius + self:GetWidth() * 0.25
    local releaseRadius = snapRadius + self:GetWidth() * 0.75
    self.isDragging = true

    self:SetScript("OnUpdate", function(current)
        local cursorX, cursorY = GetCursorPosition()
        if not cursorX or not cursorY then return end
        cursorX, cursorY = cursorX / scale, cursorY / scale

        local x, y = cursorX - centerX, cursorY - centerY
        local distance = math.sqrt(x * x + y * y)
        local clampedRadius
        if distance <= snapRadius then
            current.snapped = true
            clampedRadius = snapRadius
        elseif current.snapped and distance < pullRadius then
            clampedRadius = snapRadius
        elseif current.snapped and distance < releaseRadius then
            clampedRadius = snapRadius + (distance - pullRadius) / 2
        else
            current.snapped = false
        end

        if clampedRadius and distance > 0 then
            local factor = clampedRadius / distance
            x, y = x * factor, y * factor
        end

        local settings = Settings()
        settings.x, settings.y = x, y
        current:ClearAllPoints()
        current:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end)
end

local function EndDrag(self)
    self.isDragging = false
    self:SetScript("OnUpdate", nil)
    AP:SendMessage("SETTINGS_CHANGED", "minimap", "position")

    local overMinimap = Minimap.IsMouseOver and Minimap:IsMouseOver(60, -60, -60, 60)
    if self.snapped and not overMinimap then
        Fade(FADED_ALPHA)
    else
        Fade(1)
    end
end

function MinimapButton:Create()
    if button then return button end
    if not Minimap then return nil end

    button = CreateFrame("Button", BUTTON_NAME, Minimap)
    AP.minimapButton = button
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:SetMovable(true)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetClampedToScreen(true)

    button.border = button:CreateTexture(nil, "OVERLAY")
    button.border:SetSize(53, 53)
    button.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button.border:SetPoint("TOPLEFT")

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetSize(19, 19)
    button.icon:SetTexture("Interface\\AddOns\\AccountPlayed\\aplogo.blp")
    button.icon:SetPoint("CENTER")
    button.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)

    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")

    button:SetScript("OnEnter", function(self)
        ShowTooltip(self)
        if self.snapped then Fade(1) end
    end)
    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        local overMinimap = Minimap.IsMouseOver and Minimap:IsMouseOver()
        if self.snapped and not overMinimap then Fade(FADED_ALPHA) end
    end)
    button:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            AP:PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            AP.ToggleClassWindow()
        elseif mouseButton == "RightButton" then
            local locked = not Settings().locked
            AP.Data:SetMinimapSetting("locked", locked)
            AP:PlaySound(SOUNDKIT and (locked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
                or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF))
            local status = locked and "|cffff4040" .. (L["STATUS_LOCKED"] or "LOCKED") .. "|r"
                or "|cff40ff40" .. (L["STATUS_UNLOCKED"] or "UNLOCKED") .. "|r"
            AP:Print(string.format(L["MSG_BUTTON_STATUS"] or "Minimap button %s", status))
            if GameTooltip:GetOwner() == self then ShowTooltip(self) end
        end
    end)
    button:SetScript("OnDragStart", BeginDrag)
    button:SetScript("OnDragStop", EndDrag)
    button:HookScript("OnHide", function(self)
        if UIFrameFadeRemoveFrame then UIFrameFadeRemoveFrame(self) end
        self:SetScript("OnUpdate", nil)
        self.isDragging = false
    end)

    if Minimap.HookScript then
        Minimap:HookScript("OnEnter", function()
            if button and button.snapped and not button.isDragging and not Settings().hidden then
                Fade(1)
            end
        end)
        Minimap:HookScript("OnLeave", function()
            if button and button.snapped and not button.isDragging and not button:IsMouseOver() then
                Fade(FADED_ALPHA)
            end
        end)
    end

    self:UpdatePosition()
    self:ApplyVisibility()
    return button
end

AP.CreateMinimapButton = function()
    return MinimapButton:Create()
end

AP.ResetMinimapButton = function()
    MinimapButton:Reset()
end

AP:RegisterMessage("PLAYER_LOGIN", function()
    MinimapButton:Create()
end)

AP:RegisterMessage("SETTINGS_CHANGED", function(scope, key)
    if scope == "minimap" and button then
        if key == "position" or key == nil then
            MinimapButton:UpdatePosition()
        end
        if key == "hidden" or key == "position" or key == nil then
            MinimapButton:ApplyVisibility()
        end
    end
end)
