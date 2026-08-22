-- Account Played
-- Slash commands and character-deletion confirmation.

local _, AP = ...
local L = AP.L

local Commands = {}
AP.Commands = Commands
AP.modules.Commands = Commands

local POPUP_KEY = "ACCOUNTPLAYED_CONFIRM_DELETE"

local function Trim(value)
    return tostring(value or ""):match("^%s*(.-)%s*$")
end

local function PrintDeleteMessage(key)
    print("|cff00ff00" .. string.format(
        L["CMD_DELETE_SUCCESS"] or "Account Played: Removed '%s' from the database.", key) .. "|r")
end

StaticPopupDialogs[POPUP_KEY] = {
    text = "",
    button1 = DELETE,
    button2 = CANCEL,
    OnAccept = function(_, data)
        local key = data and data.key
        if key and AP.Data:DeleteCharacter(key) then
            PrintDeleteMessage(key)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function Commands:ConfirmDelete(key)
    if type(key) ~= "string" or AP.Data:GetDatabase()[key] == nil then return false end
    StaticPopupDialogs[POPUP_KEY].text = string.format(
        L["CMD_DELETE_CONFIRM"] or "Are you sure you want to remove |cffffff00%s|r from Account Played?", key)
    StaticPopup_Show(POPUP_KEY, nil, nil, { key = key })
    return true
end

function Commands:Delete(input)
    input = Trim(input)
    local characterName, realmName = input:match("^([^%-]+)%-(.+)$")
    if not characterName or not realmName then
        print("|cffff9900" .. (L["CMD_DELETE_USAGE"] or "Usage: /apdelete CharName-RealmName") .. "|r")
        return
    end

    local key = AP.Data:FindCharacterKey(characterName, realmName)
    if not key then
        print("|cffff4040" .. string.format(
            L["CMD_DELETE_NOT_FOUND"] or "Account Played: Character '%s' not found in the database.", input) .. "|r")
        return
    end
    self:ConfirmDelete(key)
end

function Commands:Debug()
    print("|cffff4040" .. (L["DEBUG_HEADER"] or "[AccountPlayed Debug] Known characters:") .. "|r")
    for _, character in ipairs(AP.Data:GetAllCharacters()) do
        print(string.format(" |cffffff00 - %s : %s (%s / %s / %s)|r",
            character.key,
            AP.Format:Time(character.time),
            character.class,
            character.race,
            character.faction))
    end
end

function Commands:Help()
    AP:Print(L["CMD_HELP_HEADER"] or "commands:")
    print("  |cffffff00/aplayed show|r     - " .. (L["CMD_HELP_SHOW_DESC"] or "toggle played-time window"))
    print("  |cffffff00/aplayed minimap|r  - " .. (L["CMD_HELP_MINIMAP_DESC"] or "toggle minimap icon"))
    print("  |cffffff00/aplayed reset|r    - " .. (L["CMD_HELP_RESET_DESC"] or "reset minimap icon"))
    print("  |cffffff00/apdelete Name-Realm|r - " .. (L["CMD_HELP_DELETE_DESC"] or "remove a tracked character"))
    print("  |cffffff00/apdebug|r          - " .. (L["CMD_HELP_DEBUG_DESC"] or "list tracked character data"))
end

function Commands:Handle(input)
    input = Trim(input):lower()
    if input == "show" then
        AP.ToggleClassWindow()
    elseif input == "minimap" then
        AP.MinimapButton:ToggleVisibility()
    elseif input == "reset" then
        AP.MinimapButton:Reset()
    else
        self:Help()
    end
end

SLASH_ACCOUNTPLAYED1 = "/aplayed"
SlashCmdList.ACCOUNTPLAYED = function(input)
    Commands:Handle(input)
end

SLASH_ACCOUNTPLAYEDDEBUG1 = "/apdebug"
SlashCmdList.ACCOUNTPLAYEDDEBUG = function()
    Commands:Debug()
end

SLASH_ACCOUNTPLAYEDDELETE1 = "/apdelete"
SlashCmdList.ACCOUNTPLAYEDDELETE = function(input)
    Commands:Delete(input)
end

SLASH_ACCOUNTPLAYEDPOPUP1 = "/apclasswin"
SlashCmdList.ACCOUNTPLAYEDPOPUP = function()
    AP:Print(L["MSG_CLASSWIN_DEPRECATED"] or
        "|cffff4400[DEPRECATED]|r /apclasswin will be removed; use |cffffff00/aplayed show|r.")
    AP.ToggleClassWindow()
end

SLASH_ACCOUNTPLAYEDRESETMAP1 = "/apresetmap"
SlashCmdList.ACCOUNTPLAYEDRESETMAP = function()
    AP:Print(L["MSG_CMD_DEPRECATED"] or
        "|cffff4400[DEPRECATED]|r /apresetmap will be removed; use |cffffff00/aplayed reset|r.")
    AP.MinimapButton:Reset()
end
