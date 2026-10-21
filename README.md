# LH_ExpBar

Version: 1.0.1

Keep your next level in sight without cluttering your screen. LH_ExpBar adds a compact experience bar beneath your minimap, showing your leveling progress and rested XP at a glance.

Made for WoW Forever Beta, it works as soon as you enable it. No setup or additional addons are needed.

## Features

- **Easy-to-read progress:** A gold bar and centered percentage show how far you are toward your next level.
- **Rested XP at a glance:** A light blue section shows your rested bonus, with its percentage displayed beside your progress.
- **Smooth XP gains:** Newly earned experience briefly lights up as the bar fills.
- **A compact look:** A dark background and subtle border fit neatly beneath the minimap. The bar automatically matches the minimap's width.
- **Place it where you like:** Move the bar anywhere on your screen. Each character remembers their own position.
- **Hidden at max level:** The bar disappears automatically when you reach the level cap.

## How to use

The bar appears below your minimap by default and updates as you earn experience.

For example, `45% (+ 15%)` means you are 45% of the way to your next level and have a rested XP bonus equal to 15% of a full level.

To move the bar, hold the **left mouse button** on it and drag it to your preferred spot.

To return it to its default position beneath the minimap, type:

```text
/lh_expbar reset
```

## Installation

1. Place the `LH_ExpBar` folder in your game's `Interface/AddOns` folder.
2. Restart the game.
3. Enable **LH_ExpBar** in the addon list on the character selection screen.

## Upgrading from MiniExpBar

Replace the old addon folder with **LH_ExpBar** and restart WoW. The reset command is now `/lh_expbar reset`.

To retain your saved position, close WoW and back up each character's `WTF/Account/<account>/<realm>/<character>/SavedVariables/MiniExpBar.lua` file. Copy it to `LH_ExpBar.lua` in the same SavedVariables folder, then change the table name `MiniExpBarDB` to `LH_ExpBarDB` inside the copy. Migrate before first using the renamed addon; do not overwrite an existing `LH_ExpBar.lua` containing settings you want to keep. Without migration, the bar starts at its default position beneath the minimap.

## Credits

The bundled Smooth bar texture comes from TidyPlates_ThreatPlates.

## Changelog

### 1.0.1 - 2026-10-21

- Renamed MiniExpBar to LH_ExpBar, including the addon folder, Lua/TOC files, metadata, icon and texture paths, frame name, chat messages and documentation.
- Changed the reset command to `/lh_expbar reset` and the per-character settings table to `LH_ExpBarDB`.
- Added instructions for transferring the saved position from the previous addon name.
