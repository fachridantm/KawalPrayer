import AppKit
import SwiftUI

@MainActor
final class WindowManager: NSObject, NSWindowDelegate {

    static let shared = WindowManager()

    private var mainWindow: NSWindow?
    private weak var appState: AppState?

    var isMainWindowVisible: Bool {
        mainWindow?.isVisible == true
    }

    func bringMainWindowToFront() {
        if let window = mainWindow {
            if appState?.settings.showDockWhenWindowOpen == true {
                NSApp.setActivationPolicy(.regular)
            }
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private override init() {
        super.init()
    }

    func showMainWindow(appState: AppState) {
        self.appState = appState

        if let window = mainWindow {
            if appState.settings.showDockWhenWindowOpen {
                NSApp.setActivationPolicy(.regular)
            }
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = MainWindowView()
            .environment(appState)
            .environment(\.locale, appState.settings.appLanguage.locale)

        let window = NSWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: 1060,
                height: 700
            ),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable
            ],
            backing: .buffered,
            defer: false
        )

        window.title = "KawalPrayer"
        window.minSize = NSSize(
            width: 820,
            height: 540
        )
        window.isReleasedWhenClosed = false
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.center()
        window.delegate = self
        window.contentViewController = NSHostingController(rootView: contentView)

        mainWindow = window

        if appState.settings.showDockWhenWindowOpen {
            NSApp.setActivationPolicy(.regular)
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeMainWindow() {
        mainWindow?.orderOut(nil)
        if appState?.settings.showDockWhenWindowOpen == true {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    /// Dynamically enforces comfortable geometry when switching tabs
    func adjustWindowSize(for item: MainNavItem) {
        guard let window = mainWindow else { return }

        if item == .quran {
            window.minSize = NSSize(
                width: 980,
                height: 600
            )

            if window.frame.width < 1040 || window.frame.height < 660 {
                let targetWidth = max(window.frame.width, 1060)
                let targetHeight = max(window.frame.height, 700)
                var newFrame = window.frame
                let deltaH = targetHeight - newFrame.height
                newFrame.origin.y -= deltaH
                newFrame.size = NSSize(width: targetWidth, height: targetHeight)
                window.setFrame(newFrame, display: true, animate: true)
            }
        } else {
            window.minSize = NSSize(
                width: 820,
                height: 540
            )
        }
    }

    // MARK: - NSWindowDelegate

    func windowWillClose(_ notification: Notification) {
        if appState?.settings.showDockWhenWindowOpen == true {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}
