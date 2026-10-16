import Foundation

/// A chore as the pure logic sees it: the to-do list, the reminders and the widget.
nonisolated struct ChoreSnapshot: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var roomID: UUID
    var roomName: String
    var roomOrder: Int
    var effort: Effort
    var frequency: Frequency
    var clock: ChoreClock

    func state(at now: Date, calendar: Calendar) -> ChoreState {
        ChoreState(frequency: frequency, clock: clock, now: now, calendar: calendar)
    }
}
