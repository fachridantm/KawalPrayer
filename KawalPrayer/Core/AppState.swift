import Foundation
import CoreLocation
import Observation
import ServiceManagement
import UserNotifications
import AppKit

enum IqamahState: Equatable {
    case idle
    case countdown(prayerName: String, remaining: Int)
    case finished(prayerName: String)

    var isActive: Bool {
        if case .idle = self { return false }
        return true
    }
}

@Observable
@MainActor
final class AppState {

    // MARK: - Published State

    var prayerTimes          : [PrayerTime]   = []
    var nextPrayer           : PrayerTime?
    var settings             : PrayerSettings = PrayerSettings()
    var location             : LocationModel  = .defaultLocation
    var qibla                : QiblaDirection = QiblaCalculator.calculate(latitude: -6.2088, longitude: 106.8456)

    // Status bar display
    var countdownString      : String = ""
    var nextPrayerName       : String = ""
    var nextPrayerShortTime  : String = ""
    var menuBarDisplayText   : String = ""

    // The prayer that has started and is currently active / ongoing
    var currentPrayer: PrayerTime? {
        let now = Date()
        let fardhu = prayerTimes.filter { $0.name.isFardhu }
        guard !fardhu.isEmpty else { return nil }

        let past = fardhu.filter { $0.time <= now }
        if let current = past.last {
            return current
        } else {
            return fardhu.first(where: { $0.name == .isha })
        }
    }

    // Dynamic icon name for Menu Bar based on settings
    var activeMenuBarIconName: String {
        switch settings.menuBarIconSource {
        case .currentPrayer:
            return currentPrayer?.name.icon ?? "moon.stars.fill"
        case .nextPrayer:
            return nextPrayer?.name.icon ?? "moon.stars.fill"
        case .staticMoon:
            return "moon.stars.fill"
        }
    }

    // Doa setelah adzan
    var showDoaBanner        : Bool = false
    var currentDuas          : [Dua] = []

    // Iqamah
    var iqamahState          : IqamahState = .idle

    // Location loading state
    var isLocationRefreshing : Bool = false

    // Hook to open status bar popover programmatically
    var onShowPopoverRequested: (() -> Void)?
    var onStatusBarTitleChanged: (() -> Void)?

    // Update service
    var updateService        = UpdateService.shared

    // MARK: - Private

    private let locationService = LocationService()
    private var refreshTimer    : Timer?
    private var countdownTimer  : Timer?
    private var updateCheckTimer: Timer?
    private var audioTimers     : [Timer] = []
    private var lastRefreshDay  : Int = Calendar.current.component(.day, from: Date())

    // Iqamah internals
    private var iqamahEndTime   : Date?
    private var iqamahPrayerName: String = ""
    private var currentAdzanPrayer: String = ""

    // Doa dismiss timer
    private var doaDismissTimer : Timer?

    // Doa harian
    private var dailyDuaQueue   : [Dua] = []
    private var dailyDuaDate    : Int = 0

    // Debounce timer for saveSettings
    private var saveDebounceTimer: Timer?

    // MARK: - Init

    init() {
        loadFromStorage()
        recalculateQibla()
        refreshPrayerTimes()
        startRefreshTimer()
        startCountdownTimer()
        setupLocationTracking()

        if settings.autoCheckUpdates {
            startUpdateCheckTimer()
        }

        // Request notification permission on first launch
        Task {
            _ = await NotificationService.shared.requestPermission()
        }

        NotificationService.shared.onStopAdzanActionTriggered = { [weak self] in
            Task { @MainActor [weak self] in
                self?.stopAll()
            }
        }

        AudioService.shared.onAdzanFinished = { [weak self] in
            Task { @MainActor [weak self] in
                self?.handleAdzanFinished()
            }
        }
    }

    // MARK: - Prayer Times

    func refreshPrayerTimes() {
        prayerTimes = PrayerTimeCalculator.calculate(
            for: Date(),
            location: location,
            method: settings.calculationMethod,
            asrMadhab: settings.asrMadhab,
            ihtiyatMinutes: settings.ihtiyatMinutes,
            manualOffsets: settings.manualOffsets
        )

        // Find next prayer for today, or calculate tomorrow's Fajr if all today's passed
        if let upcoming = prayerTimes.first(where: { !$0.isPast && $0.name.isFardhu }) {
            nextPrayer = upcoming
        } else {
            nextPrayer = PrayerTimeCalculator.calculateNextDayFajr(
                from: Date(),
                location: location,
                method: settings.calculationMethod,
                asrMadhab: settings.asrMadhab,
                ihtiyatMinutes: settings.ihtiyatMinutes,
                manualOffsets: settings.manualOffsets
            )
        }

        if settings.isNotificationEnabled {
            NotificationService.shared.schedule(prayerTimes: prayerTimes, settings: settings)
        }

        scheduleAudioTimers()
        updateCountdown()
    }

    private func recalculateQibla() {
        qibla = QiblaCalculator.calculate(latitude: location.latitude, longitude: location.longitude)
    }

    // MARK: - Prayer Alert & Audio Timers

    private func scheduleAudioTimers() {
        audioTimers.forEach { $0.invalidate() }
        audioTimers.removeAll()

        guard settings.isSoundEnabled || settings.isNotificationEnabled else { return }

        let upcoming = prayerTimes.filter {
            $0.name.isFardhu && !$0.isPast && !settings.mutedPrayers.contains($0.name)
        }
        for prayer in upcoming {
            let delay = prayer.time.timeIntervalSinceNow
            guard delay > 0 else { continue }

            let timer = Timer.scheduledTimer(
                withTimeInterval: delay,
                repeats: false
            ) { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.currentAdzanPrayer = prayer.name.localizedName

                    if self.settings.isNotificationEnabled {
                        NotificationService.shared.sendAdzanNotification(
                            for: prayer.name.localizedName(for: self.settings.appLanguage),
                            timeString: prayer.timeString,
                            lang: self.settings.appLanguage
                        )
                    }

                    if self.settings.isSoundEnabled {
                        AudioService.shared.playAdzan(
                            soundName: self.settings.selectedSound,
                            volumeLevel: self.settings.adzanVolume
                        )
                    }
                }
            }
            audioTimers.append(timer)
        }
    }

    // MARK: - Adzan Finished Handler

    private func handleAdzanFinished() {
        let prayerName = currentAdzanPrayer
        NotificationService.shared.dismissAdzanNotification()

        // Doa setelah adzan banner
        if settings.showDuaAfterAdzan {
            pickDuasForCurrentPrayer()
            showDoaBanner = true
            doaDismissTimer?.invalidate()

            let doaDuration = settings.duaDismissSeconds > 0
                ? Double(settings.duaDismissSeconds)
                : max(Double(settings.iqamahDurationMinutes) * 60 - 10, 15)

            doaDismissTimer = Timer.scheduledTimer(withTimeInterval: doaDuration, repeats: false) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.showDoaBanner = false
                }
            }

            // Automatically pop up Menu Bar view to show Doa banner!
            onShowPopoverRequested?()
        }

        // Iqamah countdown
        if settings.iqamahEnabled, !prayerName.isEmpty {
            startIqamahCountdown(for: prayerName)
        }
    }

    private func pickDuasForCurrentPrayer() {
        currentDuas = [Dua.afterAdzan]
    }

    func dismissDoaBanner() {
        showDoaBanner = false
        doaDismissTimer?.invalidate()
        doaDismissTimer = nil
    }

    // MARK: - Iqamah

    private func startIqamahCountdown(for prayerName: String) {
        iqamahPrayerName = prayerName
        iqamahEndTime = Date().addingTimeInterval(Double(settings.iqamahDurationMinutes) * 60)
        updateIqamahCountdown()
    }

    private func updateIqamahCountdown() {
        guard let endTime = iqamahEndTime else {
            iqamahState = .idle
            return
        }

        let remaining = Int(endTime.timeIntervalSinceNow)
        if remaining <= 0 {
            NSLog("[KawalPrayer] Iqamah countdown finished for: \(iqamahPrayerName)")
            iqamahState = .finished(prayerName: iqamahPrayerName)
            iqamahEndTime = nil
            dismissDoaBanner()
            NotificationService.shared.sendIqamahNotification(for: iqamahPrayerName, lang: settings.appLanguage)
            updateMenuBarDisplayText()
            return
        }

        iqamahState = .countdown(prayerName: iqamahPrayerName, remaining: remaining)
        updateMenuBarDisplayText()
    }

    // MARK: - Timers

    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.refreshPrayerTimes() }
        }
    }

    private func startCountdownTimer() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateCountdown()
                self?.updateIqamahCountdown()
            }
        }
    }

    func startUpdateCheckTimer() {
        updateCheckTimer?.invalidate()
        updateCheckTimer = nil

        guard settings.autoCheckUpdates else { return }

        // Initial check 5 seconds after startup
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            guard let self, self.settings.autoCheckUpdates else { return }
            await self.updateService.checkForUpdates(
                autoDownload: self.settings.autoUpdateEnabled,
                manual: false
            )
        }

        // Periodic check every 6 hours (21600 seconds)
        updateCheckTimer = Timer.scheduledTimer(
            withTimeInterval: 21600,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.settings.autoCheckUpdates else { return }
                await self.updateService.checkForUpdates(
                    autoDownload: self.settings.autoUpdateEnabled,
                    manual: false
                )
            }
        }
    }

    private func updateCountdown() {
        let today = Calendar.current.component(.day, from: Date())
        if today != lastRefreshDay {
            lastRefreshDay = today
            refreshPrayerTimes()
            return
        }

        guard let next = nextPrayer else {
            countdownString = ""
            nextPrayerName  = ""
            nextPrayerShortTime = ""
            updateMenuBarDisplayText()
            return
        }

        let diff = next.time.timeIntervalSinceNow
        guard diff > 0 else {
            refreshPrayerTimes()
            return
        }

        let h = Int(diff) / 3600
        let m = (Int(diff) % 3600) / 60
        let s = Int(diff) % 60

        nextPrayerName  = next.name.localizedName(for: settings.appLanguage)
        nextPrayerShortTime = next.shortTimeString
        let hourUnit = settings.appLanguage == .id ? "j" : "h"
        countdownString = h > 0
            ? String(format: "%d%@ %02dm", h, hourUnit, m)
            : String(format: "%02dm %02ds", m, s)

        updateMenuBarDisplayText()
    }

    private var lastReportedIconName: String = ""

    func updateMenuBarDisplayText() {
        let previous = menuBarDisplayText
        let currentIcon = activeMenuBarIconName

        if case .countdown(let prayerName, let remaining) = iqamahState {
            let m = remaining / 60
            let s = remaining % 60
            let iqamahLabel = settings.appLanguage == .ar ? "إقامة" : "Iqamah"
            menuBarDisplayText = "\(iqamahLabel) \(prayerName) • \(String(format: "%02d:%02d", m, s))"
        } else if !nextPrayerName.isEmpty {
            switch settings.menuBarDisplayMode {
            case .iconNameCountdown:
                menuBarDisplayText = "\(nextPrayerName) • \(countdownString)"
            case .iconCountdown:
                menuBarDisplayText = countdownString
            case .iconName:
                menuBarDisplayText = nextPrayerName
            case .iconTime:
                menuBarDisplayText = "\(nextPrayerName) \(nextPrayerShortTime)"
            case .iconOnly:
                menuBarDisplayText = ""
            }
        } else {
            menuBarDisplayText = ""
        }

        if previous != menuBarDisplayText || lastReportedIconName != currentIcon {
            lastReportedIconName = currentIcon
            onStatusBarTitleChanged?()
        }
    }

    // MARK: - Location

    private func setupLocationTracking() {
        locationService.onLocationUpdated = { [weak self] newLocation, newCity in
            Task { @MainActor [weak self] in
                guard let self, self.settings.useAutoLocation else { return }
                let tz = Double(TimeZone.current.secondsFromGMT()) / 3600.0
                let loc = LocationModel(
                    latitude: newLocation.coordinate.latitude,
                    longitude: newLocation.coordinate.longitude,
                    cityName: newCity,
                    timezone: tz
                )
                if loc != self.location {
                    self.location = loc
                    self.saveLocationToStorage()
                    self.recalculateQibla()
                    self.refreshPrayerTimes()
                    NSLog("[KawalPrayer] Location updated automatically to: \(newCity)")
                }
            }
        }

        if settings.useAutoLocation {
            locationService.startMonitoring()
            locationService.refreshLocation()
        }
    }

    func requestLocationRefresh() {
        isLocationRefreshing = true
        locationService.requestPermission()
        locationService.refreshLocation()

        // Safety timeout for spinner
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            self?.isLocationRefreshing = false
        }
    }

    // MARK: - Stop All

    func stopAll() {
        NotificationService.shared.dismissAdzanNotification()
        NotificationService.shared.cancelAll()
        AudioService.shared.stopAdzan()

        currentAdzanPrayer = ""
        dismissDoaBanner()
        iqamahState = .idle
        iqamahEndTime = nil
        updateMenuBarDisplayText()
    }

    // MARK: - Persistence

    func saveSettingsImmediately() {
        saveDebounceTimer?.invalidate()
        commitSaveSettings()
    }

    func saveSettings() {
        saveDebounceTimer?.invalidate()
        saveDebounceTimer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: false
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.commitSaveSettings()
            }
        }
    }

    private func saveLocationToStorage() {
        if let data = try? JSONEncoder().encode(location) {
            UserDefaults.standard.set(data, forKey: "kawal_cached_location")
        }
    }

    private func commitSaveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "kawal_prayer_settings")
        }
        NSApp.appearance = settings.appTheme.nsAppearance
        if !settings.useAutoLocation,
           let data = try? JSONEncoder().encode(location) {
            UserDefaults.standard.set(data, forKey: "kawal_manual_location")
        }
        saveLocationToStorage()
        applyLaunchAtLogin(settings.launchAtLogin)
        recalculateQibla()
        refreshPrayerTimes()
        updateMenuBarDisplayText()
        startUpdateCheckTimer()
    }

    private func applyLaunchAtLogin(_ enable: Bool) {
        do {
            if enable {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Not fatal on sandbox dev builds
        }
    }

    private func loadFromStorage() {
        if let data = UserDefaults.standard.data(forKey: "kawal_prayer_settings"),
           let decoded = try? JSONDecoder().decode(PrayerSettings.self, from: data) {
            settings = decoded
        }
        if !settings.useAutoLocation,
           let data = UserDefaults.standard.data(forKey: "kawal_manual_location"),
           let decoded = try? JSONDecoder().decode(LocationModel.self, from: data) {
            location = decoded
        } else if let data = UserDefaults.standard.data(forKey: "kawal_cached_location"),
                  let decoded = try? JSONDecoder().decode(LocationModel.self, from: data) {
            location = decoded
        }
        settings.launchAtLogin = SMAppService.mainApp.status == .enabled
    }
}
