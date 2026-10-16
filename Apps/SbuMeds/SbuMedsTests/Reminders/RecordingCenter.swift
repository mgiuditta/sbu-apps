import Foundation
@testable import SbuMeds

/// Records what would reach iOS.
final class RecordingCenter: ReminderCenter {
    var granted: NotificationAccess = .notDetermined
    var answer: NotificationAccess = .allowed
    private(set) var requests = 0
    private(set) var replaced: [[PlannedReminder]] = []
    private(set) var stillToTake: [Set<String>] = []

    func access() async -> NotificationAccess { granted }

    func requestAccess() async -> NotificationAccess {
        requests += 1
        granted = answer
        return granted
    }

    func replace(with reminders: [PlannedReminder], snoozeMinutes: Int, stillToTake: Set<String>) {
        replaced.append(reminders)
        self.stillToTake.append(stillToTake)
    }

    func sendTest() {}
}
