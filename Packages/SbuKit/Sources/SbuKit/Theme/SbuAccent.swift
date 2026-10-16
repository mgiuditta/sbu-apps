import SwiftUI

/// One app's accent: the color of the `.set` full stop on paper, and its lighter twin for the ink
/// block of the Closure. Generated per app as `SbuAccent.<app>` from `Design/tokens.json`.
public struct SbuAccent: Sendable, Hashable {
    /// `accent-<app>`: the full stop on paper and the icon square.
    public let base: Color
    /// `accent-on-ink-<app>`: the full stop inside the ink block.
    public let onInk: Color

    public init(base: Color, onInk: Color) {
        self.base = base
        self.onInk = onInk
    }
}
