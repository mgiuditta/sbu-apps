/// One deletion from the bin: how many items and how many bytes.
nonisolated struct DeletionResult: Identifiable, Equatable, Sendable {
    var count: Int
    var bytes: Int64
    /// What Sbu Clean freed since the first deletion, this one included.
    var totalBytes: Int64
    var totalCount: Int

    var id: Int64 { totalBytes }
}
