import AppKit
import SwiftUI

/// Presents `DynamicIslandAlert`s in a borderless, non-activating panel pinned to the notch
/// (or top-center on screens without one).
@MainActor
final class DynamicIslandWindowController {

    static let shared = DynamicIslandWindowController()

    private var panel: NSPanel?
    private var currentAlertId: UUID?
    private var dismissWork: DispatchWorkItem?

    private init() {}

    func present(_ alert: DynamicIslandAlert) {
        guard let screen = NSScreen.islandTarget else { return }
        tearDown()
        currentAlertId = alert.id

        let width = DimensToken.ISLAND_WIDTH
        let height = DimensToken.ISLAND_PANEL_HEIGHT
        let frame = NSRect(
            x: screen.frame.midX - width / 2,
            y: screen.frame.maxY - height,
            width: width,
            height: height
        )

        let panel = NSPanel(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = NSWindow.Level(rawValue: NSWindow.Level.mainMenu.rawValue + 1)
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle, .stationary]
        panel.isMovable = false

        let host = NSHostingView(
            rootView: DynamicIslandView(
                alert: alert,
                anchorSize: screen.islandAnchorSize,
                onDismiss: { [weak self] in self?.dismiss(id: alert.id) }
            )
        )
        panel.contentView = host
        panel.orderFrontRegardless()
        self.panel = panel

        if let seconds = alert.autoDismissSeconds {
            let work = DispatchWorkItem { [weak self] in
                self?.dismiss(id: alert.id)
            }
            dismissWork = work
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
        }
    }

    /// Dismisses the current alert; when `id` is given only if it still matches.
    func dismiss(id: UUID? = nil) {
        if let id, id != currentAlertId { return }
        tearDown()
    }

    private func tearDown() {
        dismissWork?.cancel()
        dismissWork = nil
        panel?.orderOut(nil)
        panel = nil
        currentAlertId = nil
    }
}
