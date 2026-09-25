# 1. Architectural Patterns & Services

KawalPrayer is engineered following clean architecture principles tailored for modern macOS and SwiftUI:

```
┌────────────────────────────────────────────────────────┐
│                   KawalPrayerApp                       │
│    (LSUIElement background agent, MenuBar & Window)   │
└───────────────┬────────────────────────┬───────────────┘
                │                        │
       ┌────────▼────────┐      ┌────────▼────────┐
       │StatusBarController│      │  WindowManager  │
       │ (NSStatusItem,   │      │ (NSWindow,      │
       │  NSPopover)      │      │  NavigationSplit)│
       └────────┬─────────┘      └────────┬────────┘
                │                         │
                └───────────┬─────────────┘
                            │
                  ┌─────────▼─────────┐
                  │     AppState      │
                  │ (@Observable      │
                  │  @MainActor)      │
                  └─────────┬─────────┘
                            │
    ┌──────────────┬────────┼──────────────┬──────────────┐
    │              │        │              │              │
┌───▼────┐   ┌─────▼──┐ ┌───▼────┐   ┌─────▼────┐   ┌─────▼─────┐
│Prayer  │   │Location│ │ Audio  │   │Notification│ │  Quran    │
│Calculator  │Service │ │Service │   │ Service  │   │  Service  │
└────────┘   └────────┘ └────────┘   └──────────┘   └───────────┘
```

---

## 1. State Management (`AppState`)

- **Class**: `@Observable @MainActor final class AppState`
- **Location**: `KawalPrayer/Core/AppState.swift`
- **Role**: Single Source of Truth for the entire application.
- **Responsibilities**:
  - Maintains active schedule (`prayerTimes`, `nextPrayer`, `currentPrayer`).
  - Manages real-time countdown calculation via a 1-second `Timer`.
  - Holds active settings (`PrayerSettings`) and location (`LocationModel`).
  - Observes and manages Iqamah countdown state (`IqamahState`).
  - Handles automatic banner display for Doa After Adzan.
  - Persists settings to `UserDefaults` (debounced via `saveSettings()`).
  - Restores cached location immediately on startup to prevent flickering.

---

## 2. Service Layer

All external services are decoupled from the UI and interact solely through `AppState`:

| Service | File | Purpose |
| :--- | :--- | :--- |
| `PrayerTimeCalculator` | `Core/Services/PrayerTimeCalculator.swift` | Mathematical formulas for solar declination, equation of time, solar transit, and prayer time determination with Ihtiyat. |
| `QiblaCalculator` | `Core/QiblaCalculator.swift` | Great Circle spherical trigonometry calculating the bearing angle towards the Kaaba in Mecca. |
| `LocationService` | `Core/Services/LocationService.swift` | Manages `CLLocationManager`, background significant change monitoring, distance filtering (3km), and reverse geocoding. |
| `LocationHelper` | `Core/Services/LocationHelper.swift` | Pure formatting helper converting `CLPlacemark` into `"City/Locality, District/Kecamatan"` (e.g. `"Central Jakarta, Gambir"`). |
| `AudioService` | `Core/Services/AudioService.swift` | Wraps `AVAudioPlayer` to stream or play local adzan audio files with volume control and delegates. |
| `NotificationService` | `Core/Services/NotificationService.swift` | Handles `UNUserNotificationCenter`, registers interactive categories (`stopAdzan`), schedules upcoming prayer alerts, and sends immediate Adzan alerts. |
| `QuranService` | `Core/Services/QuranService.swift` | Loads and indexes the 6,236 ayahs across 114 surahs from offline bundled JSON assets, with search and query capabilities. |
| `QuranReferenceHelper` | `Core/Services/QuranReferenceHelper.swift` | Calculates Juz and Medina Mushaf page boundaries for any surah and ayah. |

---

## 3. Window & Popover Architecture

1. **`StatusBarController`** (`Features/MenuBar/StatusBarController.swift`):
   - Creates and manages the `NSStatusItem` in the macOS menu bar.
   - Manages the `NSPopover` containing `MenuBarView`.
   - Closes popover when clicking outside or when explicitly requested.
2. **`WindowManager`** (`Features/MainWindow/WindowManager.swift`):
   - Creates a modern, unified `NSWindow` hosting `MainWindowView` when "Buka KawalPrayer" is clicked.
   - Supports hide-on-close (`isReleasedWhenClosed = false`), preserving window state without creating multiple window instances.
   - Dynamically toggles macOS Dock visibility (`NSApp.setActivationPolicy`) based on user preference (`showDockWhenWindowOpen`).

---

## 4. Persistence Architecture

- Settings are encoded to JSON and stored in `UserDefaults.standard` under key `"kawal_prayer_settings"`.
- The user's active location is stored in `UserDefaults.standard` under key `"kawal_cached_location"`.
- If manual location mode is selected, the custom location is stored under `"kawal_manual_location"`.
- On startup, `AppState.loadFromStorage()` restores both settings and the cached location synchronously before calculating initial prayer times and rendering the UI.
