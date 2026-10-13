/// Everything Sbu Noise saves, as one versioned JSON file. The playlist joins it with its ticket.
nonisolated struct NoiseFile: Codable, Equatable, Sendable {
    static let currentVersion = 1

    var version = currentVersion
    var timers: [SoundTimer] = []
    var mixes: [Mix] = []
    /// Sound ids and mix UUIDs, in the order they were added.
    var favorites: [String] = []

    init(timers: [SoundTimer] = [], mixes: [Mix] = [], favorites: [String] = []) {
        self.timers = timers
        self.mixes = mixes
        self.favorites = favorites
    }

    /// Lists added after a file was written load empty.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        timers = try container.decodeIfPresent([SoundTimer].self, forKey: .timers) ?? []
        mixes = try container.decodeIfPresent([Mix].self, forKey: .mixes) ?? []
        favorites = try container.decodeIfPresent([String].self, forKey: .favorites) ?? []
    }
}
