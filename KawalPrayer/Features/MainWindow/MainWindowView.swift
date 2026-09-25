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

    func localizedName(for lang: AppLanguage) -> String {
        switch self {
        case .schedule:
            switch lang {
            case .id: "Jadwal Sholat"
            case .en: "Prayer Schedule"
            case .ar: "جدول الصلاة"
            }
        case .quran:
            switch lang {
            case .id: "Al-Quran"
            case .en: "Quran"
            case .ar: "القرآن الكريم"
            }
        case .settings:
            switch lang {
            case .id: "Pengaturan"
            case .en: "Settings"
            case .ar: "الإعدادات"
            }
        case .about:
            switch lang {
            case .id: "Tentang"
            case .en: "About"
            case .ar: "حول"
            }
        }
    }

    var localizedName: String {
        localizedName(for: .id)
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
        .environment(\.locale, appState.settings.appLanguage.locale)
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
                        colorScheme: colorScheme,
                        appLanguage: appState.settings.appLanguage
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
        .navigationTitle(selection.localizedName(for: appState.settings.appLanguage))
    }
}

// MARK: - Schedule Detail View

private struct ScheduleDetailView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    @State private var islamicDate: String = ""
    @State private var gregorianDate: String = ""

    private func refreshDateStrings() {
        islamicDate = IslamicCalendarHelper.islamicDateString(
            offsetDays: appState.settings.hijriOffsetDays,
            lang: appState.settings.appLanguage
        )
        let locale = appState.settings.appLanguage.locale
        gregorianDate = Date().formatted(
            .dateTime.locale(locale).weekday(.wide).day().month(.wide).year()
        )
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
        .onChange(of: appState.settings.appLanguage) { refreshDateStrings() }
        .onChange(of: appState.settings.hijriOffsetDays) { refreshDateStrings() }
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
                    Text(prayer.name.localizedName(for: appState.settings.appLanguage))
                        .font(.body)
                        .fontWeight(isHighlighted ? .semibold : .regular)

                    if isCurrent {
                        Text(appState.settings.appLanguage == .id ? "(Aktif)" : (appState.settings.appLanguage == .en ? "(Active)" : "(نشط)"))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(accentColor)
                    }
                }

                Group {
                    if isCurrent {
                        Text(appState.settings.appLanguage == .id ? "Waktu sholat saat ini" : (appState.settings.appLanguage == .en ? "Current prayer time" : "وقت الصلاة الحالي"))
                            .foregroundStyle(accentColor)
                    } else if prayer.isNext {
                        Text(appState.settings.appLanguage == .id ? "Waktu berikutnya" : (appState.settings.appLanguage == .en ? "Next prayer" : "الصلاة التالية"))
                            .foregroundStyle(accentColor)
                    } else if prayer.isPast {
                        Text(appState.settings.appLanguage == .id ? "Sudah lewat" : (appState.settings.appLanguage == .en ? "Passed" : "انتهى"))
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

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var aboutDescription: String {
        switch appState.settings.appLanguage {
        case .id:
            return "Aplikasi pengingat waktu sholat dan adzan menu bar untuk macOS.\nBekerja senyap di background tanpa mengganggu dock.\nDilengkapi Al-Quran offline, arah kiblat, doa setelah adzan, dan pengaman waktu Kemenag RI."
        case .en:
            return "Menu bar prayer times & adzan app for macOS.\nRuns quietly in the background without cluttering the Dock.\nEquipped with offline Quran, Qibla direction, Dua after Adzan, and safety margin adjustments."
        case .ar:
            return "تطبيق تنبيه مواقيت الصلاة والأذان لشريط القوائم على نظام macOS.\nيعمل في الخلفية بدون الظهور في Dock.\nمزوّد بالقرآن الكريم بدون إنترنت، واتجاه القبلة، والدعاء بعد الأذان، وضوابط مواقيت الصلاة."
        }
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
                Text(appState.settings.appLanguage == .id ? "Versi \(appVersion)" : (appState.settings.appLanguage == .en ? "Version \(appVersion)" : "الإصدار \(appVersion)"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(aboutDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Divider()
                .padding(.horizontal, 80)

            VStack(spacing: 8) {
                Text(appState.settings.appLanguage == .id ? "Dibuat dengan SwiftUI & Swift 6" : (appState.settings.appLanguage == .en ? "Built with SwiftUI & Swift 6" : "تم التطوير باستخدام SwiftUI و Swift 6"))
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
    let appLanguage: AppLanguage
    let action: () -> Void

    var body: some View {
        Label(item.localizedName(for: appLanguage), systemImage: item.icon)
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
