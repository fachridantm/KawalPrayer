import SwiftUI

enum MainNavItem: String, CaseIterable, Identifiable {
    case schedule = "Jadwal Sholat"
    case quran    = "Al-Quran"
    case settings = "Pengaturan"
    case about    = "Tentang"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .schedule: "clock.fill"
        case .quran:    "book.fill"
        case .settings: "gearshape.fill"
        case .about:    "info.circle.fill"
        }
    }

    var localizedName: String {
        switch self {
        case .schedule: String(localized: "Jadwal Sholat")
        case .quran:    String(localized: "Al-Quran")
        case .settings: String(localized: "Pengaturan")
        case .about:    String(localized: "Tentang")
        }
    }
}

struct MainWindowView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var selection: MainNavItem = .schedule

    var body: some View {
        NavigationSplitView {
            sidebarView
        } detail: {
            detailView
                .environment(appState)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 680, minHeight: 480)
    }

    // MARK: - Sidebar

    private var sidebarView: some View {
        VStack(spacing: 0) {

            // Branding
            HStack(spacing: 10) {
                Image(systemName: "moon.stars.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accent(for: colorScheme))
                VStack(alignment: .leading, spacing: 2) {
                    Text("KawalPrayer")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(appState.location.cityName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider()

            // Nav items
            VStack(spacing: 4) {
                ForEach(MainNavItem.allCases) { item in
                    SidebarNavRow(
                        item: item,
                        isSelected: selection == item,
                        colorScheme: colorScheme
                    ) {
                        selection = item
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            Spacer(minLength: 0)

            Divider()

            // Close window vs Quit
            HStack {
                Button {
                    WindowManager.shared.closeMainWindow()
                } label: {
                    Label(String(localized: "Tutup Jendela"), systemImage: "xmark.circle")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Spacer()

                Button(role: .destructive) {
                    appState.saveSettingsImmediately()
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label(String(localized: "Keluar"), systemImage: "power")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationSplitViewColumnWidth(min: 190, ideal: 210)
    }

    // MARK: - Detail

    private var detailView: some View {
        ZStack {
            ScheduleDetailView()
                .opacity(selection == .schedule ? 1 : 0)
                .allowsHitTesting(selection == .schedule)

            QuranView(isActive: selection == .quran)
                .opacity(selection == .quran ? 1 : 0)
                .allowsHitTesting(selection == .quran)

            SettingsView(isActive: selection == .settings)
                .opacity(selection == .settings ? 1 : 0)
                .allowsHitTesting(selection == .settings)

            AboutView()
                .opacity(selection == .about ? 1 : 0)
                .allowsHitTesting(selection == .about)
        }
        .navigationTitle(selection.localizedName)
    }
}

// MARK: - Schedule Detail View

private struct ScheduleDetailView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    @State private var islamicDate: String = ""
    @State private var gregorianDate: String = ""
    @State private var cachedDay: Int = 0

    private func refreshDateStrings() {
        let today = Calendar.current.component(.day, from: Date())
        guard today != cachedDay else { return }
        cachedDay = today
        islamicDate = IslamicCalendarHelper.islamicDateString(offsetDays: appState.settings.hijriOffsetDays)
        gregorianDate = Date().formatted(.dateTime.weekday(.wide).day().month(.wide).year())
    }

    private var fardhuPrayers: [PrayerTime] {
        appState.prayerTimes.filter {
            $0.name.isFardhu || ($0.name == .sunrise && appState.settings.showSyuruq)
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            // Date banner: Hijriah (left) + Masehi (right)
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Tanggal Hijriah"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(islamicDate)
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(localized: "Tanggal Masehi"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(gregorianDate)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)

            Divider()

            // Sub-header: City + Qibla + Next Prayer Countdown
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(Color.accent(for: colorScheme))
                    Text(appState.location.cityName)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Button {
                        appState.requestLocationRefresh()
                    } label: {
                        if appState.isLocationRefreshing {
                            ProgressView().controlSize(.mini)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .help(String(localized: "Perbarui Lokasi"))
                }

                Spacer()

                if !appState.nextPrayerName.isEmpty {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(localized: "Berikutnya"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(appState.nextPrayerName)  \(appState.countdownString)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accent(for: colorScheme))
                            .monospacedDigit()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)

            Divider()

            // Prayer list & Qibla Compass
            List {
                QiblaCompassView()
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 4, trailing: 20))

                if appState.showDoaBanner {
                    DuaAfterAdzanView()
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                }
                if case .countdown(let prayerName, let remaining) = appState.iqamahState {
                    IqamahBannerRow(prayerName: prayerName, remaining: remaining)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                }
                if case .finished(let prayerName) = appState.iqamahState {
                    IqamahFinishedRow(prayerName: prayerName, onDismiss: { appState.iqamahState = .idle })
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                }
                ForEach(fardhuPrayers) { prayer in
                    DesktopPrayerRow(prayer: prayer)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                }
            }
            .listStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { refreshDateStrings() }
        .onChange(of: appState.prayerTimes) { refreshDateStrings() }
    }
}

// MARK: - Iqamah Banner Row

private struct IqamahBannerRow: View {

    @Environment(\.colorScheme) private var colorScheme

    let prayerName: String
    let remaining: Int

    var body: some View {
        HStack {
            Image(systemName: "bell.badge.fill")
                .font(.title3)
                .foregroundStyle(Color.accent(for: colorScheme))
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Iqamah \(prayerName)"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(String(format: "%02d:%02d", remaining / 60, remaining % 60))
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.accentBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Iqamah Finished Row

private struct IqamahFinishedRow: View {

    let prayerName: String
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.green)
            Text(String(localized: "Waktu iqamah \(prayerName)!"))
                .font(.subheadline)
                .fontWeight(.semibold)
            Spacer()
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Desktop Prayer Row

private struct DesktopPrayerRow: View {

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
        HStack(spacing: 16) {
            Image(systemName: prayer.name.icon)
                .font(.title3)
                .frame(width: 30)
                .foregroundStyle(rowColor)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(prayer.name.localizedName)
                        .font(.body)
                        .fontWeight(isHighlighted ? .semibold : .regular)

                    if isCurrent {
                        Text(String(localized: "(Aktif)"))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(accentColor)
                    }
                }

                Group {
                    if isCurrent {
                        Text(String(localized: "Waktu sholat saat ini"))
                            .foregroundStyle(accentColor)
                    } else if prayer.isNext {
                        Text(String(localized: "Waktu berikutnya"))
                            .foregroundStyle(accentColor)
                    } else if prayer.isPast {
                        Text(String(localized: "Sudah lewat"))
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(prayer.timeString)
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.medium)
                .foregroundStyle(rowColor)

            Circle()
                .fill(accentColor)
                .frame(width: 8, height: 8)
                .opacity(isHighlighted ? 1 : 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isHighlighted ? Color.accentBackground(for: colorScheme) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .opacity(prayer.isPast && !isCurrent ? 0.65 : 1.0)
    }

    private var accentColor: Color { .accent(for: colorScheme) }

    private var rowColor: Color {
        if isHighlighted { return accentColor }
        if prayer.isPast { return .secondary }
        return .primary
    }
}

// MARK: - About View

private struct AboutView: View {

    @Environment(\.colorScheme) private var colorScheme

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "moon.stars.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.accent(for: colorScheme))

            VStack(spacing: 6) {
                Text("KawalPrayer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(String(localized: "Versi \(appVersion)"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(String(localized: "Aplikasi pengingat waktu sholat dan adzan menu bar untuk macOS.\nBekerja senyap di background tanpa mengganggu dock.\nDilengkapi Al-Quran offline, arah kiblat, doa setelah adzan, dan pengaman waktu Kemenag RI."))
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Divider()
                .padding(.horizontal, 80)

            VStack(spacing: 8) {
                Text(String(localized: "Dibuat dengan SwiftUI & Swift 6"))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Sidebar Nav Row

private struct SidebarNavRow: View {

    let item: MainNavItem
    let isSelected: Bool
    let colorScheme: ColorScheme
    let action: () -> Void

    var body: some View {
        Label(item.localizedName, systemImage: item.icon)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .foregroundStyle(isSelected ? .white : Color.primary.opacity(0.85))
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accent(for: colorScheme) : .clear)
            )
            .contentShape(RoundedRectangle(cornerRadius: 6))
            .onTapGesture(perform: action)
    }
}
