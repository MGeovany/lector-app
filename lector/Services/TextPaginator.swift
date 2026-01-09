import Foundation
import UIKit

struct TextPaginator {
    struct Style: Hashable {
        let font: UIFont
        /// Extra spacing between lines (points).
        let lineSpacing: CGFloat
    }

    /// Splits the provided `text` into page-sized chunks based on `containerSize`.
    ///
    /// Uses TextKit to compute actual layout so pagination stays stable across font changes.
    static func paginate(text: String, containerSize: CGSize, style: Style) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [""] }
        guard containerSize.width > 10, containerSize.height > 10 else { return [trimmed] }

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.lineSpacing = style.lineSpacing

        let attributed = NSAttributedString(
            string: trimmed,
            attributes: [
                .font: style.font,
                .paragraphStyle: paragraph
            ]
        )

        let textStorage = NSTextStorage(attributedString: attributed)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        var pages: [String] = []

        var lastGlyphIndex = 0
        // Each text container represents a page. As we add containers, TextKit flows the text forward.
        while lastGlyphIndex < layoutManager.numberOfGlyphs {
            let container = NSTextContainer(size: containerSize)
            container.lineFragmentPadding = 0
            layoutManager.addTextContainer(container)

            let glyphRange = layoutManager.glyphRange(for: container)
            guard glyphRange.length > 0 else { break }

            let charRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            let pageText = (trimmed as NSString)
                .substring(with: charRange)
                .trimmingCharacters(in: .whitespacesAndNewlines)

            pages.append(pageText)
            lastGlyphIndex = NSMaxRange(glyphRange)
        }

        return pages.isEmpty ? [trimmed] : pages
    }
}

