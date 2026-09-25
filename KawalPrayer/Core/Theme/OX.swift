import SwiftUI

public enum OX {

    // MARK: - Spacing Scale (Matching BaseOxboxSpacing in KawalEvent)

    public enum Spacing {
        public static let None = DimensToken.SIZE_0   // 0.dp
        public static let XS2  = DimensToken.SIZE_2   // 2.dp
        public static let XS   = DimensToken.SIZE_4   // 4.dp
        public static let S    = DimensToken.SIZE_8   // 8.dp
        public static let M    = DimensToken.SIZE_12  // 12.dp
        public static let L    = DimensToken.SIZE_16  // 16.dp
        public static let XL   = DimensToken.SIZE_20  // 20.dp
        public static let XL2  = DimensToken.SIZE_24  // 24.dp
        public static let XL3  = DimensToken.SIZE_28  // 28.dp
        public static let XL4  = DimensToken.SIZE_32  // 32.dp
    }

    // MARK: - Radius Scale (Matching BaseOxboxRadius in KawalEvent)

    public enum Radius {
        public static let XS   = DimensToken.SIZE_4   // 4.dp
        public static let S    = DimensToken.SIZE_8   // 8.dp
        public static let M    = DimensToken.SIZE_12  // 12.dp
        public static let L    = DimensToken.SIZE_16  // 16.dp
        public static let XL   = DimensToken.SIZE_20  // 20.dp
        public static let XL2  = DimensToken.SIZE_24  // 24.dp
        public static let FULL: CGFloat = 999.0       // Pill/Capsule shape
    }

    // MARK: - Border Width (Matching BaseOxboxBorderWidth in KawalEvent)

    public enum Border {
        public static let WIDTH_0_5: CGFloat = 0.5
        public static let WIDTH_1: CGFloat   = DimensToken.SIZE_1
        public static let WIDTH_1_5: CGFloat = 1.5
        public static let WIDTH_2: CGFloat   = DimensToken.SIZE_2
    }

    // MARK: - Semantic Color Facade

    public enum Color {
        // Brand Primary (Outivox Green for KawalPrayer identity)
        public static let primary            = ColorToken.Green
        public static let onPrimary          = SwiftUI.Color.white

        // Brand Accents
        public static let secondary          = ColorToken.Blue
        public static let onSecondary        = SwiftUI.Color.white
        public static let tertiary           = ColorToken.Yellow
        public static let error              = ColorToken.Red

        // Dynamic Surfaces (adapts to Light/Dark)
        public static func surface(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark ? ColorToken.DarkGrey10 : SwiftUI.Color.white
        }

        public static func surfaceVariant(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark ? ColorToken.DarkGrey20 : ColorToken.LightGrey20
        }

        public static func background(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark ? ColorToken.fromHex(0x141414) : ColorToken.LightGrey10
        }

        public static func outline(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark ? ColorToken.DarkGrey30 : ColorToken.InputBorder
        }

        public static func outlineVariant(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark ? ColorToken.DarkGrey40 : ColorToken.LightGrey30
        }

        public static func onSurface(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark ? ColorToken.LightGrey10 : ColorToken.Black90
        }

        public static func onSurfaceVariant(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark ? ColorToken.LightGrey60 : ColorToken.TextSecondary
        }

        // Active Prayer Highlight
        public static func prayerActive(for scheme: ColorScheme) -> SwiftUI.Color {
            ColorToken.Green
        }

        public static func prayerActiveContainer(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark
                ? ColorToken.Green90.opacity(FloatToken.PERCENT_40)
                : ColorToken.Green10.opacity(FloatToken.PERCENT_85)
        }

        // Next Prayer Highlight
        public static func nextPrayer(for scheme: ColorScheme) -> SwiftUI.Color {
            ColorToken.Blue
        }

        public static func nextPrayerContainer(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark
                ? ColorToken.Blue90.opacity(FloatToken.PERCENT_40)
                : ColorToken.Blue10.opacity(FloatToken.PERCENT_85)
        }

        // Iqamah / Urgent Alert Highlight
        public static func iqamahAlert(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark ? ColorToken.RedHalftone : ColorToken.Red
        }

        public static func iqamahContainer(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark
                ? ColorToken.Red90.opacity(FloatToken.PERCENT_40)
                : ColorToken.Red10.opacity(FloatToken.PERCENT_85)
        }

        public static func iqamahBorder(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark
                ? ColorToken.Red.opacity(FloatToken.PERCENT_40)
                : ColorToken.Red.opacity(FloatToken.PERCENT_30)
        }

        // Iqamah Finished Highlight
        public static func iqamahFinishedContainer(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark
                ? ColorToken.Green90.opacity(FloatToken.PERCENT_40)
                : ColorToken.Green10.opacity(FloatToken.PERCENT_85)
        }

        public static func iqamahFinishedBorder(for scheme: ColorScheme) -> SwiftUI.Color {
            scheme == .dark
                ? ColorToken.Green.opacity(FloatToken.PERCENT_40)
                : ColorToken.Green.opacity(FloatToken.PERCENT_30)
        }
    }
}
