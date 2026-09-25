import Foundation
import UserNotifications

final class NotificationService: NSObject {

    static let shared = NotificationService()

    static let categoryPrayerAlert = "PRAYER_ALERT_CATEGORY"
    static let actionStopAdzan     = "ACTION_STOP_ADZAN"
    static let actionDismiss       = "ACTION_DISMISS"

    var onStopAdzanActionTriggered: (() -> Void)?
    private var activeAdzanNotificationIds: Set<String> = []

    private override init() {
        super.init()
        setupNotificationCategories()
    }

    // MARK: - Setup & Categories

    func setupNotificationCategories(for lang: AppLanguage = .id) {
        let stopTitle: String
        let dismissTitle: String
        switch lang {
        case .id:
            stopTitle = "Hentikan Adzan"
            dismissTitle = "Tutup"
        case .en:
            stopTitle = "Stop Adzan"
            dismissTitle = "Dismiss"
        case .ar:
            stopTitle = "إيقاف الأذان"
            dismissTitle = "إغلاق"
        }

        let stopAction = UNNotificationAction(
            identifier: Self.actionStopAdzan,
            title: stopTitle,
            options: [] // executes in background without activating full app
        )

        let dismissAction = UNNotificationAction(
            identifier: Self.actionDismiss,
            title: dismissTitle,
            options: [.destructive]
        )

        let category = UNNotificationCategory(
            identifier: Self.categoryPrayerAlert,
            actions: [stopAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - Permissions

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            setupNotificationCategories()
            return granted
        } catch {
            return false
        }
    }

    // MARK: - Schedule Prayers

    func schedule(prayerTimes: [PrayerTime], settings: PrayerSettings) {
        guard settings.isNotificationEnabled else { return }

        let center = UNUserNotificationCenter.current()
        let prayerIds = PrayerName.allCases.map { "prayer_\($0.rawValue)" }
        center.removePendingNotificationRequests(withIdentifiers: prayerIds)
        setupNotificationCategories(for: settings.appLanguage)

        for prayer in prayerTimes where prayer.name.isFardhu && !prayer.isPast && !settings.mutedPrayers.contains(prayer.name) {
            let content = UNMutableNotificationContent()
            let pName = prayer.name.localizedName(for: settings.appLanguage)
            switch settings.appLanguage {
            case .id:
                content.title = "Waktu \(pName)"
                content.body = "Saatnya \(pName) — \(prayer.timeString)"
            case .en:
                content.title = "\(pName) Time"
                content.body = "Time for \(pName) — \(prayer.timeString)"
            case .ar:
                content.title = "وقت صلاة \(pName)"
                content.body = "حان وقت صلاة \(pName) — \(prayer.timeString)"
            }

            content.sound = nil // Audio handled by AudioService
            content.categoryIdentifier = Self.categoryPrayerAlert

            var fireDate = prayer.time
            if settings.notificationOffset > 0 {
                fireDate = prayer.time.addingTimeInterval(-Double(settings.notificationOffset) * 60)
            }

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.hour, .minute, .second], from: fireDate),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "prayer_\(prayer.name.rawValue)",
                content: content,
                trigger: trigger
            )
            center.add(request) { error in
                if let error {
                    NSLog("[KawalPrayer] Schedule error \(prayer.name.rawValue): \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Adzan Notification (Real-time with interactive actions)

    func sendAdzanNotification(for prayerName: String, timeString: String, lang: AppLanguage = .id) {
        setupNotificationCategories(for: lang)
        let content = UNMutableNotificationContent()
        switch lang {
        case .id:
            content.title = "Waktu \(prayerName)"
            content.body = "Saatnya \(prayerName) — \(timeString)"
        case .en:
            content.title = "\(prayerName) Time"
            content.body = "Time for \(prayerName) — \(timeString)"
        case .ar:
            content.title = "وقت صلاة \(prayerName)"
            content.body = "حان وقت صلاة \(prayerName) — \(timeString)"
        }
        content.sound = nil
        content.categoryIdentifier = Self.categoryPrayerAlert

        let notifId = "adzan_\(prayerName)_\(Int(Date().timeIntervalSince1970))"
        activeAdzanNotificationIds.insert(notifId)

        let request = UNNotificationRequest(
            identifier: notifId,
            content: content,
            trigger: nil
        )

        let center = UNUserNotificationCenter.current()
        center.add(request) { [weak self] error in
            if let error {
                NSLog("[KawalPrayer] Adzan notification error: \(error.localizedDescription)")
            } else {
                NSLog("[KawalPrayer] Adzan notification delivered: \(notifId)")
                // Auto-dismiss safety timeout: 4 minutes if not dismissed by adzan finish
                DispatchQueue.main.asyncAfter(deadline: .now() + 240) {
                    self?.dismissAdzanNotification(id: notifId)
                }
            }
        }
    }

    // MARK: - Dismissal

    func dismissAdzanNotification(id: String? = nil) {
        let center = UNUserNotificationCenter.current()
        if let id {
            center.removeDeliveredNotifications(withIdentifiers: [id])
            center.removePendingNotificationRequests(withIdentifiers: [id])
            activeAdzanNotificationIds.remove(id)
        } else {
            let ids = Array(activeAdzanNotificationIds)
            center.removeDeliveredNotifications(withIdentifiers: ids)
            center.removePendingNotificationRequests(withIdentifiers: ids)
            activeAdzanNotificationIds.removeAll()
        }
    }

    // MARK: - Iqamah Notification

    func sendIqamahNotification(for prayerName: String, lang: AppLanguage = .id) {
        let content = UNMutableNotificationContent()
        switch lang {
        case .id:
            content.title = "Iqamah \(prayerName) Selesai"
            content.body = "Saatnya mendirikan sholat"
        case .en:
            content.title = "\(prayerName) Iqamah Completed"
            content.body = "Time to establish prayer"
        case .ar:
            content.title = "انتهت إقامة صلاة \(prayerName)"
            content.body = "حان وقت إقامة الصلاة"
        }
        content.sound = .default

        let id = "iqamah_\(prayerName)_\(Int(Date().timeIntervalSince1970))"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)

        let center = UNUserNotificationCenter.current()
        center.add(request) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                center.removeDeliveredNotifications(withIdentifiers: [id])
            }
        }
    }

    func cancelAll() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        activeAdzanNotificationIds.removeAll()
    }
}
