/// A word or emoji and how many times it was used.
nonisolated struct RankedTerm: Hashable, Sendable {
    let term: String
    let count: Int
}
