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
        HStack(spacing: 12) {
            Image(systemName: prayer.name.icon)
                .frame(width: 20)
                .foregroundStyle(rowColor)

            HStack(spacing: 5) {
                Text(prayer.name.localizedName(for: appState.settings.appLanguage))
                    .fontWeight(isHighlighted ? .semibold : .regular)
                    .foregroundStyle(prayer.isPast && !isCurrent ? .secondary : .primary)

                if isCurrent {
                    Text(appState.settings.appLanguage == .id ? "(Aktif)" : (appState.settings.appLanguage == .en ? "(Active)" : "(نشط)"))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(accentColor)
                }
            }

            Spacer()

            Text(prayer.timeString)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(rowColor)

            Circle()
                .fill(accentColor)
                .frame(width: 6, height: 6)
                .opacity(isHighlighted ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 9)
        .background(isHighlighted ? Color.accentBackground(for: colorScheme) : Color.clear)
        .opacity(prayer.isPast && !isCurrent ? 0.65 : 1.0)
    }

    private var accentColor: Color { .accent(for: colorScheme) }

    private var rowColor: Color {
        if isHighlighted { return accentColor }
        if prayer.isPast { return .secondary }
        return .primary
    }
}
