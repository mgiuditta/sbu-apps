/// One point of the completion line: the rate over a few days in a row.
nonisolated struct CompletionPoint: Identifiable, Equatable, Sendable {
    /// Position on the line, 0 for the oldest.
    let index: Int
    let firstDay: LogicalDay
    let lastDay: LogicalDay
    /// From 0 to 1.
    let rate: Double

    var id: Int { index }
}
