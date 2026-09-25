import SwiftUI
import AppKit

struct MushafPageView: View {

    let surah: Surah
    @Binding var arabicFontSize: Double
    @Binding var scrollToAyah: Int?
    @Binding var viewMode: QuranViewMode

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedAyahNumber: Int?
    @State private var showCopiedAlert = false
    @State private var starScale: CGFloat = 1.0

    private var startPage: Int {
        QuranReferenceHelper.startPage(forSurah: surah.id)
    }

    private var currentJuz: Int {
        let ayahNum = selectedAyahNumber ?? 1
        return QuranReferenceHelper.juz(forSurah: surah.id, ayah: ayahNum)
    }

    private var showBismillah: Bool {
        surah.id != 1 && surah.id != 9
    }

    private var selectedAyah: Ayah? {
        guard let num = selectedAyahNumber else { return nil }
        return surah.ayahs.first { $0.numberInSurah == num }
    }

    private var isSelectedAyahBookmarked: Bool {
        guard let ayah = selectedAyah else { return false }
        let key = "\(ayah.surahId)_\(ayah.numberInSurah)"
        return appState.settings.quranBookmarks.contains(key)
    }

    private var parchmentBackground: Color {
        OX.Color.background(for: colorScheme)
    }

    private var parchmentPageInner: Color {
        OX.Color.surface(for: colorScheme)
    }

    private var parchmentBorder: Color {
        OX.Color.outline(for: colorScheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation & Metadata Bar
            topBar

            Divider()

            // Main Mushaf Page Container
            ZStack(alignment: .bottom) {
                VStack(spacing: 8) {
                    // Surah Decorative Banner & Bismillah Header
                    VStack(spacing: 10) {
                        SurahBannerView(surah: surah)
                            .padding(.top, 12)

                        if showBismillah {
                            Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                                .font(.system(size: max(18, arabicFontSize * 0.72), weight: .regular))
                                .foregroundStyle(colorScheme == .dark ? Color(white: 0.9) : Color(white: 0.15))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 2)
                        }
                    }

                    // Continuous Flowing Arabic Text
                    MushafTextView(
                        surah: surah,
                        arabicFontSize: CGFloat(arabicFontSize),
                        selectedAyahNumber: selectedAyahNumber,
                        colorScheme: colorScheme,
                        onSelectAyah: { ayahNum in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedAyahNumber = ayahNum
                            }
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Page Footer Indicator (e.g. Page 453)
                    HStack {
                        Spacer()
                        Text("\(startPage)")
                            .font(.system(size: 11, weight: .medium, design: .serif))
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 20)
                            .padding(.bottom, 6)
                    }
                }
                .padding(.horizontal, OX.Spacing.L)
                .background(parchmentPageInner)
                .overlay(
                    RoundedRectangle(cornerRadius: OX.Radius.S)
                        .strokeBorder(parchmentBorder, lineWidth: OX.Border.WIDTH_1)
                        .padding(DimensToken.SIZE_6)
                )

                // Interactive Selected Ayah Action Card & Translation Drawer
                if let ayah = selectedAyah {
                    selectedAyahCard(ayah: ayah)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(parchmentBackground)
        }
        .onAppear {
            if let target = scrollToAyah {
                selectedAyahNumber = target
                scrollToAyah = nil
            }
        }
        .onChange(of: scrollToAyah) { _, target in
            if let target = target {
                withAnimation(.easeInOut) {
                    selectedAyahNumber = target
                }
                scrollToAyah = nil
            }
        }
    }

    // MARK: - Top Bar

    private var topBarMetadataText: String {
        let versesLabel = appState.settings.appLanguage == .id ? "Ayat" : (appState.settings.appLanguage == .en ? "Verses" : "آيات")
        let pageLabel = appState.settings.appLanguage == .id ? "Halaman" : (appState.settings.appLanguage == .en ? "Page" : "صفحة")
        let juzLabel = appState.settings.appLanguage == .ar ? "الجزء \(QuranReferenceHelper.easternArabicNumerals(from: currentJuz))" : "Juz' \(currentJuz)"
        return "\(pageLabel) \(startPage), \(juzLabel) • \(surah.ayahCount) \(versesLabel)"
    }

    private var viewModePicker: some View {
        Picker(
            "",
            selection: $viewMode
        ) {
            Label(
                String(localized: "Mushaf"),
                systemImage: "book.pages.fill"
            )
            .tag(QuranViewMode.mushaf)

            Label(
                String(localized: "Per Ayat"),
                systemImage: "list.bullet.rectangle.portrait.fill"
            )
            .tag(QuranViewMode.verseList)
        }
        .labelsHidden()
        .pickerStyle(.segmented)
        .fixedSize(
            horizontal: true,
            vertical: false
        )
        .onChange(of: viewMode) { _, newMode in
            appState.settings.quranViewMode = newMode
            appState.saveSettingsImmediately()
        }
    }

    private var fontSizeSlider: some View {
        HStack(spacing: DimensToken.SIZE_6) {
            Image(systemName: "textformat.size.smaller")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Slider(
                value: $arabicFontSize,
                in: 18...42,
                step: 1
            )
            .frame(width: DimensToken.SIZE_72)
            .onChange(of: arabicFontSize) {
                appState.saveSettingsImmediately()
            }

            Image(systemName: "textformat.size.larger")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .fixedSize(
            horizontal: true,
            vertical: false
        )
    }

    private var topBar: some View {
        ViewThatFits(in: .horizontal) {
            // Wide layout: Single horizontal bar
            HStack(spacing: OX.Spacing.M) {
                VStack(
                    alignment: .leading,
                    spacing: DimensToken.SIZE_2
                ) {
                    Text(surah.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Text(topBarMetadataText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .fixedSize(
                    horizontal: true,
                    vertical: false
                )

                Spacer(minLength: OX.Spacing.M)

                HStack(spacing: OX.Spacing.L) {
                    viewModePicker
                    fontSizeSlider
                }
                .fixedSize(
                    horizontal: true,
                    vertical: false
                )
            }

            // Compact layout: Two rows for small windows
            VStack(
                alignment: .leading,
                spacing: DimensToken.SIZE_8
            ) {
                HStack(
                    alignment: .firstTextBaseline,
                    spacing: OX.Spacing.S
                ) {
                    Text(surah.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Spacer(minLength: OX.Spacing.S)

                    Text(topBarMetadataText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                HStack(spacing: OX.Spacing.M) {
                    viewModePicker

                    Spacer(minLength: OX.Spacing.M)

                    fontSizeSlider
                }
            }
        }
        .padding(.horizontal, OX.Spacing.L)
        .padding(.vertical, DimensToken.SIZE_10)
        .background(.bar)
    }

    // MARK: - Selected Ayah Action Card & Translation Drawer

    private func selectedAyahCard(ayah: Ayah) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Ayah Reference + Action Pill
            HStack {
                HStack(spacing: 6) {
                    Text("\(surah.name) : \(ayah.numberInSurah)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accent(for: colorScheme))

                    let juzLabel = "Juz' \(QuranReferenceHelper.juz(forSurah: ayah.surahId, ayah: ayah.numberInSurah))"
                    Text("•  \(juzLabel)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Floating Action Buttons
                HStack(spacing: 8) {
                    // Bookmark Button
                    Button {
                        toggleBookmark(ayah: ayah)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isSelectedAyahBookmarked ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundStyle(isSelectedAyahBookmarked ? .yellow : .secondary)
                                .scaleEffect(starScale)
                            Text(isSelectedAyahBookmarked ? String(localized: "Tersimpan") : String(localized: "Simpan"))
                                .font(.caption2)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(.quaternary))
                    }
                    .buttonStyle(.plain)
                    .help(String(localized: "Bookmark ayat"))

                    // Copy Button
                    Button {
                        copyAyah(ayah: ayah)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: showCopiedAlert ? "checkmark" : "doc.on.doc")
                                .font(.caption)
                                .foregroundStyle(showCopiedAlert ? .green : .secondary)
                            Text(showCopiedAlert ? String(localized: "Tersalin") : String(localized: "Salin"))
                                .font(.caption2)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(.quaternary))
                    }
                    .buttonStyle(.plain)
                    .help(String(localized: "Salin ayat"))

                    // Close Button
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            selectedAyahNumber = nil
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help(String(localized: "Tutup"))
                }
            }

            Divider()

            // Translations
            VStack(alignment: .leading, spacing: 6) {
                // Indonesian
                VStack(alignment: .leading, spacing: 2) {
                    Text("ID")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text(ayah.translationId)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // English
                VStack(alignment: .leading, spacing: 2) {
                    Text("EN")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text(ayah.translationEn)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxHeight: 120)
        }
        .padding(OX.Spacing.M)
        .background(
            RoundedRectangle(cornerRadius: OX.Radius.L)
                .fill(.regularMaterial)
                .shadow(
                    color: .black.opacity(FloatToken.PERCENT_20),
                    radius: DimensToken.SIZE_10,
                    x: DimensToken.SIZE_0,
                    y: -DimensToken.SIZE_2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: OX.Radius.L)
                .strokeBorder(
                    Color.accent(for: colorScheme).opacity(FloatToken.PERCENT_40),
                    lineWidth: OX.Border.WIDTH_1
                )
        )
        .padding(.horizontal, OX.Spacing.M)
        .padding(.bottom, OX.Spacing.M)
    }

    // MARK: - Actions

    private func toggleBookmark(ayah: Ayah) {
        let key = "\(ayah.surahId)_\(ayah.numberInSurah)"
        withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
            if let index = appState.settings.quranBookmarks.firstIndex(of: key) {
                appState.settings.quranBookmarks.remove(at: index)
            } else {
                appState.settings.quranBookmarks.insert(key, at: 0)
            }
            starScale = 1.7
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                starScale = 1.0
            }
        }
        appState.saveSettingsImmediately()
    }

    private func copyAyah(ayah: Ayah) {
        let text = """
        \(ayah.arabicText)

        \(ayah.translationId)

        \(ayah.translationEn)
        """
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        showCopiedAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopiedAlert = false
        }
    }
}
