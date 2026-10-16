import SwiftUI

public extension EnvironmentValues {
    /// The accent of the app on screen, set by `SbuAppShell` and `SbuTabShell`: the `.set` full
    /// stop takes `base`, the Closure takes `onInk`. `nil` falls back to the tint.
    @Entry var sbuAccent: SbuAccent?
}

extension EnvironmentValues {
    /// Counts the times a control changed the figure, so the full stop can beat. Set by the shells.
    @Entry var sbuFigurePulse: SbuFigurePulse?
}
