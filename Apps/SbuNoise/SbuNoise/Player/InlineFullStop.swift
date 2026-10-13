import SbuKit
import SwiftUI
import UIKit

/// The full stop as a piece of text, for a figure that may wrap: it stays right after the last
/// word, on its baseline, instead of at the edge of the whole paragraph as an `HStack` puts it.
/// Same geometry as `SbuFullStop` (side `markSize`, gap `markGap`, in the accent).
enum InlineFullStop {
    /// - Parameters:
    ///   - fontSize: The figure's point size after Dynamic Type scaling.
    ///   - tracking: The figure's tracking, which also follows its last glyph and so eats into the gap.
    static func text(fontSize: CGFloat, tracking: CGFloat) -> Text {
        let side = fontSize * SbuTheme.markSize
        let gap = max(0, fontSize * SbuTheme.markGap - tracking)
        let image = UIGraphicsImageRenderer(size: CGSize(width: gap + side, height: side)).image { context in
            UIColor.black.setFill()
            context.fill(CGRect(x: gap, y: 0, width: side, height: side))
        }
        return Text(Image(uiImage: image.withRenderingMode(.alwaysTemplate))).foregroundStyle(.tint)
    }
}
