/// One step of the undo history: the values, the notes and the selected cell before a move.
nonisolated struct Snapshot: Codable, Hashable, Sendable {
    let cells: [Int]
    let notes: [Int]
    let selected: Int?
}
