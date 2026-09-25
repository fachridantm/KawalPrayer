import AppKit
import SwiftUI

@MainActor
final class WindowManager: NSObject, NSWindowDelegate {

    static let shared = WindowManager()

    private var mainWindow: NSWindow?
    private weak var appState: AppState?

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

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 740, height: 540),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "KawalPrayer"
        window.minSize = NSSize(width: 640, height: 460)
        window.isReleasedWhenClosed = false
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

    // MARK: - NSWindowDelegate

    func windowWillClose(_ notification: Notification) {
        if appState?.settings.showDockWhenWindowOpen == true {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}
