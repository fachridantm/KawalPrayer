# KawalPrayer AI Guidelines & Technical Documentation Index

Welcome to the comprehensive documentation index for **KawalPrayer**. This directory contains architectural specifications, design token standards, coding guardrails, and feature implementation guides for developers and AI agents.

---

## 🏛️ Core Architecture & Foundation Guidelines

| Document | Description |
|---|---|
| [1. Architectural Patterns & Services](1-architectural-patterns.md) | Single Source of Truth (`AppState`), `@Observable` macro, clean service separation, AppKit window and popover integration, and persistence. |
| [2. Design Tokens & Theming](2-design-tokens-theming.md) | The Outivox Design Token System (`ColorToken`, `DimensToken`, `FloatToken`, `OX` facade, `GoogleColorDivider`), signature geometry, and the Zero Raw Literals rule. |
| [3. Code Style & Guardrails](3-code-style-and-guardrails.md) | Multi-line argument formatting, zero raw dimension/opacity literals, MainActor concurrency, nil-safety, and test requirements. |
| [4. Localization & Internationalization](4-localization-and-internationalization.md) | Multi-language engine (Bahasa Indonesia, English, Arabic RTL), Hijri calendar offset calculations, and localized date/number formatters. |
| [5. Background Agent & Audio Lifecycle](5-background-agent-and-audio.md) | `LSUIElement = true` macOS background agent mode, `AVAudioPlayer` session handling, interactive notification actions (`stopAdzan`), and auto-dismissal. |

---

## 📱 Feature Specifications & Guides

| Feature Document | Scope & Key Components |
|---|---|
| [Menu Bar Agent](feature/menu-bar-agent.md) | Status bar item lifecycle, 5 display modes (Icon+Name+Countdown, Icon+Countdown, etc.), dynamic prayer icon switching, popover attachment. |
| [Prayer Schedule & Calculations](feature/prayer-schedule-and-calculations.md) | Astronomical calculation formulas, Kemenag RI +2 min Ihtiyat safety margin, Shafii/Hanafi Asr shadow factors, midnight Fajr rollover. |
| [Location & Qibla Direction](feature/location-and-qibla.md) | Real-time CoreLocation monitoring, persistent `City, District/Kecamatan` formatting (`LocationHelper`), Great Circle Kaaba azimuth and visual compass. |
| [Iqamah & Adzan Dua](feature/iqamah-and-adzan-dua.md) | Configurable Iqamah countdown timer with finished notification, automatic Menu Bar pop-up displaying Dua after Adzan. |
| [Offline Quran & Mushaf](feature/offline-quran-and-mushaf.md) | Dual-mode Quran (Authentic Medina Mushaf page view with ayah badges & Per-Ayah vertical list), offline JSON dataset, bookmarks, and search. |
| [Settings & Customization](feature/settings-and-customization.md) | Audio volume slider and previews, per-prayer notifications and audio toggles, display modes, launch at login via `SMAppService`. |

---

## 🚀 Quick Commands

```bash
# Build Debug
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project KawalPrayer.xcodeproj -scheme KawalPrayer -configuration Debug build

# Run Unit Tests
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project KawalPrayer.xcodeproj -scheme KawalPrayer test

# Build Release DMG Package
./scripts/build_dmg.sh
```
