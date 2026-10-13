@testable import SbuHabits

/// Keeps every change of the countdown a `HabitsModel` reports, in place of ActivityKit.
final class ActivityLog {
    private(set) var updates: [TimerActivityUpdate] = []

    var last: TimerActivityUpdate? { updates.last }

    func record(_ update: TimerActivityUpdate) {
        updates.append(update)
    }
}
