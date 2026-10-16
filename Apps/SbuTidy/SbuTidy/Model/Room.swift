import Foundation
import SwiftData

/// A room of the home, Tody's "area": its chores and its place in your list.
@Model
final class Room {
    var id = UUID()
    var name = ""
    var kindRaw = RoomKind.other.rawValue
    /// Your order in the rooms list, and of the groups in the to-do list.
    var order = 0
    var createdAt = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Chore.room) var chores: [Chore]? = []

    init(name: String, kind: RoomKind, order: Int) {
        self.name = name
        kindRaw = kind.rawValue
        self.order = order
    }

    var kind: RoomKind {
        get { RoomKind(rawValue: kindRaw) ?? .other }
        set { kindRaw = newValue.rawValue }
    }

    var choreList: [Chore] { chores ?? [] }

    func summary(at now: Date, calendar: Calendar) -> RoomSummary {
        RoomSummary(choreList.map { $0.snapshot.state(at: now, calendar: calendar) })
    }
}
