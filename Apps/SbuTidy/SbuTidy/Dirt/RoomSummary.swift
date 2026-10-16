import Foundation

/// A room at a glance, for the rooms list: how many chores, how many to do and how late.
nonisolated struct RoomSummary: Equatable, Sendable {
    nonisolated enum Status: Equatable, Sendable {
        /// No chores yet.
        case empty
        /// Nothing to do today.
        case clean
        /// Something due today, nothing late.
        case due
        /// At least one chore late.
        case overdue
        /// Every chore paused.
        case paused
    }

    let choreCount: Int
    /// Due today or late.
    let toDoCount: Int
    let overdueCount: Int
    /// Average level of the chores not paused, 0 to 1, as Tody's room bar.
    let level: Double
    let status: Status

    init(_ states: [ChoreState]) {
        choreCount = states.count
        toDoCount = states.filter { $0.status.isToDo }.count
        overdueCount = states.filter { $0.status == .overdue }.count
        let active = states.filter { $0.status != .paused }
        level = active.isEmpty ? 0 : active.map(\.level).reduce(0, +) / Double(active.count)
        status = if states.isEmpty {
            .empty
        } else if overdueCount > 0 {
            .overdue
        } else if toDoCount > 0 {
            .due
        } else if active.isEmpty {
            .paused
        } else {
            .clean
        }
    }
}
