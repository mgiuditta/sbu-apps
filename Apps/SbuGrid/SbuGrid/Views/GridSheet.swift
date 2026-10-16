/// The sheets the grid screen opens, one at a time.
nonisolated enum GridSheet: String, Identifiable, Sendable {
    case grid

    var id: Self { self }
}
