/// The sheets the grid screen opens, one at a time.
nonisolated enum GridSheet: String, Identifiable, Sendable {
    case grid
    case paper
    case export

    var id: Self { self }
}
