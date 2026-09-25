import Foundation

enum IslamicCalendarHelper {

    private static let idMonths = [
        "Muharram", "Safar", "Rabi'ul Awal", "Rabi'ul Akhir",
        "Jumadil Awal", "Jumadil Akhir", "Rajab", "Sya'ban",
        "Ramadan", "Syawal", "Dzulqa'dah", "Dzulhijjah"
    ]

    private static let enMonths = [
        "Muharram", "Safar", "Rabi al-Awwal", "Rabi al-Thani",
        "Jumada al-Ula", "Jumada al-Thani", "Rajab", "Sha'ban",
        "Ramadan", "Shawwal", "Dhul Qi'dah", "Dhul Hijjah"
    ]

    private static let arMonths = [
        "محرّم", "صفر", "ربيع الأول", "ربيع الآخر",
        "جمادى الأولى", "جمادى الآخرة", "رجب", "شعبان",
        "رمضان", "شوال", "ذو القعدة", "ذو الحجة"
    ]

    static func islamicDateString(for date: Date = Date(), offsetDays: Int = 0, lang: AppLanguage = .id) -> String {
        let targetDate = offsetDays == 0 ? date : Calendar.current.date(byAdding: .day, value: offsetDays, to: date) ?? date
        let cal = Calendar(identifier: .islamicUmmAlQura)
        let comp = cal.dateComponents([.year, .month, .day], from: targetDate)
        guard let day = comp.day, let month = comp.month, let year = comp.year, month >= 1, month <= 12 else { return "" }

        let monthName: String
        let suffix: String
        switch lang {
        case .id:
            monthName = idMonths[month - 1]
            suffix = "H"
        case .en:
            monthName = enMonths[month - 1]
            suffix = "AH"
        case .ar:
            monthName = arMonths[month - 1]
            suffix = "هـ"
        }
        return "\(day) \(monthName) \(year) \(suffix)"
    }
}
