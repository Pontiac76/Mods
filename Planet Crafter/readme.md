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

- Run the script from your BepInEx\plugins directory
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
