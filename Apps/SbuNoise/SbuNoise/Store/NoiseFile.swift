/// Everything Sbu Noise saves, as one versioned JSON file. The playlist joins it with its ticket.
nonisolated struct NoiseFile: Codable, Equatable, Sendable {
    static let currentVersion = 1

    var version = currentVersion
    var timers: [SoundTimer] = []
    var alarms: [SoundAlarm] = []
    var mixes: [Mix] = []
    /// Sound ids and mix UUIDs, in the order they were added.
    var favorites: [String] = []
    /// Gestisci: the sound ids in the user's order, and the ones hidden from the player.
    var soundOrder: [String] = []
    var hiddenSounds: [String] = []

    init(timers: [SoundTimer] = [], mixes: [Mix] = [], favorites: [String] = [], arrangement: SoundArrangement = SoundArrangement()) {
        self.timers = timers
        self.mixes = mixes
        self.favorites = favorites
        self.arrangement = arrangement
    }

    var arrangement: SoundArrangement {
        get { SoundArrangement(order: soundOrder, hidden: Set(hiddenSounds)) }
        set {
            soundOrder = newValue.order
            hiddenSounds = newValue.hidden.sorted()
        }
    }

    /// Lists added after a file was written load empty.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        timers = try container.decodeIfPresent([SoundTimer].self, forKey: .timers) ?? []
        alarms = try container.decodeIfPresent([SoundAlarm].self, forKey: .alarms) ?? []
        mixes = try container.decodeIfPresent([Mix].self, forKey: .mixes) ?? []
        favorites = try container.decodeIfPresent([String].self, forKey: .favorites) ?? []
        soundOrder = try container.decodeIfPresent([String].self, forKey: .soundOrder) ?? []
        hiddenSounds = try container.decodeIfPresent([String].self, forKey: .hiddenSounds) ?? []
    }
}
