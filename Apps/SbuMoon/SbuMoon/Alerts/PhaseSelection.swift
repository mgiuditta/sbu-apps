import Foundation

/// The principal phases the user wants an alert for; a toggle binds to one phase.
nonisolated struct PhaseSelection: Equatable, Sendable {
    private(set) var phases: Set<PrincipalPhase>

    init(_ phases: Set<PrincipalPhase> = []) {
        self.phases = phases
    }

    var isEmpty: Bool { phases.isEmpty }

    subscript(phase: PrincipalPhase) -> Bool {
        get { phases.contains(phase) }
        set {
            if newValue {
                phases.insert(phase)
            } else {
                phases.remove(phase)
            }
        }
    }

    /// Whether this selection has a phase that `other` did not.
    func adds(to other: PhaseSelection) -> Bool {
        phases.isSubset(of: other.phases) == false
    }
}
