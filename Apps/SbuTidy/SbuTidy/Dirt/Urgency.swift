import Foundation

/// Tody's order: the dirtiest first, relative to its frequency. Paused chores go last;
/// ties go by due date, then by name, so the order never jumps between two launches.
nonisolated enum Urgency {
    static func sorted(_ chores: [ChoreSnapshot], at now: Date, calendar: Calendar) -> [(chore: ChoreSnapshot, state: ChoreState)] {
        chores
            .map { (chore: $0, state: $0.state(at: now, calendar: calendar)) }
            .sorted { first, second in
                if first.state.isPausedForSorting != second.state.isPausedForSorting { return !first.state.isPausedForSorting }
                if first.state.dirtiness != second.state.dirtiness { return first.state.dirtiness > second.state.dirtiness }
                if first.state.dueDate != second.state.dueDate { return first.state.dueDate < second.state.dueDate }
                let byName = first.chore.name.localizedStandardCompare(second.chore.name)
                if byName != .orderedSame { return byName == .orderedAscending }
                return first.chore.id.uuidString < second.chore.id.uuidString
            }
    }
}

private extension ChoreState {
    nonisolated var isPausedForSorting: Bool { status == .paused }
}
