# MiniExpBar

Minimale Erfahrungsleiste für WoW Forever Beta (Interface 16001).

- Startposition direkt unter der Minimap; die Breite passt sich deren Größe und Skalierung an.
- Schwarzer Hintergrund, goldene Erfahrung, hellblaue Erholungs-Erfahrung, Smooth-Textur und dünner Blizzard-Rahmen.
- Neue Erfahrung wird für 0,6 Sekunden hellgold hervorgehoben, während die goldene Füllung weich nachzieht. Beim Laden und beim Levelwechsel wird der Stand direkt gesetzt.
- Mittig steht die aktuelle Erfahrung in Prozent des nächsten Levels, bei Erholungs-Erfahrung ergänzt um `(+ 15%)`. Der Vorrat kann über 100 % liegen; der sichtbare Abschnitt endet am Leistenrand.
- Mit gedrückter linker Maustaste ziehen. Die Position wird pro Charakter gespeichert.
- `/miniexpbar reset` setzt die Position zurück.
- Am Maximallevel wird die Leiste ausgeblendet.

WoW neu starten, damit das neue AddOn erkannt wird, und MiniExpBar in der AddOn-Liste aktivieren.

Die lokale Smooth-Textur stammt aus der vorhandenen Installation von TidyPlates_ThreatPlates (`Artwork/Smooth.tga`, dort als `Smooth` registriert). Zur Laufzeit werden keine weiteren AddOns benötigt.

## AddOn-Icon

Die AddOn-Liste verwendet `Media/Icon.tga` (256 × 256 Pixel, unkomprimiertes RGBA). Die hochauflösende Vorlage liegt in `Media/Icon.png`. Nach dem Hinzufügen WoW neu starten.

Erstellt mit dem integrierten Imagegen-Tool. Generierungs-Prompt:

> Use case: logo-brand. Create a square World of Warcraft-style fantasy addon icon. Exact text: "mXP" (lowercase m, uppercase X and P), one centered line, very large readable lettering filling most of the square. Heavy ornate fantasy serif letters, beveled burnished gold, warm highlights, dark outline. Deep midnight blue textured background, restrained thin antique gold square frame. High contrast, readable at 32x32 pixels. No other text, no extra symbols, no watermark. Flat front-facing icon, not a mockup.
