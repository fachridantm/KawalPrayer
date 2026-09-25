import SwiftUI

struct QiblaCompassView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: OX.Spacing.L) {
            ZStack {
                Circle()
                    .strokeBorder(
                        OX.Color.outline(for: colorScheme),
                        lineWidth: OX.Border.WIDTH_2
                    )
                    .frame(
                        width: DimensToken.SIZE_52,
                        height: DimensToken.SIZE_52
                    )

                // Compass Rose markers
                Text(appState.settings.appLanguage == .id ? "U" : (appState.settings.appLanguage == .en ? "N" : "ش"))
                    .font(.system(
                        size: DimensToken.SIZE_8,
                        weight: .bold
                    ))
                    .foregroundStyle(.secondary)
                    .offset(y: -DimensToken.SIZE_20)

                // Kaaba needle
                Image(systemName: "location.north.fill")
                    .font(.system(size: DimensToken.SIZE_20))
                    .foregroundStyle(ColorToken.Green)
                    .rotationEffect(.degrees(appState.qibla.degrees))
            }

            VStack(
                alignment: .leading,
                spacing: DimensToken.SIZE_4
            ) {
                Text(appState.settings.appLanguage == .id ? "Arah Kiblat" : (appState.settings.appLanguage == .en ? "Qibla Direction" : "اتجاه القبلة"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(appState.qibla.formattedBearing(for: appState.settings.appLanguage))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(ColorToken.Green)

                Text(appState.settings.appLanguage == .id
                    ? "Koordinat: \(String(format: "%.4f", appState.location.latitude)), \(String(format: "%.4f", appState.location.longitude))"
                    : (appState.settings.appLanguage == .en
                        ? "Coordinates: \(String(format: "%.4f", appState.location.latitude)), \(String(format: "%.4f", appState.location.longitude))"
                        : "الإحداثيات: \(String(format: "%.4f", appState.location.latitude))، \(String(format: "%.4f", appState.location.longitude))"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(DimensToken.SIZE_14)
        .background(
            RoundedRectangle(cornerRadius: OX.Radius.L)
                .fill(Color.accentBackground(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: OX.Radius.L)
                        .strokeBorder(
                            OX.Color.outline(for: colorScheme),
                            lineWidth: OX.Border.WIDTH_1
                        )
                )
        )
    }
}
