# Feature: Prayer Schedule & Calculations

KawalPrayer calculates prayer times mathematically offline based on solar astronomical algorithms.

---

## 1. Astronomical Calculation Engine

Defined in `Core/Services/PrayerTimeCalculator.swift`.

### Solar Transit (Dhuhr)
Calculated based on Julian Day, solar mean anomaly, equation of center, ecliptic longitude, and equation of time:
$$\text{Transit} = 12 + \text{Timezone} - \frac{\text{Longitude}}{15} - \frac{\text{EqT}}{60}$$

### Asr Calculation (Shadow Factor)
- **Syafi'i / Maliki / Hanbali (Default)**: Shadow factor $t = 1$.
- **Hanafi**: Shadow factor $t = 2$.
$$\text{Hour Angle} = \arccos\left(\frac{\sin(\operatorname{arccot}(t + \tan|\text{Latitude} - \delta|)) - \sin(\text{Latitude})\sin(\delta)}{\cos(\text{Latitude})\cos(\delta)}\right)$$

### Fajr & Isha Sun Depression Angles
- **Kemenag RI (Standard Indonesia)**: Fajr $20.0^\circ$, Isha $18.0^\circ$.
- **Muslim World League (MWL)**: Fajr $18.0^\circ$, Isha $17.0^\circ$.
- **ISNA (North America)**: Fajr $15.0^\circ$, Isha $15.0^\circ$.
- **Umm al-Qura (Makkah)**: Fajr $18.5^\circ$, Isha 90 minutes after Maghrib.
- **Egyptian General Authority**: Fajr $19.5^\circ$, Isha $17.5^\circ$.

---

## 2. Kemenag RI Safety Margin (+2 Minutes Ihtiyat)

- In Indonesia, official prayer schedules published by the Ministry of Religious Affairs (Kemenag RI / Bimas Islam) incorporate a **+2 minute Ihtiyat (safety margin)** added to calculated times (except Syuruq where 2 minutes are subtracted).
- KawalPrayer includes this +2 minute Ihtiyat by default so times match local mosques perfectly.
- Users can customize this offset in Settings (`ihtiyatMinutes`).

---

## 3. 24-Hour Continuous Countdown (Midnight Rollover)

- When all prayer times for the current day have passed (after Isha), the countdown does not disappear or show negative numbers.
- `PrayerTimeCalculator.calculateNextDayFajr` automatically computes Fajr for tomorrow (`Date().addingTimeInterval(86400)`), ensuring continuous, uninterrupted 24-hour countdowns.
