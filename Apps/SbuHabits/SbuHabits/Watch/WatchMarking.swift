/// Applies a `WatchAction` to the habits, with the rules of a tap on the iPhone: `mark(on:hour:)`
/// adds one time up to the goal, past the Limite for an Abitudine da evitare, and takes a skip
/// back; `undoLast(on:)` takes the day's last mark back. The iPhone uses it to save the action,
/// the watch to show it before the iPhone answers.
nonisolated enum WatchMarking {
    /// - Returns: Whether a habit changed: never for a day still to come or a habit not there.
    static func apply(_ action: WatchAction, to habits: inout [Habit], today: LogicalDay) -> Bool {
        guard action.day <= today, let index = habits.firstIndex(where: { $0.id == action.habitID }) else { return false }
        let before = habits[index]
        switch action.kind {
        case .mark: habits[index].mark(on: action.day, hour: action.hour)
        case .undo: habits[index].undoLast(on: action.day)
        }
        return habits[index] != before
    }
}
