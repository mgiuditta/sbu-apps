/// The row, column and box a correct value completes, and whether it completes the grid.
nonisolated struct CompletedGroups: OptionSet, Hashable, Sendable {
    let rawValue: Int

    static let box = CompletedGroups(rawValue: 1 << 0)
    static let row = CompletedGroups(rawValue: 1 << 1)
    static let column = CompletedGroups(rawValue: 1 << 2)
    static let grid = CompletedGroups(rawValue: 1 << 3)

    /// Rows, columns and boxes: each one multiplies the points by five more.
    var count: Int {
        [Self.box, .row, .column].count(where: contains)
    }
}
