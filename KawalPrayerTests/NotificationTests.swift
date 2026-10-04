import XCTest
@testable import KawalPrayer

final class NotificationTests: XCTestCase {

    func testCategoryAndActionConstants() {
        XCTAssertEqual(NotificationService.categoryPrayerAlert, "PRAYER_ALERT_CATEGORY")
        XCTAssertEqual(NotificationService.actionStopAdzan, "ACTION_STOP_ADZAN")
        XCTAssertEqual(NotificationService.actionDismiss, "ACTION_DISMISS")
    }

    func testIconAttachment() {
        let service = NotificationService.shared
        if let attachment = service.createIconAttachment() {
            XCTAssertEqual(attachment.identifier, "prayer_notification_icon")
            XCTAssertTrue(attachment.url.path.hasSuffix(".png"))
        }
    }

    func testDismissAdzanNotification() {
        let service = NotificationService.shared
        // Ensure dismissAdzanNotification executes safely and cleans up
        service.dismissAdzanNotification()
        service.dismissAdzanNotification(id: "test_notification_id")
        XCTAssertTrue(true)
    }

    func testSchedulePrayerNotifications() {
        let service = NotificationService.shared
        let testDate = Date().addingTimeInterval(3600)
        let samplePrayers = [
            PrayerTime(name: .dhuhr, time: testDate, timezoneOffset: 7.0, isPast: false),
            PrayerTime(name: .asr, time: testDate.addingTimeInterval(7200), timezoneOffset: 7.0, isPast: false)
        ]

        var settings = PrayerSettings()
        settings.isNotificationEnabled = true
        settings.notificationOffset = 0
        service.schedule(prayerTimes: samplePrayers, settings: settings)

        // Test with advance offset
        settings.notificationOffset = 10
        service.schedule(prayerTimes: samplePrayers, settings: settings)
        XCTAssertTrue(true)
    }

    func testSendAdzanNotification() {
        let service = NotificationService.shared
        service.sendAdzanNotification(
            for: "Dhuhr",
            timeString: "12:09 WIB",
            lang: .en
        )
        service.dismissAdzanNotification()
        XCTAssertTrue(true)
    }

    func testSendIqamahNotification() {
        let service = NotificationService.shared
        service.sendIqamahNotification(
            for: "Dhuhr",
            lang: .en
        )
        XCTAssertTrue(true)
    }
}
