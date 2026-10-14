/// A row of the 1.x `folders` table.
nonisolated struct LegacyFolder: Equatable, Sendable {
    var id: Int
    var name: String
    var createdAt: String
}
