# KawalPrayer

<div align="center">
  <img src="KawalPrayer/Assets.xcassets/AppIcon.appiconset/icon_128x128.png" width="96" height="96" alt="KawalPrayer Icon" />
  <h3>Aplikasi Pengingat Waktu Sholat, Adzan, & Al-Quran Menu Bar untuk macOS</h3>
  <p><b>by Outivox</b></p>

  [![macOS](https://img.shields.io/badge/macOS-14%2B-black?logo=apple&logoColor=white)](https://apple.com/macos)
  [![Swift](https://img.shields.io/badge/Swift-5.9%20%2F%206-orange?logo=swift&logoColor=white)](https://swift.org)
  [![SwiftUI](https://img.shields.io/badge/SwiftUI-%40Observable-blue)](https://developer.apple.com/xcode/swiftui/)
  [![Outivox Design System](https://img.shields.io/badge/Outivox-Design%20Tokens-34A853)](ai-guidelines/2-design-tokens-theming.md)
  [![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
</div>

---

**KawalPrayer** adalah aplikasi menu bar macOS native yang dirancang untuk bekerja secara senyap di background tanpa mengotori Dock atau app switcher (`⌘Tab`). Dilengkapi dengan perhitungan astronomi hisab akurat standar Kementerian Agama RI (+2 menit Ihtiyat), Al-Quran 30 juz offline dengan tampilan Mushaf Madinah otentik, kompas arah kiblat, notifikasi interaktif, serta pop-up otomatis doa setelah adzan.

Didesain dengan identitas visual khas **Outivox** berbasis **Outivox Design Token System** (`ColorToken`, `DimensToken`, `FloatToken`, dan `OX` facade) dengan aturan *Zero Raw Literals*.

---

## 🌟 Fitur Unggulan

### 1. Senyap di Background (`LSUIElement = true`)
- Tinggal di macOS Menu Bar tanpa memunculkan ikon di Dock atau `⌘Tab` saat startup.
- Jendela utama (Dashboard, Al-Quran, Pengaturan) hanya dibuka saat Anda memilih **"Buka KawalPrayer"**.
- Menutup jendela (`⌘W` atau tombol merah) hanya menyembunyikannya; aplikasi tetap siaga menjaga jadwal waktu sholat.
- Opsi *"Tampilkan di Dock saat Jendela Terbuka"* tersedia di Pengaturan bagi pengguna yang menginginkan integrasi Dock standar saat jendela aktif.

### 2. Format Menu Bar & Ikon Dinamis
- **5 Pilihan Tampilan Status Bar** (ideal untuk MacBook ber-notch maupun monitor lebar):
  1. `Icon + Nama + Hitung Mundur` *(Default, contoh: `🌙 Subuh • 00:45`)*
  2. `Icon + Hitung Mundur` *(contoh: `🌙 00:45`)*
  3. `Icon + Nama Sholat` *(contoh: `🌙 Subuh`)*
  4. `Icon + Waktu Sholat` *(contoh: `🌙 Subuh 04:35`)*
  5. `Hanya Icon` *(contoh: `🌙`)*
- **Ikon Menu Bar Dinamis**: Dapat menampilkan ikon sholat yang sedang aktif (mis. `sun.haze.fill` saat Dzuhur), sholat berikutnya, atau ikon bulan sabit statis.

### 3. Deteksi Lokasi Persisten dengan Kecamatan/Distrik
- Menggunakan CoreLocation untuk mendeteksi pergerakan secara hemat daya (filter jarak 3 km).
- Memformat nama lokasi secara lengkap dan elegan: **`Kota/Wilayah, Kecamatan/Distrik`** (contoh: **`Central Jakarta, Gambir`** atau **`Bandung, Coblong`**).
- **Penyimpanan Persisten**: Lokasi terakhir disimpan ke `UserDefaults` sehingga saat aplikasi dibuka kembali, lokasi langsung tampil seketika tanpa jeda atau reset sementara ke default.
- Tombol **Perbarui Lokasi GPS** tersedia di header popover menu bar dan menu Pengaturan.

### 4. Akurasi Jadwal Sholat Kemenag RI (+2 Menit Ihtiyat)
- Perhitungan hisab astronomi offline dilengkapi **Pengaman Waktu (Ihtiyat)** standar Kementerian Agama RI (+2 menit default) agar waktu adzan cocok dengan masjid sekitar dan jadwal resmi Bimas Islam.
- Pilihan madhab Ashar: **Syafi'i / Maliki / Hanbali** (bayangan 1×) atau **Hanafi** (bayangan 2×).
- Pilihan hisab internasional: Muslim World League (MWL), ISNA, Umm al-Qura (Makkah), dan Egyptian.
- **Hitung Mundur 24 Jam Tanpa Putus**: Setelah waktu Isya lewat, hitung mundur otomatis beralih menghitung waktu Subuh esok hari tanpa jeda.

### 5. Pop-up Otomatis Doa Setelah Adzan & Iqamah Timer
- Begitu adzan selesai (atau setelah pengguna menekan "Hentikan Adzan"), popover menu bar otomatis terbuka menampilkan kartu **Doa Setelah Adzan** lengkap dengan teks Arab, transliterasi Latin, dan terjemahan.
- **Iqamah Timer**: Penghitung mundur jeda adzan dan iqamah (1–30 menit) dengan notifikasi *"Waktu iqamah <Sholat>!"* saat waktu tiba.

### 6. Notifikasi Interaktif dengan Action Button
- Banner notifikasi saat masuk waktu sholat dilengkapi tombol aksi:
  - **"Hentikan Adzan"**: Menghentikan lantunan audio adzan langsung dari notifikasi tanpa perlu membuka aplikasi.
  - **"Tutup"**: Menutup notifikasi.
- **Auto-Dismiss**: Notifikasi otomatis dibersihkan dari Notification Center begitu audio adzan selesai diputar.

### 7. Al-Quran 30 Juz Offline (Mushaf Madinah & Per Ayat)
- **114 Surah Lengkap Offline** — 100% tanpa koneksi internet.
- **Mode Tampilan Ganda**:
  - **Mushaf Madinah**: Layout halaman mushaf berkesinambungan dengan kaligrafi surah otentik (`SurahBannerView`), nomor ayat lingkaran interaktif, dan terjemahan pop-up saat ayat diketuk.
  - **Per Ayat**: Tampilan daftar vertikal per ayat dengan tombol salin dan bookmark instan.
- Pencarian cepat dan slider ukuran font Arab (18–40pt).

### 8. Kompas Arah Kiblat Real-Time
- Menghitung derajat azimuth lingkaran besar (*Great Circle*) ke Ka'bah di Makkah (`21.4225° N, 39.8262° E`).
- Kompas visual dengan jarum Ka'bah berwarna Outivox Green (`ColorToken.Green`) dan teks arah mata angin (mis. `295° BLB`).

---

## 🏗️ Arsitektur & Pedoman Pengembangan

Dokumentasi lengkap arsitektur dan pedoman AI agent tersedia di:
- [**AGENTS.md**](AGENTS.md) — Aturan teknis dan guardrails utama.
- [**ai-guidelines/INDEX.md**](ai-guidelines/INDEX.md) — Indeks dokumentasi teknis & spesifikasi fitur:
  - [1. Architectural Patterns & Services](ai-guidelines/1-architectural-patterns.md)
  - [2. Design Tokens & Theming](ai-guidelines/2-design-tokens-theming.md)
  - [3. Code Style & Guardrails](ai-guidelines/3-code-style-and-guardrails.md)
  - [4. Localization & Internationalization](ai-guidelines/4-localization-and-internationalization.md)
  - [5. Background Agent & Audio Lifecycle](ai-guidelines/5-background-agent-and-audio.md)

---

## 🛠️ Cara Membangun (Build from Source)

### Prasyarat
- macOS 14.0 (Sonoma) atau lebih baru
- Xcode 15 / 16 / 27+ di `/Applications/Xcode.app`

### Build & Run
```bash
# Debug Build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project KawalPrayer.xcodeproj \
  -scheme KawalPrayer \
  -configuration Debug build

# Jalankan Unit Tests (29 tests)
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project KawalPrayer.xcodeproj \
  -scheme KawalPrayer test
```

### Membuat File Installer DMG
Jalankan script otomatis pembuatan DMG:
```bash
./scripts/build_dmg.sh
```
File installer `KawalPrayer-v1.0.0.dmg` akan langsung siap di root folder.

---

## 📄 Lisensi & Hak Cipta
Dibuat dengan ❤️ oleh **Outivox**.
Didistribusikan di bawah lisensi MIT.
