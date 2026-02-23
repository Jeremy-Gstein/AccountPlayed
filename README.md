# AccountPlayed
Simple WoW addon to track and display /played time. sorting by class across all realms.

[![CurseForge Downloads](https://img.shields.io/curseforge/dt/1426046?style=for-the-badge&color=green)](https://www.curseforge.com/wow/addons/account-played)

<img width="791" height="339" alt="image" src="https://github.com/user-attachments/assets/dda71859-7138-45f5-91b9-e8bc22eaa8cc" />

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
- [WOWHEAD](https://www.wowhead.com/news/find-your-favorite-class-with-account-played-380300) - Huge thanks for promoting the addon!! seeing all the screenshots shared online is surreal to say the least.
- [r/wow](https://www.reddit.com/r/wow/comments/1quo3h0/account_played_track_and_display_your_characters/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button) - All the great feedback like missing documentation on slashcommands, bugs with missing minimap, and screenshots shared (:

--- 

### Contributing:
- PRs/Issues welcome! or faster response/general feedback, free to reach out via email: jeremy51b5@pm.me
- install `just` to run the repos `justfile` 
- set PATHs to match local at the top of `justfile`

Examples:
```bash
# Requires `just`
just --list # print all commands
just ls retail # list all files in retail addon dir
just sync retail # sync local repo changes to retail addon dir 
just rm retail # remove addon from retail dir. (keeps local repo unchanged)
just debug # print os, set PATHs, shasum of all files.
```

Generate a Tagged Release to trigger ./.github/workflows/build.yml (packager action)
```bash
# just build <tag> <commit>
just build 1.0.0 "Commit Message for Tagged release"
```

**Update and Version maintaining:**
```txt
*.0.0 - Breaking changes or New Features
0.*.0 - New Supported Language/Locale
0.0.* - Bug fixes, .toc updates, and small changes
```
