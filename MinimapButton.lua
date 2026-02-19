-- Account Played Minimap Button 
-- Performance improvements:
-- 1. Replaced continuous OnUpdate polling with event-driven OnEnter/OnLeave
-- 2. Used Blizzard's UIFrameFade functions for hardware-accelerated animations
-- 3. Cached constant values in drag handler
-- 4. Added cleanup on hide
-- Expected: 0% CPU when idle (down from 0.02-0.06%)
-- `/apresetmap` is being depreciated in v2.0.0 Use new api: `/aplayed reset`

local _, addonTable = ...
local L = addonTable.L

-- Addon namespace
AccountPlayed = AccountPlayed or {}
local AP = AccountPlayed

local BUTTON_NAME = "AccountPlayed_MinimapButton"

-- Migrate from old angle-only format or initialize defaults
local function InitDB()
    if not AccountPlayedMinimapDB then
        AccountPlayedMinimapDB = {}
    end

    -- Migrate: if old angle-based data exists, convert to x,y
    if AccountPlayedMinimapDB.angle and not AccountPlayedMinimapDB.x then
        local angle = math.rad(AccountPlayedMinimapDB.angle)
        local radius = 105
        AccountPlayedMinimapDB.x = math.cos(angle) * radius
        AccountPlayedMinimapDB.y = math.sin(angle) * radius
        AccountPlayedMinimapDB.angle = nil
    end

    -- Default position: bottom-left of minimap (equivalent to old 225 degrees)
    if not AccountPlayedMinimapDB.x then
        local angle = math.rad(225)
        local radius = 105
        AccountPlayedMinimapDB.x = math.cos(angle) * radius
        AccountPlayedMinimapDB.y = math.sin(angle) * radius
    end
    
    -- Default locked state
    if AccountPlayedMinimapDB.locked == nil then
        AccountPlayedMinimapDB.locked = false
    end
end

-- Positioning
local function UpdateButtonPosition(button)
    local x = AccountPlayedMinimapDB.x or 0
    local y = AccountPlayedMinimapDB.y or 0
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Fade animation using Blizzard's built-in system
local function FadeButton(btn, targetAlpha, duration)
    duration = duration or 0.15
    
    -- Cancel any existing fades
    UIFrameFadeRemoveFrame(btn)
    
    local currentAlpha = btn:GetAlpha()
    
    if math.abs(targetAlpha - currentAlpha) < 0.01 then
        return  -- Already at target
    end
    
    if targetAlpha > currentAlpha then
        UIFrameFadeIn(btn, duration, currentAlpha, targetAlpha)
    else
        UIFrameFadeOut(btn, duration, currentAlpha, targetAlpha)
    end
end

-- Creation of the Minimap button
local function CreateMinimapButton()
    -- Don't create if hidden
    if AccountPlayedMinimapDB.hidden then
        return
    end

    -- Update position if already exists
    if _G[BUTTON_NAME] then
        UpdateButtonPosition(_G[BUTTON_NAME])
        return
    end

    local btn = CreateFrame("Button", BUTTON_NAME, Minimap)
    btn:SetSize(31, 31)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:SetMovable(true)
    btn:EnableMouse(true)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:SetClampedToScreen(true)
    btn:SetAlpha(0.01)  -- Start faded out

    -- Tooltip, Click Handlers, and Fade on Hover
    btn:SetScript("OnEnter", function(self)
        -- Don't show tooltip or fade in when the button is intentionally hidden
        if AccountPlayedMinimapDB.hidden then return end

        -- Show tooltip
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(L["TOOLTIP_TITLE"], 0.4, 0.78, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("|cffffffff" .. L["TOOLTIP_LEFT_CLICK"] .. "|r", "|cff00ff00" .. L["TOOLTIP_TOGGLE_WINDOW"] .. "|r")
        if not AccountPlayedMinimapDB.locked then
            GameTooltip:AddDoubleLine("|cffffffff" .. L["TOOLTIP_DRAG_MOVE"] .. "|r", "|cffffff00" .. L["TOOLTIP_MOVE_ICON"] .. "|r")
        end
        GameTooltip:AddDoubleLine("|cffffffff" .. L["TOOLTIP_RIGHT_CLICK"] .. "|r", "|cffff8800" .. L["TOOLTIP_LOCK_UNLOCK"] .. "|r")
        GameTooltip:AddLine(" ")
        local statusText = AccountPlayedMinimapDB.locked and "|cffff0000[" .. L["STATUS_LOCKED"] .. "]|r" or "|cff00ff00[" .. L["STATUS_UNLOCKED"] .. "]|r"
        GameTooltip:AddLine(statusText, 1, 1, 1)
        GameTooltip:Show()
        
        -- Keep button visible when hovering over it
        if self.snapped and not AccountPlayedMinimapDB.hidden then
            FadeButton(self, 1, 0.15)
        end
    end)
    
    btn:SetScript("OnLeave", function(self)
        -- Hide tooltip
        GameTooltip:Hide()
        
        -- Only fade if we're leaving both the button AND the minimap area
        if self.snapped and not Minimap:IsMouseOver() then
            FadeButton(self, 0.01, 0.15)
        end
    end)
    
    btn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            AP.ToggleClassWindow()
        elseif button == "RightButton" then
            AccountPlayedMinimapDB.locked = not AccountPlayedMinimapDB.locked
            PlaySound(AccountPlayedMinimapDB.locked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
            
            local statusMsg = AccountPlayedMinimapDB.locked and "|cffff0000" .. L["STATUS_LOCKED"] .. "|r" or "|cff00ff00" .. L["STATUS_UNLOCKED"] .. "|r"
            print("|cff00ff00Account Played:|r " .. string.format(L["MSG_BUTTON_STATUS"], statusMsg))
            
            -- Update tooltip if showing
            if GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
        end
    end)

    -- Hook Minimap's own mouse events instead of creating blocking overlay
    Minimap:HookScript("OnEnter", function()
        if not btn.isDragging and btn.snapped and not AccountPlayedMinimapDB.hidden then
            FadeButton(btn, 1, 0.15)
        end
    end)
    
    Minimap:HookScript("OnLeave", function()
        -- Only fade out if mouse is not over the button itself
        if not btn.isDragging and btn.snapped and not btn:IsMouseOver() then
            FadeButton(btn, 0.01, 0.15)
        end
    end)

    -- Border (OVERLAY, positioned first)
    btn.border = btn:CreateTexture(nil, "OVERLAY")
    btn.border:SetSize(53, 53)
    btn.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    btn.border:SetPoint("TOPLEFT")

    -- Icon (ARTWORK layer, smaller size)
    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetSize(17, 17)
    btn.icon:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01")
    btn.icon:SetPoint("CENTER")
    btn.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)

    -- Highlight
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")

    -- Drag handlers with cached values
    btn:SetScript("OnDragStart", function(self)
        if AccountPlayedMinimapDB.locked then
            print("|cff00ff00Account Played:|r " .. L["MSG_BUTTON_LOCKED"])
            return
        end
        
        self.isDragging = true
        
        -- Cache values that don't change during drag
        local minimap = Minimap
        local minimapScale = minimap:GetEffectiveScale()
        local minimapCenterX, minimapCenterY = minimap:GetCenter()
        local minimapWidth = minimap:GetWidth()
        local buttonWidth = self:GetWidth()
        local edgeRadius = (minimapWidth + buttonWidth) / 2
        local RADIUS_ADJUST = -5
        
        -- Pre-calculate snap thresholds
        local radSnap = edgeRadius + RADIUS_ADJUST
        local radPull = edgeRadius + buttonWidth * 0.2
        local radFree = edgeRadius + buttonWidth * 0.7
        
        self:SetScript("OnUpdate", function(self)
            local cx, cy = GetCursorPosition()
            cx, cy = cx / minimapScale, cy / minimapScale
            local dx, dy = cx - minimapCenterX, cy - minimapCenterY
            
            -- Use squared distance when possible (avoids sqrt)
            local distSquared = dx * dx + dy * dy
            local dist = distSquared ^ 0.5  -- Only calc actual distance once
            
            local radClamp
            
            -- Snapping logic
            if dist <= radSnap then
                self.snapped = true
                radClamp = radSnap
            elseif dist < radPull and self.snapped then
                radClamp = radSnap
            elseif dist < radFree and self.snapped then
                radClamp = radSnap + (dist - radPull) / 2
            else
                self.snapped = false
            end

            -- Apply final position
            if radClamp and dist > 0 then
                local factor = radClamp / dist
                dx = dx * factor
                dy = dy * factor
            end

            AccountPlayedMinimapDB.x = dx
            AccountPlayedMinimapDB.y = dy
            self:ClearAllPoints()
            self:SetPoint("CENTER", minimap, "CENTER", dx, dy)
        end)
    end)

    btn:SetScript("OnDragStop", function(self)
        self.isDragging = false
        self:SetScript("OnUpdate", nil)
        
        -- Update fade state after drag ends
        if self.snapped and Minimap:IsMouseOver(60, -60, -60, 60) then
            FadeButton(self, 1, 0.15)
        elseif self.snapped then
            FadeButton(self, 0.01, 0.15)
        else
            FadeButton(self, 1, 0.15)
        end
    end)

    --  Cleanup on hide
    btn:HookScript("OnHide", function(self)
        -- Cancel any running fades
        UIFrameFadeRemoveFrame(self)
        -- Remove OnUpdate if dragging was interrupted
        self:SetScript("OnUpdate", nil)
        self.isDragging = false
    end)

    -- Determine initial snap state
    local edgeRadius = (Minimap:GetWidth() + btn:GetWidth()) / 2
    local savedDist = (AccountPlayedMinimapDB.x ^ 2 + AccountPlayedMinimapDB.y ^ 2) ^ 0.5
    btn.snapped = (savedDist <= edgeRadius + btn:GetWidth() * 0.3)
    
    -- Set initial opacity based on snap state
    if btn.snapped then
        -- Start invisible if snapped, will fade in when mouse enters
        btn:SetAlpha(0.01)
    else
        -- If not snapped (free-positioned), make it visible
        btn:SetAlpha(1)
    end

    UpdateButtonPosition(btn)
end

-- Expose so AccountPlayed.lua can create the button on demand (e.g. /aplayed minimap to re-show after a hidden reload)
AP.CreateMinimapButton = CreateMinimapButton
-- Called by /aplayed reset (defined in AccountPlayed.lua).
function AP.ResetMinimapButton()
    -- Reset to default position (bottom-left, 225 degrees)
    local angle = math.rad(225)
    local radius = 105
    AccountPlayedMinimapDB.x = math.cos(angle) * radius
    AccountPlayedMinimapDB.y = math.sin(angle) * radius

    -- Clear hidden flag so the button becomes visible again
    AccountPlayedMinimapDB.hidden = false

    local btn = _G[BUTTON_NAME]
    if btn then
        btn.snapped = true
        UIFrameFadeRemoveFrame(btn)  -- cancel any in-progress fade
        btn:EnableMouse(true)
        btn:Show()
        btn:SetAlpha(0.01)  -- Snapped default: reveal on hover
        UpdateButtonPosition(btn)
        print("|cff00ff00Account Played:|r " .. L["MSG_RESET_SUCCESS"])
    else
        print("|cff00ff00Account Played:|r " .. L["MSG_RESET_NEXT"])
    end
end

-- Deprecated alias: /apresetmap  (kept for backwards compatibility)
SLASH_ACCOUNTPLAYEDRESETMAP1 = "/apresetmap"
SlashCmdList.ACCOUNTPLAYEDRESETMAP = function()
    print("|cff00ff00Account Played:|r " .. L["MSG_CMD_DEPRECATED"])
    AP.ResetMinimapButton()
end

-- Init
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    InitDB()
    CreateMinimapButton()
end)
