import SwiftUI

struct QiblaCompassView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 2)
                    .frame(width: 52, height: 52)

                // Compass Rose markers
                Text("U")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.secondary)
                    .offset(y: -20)

                // Kaaba needle
                Image(systemName: "location.north.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.accent(for: colorScheme))
                    .rotationEffect(.degrees(appState.qibla.degrees))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(String(localized: "Arah Kiblat"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(appState.qibla.formattedBearing)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accent(for: colorScheme))

                Text(String(localized: "Koordinat: \(String(format: "%.4f", appState.location.latitude)), \(String(format: "%.4f", appState.location.longitude))"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.accentBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
