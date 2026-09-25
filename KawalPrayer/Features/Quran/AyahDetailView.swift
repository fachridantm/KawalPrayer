import AppKit
import SwiftUI

struct AyahDetailView: View {

    let surah: Surah
    @Binding var arabicFontSize: Double
    @Binding var scrollToAyah: Int?
    @Binding var viewMode: QuranViewMode

    @Environment(AppState.self) private var appState
    @State private var highlightedAyah: Int?

    private var showBismillah: Bool {
        surah.id != 1 && surah.id != 9
    }

    private var localizedMeaning: String {
        switch appState.settings.appLanguage {
        case .id: surah.indonesianName
        case .en: surah.englishName
        case .ar: surah.englishName
        }
    }

    var body: some View {
        @Bindable var appState = appState

        VStack(spacing: DimensToken.SIZE_0) {
            // Top Navigation & Mode Switcher Bar
            topBar

            Divider()

            // Ayat list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: OX.Spacing.L) {
                        // Surah Header Banner
                        VStack(spacing: DimensToken.SIZE_4) {
                            Text(surah.arabicName)
                                .font(.largeTitle)
                            Text(surah.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            let versesLabel = appState.settings.appLanguage == .id ? "Ayat" : (appState.settings.appLanguage == .en ? "Verses" : "آيات")
                            let revType = appState.settings.appLanguage == .en ? (surah.revelationType == "Makkiyah" ? "Meccan" : "Medinan") : surah.revelationType
                            Text("\(localizedMeaning) — \(surah.ayahCount) \(versesLabel) — \(revType)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DimensToken.SIZE_14)

                        // Bismillah separator
                        if showBismillah {
                            Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                                .font(.system(size: DimensToken.SIZE_20))
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                        }
                        ForEach(surah.ayahs) { ayah in
                            let key = "\(ayah.surahId)_\(ayah.numberInSurah)"
                            AyahRow(
                                ayah: ayah,
                                arabicFontSize: arabicFontSize,
                                isHighlighted: highlightedAyah == ayah.numberInSurah,
                                isBookmarked: appState.settings.quranBookmarks.contains(key),
                                onToggleBookmark: {
                                    withAnimation(.spring(
                                        response: 0.3,
                                        dampingFraction: 0.7
                                    )) {
                                        if let index = appState.settings.quranBookmarks.firstIndex(of: key) {
                                            appState.settings.quranBookmarks.remove(at: index)
                                        } else {
                                            appState.settings.quranBookmarks.insert(key, at: 0)
                                        }
                                    }
                                    appState.saveSettingsImmediately()
                                }
                            )
                            .id(ayah.numberInSurah)
                        }
                    }
                    .padding(OX.Spacing.XL)
                }
                .onAppear {
                    scrollToTarget(proxy: proxy)
                }
                .onChange(of: scrollToAyah) {
                    scrollToTarget(proxy: proxy)
                }
            }
        }
    }

    // MARK: - Top Bar

    private var topBarMetadataText: String {
        let versesLabel = appState.settings.appLanguage == .id ? "Ayat" : (appState.settings.appLanguage == .en ? "Verses" : "آيات")
        let revType = appState.settings.appLanguage == .en ? (surah.revelationType == "Makkiyah" ? "Meccan" : "Medinan") : surah.revelationType
        return "\(localizedMeaning) • \(surah.ayahCount) \(versesLabel) • \(revType)"
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

    private func scrollToTarget(proxy: ScrollViewProxy) {
        guard let target = scrollToAyah else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.4)) {
                proxy.scrollTo(target, anchor: .top)
            }
            // Flash highlight on the target ayah
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation(.easeIn(duration: 0.2)) {
                    highlightedAyah = target
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        highlightedAyah = nil
                    }
                }
            }
            scrollToAyah = nil
        }
    }
}

// MARK: - Ayah Row

private struct AyahRow: View {

    @Environment(\.colorScheme) private var colorScheme

    let ayah: Ayah
    let arabicFontSize: Double
    var isHighlighted: Bool = false
    var isBookmarked: Bool = false
    var onToggleBookmark: () -> Void = {}

    @State private var showCopied = false
    @State private var starScale: CGFloat = 1.0

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: OX.Spacing.M
        ) {
            // Ayah number badge + bookmark + copy button
            HStack {
                Text("\(ayah.numberInSurah)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(
                        width: DimensToken.SIZE_28,
                        height: DimensToken.SIZE_28
                    )
                    .background(Circle().strokeBorder(OX.Color.outline(for: colorScheme)))

                Spacer()

                Button {
                    onToggleBookmark()
                    withAnimation(.spring(
                        response: 0.25,
                        dampingFraction: 0.4
                    )) {
                        starScale = 1.8
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(
                            response: 0.3,
                            dampingFraction: 0.4
                        )) {
                            starScale = 1.0
                        }
                    }
                } label: {
                    Image(systemName: isBookmarked ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundStyle(isBookmarked ? ColorToken.Yellow : .secondary)
                        .scaleEffect(starScale)
                        .animation(
                            .easeInOut(duration: 0.2),
                            value: isBookmarked
                        )
                }
                .buttonStyle(.plain)
                .help(String(localized: "Bookmark ayat"))

                Button {
                    let text = """
                    \(ayah.arabicText)

                    \(ayah.translationId)

                    \(ayah.translationEn)
                    """
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                    showCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showCopied = false
                    }
                } label: {
                    Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                        .foregroundStyle(showCopied ? ColorToken.Green : .secondary)
                }
                .buttonStyle(.plain)
                .help(String(localized: "Salin ayat"))
            }

            // Arabic text
            Text(ayah.arabicText)
                .font(.system(size: arabicFontSize))
                .multilineTextAlignment(.trailing)
                .frame(
                    maxWidth: .infinity,
                    alignment: .trailing
                )
                .environment(\.layoutDirection, .rightToLeft)

            // Indonesian translation
            Text(ayah.translationId)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            // English translation
            Text(ayah.translationEn)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
        .padding(DimensToken.SIZE_12)
        .background(Color.accentBackground(for: colorScheme).opacity(FloatToken.PERCENT_50))
        .overlay(
            RoundedRectangle(cornerRadius: OX.Radius.M)
                .stroke(
                    ColorToken.Green,
                    lineWidth: isHighlighted ? OX.Border.WIDTH_2 : OX.Border.WIDTH_0_5
                )
                .opacity(isHighlighted ? FloatToken.PERCENT_100 : FloatToken.PERCENT_0)
        )
        .clipShape(RoundedRectangle(cornerRadius: OX.Radius.M))
    }
}
