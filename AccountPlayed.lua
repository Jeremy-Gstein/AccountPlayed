-- Account Played
-- Shared namespace, lifecycle, and internal message bus.

local ADDON_NAME, AP = ...

-- Keep the historical global namespace for integrations and old macros while
-- using the table supplied by WoW as the single source of truth internally.
_G.AccountPlayed = AP

AP.name = ADDON_NAME
AP.L = AP.L or {}
AP.modules = AP.modules or {}
AP._messages = AP._messages or {}

local unpack = unpack or table.unpack

local function AssertMessageArguments(message, callback)
    assert(type(message) == "string" and message ~= "", "message must be a non-empty string")
    assert(type(callback) == "function", "callback must be a function")
end

function AP:RegisterMessage(message, callback)
    AssertMessageArguments(message, callback)

    local listeners = self._messages[message]
    if not listeners then
        listeners = {}
        self._messages[message] = listeners
    end

    listeners[#listeners + 1] = callback
    return callback
end

function AP:UnregisterMessage(message, callback)
    local listeners = self._messages[message]
    if not listeners then return end

    for index = #listeners, 1, -1 do
        if listeners[index] == callback then
            table.remove(listeners, index)
        end
    end

    if #listeners == 0 then
        self._messages[message] = nil
    end
end

local function DispatchSafely(callback, ...)
    if type(geterrorhandler) ~= "function" then
        callback(...)
        return
    end

    local arguments = { ... }
    local argumentCount = select("#", ...)
    local errorHandler = geterrorhandler()
    if type(errorHandler) ~= "function" then
        callback(...)
        return
    end
    xpcall(function()
        callback(unpack(arguments, 1, argumentCount))
    end, errorHandler)
end

function AP:SendMessage(message, ...)
    local listeners = self._messages[message]
    if not listeners then return end

    -- A listener may unsubscribe while handling a message. Iterate over a
    -- snapshot so every listener registered at dispatch time runs exactly once.
    local snapshot = {}
    for index = 1, #listeners do
        snapshot[index] = listeners[index]
    end

    for index = 1, #snapshot do
        DispatchSafely(snapshot[index], ...)
    end
end

function AP:Print(message)
    print("|cff00ff00Account Played:|r " .. tostring(message or ""))
end

function AP:PlaySound(sound)
    if sound and PlaySound then
        PlaySound(sound)
    end
end

function AP:After(delay, callback)
    if C_Timer and C_Timer.After then
        C_Timer.After(delay, callback)
    else
        callback()
    end
end

local eventFrame = CreateFrame("Frame")
AP.eventFrame = eventFrame
AP.mainFrame = eventFrame -- Public compatibility alias used by API v1 clients.

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("TIME_PLAYED_MSG")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon ~= ADDON_NAME then return end

        self:UnregisterEvent("ADDON_LOADED")
        if AP.Data then
            AP.Data:Initialize()
        end
        AP:SendMessage("ADDON_READY")
        return
    end

    AP:SendMessage(event, ...)
end)
