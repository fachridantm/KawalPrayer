import SwiftUI

/// Kind of alert shown in the Notch / Dynamic Island HUD.
enum DynamicIslandAlertKind {
    case adzan
    case reminder
    case iqamah

    var icon: String {
        switch self {
        case .adzan:    "speaker.wave.3.fill"
        case .reminder: "bell.fill"
        case .iqamah:   "moon.stars.fill"
        }
    }

    var accent: Color {
        switch self {
        case .adzan:    ColorToken.Green
        case .reminder: ColorToken.Yellow
        case .iqamah:   ColorToken.Blue
        }
    }
}

/// Unified content model presented by `DynamicIslandWindowController`.
struct DynamicIslandAlert: Identifiable {
    let id = UUID()
    let kind: DynamicIslandAlertKind
    let title: String
    let body: String
    var actionTitle: String? = nil
    var dismissTitle: String = ""
    var onAction: (() -> Void)? = nil
    /// `nil` keeps the alert visible until dismissed manually / by adzan end.
    var autoDismissSeconds: TimeInterval? = nil
}

/// Layout constants for the island (no raw literals in views).
extension DimensToken {
    static let ISLAND_WIDTH: CGFloat       = 380.0
    static let ISLAND_HEIGHT: CGFloat      = 130.0
    static let ISLAND_PANEL_HEIGHT: CGFloat = 160.0
    static let ISLAND_FALLBACK_NOTCH_W: CGFloat = 160.0
    static let ISLAND_FALLBACK_NOTCH_H: CGFloat = 32.0
}
