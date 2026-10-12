import SwiftUI

public extension SbuTheme {
    // MARK: - iOS styles (Dynamic Type)

    /// `large-title`: title of the NavigationStack.
    static let largeTitle = Font.largeTitle
    /// `title-2`: section heading inside a screen.
    static let title2 = Font.title2.bold()
    /// `headline`: title of a list row.
    static let headline = Font.headline
    /// `body`: running text and descriptions.
    static let body = Font.body
    /// `subheadline`: second line of a list row, in `inkMuted`.
    static let subheadline = Font.subheadline
    /// `footnote`: notes under a section and privacy copy, in `inkMuted`.
    static let footnote = Font.footnote
    /// `caption`: the only uppercase style, for labels above figures and form headers.
    /// Pair with `.textCase(.uppercase)` and `.tracking(SbuTheme.captionTracking)`.
    static let caption = Font.caption.weight(.medium)
    /// Letter spacing of `caption`.
    static let captionTracking: CGFloat = 0.4

    // MARK: - Numbers

    /// Point size of `stat` before Dynamic Type scaling.
    static let statSize: CGFloat = 40
    /// Point size of `statSmall` before Dynamic Type scaling.
    static let statSmallSize: CGFloat = 22
    /// Point size of `statHero` before Dynamic Type scaling.
    static let statHeroSize: CGFloat = 64
    /// Letter spacing of `stat`.
    static let statTracking: CGFloat = -1
    /// Letter spacing of `statHero`.
    static let statHeroTracking: CGFloat = -2

    /// `stat`: the one figure the app exists to show. Monospaced digits, one per screen.
    static let stat = numberFont(size: statSize)
    /// `stat-hero`: the figure on the tool screen, in `onField` over the app's field.
    /// One per app, never on a management screen.
    static let statHero = numberFont(size: statHeroSize)
    /// `stat-small`: amounts and counters in list rows, right aligned.
    static let statSmall = numberFont(size: statSmallSize)

    /// Creates the monospaced number font used by `statHero`, `stat` and `statSmall` at a given size.
    ///
    /// Components pass a `@ScaledMetric` size so figures follow Dynamic Type.
    /// - Parameter size: The point size, usually scaled from `statHeroSize`, `statSize` or `statSmallSize`.
    /// - Returns: A medium-weight monospaced font with monospaced digits.
    static func numberFont(size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced).monospacedDigit()
    }
}
