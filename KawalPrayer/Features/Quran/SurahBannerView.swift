import SwiftUI

struct SurahBannerView: View {

    let surah: Surah
    @Environment(\.colorScheme) private var colorScheme

    private var bannerGreen: Color {
        colorScheme == .dark ? ColorToken.GreenHalftone : ColorToken.Green
    }

    private var bannerBackground: Color {
        colorScheme == .dark ? ColorToken.DarkGrey10 : ColorToken.Green10.opacity(0.60)
    }

    var body: some View {
        ZStack {
            // Background fill
            RoundedRectangle(cornerRadius: OX.Radius.S)
                .fill(bannerBackground)

            // Ornamental outer and inner borders
            RoundedRectangle(cornerRadius: OX.Radius.S)
                .stroke(bannerGreen, lineWidth: OX.Border.WIDTH_1_5)
                .padding(DimensToken.SIZE_2)

            RoundedRectangle(cornerRadius: OX.Radius.XS)
                .stroke(bannerGreen.opacity(FloatToken.PERCENT_60), lineWidth: OX.Border.WIDTH_1)
                .padding(DimensToken.SIZE_4)

            // Decorative Arabesque Pattern & Center Title
            HStack(spacing: OX.Spacing.S) {
                // Left Arabesque Flourish
                ArabesqueFlourish(direction: .left, color: bannerGreen)
                    .frame(height: DimensToken.SIZE_32)
                    .frame(maxWidth: .infinity)

                // Center Title Cartouche
                HStack(spacing: OX.Spacing.XS2) {
                    Text("﴾")
                        .font(.system(size: DimensToken.SIZE_20, weight: .light))
                        .foregroundStyle(bannerGreen)

                    Text(formattedArabicTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(bannerGreen)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("﴿")
                        .font(.system(size: DimensToken.SIZE_20, weight: .light))
                        .foregroundStyle(bannerGreen)
                }
                .padding(.horizontal, DimensToken.SIZE_14)
                .padding(.vertical, DimensToken.SIZE_4)
                .background(
                    RoundedRectangle(cornerRadius: OX.Radius.L)
                        .strokeBorder(bannerGreen.opacity(FloatToken.PERCENT_40), lineWidth: OX.Border.WIDTH_1)
                        .background(bannerBackground)
                )

                // Right Arabesque Flourish
                ArabesqueFlourish(direction: .right, color: bannerGreen)
                    .frame(height: DimensToken.SIZE_32)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, OX.Spacing.M)
        }
        .frame(height: DimensToken.SIZE_52)
        .padding(.horizontal, OX.Spacing.XL)
    }

    private var formattedArabicTitle: String {
        var name = surah.arabicName
        if !name.hasPrefix("سُورَةُ") && !name.hasPrefix("سورة") {
            name = "سُورَةُ \(name)"
        }
        return name
    }
}

// MARK: - Arabesque Flourish Pattern

private struct ArabesqueFlourish: View {
    enum Direction { case left, right }

    let direction: Direction
    let color: Color

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let midY = h / 2.0

            var path = Path()

            // Main horizontal vine line
            path.move(to: CGPoint(x: 0, y: midY))
            path.addLine(to: CGPoint(x: w, y: midY))

            // Upper & Lower wave curls
            let curlStep: CGFloat = 20
            var x: CGFloat = 8
            var toggle = true

            while x + curlStep <= w - 8 {
                let cpY = toggle ? midY - 9 : midY + 9
                path.move(to: CGPoint(x: x, y: midY))
                path.addQuadCurve(
                    to: CGPoint(x: x + curlStep, y: midY),
                    control: CGPoint(x: x + curlStep / 2, y: cpY)
                )

                // Small decorative leaf / diamond
                let leafY = toggle ? midY - 6 : midY + 6
                let leafRect = CGRect(x: x + curlStep / 2 - 2, y: leafY - 2, width: 4, height: 4)
                context.fill(Path(ellipseIn: leafRect), with: .color(color.opacity(0.8)))

                x += curlStep
                toggle.toggle()
            }

            context.stroke(path, with: .color(color.opacity(0.7)), lineWidth: 1.0)
        }
        .scaleEffect(x: direction == .right ? -1 : 1, y: 1)
    }
}
