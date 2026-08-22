-- Account Played
-- Localized time, label, and color formatting shared by every view.

local _, AP = ...
local L = AP.L

local Format = {}
AP.Format = Format
AP.modules.Format = Format

local RACE_PALETTE = {
    { r = 0.36, g = 0.67, b = 0.92 },
    { r = 0.55, g = 0.82, b = 0.48 },
    { r = 0.93, g = 0.66, b = 0.31 },
    { r = 0.82, g = 0.50, b = 0.86 },
    { r = 0.90, g = 0.46, b = 0.46 },
    { r = 0.45, g = 0.84, b = 0.74 },
    { r = 0.78, g = 0.76, b = 0.42 },
    { r = 0.66, g = 0.58, b = 0.95 },
}

local function Seconds(value)
    value = tonumber(value) or 0
    if value ~= value or value < 0 or value == math.huge or value == -math.huge then return 0 end
    return value
end

local function Unit(key, fallback)
    return L[key] or fallback
end

local function CopyColor(color)
    if not color then return { r = 1, g = 1, b = 1 } end
    return { r = color.r or 1, g = color.g or 1, b = color.b or 1 }
end

function Format:Time(seconds)
    local totalHours = math.floor(Seconds(seconds) / 3600)
    return string.format("%d%s %d%s",
        math.floor(totalHours / 24), Unit("TIME_UNIT_DAY", "d"),
        totalHours % 24, Unit("TIME_UNIT_HOUR", "h"))
end

function Format:CompactTime(seconds, useYears)
    local totalHours = math.floor(Seconds(seconds) / 3600)
    if useYears then
        local days = math.floor(totalHours / 24)
        if days > 0 then
            return string.format("%d%s", days, Unit("TIME_UNIT_DAY", "d"))
        end
    end
    return string.format("%d%s", totalHours, Unit("TIME_UNIT_HOUR", "h"))
end

function Format:DetailedTime(seconds, useYears)
    seconds = Seconds(seconds)
    local totalHours = math.floor(seconds / 3600)
    if useYears then
        local days = math.floor(totalHours / 24)
        if days > 0 then
            return string.format("%d%s %d%s",
                days, Unit("TIME_UNIT_DAY", "d"),
                totalHours % 24, Unit("TIME_UNIT_HOUR", "h"))
        end
    end
    return string.format("%d%s %d%s",
        totalHours, Unit("TIME_UNIT_HOUR", "h"),
        math.floor((seconds % 3600) / 60), Unit("TIME_UNIT_MINUTE", "m"))
end

function Format:TotalTime(seconds, useYears)
    seconds = Seconds(seconds)
    local days = math.floor(seconds / 86400)
    if useYears and days >= 365 then
        return string.format("%d%s %d%s",
            math.floor(days / 365), Unit("TIME_UNIT_YEAR", "y"),
            days % 365, Unit("TIME_UNIT_DAY", "d"))
    end
    return self:CompactTime(seconds, useYears)
end

function Format:DistributionValue(seconds, total, mode, useYears)
    total = Seconds(total)
    local percent = total > 0 and Seconds(seconds) / total * 100 or 0
    if mode == "days" then
        return self:CompactTime(seconds, useYears)
    elseif mode == "percent" then
        return string.format("%.1f%%", percent)
    end
    return string.format("%.1f%%  %s", percent, self:CompactTime(seconds, useYears))
end

function Format:ClassName(classFile)
    if not classFile or classFile == "UNKNOWN" then
        return L["UNKNOWN"] or "Unknown"
    end
    return (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[classFile]) or classFile
end

function Format:RaceName(raceFile, localizedName)
    if not raceFile or raceFile == "UNKNOWN" then
        return L["UNKNOWN"] or "Unknown"
    end
    return localizedName or raceFile
end

function Format:FactionName(factionFile, localizedName)
    if not factionFile or factionFile == "UNKNOWN" then
        return L["UNKNOWN"] or "Unknown"
    end
    return localizedName or factionFile
end

function Format:GroupLabel(kind, entry)
    if kind == "class" then
        return self:ClassName(entry.key)
    elseif kind == "race" then
        return self:RaceName(entry.key, entry.raceName)
    elseif kind == "faction" then
        return self:FactionName(entry.key, entry.factionName)
    end
    return entry.key or (L["UNKNOWN"] or "Unknown")
end

local function PaletteIndex(value)
    local hash = 0
    value = tostring(value or "")
    for index = 1, #value do
        hash = (hash * 33 + value:byte(index)) % 2147483647
    end
    return hash % #RACE_PALETTE + 1
end

function Format:GroupColor(kind, key)
    if key == "UNKNOWN" then
        return { r = 0.55, g = 0.55, b = 0.55 }
    elseif kind == "class" then
        return CopyColor(RAID_CLASS_COLORS and RAID_CLASS_COLORS[key])
    elseif kind == "faction" then
        if key == "Alliance" then
            return { r = 0.32, g = 0.55, b = 1 }
        elseif key == "Horde" then
            return { r = 0.93, g = 0.20, b = 0.18 }
        end
        return { r = 0.55, g = 0.55, b = 0.55 }
    end
    return CopyColor(RACE_PALETTE[PaletteIndex(key)])
end

function Format:CharacterColor(classFile)
    return CopyColor(RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile])
end

function Format:ColorCode(color)
    local function Channel(value)
        return math.floor(math.max(0, math.min(1, value or 1)) * 255 + 0.5)
    end
    return string.format("|cff%02x%02x%02x", Channel(color.r), Channel(color.g), Channel(color.b))
end
