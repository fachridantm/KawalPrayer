import SwiftUI

struct QuranView: View {

    var isActive: Bool = true

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedSurahId: Int?
    @State private var searchText = ""
    @State private var showBookmarks = false
    @State private var scrollToAyah: Int?

    private let quranService = QuranService.shared

    var body: some View {
        @Bindable var appState = appState

        HStack(spacing: DimensToken.SIZE_0) {
            // Left: Surah list
            SurahListView(
                surahs: quranService.surahs,
                selectedSurahId: $selectedSurahId,
                searchText: $searchText,
                showBookmarks: $showBookmarks,
                onSelectSurah: { _ in showBookmarks = false }
            )
            .frame(width: DimensToken.SIZE_80 * 3 + DimensToken.SIZE_16)
            .clipped()

            Divider()

            // Right: Bookmark list or Ayah detail
            if showBookmarks {
                BookmarkListView { surahId, numberInSurah in
                    scrollToAyah = nil
                    selectedSurahId = surahId
                    showBookmarks = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        scrollToAyah = numberInSurah
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
            } else if let surahId = selectedSurahId,
               let surah = quranService.surah(byId: surahId) {
                Group {
                    if appState.settings.quranViewMode == .mushaf {
                        MushafPageView(
                            surah: surah,
                            arabicFontSize: $appState.settings.quranArabicFontSize,
                            scrollToAyah: $scrollToAyah,
                            viewMode: $appState.settings.quranViewMode
                        )
                    } else {
                        AyahDetailView(
                            surah: surah,
                            arabicFontSize: $appState.settings.quranArabicFontSize,
                            scrollToAyah: $scrollToAyah,
                            viewMode: $appState.settings.quranViewMode
                        )
                    }
                }
                .id(surahId)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .clipped()
            } else {
                emptyState
            }
        }
        .padding(.top, DimensToken.SIZE_52)
        .onAppear {
            if let lastId = appState.settings.quranLastSurahId {
                selectedSurahId = lastId
            }
        }
        .onChange(of: selectedSurahId) { _, newValue in
            appState.settings.quranLastSurahId = newValue
            appState.saveSettingsImmediately()
        }
    }

    private var emptyState: some View {
        VStack(spacing: OX.Spacing.M) {
            Image(systemName: "book.fill")
                .font(.system(size: DimensToken.SIZE_48))
                .foregroundStyle(.tertiary)

            Text(String(localized: "Pilih surah untuk membaca"))
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}
