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
    /// Accent color: Islamic Forest Green (#007200) in light mode, Warm Orange in dark mode.
    static func accent(for scheme: ColorScheme) -> Color {
        scheme == .light ? Color(red: 0, green: 0.447, blue: 0) : .orange
    }
    /// Background highlight row tint
    static func accentBackground(for scheme: ColorScheme) -> Color {
        scheme == .light ? Color(red: 0.941, green: 0.969, blue: 0.933) : .orange.opacity(0.08)
    }
}

// MARK: - App Delegate

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {

    private(set) var appState = AppState()
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Apply saved theme appearance
        NSApp.appearance = appState.settings.appTheme.nsAppearance

        // Apply language override
        UserDefaults.standard.set([appState.settings.appLanguage.localeIdentifier], forKey: "AppleLanguages")

        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self

        // Initialize status bar item and popover
        statusBarController = StatusBarController(appState: appState)
    }

    // Handle interactive notification actions (e.g. Stop Adzan from banner)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let action = response.actionIdentifier
        NSLog("[KawalPrayer] User clicked notification action: \(action)")

        if action == NotificationService.actionStopAdzan {
            NotificationService.shared.onStopAdzanActionTriggered?()
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
