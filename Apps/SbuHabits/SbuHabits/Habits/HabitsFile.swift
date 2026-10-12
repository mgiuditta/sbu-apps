/// Everything Sbu Habits saves: one JSON file in the App Group, shared with the widget.
nonisolated struct HabitsFile: Codable, Equatable, Sendable {
    /// Bump when the format changes in a way this version cannot read back.
    static let currentVersion = 1

    var version = currentVersion
    var habits: [Habit] = []
}
