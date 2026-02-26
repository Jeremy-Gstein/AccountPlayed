# AccountPlayed
Simple WoW addon to track and display /played time. sorting by class across all realms.

[![CurseForge Downloads](https://img.shields.io/curseforge/dt/1426046?style=for-the-badge&color=green)](https://www.curseforge.com/wow/addons/account-played)

<img width="757" height="414" alt="image" src="https://github.com/user-attachments/assets/b2f04b66-0b31-4f1d-86ac-ad13143e7fde" />
<img width="264" height="136" alt="image" src="https://github.com/user-attachments/assets/6a516b04-c65a-4592-81b5-438e4cdd5819" />
<img width="601" height="69" alt="image" src="https://github.com/user-attachments/assets/09c7e94e-9795-4dcd-80cb-798366d94677" />

**Features:**
- View your account's top played time by class
- Sorted by (class / total account played) as a percentage
- Small popup UI (resize, drag, move, and scroll as you please!)
- Minimap button to toggle UI (fades when mouse is not over minimap)
- Hover over classes to get a popup of all characters making up the playtime
- Button to toggle between Years/Days or Hours/Min
- Press Escape to close window
- **(NEW)** Rework existing slash commands to use a more consistent name: `/aplayed`
- **(NEW)** `/aplayed minimap` - remove the minimap icon (toggle on/off OR use `/aplayed reset` and run `/reload`)
- **(NEW/Work-in-Progress)** Localized framework currently supporting enUS, zhCN, zhTW, frFR

**Usage:**
- `/aplayed`         - list available commands
- `/aplayed show`    - toggle class time window
- `/aplayed minimap` - toggle the AccountPlayed minimap icon on/off
- `/aplayed reset`   - reset the position of the minimap button to the bottom left of the minimap
- `/apdebug`         - prints a list of all stored characters to chat in the following format: `Realm-Name: TimePlayed (CLASS)`

**Deprecated** (will be removed in a future update):
- `/apclasswin` - toggle class time window (use new API: `/aplayed show`)
- `/apresetmap` - reset the position of the minimap button to the bottom left of the minimap (use new API: `/aplayed reset`)

### Quick-start:
- Download the latest release here on github. extract the zip to your games addon folder.
- (Recommended) Download with your favorite addon manager via [Curse](https://www.curseforge.com/wow/addons/account-played) OR [Wago.io](https://addons.wago.io/addons/accountplayed)

### Honorable Mentions:
HUGE Thank you to everyone in [Seems Good](https://seemsgood.org) for testing and motivating to publish and share with others.
- Pip: Original idea to share time played and compare with other guildies.
- Whare: WoW api help and debugging
- [Amadeus](https://github.com/Amadeus-): Minimap fix to support all ui layouts, padding with class names, and better fomatting
- [SGSwdzgr](https://github.com/SGSwdzgr): Added Localizatin Support for Simplified Chinese (zhCN) and Traditional Chinese (zhTW) and English (enUS)
- [ZelionGG](https://github.com/Jeremy-Gstein/AccountPlayed/commits?author=ZelionGG): Added Localization for French locale (frFr)
- [Hubbotu](https://github.com/Hubbotu) - Added Localization for Russian locale (ruRU)
- [Smooth](https://github.com/Smooth26) - Added Localization for Spanish (esES), (esMX), and (ptBR)
- [WOWHEAD](https://www.wowhead.com/news/find-your-favorite-class-with-account-played-380300) - Huge thanks for promoting the addon!! seeing all the screenshots shared online is surreal to say the least.
- [r/wow](https://www.reddit.com/r/wow/comments/1quo3h0/account_played_track_and_display_your_characters/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button) - All the great feedback like missing documentation on slashcommands, bugs with missing minimap, and screenshots shared (:

--- 

### Contributing:
- PRs/Issues welcome! or faster response/general feedback, free to reach out via email: jeremy51b5@pm.me
- install `just` to run the repos `justfile` 
- set PATHs to match local at the top of `justfile`

**Localizing**:
(Huge thanks to [SGSwdzgr](https://github.com/SGSwdzgr) for implimenting a framework for adding locales!!)
- if using AI for translations please markup with: `-- (AI-GENERATED TRANSLATION)` 
- if fixing a translation (or adding) markup with your github username: `-- (FIXED BY: Jeremy-Gstein)` (example)
- supported languages/locales sourced from: [WoW's API](https://warcraft.wiki.gg/wiki/API_GetAvailableLocaleInfo)

| Status        | Country                              | Language   | Code |
|---------------|--------------------------------------|------------|------|
| Completed     | Brazil                               | Portuguese | ptBR |
| Completed     | China                                | Chinese    | zhCN |
| Completed     | France                               | French     | frFR |
| Completed     | Germany                              | German     | deDE |
| Completed     | Russia                               | Russian    | ruRU |
| Completed     | Spain                                | Spanish    | esES |
| Completed     | Taiwan                               | Chinese    | zhTW |
| Completed     | United States of America             | English    | enUS |
| Not Completed | Italy                                | Italian    | itIT |
| Not Completed | Mexico                               | Spanish    | esMX |
| Not Completed | Portugal                             | Portuguese | ptPT |
| Not Completed | Republic of Korea                    | Korean     | koKR |
| Not Completed | Taiwan                               | English    | enTW |
| Not Completed | Great Britain and Northern Ireland   | English    | enGB |

---

**Update and Version maintaining:**
```txt
*.0.0 - Breaking changes or New Features
0.*.0 - New Supported Language/Locale
0.0.* - Bug fixes, .toc updates, and small changes
```

Examples with justfile:
- install `just` to run the repos `justfile` 
- set PATHs to match local at the top of `justfile`
```bash
# Requires `just`
just --list # print all commands
just ls retail # list all files in retail addon dir
just sync retail # sync local repo changes to retail addon dir 
just rm retail # remove addon from retail dir. (keeps local repo unchanged)
just debug # print os, set PATHs, shasum of all files.
```

Generate a Tagged Release to trigger .github/workflows/build.yml (packager action)
```bash
# just build <tag> <commit>
just build 1.0.0 "Commit Message for Tagged release"
```
