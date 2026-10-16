import Foundation

/// The to-do list: the chores of a filter grouped by room, rooms in your order, chores by urgency.
nonisolated struct TodayList: Equatable, Sendable {
    nonisolated struct Item: Identifiable, Equatable, Sendable {
        let chore: ChoreSnapshot
        let state: ChoreState
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

    init(_ chores: [ChoreSnapshot], filter: TodayFilter, now: Date, calendar: Calendar) {
        let ranked = Urgency.sorted(chores, at: now, calendar: calendar)
        toDoCount = ranked.filter { $0.state.status.isToDo }.count
        overdueCount = ranked.filter { $0.state.status == .overdue }.count

        let shown: [Item] = switch filter {
        case .toDo:
            ranked.filter { $0.state.status.isToDo }.map { Item(chore: $0.chore, state: $0.state) }
        case .upcoming:
            ranked
                .filter { $0.state.status == .clean && $0.state.daysUntilDue <= TodayFilter.upcomingDays }
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
}
