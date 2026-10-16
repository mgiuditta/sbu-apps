import SwiftUI

/// The one tempo of every Sbu app (ADR-0014), from the `motion-*` tokens.
///
/// Figures change on `base`, the full stop arrives on `spring` and beats on `short`. With Reduce
/// Motion there is no movement: `animation(_:reduceMotion:)` returns `nil` and transitions fall
/// back to opacity.
public enum SbuMotion {
    /// 180 ms ease out: the full stop's beat, small state changes.
    public static let short = Animation.easeOut(duration: SbuTheme.motionShort)
    /// 320 ms ease in and out: figures changing value.
    public static let base = Animation.easeInOut(duration: SbuTheme.motionBase)
    /// The full stop arriving from below once the value settles.
    public static let spring = Animation.spring(response: SbuTheme.motionSpringResponse, dampingFraction: SbuTheme.motionSpringDamping)

    /// The animation to run, or `nil` (no animation) when the person asked for reduced motion.
    public static func animation(_ animation: Animation, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : animation
    }

    /// A transition that moves in from an edge, or only fades when the person asked for reduced motion.
    public static func transition(from edge: Edge, reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .opacity : .move(edge: edge).combined(with: .opacity)
    }
}
