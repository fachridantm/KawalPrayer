# 3. Code Style & Guardrails

This document establishes the technical rules and formatting requirements enforced across the KawalPrayer repository.

---

## 1. Zero Raw Literals Guardrail

Every contributor and AI agent must adhere strictly to the **Zero Raw Literals** standard:

```swift
// ❌ WRONG (Forbidden raw literals)
VStack(spacing: 8) {
    Text("Title")
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
}

// ✅ CORRECT (Outivox Tokens)
VStack(spacing: OX.Spacing.S) {
    Text("Title")
        .padding(.horizontal, OX.Spacing.L)
        .padding(.vertical, DimensToken.SIZE_12)
        .background(ColorToken.Green10)
        .clipShape(RoundedRectangle(cornerRadius: OX.Radius.S))
}
```

---

## 2. Multi-Line Parameter Formatting

When calling initializers, functions, or SwiftUI modifiers with **more than 1 argument**, each argument must be on its own line:

```swift
// ❌ WRONG (Single line with multiple arguments)
HStack(alignment: .center, spacing: 12) { ... }
Image(systemName: "star").frame(width: 24, height: 24)

// ✅ CORRECT (Multi-line parameter alignment)
HStack(
    alignment: .center,
    spacing: OX.Spacing.M
) {
    ...
}

Image(systemName: "star")
    .frame(
        width: DimensToken.SIZE_24,
        height: DimensToken.SIZE_24
    )
```

---

## 3. Swift Concurrency & `@MainActor` Isolation

- `AppState` is annotated with `@MainActor`. All property mutations, timer updates, and notification actions must execute on the Main Actor.
- Background asynchronous tasks (e.g. Geocoding, Notification permission) must switch back to the Main Actor before mutating `AppState`:
  ```swift
  Task { @MainActor [weak self] in
      self?.location = loc
      self?.refreshPrayerTimes()
  }
  ```

---

## 4. Nil Safety & Error Handling

- **No Force Unwraps**: The `!` operator is prohibited in production source code, with the sole exception of well-verified static regex or format strings.
- **Fail-Safe Fallbacks**: If location geocoding returns `nil`, fall back to the cached location or `LocationModel.defaultLocation`.

---

## 5. Comment Preservation

Never remove existing docstrings, explanation comments, or attribution notices. If logic is modified, update the comments to reflect the new behavior.
