# 5. Background Agent & Audio Lifecycle

KawalPrayer operates as a quiet macOS background agent designed to run 24/7 without cluttering the user's workspace.

---

## 1. Background Agent Mode (`LSUIElement`)

- **Configuration**: `LSUIElement = true` in `Info.plist`.
- **Behavior**:
  - The app lives strictly in the macOS Menu Bar via `NSStatusItem`.
  - It does NOT appear in the Dock or in the Command-Tab (`⌘Tab`) application switcher.
  - The app does not display a window at launch.
  - If the user closes the main window, the window is hidden (`isReleasedWhenClosed = false`), and the background prayer scheduler remains active.
- **Optional Dock Visibility**:
  - In `SettingsView`, users can enable *"Tampilkan di Dock saat Jendela Terbuka"*.
  - When enabled, `WindowManager` dynamically switches the activation policy:
    ```swift
    NSApp.setActivationPolicy(.regular) // When window opens
    NSApp.setActivationPolicy(.accessory) // When window closes
    ```

---

## 2. Audio Playback Engine (`AudioService.swift`)

- **Technology**: Built on Apple's `AVFoundation` with `AVAudioPlayer`.
- **Playback Delegate**:
  - Conforms to `AVAudioPlayerDelegate`.
  - When playback finishes naturally:
    ```swift
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        onAdzanFinished?()
    }
    ```
- **Volume & Preview**:
  - Supports custom volume scaling (`adzanVolume`: 0.1 to 1.0).
  - Provides a one-click audio preview in `SettingsView`.

---

## 3. Interactive Notifications & Auto-Dismissal

- **Notification Category**:
  - Identifier: `"PRAYER_ALERT"`
  - Actions:
    1. `"STOP_ADZAN"`: Stops playing audio immediately without opening the window.
    2. `"DISMISS"`: Dismisses the banner.
- **Auto-Dismissal Workflow**:
  - When the adzan audio finishes playing (or the user stops it):
    ```swift
    NotificationService.shared.dismissAdzanNotification()
    ```
  - Removes delivered notifications from the macOS Notification Center automatically.
