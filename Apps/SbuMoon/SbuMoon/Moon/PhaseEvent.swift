import Foundation

/// A principal phase and the instant it happens.
nonisolated struct PhaseEvent: Equatable, Sendable {
    var phase: PrincipalPhase
    var date: Date
}
