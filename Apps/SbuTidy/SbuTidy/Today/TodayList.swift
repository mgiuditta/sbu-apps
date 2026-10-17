import Foundation

/// The to-do list: the chores of a filter grouped by room, rooms in your order, chores by urgency.
/// "Da fare" keeps the chores done today after the others, ticked, so a tick can be taken back.
nonisolated struct TodayList: Equatable, Sendable {
    nonisolated struct Item: Identifiable, Equatable, Sendable {
        let chore: ChoreSnapshot
        let state: ChoreState
        /// Done today: ticked in "Da fare", left out of "In scadenza".
        var isDone = false
        var id: UUID { chore.id }
    }

    nonisolated struct Section: Identifiable, Equatable, Sendable {
        let roomID: UUID
        let roomName: String
        let items: [Item]
        var id: UUID { roomID }
    }

    let sections: [Section]
    /// Chores due today or late, whatever the filter: the screen's figure.
    let toDoCount: Int
    let overdueCount: Int
    /// Chores done today and no longer to do: with none left to do, the day is closed.
    let doneCount: Int

    /// - Parameter doneToday: The chores with a completion today.
    init(_ chores: [ChoreSnapshot], filter: TodayFilter, now: Date, calendar: Calendar, doneToday: Set<UUID> = []) {
        let ranked = Urgency.sorted(chores, at: now, calendar: calendar)
        let toDo = ranked.filter { $0.state.status.isToDo }
        let done = ranked.filter { !$0.state.status.isToDo && doneToday.contains($0.chore.id) }
        toDoCount = toDo.count
        overdueCount = toDo.filter { $0.state.status == .overdue }.count
        doneCount = done.count

        let shown: [Item] = switch filter {
        case .toDo:
            toDo.map { Item(chore: $0.chore, state: $0.state) } + done.map { Item(chore: $0.chore, state: $0.state, isDone: true) }
        case .upcoming:
            ranked
                .filter { $0.state.status == .clean && $0.state.daysUntilDue <= TodayFilter.upcomingDays && !doneToday.contains($0.chore.id) }
                // What comes first comes first, not what is dirtiest.
                .sorted { $0.state.dueDate < $1.state.dueDate }
                .map { Item(chore: $0.chore, state: $0.state) }
        }

        let rooms = Dictionary(grouping: shown, by: \.chore.roomID)
        sections = rooms.values
            .compactMap { items -> Section? in
                guard let first = items.first else { return nil }
                return Section(roomID: first.chore.roomID, roomName: first.chore.roomName, items: items)
            }
            .sorted { first, second in
                let firstOrder = first.items[0].chore.roomOrder
                let secondOrder = second.items[0].chore.roomOrder
                if firstOrder != secondOrder { return firstOrder < secondOrder }
                return first.roomName.localizedStandardCompare(second.roomName) == .orderedAscending
            }
    }

    var isEmpty: Bool { sections.isEmpty }

    /// Nothing left to do today, and something was done: the full stop is set.
    var isDayClosed: Bool { toDoCount == 0 && doneCount > 0 }
}
