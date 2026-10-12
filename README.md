# MiniExpBar

Minimal experience bar for WoW Forever Beta (Interface 16001).

- Starts directly below the minimap; its width adjusts to the minimap's size and scale.
- Black background, gold XP, light blue rested XP, a Smooth texture, and a thin Blizzard border.
- Newly gained XP is highlighted in light gold for 0.6 seconds while the gold fill smoothly catches up. On loading and leveling up, the value is set immediately.
- The centered label shows current XP as a percentage of the XP required for the next level, with rested XP added as `(+ 15%)`. Rested XP can exceed 100%; the visible segment stops at the edge of the bar.
- Hold the left mouse button and drag to move the bar. Its position is saved per character.
- `/miniexpbar reset` resets the position.
- The bar is hidden at maximum level.

Restart WoW so the new addon is detected, then enable MiniExpBar in the addon list.

The bundled Smooth texture comes from the existing TidyPlates_ThreatPlates installation (`Artwork/Smooth.tga`, registered there as `Smooth`). No other addons are required at runtime.

## Addon icon

The addon list uses `Media/Icon.tga` (256 × 256 pixels, uncompressed RGBA). The high-resolution source image is stored in `Media/Icon.png`. Restart WoW after adding the icon.

Created with the built-in Imagegen tool. Generation prompt:

> Use case: logo-brand. Create a square World of Warcraft-style fantasy addon icon. Exact text: "mXP" (lowercase m, uppercase X and P), one centered line, very large readable lettering filling most of the square. Heavy ornate fantasy serif letters, beveled burnished gold, warm highlights, dark outline. Deep midnight blue textured background, restrained thin antique gold square frame. High contrast, readable at 32x32 pixels. No other text, no extra symbols, no watermark. Flat front-facing icon, not a mockup.
