import Foundation

/// One notification to hand to iOS: the phase, when it happens, and when to say so.
nonisolated struct PlannedPhaseAlert: Equatable, Sendable {
    var phase: PrincipalPhase
    /// The instant of the phase.
    var eventDate: Date
    /// When the notification arrives: the chosen time on the day of the phase.
    var fireDate: Date

    /// Stable for the same phase instant, so a new plan replaces rather than duplicates.
    var identifier: String {
        "phase-\(phase.storageKey)-\(Int(eventDate.timeIntervalSince1970))"
    }
}
