import SwiftUI

struct MenuBarView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()

            // Doa setelah adzan banner
            if appState.showDoaBanner {
                DuaAfterAdzanView()
                Divider()
            }

            // Iqamah countdown banner
            if case .countdown(let prayerName, let remaining) = appState.iqamahState {
                iqamahBannerView(prayerName: prayerName, remaining: remaining)
                Divider()
            } else if case .finished(let prayerName) = appState.iqamahState {
                iqamahFinishedBanner(prayerName: prayerName)
                Divider()
            }

            dateAndQiblaBannerView
            Divider()

            PrayerScheduleView()
            Divider()

            footerView
        }
        .frame(width: 360)
        .background(Color(NSColor.windowBackgroundColor))
        .environment(\.locale, appState.settings.appLanguage.locale)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Image(systemName: appState.activeMenuBarIconName)
                        .font(.headline)
                        .foregroundStyle(Color.accent(for: colorScheme))
                    Text("KawalPrayer")
                        .font(.headline)
                        .fontWeight(.bold)
                }

                HStack(spacing: 6) {
                    Text(appState.location.cityName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button {
                        appState.requestLocationRefresh()
                    } label: {
                        if appState.isLocationRefreshing {
                            ProgressView()
                                .controlSize(.mini)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .help(String(localized: "Perbarui Lokasi GPS"))
                }
            }

            Spacer()

            if !appState.nextPrayerName.isEmpty {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(appState.nextPrayerName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(appState.countdownString)
                        .font(.system(.callout, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accent(for: colorScheme))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Iqamah Banner

    private func iqamahBannerView(prayerName: String, remaining: Int) -> some View {
        let minutes = remaining / 60
        let seconds = remaining % 60
        return HStack {
            Image(systemName: "bell.badge.fill")
                .foregroundStyle(Color.accent(for: colorScheme))
            VStack(alignment: .leading, spacing: 1) {
                Text(String(localized: "Iqamah \(prayerName)"))
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(String(format: "%02d:%02d", minutes, seconds))
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.accentBackground(for: colorScheme))
    }

    private func iqamahFinishedBanner(prayerName: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(String(localized: "Waktu iqamah \(prayerName)!"))
                .font(.caption)
                .fontWeight(.semibold)
            Spacer()
            Button {
                appState.iqamahState = .idle
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.1))
    }

    // MARK: - Date & Qibla Banner

    private var dateAndQiblaBannerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Hijriah"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(IslamicCalendarHelper.islamicDateString(offsetDays: appState.settings.hijriOffsetDays, lang: appState.settings.appLanguage))
                    .font(.caption)
                    .fontWeight(.semibold)
            }

            Spacer()

            VStack(alignment: .center, spacing: 2) {
                Text(String(localized: "Arah Kiblat"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                HStack(spacing: 3) {
                    Image(systemName: "safari.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.accent(for: colorScheme))
                    Text(appState.qibla.formattedBearing(for: appState.settings.appLanguage))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(localized: "Masehi"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(Date().formatted(.dateTime.locale(appState.settings.appLanguage.locale).weekday(.abbreviated).day().month(.abbreviated).year()))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            if AudioService.shared.isPlaying {
                Button(String(localized: "Stop Adzan")) {
                    appState.stopAll()
                }
                .foregroundStyle(.red)
                .buttonStyle(.plain)
            }

            Spacer()

            Button {
                StatusBarController.shared?.closePopover()
                WindowManager.shared.showMainWindow(appState: appState)
            } label: {
                Label(String(localized: "Buka KawalPrayer"), systemImage: "macwindow")
            }
            .buttonStyle(.plain)

            Divider()
                .frame(height: 12)
                .padding(.horizontal, 4)

            Button {
                appState.saveSettingsImmediately()
                NSApplication.shared.terminate(nil)
            } label: {
                Label(String(localized: "Keluar"), systemImage: "power")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
