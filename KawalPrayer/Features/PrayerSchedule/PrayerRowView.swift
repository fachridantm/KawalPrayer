import SwiftUI

struct PrayerRowView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    let prayer: PrayerTime

    private var isCurrent: Bool {
        appState.currentPrayer?.name == prayer.name
    }

    private var isHighlighted: Bool {
        isCurrent || prayer.isNext
    }

    var body: some View {
        HStack(spacing: OX.Spacing.M) {
            Image(systemName: prayer.name.icon)
                .frame(width: DimensToken.SIZE_20)
                .foregroundStyle(rowColor)

            HStack(spacing: OX.Spacing.XS) {
                Text(prayer.name.localizedName(for: appState.settings.appLanguage))
                    .fontWeight(isHighlighted ? .semibold : .regular)
                    .foregroundStyle(prayer.isPast && !isCurrent ? .secondary : .primary)

                if isCurrent {
                    Text(appState.settings.appLanguage == .id ? "Aktif" : (appState.settings.appLanguage == .en ? "Active" : "نشط"))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, DimensToken.SIZE_6)
                        .padding(.vertical, DimensToken.SIZE_2)
                        .background(Capsule().fill(ColorToken.Green))
                }
            }

            Spacer()

            Text(prayer.timeString)
                .font(.system(.body, design: .monospaced))
                .fontWeight(isHighlighted ? .semibold : .regular)
                .foregroundStyle(rowColor)

            Circle()
                .fill(accentColor)
                .frame(width: DimensToken.SIZE_6, height: DimensToken.SIZE_6)
                .opacity(isHighlighted ? FloatToken.PERCENT_100 : FloatToken.PERCENT_0)
        }
        .padding(.horizontal, OX.Spacing.L)
        .padding(.vertical, DimensToken.SIZE_8)
        .background(
            isHighlighted
                ? RoundedRectangle(cornerRadius: OX.Radius.M)
                    .fill(Color.accentBackground(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: OX.Radius.M)
                            .strokeBorder(
                                isCurrent ? ColorToken.Green.opacity(FloatToken.PERCENT_40) : Color.clear,
                                lineWidth: OX.Border.WIDTH_1
                            )
                    )
                : nil
        )
        .opacity(prayer.isPast && !isCurrent ? FloatToken.PERCENT_60 : FloatToken.PERCENT_100)
    }

    private var accentColor: Color { .accent(for: colorScheme) }

    private var rowColor: Color {
        if isHighlighted { return accentColor }
        if prayer.isPast { return .secondary }
        return .primary
    }
}
