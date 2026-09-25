import Foundation

enum AsrMadhab: String, Codable, CaseIterable {
    case shafii = "Syafi'i"
    case hanafi = "Hanafi"

    var shadowFactor: Double {
        switch self {
        case .shafii: 1.0
        case .hanafi: 2.0
        }
    }
}

enum AppTheme: String, Codable, CaseIterable {
    case system = "Sistem"
    case light  = "Terang"
    case dark   = "Gelap"

    var icon: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light:  "sun.max.fill"
        case .dark:   "moon.fill"
        }
    }

    var localizedName: String {
        localizedName(for: .id)
    }

    func localizedName(for lang: AppLanguage) -> String {
        switch self {
        case .system:
            switch lang {
            case .id: "Sistem"
            case .en: "System"
            case .ar: "النظام"
            }
        case .light:
            switch lang {
            case .id: "Terang"
            case .en: "Light"
            case .ar: "فاتح"
            }
        case .dark:
            switch lang {
            case .id: "Gelap"
            case .en: "Dark"
            case .ar: "داكن"
            }
        }
    }
}

enum MenuBarDisplayMode: String, Codable, CaseIterable, Identifiable {
    case iconNameCountdown = "icon_name_countdown"
    case iconCountdown     = "icon_countdown"
    case iconName          = "icon_name"
    case iconTime          = "icon_time"
    case iconOnly          = "icon_only"

    var id: String { rawValue }

    var localizedName: String {
        localizedName(for: .id)
    }

    func localizedName(for lang: AppLanguage) -> String {
        switch self {
        case .iconNameCountdown:
            switch lang {
            case .id: "Icon + Nama + Hitung Mundur (Default)"
            case .en: "Icon + Name + Countdown (Default)"
            case .ar: "أيقونة + الاسم + العد التنازلي (افتراضي)"
            }
        case .iconCountdown:
            switch lang {
            case .id: "Icon + Hitung Mundur"
            case .en: "Icon + Countdown"
            case .ar: "أيقونة + العد التنازلي"
            }
        case .iconName:
            switch lang {
            case .id: "Icon + Nama Sholat"
            case .en: "Icon + Prayer Name"
            case .ar: "أيقونة + اسم الصلاة"
            }
        case .iconTime:
            switch lang {
            case .id: "Icon + Waktu Sholat"
            case .en: "Icon + Prayer Time"
            case .ar: "أيقونة + وقت الصلاة"
            }
        case .iconOnly:
            switch lang {
            case .id: "Hanya Icon"
            case .en: "Icon Only"
            case .ar: "أيقونة فقط"
            }
        }
    }

    var samplePreview: String {
        samplePreview(for: .id)
    }

    func samplePreview(for lang: AppLanguage) -> String {
        let prayer = lang == .id ? "Subuh" : (lang == .en ? "Fajr" : "الفجر")
        switch self {
        case .iconNameCountdown: return "\(prayer) • 00:45"
        case .iconCountdown:     return "00:45"
        case .iconName:          return prayer
        case .iconTime:          return "\(prayer) 04:35"
        case .iconOnly:
            return ""
        }
    }
}

enum MenuBarIconSource: String, Codable, CaseIterable, Identifiable {
    case currentPrayer = "current_prayer"
    case nextPrayer    = "next_prayer"
    case staticMoon    = "static_moon"

    var id: String { rawValue }

    var localizedName: String {
        localizedName(for: .id)
    }

    func localizedName(for lang: AppLanguage) -> String {
        switch self {
        case .currentPrayer:
            switch lang {
            case .id: "Ikon Sholat Saat Ini / Aktif (Default)"
            case .en: "Current / Active Prayer Icon (Default)"
            case .ar: "أيقونة الصلاة الحالية / النشطة (افتراضي)"
            }
        case .nextPrayer:
            switch lang {
            case .id: "Ikon Sholat Berikutnya (Target)"
            case .en: "Next Prayer Icon (Target)"
            case .ar: "أيقونة الصلاة القادمة (الهدف)"
            }
        case .staticMoon:
            switch lang {
            case .id: "Tetap Ikon Bulan Bintang"
            case .en: "Static Moon & Stars Icon"
            case .ar: "أيقونة الهلال والنجوم الثابتة"
            }
        }
    }
}

enum CalculationMethod: String, Codable, CaseIterable {
    case kemenagRI = "Kemenag RI"
    case mwl       = "Muslim World League"
    case isna      = "ISNA"
    case ummAlQura = "Umm al-Qura"
    case egypt     = "Egyptian"

    var fajrAngle: Double {
        switch self {
        case .kemenagRI: 20.0
        case .mwl:       18.0
        case .isna:      15.0
        case .ummAlQura: 18.5
        case .egypt:     19.5
        }
    }

    var ishaAngle: Double? {
        switch self {
        case .kemenagRI: 18.0
        case .mwl:       17.0
        case .isna:      15.0
        case .ummAlQura: nil
        case .egypt:     17.5
        }
    }

    var ishaInterval: Double { 90.0 }

    var localizedName: String {
        localizedName(for: .id)
    }

    func localizedName(for lang: AppLanguage) -> String {
        switch self {
        case .kemenagRI: "Kemenag RI"
        case .mwl:       "Muslim World League"
        case .isna:      "ISNA"
        case .ummAlQura: "Umm al-Qura"
        case .egypt:
            switch lang {
            case .id: "Egyptian (Mesir)"
            case .en: "Egyptian General Authority"
            case .ar: "الهيئة المصرية العامة للمساحة"
            }
        }
    }
}

enum AppLanguage: String, Codable, CaseIterable {
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

    var localeIdentifier: String { rawValue }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    var bundle: Bundle {
        if let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return Bundle.main
    }

    static var systemDefault: AppLanguage {
        guard let preferred = Locale.preferredLanguages.first else { return .id }
        let lang = String(preferred.prefix(2))
        return AppLanguage(rawValue: lang) ?? .id
    }
}

enum QuranViewMode: String, Codable, CaseIterable, Identifiable {
    case mushaf     = "mushaf"
    case verseList  = "verse_list"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .mushaf: "book.pages.fill"
        case .verseList: "list.bullet.rectangle.portrait.fill"
        }
    }

    var localizedName: String {
        localizedName(for: .id)
    }

    func localizedName(for lang: AppLanguage) -> String {
        switch self {
        case .mushaf:
            switch lang {
            case .id: "Tampilan Mushaf"
            case .en: "Mushaf View"
            case .ar: "عرض المصحف"
            }
        case .verseList:
            switch lang {
            case .id: "Tampilan Per Ayat"
            case .en: "Verse by Verse"
            case .ar: "آية بآية"
            }
        }
    }
}

struct PrayerSettings: Codable, Equatable {
    var isSoundEnabled          : Bool                    = true
    var isNotificationEnabled   : Bool                    = true
    var isCountdownEnabled      : Bool                    = true
    var menuBarDisplayMode      : MenuBarDisplayMode      = .iconNameCountdown
    var menuBarIconSource       : MenuBarIconSource       = .currentPrayer
    var useAutoLocation         : Bool                    = true
    var notificationOffset      : Int                     = 0
    var appTheme                : AppTheme                = .system
    var launchAtLogin           : Bool                    = false
    var mutedPrayers            : Set<PrayerName>         = []
    var selectedSound           : String                  = "adzan_makkah"
    var calculationMethod       : CalculationMethod       = .kemenagRI
    var ihtiyatMinutes          : Int                     = 2
    var manualOffsets           : [String: Int]           = [:]
    var showSyuruq              : Bool                    = false
    var asrMadhab               : AsrMadhab               = .shafii
    var showDuaAfterAdzan       : Bool                    = true
    var duaDismissSeconds       : Int                     = 30
    var iqamahEnabled           : Bool                    = true
    var iqamahDurationMinutes   : Int                     = 5
    var appLanguage             : AppLanguage             = AppLanguage.systemDefault
    var hijriOffsetDays         : Int                     = 0
    var adzanVolume             : Double                  = 1.0
    var showDockWhenWindowOpen  : Bool                    = false
    var quranLastSurahId        : Int?                    = nil
    var quranArabicFontSize     : Double                  = 26
    var quranBookmarks          : [String]                = []
    var quranViewMode           : QuranViewMode           = .mushaf

    var locale: Locale {
        appLanguage.locale
    }

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        isSoundEnabled          = try c.decodeIfPresent(Bool.self,                  forKey: .isSoundEnabled)          ?? true
        isNotificationEnabled   = try c.decodeIfPresent(Bool.self,                  forKey: .isNotificationEnabled)   ?? true
        isCountdownEnabled      = try c.decodeIfPresent(Bool.self,                  forKey: .isCountdownEnabled)      ?? true
        menuBarDisplayMode      = try c.decodeIfPresent(MenuBarDisplayMode.self,    forKey: .menuBarDisplayMode)      ?? .iconNameCountdown
        menuBarIconSource       = try c.decodeIfPresent(MenuBarIconSource.self,     forKey: .menuBarIconSource)       ?? .currentPrayer
        useAutoLocation         = try c.decodeIfPresent(Bool.self,                  forKey: .useAutoLocation)         ?? true
        notificationOffset      = try c.decodeIfPresent(Int.self,                   forKey: .notificationOffset)      ?? 0
        appTheme                = try c.decodeIfPresent(AppTheme.self,              forKey: .appTheme)                ?? .system
        launchAtLogin           = try c.decodeIfPresent(Bool.self,                  forKey: .launchAtLogin)           ?? false
        mutedPrayers            = try c.decodeIfPresent(Set<PrayerName>.self,       forKey: .mutedPrayers)            ?? []
        selectedSound           = try c.decodeIfPresent(String.self,                forKey: .selectedSound)           ?? "adzan_makkah"
        calculationMethod       = try c.decodeIfPresent(CalculationMethod.self,     forKey: .calculationMethod)       ?? .kemenagRI
        ihtiyatMinutes          = try c.decodeIfPresent(Int.self,                   forKey: .ihtiyatMinutes)          ?? 2
        manualOffsets           = try c.decodeIfPresent([String: Int].self,         forKey: .manualOffsets)           ?? [:]
        showSyuruq              = try c.decodeIfPresent(Bool.self,                  forKey: .showSyuruq)              ?? false
        asrMadhab               = try c.decodeIfPresent(AsrMadhab.self,             forKey: .asrMadhab)               ?? .shafii
        showDuaAfterAdzan       = try c.decodeIfPresent(Bool.self,                  forKey: .showDuaAfterAdzan)       ?? true
        duaDismissSeconds       = try c.decodeIfPresent(Int.self,                   forKey: .duaDismissSeconds)       ?? 30
        iqamahEnabled           = try c.decodeIfPresent(Bool.self,                  forKey: .iqamahEnabled)           ?? true
        iqamahDurationMinutes   = try c.decodeIfPresent(Int.self,                   forKey: .iqamahDurationMinutes)   ?? 5
        appLanguage             = try c.decodeIfPresent(AppLanguage.self,           forKey: .appLanguage)             ?? AppLanguage.systemDefault
        hijriOffsetDays         = try c.decodeIfPresent(Int.self,                   forKey: .hijriOffsetDays)         ?? 0
        adzanVolume             = try c.decodeIfPresent(Double.self,                forKey: .adzanVolume)             ?? 1.0
        showDockWhenWindowOpen  = try c.decodeIfPresent(Bool.self,                  forKey: .showDockWhenWindowOpen)  ?? false
        quranLastSurahId        = try c.decodeIfPresent(Int.self,                   forKey: .quranLastSurahId)
        quranArabicFontSize     = try c.decodeIfPresent(Double.self,                forKey: .quranArabicFontSize)     ?? 26
        quranBookmarks          = try c.decodeIfPresent([String].self,              forKey: .quranBookmarks)          ?? []
        quranViewMode           = try c.decodeIfPresent(QuranViewMode.self,         forKey: .quranViewMode)           ?? .mushaf
    }
}
