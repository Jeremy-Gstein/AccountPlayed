# AccountPlayed 
Simple WoW addon to track and display /played time. sorting by class across all realms.

![CurseForge Downloads](https://img.shields.io/curseforge/dt/1426046?style=for-the-badge&color=green)

<img width="534" height="389" alt="image" src="https://github.com/user-attachments/assets/8bb04d03-74ae-418f-9950-527791d880e0" />

Features:
- View your accounts top played time by class
- sorted by (class/total account /played) as a percentage
- small popup ui (resize, drag, move, and scroll as you please!)
- minimap button to toggle ui.

*tested on beta to ensure Midnight compatibility*

### Quick-start:
- Download the latest release here on github. extract the zip to your games addon folder.
- (Recommended) Download with your favorite addon manager via [Curse](https://www.curseforge.com/wow/addons/account-played)

### Contributing:
- install `just` to run the repos `justfile` 
- set PATHs to match local at the top of `justfile`

Examples:
```bash
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
