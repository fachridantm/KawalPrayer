import XCTest
@testable import KawalPrayer

final class IqamahTests: XCTestCase {

    func testIqamahStateValues() {
        let idle = IqamahState.idle
        XCTAssertFalse(idle.isActive)

        let countdown = IqamahState.countdown(prayerName: "Subuh", remaining: 300)
        XCTAssertTrue(countdown.isActive)

        let finished = IqamahState.finished(prayerName: "Subuh")
        XCTAssertTrue(finished.isActive)
    }

    func testMenuBarDisplayModeDefault() {
        let settings = PrayerSettings()
        XCTAssertEqual(settings.menuBarDisplayMode, .iconNameCountdown)
        XCTAssertEqual(settings.ihtiyatMinutes, 2)
    }
}
