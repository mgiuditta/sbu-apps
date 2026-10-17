import SwiftUI

/// The three haptic signs of Sbu (ADR-0014). No app plays any other feedback.
public nonisolated enum SbuHaptic: Sendable, CaseIterable {
    /// The person changed a figure: `.selection`.
    case tick
    /// The full stop settled: a heavy impact at 0.9.
    case dot
    /// The Closure: `.success`.
    case closure

    /// The system feedback behind the sign.
    public var feedback: SensoryFeedback {
        switch self {
        case .tick: .selection
        case .dot: .impact(weight: .heavy, intensity: 0.9)
        case .closure: .success
        }
    }
}

public extension View {
    /// Plays a Sbu haptic each time `trigger` changes, unless `\.sbuPlaysHaptics` is off.
    func sbuHaptic(_ haptic: SbuHaptic, trigger: some Equatable) -> some View {
        modifier(SbuHapticModifier(haptic: haptic, trigger: trigger))
    }
}

private struct SbuHapticModifier<Trigger: Equatable>: ViewModifier {
    let haptic: SbuHaptic
    let trigger: Trigger

    @Environment(\.sbuPlaysHaptics) private var playsHaptics

    func body(content: Content) -> some View {
        content.sensoryFeedback(haptic.feedback, trigger: trigger) { _, _ in playsHaptics }
    }
}
