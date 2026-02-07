--------------------------------------------------
-- Account Played Minimap Button
-- Hybrid snap/free-form positioning system:
--   - Snaps to minimap edge when close (works with round minimap)
--   - Breaks free for arbitrary positioning (works with square minimap / ElvUI)
--   - Saves x,y offset relative to Minimap center between sessions
--------------------------------------------------
local BUTTON_NAME = "AccountPlayed_MinimapButton"

-- Migrate from old angle-only format or initialize defaults.
-- New format stores x,y offsets from Minimap center.
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
end

--------------------------------------------------
-- Positioning
--------------------------------------------------
local function UpdateButtonPosition(button)
    local x = AccountPlayedMinimapDB.x or 0
    local y = AccountPlayedMinimapDB.y or 0
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Save the button's current position as an offset from Minimap center
local function SaveButtonPosition(button)
    local bx, by = button:GetCenter()
    local mx, my = Minimap:GetCenter()
    if bx and mx then
        AccountPlayedMinimapDB.x = bx - mx
        AccountPlayedMinimapDB.y = by - my
    end
end

--------------------------------------------------
-- Drag logic constants
-- These define concentric distance zones around the minimap center:
--   <= radSnap  : snap to the minimap edge (circular behavior)
--   <= radPull  : resist pulling away if currently snapped
--   <= radFree  : gradual transition from snapped to free
--   >  radFree  : fully free-form positioning
--------------------------------------------------
local RADIUS_ADJUST = -5  -- tighten the snap ring slightly

--------------------------------------------------
-- Creation
--------------------------------------------------
local function CreateMinimapButton()
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
    btn:RegisterForClicks("LeftButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:SetClampedToScreen(true)

    -- Track whether the icon is snapped to the minimap edge
    btn.snapped = true

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
    -- Drag (hybrid snap / free-form)
    --------------------------------------------------
    btn:SetScript("OnDragStart", function(self)
        self.isDragging = true
        self:SetScript("OnUpdate", function(self)
            local minimap = Minimap
            local mx, my = minimap:GetCenter()
            local scale = minimap:GetEffectiveScale()

            -- Cursor position in the same coordinate space as minimap
            local cx, cy = GetCursorPosition()
            cx, cy = cx / scale, cy / scale

            -- Vector from minimap center to cursor
            local dx, dy = cx - mx, cy - my
            local dist = (dx * dx + dy * dy) ^ 0.5

            -- Compute snap/free zone radii based on current minimap size
            local edgeRadius = (minimap:GetWidth() + self:GetWidth()) / 2
            local radSnap = edgeRadius + RADIUS_ADJUST
            local radPull = edgeRadius + self:GetWidth() * 0.2
            local radFree = edgeRadius + self:GetWidth() * 0.7

            -- Determine whether to clamp to the edge ring
            local radClamp
            if dist <= radSnap then
                -- Close to minimap: snap to edge
                self.snapped = true
                radClamp = radSnap
            elseif dist < radPull and self.snapped then
                -- Slightly beyond edge but still snapped: hold at edge
                radClamp = radSnap
            elseif dist < radFree and self.snapped then
                -- Transition zone: gradually release
                radClamp = radSnap + (dist - radPull) / 2
            else
                -- Far enough away: free positioning
                self.snapped = false
            end

            -- If clamping, scale the offset vector to the clamp radius
            if radClamp and dist > 0 then
                local factor = radClamp / dist
                dx = dx * factor
                dy = dy * factor
            end

            -- Apply position
            AccountPlayedMinimapDB.x = dx
            AccountPlayedMinimapDB.y = dy
            self:ClearAllPoints()
            self:SetPoint("CENTER", minimap, "CENTER", dx, dy)
        end)
    end)

    btn:SetScript("OnDragStop", function(self)
        self.isDragging = false
        self:SetScript("OnUpdate", nil)
        -- Save final position (already stored in DB during drag)
    end)

    -- Determine initial snap state from saved position
    local edgeRadius = (Minimap:GetWidth() + btn:GetWidth()) / 2
    local savedDist = (AccountPlayedMinimapDB.x ^ 2 + AccountPlayedMinimapDB.y ^ 2) ^ 0.5
    btn.snapped = (savedDist <= edgeRadius + btn:GetWidth() * 0.3)

    UpdateButtonPosition(btn)
end

--------------------------------------------------
-- Init
--------------------------------------------------
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    InitDB()
    CreateMinimapButton()
end)
