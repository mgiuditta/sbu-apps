/// The lists the ☰ menu switches between, as in the original. Playlist and favorites join with their tickets.
nonisolated enum PlayerCategory: String, CaseIterable, Identifiable, Sendable {
    case sounds
    case mixes

    var id: Self { self }
}
