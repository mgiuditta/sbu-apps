/// Everything Sbu Noise saves, as one versioned JSON file. Favorites and the playlist join it
/// with their tickets.
nonisolated struct NoiseFile: Codable, Equatable, Sendable {
    static let currentVersion = 1

    var version = currentVersion
    var timers: [SoundTimer] = []
    var mixes: [Mix] = []

    init(timers: [SoundTimer] = [], mixes: [Mix] = []) {
        self.timers = timers
        self.mixes = mixes
    }

    /// Lists added after a file was written load empty.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        timers = try container.decodeIfPresent([SoundTimer].self, forKey: .timers) ?? []
        mixes = try container.decodeIfPresent([Mix].self, forKey: .mixes) ?? []
    }
}
