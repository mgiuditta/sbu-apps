/// An album the user made in Photos.
nonisolated struct Album: Identifiable, Hashable, Sendable {
    /// The PhotoKit local identifier of the collection.
    let id: String
    var title: String
    var count: Int
}
