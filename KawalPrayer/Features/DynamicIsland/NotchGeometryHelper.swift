import AppKit

extension NSScreen {

    /// `true` when the display has a physical camera housing (notch).
    var hasPhysicalNotch: Bool {
        safeAreaInsets.top > 0
    }

    /// Frame of the physical notch in global screen coordinates, if present.
    var notchFrame: CGRect? {
        guard hasPhysicalNotch,
              let left = auxiliaryTopLeftArea,
              let right = auxiliaryTopRightArea else {
            return nil
        }
        return CGRect(
            x: left.maxX,
            y: frame.maxY - safeAreaInsets.top,
            width: right.minX - left.maxX,
            height: safeAreaInsets.top
        )
    }

    /// Size of the notch, or a pill-sized fallback for screens without one.
    var islandAnchorSize: CGSize {
        if let notch = notchFrame {
            return notch.size
        }
        return CGSize(
            width: DimensToken.ISLAND_FALLBACK_NOTCH_W,
            height: DimensToken.ISLAND_FALLBACK_NOTCH_H
        )
    }

    /// Preferred screen: the one with a notch, otherwise the main screen.
    static var islandTarget: NSScreen? {
        NSScreen.screens.first(where: { $0.hasPhysicalNotch }) ?? NSScreen.main
    }
}
