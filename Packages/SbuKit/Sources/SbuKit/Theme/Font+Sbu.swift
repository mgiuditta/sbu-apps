import SwiftUI

public extension Font {
    /// The figure face: Bricolage Grotesque ExtraBold with tabular figures, the optical size tied
    /// to the point size, and a width on the `wdth` axis.
    ///
    /// The size is fixed: `SbuFigure` picks it on the grid and narrows the width before it ever
    /// wraps, so it does not follow Dynamic Type a second time.
    /// - Parameters:
    ///   - size: The point size, `figureHeroMin` to `figureHeroMax` on the tool screen.
    ///   - width: The `wdth` value, from `figureWidthMin` (75) to `figureWidthMax` (100).
    static func sbuFigure(size: CGFloat, width: CGFloat = SbuTheme.figureWidthMax) -> Font {
        Font(SbuFont.figure(size: size, width: width))
    }

    /// The screen title at its base size: Bricolage ExtraBold 34, width 87.
    /// `SbuScreenTitle` scales it with Dynamic Type.
    static var sbuTitle: Font {
        sbuFigure(size: SbuTheme.titleSize, width: SbuTheme.figureWidthMid)
    }

    /// The cartiglio and metadata face: IBM Plex Mono Medium 11, scaling with `.caption2`.
    /// Pair with `.textCase(.uppercase)` and `.tracking(SbuTheme.cartiglioTracking * size)`;
    /// `SbuScreenTitle` already does. Never for figures.
    static var sbuCartiglio: Font {
        _ = SbuFont.isRegistered
        return .custom(SbuFont.monoPostScriptName, size: SbuTheme.cartiglioSize, relativeTo: .caption2)
    }
}
