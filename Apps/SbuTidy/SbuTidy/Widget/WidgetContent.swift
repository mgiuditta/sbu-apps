import Foundation

/// What the widget shows at a moment: the figure of the app and the most urgent chores.
nonisolated struct WidgetContent: Equatable, Sendable {
    nonisolated struct Item: Equatable, Hashable, Sendable {
        let name: String
        let roomName: String
        let label: DueLabel
    }

    let toDoCount: Int
    let overdueCount: Int
    /// To do now, the dirtiest first; when nothing is, the next ones coming.
    let items: [Item]
    /// No rooms or no chores yet: the widget says how to start.
    let isEmpty: Bool

    init(_ chores: [ChoreSnapshot], at now: Date, calendar: Calendar, limit: Int) {
        let ranked = Urgency.sorted(chores, at: now, calendar: calendar)
        let toDo = ranked.filter { $0.state.status.isToDo }
        toDoCount = toDo.count
        overdueCount = toDo.filter { $0.state.status == .overdue }.count
        isEmpty = chores.isEmpty
        let shown = toDo.isEmpty
            ? ranked.filter { $0.state.status == .clean }.sorted { $0.state.dueDate < $1.state.dueDate }
            : toDo
        items = shown.prefix(max(limit, 0)).map { Item(name: $0.chore.name, roomName: $0.chore.roomName, label: DueLabel($0.state)) }
    }

    init(toDoCount: Int, overdueCount: Int, items: [Item], isEmpty: Bool) {
        self.toDoCount = toDoCount
        self.overdueCount = overdueCount
        self.items = items
        self.isEmpty = isEmpty
    }

    /// The moments the widget changes by itself: now, then each of the next midnights, when
    /// chores turn due or late without anyone opening the app.
    static func moments(from now: Date, calendar: Calendar, days: Int) -> [Date] {
        let today = calendar.startOfDay(for: now)
        let midnights = (1...max(days, 1)).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
        return [now] + midnights
    }
}
