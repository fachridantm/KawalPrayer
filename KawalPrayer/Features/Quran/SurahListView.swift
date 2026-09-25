import SwiftUI

struct SurahListView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    let surahs: [Surah]
    @Binding var selectedSurahId: Int?
    @Binding var searchText: String
    @Binding var showBookmarks: Bool
    var onSelectSurah: ((_ surahId: Int) -> Void)?

    private var filteredSurahs: [Surah] {
        QuranService.shared.search(query: searchText)
    }

    private var bookmarkCount: Int {
        appState.settings.quranBookmarks.count
    }

    var body: some View {
        VStack(spacing: DimensToken.SIZE_0) {
            // Inline search field
            HStack(spacing: DimensToken.SIZE_6) {
                Image(systemName: "magnifyingglass")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField(
                    String(localized: "Cari surah..."),
                    text: $searchText
                )
                .textFieldStyle(.plain)
                .font(.subheadline)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(DimensToken.SIZE_8)
            .background(.bar)

            // Bookmark entry point
            if bookmarkCount > 0 {
                Button {
                    showBookmarks.toggle()
                } label: {
                    HStack(spacing: DimensToken.SIZE_6) {
                        Image(systemName: showBookmarks ? "bookmark.fill" : "bookmark")
                            .font(.caption)
                            .foregroundStyle(Color.accent(for: colorScheme))
                        Text(String(localized: "Ayat Tersimpan"))
                            .font(.caption)
                        Spacer()
                        Text("\(bookmarkCount)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, DimensToken.SIZE_6)
                            .padding(.vertical, DimensToken.SIZE_2)
                            .background(Capsule().fill(ColorToken.Green))
                            .id("badge_\(bookmarkCount)")
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                            .animation(
                                .spring(response: 0.3, dampingFraction: 0.7),
                                value: bookmarkCount
                            )
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, DimensToken.SIZE_10)
                    .padding(.vertical, DimensToken.SIZE_6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Divider()

            List(filteredSurahs) { surah in
                SurahRow(
                    surah: surah,
                    isSelected: selectedSurahId == surah.id && !showBookmarks,
                    appLanguage: appState.settings.appLanguage
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedSurahId = surah.id
                    onSelectSurah?(surah.id)
                }
                .listRowInsets(EdgeInsets(
                    top: DimensToken.SIZE_2,
                    leading: DimensToken.SIZE_8,
                    bottom: DimensToken.SIZE_2,
                    trailing: DimensToken.SIZE_8
                ))
            }
            .listStyle(.inset)
        }
    }
}

// MARK: - Surah Row

private struct SurahRow: View {

    @Environment(\.colorScheme) private var colorScheme

    let surah: Surah
    let isSelected: Bool
    let appLanguage: AppLanguage

    private var localizedMeaning: String {
        switch appLanguage {
        case .id: surah.indonesianName
        case .en: surah.englishName
        case .ar: surah.englishName
        }
    }

    var body: some View {
        HStack(spacing: OX.Spacing.M) {
            Text("\(surah.id)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? Color.white.opacity(FloatToken.PERCENT_80) : .secondary)
                .frame(
                    width: DimensToken.SIZE_28,
                    height: DimensToken.SIZE_28
                )
                .background(
                    Circle().strokeBorder(
                        isSelected
                            ? Color.white.opacity(FloatToken.PERCENT_30)
                            : Color.secondary.opacity(FloatToken.PERCENT_30)
                    )
                )

            VStack(
                alignment: .leading,
                spacing: DimensToken.SIZE_2
            ) {
                Text(surah.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text(localizedMeaning)
                    .font(.caption)
                    .foregroundStyle(isSelected ? Color.white.opacity(FloatToken.PERCENT_70) : .secondary)
            }

            Spacer()

            VStack(
                alignment: .trailing,
                spacing: DimensToken.SIZE_2
            ) {
                Text(surah.arabicName)
                    .font(.body)
                Text(appLanguage == .id ? "\(surah.ayahCount) ayat" : (appLanguage == .en ? "\(surah.ayahCount) verses" : "\(surah.ayahCount) آية"))
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Color.white.opacity(FloatToken.PERCENT_70) : .secondary)
            }
        }
        .foregroundStyle(isSelected ? Color.white : Color.primary)
        .padding(.vertical, DimensToken.SIZE_6)
        .padding(.horizontal, DimensToken.SIZE_8)
        .background(
            RoundedRectangle(cornerRadius: OX.Radius.S)
                .fill(isSelected ? ColorToken.Green : Color.clear)
        )
    }
}
