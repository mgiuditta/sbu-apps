// iOS only: the shell has no place on Apple Watch.
#if os(iOS)

import UIKit

/// Large navigation titles of management screens in the title face, Bricolage ExtraBold width 87,
/// scaled with Dynamic Type like `.largeTitle`. Inline titles stay SF.
enum SbuNavigationBarAppearance {
    /// Applies the appearance once per process; the shells call it before their first bar exists.
    static let apply: Void = {
        let font = SbuFont.figure(size: SbuTheme.titleSize, width: SbuTheme.figureWidthMid) as UIFont
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: font),
        ]
    }()
}

#endif
