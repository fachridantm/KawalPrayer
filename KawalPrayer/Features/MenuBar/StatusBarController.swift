import AppKit
import SwiftUI

@MainActor
final class StatusBarController: NSObject {

    static var shared: StatusBarController?

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
        super.init()
        Self.shared = self
        setupStatusItem()
        setupPopover()
        observeAppState()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem.button else { return }

        // Template icon adapts automatically to light/dark menu bar
        let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        if let image = NSImage(systemSymbolName: "moon.stars.fill", accessibilityDescription: "KawalPrayer")?.withSymbolConfiguration(config) {
            image.isTemplate = true
            button.image = image
            button.imagePosition = .imageLeading
        }

        button.target = self
        button.action = #selector(togglePopover(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])

        updateStatusItem()
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 480)
        popover.behavior = .transient
        popover.animates = true

        let rootView = MenuBarView()
            .environment(appState)
            .environment(\.locale, appState.settings.appLanguage.locale)

        popover.contentViewController = NSHostingController(rootView: rootView)
    }

    private func observeAppState() {
        appState.onStatusBarTitleChanged = { [weak self] in
            self?.updateStatusItem()
        }

        appState.onShowPopoverRequested = { [weak self] in
            self?.showPopover()
        }
    }

    func updateStatusItem() {
        guard let button = statusItem.button else { return }

        // Dynamic icon based on active current prayer or user settings
        let iconName = appState.activeMenuBarIconName
        let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        if let image = NSImage(systemSymbolName: iconName, accessibilityDescription: "KawalPrayer")?.withSymbolConfiguration(config) {
            image.isTemplate = true
            button.image = image
            button.imagePosition = .imageLeading
        }

        let text = appState.menuBarDisplayText
        if text.isEmpty {
            button.title = ""
        } else {
            // Space between icon and text
            button.title = " \(text)"
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        }
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            // Right-click also toggles popover or can open menu
            if popover.isShown {
                popover.performClose(sender)
            } else {
                showPopover()
            }
        } else {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                showPopover()
            }
        }
    }

    func showPopover() {
        guard let button = statusItem.button else { return }
        if !popover.isShown {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func closePopover() {
        if popover.isShown {
            popover.performClose(nil)
        }
    }
}
