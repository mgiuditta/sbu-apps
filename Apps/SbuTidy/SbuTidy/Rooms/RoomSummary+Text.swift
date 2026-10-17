import Foundation

extension RoomSummary {
    /// The word next to a room, never color alone: "Pulita", "2 da fare", "1 in ritardo".
    var statusText: LocalizedStringResource {
        switch status {
        case .empty: "Nessuna attività"
        case .clean: "Pulita"
        case .due: "\(toDoCount) da fare"
        case .overdue: "\(overdueCount) in ritardo"
        case .paused: "In pausa"
        }
    }

    /// Something due today or late: the room is not in order.
    var hasWork: Bool { status == .due || status == .overdue }
}
