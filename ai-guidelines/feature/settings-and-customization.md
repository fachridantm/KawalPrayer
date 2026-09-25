# Feature: Settings & Customization

The Settings module (`Features/Settings/SettingsView.swift`) provides granular control over prayer calculations, notifications, audio, and visual appearance.

---

## 1. Appearance & Menu Bar
- **Menu Bar Display Format**: 5 modes (Icon+Name+Countdown, Icon+Countdown, Icon+Name, Icon+Time, Icon Only).
- **Menu Bar Icon Source**: Current Prayer icon, Next Prayer icon, or Static Moon.
- **Theme**: System, Light, Dark.
- **Show Syuruq**: Toggles display of sunrise time in schedule and popover.
- **Show Dock Icon**: Toggles whether KawalPrayer appears in the macOS Dock when its main window is active.

---

## 2. Notifications & Pre-Prayer Alerts
- **Master Notification Toggle**: Enables or disables banner alerts.
- **Pre-Prayer Warning Offset**: Sends an advance reminder (0 to 30 minutes before adzan, step: 5 mins).
- **Per-Prayer Mute Controls**: Individually toggle notifications and adzan for Fajr, Dhuhr, Asr, Maghrib, or Isha.

---

## 3. Adzan Audio & Sound Management
- **Sound Selection**: Choose from bundled high-quality adzan recordings (Makkah, Madinah, etc.).
- **Volume Slider**: Adjusts volume level from 10% to 100%.
- **Live Sound Test**: Play and stop adzan test audio directly from Settings.

---

## 4. Dua After Adzan & Iqamah
- **Auto Pop-up Toggle**: Enables or disables the automatic popover display after adzan.
- **Dua Dismiss Duration**: 0 to 120 seconds (0 = stays open until manually closed).
- **Iqamah Enabled & Duration**: Configurable duration from 1 to 30 minutes.

---

## 5. Calculation Engine & Safety Margins
- **Calculation Method**: Kemenag RI (Standard Indonesia), Muslim World League, ISNA, Umm al-Qura, Egyptian.
- **Madhab Ashar**: Syafi'i (shadow 1×) or Hanafi (shadow 2×).
- **Ihtiyat (Safety Margin)**: Default +2 minutes (Kemenag standard), configurable from -5 to +10 minutes.
- **Manual Offsets**: ± minutes per prayer (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha).
- **Hijri Date Correction**: Offset from -2 to +2 days.

---

## 6. Location & Launch at Login
- **Auto Location (GPS)**: Real-time CoreLocation tracking with persistent city and district formatting.
- **Manual City Search**: Reverse geocodes entered city/district and saves custom coordinates.
- **Launch at Login**: Integrates with Apple's `SMAppService.mainApp` to launch silently at macOS boot.
