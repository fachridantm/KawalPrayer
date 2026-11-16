# KawalPrayer

<div align="center">
  <img src="KawalPrayer/Assets.xcassets/AppIcon.appiconset/icon_128x128.png" width="96" height="96" alt="KawalPrayer Icon" />
  <h3>Native macOS Menu Bar Prayer Times, Adzan & Offline Quran App</h3>
  <p><b>by Outivox</b></p>

  [![macOS](https://img.shields.io/badge/macOS-14%2B-black?logo=apple&logoColor=white)](https://apple.com/macos)
  [![Swift](https://img.shields.io/badge/Swift-5.9%20%2F%206-orange?logo=swift&logoColor=white)](https://swift.org)
  [![SwiftUI](https://img.shields.io/badge/SwiftUI-%40Observable-blue)](https://developer.apple.com/xcode/swiftui/)
  [![Outivox Design System](https://img.shields.io/badge/Outivox-Design%20Tokens-34A853)](ai-guidelines/2-design-tokens-theming.md)
  [![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
</div>

---

**KawalPrayer** is a native macOS menu bar application designed to run silently in the background without cluttering the Dock or app switcher (`⌘Tab`). It features accurate astronomical prayer time calculations following Indonesia's Ministry of Religious Affairs (Kemenag RI, +2 min Ihtiyat), a complete offline 30-Juz Quran with an authentic Madinah Mushaf layout, a real-time Qibla compass, interactive notifications, Dynamic Island / notch alerts, and an automatic post-Adzan dua pop-up.

Built with the **Outivox** visual identity using the **Outivox Design Token System** (`ColorToken`, `DimensToken`, `FloatToken`, and `OX` facade) under a strict *Zero Raw Literals* rule.

---

## Installation

1. Download the latest `KawalPrayer-v*.dmg` from [GitHub Releases](https://github.com/fachridantm/KawalPrayer/releases/latest).
2. Open the downloaded `.dmg` file and drag `KawalPrayer.app` into your `/Applications` folder.

### Opening the App (Bypassing macOS Gatekeeper)

Because `KawalPrayer` is ad-hoc signed without a paid Apple Developer ID certificate, macOS Gatekeeper may show a warning such as *"KawalPrayer cannot be opened because the developer cannot be verified"* or *"Apple could not verify KawalPrayer is free of malware"*.

You can allow it using either method below:

#### Option 1: System Settings (Recommended)
1. Double-click `KawalPrayer.app` in `/Applications` (or right-click → **Open**) and click **Done** / **Cancel** on the warning dialog.
2. Open **System Settings** → **Privacy & Security**.
3. Scroll down to the **Security** section.
4. Click **Open Anyway** next to the message about `KawalPrayer`, then confirm with **Open**.

#### Option 2: Terminal
Run the following command to clear the macOS quarantine attribute:
```bash
xattr -cr /Applications/KawalPrayer.app
```
Then open `KawalPrayer.app` normally from `/Applications` or Spotlight.

---

## Key Features

### 1. Silent Background Agent (`LSUIElement = true`)
- Lives in the macOS Menu Bar without showing an icon in the Dock or `⌘Tab` on startup.
- The main window (Dashboard, Quran, Settings) only opens when you select **"Open KawalPrayer"**.
- Closing the window (`⌘W` or red close button) only hides it; the app stays active in the background to track prayer times.
- An optional *"Show in Dock when Window is Open"* setting is available if you prefer standard Dock integration while the window is open.

### 2. Menu Bar Formats & Dynamic Icons
- **5 Status Bar Display Modes** (great for both notched MacBooks and wide displays):
  1. `Icon + Name + Countdown` *(Default, e.g. `🌙 Fajr • 00:45`)*
  2. `Icon + Countdown` *(e.g. `🌙 00:45`)*
  3. `Icon + Prayer Name` *(e.g. `🌙 Fajr`)*
  4. `Icon + Prayer Time` *(e.g. `🌙 Fajr 04:35`)*
  5. `Icon Only` *(e.g. `🌙`)*
- **Dynamic Menu Bar Icon**: Can display the current prayer icon (e.g. `sun.haze.fill` for Dhuhr), the next prayer icon, or a static crescent icon.

### 3. Persistent Location Detection (City & District)
- Uses `CoreLocation` for low-power movement detection (3 km distance filter).
- Formats locations cleanly as **`City/Locality, District/SubLocality`** (e.g. **`Central Jakarta, Gambir`** or **`Bandung, Coblong`**).
- **Persistent Storage**: The last resolved location is saved to `UserDefaults` so it appears immediately on launch without flickering or resetting to a fallback.
- Includes a **Refresh GPS Location** button in both the menu bar popover header and Settings.

### 4. Prayer Time Accuracy (Kemenag RI +2 Min Ihtiyat)
- Offline astronomical calculation with **Ihtiyat** safety margin (+2 minutes default, matching Kemenag RI / Bimas Islam schedules).
- Asr juristic method options: **Shafi'i / Maliki / Hanbali** (1× shadow) or **Hanafi** (2× shadow).
- International calculation methods: Muslim World League (MWL), ISNA, Umm al-Qura (Makkah), and Egyptian.
- **24-Hour Continuous Countdown**: After Isha passes, the countdown automatically transitions to the next day's Fajr.

### 5. Dynamic Island / Notch Alerts, Post-Adzan Dua & Iqamah Timer
- **Notch Alert**: Displays a sleek, non-intrusive Dynamic Island alert at the top of the screen when prayer time arrives, with **Stop Adzan** and **Dismiss** controls.
- **Post-Adzan Dua**: Once Adzan finishes (or after clicking "Stop Adzan"), the menu bar popover automatically opens with the **Dua After Adzan** card (Arabic text, Latin transliteration, and translation).
- **Iqamah Timer**: Configurable countdown between Adzan and Iqamah (1–30 minutes) with an *"Iqamah time for <Prayer>!"* notification.

### 6. Interactive Notifications
- Prayer-time notifications include quick action buttons:
  - **"Stop Adzan"**: Stops Adzan audio directly from the notification banner.
  - **"Dismiss"**: Closes the notification.
- **Auto-Dismiss**: Automatically clears the notification from Notification Center once Adzan playback finishes.

### 7. Offline 30-Juz Quran (Madinah Mushaf & Per-Ayah)
- **All 114 Surahs Offline** — 100% available without an internet connection.
- **Dual Reading Modes**:
  - **Madinah Mushaf**: Continuous mushaf page layout with authentic surah calligraphy (`SurahBannerView`), interactive circular ayah numbers, and tap-to-view translation pop-ups.
  - **Per-Ayah**: Vertical list view with instant copy and bookmark actions.
- Fast search and adjustable Arabic font size slider (18–40pt).

### 8. Real-Time Qibla Compass
- Computes the Great Circle azimuth to the Kaaba in Makkah (`21.4225° N, 39.8262° E`).
- Visual compass with an Outivox Green (`ColorToken.Green`) Kaaba needle and cardinal direction readout (e.g. `295° WNW`).

---

## Architecture & Development Guidelines

Full architectural documentation and AI agent guidelines are available in:
- [**AGENTS.md**](AGENTS.md) — Core technical rules and guardrails.
- [**ai-guidelines/INDEX.md**](ai-guidelines/INDEX.md) — Technical documentation & feature specs:
  - [1. Architectural Patterns & Services](ai-guidelines/1-architectural-patterns.md)
  - [2. Design Tokens & Theming](ai-guidelines/2-design-tokens-theming.md)
  - [3. Code Style & Guardrails](ai-guidelines/3-code-style-and-guardrails.md)
  - [4. Localization & Internationalization](ai-guidelines/4-localization-and-internationalization.md)
  - [5. Background Agent & Audio Lifecycle](ai-guidelines/5-background-agent-and-audio.md)

---

## Build from Source

### Prerequisites
- macOS 14.0 (Sonoma) or newer
- Xcode 15 / 16 / 27+ at `/Applications/Xcode.app`

### Build & Run
```bash
# Debug Build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project KawalPrayer.xcodeproj \
  -scheme KawalPrayer \
  -configuration Debug build

# Run Unit Tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project KawalPrayer.xcodeproj \
  -scheme KawalPrayer test
```

### Build DMG Installer
Run the automated DMG packaging script:
```bash
./scripts/build_dmg.sh
```
The installer `KawalPrayer-v<version>.dmg` will be generated in the repository root.

---

## License & Copyright
Made with ❤️ by **Outivox**.  
Distributed under the MIT License.
