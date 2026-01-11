--------------------------------------------------
-- Account Played Minimap Button
--------------------------------------------------
local BUTTON_NAME = "AccountPlayed_MinimapButton"
AccountPlayedMinimapDB = AccountPlayedMinimapDB or {
    angle = 225,
}

--------------------------------------------------
-- Positioning (based on LibDBIcon)
--------------------------------------------------
local function UpdateButtonPosition(button)
    local angle = math.rad(AccountPlayedMinimapDB.angle or 225)
    local x, y, q = math.cos(angle), math.sin(angle), 1
    
    if x < 0 then q = q + 1 end
    if y > 0 then q = q + 2 end
    
    -- For round minimaps, always use 80 radius
    x, y = x * 105, y * 105
    
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

--------------------------------------------------
-- Creation
--------------------------------------------------
local function CreateMinimapButton()
    if _G[BUTTON_NAME] then
        UpdateButtonPosition(_G[BUTTON_NAME])
        return
    end
    
    local btn = CreateFrame("Button", BUTTON_NAME, Minimap)
    btn:SetSize(31, 31)  -- LibDBIcon uses 31x31
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:EnableMouse(true)
    btn:RegisterForClicks("LeftButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:SetClampedToScreen(true)
    
    --------------------------------------------------
    -- Border (OVERLAY, positioned first)
    --------------------------------------------------
    btn.border = btn:CreateTexture(nil, "OVERLAY")
    btn.border:SetSize(53, 53)
    btn.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    btn.border:SetPoint("TOPLEFT")
    
    --------------------------------------------------
    -- Icon (ARTWORK layer, smaller size)
    --------------------------------------------------
    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetSize(17, 17)
    btn.icon:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01")
    btn.icon:SetPoint("CENTER")
    btn.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    
    --------------------------------------------------
    -- Highlight
    --------------------------------------------------
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
    
    --------------------------------------------------
    -- Tooltip
    --------------------------------------------------
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Account Played", 1, 1, 1)
        GameTooltip:AddLine("Left Click: Toggle window", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Drag: Move icon", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    --------------------------------------------------
    -- Click
    --------------------------------------------------
    btn:SetScript("OnClick", function()
        SlashCmdList.ACCOUNTPLAYEDPOPUP()
    end)
    
    --------------------------------------------------
    -- Drag
    --------------------------------------------------
    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            cx, cy = cx / scale, cy / scale
            local angle = math.deg(math.atan2(cy - my, cx - mx)) % 360
            AccountPlayedMinimapDB.angle = angle
            UpdateButtonPosition(self)
        end)
    end)
    btn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    
    UpdateButtonPosition(btn)
end

--------------------------------------------------
-- Init
--------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    CreateMinimapButton()
end)
