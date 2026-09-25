# Agent Guidelines & Guardrails — KawalPrayer

Welcome to the **KawalPrayer** repository. Follow these strict rules and guidelines when reading, writing, and refactoring code across the codebase.

For in-depth architectural and implementation guides, refer to the [AI Guidelines Index](ai-guidelines/INDEX.md):
- [1. Architectural Patterns & Services](ai-guidelines/1-architectural-patterns.md)
- [2. Design Tokens & Theming](ai-guidelines/2-design-tokens-theming.md)
- [3. Code Style & Guardrails](ai-guidelines/3-code-style-and-guardrails.md)
- [4. Localization & Internationalization](ai-guidelines/4-localization-and-internationalization.md)
- [5. Background Agent & Audio Lifecycle](ai-guidelines/5-background-agent-and-audio.md)

Feature Guidelines:
- [Menu Bar Agent](ai-guidelines/feature/menu-bar-agent.md) | [Prayer Schedule & Calculations](ai-guidelines/feature/prayer-schedule-and-calculations.md) | [Location & Qibla](ai-guidelines/feature/location-and-qibla.md) | [Iqamah & Adzan Dua](ai-guidelines/feature/iqamah-and-adzan-dua.md) | [Offline Quran & Mushaf](ai-guidelines/feature/offline-quran-and-mushaf.md) | [Settings & Customization](ai-guidelines/feature/settings-and-customization.md)

---

## 1. Project Overview & Identity

- **Application Name**: KawalPrayer
- **Bundle Identifier**: `com.outivox.KawalPrayer` (Tests: `com.outivox.KawalPrayerTests`)
- **Platform**: macOS 14.0+ (Sonoma, Sequoia, and newer)
- **Architecture**: Native Swift 5.9 / Swift 6, SwiftUI with `@Observable` macro, AppKit integration (`NSStatusItem`, `NSPopover`, `NSWindowController`).
- **Operating Model**: Pure macOS Background Agent (`LSUIElement = true` in Info.plist). The app resides strictly in the Menu Bar without docking or showing an icon in the macOS Dock or `⌘Tab` app switcher, unless explicitly configured in settings.
- **Design System**: Outivox Design Token System ported directly from [KawalEvent](file:///Users/fachridantm/Library/CloudStorage/OneDrive-uinjkt.ac.id/StudioProjects/KawalEvent) (`ColorToken`, `DimensToken`, `FloatToken`, `OX` facade, `GoogleColorDivider`).

---

## 2. Code Generation & Swift Style Guardrails

- **Zero Raw Literals Rule**:
  - **No raw dimension numbers**: Never hardcode raw numbers for padding, spacing, frame sizes, corner radii, or stroke widths (e.g. `.padding(16)` or `cornerRadius: 8`).
    - Use `OX.Spacing.*` for standard layout spacings.
    - Use `OX.Radius.*` for corner radii.
    - Use `OX.Border.*` for stroke widths.
    - Use `DimensToken.*` for component dimensions (e.g. `DimensToken.SIZE_32`).
  - **No raw opacity floats**: Never use raw float numbers like `0.5`, `0.65`, or `0.85` in `.opacity()`. Use `FloatToken.*` (e.g. `FloatToken.PERCENT_50`, `FloatToken.PERCENT_65`, `FloatToken.PERCENT_85`).
  - **No ad-hoc colors**: Always route colors through `OX.Color.*` (semantic facade) or `ColorToken.*` (palette token).
- **Formatting — Multi-Line Parameters**:
  - If a function call, initializer, or SwiftUI modifier has **more than one argument**, put each parameter on its own line:
    ```swift
    // ✅ Correct
    HStack(
        alignment: .center,
        spacing: OX.Spacing.M
    ) {
        ...
    }

    // ❌ Incorrect
    HStack(alignment: .center, spacing: 12) { ... }
    ```
- **Formatting — Multi-Line Modifier Chains**:
  - Place each SwiftUI modifier on a separate line.
- **Comments & Docstrings**:
  - Preserve all existing documentation and comments. Never delete explanatory notes during refactoring.
- **No Force Unwrapping**:
  - Avoid force unwrapping (`!`) in production application code. Use `guard let`, `if let`, or nil-coalescing (`??`).
- **MainActor Isolation**:
  - `AppState`, UI views, and delegate callbacks affecting UI must be strictly dispatched on `@MainActor`.

---

## 3. Architecture & State Management

- **Single Source of Truth (`AppState`)**:
  - Global observable state is maintained in `@Observable @MainActor final class AppState`.
  - Injected into views via SwiftUI `@Environment(AppState.self)`.
  - All side-effects (timers, audio, notifications, location, calculations) are orchestrated by `AppState` through dedicated singleton services.
- **Service Layer (`Core/Services/`)**:
  - `PrayerTimeCalculator`: Pure astronomical math for prayer times based on coordinates, date, calculation method, and madhab.
  - `QiblaCalculator`: Calculates great circle azimuth to the Kaaba (`21.4225° N, 39.8262° E`).
  - `LocationService`: Wraps `CLLocationManager` with background distance filter monitoring and reverse geocoding.
  - `LocationHelper`: Parses `CLPlacemark` into clean `City, District/Kecamatan` (e.g., `Central Jakarta, Gambir`).
  - `AudioService`: Manages `AVAudioPlayer` playback of Adzan audio with volume scaling and completion delegates.
  - `NotificationService`: Configures actionable `UNNotificationCategory` (`stopAdzan`), schedules upcoming prayer alerts, and sends immediate Adzan alerts with auto-dismissal.
  - `QuranService`: Offline JSON parser for 114 Surahs and 6,236 Ayahs with search and query helpers.

---

## 4. Location & Persistence Rules

- **Persistent City & District Format**:
  - The user's location must always be displayed as `"<City/Locality>, <District/SubLocality>"` (e.g. `Central Jakarta, Gambir`).
  - Whenever location is resolved (automatically via GPS or manually), it must immediately be saved to `UserDefaults` under key `kawal_cached_location`.
  - On app launch, `AppState.loadFromStorage()` must immediately restore `kawal_cached_location` so the user never sees a flickering fallback or generic city.
  - Default coordinates are set to Monas Gambir (`latitude: -6.1754, longitude: 106.8272`).

---

## 5. Verification & Testing Standards

- **Unit Testing**:
  - All business logic, tokens, and calculations must have comprehensive unit tests in `KawalPrayerTests/`.
  - Run tests with:
    ```bash
    DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project KawalPrayer.xcodeproj -scheme KawalPrayer test
    ```
  - 100% test pass rate is mandatory before committing code.
- **Release DMG Packaging**:
  - Production DMG packages must be verified via:
    ```bash
    ./scripts/build_dmg.sh
    ```
  - Outputs `KawalPrayer-v1.0.0.dmg` in the repository root.
