/// Everything Sbu Habits saves: one JSON file in the App Group, shared with the widget.
nonisolated struct HabitsFile: Codable, Equatable, Sendable {
    /// Bump when the format changes in a way this version cannot read back.
    static let currentVersion = 1
    /// The hours a day can start at: 0 is midnight, 4 suits a night shift.
    static let startHourRange = 0...6

    var version = currentVersion
    var habits: [Habit] = []
    /// Hour the logical day starts; what happens before it counts for the day before.
    var startHour = 0

    init(habits: [Habit] = [], startHour: Int = 0) {
        self.habits = habits
        self.startHour = startHour
    }

    // Files saved before the start of the day existed start at midnight.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        habits = try container.decode([Habit].self, forKey: .habits)
        startHour = try container.decodeIfPresent(Int.self, forKey: .startHour) ?? 0
    }
}
