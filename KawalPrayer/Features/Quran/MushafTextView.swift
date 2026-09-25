import AppKit
import SwiftUI

struct MushafTextView: NSViewRepresentable {

    let surah: Surah
    let arabicFontSize: CGFloat
    let selectedAyahNumber: Int?
    let colorScheme: ColorScheme
    let onSelectAyah: (Int?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true

        let textView = InteractiveMushafTextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.drawsBackground = false
        textView.textContainer?.lineFragmentPadding = 12
        textView.textContainer?.widthTracksTextView = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]

        textView.onAyahClicked = { ayahNum in
            context.coordinator.parent.onSelectAyah(ayahNum)
        }

        scrollView.documentView = textView
        context.coordinator.textView = textView

        context.coordinator.updateContent(surah: surah, fontSize: arabicFontSize, colorScheme: colorScheme, selectedAyah: selectedAyahNumber)

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.updateContent(
            surah: surah,
            fontSize: arabicFontSize,
            colorScheme: colorScheme,
            selectedAyah: selectedAyahNumber
        )
    }

    // MARK: - Coordinator

    final class Coordinator {
        var parent: MushafTextView
        fileprivate weak var textView: InteractiveMushafTextView?

        private var lastSurahId: Int?
        private var lastFontSize: CGFloat?
        private var lastColorScheme: ColorScheme?
        private var lastSelectedAyah: Int?
        private var ayahRanges: [Int: NSRange] = [:]

        init(_ parent: MushafTextView) {
            self.parent = parent
        }

        func updateContent(surah: Surah, fontSize: CGFloat, colorScheme: ColorScheme, selectedAyah: Int?) {
            guard textView != nil else { return }

            let needsFullRebuild = (lastSurahId != surah.id || lastFontSize != fontSize || lastColorScheme != colorScheme)

            if needsFullRebuild {
                lastSurahId = surah.id
                lastFontSize = fontSize
                lastColorScheme = colorScheme
                lastSelectedAyah = selectedAyah

                rebuildAttributedString(surah: surah, fontSize: fontSize, colorScheme: colorScheme, selectedAyah: selectedAyah)
            } else if lastSelectedAyah != selectedAyah {
                lastSelectedAyah = selectedAyah
                updateHighlightOnly(selectedAyah: selectedAyah, colorScheme: colorScheme)
            }
        }

        private func rebuildAttributedString(surah: Surah, fontSize: CGFloat, colorScheme: ColorScheme, selectedAyah: Int?) {
            guard let textView = textView else { return }

            let isDark = (colorScheme == .dark)
            let textColor = isDark ? NSColor(white: 0.94, alpha: 1.0) : NSColor(white: 0.12, alpha: 1.0)
            let arabicFont = NSFont(name: "Geeza Pro", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.baseWritingDirection = .rightToLeft
            paragraphStyle.lineSpacing = fontSize * 0.42
            paragraphStyle.paragraphSpacing = fontSize * 0.35

            let fullAttrString = NSMutableAttributedString()
            var newRanges: [Int: NSRange] = [:]

            for (index, ayah) in surah.ayahs.enumerated() {
                let startPos = fullAttrString.length
                let isFirst = (index == 0)

                let cleanedArabic = QuranReferenceHelper.cleanArabicText(for: ayah, isFirstAyah: isFirst)

                // Verse Arabic Text
                var textAttrs: [NSAttributedString.Key: Any] = [
                    .font: arabicFont,
                    .foregroundColor: textColor,
                    .paragraphStyle: paragraphStyle,
                    NSAttributedString.Key("AyahNumber"): ayah.numberInSurah
                ]

                if selectedAyah == ayah.numberInSurah {
                    textAttrs[.backgroundColor] = highlightColor(isDark: isDark)
                }

                let verseText = NSAttributedString(string: cleanedArabic + " ", attributes: textAttrs)
                fullAttrString.append(verseText)

                // Inline Circled Verse Badge
                let badgeAttachment = NSTextAttachment()
                badgeAttachment.image = makeVerseBadgeImage(number: ayah.numberInSurah, fontSize: fontSize, isDark: isDark)
                // Center alignment baseline offset
                badgeAttachment.bounds = CGRect(x: 0, y: -4, width: badgeAttachment.image?.size.width ?? 24, height: badgeAttachment.image?.size.height ?? 24)

                var badgeAttrs: [NSAttributedString.Key: Any] = [
                    .paragraphStyle: paragraphStyle,
                    NSAttributedString.Key("AyahNumber"): ayah.numberInSurah
                ]
                if selectedAyah == ayah.numberInSurah {
                    badgeAttrs[.backgroundColor] = highlightColor(isDark: isDark)
                }

                let badgeString = NSMutableAttributedString(attachment: badgeAttachment)
                badgeString.addAttributes(badgeAttrs, range: NSRange(location: 0, length: badgeString.length))
                fullAttrString.append(badgeString)

                // Spacer between verses
                fullAttrString.append(NSAttributedString(string: "  ", attributes: [
                    .font: arabicFont,
                    .paragraphStyle: paragraphStyle
                ]))

                let endPos = fullAttrString.length
                newRanges[ayah.numberInSurah] = NSRange(location: startPos, length: endPos - startPos)
            }

            self.ayahRanges = newRanges

            textView.ayahRanges = newRanges
            textView.textStorage?.setAttributedString(fullAttrString)

            if let selected = selectedAyah, let range = newRanges[selected] {
                textView.scrollRangeToVisible(range)
            }
        }

        private func updateHighlightOnly(selectedAyah: Int?, colorScheme: ColorScheme) {
            guard let textView = textView, let storage = textView.textStorage else { return }

            let isDark = (colorScheme == .dark)
            storage.beginEditing()

            // Remove previous highlights
            storage.removeAttribute(.backgroundColor, range: NSRange(location: 0, length: storage.length))

            // Apply new highlight if any
            if let selected = selectedAyah, let range = ayahRanges[selected], range.location + range.length <= storage.length {
                storage.addAttribute(.backgroundColor, value: highlightColor(isDark: isDark), range: range)
                textView.scrollRangeToVisible(range)
            }

            storage.endEditing()
            textView.needsDisplay = true
        }

        private func highlightColor(isDark: Bool) -> NSColor {
            if isDark {
                return NSColor(
                    srgbRed: 0x00 / 255.0,
                    green: 0x35 / 255.0,
                    blue: 0x10 / 255.0,
                    alpha: CGFloat(FloatToken.PERCENT_40)
                )
            } else {
                return NSColor(
                    srgbRed: 0xE6 / 255.0,
                    green: 0xEE / 255.0,
                    blue: 0xE8 / 255.0,
                    alpha: CGFloat(FloatToken.PERCENT_85)
                )
            }
        }

        private func makeVerseBadgeImage(number: Int, fontSize: CGFloat, isDark: Bool) -> NSImage {
            let diameter = max(DimensToken.SIZE_24, fontSize * CGFloat(FloatToken.PERCENT_85))
            let imageSize = NSSize(width: diameter + DimensToken.SIZE_4, height: diameter)

            let img = NSImage(size: imageSize, flipped: false) { rect in
                let circleRect = NSRect(
                    x: DimensToken.SIZE_2,
                    y: DimensToken.SIZE_1,
                    width: diameter - DimensToken.SIZE_2,
                    height: diameter - DimensToken.SIZE_2
                )
                let greenColor = isDark
                    ? NSColor(srgbRed: 0x5C / 255.0, green: 0xDB / 255.0, blue: 0x6D / 255.0, alpha: 1.0)
                    : NSColor(srgbRed: 0x34 / 255.0, green: 0xA8 / 255.0, blue: 0x53 / 255.0, alpha: 1.0)

                // Circle stroke
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = OX.Border.WIDTH_1_5
                greenColor.setStroke()
                path.stroke()

                // Inside number (clean Arabic or Latin numeral)
                let text = "\(number)"
                let numFontSize = max(DimensToken.SIZE_9, diameter * CGFloat(FloatToken.PERCENT_44))
                let font = NSFont.systemFont(ofSize: numFontSize, weight: .semibold)
                let textAttrs: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: greenColor
                ]
                let strSize = (text as NSString).size(withAttributes: textAttrs)
                let textRect = NSRect(
                    x: circleRect.midX - strSize.width / 2.0,
                    y: circleRect.midY - strSize.height / 2.0,
                    width: strSize.width,
                    height: strSize.height
                )
                (text as NSString).draw(in: textRect, withAttributes: textAttrs)

                return true
            }
            img.isTemplate = false
            return img
        }
    }
}

// MARK: - Interactive Custom NSTextView

fileprivate final class InteractiveMushafTextView: NSTextView {

    var onAyahClicked: ((Int?) -> Void)?
    var ayahRanges: [Int: NSRange] = [:]

    override func resetCursorRects() {
        super.resetCursorRects()
        guard let layoutManager = layoutManager, let textContainer = textContainer else { return }

        for (_, range) in ayahRanges {
            let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            layoutManager.enumerateEnclosingRects(
                forGlyphRange: glyphRange,
                withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0),
                in: textContainer
            ) { rect, _ in
                self.addCursorRect(rect, cursor: .pointingHand)
            }
        }
    }

    override func mouseDown(with event: NSEvent) {
        let clickPoint = convert(event.locationInWindow, from: nil)
        guard let layoutManager = layoutManager, let textContainer = textContainer, let textStorage = textStorage else {
            super.mouseDown(with: event)
            return
        }

        let charIndex = layoutManager.characterIndex(
            for: clickPoint,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        if charIndex < textStorage.length {
            if let ayahNum = textStorage.attribute(NSAttributedString.Key("AyahNumber"), at: charIndex, effectiveRange: nil) as? Int {
                onAyahClicked?(ayahNum)
                return
            }
        }

        // Tapped outside any ayah -> dismiss selection
        onAyahClicked?(nil)
    }
}
