/// What happened to a dose, as stored.
nonisolated enum DoseMark: String, Codable, Sendable {
    case taken
    case skipped
    /// The day ended and nobody marked it: written at the next launch, so the history is complete
    /// even if the schedule changes later.
    case missed
    /// Postponed to another time today, still to take.
    case moved
}
