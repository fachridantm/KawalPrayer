import SwiftUI
import UserNotifications

// MARK: - UI Extensions

extension AppTheme {
    var nsAppearance: NSAppearance? {
        switch self {
        case .system: nil
        case .light:  NSAppearance(named: .aqua)
        case .dark:   NSAppearance(named: .darkAqua)
        }
    }
}

extension Color {
    /// Outivox Brand Accent: Google Green in light mode, vibrant GreenHalftone in dark mode.
    static func accent(for scheme: ColorScheme) -> Color {
        scheme == .dark ? ColorToken.GreenHalftone : ColorToken.Green
    }

    /// Outivox Background highlight tint: Green10 in light mode, subtle Green90 tint in dark mode.
    static func accentBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? ColorToken.Green90.opacity(0.40)
            : ColorToken.Green10.opacity(0.80)
    }
}

// MARK: - App Delegate

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {

    private(set) var appState: AppState!
    private var statusBarController: StatusBarController?

    func applicationWillFinishLaunching(_ notification: Notification) {
        // Skip singleton check when running unit tests
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil,
              NSClassFromString("XCTestCase") == nil else {
            return
        }

        // Enforce single instance: if another instance is already running, activate it and exit this process
        let bundleID = Bundle.main.bundleIdentifier ?? "com.outivox.KawalPrayer"
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
        let currentPID = ProcessInfo.processInfo.processIdentifier

        if let existingApp = runningApps.first(where: { $0.processIdentifier != currentPID }) {
            NSLog("[KawalPrayer] Another instance is already running (PID: \(existingApp.processIdentifier)). Activating existing instance and exiting.")
            existingApp.activate(options: [.activateIgnoringOtherApps])
            exit(0)
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        appState = AppState()

        // Apply saved theme appearance
        NSApp.appearance = appState.settings.appTheme.nsAppearance

        // Apply language override
        UserDefaults.standard.set([appState.settings.appLanguage.localeIdentifier], forKey: "AppleLanguages")

        // Set application icon
        if let iconImage = NSImage(named: "AppIcon")
            ?? NSImage(contentsOf: Bundle.main.url(forResource: "NotificationIcon", withExtension: "png") ?? URL(fileURLWithPath: "")) {
            NSApp.applicationIconImage = iconImage
        }

        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self

        // Initialize status bar item and popover
        statusBarController = StatusBarController(appState: appState)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApp.activate(ignoringOtherApps: true)
        if WindowManager.shared.isMainWindowVisible {
            WindowManager.shared.bringMainWindowToFront()
        } else {
            statusBarController?.showPopover()
        }
        return true
    }

    // Handle interactive notification actions (e.g. Stop Adzan from banner, click banner, dismiss)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let action = response.actionIdentifier
        let notifId = response.notification.request.identifier
        NSLog("[KawalPrayer] User clicked notification action: \(action) for id: \(notifId)")

        if action == NotificationService.actionStopAdzan {
            NotificationService.shared.onStopAdzanActionTriggered?()
            NotificationService.shared.dismissAdzanNotification(id: notifId)
        } else if action == NotificationService.actionDismiss || action == UNNotificationDismissActionIdentifier {
            NotificationService.shared.dismissAdzanNotification(id: notifId)
        } else if action == UNNotificationDefaultActionIdentifier {
            // User clicked the notification banner itself:
            // 1. Activate the running app and bring it to front
            NSApp.activate(ignoringOtherApps: true)
            if WindowManager.shared.isMainWindowVisible {
                WindowManager.shared.bringMainWindowToFront()
            } else {
                statusBarController?.showPopover()
            }
            // 2. Dismiss this notification from Notification Center
            NotificationService.shared.dismissAdzanNotification(id: notifId)
        }

        completionHandler()
    }

    // Allow notifications to present banner even when active
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}

// MARK: - App Entry Point

@main
struct KawalPrayerApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // Pure background agent: no top-level windows opened on launch.
        // Windows are opened on demand via WindowManager.
        Settings {
            EmptyView()
        }
    }
}
