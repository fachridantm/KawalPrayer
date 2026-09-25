# 2. Design Tokens & Theming (Outivox Design System)

KawalPrayer strictly implements the **Outivox Design Token System** ported from the [KawalEvent](file:///Users/fachridantm/Library/CloudStorage/OneDrive-uinjkt.ac.id/StudioProjects/KawalEvent) repository:

```
Core/Theme/
├── Components/
│   └── GoogleColorDivider.swift
├── OX.swift
└── Token/
    ├── ColorToken.swift
    ├── DimensToken.swift
    └── FloatToken.swift
```

---

## 1. Zero Raw Literals Rule

To prevent visual inconsistencies, code plagiarism, and magic numbers:
1. **Never use raw numbers for dimensions** (`.padding(16)`, `width: 32`, `cornerRadius: 8`). Use `OX.Spacing.*`, `OX.Radius.*`, `OX.Border.*`, or `DimensToken.*`.
2. **Never use raw floats for opacities** (`.opacity(0.5)`). Use `FloatToken.*` (e.g. `FloatToken.PERCENT_50`).
3. **Never use raw Color literals** (`Color(red: ...)`, `Color.green`). Use `OX.Color.*` or `ColorToken.*`.

---

## 2. Color Tokens (`ColorToken.swift`)

### Primary Google/Outivox Palettes:
- **Blue**: `ColorToken.Blue` (`#4285F4`), scales `Blue10` (`#E6F3FF`) through `Blue90` (`#003666`).
- **Green** (Primary KawalPrayer Brand): `ColorToken.Green` (`#34A853`), scales `Green10` (`#E6EEE8`) through `Green90` (`#003510`).
- **Yellow**: `ColorToken.Yellow` (`#F9AB00`), scales `Yellow10` (`#FFFFFBEE`) through `Yellow90` (`#997309`).
- **Red**: `ColorToken.Red` (`#EA4335`), scales `Red10` (`#FBE9EA`) through `Red90` (`#6E1215`).

### Neutral Scales:
- **LightGrey**: `LightGrey10` (`#FAFAFA`) through `LightGrey90` (`#CCCCCC`).
- **DarkGrey**: `DarkGrey10` (`#1E1E1E` - Outivox brand outline) through `DarkGrey90` (`#808080`).

---

## 3. Dimension Tokens (`DimensToken.swift`)

Represents discrete dimension points (Dp in Android, Pt in macOS):
- `DimensToken.SIZE_0` = `0.0`
- `DimensToken.SIZE_1` = `1.0`
- `DimensToken.SIZE_2` = `2.0`
- `DimensToken.SIZE_4` = `4.0`
- `DimensToken.SIZE_6` = `6.0`
- `DimensToken.SIZE_8` = `8.0`
- `DimensToken.SIZE_10` = `10.0`
- `DimensToken.SIZE_12` = `12.0`
- `DimensToken.SIZE_14` = `14.0`
- `DimensToken.SIZE_16` = `16.0`
- `DimensToken.SIZE_20` = `20.0`
- `DimensToken.SIZE_24` = `24.0`
- `DimensToken.SIZE_28` = `28.0`
- `DimensToken.SIZE_32` = `32.0`
- `DimensToken.SIZE_48` = `48.0`
- `DimensToken.SIZE_50` = `50.0`
- `DimensToken.SIZE_52` = `52.0`
- `DimensToken.SIZE_80` = `80.0`

---

## 4. Float Tokens (`FloatToken.swift`)

Replaces raw float opacity and scalar numbers:
- `FloatToken.PERCENT_0` = `0.0`
- `FloatToken.PERCENT_10` = `0.10`
- `FloatToken.PERCENT_15` = `0.15`
- `FloatToken.PERCENT_20` = `0.20`
- `FloatToken.PERCENT_30` = `0.30`
- `FloatToken.PERCENT_40` = `0.40`
- `FloatToken.PERCENT_50` = `0.50`
- `FloatToken.PERCENT_60` = `0.60`
- `FloatToken.PERCENT_65` = `0.65`
- `FloatToken.PERCENT_70` = `0.70`
- `FloatToken.PERCENT_80` = `0.80`
- `FloatToken.PERCENT_85` = `0.85`
- `FloatToken.PERCENT_90` = `0.90`
- `FloatToken.PERCENT_100` = `1.00`

---

## 5. The `OX` Facade (`OX.swift`)

The unified interface for spacing, radii, borders, and adaptive colors:

### `OX.Spacing`
- `OX.Spacing.None` = `DimensToken.SIZE_0` (0pt)
- `OX.Spacing.XS2`  = `DimensToken.SIZE_2` (2pt)
- `OX.Spacing.XS`   = `DimensToken.SIZE_4` (4pt)
- `OX.Spacing.S`    = `DimensToken.SIZE_8` (8pt)
- `OX.Spacing.M`    = `DimensToken.SIZE_12` (12pt)
- `OX.Spacing.L`    = `DimensToken.SIZE_16` (16pt)
- `OX.Spacing.XL`   = `DimensToken.SIZE_20` (20pt)
- `OX.Spacing.XL2`  = `DimensToken.SIZE_24` (24pt)

### `OX.Radius`
- `OX.Radius.XS`  = `DimensToken.SIZE_4` (4pt)
- `OX.Radius.S`   = `DimensToken.SIZE_8` (8pt)
- `OX.Radius.M`   = `DimensToken.SIZE_12` (12pt)
- `OX.Radius.L`   = `DimensToken.SIZE_16` (16pt)
- `OX.Radius.XL`  = `DimensToken.SIZE_20` (20pt)
- `OX.Radius.FULL` = `999.0` (Pill / Capsule)

### `OX.Border`
- `OX.Border.WIDTH_0_5` = `0.5`
- `OX.Border.WIDTH_1`   = `DimensToken.SIZE_1` (1.0pt)
- `OX.Border.WIDTH_1_5` = `1.5`
- `OX.Border.WIDTH_2`   = `DimensToken.SIZE_2` (2.0pt)

### `OX.Color` (Adaptive Semantic Colors)
- `OX.Color.primary` = `ColorToken.Green`
- `OX.Color.secondary` = `ColorToken.Blue`
- `OX.Color.surface(for: scheme)` = Dark: `DarkGrey10`, Light: `White`
- `OX.Color.outline(for: scheme)` = Dark: `DarkGrey30`, Light: `InputBorder`
- `OX.Color.prayerActive(for: scheme)` = `ColorToken.Green`
- `OX.Color.prayerActiveContainer(for: scheme)` = Dark: `Green90` (40%), Light: `Green10` (85%)
- `OX.Color.nextPrayer(for: scheme)` = `ColorToken.Blue`
- `OX.Color.nextPrayerContainer(for: scheme)` = Dark: `Blue90` (40%), Light: `Blue10` (85%)

---

## 6. Signature Components (`GoogleColorDivider.swift`)

Outivox's signature four-color accent strip:
```swift
GoogleColorDivider(thickness: DimensToken.SIZE_3)
```
Renders a capsule composed of 4 equal segments: Blue `#4285F4`, Red `#EA4335`, Yellow `#F9AB00`, and Green `#34A853`. Used at top of the Menu Bar and in the About dashboard view.
