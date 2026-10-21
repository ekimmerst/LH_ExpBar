# LH_ExpBar

Version: 1.1.0

Keep your next level in sight without cluttering your screen. LH_ExpBar adds a compact experience bar beneath your minimap, showing your leveling progress and rested XP at a glance.

Made for WoW Forever Beta, it works as soon as you enable it. No setup is needed beyond installing the required LH_Tweaks core.

## Features

- **Easy-to-read progress:** A gold bar and centered percentage show how far you are toward your next level.
- **Rested XP at a glance:** A light blue section shows your rested bonus, with its percentage displayed beside your progress.
- **Smooth XP gains:** Newly earned experience briefly lights up as the bar fills.
- **A compact look:** A dark background and subtle border fit neatly beneath the minimap. Default width matches the minimap, including scale differences. Custom widths remain relative to it.
- **Position and size controls:** Unlock the bar to move it. A small circle below its bottom-right corner resizes width and height independently from 50% to 200%, matching LH_Range's controls. Width has a 70-UI-unit minimum. Text remains outlined at 12 points. Each character remembers position, dimensions and locking.
- **Detailed XP tooltip:** Hover over the locked bar to see current XP out of the level's requirement, full rested XP and XP still needed, with integer amounts and percentages to two decimal places. Rested XP is expressed as a percentage of a full level and is not clipped to the drawn segment. Values update while the tooltip is open.
- **Hidden at max level:** The locked bar disappears automatically at the level cap. Unlocking shows a preview so its layout remains editable.
- **Native settings:** All configuration lives under WoW Settings > AddOns > LH Tweaks > LH ExpBar.

## How to use

The bar appears below your minimap by default and updates as you earn experience.

For example, `45% (+ 15%)` means you are 45% of the way to your next level and have a rested XP bonus equal to 15% of a full level.

The bar starts **locked**, including after upgrading an older installation without a saved lock setting. Your saved position is retained. While locked, hovering shows the detailed XP tooltip and dragging does not move the bar.

To move or resize it, use the native **Unlock the experience bar** checkbox, or type:

```text
/lh_expbar unlock
```

Left-drag the bar to move it. Left-drag the small circle below the right edge to change width horizontally and height vertically. Use `/lh_expbar lock` or disable the checkbox to lock it again and hide the circle.

The native options also provide **Bar width** and **Bar height** sliders and **Reset layout**. `/lh_expbar reset` restores the default dimensions and position beneath the minimap while preserving the lock setting. Blizzard's **Defaults** for this category additionally locks the bar; the game-wide Defaults action resets it too. All settings use the existing per-character `LH_ExpBarDB` table. With the default position, the bar stays anchored below the minimap until you actually move or resize it.

## Installation

1. Place the complete `LH_ExpBar` folder, including Settings.lua and Media, in your game's `Interface/AddOns` folder. Install and enable LH_Tweaks too.
2. Restart the game.
3. Enable **LH ExpBar**, grouped under **LH Tweaks**, in the addon list on the character selection screen.

Fully restart WoW after updating to 1.1.0 because the TOC now loads Settings.lua and adds grouping metadata.

## Upgrading from MiniExpBar

Replace the old addon folder with **LH_ExpBar** and restart WoW. The reset command is now `/lh_expbar reset`.

To retain your saved position, close WoW and back up each character's `WTF/Account/<account>/<realm>/<character>/SavedVariables/MiniExpBar.lua` file. Copy it to `LH_ExpBar.lua` in the same SavedVariables folder, then change the table name `MiniExpBarDB` to `LH_ExpBarDB` inside the copy. Migrate before first using the renamed addon; do not overwrite an existing `LH_ExpBar.lua` containing settings you want to keep. Without migration, the bar starts at its default position beneath the minimap.

## Credits

The bundled Smooth bar texture comes from TidyPlates_ThreatPlates.

Media/Icon.png and Media/Icon.tga are exact copies of LH_Tweaks' shared gold LH artwork, using Spoken's chamfered gold frame as the reference. There is no runtime dependency on Spoken.

## Verification

`.settings-test.py` passed with Lua 5.1 simulations for current/rested XP tooltip values (including zero rested XP and more than one level of rested XP), live tooltip refresh and ownership, XP gain animation, locking, dragging, independent resizing and limits, frame/parent/minimap scale conversion, missed mouse-up, minimap width changes, default anchoring, max-level preview, saved-state reload and native category controls/defaults. Loading the actual LH_Range code also verifies that its default width follows the resized XP bar. Icon files are verified byte-for-byte against LH_Tweaks. `git diff --check` passed.

Native rendering remains pending in game: restart WoW, inspect LH Tweaks > LH ExpBar, move and resize the bar, lock it and hover, gain XP/change rested XP, and check persistence after `/reload`. Run the simulation with `python LH_ExpBar/.settings-test.py` from the AddOns folder when Lupa is available in `LH_Tweaks/.test-runtime`.

## Changelog

### 1.1.0 - 2026-10-21

- Added `/lh_expbar unlock` and `lock`, defaulting to locked while retaining existing saved positions.
- Added LH_Range-style bottom-right circle resizing with independent width and height factors, saved per character; reset restores size as well as position.
- Added a locked-bar hover tooltip with current XP, full rested XP and remaining XP in numbers and percentages, refreshed on XP/rested updates.
- Added native settings under LH Tweaks with unlock, width/height sliders, layout reset and scoped defaults.
- Added the shared LH icon and native AddOn list grouping under LH Tweaks.
- Kept XP gain animation and minimap-width tracking; added an unlocked max-level preview.

### 1.0.1 - 2026-10-21

- Renamed MiniExpBar to LH_ExpBar, including the addon folder, Lua/TOC files, metadata, icon and texture paths, frame name, chat messages and documentation.
- Changed the reset command to `/lh_expbar reset` and the per-character settings table to `LH_ExpBarDB`.
- Added instructions for transferring the saved position from the previous addon name.

## Required core addon

Install and enable **LH_Tweaks** alongside this addon. LH_Tweaks is the shared LiteHawk configuration host and must load first. CurseForge releases must list LH_Tweaks as a required dependency so the client installs it automatically.
