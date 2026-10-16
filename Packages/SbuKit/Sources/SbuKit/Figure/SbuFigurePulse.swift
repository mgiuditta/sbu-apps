import Observation

/// The beat of the figure: `.sbuAffectsFigure` bumps `count`, `SbuFullStop` beats on each change.
@Observable
final class SbuFigurePulse {
    var count = 0
}
