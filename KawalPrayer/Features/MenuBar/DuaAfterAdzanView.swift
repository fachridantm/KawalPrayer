import SwiftUI

struct DuaAfterAdzanView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: DimensToken.SIZE_8) {
            HStack {
                Image(systemName: "hands.and.sparkles.fill")
                    .foregroundStyle(Color.accent(for: colorScheme))

                Text(String(localized: "Doa Setelah Adzan"))
                    .font(.caption)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    appState.dismissDoaBanner()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            ForEach(
                Array(appState.currentDuas.enumerated()),
                id: \.offset
            ) { _, dua in
                VStack(spacing: DimensToken.SIZE_6) {
                    Text(dua.title(for: appState.settings.appLanguage))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.accent(for: colorScheme))

                    Text(dua.arabic)
                        .font(.system(size: DimensToken.SIZE_14))
                        .multilineTextAlignment(.center)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                        .environment(\.layoutDirection, .rightToLeft)

                    Text(dua.transliteration)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    Text(dua.translation(for: appState.settings.appLanguage))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .italic()
                        .multilineTextAlignment(.center)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
            }
        }
        .padding(DimensToken.SIZE_12)
        .background(
            RoundedRectangle(cornerRadius: OX.Radius.M)
                .fill(Color.accentBackground(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: OX.Radius.M)
                        .strokeBorder(
                            OX.Color.outline(for: colorScheme),
                            lineWidth: OX.Border.WIDTH_1
                        )
                )
        )
        .padding(.horizontal, DimensToken.SIZE_12)
        .padding(.vertical, DimensToken.SIZE_6)
    }
}
