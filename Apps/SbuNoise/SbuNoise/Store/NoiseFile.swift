/// Everything Sbu Noise saves, as one versioned JSON file. Favorites, mixes and the playlist join it
/// with their tickets.
nonisolated struct NoiseFile: Codable, Equatable, Sendable {
    static let currentVersion = 1

    var version = currentVersion
    var timers: [SoundTimer] = []
}
