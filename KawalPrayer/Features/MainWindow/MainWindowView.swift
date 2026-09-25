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
        VStack(spacing: DimensToken.SIZE_0) {

            // Branding
            HStack(spacing: DimensToken.SIZE_10) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: DimensToken.SIZE_32,
                        height: DimensToken.SIZE_32
                    )
                    .clipShape(RoundedRectangle(cornerRadius: OX.Radius.S))

                VStack(
                    alignment: .leading,
                    spacing: DimensToken.SIZE_2
                ) {
                    Text("KawalPrayer")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(appState.location.cityName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(.horizontal, OX.Spacing.L)
            .padding(.vertical, DimensToken.SIZE_14)

            GoogleColorDivider()

            // Nav items
            VStack(spacing: DimensToken.SIZE_4) {
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
            .padding(.horizontal, OX.Spacing.M)
            .padding(.top, OX.Spacing.M)

            Spacer(minLength: DimensToken.SIZE_0)

            Divider()

            // Close window vs Quit
            HStack {
                Button {
                    WindowManager.shared.closeMainWindow()
                } label: {
                    Label(
                        String(localized: "Tutup Jendela"),
                        systemImage: "xmark.circle"
                    )
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Spacer()

                Button(role: .destructive) {
                    appState.saveSettingsImmediately()
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label(
                        String(localized: "Keluar"),
                        systemImage: "power"
                    )
                }
                .buttonStyle(.plain)
                .foregroundStyle(ColorToken.Red)
            }
            .padding(.horizontal, OX.Spacing.L)
            .padding(.vertical, OX.Spacing.M)
        }
        .navigationSplitViewColumnWidth(
            min: DimensToken.SIZE_80 * 2 + DimensToken.SIZE_30,
            ideal: DimensToken.SIZE_80 * 2 + DimensToken.SIZE_50
        )
    }

    // MARK: - Detail

    private var detailView: some View {
        @Bindable var appState = appState

        return ZStack {
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
        .toolbar {
            if selection == .quran {
                ToolbarItemGroup(placement: .primaryAction) {
                    Picker(
                        "",
                        selection: $appState.settings.quranViewMode
                    ) {
                        Label(
                            String(localized: "Mushaf"),
                            systemImage: "book.pages.fill"
                        )
                        .tag(QuranViewMode.mushaf)

                        Label(
                            String(localized: "Per Ayat"),
                            systemImage: "list.bullet.rectangle.portrait.fill"
                        )
                        .tag(QuranViewMode.verseList)
                    }
                    .pickerStyle(.segmented)
                    .help(String(localized: "Pilihan Tampilan Al-Quran"))

                    HStack(spacing: DimensToken.SIZE_6) {
                        Image(systemName: "textformat.size.smaller")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Slider(
                            value: $appState.settings.quranArabicFontSize,
                            in: 18...42,
                            step: 1
                        )
                        .frame(width: DimensToken.SIZE_80)
                        .onChange(of: appState.settings.quranArabicFontSize) {
                            appState.saveSettingsImmediately()
                        }

                        Image(systemName: "textformat.size.larger")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .help(String(localized: "Ukuran Huruf Arab"))
                }
            }
        }
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
                VStack(
                    alignment: .leading,
                    spacing: DimensToken.SIZE_2
                ) {
                    Text(String(localized: "Tanggal Hijriah"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(islamicDate)
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(
                    alignment: .trailing,
                    spacing: DimensToken.SIZE_2
                ) {
                    Text(String(localized: "Tanggal Masehi"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(gregorianDate)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, OX.Spacing.XL2)
            .padding(.vertical, DimensToken.SIZE_14)

            Divider()

            // Sub-header: City + Qibla + Next Prayer Countdown
            HStack(alignment: .center) {
                HStack(spacing: DimensToken.SIZE_6) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(ColorToken.Green)
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
                    VStack(
                        alignment: .trailing,
                        spacing: DimensToken.SIZE_2
                    ) {
                        Text(String(localized: "Berikutnya"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(appState.nextPrayerName)  \(appState.countdownString)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(ColorToken.Blue)
                            .monospacedDigit()
                    }
                }
            }
            .padding(.horizontal, OX.Spacing.XL2)
            .padding(.vertical, DimensToken.SIZE_10)

            Divider()

            // Prayer list & Qibla Compass
            List {
                QiblaCompassView()
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(
                        top: DimensToken.SIZE_8,
                        leading: DimensToken.SIZE_20,
                        bottom: DimensToken.SIZE_4,
                        trailing: DimensToken.SIZE_20
                    ))

                if appState.showDoaBanner {
                    DuaAfterAdzanView()
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(
                            top: DimensToken.SIZE_4,
                            leading: DimensToken.SIZE_8,
                            bottom: DimensToken.SIZE_4,
                            trailing: DimensToken.SIZE_8
                        ))
                }
                if case .countdown(let prayerName, let remaining) = appState.iqamahState {
                    IqamahBannerRow(prayerName: prayerName, remaining: remaining)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(
                            top: DimensToken.SIZE_4,
                            leading: DimensToken.SIZE_20,
                            bottom: DimensToken.SIZE_4,
                            trailing: DimensToken.SIZE_20
                        ))
                }
                if case .finished(let prayerName) = appState.iqamahState {
                    IqamahFinishedRow(prayerName: prayerName, onDismiss: { appState.iqamahState = .idle })
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(
                            top: DimensToken.SIZE_4,
                            leading: DimensToken.SIZE_20,
                            bottom: DimensToken.SIZE_4,
                            trailing: DimensToken.SIZE_20
                        ))
                }
                ForEach(fardhuPrayers) { prayer in
                    DesktopPrayerRow(prayer: prayer)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(
                            top: DimensToken.SIZE_4,
                            leading: DimensToken.SIZE_20,
                            bottom: DimensToken.SIZE_4,
                            trailing: DimensToken.SIZE_20
                        ))
                }
            }
            .listStyle(.plain)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .padding(.top, DimensToken.SIZE_52)
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
        HStack(spacing: DimensToken.SIZE_10) {
            Image(systemName: "bell.badge.fill")
                .font(.title3)
                .foregroundStyle(ColorToken.Red)
            VStack(
                alignment: .leading,
                spacing: DimensToken.SIZE_2
            ) {
                Text(String(localized: "Iqamah \(prayerName)"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(String(format: "%02d:%02d", remaining / 60, remaining % 60))
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundStyle(ColorToken.Red)
            }
            Spacer()
        }
        .padding(.vertical, DimensToken.SIZE_8)
        .padding(.horizontal, DimensToken.SIZE_12)
        .background(
            RoundedRectangle(cornerRadius: OX.Radius.M)
                .fill(ColorToken.Red10)
                .overlay(
                    RoundedRectangle(cornerRadius: OX.Radius.M)
                        .strokeBorder(
                            ColorToken.Red.opacity(FloatToken.PERCENT_30),
                            lineWidth: OX.Border.WIDTH_1
                        )
                )
        )
    }
}

// MARK: - Iqamah Finished Row

private struct IqamahFinishedRow: View {

    let prayerName: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: DimensToken.SIZE_10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(ColorToken.Green)
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
        .padding(.vertical, DimensToken.SIZE_8)
        .padding(.horizontal, DimensToken.SIZE_12)
        .background(
            RoundedRectangle(cornerRadius: OX.Radius.M)
                .fill(ColorToken.Green10)
                .overlay(
                    RoundedRectangle(cornerRadius: OX.Radius.M)
                        .strokeBorder(
                            ColorToken.Green.opacity(FloatToken.PERCENT_30),
                            lineWidth: OX.Border.WIDTH_1
                        )
                )
        )
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
        HStack(spacing: OX.Spacing.L) {
            Image(systemName: prayer.name.icon)
                .font(.title3)
                .frame(width: DimensToken.SIZE_30)
                .foregroundStyle(rowColor)

            VStack(
                alignment: .leading,
                spacing: DimensToken.SIZE_2
            ) {
                HStack(spacing: DimensToken.SIZE_6) {
                    Text(prayer.name.localizedName(for: appState.settings.appLanguage))
                        .font(.body)
                        .fontWeight(isHighlighted ? .semibold : .regular)

                    if isCurrent {
                        Text(appState.settings.appLanguage == .id ? "Aktif" : (appState.settings.appLanguage == .en ? "Active" : "نشط"))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, DimensToken.SIZE_6)
                            .padding(.vertical, DimensToken.SIZE_2)
                            .background(Capsule().fill(ColorToken.Green))
                    } else if prayer.isNext {
                        Text(appState.settings.appLanguage == .id ? "Berikutnya" : (appState.settings.appLanguage == .en ? "Next" : "التالية"))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, DimensToken.SIZE_6)
                            .padding(.vertical, DimensToken.SIZE_2)
                            .background(Capsule().fill(ColorToken.Blue))
                    }
                }

                Group {
                    if isCurrent {
                        Text(appState.settings.appLanguage == .id ? "Waktu sholat saat ini" : (appState.settings.appLanguage == .en ? "Current prayer time" : "وقت الصلاة الحالي"))
                            .foregroundStyle(ColorToken.Green)
                    } else if prayer.isNext {
                        Text(appState.settings.appLanguage == .id ? "Waktu berikutnya" : (appState.settings.appLanguage == .en ? "Next prayer" : "الصلاة التالية"))
                            .foregroundStyle(ColorToken.Blue)
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
                .fill(statusIndicatorColor)
                .frame(
                    width: DimensToken.SIZE_8,
                    height: DimensToken.SIZE_8
                )
                .opacity(isHighlighted ? FloatToken.PERCENT_100 : FloatToken.PERCENT_0)
        }
        .padding(.vertical, DimensToken.SIZE_10)
        .padding(.horizontal, DimensToken.SIZE_14)
        .background(
            isCurrent
                ? RoundedRectangle(cornerRadius: OX.Radius.M)
                    .fill(OX.Color.prayerActiveContainer(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: OX.Radius.M)
                            .strokeBorder(
                                ColorToken.Green.opacity(FloatToken.PERCENT_40),
                                lineWidth: OX.Border.WIDTH_1
                            )
                    )
                : (prayer.isNext
                    ? RoundedRectangle(cornerRadius: OX.Radius.M)
                        .fill(OX.Color.nextPrayerContainer(for: colorScheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: OX.Radius.M)
                                .strokeBorder(
                                    ColorToken.Blue.opacity(FloatToken.PERCENT_40),
                                    lineWidth: OX.Border.WIDTH_1
                                )
                        )
                    : nil)
        )
        .opacity(prayer.isPast && !isCurrent ? FloatToken.PERCENT_65 : FloatToken.PERCENT_100)
    }

    private var statusIndicatorColor: Color {
        if isCurrent { return ColorToken.Green }
        if prayer.isNext { return ColorToken.Blue }
        return .clear
    }

    private var rowColor: Color {
        if isCurrent { return ColorToken.Green }
        if prayer.isNext { return ColorToken.Blue }
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
        VStack(spacing: DimensToken.SIZE_20) {
            Spacer()

            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: DimensToken.SIZE_80,
                    height: DimensToken.SIZE_80
                )
                .clipShape(RoundedRectangle(cornerRadius: OX.Radius.XL))
                .shadow(
                    color: Color.black.opacity(FloatToken.PERCENT_15),
                    radius: DimensToken.SIZE_8,
                    x: DimensToken.SIZE_0,
                    y: DimensToken.SIZE_4
                )

            VStack(spacing: DimensToken.SIZE_6) {
                Text("KawalPrayer")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(appState.settings.appLanguage == .id ? "Versi \(appVersion)" : (appState.settings.appLanguage == .en ? "Version \(appVersion)" : "الإصدار \(appVersion)"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("by Outivox")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(ColorToken.Green)
                    .padding(.horizontal, DimensToken.SIZE_8)
                    .padding(.vertical, DimensToken.SIZE_2)
                    .background(
                        Capsule()
                            .fill(ColorToken.Green10)
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        ColorToken.Green.opacity(FloatToken.PERCENT_30),
                                        lineWidth: OX.Border.WIDTH_1
                                    )
                            )
                    )
            }

            GoogleColorDivider(thickness: DimensToken.SIZE_3)
                .frame(width: DimensToken.SIZE_80 * 2)

            Text(aboutDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DimensToken.SIZE_40)

            Divider()
                .padding(.horizontal, DimensToken.SIZE_80)

            VStack(spacing: DimensToken.SIZE_8) {
                Text(appState.settings.appLanguage == .id ? "Dibuat dengan SwiftUI & Swift 6 • Outivox Design Token System" : (appState.settings.appLanguage == .en ? "Built with SwiftUI & Swift 6 • Outivox Design Token System" : "تم التطوير باستخدام SwiftUI و Swift 6 • نظام Outivox للتصميم"))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
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
        Label(
            item.localizedName(for: appLanguage),
            systemImage: item.icon
        )
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.vertical, DimensToken.SIZE_6)
        .padding(.horizontal, DimensToken.SIZE_8)
        .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(FloatToken.PERCENT_85))
        .background(
            RoundedRectangle(cornerRadius: OX.Radius.S)
                .fill(isSelected ? ColorToken.Green : Color.clear)
        )
        .contentShape(RoundedRectangle(cornerRadius: OX.Radius.S))
        .onTapGesture(perform: action)
    }
}
