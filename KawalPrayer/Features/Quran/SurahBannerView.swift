import SwiftUI

struct SurahBannerView: View {

    let surah: Surah
    @Environment(\.colorScheme) private var colorScheme

    private var bannerGreen: Color {
        colorScheme == .dark
            ? Color(red: 0.35, green: 0.72, blue: 0.48)
            : Color(red: 0.12, green: 0.45, blue: 0.25)
    }

    private var bannerBackground: Color {
        colorScheme == .dark
            ? Color(red: 0.14, green: 0.16, blue: 0.14).opacity(0.8)
            : Color(red: 0.95, green: 0.96, blue: 0.93)
    }

    var body: some View {
        ZStack {
            // Background fill
            RoundedRectangle(cornerRadius: 6)
                .fill(bannerBackground)

            // Ornamental outer and inner borders
            RoundedRectangle(cornerRadius: 6)
                .stroke(bannerGreen, lineWidth: 1.5)
                .padding(2)

            RoundedRectangle(cornerRadius: 4)
                .stroke(bannerGreen.opacity(0.6), lineWidth: 0.8)
                .padding(5)

            // Decorative Arabesque Pattern & Center Title
            HStack(spacing: 8) {
                // Left Arabesque Flourish
                ArabesqueFlourish(direction: .left, color: bannerGreen)
                    .frame(height: 32)
                    .frame(maxWidth: .infinity)

                // Center Title Cartouche
                HStack(spacing: 6) {
                    Text("﴾")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(bannerGreen)

                    Text(formattedArabicTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(bannerGreen)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("﴿")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(bannerGreen)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(bannerGreen.opacity(0.4), lineWidth: 1)
                        .background(bannerBackground)
                )

                // Right Arabesque Flourish
                ArabesqueFlourish(direction: .right, color: bannerGreen)
                    .frame(height: 32)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 52)
        .padding(.horizontal, 20)
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
