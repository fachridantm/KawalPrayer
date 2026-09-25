import XCTest
@testable import KawalPrayer

final class NotificationTests: XCTestCase {

    func testCategoryAndActionConstants() {
        XCTAssertEqual(NotificationService.categoryPrayerAlert, "PRAYER_ALERT_CATEGORY")
        XCTAssertEqual(NotificationService.actionStopAdzan, "ACTION_STOP_ADZAN")
        XCTAssertEqual(NotificationService.actionDismiss, "ACTION_DISMISS")
    }
}
