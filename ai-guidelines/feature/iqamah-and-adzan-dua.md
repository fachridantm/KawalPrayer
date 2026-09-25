# Feature: Iqamah & Dua After Adzan

KawalPrayer coordinates post-adzan workflows including automated Dua presentation and Iqamah countdown timers.

---

## 1. Automatic Dua After Adzan Pop-up

### Workflow Trigger
1. When adzan audio playback completes (or when user stops adzan via the notification or menu bar), `AudioService.shared.onAdzanFinished` triggers.
2. `AppState.handleAdzanFinished()` activates:
   - Sets `showDoaBanner = true`.
   - Calls `onShowPopoverRequested?()`, which opens the Menu Bar popover automatically so the user can immediately recite the Dua without opening the main window.
3. The Dua card displays:
   - Arabic text with RTL layout.
   - Latin transliteration.
   - Localized translation (Bahasa Indonesia or English).
4. Auto-dismisses after `duaDismissSeconds` (default: 60s, configurable in Settings; set to 0 to keep open until manual dismissal).

---

## 2. Iqamah Countdown Timer

### State Machine (`IqamahState`)
```swift
enum IqamahState: Equatable {
    case idle
    case countdown(prayerName: String, remaining: Int)
    case finished(prayerName: String)
}
```

### Lifecycle
1. Triggered immediately after Adzan completes if `iqamahEnabled` is `true`.
2. Computes `iqamahEndTime = Date().addingTimeInterval(minutes * 60)`.
3. Every second, `updateIqamahCountdown()` updates remaining time:
   - Status bar text changes to: `Iqamah <Prayer> • MM:SS`.
   - Menu bar popover displays adaptive red Outivox card (`OX.Color.iqamahContainer` and `OX.Color.iqamahAlert`).
4. When countdown reaches 0:
   - Sets `iqamahState = .finished`.
   - Sends notification: *"Waktu iqamah <Prayer>!"*.
   - Plays chime alert and updates UI to green finished badge (`OX.Color.iqamahFinishedContainer`).
