# KawalPrayer

Aplikasi pengingat waktu sholat dan adzan menu bar untuk macOS. Berjalan senyap di background tanpa menampilkan ikon di Dock atau membuka jendela otomatis saat startup.

![macOS](https://img.shields.io/badge/macOS-14%2B-black?logo=apple&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-5.9%20%2F%206-orange?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-%40Observable-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 🌟 Fitur Utama

- **Background Agent (Senyap di Menu Bar)**:
  - Dikonfigurasi dengan `LSUIElement = true`. Aplikasi hidup di menu bar macOS tanpa mengotori Dock atau app switcher (`⌘Tab`).
  - Tidak membuka jendela secara otomatis saat startup.
  - Jendela utama (Dashboard, Al-Quran, Pengaturan) hanya terbuka saat Anda menekan **"Buka KawalPrayer"** dari menu bar.
  - Menutup jendela (tombol merah atau `⌘W`) hanya menyembunyikan jendela; aplikasi tetap siaga di background.
  - Opsi *"Tampilkan di Dock saat Jendela Terbuka"* di Pengaturan.

- **Tampilan Menu Bar yang Dapat Dikustomisasi**:
  - Pilihan format tampilan status bar sesuai preferensi (sangat cocok untuk MacBook dengan notch):
    1. **Icon + Nama + Hitung Mundur** *(Default, contoh: `🌙 Subuh • 00:45`)*
    2. **Icon + Hitung Mundur** *(contoh: `🌙 00:45`)*
    3. **Icon + Nama Sholat** *(contoh: `🌙 Subuh`)*
    4. **Icon + Waktu Sholat** *(contoh: `🌙 Subuh 04:35`)*
    5. **Hanya Icon** *(contoh: `🌙`)*

- **Akurasi Jadwal Sholat Kemenag RI (+2 Menit Ihtiyat)**:
  - Perhitungan hisab astronomi dilengkapi dengan **Pengaman Waktu (Ihtiyat)** standar Kementerian Agama RI (+2 menit default) agar waktu adzan cocok dengan masjid dan jadwal resmi Bimas Islam.
  - Mendukung metode hisab internasional: Muslim World League (MWL), ISNA, Umm al-Qura, dan Egyptian.
  - Pilihan madhab Ashar: Syafi'i (faktor bayangan 1×) atau Hanafi (faktor bayangan 2×).
  - Koreksi manual per waktu sholat (± menit).

- **Hitung Mundur 24 Jam Tanpa Putus**:
  - Setelah waktu Isya terlewati di malam hari, hitung mundur otomatis beralih ke waktu Subuh esok hari sehingga status bar tidak pernah kosong.

- **Deteksi Lokasi GPS & Pergerakan Real-Time**:
  - Menggunakan CoreLocation untuk mendeteksi perpindahan lokasi secara hemat daya.
  - Tombol **Perbarui Lokasi GPS** langsung di header popover menu bar dan di menu Pengaturan.

- **Arah Kiblat Akurat**:
  - Menghitung derajat arah Ka'bah (azimuth) dari koordinat GPS Anda secara real-time.
  - Dilengkapi kompas visual di Dashboard dan informasi arah mata angin (contoh: `295° BL`).

- **Notifikasi Interaktif dengan Action Button**:
  - Banner notifikasi saat masuk waktu sholat dilengkapi tombol aksi:
    - **"Hentikan Adzan"**: Menghentikan suara adzan langsung dari notifikasi tanpa harus membuka aplikasi.
    - **"Tutup"**: Menutup notifikasi.
  - **Auto-Dismiss**: Notifikasi otomatis dibersihkan dari Notification Center segera setelah audio adzan selesai diputar.

- **Pop-up Otomatis Doa Setelah Adzan di Menu Bar**:
  - Begitu adzan selesai (atau setelah pengguna menekan "Hentikan Adzan"), popover menu bar otomatis terbuka menampilkan kartu **Doa Setelah Adzan** (teks Arab, transliterasi Latin, dan terjemahan).
  - Waktu auto-dismiss doa dapat diatur di Pengaturan (atau tetap tampil sampai ditutup manual).

- **Iqamah Timer**:
  - Penghitung mundur waktu jeda antara adzan dan iqamah (default: 5 menit).
  - Notifikasi saat waktu iqamah tiba.

- **Al-Quran 30 Juz Offline**:
  - 114 surah lengkap dengan teks Arab, terjemahan Bahasa Indonesia, dan Bahasa Inggris.
  - Fitur pencarian surah dan ayat.
  - Penanda (bookmark) ayat dengan badge counter dan animasi lompat ke ayat.
  - Pengatur ukuran font teks Arab (18–40pt).
  - Salin ayat beserta artinya dalam satu klik.

- **Kontrol Audio & Suara Adzan**:
  - Pilihan rekaman audio adzan Makkah & Madinah.
  - Slider volume adzan independen dan tombol uji suara (preview).

- **Kalender Hijriah & Masehi**:
  - Tampilan tanggal Hijriah dengan opsi koreksi penyesuaian (±2 hari) agar sesuai sidang isbat pemerintah.

- **Buka Otomatis saat Login (Startup)**:
  - Terintegrasi dengan macOS `SMAppService` modern.

---

## 🛠️ Cara Membangun (Build from Source)

### Prasyarat
- macOS 14.0 (Sonoma) atau lebih baru
- Xcode 15/16/27+ terpasang di `/Applications/Xcode.app`

### Langkah-langkah
```bash
# 1. Buka project di Xcode
open KawalPrayer.xcodeproj

# 2. Tekan ⌘R di Xcode untuk menjalankan aplikasi
```

### Membangun DMG (Installer)
Jalankan script pembuatan file DMG:
```bash
./scripts/build_dmg.sh
```
File installer `KawalPrayer-v1.0.0.dmg` akan siap di root folder.

---

## 📂 Struktur Arsitektur

```
KawalPrayer/
├── KawalPrayer.xcodeproj/
├── KawalPrayer/
│   ├── KawalPrayerApp.swift        # Entry point & AppDelegate (Background Agent)
│   ├── KawalPrayer.entitlements    # Sandbox, Location, Network entitlements
│   ├── Localizable.xcstrings       # Lokalisasi (ID, EN, AR)
│   ├── Assets.xcassets/            # AppIcon, AccentColor, Bookmark icon
│   ├── Core/
│   │   ├── AppState.swift          # Single Source of Truth (@Observable, @MainActor)
│   │   ├── QiblaCalculator.swift   # Formula arah kiblat ke Ka'bah
│   │   ├── IslamicCalendarHelper.swift # Tanggal Hijriah dengan koreksi offset
│   │   ├── Models/                 # PrayerTime, PrayerSettings, LocationModel, DuaModel, Surah, Ayah
│   │   └── Services/               # PrayerTimeCalculator, LocationService, NotificationService, AudioService, QuranService
│   ├── Features/
│   │   ├── MenuBar/                # StatusBarController, MenuBarView, DuaAfterAdzanView
│   │   ├── MainWindow/             # WindowManager (On-demand), MainWindowView
│   │   ├── PrayerSchedule/         # PrayerScheduleView, PrayerRowView, QiblaCompassView
│   │   ├── Quran/                  # QuranView, SurahListView, AyahDetailView, BookmarkListView
│   │   └── Settings/               # SettingsView
│   └── Resources/
│       ├── Quran/quran.json        # Data offline 114 Surah
│       └── Sounds/                 # Audio MP3 adzan
└── KawalPrayerTests/               # Unit tests (Perhitungan jadwal, Kiblat, Iqamah, Notifikasi)
```

---

## 📜 Lisensi

MIT License.
