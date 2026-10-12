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
    static let statTracking: CGFloat = -1.5
    /// Letter spacing of `statHero`.
    static let statHeroTracking: CGFloat = -3

    /// `stat`: the one figure the app exists to show, closed by `SbuFullStop`. One per screen.
    static let stat = numberFont(size: statSize)
    /// `stat-hero`: the figure on the tool screen, in `ink`, closed by `SbuFullStop`. One per app.
    static let statHero = numberFont(size: statHeroSize)
    /// `stat-small`: amounts and counters in list rows, right aligned, without a full stop.
    static let statSmall = smallNumberFont(size: statSmallSize)

    /// Creates the font of `statHero` and `stat` at a given size: Bricolage Grotesque ExtraBold
    /// with tabular figures, so a changing figure does not shift.
    ///
    /// The size is fixed because components already scale it with a `@ScaledMetric`, so figures
    /// follow Dynamic Type once. The first call registers the font bundled with SbuKit.
    /// - Parameter size: The point size, usually scaled from `statHeroSize` or `statSize`.
    static func numberFont(size: CGFloat) -> Font {
        _ = SbuFont.isRegistered
        return .custom(SbuFont.statPostScriptName, fixedSize: size).monospacedDigit()
    }

    /// Creates the font of `statSmall` at a given size: SF, weight 500, monospaced digits.
    ///
    /// - Parameter size: The point size, usually scaled from `statSmallSize`.
    static func smallNumberFont(size: CGFloat) -> Font {
        .system(size: size, weight: .medium).monospacedDigit()
    }
}
