/// The settings that change how a move plays out. The original turns them all on.
nonisolated struct Rules: Codable, Hashable, Sendable {
    /// A digit that differs from the solution is a mistake, and shows as one.
    var checksMistakes = true
    /// A digit takes itself out of the notes in its row, column and box.
    var removesNotes = true
}
