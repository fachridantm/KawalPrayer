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
        let prayerIds = PrayerName.allCases.flatMap { [
            "prayer_\($0.rawValue)",
            "reminder_\($0.rawValue)",
            "adzan_\($0.rawValue)"
        ] }
        center.removePendingNotificationRequests(withIdentifiers: prayerIds)
        setupNotificationCategories(for: settings.appLanguage)

        let now = Date()

        for prayer in prayerTimes where prayer.name.isFardhu && !prayer.isPast && !settings.mutedPrayers.contains(prayer.name) {
            let pName = prayer.name.localizedName(for: settings.appLanguage)

            // 1. Advance reminder notification if offset is configured (> 0) and in the future
            if settings.notificationOffset > 0 {
                let reminderDate = prayer.time.addingTimeInterval(-Double(settings.notificationOffset) * 60)
                if reminderDate > now {
                    let reminderContent = UNMutableNotificationContent()
                    switch settings.appLanguage {
                    case .id:
                        reminderContent.title = "Pengingat \(pName)"
                        reminderContent.body = "\(settings.notificationOffset) menit menuju \(pName) — \(prayer.timeString)"
                    case .en:
                        reminderContent.title = "\(pName) Reminder"
                        reminderContent.body = "\(settings.notificationOffset) minutes until \(pName) — \(prayer.timeString)"
                    case .ar:
                        reminderContent.title = "تذكير صلاة \(pName)"
                        reminderContent.body = "\(settings.notificationOffset) دقائق حتى صلاة \(pName) — \(prayer.timeString)"
                    }

                    reminderContent.sound = nil
                    reminderContent.categoryIdentifier = Self.categoryPrayerAlert
                    if let attachment = createIconAttachment() {
                        reminderContent.attachments = [attachment]
                    }

                    let reminderTrigger = UNCalendarNotificationTrigger(
                        dateMatching: Calendar.current.dateComponents(
                            [.hour, .minute, .second],
                            from: reminderDate
                        ),
                        repeats: false
                    )

                    let reminderRequest = UNNotificationRequest(
                        identifier: "reminder_\(prayer.name.rawValue)",
                        content: reminderContent,
                        trigger: reminderTrigger
                    )

                    center.add(reminderRequest) { error in
                        if let error {
                            NSLog("[KawalPrayer] Reminder schedule error \(prayer.name.rawValue): \(error.localizedDescription)")
                        }
                    }
                }
            }

            // 2. Exact prayer time alert (always fires at prayer.time)
            guard prayer.time > now else { continue }

            let content = UNMutableNotificationContent()
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
            if let attachment = createIconAttachment() {
                content.attachments = [attachment]
            }

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    [.hour, .minute, .second],
                    from: prayer.time
                ),
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
        if let attachment = createIconAttachment() {
            content.attachments = [attachment]
        }

        // Use deterministic prayer identifier to prevent multiple duplicate banners for the same prayer
        let notifId = "adzan_\(prayerName)"
        activeAdzanNotificationIds.insert(notifId)

        let center = UNUserNotificationCenter.current()
        // Remove any previously scheduled or delivered notifications to avoid duplicates
        let scheduledIds = PrayerName.allCases.flatMap { [
            "prayer_\($0.rawValue)",
            "reminder_\($0.rawValue)",
            "adzan_\($0.rawValue)"
        ] }
        center.removePendingNotificationRequests(withIdentifiers: scheduledIds)
        center.removeDeliveredNotifications(withIdentifiers: scheduledIds)

        let request = UNNotificationRequest(
            identifier: notifId,
            content: content,
            trigger: nil
        )

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
        let scheduledIds = PrayerName.allCases.flatMap { [
            "prayer_\($0.rawValue)",
            "reminder_\($0.rawValue)",
            "adzan_\($0.rawValue)"
        ] }
        var idsToRemove = Set(scheduledIds)
        idsToRemove.formUnion(activeAdzanNotificationIds)
        if let id {
            idsToRemove.insert(id)
        }

        let idsArray = Array(idsToRemove)
        center.removeDeliveredNotifications(withIdentifiers: idsArray)
        center.removePendingNotificationRequests(withIdentifiers: idsArray)

        if let id {
            activeAdzanNotificationIds.remove(id)
        } else {
            activeAdzanNotificationIds.removeAll()
        }

        // Catch any delivered notifications by category or prefix
        center.getDeliveredNotifications { notifications in
            let alertIds = notifications.filter { notif in
                notif.request.content.categoryIdentifier == Self.categoryPrayerAlert
                || notif.request.identifier.hasPrefix("adzan_")
                || notif.request.identifier.hasPrefix("prayer_")
                || notif.request.identifier.hasPrefix("reminder_")
            }.map { $0.request.identifier }

            if !alertIds.isEmpty {
                center.removeDeliveredNotifications(withIdentifiers: alertIds)
            }
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
        if let attachment = createIconAttachment() {
            content.attachments = [attachment]
        }

        let id = "iqamah_\(prayerName)_\(Int(Date().timeIntervalSince1970))"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)

        let center = UNUserNotificationCenter.current()
        center.add(request) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                center.removeDeliveredNotifications(withIdentifiers: [id])
            }
        }
    }

    // MARK: - Notification Icon Attachment

    func createIconAttachment() -> UNNotificationAttachment? {
        let bundleURL = Bundle.main.url(forResource: "NotificationIcon", withExtension: "png")
            ?? Bundle(for: NotificationService.self).url(forResource: "NotificationIcon", withExtension: "png")

        guard let sourceURL = bundleURL else {
            return nil
        }

        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("notif_icon_\(UUID().uuidString).png")
        do {
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: tempURL)
            return try UNNotificationAttachment(
                identifier: "prayer_notification_icon",
                url: tempURL,
                options: nil
            )
        } catch {
            NSLog("[KawalPrayer] Failed to create notification icon attachment: \(error.localizedDescription)")
            return nil
        }
    }

    func cancelAll() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        activeAdzanNotificationIds.removeAll()
    }
}
