import Foundation
import Testing
@testable import SbuSubscriptions

/// Stands in for iOS: records what the app hands over, and answers with a chosen permission.
final class RecordingReminderCenter: ReminderCenter {
    var current: NotificationAccess
    var afterRequest: NotificationAccess
    private(set) var requests = 0
    private(set) var replaced: [[PlannedReminder]] = []

    init(current: NotificationAccess, afterRequest: NotificationAccess = .allowed) {
        self.current = current
        self.afterRequest = afterRequest
    }

    func access() async -> NotificationAccess { current }
    func requestAccess() async -> NotificationAccess {
        requests += 1
        current = afterRequest
        return current
    }
    func replace(with reminders: [PlannedReminder]) { replaced.append(reminders) }
    func sendTest() {}
}

struct RemindersTests {
    let defaults = UserDefaults(suiteName: "RemindersTests.\(UUID().uuidString)")!

    func source(daysBefore: Int?) -> ReminderSource {
        ReminderSource(id: "a", name: "Musica", price: 10, currencyCode: "EUR",
                       schedule: BillingSchedule(start: .now.addingTimeInterval(10 * 86_400), cycle: .monthly),
                       trialEnd: nil, daysBefore: daysBefore, isActive: true)
    }

    @Test func asksOnlyOnceASubscriptionHasAReminder() async {
        let center = RecordingReminderCenter(current: .notDetermined)
        let reminders = Reminders(defaults: defaults, center: center)
        await reminders.reschedule([])
        await reminders.reschedule([source(daysBefore: nil)])
        #expect(center.requests == 0)
        await reminders.reschedule([source(daysBefore: 1)])
        #expect(center.requests == 1)
        #expect(center.replaced.last?.isEmpty == false)
    }

    @Test func deniedClearsEveryPendingReminder() async {
        let center = RecordingReminderCenter(current: .denied)
        let reminders = Reminders(defaults: defaults, center: center)
        await reminders.reschedule([source(daysBefore: 1)])
        #expect(center.requests == 0)
        #expect(center.replaced == [[]])
        #expect(reminders.access == .denied)
    }

    @Test func timeIsKeptAcrossLaunches() {
        let reminders = Reminders(defaults: defaults, center: RecordingReminderCenter(current: .allowed))
        #expect(reminders.minutesAfterMidnight == 9 * 60)
        reminders.minutesAfterMidnight = 20 * 60 + 30
        #expect(Reminders(defaults: defaults, center: RecordingReminderCenter(current: .allowed)).minutesAfterMidnight == 20 * 60 + 30)
    }
}
