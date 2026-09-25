# Feature: Menu Bar Agent

The Menu Bar Agent is the primary touchpoint of KawalPrayer. It gives users immediate, at-a-glance awareness of prayer schedules and countdowns.

---

## 1. Components & Architecture

- **`StatusBarController.swift`**: Initializes the macOS `NSStatusItem` (`.variableLength`), creates an `NSPopover`, and handles left-click toggle events.
- **`MenuBarView.swift`**: SwiftUI view hosted inside the popover displaying:
  1. `GoogleColorDivider` (Outivox 4-color strip)
  2. Location & city refresh button
  3. Next prayer countdown
  4. Active Iqamah banner (if active)
  5. Active Dua After Adzan banner (if active)
  6. Hijri, Qibla azimuth, and Gregorian date strip
  7. Today's prayer times list with active/passed status
  8. Open window & Quit buttons

---

## 2. Display Modes (`MenuBarDisplayMode`)

Users can customize the status bar item format in Settings:

| Mode | Format Preview (English) | Preview (Indonesian) | Ideal For |
|---|---|---|---|
| `iconNameCountdown` | `🌙 Fajr • 00:45` | `🌙 Subuh • 00:45` | Default, spacious menu bars |
| `iconCountdown` | `🌙 00:45` | `🌙 00:45` | MacBooks with notch |
| `iconName` | `🌙 Fajr` | `🌙 Subuh` | Minimalist name |
| `iconTime` | `🌙 Fajr 04:35` | `🌙 Subuh 04:35` | Fixed schedule view |
| `iconOnly` | `🌙` | `🌙` | Ultra-compact icon only |

---

## 3. Dynamic Menu Bar Icon Sources (`MenuBarIconSource`)

Users can choose how the menu bar icon reflects prayer status:
- **`currentPrayer` (Default)**: Displays the SF Symbol icon of the prayer currently in progress (e.g. `sun.haze.fill` during Dhuhr, `sunset.fill` during Maghrib).
- **`nextPrayer`**: Displays the icon of the upcoming prayer target.
- **`staticMoon`**: Displays a consistent `moon.stars.fill`.

---

## 4. Automatic Popover Opening

When an Adzan completes (or the user stops it), `AppState.onShowPopoverRequested?()` triggers `StatusBarController.showPopover()` to automatically present the **Dua After Adzan** card.
