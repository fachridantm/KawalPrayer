import Foundation

struct Dua: Identifiable, Equatable {
    var id: String { titleId }
    let titleId: String
    let titleEn: String
    let arabic: String
    let transliteration: String
    let translationId: String
    let translationEn: String

    var title: String { titleId }
    var translation: String { translationId }

    func title(for lang: AppLanguage) -> String {
        lang == .id ? titleId : titleEn
    }

    func translation(for lang: AppLanguage) -> String {
        lang == .id ? translationId : translationEn
    }
}

extension Dua {
    static let all: [Dua] = [
        Dua(
            titleId: "Doa Setelah Adzan — HR. Bukhari",
            titleEn: "Supplication After the Call to Prayer (Adzan) — Sahih al-Bukhari",
            arabic: "اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ",
            transliteration: "Allāhumma Rabba hāżihid da'watit tāmmah, waṣ-ṣalātil qā'imah, āti Muḥammadanil wasīlata wal faḍīlah, wab'aṡhu maqāman maḥmūdanil lażī wa'adtah.",
            translationId: "Ya Allah, Tuhan pemilik seruan yang sempurna ini dan sholat yang akan ditegakkan, karuniakanlah kepada Muhammad wasilah dan keutamaan, dan bangkitkanlah beliau ke tempat terpuji yang telah Engkau janjikan.",
            translationEn: "O Allah, Lord of this perfect call and the prayer to be offered, grant Muhammad the privilege and eminence, and raise him to the praiseworthy station that You have promised him."
        ),
        Dua(
            titleId: "Keutamaan Antara Adzan & Iqamah — HR. Abu Dawud, Tirmidzi",
            titleEn: "Virtue of Supplication Between Adzan & Iqamah — Abu Dawud & at-Tirmidhi",
            arabic: "الدُّعَاءُ لَا يُرَدُّ بَيْنَ الْأَذَانِ وَالْإِقَامَةِ",
            transliteration: "Ad-du'ā'u lā yuraddu bainal ażāni wal iqāmah.",
            translationId: "Doa tidak akan ditolak antara adzan dan iqamah. Berdoalah dengan sungguh-sungguh di waktu ini.",
            translationEn: "Supplication made between the adzan and the iqamah is not rejected. Supplicate sincerely during this time."
        ),
        Dua(
            titleId: "Doa Sapu Jagad — QS. Al-Baqarah: 201",
            titleEn: "Comprehensive Supplication — Surah Al-Baqarah: 201",
            arabic: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
            transliteration: "Rabbanā ātinā fid dunyā ḥasanah, wa fil ākhirati ḥasanah, wa qinā 'ażāban nār.",
            translationId: "Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat, dan lindungilah kami dari azab neraka.",
            translationEn: "Our Lord, give us in this world that which is good and in the Hereafter that which is good, and protect us from the punishment of the Fire."
        ),
        Dua(
            titleId: "Memohon Ilmu, Rezeki & Amal Diterima — HR. Ibnu Majah",
            titleEn: "Supplication for Beneficial Knowledge, Sustenance & Accepted Deeds — Ibn Majah",
            arabic: "اللَّهُمَّ إِنِّI أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا وَعَمَلًا مُتَقَبَّلًا",
            transliteration: "Allāhumma innī as'aluka 'ilman nāfi'ā, wa rizqan ṭayyibā, wa 'amalan mutaqabbalā.",
            translationId: "Ya Allah, aku memohon kepada-Mu ilmu yang bermanfaat, rezeki yang baik, dan amal yang diterima.",
            translationEn: "O Allah, I ask You for beneficial knowledge, wholesome sustenance, and deeds that are accepted."
        ),
        Dua(
            titleId: "Sayyidul Istighfar — HR. Bukhari",
            titleEn: "The Master of Seeking Forgiveness (Sayyidul Istighfar) — Sahih al-Bukhari",
            arabic: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ",
            transliteration: "Allāhumma Anta Rabbī lā ilāha illā Anta, khalaqtanī wa ana 'abduka, wa ana 'alā 'ahdika wa wa'dika mastaṭa'tu, a'ūżu bika min syarri mā ṣana'tu, abū'u laka bini'matika 'alayya wa abū'u biżanbī, faghfir lī fa innahu lā yaghfiruż żunūba illā Anta.",
            translationId: "Ya Allah, Engkau Tuhanku, tidak ada tuhan selain Engkau. Engkau menciptakanku dan aku hamba-Mu. Aku berada di atas perjanjian dan janji-Mu semampuku. Aku berlindung kepada-Mu dari keburukan yang kuperbuat. Aku mengakui nikmat-Mu kepadaku dan mengakui dosaku, maka ampunilah aku, sesungguhnya tidak ada yang mengampuni dosa selain Engkau.",
            translationEn: "O Allah, You are my Lord, there is no deity worthy of worship except You. You created me and I am Your servant, and I abide by Your covenant and promise as best I can. I seek refuge in You from the evil of what I have done. I acknowledge Your favor upon me, and I acknowledge my sin, so forgive me, for none can forgive sins except You."
        ),
        Dua(
            titleId: "Perlindungan Dari Empat Hal — HR. Muslim",
            titleEn: "Refuge From Four Afflictions — Sahih Muslim",
            arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ وَمِنْ عَذَابِ جَهَنَّمَ وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ وَمِنْ شَرِّ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ",
            transliteration: "Allāhumma innī a'ūżu bika min 'ażābil qabr, wa min 'ażābi jahannam, wa min fitnatil maḥyā wal mamāt, wa min syarri fitnatil masīḥid dajjāl.",
            translationId: "Ya Allah, aku berlindung kepada-Mu dari siksa kubur, dari siksa neraka Jahannam, dari fitnah kehidupan dan kematian, dan dari kejahatan fitnah Dajjal.",
            translationEn: "O Allah, I seek refuge in You from the torment of the grave, from the torment of Hellfire, from the trials of life and death, and from the evil trial of the False Messiah (Dajjal)."
        )
    ]
}
