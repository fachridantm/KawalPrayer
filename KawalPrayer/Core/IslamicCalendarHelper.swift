import Foundation

enum IslamicCalendarHelper {

    private static let monthKeys: [LocalizedStringResource] = [
        "Muharram", "Safar", "Rabi'ul Awal", "Rabi'ul Akhir",
        "Jumadil Awal", "Jumadil Akhir", "Rajab", "Sya'ban",
        "Ramadan", "Syawal", "Dzulqa'dah", "Dzulhijjah"
    ]

    static func islamicDateString(for date: Date = Date(), offsetDays: Int = 0) -> String {
        let targetDate = offsetDays == 0 ? date : Calendar.current.date(byAdding: .day, value: offsetDays, to: date) ?? date
        let cal = Calendar(identifier: .islamicUmmAlQura)
        let comp = cal.dateComponents([.year, .month, .day], from: targetDate)
        guard let day = comp.day, let month = comp.month, let year = comp.year, month >= 1, month <= 12 else { return "" }
        let monthName = String(localized: monthKeys[month - 1])
        return "\(day) \(monthName) \(year) H"
    }
}
