--------------------------------------------------
-- Account Played - Lifetime Playtime Statistics
--
-- Calculates how your total WoW playtime compares
-- to all the free time you've had since launch day.
--
-- Formula:
--   HoursSinceRelease = (now - 2004-11-23) in hours
--   SleepHours        = S  * DaysSinceRelease    (default S = 8 h/night)
--   AwakeHours        = HoursSinceRelease - SleepHours
--   WorkHours         = (DaysSinceRelease * 5/7) * W   (default W = 8 h/weekday)
--   FreeTime          = AwakeHours - WorkHours
--   PercentOfFreeTime = P / FreeTime
--   PercentOfAwake    = P / AwakeHours
--   YearsPlaying      = P / (24 * 365.25)
--
-- where P = total account hours played.
--------------------------------------------------

local _, addonTable = ...
local L = addonTable.L

AccountPlayed = AccountPlayed or {}
local AP = AccountPlayed

--------------------------------------------------
-- Constants
--------------------------------------------------

-- Unix timestamp for WoW's original release: 2004-11-23 00:00:00 UTC
--   Days from epoch (1970-01-01) to 2004-01-01:
--     34 years, 8 leap years (1972,76,80,84,88,92,96,2000) = 12418 days
--   Days from 2004-01-01 to 2004-11-23 (start of day):
--     Jan(31)+Feb(29)+Mar(31)+Apr(30)+May(31)+Jun(30)+
--     Jul(31)+Aug(31)+Sep(30)+Oct(31)+Nov 1-22(22) = 327 days
--   Total: (12418 + 327) days * 86400 s/day = 1101168000
local WOW_RELEASE_TIMESTAMP = 1101168000

local HOURS_PER_YEAR = 24 * 365.25
local WEEKDAY_RATIO  = 5 / 7

--------------------------------------------------
-- Core Calculation
--------------------------------------------------

-- P : total account hours played
-- S : assumed sleep hours per night  (default 8)
-- W : assumed work hours per weekday (default 8)
local function CalculatePlaytimeStats(P, S, W)
    S = S or 8
    W = W or 8

    local secondsSinceRelease = time() - WOW_RELEASE_TIMESTAMP
    if secondsSinceRelease <= 0 then
        return nil, "System clock is set before WoW's release date."
    end

    local HoursSinceRelease = secondsSinceRelease / 3600
    local DaysSinceRelease  = HoursSinceRelease / 24
    local SleepHours        = S * DaysSinceRelease
    local AwakeHours        = HoursSinceRelease - SleepHours
    local WorkHours         = (DaysSinceRelease * WEEKDAY_RATIO) * W
    local FreeTime          = AwakeHours - WorkHours

    return {
        PlayerAccountHours = P,
        FreeTime           = FreeTime,
        AwakeHours         = AwakeHours,
        PercentOfFreeTime  = FreeTime   > 0 and (P / FreeTime)   or 0,
        PercentOfAwakeTime = AwakeHours > 0 and (P / AwakeHours) or 0,
        YearsSpentPlaying  = P / HOURS_PER_YEAR,
    }
end

--------------------------------------------------
-- Chat Output
--------------------------------------------------

local C_GOLD  = "|cffffd100"
local C_WHITE = "|cffffffff"
local C_GREEN = "|cff00ff96"
local C_LBLUE = "|cff69ccf0"
local C_GREY  = "|cffaaaaaa"
local C_RESET = "|r"

local DIVIDER = "  " .. C_GREY .. string.rep("-", 38) .. C_RESET

-- Prints one labeled row with dot-leader alignment.
local function Row(label, value)
    local dots = string.rep(".", math.max(2, 38 - #label - #value))
    print(string.format("  %s%s%s %s%s%s %s%s%s",
        C_LBLUE, label,  C_RESET,
        C_GREY,  dots,   C_RESET,
        C_WHITE, value,  C_RESET))
end

-- Colour shifts green -> yellow -> red based on how large the percentage is.
local function PctColor(pct)
    if     pct < 0.10 then return C_GREEN
    elseif pct < 0.25 then return "|cffffff00"
    else                    return "|cffff4040"
    end
end

-- Public: compute and print the lifetime stats block to chat.
function AP.PrintPlaytimeStats()
    local totalSeconds = 0
    for _, data in pairs(AccountPlayedDB) do
        if type(data) == "table" and data.time then
            totalSeconds = totalSeconds + data.time
        end
    end

    if totalSeconds == 0 then
        print(C_GOLD .. "[" .. L["STATS_HEADER"] .. "]" .. C_RESET)
        print("  " .. C_GREY .. L["STATS_NO_DATA"] .. C_RESET)
        return
    end

    local P = totalSeconds / 3600
    local stats, err = CalculatePlaytimeStats(P)
    if not stats then
        print(C_GOLD .. "[AccountPlayed] " .. C_RESET .. (err or "Unknown error."))
        return
    end

    -- Header
    print(C_GOLD .. "  == " .. L["STATS_HEADER"] .. " ==" .. C_RESET)
    print(DIVIDER)

    -- Your playtime
    Row(L["STATS_TOTAL_HOURS"],
        string.format("%s%.0fh%s", C_GREEN, stats.PlayerAccountHours, C_RESET))
    Row(L["STATS_YEARS"],
        string.format("%s%.2f yrs%s", C_GREEN, stats.YearsSpentPlaying, C_RESET))

    print(DIVIDER)

    -- Available free time pool
    Row(L["STATS_FREE_TIME"],
        string.format("%.0fh", stats.FreeTime))

    print(DIVIDER)

    -- What fraction of your life was WoW?
    local pf  = stats.PercentOfFreeTime
    local paw = stats.PercentOfAwakeTime

    Row(L["STATS_PCT_FREE"],
        string.format("%s%.2f%%%s", PctColor(pf),  pf  * 100, C_RESET))
    Row(L["STATS_PCT_AWAKE"],
        string.format("%s%.2f%%%s", PctColor(paw), paw * 100, C_RESET))

    print(DIVIDER)
    print("  " .. C_GREY
        .. "(Assumes 8h sleep/night, 8h work/weekday, since 2004-11-23)"
        .. C_RESET)
end

--------------------------------------------------
-- Slash Command   /apstats
--------------------------------------------------

SLASH_ACCOUNTPLAYEDSTATS1 = "/apstats"
SlashCmdList.ACCOUNTPLAYEDSTATS = function()
    AP.PrintPlaytimeStats()
end
