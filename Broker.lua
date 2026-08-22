-- Account Played
-- LibDataBroker integration for display-bar add-ons.

local _, AP = ...
local L = AP.L

local Broker = {}
AP.Broker = Broker
AP.modules.Broker = Broker

local ldb = LibStub("LibDataBroker-1.1", true)
if not ldb then return end

local object = ldb:NewDataObject("AccountPlayed", {
    type = "data source",
    text = L["ADDON_NAME"] or "Account Played",
    icon = "Interface\\AddOns\\AccountPlayed\\aplogo.blp",
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(L["TOOLTIP_TITLE"] or "Account Played", 1, 1, 1)
        tooltip:AddLine(L["TOOLTIP_TOGGLE_WINDOW"] or "Click to toggle the played-time window", 0.8, 0.8, 0.8)
    end,
    OnClick = function(_, mouseButton)
        if mouseButton == "LeftButton" then
            AP.ToggleClassWindow()
        end
    end,
})

Broker.object = object

function Broker:Refresh()
    if not AP.Data.initialized then return end
    local settings = AP.Data:GetPopupSettings()
    object.text = AP.Format:TotalTime(AP.Data:GetAccountTotal(), settings.useYears)
end

AP:RegisterMessage("ADDON_READY", function() Broker:Refresh() end)
AP:RegisterMessage("CHARACTER_UPDATED", function() Broker:Refresh() end)
AP:RegisterMessage("CHARACTER_REMOVED", function() Broker:Refresh() end)
AP:RegisterMessage("SETTINGS_CHANGED", function(scope)
    if scope == "popup" then Broker:Refresh() end
end)
