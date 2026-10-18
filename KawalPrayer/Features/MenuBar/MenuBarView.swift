import SwiftUI

struct MenuBarView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: DimensToken.SIZE_0) {
            // Outivox Signature Brand Color Divider
            GoogleColorDivider(thickness: DimensToken.SIZE_3)

            headerView
            Divider()

            // Update banner / button
            if appState.updateService.isUpdateAvailable {
                updateBannerView
                Divider()
            }

            // Doa setelah adzan banner
            if appState.showDoaBanner {
                DuaAfterAdzanView()
                Divider()
            }

            // Iqamah countdown banner
            if case .countdown(let prayerName, let remaining) = appState.iqamahState {
                iqamahBannerView(
                    prayerName: prayerName,
                    remaining: remaining
                )
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
        .frame(width: DimensToken.SIZE_80 * 4 + DimensToken.SIZE_40)
        .background(OX.Color.surface(for: colorScheme))
        .environment(\.locale, appState.settings.appLanguage.locale)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(
                alignment: .leading,
                spacing: DimensToken.SIZE_2
            ) {
                HStack(spacing: DimensToken.SIZE_6) {
                    Image(systemName: appState.activeMenuBarIconName)
                        .font(.headline)
                        .foregroundStyle(Color.accent(for: colorScheme))
                    Text("KawalPrayer")
                        .font(.headline)
                        .fontWeight(.bold)
                }

                HStack(spacing: DimensToken.SIZE_6) {
                    Text(appState.location.cityName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Button {
                        appState.requestLocationRefresh()
                    } label: {
                        if appState.isLocationRefreshing {
                            ProgressView()
                                .controlSize(.mini)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: DimensToken.SIZE_10))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .help(String(localized: "Perbarui Lokasi GPS"))
                }
            }

            Spacer()

            if !appState.nextPrayerName.isEmpty {
                VStack(
                    alignment: .trailing,
                    spacing: DimensToken.SIZE_2
                ) {
                    Text(appState.nextPrayerName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(appState.countdownString)
                        .font(.system(.callout, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundStyle(ColorToken.Blue)
                }
            }
        }
        .padding(.horizontal, OX.Spacing.L)
        .padding(.vertical, DimensToken.SIZE_12)
    }

    // MARK: - Iqamah Banner

    private func iqamahBannerView(prayerName: String, remaining: Int) -> some View {
        let minutes = remaining / 60
        let seconds = remaining % 60
        return HStack(spacing: DimensToken.SIZE_10) {
            Image(systemName: "bell.badge.fill")
                .foregroundStyle(OX.Color.iqamahAlert(for: colorScheme))
            VStack(
                alignment: .leading,
                spacing: DimensToken.SIZE_2
            ) {
                Text(String(localized: "Iqamah \(prayerName)"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(OX.Color.onSurface(for: colorScheme))
                Text(String(format: "%02d:%02d", minutes, seconds))
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundStyle(OX.Color.iqamahAlert(for: colorScheme))
            }
            Spacer()
        }
        .padding(.horizontal, DimensToken.SIZE_12)
        .padding(.vertical, DimensToken.SIZE_8)
        .background(
            RoundedRectangle(cornerRadius: OX.Radius.M)
                .fill(OX.Color.iqamahContainer(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: OX.Radius.M)
                        .strokeBorder(
                            OX.Color.iqamahBorder(for: colorScheme),
                            lineWidth: OX.Border.WIDTH_1
                        )
                )
        )
        .padding(.horizontal, DimensToken.SIZE_12)
        .padding(.vertical, DimensToken.SIZE_6)
    }

    private func iqamahFinishedBanner(prayerName: String) -> some View {
        HStack(spacing: DimensToken.SIZE_10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.accent(for: colorScheme))
            Text(String(localized: "Waktu iqamah \(prayerName)!"))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(OX.Color.onSurface(for: colorScheme))
            Spacer()
            Button {
                appState.iqamahState = .idle
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DimensToken.SIZE_12)
        .padding(.vertical, DimensToken.SIZE_8)
        .background(
            RoundedRectangle(cornerRadius: OX.Radius.M)
                .fill(OX.Color.iqamahFinishedContainer(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: OX.Radius.M)
                        .strokeBorder(
                            OX.Color.iqamahFinishedBorder(for: colorScheme),
                            lineWidth: OX.Border.WIDTH_1
                        )
                )
        )
        .padding(.horizontal, DimensToken.SIZE_12)
        .padding(.vertical, DimensToken.SIZE_6)
    }

    // MARK: - Date & Qibla Banner

    private var dateAndQiblaBannerView: some View {
        HStack {
            VStack(
                alignment: .leading,
                spacing: DimensToken.SIZE_2
            ) {
                Text(String(localized: "Hijriah"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(IslamicCalendarHelper.islamicDateString(
                    offsetDays: appState.settings.hijriOffsetDays,
                    lang: appState.settings.appLanguage
                ))
                .font(.caption)
                .fontWeight(.semibold)
            }

            Spacer()

            VStack(
                alignment: .center,
                spacing: DimensToken.SIZE_2
            ) {
                Text(String(localized: "Arah Kiblat"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                HStack(spacing: DimensToken.SIZE_4) {
                    Image(systemName: "safari.fill")
                        .font(.caption2)
                        .foregroundStyle(ColorToken.Green)
                    Text(appState.qibla.formattedBearing(for: appState.settings.appLanguage))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }

            Spacer()

            VStack(
                alignment: .trailing,
                spacing: DimensToken.SIZE_2
            ) {
                Text(String(localized: "Masehi"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(Date().formatted(
                    .dateTime
                        .locale(appState.settings.appLanguage.locale)
                        .weekday(.abbreviated)
                        .day()
                        .month(.abbreviated)
                        .year()
                ))
                .font(.caption)
                .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, OX.Spacing.L)
        .padding(.vertical, OX.Spacing.S)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            if AudioService.shared.isPlaying {
                Button(String(localized: "Stop Adzan")) {
                    appState.stopAll()
                }
                .foregroundStyle(ColorToken.Red)
                .buttonStyle(.plain)
            }

            Spacer()

            Button {
                StatusBarController.shared?.closePopover()
                WindowManager.shared.showMainWindow(appState: appState)
            } label: {
                Label(
                    String(localized: "Buka KawalPrayer"),
                    systemImage: "macwindow"
                )
            }
            .buttonStyle(.plain)

            Divider()
                .frame(height: DimensToken.SIZE_12)
                .padding(.horizontal, DimensToken.SIZE_4)

            Button {
                appState.saveSettingsImmediately()
                NSApplication.shared.terminate(nil)
            } label: {
                Label(
                    String(localized: "Keluar"),
                    systemImage: "power"
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, OX.Spacing.L)
        .padding(.vertical, DimensToken.SIZE_10)
    }

    // MARK: - Update Banner

    private var updateBannerView: some View {
        HStack(spacing: OX.Spacing.M) {
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .font(.title3)
                .foregroundStyle(Color.accent(for: colorScheme))

            VStack(
                alignment: .leading,
                spacing: DimensToken.SIZE_2
            ) {
                HStack(spacing: DimensToken.SIZE_4) {
                    Text(String(localized: "Update Available"))
                        .font(.caption)
                        .fontWeight(.bold)
                    if let version = appState.updateService.latestRelease?.version {
                        Text("v\(version)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                updateStatusSubtitle
            }

            Spacer()

            updateActionButton
        }
        .padding(.horizontal, OX.Spacing.L)
        .padding(.vertical, OX.Spacing.S)
        .background(Color.accentBackground(for: colorScheme))
    }

    @ViewBuilder
    private var updateStatusSubtitle: some View {
        switch appState.updateService.status {
        case .downloading(let progress):
            HStack(spacing: DimensToken.SIZE_4) {
                ProgressView(
                    value: progress,
                    total: FloatToken.PERCENT_100
                )
                .progressViewStyle(.linear)
                .frame(width: DimensToken.SIZE_80)

                Text(String(format: "%.0f%%", progress * 100))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        case .readyToInstall:
            Text(String(localized: "Ready to install"))
                .font(.caption2)
                .foregroundStyle(ColorToken.Green)
        default:
            Text(String(localized: "New version ready to download"))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var updateActionButton: some View {
        switch appState.updateService.status {
        case .downloading:
            ProgressView()
                .controlSize(.small)
        case .readyToInstall(_, let localPath):
            Button {
                appState.updateService.installUpdate(localURL: localPath)
            } label: {
                Text(String(localized: "Install"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, OX.Spacing.S)
                    .padding(.vertical, DimensToken.SIZE_4)
                    .background(ColorToken.Green)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: OX.Radius.S))
            }
            .buttonStyle(.plain)
        default:
            Button {
                if let release = appState.updateService.latestRelease {
                    Task {
                        await appState.updateService.downloadUpdate(release: release)
                    }
                }
            } label: {
                Text(String(localized: "Update"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, OX.Spacing.M)
                    .padding(.vertical, DimensToken.SIZE_4)
                    .background(Color.accent(for: colorScheme))
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: OX.Radius.S))
            }
            .buttonStyle(.plain)
        }
    }
}

