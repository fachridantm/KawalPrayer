import XCTest
@testable import KawalPrayer

final class PrayerTimeCalculatorTests: XCTestCase {

    private let jakarta = LocationModel(
        latitude: -6.2088,
        longitude: 106.8456,
        cityName: "Jakarta",
        timezone: 7.0
    )

    private var testDate: Date {
        var c = DateComponents()
        c.year = 2026; c.month = 3; c.day = 13
        c.hour = 12; c.minute = 0; c.second = 0
        c.timeZone = TimeZone(secondsFromGMT: 7 * 3600)
        return Calendar.current.date(from: c)!
    }

    func testCalculationReturnsAllSixPrayers() {
        let times = PrayerTimeCalculator.calculate(
            for: testDate,
            location: jakarta,
            method: .kemenagRI,
            asrMadhab: .shafii,
            ihtiyatMinutes: 2
        )
        XCTAssertEqual(times.count, 6)
        let names = Set(times.map(\.name))
        let expected: Set<PrayerName> = [.fajr, .sunrise, .dhuhr, .asr, .maghrib, .isha]
        XCTAssertEqual(names, expected)
    }

    func testIhtiyatAddsMinutes() {
        let baseTimes = PrayerTimeCalculator.calculate(
            for: testDate,
            location: jakarta,
            method: .kemenagRI,
            asrMadhab: .shafii,
            ihtiyatMinutes: 0
        )
        let ihtiyatTimes = PrayerTimeCalculator.calculate(
            for: testDate,
            location: jakarta,
            method: .kemenagRI,
            asrMadhab: .shafii,
            ihtiyatMinutes: 2
        )

        let baseFajr = baseTimes.first(where: { $0.name == .fajr })!
        let ihtiyatFajr = ihtiyatTimes.first(where: { $0.name == .fajr })!

        let diff = ihtiyatFajr.time.timeIntervalSince(baseFajr.time)
        XCTAssertEqual(diff, 120.0, accuracy: 1.0, "Ihtiyat +2 menit harus menambahkan 120 detik")
    }

    func testHanafiAsrLaterThanShafii() {
        let shafiiTimes = PrayerTimeCalculator.calculate(
            for: testDate, location: jakarta, method: .kemenagRI, asrMadhab: .shafii
        )
        let hanafiTimes = PrayerTimeCalculator.calculate(
            for: testDate, location: jakarta, method: .kemenagRI, asrMadhab: .hanafi
        )

        let shafiiAsr = shafiiTimes.first(where: { $0.name == .asr })!
        let hanafiAsr = hanafiTimes.first(where: { $0.name == .asr })!

        XCTAssertGreaterThan(hanafiAsr.time, shafiiAsr.time, "Asr Hanafi harus lebih lambat dari Syafi'i")
    }

    func testNextDayFajrCalculation() {
        let nextFajr = PrayerTimeCalculator.calculateNextDayFajr(
            from: testDate,
            location: jakarta,
            method: .kemenagRI,
            asrMadhab: .shafii,
            ihtiyatMinutes: 2
        )

        XCTAssertNotNil(nextFajr)
        XCTAssertEqual(nextFajr?.name, .fajr)
        XCTAssertTrue(nextFajr!.isNext)
        XCTAssertFalse(nextFajr!.isPast)
        XCTAssertGreaterThan(nextFajr!.time, testDate)
    }
}
