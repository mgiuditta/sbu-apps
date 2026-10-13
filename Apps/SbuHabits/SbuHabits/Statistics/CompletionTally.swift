/// Expected days done and missed: what the completion rate of the Statistiche counts.
nonisolated struct CompletionTally: Equatable, Sendable {
    static let zero = CompletionTally(done: 0, missed: 0)

    var done: Int
    var missed: Int

    /// Done over done and missed, from 0 to 1; `nil` when nothing was expected.
    var rate: Double? {
        let total = done + missed
        return total == 0 ? nil : Double(done) / Double(total)
    }

    static func + (lhs: CompletionTally, rhs: CompletionTally) -> CompletionTally {
        CompletionTally(done: lhs.done + rhs.done, missed: lhs.missed + rhs.missed)
    }

    static func += (lhs: inout CompletionTally, rhs: CompletionTally) {
        lhs = lhs + rhs
    }
}
