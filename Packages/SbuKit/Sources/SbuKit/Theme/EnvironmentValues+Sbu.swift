import SwiftUI

public extension EnvironmentValues {
    /// The accent of the app on screen, set by `SbuAppShell` and `SbuTabShell`: the `.set` full
    /// stop takes `base`, the Closure takes `onInk`. `nil` falls back to the tint.
    @Entry var sbuAccent: SbuAccent?

    /// Whether Sbu haptics play: `false` when the person turned the app's vibration off.
    /// The full stop's `dot`, the `tick` of `.sbuAffectsFigure` and the Closure follow it.
    @Entry var sbuPlaysHaptics = true
}

extension EnvironmentValues {
    /// Counts the times a control changed the figure, so the full stop can beat. Set by the shells.
    @Entry var sbuFigurePulse: SbuFigurePulse?

    /// Whether the view sits on `.sbuPaper`, whose coordinate space the hero figure snaps to.
    @Entry var sbuIsOnPaper = false
}
