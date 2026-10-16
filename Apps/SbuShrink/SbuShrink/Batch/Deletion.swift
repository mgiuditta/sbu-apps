/// Where "Elimina originali" is.
nonisolated enum Deletion: Equatable, Sendable {
    /// Not asked.
    case idle
    /// Waiting for the system confirmation.
    case deleting
    /// This many originals went to Recently Deleted.
    case deleted(Int)
    /// Photos did not delete them.
    case failed
}
