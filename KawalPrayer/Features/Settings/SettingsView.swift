import SwiftUI
import CoreLocation

struct SettingsView: View {

    var isActive: Bool = true

    @Environment(AppState.self) private var appState
    @State private var settings: PrayerSettings = PrayerSettings()
    @State private var manualCity: String = ""
    @State private var showRestartAlert: Bool = false
    @State private var showMadhabAlert: Bool = false
    @State private var didAppear: Bool = false
    @State private var availableSounds: [String] = []

    private var fardhuPrayerNames: [PrayerName] {
        PrayerName.allCases.filter { $0.isFardhu }
    }

    var body: some View {
        Form {

            // MARK: Menu Bar & Tampilan
            Section(String(localized: "Tampilan Menu Bar")) {
                Picker(
                    String(localized: "Format Teks Menu Bar"),
                    selection: $settings.menuBarDisplayMode
                ) {
                    ForEach(MenuBarDisplayMode.allCases) { mode in
                        let preview = mode.samplePreview(for: settings.appLanguage)
                        let title = preview.isEmpty
                            ? mode.localizedName(for: settings.appLanguage)
                            : "\(mode.localizedName(for: settings.appLanguage)) (\(preview))"
                        Text(title).tag(mode)
                    }
                }

                Picker(String(localized: "Ikon Menu Bar"), selection: $settings.menuBarIconSource) {
                    ForEach(MenuBarIconSource.allCases) { source in
                        Text(source.localizedName(for: settings.appLanguage)).tag(source)
                    }
                }

                Picker(String(localized: "Tema Aplikasi"), selection: $settings.appTheme) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Label(theme.localizedName(for: settings.appLanguage), systemImage: theme.icon).tag(theme)
                    }
                }
                .pickerStyle(.segmented)

                Toggle(String(localized: "Tampilkan Waktu Syuruq"), isOn: $settings.showSyuruq)
                Toggle(String(localized: "Tampilkan di Dock saat Jendela Terbuka"), isOn: $settings.showDockWhenWindowOpen)
            }

            // MARK: Notifikasi
            Section(String(localized: "Notifikasi")) {
                Toggle(String(localized: "Banner Notifikasi"), isOn: $settings.isNotificationEnabled)

                Stepper(
                    String(localized: "Notif \(settings.notificationOffset) menit sebelum sholat"),
                    value: $settings.notificationOffset,
                    in: 0...30,
                    step: 5
                )
                .disabled(!settings.isNotificationEnabled)

                Button(String(localized: "Stop Semua Notifikasi & Audio"), role: .destructive) {
                    appState.stopAll()
                }
            }

            // MARK: Notifikasi per Sholat
            Section(String(localized: "Notifikasi per Waktu Sholat")) {
                ForEach(fardhuPrayerNames) { prayer in
                    Toggle(prayer.localizedName(for: settings.appLanguage), isOn: Binding(
                        get: { !settings.mutedPrayers.contains(prayer) },
                        set: { enabled in
                            if enabled { settings.mutedPrayers.remove(prayer) }
                            else       { settings.mutedPrayers.insert(prayer) }
                        }
                    ))
                }
            }
            .disabled(!settings.isNotificationEnabled)

            // MARK: Suara Adzan & Audio
            Section(String(localized: "Suara Adzan")) {
                Toggle(String(localized: "Aktifkan Audio Adzan"), isOn: $settings.isSoundEnabled)

                if !availableSounds.isEmpty {
                    Picker(String(localized: "Pilih Suara"), selection: $settings.selectedSound) {
                        ForEach(availableSounds, id: \.self) { sound in
                            Text(sound.replacingOccurrences(of: "_", with: " ").capitalized)
                                .tag(sound)
                        }
                    }
                    .disabled(!settings.isSoundEnabled)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(String(localized: "Volume Adzan"))
                            Spacer()
                            Text("\(Int(settings.adzanVolume * 100))%")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $settings.adzanVolume, in: 0.1...1.0, step: 0.05)
                    }
                    .disabled(!settings.isSoundEnabled)

                    HStack {
                        if AudioService.shared.isPlaying {
                            Button(role: .destructive) {
                                AudioService.shared.stopAdzan()
                            } label: {
                                Label(String(localized: "Hentikan"), systemImage: "stop.fill")
                            }
                        } else {
                            Button {
                                AudioService.shared.playAdzan(soundName: settings.selectedSound, volumeLevel: settings.adzanVolume)
                            } label: {
                                Label(String(localized: "Uji Suara Adzan"), systemImage: "play.fill")
                            }
                        }
                    }
                    .disabled(!settings.isSoundEnabled)
                }
            }

            // MARK: Doa Setelah Adzan
            Section(String(localized: "Doa Setelah Adzan")) {
                Toggle(String(localized: "Pop-up Doa di Menu Bar Setelah Adzan"), isOn: $settings.showDuaAfterAdzan)

                Stepper(
                    String(localized: "Auto-dismiss \(settings.duaDismissSeconds) detik"),
                    value: $settings.duaDismissSeconds,
                    in: 0...120,
                    step: 5
                )
                .disabled(!settings.showDuaAfterAdzan)

                if settings.duaDismissSeconds == 0 {
                    Text(String(localized: "Doa tidak akan otomatis hilang sampai ditutup"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: Iqamah
            Section("Iqamah") {
                Toggle(String(localized: "Aktifkan Iqamah Timer"), isOn: $settings.iqamahEnabled)
                Stepper(
                    String(localized: "Durasi \(settings.iqamahDurationMinutes) menit"),
                    value: $settings.iqamahDurationMinutes,
                    in: 1...30,
                    step: 1
                )
                .disabled(!settings.iqamahEnabled)
            }

            // MARK: Lokasi & GPS
            Section(String(localized: "Lokasi & GPS")) {
                Toggle(String(localized: "Lokasi Otomatis (GPS & Pergerakan)"), isOn: $settings.useAutoLocation)
                    .onChange(of: settings.useAutoLocation) { _, useAuto in
                        if useAuto { appState.requestLocationRefresh() }
                    }

                if settings.useAutoLocation {
                    HStack {
                        Button {
                            appState.requestLocationRefresh()
                        } label: {
                            HStack(spacing: 6) {
                                if appState.isLocationRefreshing {
                                    ProgressView().controlSize(.small)
                                    Text(String(localized: "Mendeteksi Lokasi..."))
                                } else {
                                    Image(systemName: "location.fill")
                                    Text(String(localized: "Perbarui Lokasi GPS Sekarang"))
                                }
                            }
                        }
                        .disabled(appState.isLocationRefreshing)
                    }
                } else {
                    HStack {
                        TextField(String(localized: "Nama kota"), text: $manualCity)
                        Button(String(localized: "Simpan")) {
                            saveManualCity()
                        }
                        .disabled(manualCity.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                LabeledContent(String(localized: "Lokasi saat ini"), value: appState.location.cityName)
                    .foregroundStyle(.secondary)

                LabeledContent(String(localized: "Arah Kiblat"), value: appState.qibla.formattedBearing(for: settings.appLanguage))
                    .foregroundStyle(.secondary)
            }

            // MARK: Metode Hisab & Ihtiyat
            Section(String(localized: "Metode Hisab & Koreksi")) {
                Picker(String(localized: "Metode Hisab"), selection: $settings.calculationMethod) {
                    ForEach(CalculationMethod.allCases, id: \.self) { method in
                        Text(method.localizedName(for: settings.appLanguage)).tag(method)
                    }
                }

                Stepper(
                    String(localized: "Pengaman Waktu (Ihtiyat): +\(settings.ihtiyatMinutes) menit"),
                    value: $settings.ihtiyatMinutes,
                    in: 0...5,
                    step: 1
                )
                Text(String(localized: "Standar Kemenag RI menggunakan pengaman waktu +2 menit agar sesuai jadwal masjid."))
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Stepper(
                    String(localized: "Koreksi Tanggal Hijriah: \(settings.hijriOffsetDays >= 0 ? "+\(settings.hijriOffsetDays)" : "\(settings.hijriOffsetDays)") hari"),
                    value: $settings.hijriOffsetDays,
                    in: -2...2,
                    step: 1
                )

                Picker(String(localized: "Madhab Ashar"), selection: $settings.asrMadhab) {
                    ForEach(AsrMadhab.allCases, id: \.self) { madhab in
                        Text(madhab.rawValue).tag(madhab)
                    }
                }
                .onChange(of: settings.asrMadhab) { _, _ in
                    guard didAppear else { return }
                    showMadhabAlert = true
                }
            }
            .alert(String(localized: "Madhab Diubah"), isPresented: $showMadhabAlert) {
                Button("OK") { }
            } message: {
                if let asrTime = appState.prayerTimes.first(where: { $0.name == .asr }) {
                    Text(String(localized: "Madhab berhasil diubah ke \(settings.asrMadhab.rawValue). Waktu Ashar hari ini: \(asrTime.timeString)"))
                }
            }

            // MARK: Al-Qur'an
            Section(String(localized: "Al-Qur'an")) {
                Picker(String(localized: "Tampilan Al-Qur'an"), selection: $settings.quranViewMode) {
                    ForEach(QuranViewMode.allCases) { mode in
                        Text(mode.localizedName(for: settings.appLanguage)).tag(mode)
                    }
                }

                Stepper(
                    String(localized: "Ukuran Tulisan Arab: \(Int(settings.quranArabicFontSize)) pt"),
                    value: $settings.quranArabicFontSize,
                    in: 18...42,
                    step: 1
                )
            }

            // MARK: App Updates
            Section(String(localized: "App Updates")) {
                Toggle(
                    String(localized: "Automatically Update"),
                    isOn: $settings.autoUpdateEnabled
                )

                Toggle(
                    String(localized: "Automatically Check for Updates"),
                    isOn: $settings.autoCheckUpdates
                )

                HStack {
                    Text(String(localized: "Current Version"))
                    Spacer()
                    Text(appState.updateService.displayVersion)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Button {
                        Task {
                            await appState.updateService.checkForUpdates(
                                autoDownload: settings.autoUpdateEnabled,
                                manual: true
                            )
                        }
                    } label: {
                        if case .checking = appState.updateService.status {
                            HStack(spacing: DimensToken.SIZE_6) {
                                ProgressView()
                                    .controlSize(.mini)
                                Text(String(localized: "Checking..."))
                            }
                        } else {
                            Label(
                                String(localized: "Check for Updates Now"),
                                systemImage: "arrow.triangle.2.circlepath"
                            )
                        }
                    }
                    .disabled(appState.updateService.status == .checking)

                    Spacer()

                    switch appState.updateService.status {
                    case .upToDate:
                        Text(String(localized: "Up to date"))
                            .font(.caption)
                            .foregroundStyle(ColorToken.Green)
                    case .updateAvailable(let release):
                        HStack(spacing: OX.Spacing.S) {
                            Text("v\(release.version)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(ColorToken.Blue)
                            Button(String(localized: "Update")) {
                                Task {
                                    await appState.updateService.downloadUpdate(release: release)
                                }
                            }
                        }
                    case .downloading(let progress):
                        HStack(spacing: DimensToken.SIZE_6) {
                            ProgressView(
                                value: progress,
                                total: FloatToken.PERCENT_100
                            )
                            .progressViewStyle(.linear)
                            .frame(width: DimensToken.SIZE_80)
                            Text(String(format: "%.0f%%", progress * 100))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    case .readyToInstall(let release, let localPath):
                        HStack(spacing: OX.Spacing.S) {
                            Text("v\(release.version)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(ColorToken.Green)
                            Button(String(localized: "Install")) {
                                appState.updateService.installUpdate(localURL: localPath)
                            }
                        }
                    case .error(let msg):
                        Text(msg)
                            .font(.caption)
                            .foregroundStyle(ColorToken.Red)
                            .lineLimit(1)
                    case .idle, .checking:
                        EmptyView()
                    }
                }
            }

            // MARK: Sistem & Startup
            Section(String(localized: "Sistem")) {
                Toggle(String(localized: "Buka otomatis saat Login (Startup)"), isOn: $settings.launchAtLogin)
            }

            // MARK: Bahasa
            Section(String(localized: "Bahasa")) {
                Picker(String(localized: "Bahasa Aplikasi"), selection: $settings.appLanguage) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .onChange(of: settings.appLanguage) { _, newLang in
                    UserDefaults.standard.set([newLang.localeIdentifier], forKey: "AppleLanguages")
                    UserDefaults.standard.synchronize()
                    appState.settings.appLanguage = newLang
                    appState.saveSettingsImmediately()
                    showRestartAlert = true
                }

                Text(String(localized: "Perubahan bahasa memerlukan restart aplikasi"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .alert(String(localized: "Restart Aplikasi"), isPresented: $showRestartAlert) {
                Button(String(localized: "Restart Sekarang")) {
                    appState.settings = settings
                    appState.saveSettingsImmediately()
                    let bundlePath = Bundle.main.bundlePath
                    let task = Process()
                    task.launchPath = "/bin/sh"
                    task.arguments = ["-c", "sleep 1 && open \"\(bundlePath)\""]
                    try? task.run()
                    NSApplication.shared.terminate(nil)
                }
                Button(String(localized: "Nanti"), role: .cancel) { }
            } message: {
                Text(String(localized: "Aplikasi perlu di-restart agar perubahan bahasa diterapkan. Restart sekarang?"))
            }

        }
        .formStyle(.grouped)
        .padding(.top, DimensToken.SIZE_52)
        .environment(\.locale, settings.appLanguage.locale)
        .onAppear {
            settings = appState.settings
            manualCity = appState.location.cityName
            if availableSounds.isEmpty {
                availableSounds = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil)
                    .map { URL(fileURLWithPath: $0).deletingPathExtension().lastPathComponent }
                    .sorted()
                if availableSounds.isEmpty {
                    availableSounds = ["adzan_makkah", "adzan_madinah"]
                }
            }
            DispatchQueue.main.async { didAppear = true }
        }
        .onChange(of: isActive) { _, active in
            guard active, didAppear else { return }
            didAppear = false
            settings = appState.settings
            manualCity = appState.location.cityName
            DispatchQueue.main.async { didAppear = true }
        }
        .onChange(of: settings) { _, newVal in
            guard didAppear else { return }
            appState.settings = newVal
            appState.saveSettings()
        }
    }

    private func saveManualCity() {
        let geocoder = CLGeocoder()
        Task {
            guard let placemarks = try? await geocoder.geocodeAddressString(manualCity),
                  let place = placemarks.first,
                  let coord = place.location?.coordinate else { return }
            let tz = Double(TimeZone.current.secondsFromGMT() / 3600)
            let formattedCity = LocationHelper.formatCityAndDistrict(from: place)
            appState.location = LocationModel(
                latitude : coord.latitude,
                longitude: coord.longitude,
                cityName : formattedCity.isEmpty ? manualCity : formattedCity,
                timezone : tz
            )
            appState.saveSettingsImmediately()
        }
    }
}
