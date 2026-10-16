import Foundation
import Testing
@testable import SbuTidy

/// Records what the app asks of iOS's notification center.
final class RecordingCenter: ReminderCenter {
    var granted: NotificationAccess
    private(set) var current: NotificationAccess = .notDetermined
    private(set) var requests = 0
    private(set) var replaced: [[PlannedReminder]] = []
    private(set) var tests = 0

    init(granting granted: NotificationAccess) {
        self.granted = granted
    }

    func access() async -> NotificationAccess { current }

    func requestAccess() async -> NotificationAccess {
        requests += 1
        current = granted
        return current
    }

    func replace(with reminders: [PlannedReminder]) { replaced.append(reminders) }
    func sendTest() { tests += 1 }
}

struct RemindersTests {
    private let defaults: UserDefaults

    init() {
        let name = "tidy.tests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: name) ?? .standard
        defaults.removePersistentDomain(forName: name)
    }

    private let chores = [Fixtures.chore("WC", lastDone: Fixtures.daysAgo(4))]

    @Test func offByDefaultAndNeverAsks() async {
        let center = RecordingCenter(granting: .allowed)
        let reminders = Reminders(defaults: defaults, center: center)
        #expect(!reminders.isOn)
        await reminders.reschedule(chores, now: Fixtures.now, calendar: Fixtures.calendar)
        #expect(center.requests == 0)
        #expect(center.replaced == [[]])
    }

    @Test func turningOnAsksOnceThenPlans() async {
        let center = RecordingCenter(granting: .allowed)
        let reminders = Reminders(defaults: defaults, center: center)
        reminders.isOn = true
        await reminders.reschedule(chores, now: Fixtures.now, calendar: Fixtures.calendar)
        await reminders.reschedule(chores, now: Fixtures.now, calendar: Fixtures.calendar)
        #expect(center.requests == 1)
        #expect(center.replaced.last?.first?.choreNames == ["WC"])
        #expect(reminders.access == .allowed)
    }

    @Test func refusedClearsEverything() async {
        let center = RecordingCenter(granting: .denied)
        let reminders = Reminders(defaults: defaults, center: center)
        reminders.isOn = true
        await reminders.reschedule(chores, now: Fixtures.now, calendar: Fixtures.calendar)
        #expect(reminders.access == .denied)
        #expect(center.replaced == [[]])
    }

    @Test func choicesSurviveARelaunch() {
        let first = Reminders(defaults: defaults, center: RecordingCenter(granting: .allowed))
        first.isOn = true
        first.setTime(Fixtures.date(2026, 10, 14, 19, 45), calendar: Fixtures.calendar)
        let second = Reminders(defaults: defaults, center: RecordingCenter(granting: .allowed))
        #expect(second.isOn)
        #expect(second.minutesAfterMidnight == 19 * 60 + 45)
    }

    @Test(arguments: [-1, 24 * 60, 99_999, Int.min])
    func aCorruptStoredTimeFallsBackToNine(minutes: Int) {
        defaults.set(minutes, forKey: "reminders.minutesAfterMidnight")
        #expect(Reminders(defaults: defaults, center: RecordingCenter(granting: .allowed)).minutesAfterMidnight == Reminders.defaultMinutes)
    }

    @Test func timeRoundTripsThroughThePicker() {
        let reminders = Reminders(defaults: defaults, center: RecordingCenter(granting: .allowed))
        reminders.minutesAfterMidnight = 6 * 60 + 5
        let time = reminders.time(on: Fixtures.now, calendar: Fixtures.calendar)
        #expect(time == Fixtures.date(2026, 10, 14, 6, 5))
    }

    @Test func testNotificationGoesToTheCenter() {
        let center = RecordingCenter(granting: .allowed)
        Reminders(defaults: defaults, center: center).sendTest()
        #expect(center.tests == 1)
    }
}
