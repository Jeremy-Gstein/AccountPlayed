# AccountPlayed

AccountPlayed is a World of Warcraft add-on that records each character's
`/played` response and turns the locally collected data into an account-wide
play-time overview.

[![CurseForge Downloads](https://img.shields.io/curseforge/dt/1426046?style=for-the-badge&color=green)](https://www.curseforge.com/wow/addons/account-played)

<img width="757" height="414" alt="AccountPlayed window" src="https://github.com/user-attachments/assets/b2f04b66-0b31-4f1d-86ac-ad13143e7fde" />

## Features

- Class, character, race, and faction views across every tracked realm
- Bar and pie visualizations for distribution views
- Deterministic sorting by played time, with totals and percentages
- Character tooltips, chat summaries, and deletion controls
- A movable, resizable, scrollable window that remembers its layout
- Hours/minutes and years/days time formats
- Configurable text scale and value display
- Movable minimap button with snapping, fading, locking, and visibility controls
- LibDataBroker support for display-bar add-ons
- English fallback plus zhCN, zhTW, frFR, ruRU, deDE, esMX, esES, and ptBR locale data
- A versioned LibStub API for other add-ons

AccountPlayed can only know about a character after that character has been
logged in while the add-on is enabled. Race and faction metadata for older
records is filled in the next time each character reports `/played`; until
then, it appears under **Unknown**.

## Commands

| Command | Action |
| --- | --- |
| `/aplayed` | Show command help |
| `/aplayed show` | Toggle the played-time window |
| `/aplayed minimap` | Show or hide the minimap button |
| `/aplayed reset` | Reset and show the minimap button |
| `/apdelete Name-Realm` | Remove a tracked character after confirmation |
| `/apdebug` | Print all stored character records |

`/apclasswin` and `/apresetmap` remain as deprecated compatibility aliases.

## Installation

Install AccountPlayed with an add-on manager from
[CurseForge](https://www.curseforge.com/wow/addons/account-played) or
[Wago](https://addons.wago.io/addons/accountplayed), or extract a
[GitHub release](https://github.com/Jeremy-Gstein/AccountPlayed/releases) into
the appropriate `Interface/AddOns` directory.

## Public API

The `AccountPlayed-1.0` LibStub library exposes snapshots of the tracked data.
API version 2 adds race and faction metadata and totals while preserving the
version 1 methods.

```lua
local Played = LibStub("AccountPlayed-1.0")

local totalSeconds = Played:GetAccountTotal()
local characters = Played:GetAllCharacters()
local classTotals = Played:GetClassTotals()

Played:OnCharacterUpdated("MyAddon", function(
    realm, name, seconds, classFile, raceFile, factionFile
)
    -- The stored record changed.
end)

-- Later:
Played:OffCharacterUpdated("MyAddon")
```

Available queries include `GetAccountTotal`, `GetClassTotals`,
`GetRaceTotals`, `GetFactionTotals`, `GetAllCharacters`,
`GetCharactersByClass`, `GetCharacterCount`, `GetCharacterData`,
`HasCharacter`, and `GetCurrentCharacterTime`. Time helpers are
`FormatTime`, `FormatTimeHours`, and `FormatTimeDetailed`.

Advanced CallbackHandler consumers can register with their own handler object:

```lua
Played.RegisterCallback(myObject, "CharacterUpdated", "OnCharacterUpdated")
```

## Development

The rewrite separates lifecycle, saved data, formatting, UI, settings,
minimap, commands, broker integration, and the public API. Vendor libraries in
`Libs/` remain unchanged.

Run the local verification suite with:

```bash
lua tests/run.lua
luac -p *.lua Libs/*.lua
```

The included `justfile` contains optional local sync and release helpers.
Override its install paths for your own WoW installation.

### Localization

Translations are community-maintained. Please identify AI-generated additions
with `-- (AI-GENERATED TRANSLATION)` and translation fixes with a contributor
comment.

| Status | Language | Locale |
| --- | --- | --- |
| Completed | Portuguese (Brazil) | ptBR |
| Completed | Chinese (Simplified) | zhCN |
| Completed | Chinese (Traditional) | zhTW |
| Completed | French | frFR |
| Completed | German | deDE |
| Completed | Russian | ruRU |
| Completed | Spanish (Mexico) | esMX |
| Completed | Spanish (Spain) | esES |
| Completed | English (United States) | enUS |
| Not completed | Italian | itIT |
| Not completed | Korean | koKR |
| Not completed | Portuguese (Portugal) | ptPT |

## Thanks

Thanks to everyone in [Seems Good](https://seemsgood.org) for testing and
encouragement, and to the community contributors who built and translated the
original add-on:

- Pip, for the original idea
- Whare, for WoW API help and debugging
- [Amadeus](https://github.com/Amadeus-), for minimap and formatting fixes
- [SGSwdzgr](https://github.com/SGSwdzgr), for the localization framework and Chinese locales
- [ZelionGG](https://github.com/Jeremy-Gstein/AccountPlayed/commits?author=ZelionGG), for French
- [Hubbotu](https://github.com/Hubbotu), for Russian
- [Smooth](https://github.com/Smooth26), for Spanish and Brazilian Portuguese
- [DaBear78](https://github.com/DaBear78), for German

Issues and pull requests are welcome.
