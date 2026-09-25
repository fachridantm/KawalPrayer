import XCTest
@testable import KawalPrayer

final class LocalizationTests: XCTestCase {

    func testPrayerNamesLocalizedInEnglish() {
        XCTAssertEqual(PrayerName.fajr.localizedName(for: .en), "Fajr")
        XCTAssertEqual(PrayerName.sunrise.localizedName(for: .en), "Sunrise")
        XCTAssertEqual(PrayerName.dhuhr.localizedName(for: .en), "Dhuhr")
        XCTAssertEqual(PrayerName.asr.localizedName(for: .en), "Asr")
        XCTAssertEqual(PrayerName.maghrib.localizedName(for: .en), "Maghrib")
        XCTAssertEqual(PrayerName.isha.localizedName(for: .en), "Isha")
    }

    func testPrayerNamesLocalizedInIndonesian() {
        XCTAssertEqual(PrayerName.fajr.localizedName(for: .id), "Subuh")
        XCTAssertEqual(PrayerName.sunrise.localizedName(for: .id), "Syuruq")
        XCTAssertEqual(PrayerName.dhuhr.localizedName(for: .id), "Dzuhur")
        XCTAssertEqual(PrayerName.asr.localizedName(for: .id), "Ashar")
        XCTAssertEqual(PrayerName.maghrib.localizedName(for: .id), "Maghrib")
        XCTAssertEqual(PrayerName.isha.localizedName(for: .id), "Isya")
    }

    func testMenuBarDisplayModeEnglish() {
        let mode = MenuBarDisplayMode.iconNameCountdown
        XCTAssertEqual(mode.localizedName(for: .en), "Icon + Name + Countdown (Default)")
        XCTAssertEqual(mode.samplePreview(for: .en), "Fajr • 00:45")

        let iconOnly = MenuBarDisplayMode.iconOnly
        XCTAssertEqual(iconOnly.localizedName(for: .en), "Icon Only")
        XCTAssertEqual(iconOnly.samplePreview(for: .en), "(Icon Only)")
    }

    func testMenuBarIconSourceEnglish() {
        XCTAssertEqual(MenuBarIconSource.currentPrayer.localizedName(for: .en), "Current / Active Prayer Icon (Default)")
        XCTAssertEqual(MenuBarIconSource.nextPrayer.localizedName(for: .en), "Next Prayer Icon (Target)")
        XCTAssertEqual(MenuBarIconSource.staticMoon.localizedName(for: .en), "Static Moon & Stars Icon")
    }

    func testDuaModelEnglish() {
        let firstDua = Dua.all[0]
        XCTAssertEqual(firstDua.title(for: .en), "Supplication After the Call to Prayer (Adzan) — Sahih al-Bukhari")
        XCTAssertTrue(firstDua.translation(for: .en).contains("O Allah, Lord of this perfect call"))

        XCTAssertEqual(firstDua.title(for: .id), "Doa Setelah Adzan — HR. Bukhari")
        XCTAssertTrue(firstDua.translation(for: .id).contains("Ya Allah, Tuhan pemilik seruan yang sempurna ini"))
    }

    func testIslamicCalendarHelperEnglish() {
        let date = Date()
        let idStr = IslamicCalendarHelper.islamicDateString(for: date, offsetDays: 0, lang: .id)
        let enStr = IslamicCalendarHelper.islamicDateString(for: date, offsetDays: 0, lang: .en)

        XCTAssertTrue(idStr.hasSuffix(" H"), "Indonesian Hijri date should end with ' H'")
        XCTAssertTrue(enStr.hasSuffix(" AH"), "English Hijri date should end with ' AH'")
    }
}
