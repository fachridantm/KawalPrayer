# Feature: Offline Quran & Mushaf

KawalPrayer features a complete offline Quran reader with dual visualization modes: an authentic Medina Mushaf page layout and a vertical per-ayah translation view.

---

## 1. Dual View Modes (`QuranViewMode`)

Users can switch seamlessly between two reading experiences using a segmented picker:

### A. Authentic Medina Mushaf Mode (`QuranViewMode.mushaf`)
- Rendered via `MushafPageView.swift` and `MushafTextView.swift`.
- **Authentic Calligraphic Banner (`SurahBannerView.swift`)**:
  - Outivox geometric border with floral corners (`ColorToken.Green`).
  - Centered golden frame displaying the surah name in Arabic calligraphy and ayah count.
- **Continuous Flowing Arabic Text**:
  - Implemented via a high-performance native AppKit `NSTextView` wrapper (`InteractiveMushafTextView`).
  - Text alignment is centered and Right-to-Left (RTL).
  - Circled ayah number badges are generated dynamically as `NSTextAttachment` images with Outivox border width and green outlines.
- **Interactive Ayah Inspection**:
  - Clicking any ayah or badge in the Mushaf highlights the entire verse in Outivox Green (`ColorToken.Green10` / `ColorToken.Green90`) and presents an animated bottom translation card with Latin transliteration and Indonesian/English translation.

### B. Per-Ayah List Mode (`QuranViewMode.verseList`)
- Rendered via `AyahDetailView.swift`.
- Vertical list of individual cards with ayah number badges, Arabic text, Indonesian translation, and English translation.
- One-click copy button copying Arabic + translations to clipboard.
- Star bookmark button with bounce animation.

---

## 2. Bookmark System

- Stored in `PrayerSettings.quranBookmarks` as unique string keys: `"<surahId>_<numberInSurah>"` (e.g. `"2_255"` for Ayat al-Kursi).
- Rendered in `BookmarkListView.swift`.
- Clicking any bookmark switches back to the Quran reader and smoothly scrolls the target ayah into view.

---

## 3. Offline Data & Search

- Bundled in `quran.json` inside the app bundle — zero internet connectivity required.
- Fast multi-term search across surah names (Indonesian, English, Arabic) and translations.
