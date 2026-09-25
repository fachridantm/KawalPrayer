import Foundation

enum QuranReferenceHelper {

    // MARK: - 30 Juz Boundaries (Surah, Ayah)

    private static let juzBoundaries: [(juz: Int, surah: Int, ayah: Int)] = [
        (1, 1, 1),
        (2, 2, 142),
        (3, 2, 253),
        (4, 3, 93),
        (5, 4, 24),
        (6, 4, 148),
        (7, 5, 82),
        (8, 6, 111),
        (9, 7, 88),
        (10, 8, 41),
        (11, 9, 93),
        (12, 11, 6),
        (13, 12, 53),
        (14, 15, 1),
        (15, 17, 1),
        (16, 18, 75),
        (17, 21, 1),
        (18, 23, 1),
        (19, 25, 21),
        (20, 27, 56),
        (21, 29, 46),
        (22, 33, 31),
        (23, 36, 28),
        (24, 39, 32),
        (25, 41, 47),
        (26, 46, 1),
        (27, 51, 31),
        (28, 58, 1),
        (29, 67, 1),
        (30, 78, 1)
    ]

    /// Calculates the Juz number (1...30) for a given Surah and Ayah.
    static func juz(forSurah surahId: Int, ayah: Int = 1) -> Int {
        var currentJuz = 1
        for boundary in juzBoundaries {
            if surahId > boundary.surah || (surahId == boundary.surah && ayah >= boundary.ayah) {
                currentJuz = boundary.juz
            }
        }
        return currentJuz
    }

    // MARK: - Madani Mushaf (604 Pages) Surah Start Page Mapping

    private static let surahStartPages: [Int] = [
        1, 2, 50, 77, 106, 128, 151, 177, 187, 208,
        221, 235, 249, 255, 262, 267, 282, 293, 305, 312,
        322, 332, 342, 350, 359, 367, 377, 385, 396, 404,
        411, 415, 418, 428, 434, 440, 446, 453, 458, 467,
        477, 483, 489, 496, 499, 502, 507, 511, 515, 518,
        520, 523, 526, 528, 531, 534, 537, 542, 545, 549,
        551, 553, 554, 556, 558, 560, 562, 564, 566, 568,
        570, 572, 574, 575, 577, 578, 580, 582, 583, 585,
        586, 587, 587, 589, 590, 591, 591, 592, 593, 594,
        595, 595, 596, 596, 597, 597, 598, 598, 599, 599,
        600, 600, 601, 601, 601, 602, 602, 602, 603, 603,
        603, 604, 604, 604
    ]

    /// Starting page in standard Madani 604-page Mushaf.
    static func startPage(forSurah surahId: Int) -> Int {
        guard surahId >= 1 && surahId <= surahStartPages.count else { return 1 }
        return surahStartPages[surahId - 1]
    }

    // MARK: - Arabic Text Cleaning for Mushaf

    /// Prepares Arabic text for continuous Mushaf reading.
    /// Strips the repeated Bismillah prefix from Ayah 1 (since Bismillah is displayed in the ornamental header).
    static func cleanArabicText(for ayah: Ayah, isFirstAyah: Bool) -> String {
        var text = ayah.arabicText.replacingOccurrences(of: "\u{FEFF}", with: "")

        if isFirstAyah && ayah.surahId != 1 && ayah.surahId != 9 {
            let bismillahPrefixes = [
                "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ",
                "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ",
                "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
                "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
            ]
            for prefix in bismillahPrefixes {
                if text.hasPrefix(prefix) {
                    text = String(text.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
                    break
                }
            }
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Converts an integer to Eastern Arabic numerals (١, ٢, ٣...).
    static func easternArabicNumerals(from number: Int) -> String {
        let arabicDigits = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
        return String(number).compactMap { char -> String? in
            guard let digit = Int(String(char)), digit >= 0, digit <= 9 else { return nil }
            return arabicDigits[digit]
        }.joined()
    }
}
