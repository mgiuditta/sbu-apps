import SwiftUI

/// WCAG 2 contrast between two colors, the check behind every promised token pair.
public nonisolated enum SbuContrast {
    /// The contrast ratio of two resolved colors, from 1 (same luminance) to 21 (black on white).
    /// Order does not matter. Alpha is ignored: tokens promised as pairs are opaque.
    public static func ratio(_ first: Color.Resolved, _ second: Color.Resolved) -> Double {
        let luminances = [first, second].map(luminance).sorted(by: >)
        return (luminances[0] + 0.05) / (luminances[1] + 0.05)
    }

    /// The minimum ratio for text: 4.5:1 (WCAG AA).
    public static let text = 4.5
    /// The minimum ratio for a graphic, such as the waiting full stop: 3:1 (WCAG AA).
    public static let graphic = 3.0

    private static func luminance(_ color: Color.Resolved) -> Double {
        // Color.Resolved already holds linear components: the sRGB transfer is undone.
        0.2126 * Double(color.linearRed) + 0.7152 * Double(color.linearGreen) + 0.0722 * Double(color.linearBlue)
    }
}
