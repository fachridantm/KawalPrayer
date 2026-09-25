# Feature: Location & Qibla Direction

KawalPrayer incorporates automatic CoreLocation monitoring and spherical trigonometric Qibla calculations.

---

## 1. Persistent Location & District Formatting

### The `LocationHelper` Engine
Defined in `Core/Services/LocationHelper.swift`:
```swift
LocationHelper.formatCityAndDistrict(from: place)
```
- Extracts `locality` (City) and `subLocality` (District / Kecamatan).
- Assembles them into standard format: `"<City>, <District>"` (e.g. `"Central Jakarta, Gambir"` or `"Bandung, Coblong"`).
- Deduplicates identical tokens (e.g. `"Singapore, Singapore"` becomes `"Singapore"`).

### Persistence Across Launches
- When resolved, the location model is immediately serialized and persisted to `UserDefaults` under key `"kawal_cached_location"`.
- On subsequent app launches, `AppState.loadFromStorage()` restores the cached location synchronously before network geocoding starts, eliminating startup delays or flickering fallback text.

### Battery-Efficient Tracking
- Uses `CLLocationManager` with a `distanceFilter` of 3,000 meters (3 km).
- Listens to significant location change events so the app updates seamlessly when the user travels, without draining battery.

---

## 2. Qibla Calculator (`QiblaCalculator.swift`)

Calculates the exact spherical Great Circle forward azimuth from user coordinates $(\phi_1, \lambda_1)$ to the Kaaba $(\phi_2 = 21.4225^\circ\text{ N}, \lambda_2 = 39.8262^\circ\text{ E})$:

$$\Delta\lambda = \lambda_2 - \lambda_1$$
$$y = \sin(\Delta\lambda)\cos(\phi_2)$$
$$x = \cos(\phi_1)\sin(\phi_2) - \sin(\phi_1)\cos(\phi_2)\cos(\Delta\lambda)$$
$$\text{Bearing} = (\operatorname{atan2}(y, x) \times \frac{180}{\pi} + 360) \pmod{360}$$

### Compass Visualization
Rendered in `Features/PrayerSchedule/QiblaCompassView.swift`:
- Shows a rotating Kaaba needle with Outivox Green (`ColorToken.Green`).
- Outer circle ring rendered with `OX.Color.outline(for: colorScheme)`.
- Displays numeric bearing degree, cardinal direction (e.g. `295° BLB`), and GPS coordinates.
