# Planet Crafter Mod Updater (akarnokd)

*Coded with AI Agent Love*

---

## Overview

This script queries the akarnokd/ThePlanetCrafterMods GitHub releases API, retrieves the most recent releases, and performs a best-effort extraction of human-readable release titles from the release metadata.

It then allows you to select a release, downloads akarnokd-all.zip, and updates only the mod folders that already exist locally.

---

## Behavior

- Replaces the contents of existing mod folders with files from the selected release
- Skips any local folders that do not exist in the zip
- Does not install new mods you do not already have
- Does not modify anything outside the matched folders
- Does exactly what it says and nothing more

---

## Requirements / Assumptions

- Run the script from your `BepInEx\plugins` directory
  (or specify a different path via -TargetPath)
- Local folder names must match the folder names inside the zip archive
- Internet access is required to query GitHub and download releases

---

## Usage

### Interactive (recommended)

    .\update_akarnokd.ps1

- Displays the latest releases (newest first)
- Shows a best-effort readable title
- Prompts for selection

### Specific version

    .\update_akarnokd.ps1 -Version v761

- Skips the menu
- Downloads and installs the specified release directly

### Dry run

    .\update_akarnokd.ps1 -WhatIf

- Shows what would be changed without modifying anything

### Custom path

    .\update_akarnokd.ps1 -TargetPath "D:\Games\The Planet Crafter\BepInEx\plugins"

---

## Notes

- Release titles are extracted from GitHub metadata
- Emoji and markdown formatting are stripped for readability
- If the author formats releases inconsistently, results may vary slightly

---

## Warning

- This script overwrites the contents of existing mod folders
- No backups are created
- If something breaks, that is on you (or your past self)

---

## Philosophy

- Does not try to be clever
- Does not install things you did not ask for
- Does not assume anything beyond folder name matching

Just updates what you already have. Nothing more, nothing less.


---

## Example Output
```
PS G:\SteamLibrary\steamapps\common\The Planet Crafter\BepInEx\plugins> .\update_akarnokd.ps1

Available releases:

 1. v2.005 - Patch 1 [v761]
 2. v2.005 - Development Branch - Patch 1 [v760]
 3. v2.004 - Update 2.0 Officially only on STEAM for now* [v759]
 4. v2.004a - Development Branch - Update [v758]
 5. v2.004a - Development Branch - Update [v757]
 6. v2.004 - Development Branch - Update [v756]
 7. v2.004 - Development Branch - Update [v755]
 8. v2.003 - Development Branch - Update [v754]
 9. v2.002 - Development Branch - Update [v753]

Enter the number to download (1-9): 1

Chosen release: v2.005 - Patch 1
Tag:            v761
Asset:          akarnokd-all.zip
Target path:    G:\SteamLibrary\steamapps\common\The Planet Crafter\BepInEx\plugins

Downloading https://github.com/akarnokd/ThePlanetCrafterMods/releases/download/v761/akarnokd-all.zip

Folders to update:
 - akarnokd - (Cheat) Asteroid Landing Position Override
 - akarnokd - (Cheat) Auto Consume Oxygen-Water-Food
 - akarnokd - (Cheat) Auto Grab and Mine
 - akarnokd - (Cheat) Auto Sequence DNA
 - akarnokd - (Cheat) Auto Store
 - akarnokd - (Cheat) Craft From Nearby Containers
 - akarnokd - (Cheat) Inventory Stacking
 - akarnokd - (Cheat) Machines Deposit Into Remote Containers
 - akarnokd - (Cheat) Recyclers Deposit Into Remote Containers
 - akarnokd - (Misc) Mod Enabler
 - akarnokd - (UI) Beacon Text
 - akarnokd - (UI) Overview Panel
 - akarnokd - (UI) Prevent Accidental Deconstruction
 - akarnokd - (UI) Show Grab N Mine Count
 - akarnokd - (UI) Show Rocket Counts


Done.
```
---
```
PS G:\SteamLibrary\steamapps\common\The Planet Crafter\BepInEx\plugins> .\update_akarnokd.ps1 -Version v761

Chosen release: v2.005 - Patch 1
Tag:            v761
Asset:          akarnokd-all.zip
Target path:    G:\SteamLibrary\steamapps\common\The Planet Crafter\BepInEx\plugins

Downloading https://github.com/akarnokd/ThePlanetCrafterMods/releases/download/v761/akarnokd-all.zip

Folders to update:
 - akarnokd - (Cheat) Asteroid Landing Position Override
 - akarnokd - (Cheat) Auto Consume Oxygen-Water-Food
 - akarnokd - (Cheat) Auto Grab and Mine
 - akarnokd - (Cheat) Auto Sequence DNA
 - akarnokd - (Cheat) Auto Store
 - akarnokd - (Cheat) Craft From Nearby Containers
 - akarnokd - (Cheat) Inventory Stacking
 - akarnokd - (Cheat) Machines Deposit Into Remote Containers
 - akarnokd - (Cheat) Recyclers Deposit Into Remote Containers
 - akarnokd - (Misc) Mod Enabler
 - akarnokd - (UI) Beacon Text
 - akarnokd - (UI) Overview Panel
 - akarnokd - (UI) Prevent Accidental Deconstruction
 - akarnokd - (UI) Show Grab N Mine Count
 - akarnokd - (UI) Show Rocket Counts


Done.
```
