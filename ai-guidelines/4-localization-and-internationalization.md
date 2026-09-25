# 4. Localization & Internationalization

KawalPrayer is fully localized for three primary languages:
- **Bahasa Indonesia (`.id`)** — Default
- **English (`.en`)**
- **Arabic (`.ar`)** — With Right-to-Left (RTL) Arabic typography and Mushaf support

---

## 1. Supported Languages (`AppLanguage`)

Defined in `Core/Models/PrayerSettings.swift`:
```swift
enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case id = "id"
    case en = "en"
    case ar = "ar"

    var displayName: String {
        switch self {
        case .id: "Bahasa Indonesia"
        case .en: "English"
        case .ar: "العربية"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }
}
```

---

## 2. Localization Implementation Pattern

1. **String Catalogs & `String(localized:)`**:
   - UI strings utilize standard Apple `String(localized: "...")` with keys defined in Indonesian.
2. **Explicit Enums Localized Methods**:
   - Models like `PrayerName`, `MenuBarDisplayMode`, and `MainNavItem` implement `localizedName(for lang: AppLanguage) -> String`:
   ```swift
   func localizedName(for lang: AppLanguage) -> String {
       switch self {
       case .fajr:
           switch lang {
           case .id: "Subuh"
           case .en: "Fajr"
           case .ar: "الفجر"
           }
       ...
       }
   }
   ```
3. **Arabic RTL Text Support**:
   - Quran ayahs and Arabic dua texts apply:
     ```swift
     .environment(\.layoutDirection, .rightToLeft)
     ```
   - Arabic fonts use Apple's native **"Geeza Pro"** or system serif/arabic font.

---

## 3. Islamic Hijri Calendar (`IslamicCalendarHelper.swift`)

- Calculates the Hijri date using `Calendar(identifier: .islamicUmmAlQura)`.
- Supports user-configurable `hijriOffsetDays` (±2 days) to match official government moon-sighting (Ru'yatul Hilal) announcements.
- Formatted via `islamicDateString(offsetDays:lang:)`.
