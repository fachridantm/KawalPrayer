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
