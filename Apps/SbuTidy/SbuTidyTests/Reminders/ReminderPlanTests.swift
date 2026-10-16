import Foundation
import Testing
@testable import SbuTidy

struct ReminderPlanTests {
    private func plan(_ chores: [ChoreSnapshot], hour: Int = 9, minute: Int = 0, now: Date = Fixtures.now, days: Int = ReminderPlan.days) -> [PlannedReminder] {
        ReminderPlan.reminders(for: chores, hour: hour, minute: minute, now: now, calendar: Fixtures.calendar, days: days)
    }

    @Test func nothingToDoNothingSent() {
        #expect(plan([]).isEmpty)
    }

    @Test func aDayGetsAReminderOnlyWhenAChoreTurnsDueOnIt() {
        // Weekly, done 4 days ago at noon: due on the 17th, nothing before.
        let chore = Fixtures.chore("WC", lastDone: Fixtures.daysAgo(4))
        let reminders = plan([chore])
        #expect(reminders.first?.fireDate == Fixtures.date(2026, 10, 17, 9))
        #expect(reminders.first?.choreNames == ["WC"])
        // Then every 7 days only if done; the plan is made again after each "Fatta".
        #expect(reminders.count == 1)
    }

    @Test func aLateChoreIsNotRepeatedEveryMorning() {
        let late = Fixtures.chore("Forno", lastDone: Fixtures.daysAgo(30))
        #expect(plan([late]).isEmpty)
    }

    @Test func dueTodayIsRemindedIfTheTimeHasNotPassed() {
        let chore = Fixtures.chore("Piatti", every: 1, lastDone: Fixtures.date(2026, 10, 13, 20))
        let morning = Fixtures.date(2026, 10, 14, 7)
        #expect(plan([chore], now: morning).first?.fireDate == Fixtures.date(2026, 10, 14, 9))
        let afternoon = Fixtures.date(2026, 10, 14, 15)
        #expect(plan([chore], now: afternoon).first?.fireDate != Fixtures.date(2026, 10, 14, 9))
    }

    @Test func pausedChoresNeverRemind() {
        let paused = Fixtures.chore(lastDone: Fixtures.daysAgo(5), pausedAt: Fixtures.daysAgo(1))
        #expect(plan([paused]).isEmpty)
    }

    @Test func choresOfTheSameDayShareOneNotificationDirtiestFirst() {
        // Both due on the 17th: the dirtiest now comes first.
        let weekly = Fixtures.chore("Pavimenti", every: 7, lastDone: Fixtures.daysAgo(4))
        let threeDays = Fixtures.chore("Spazzatura", every: 3, lastDone: Fixtures.date(2026, 10, 14, 8))
        let reminders = plan([weekly, threeDays])
        #expect(reminders.count == 1)
        #expect(reminders.first?.choreNames == ["Pavimenti", "Spazzatura"])
    }

    @Test func aChoreIsRemindedOnceUntilItIsDoneAgain() {
        // Done now: due tomorrow, then the plan stops because it is not done again.
        let chore = Fixtures.chore(every: 1, lastDone: Fixtures.now)
        #expect(plan([chore]).count == 1)
    }

    @Test(arguments: [(-5, -10, 0, 0), (30, 99, 23, 59), (7, 30, 7, 30)])
    func absurdTimesAreClamped(hour: Int, minute: Int, expectedHour: Int, expectedMinute: Int) throws {
        let chore = Fixtures.chore(lastDone: Fixtures.daysAgo(4))
        let reminder = try #require(plan([chore], hour: hour, minute: minute).first)
        let parts = Fixtures.calendar.dateComponents([.hour, .minute], from: reminder.fireDate)
        #expect(parts.hour == expectedHour)
        #expect(parts.minute == expectedMinute)
    }

    @Test(arguments: [0, -3])
    func noDaysNoReminders(days: Int) {
        #expect(plan([Fixtures.chore(lastDone: Fixtures.daysAgo(4))], days: days).isEmpty)
    }

    @Test func beyondTheHorizonIsLeftForTheNextPlan() {
        let monthly = Fixtures.chore(every: 30, lastDone: Fixtures.daysAgo(1))
        #expect(plan([monthly]).isEmpty)
    }

    @Test func identifiersAreStablePerDay() {
        let chore = Fixtures.chore(lastDone: Fixtures.daysAgo(4))
        #expect(plan([chore]).map(\.identifier) == plan([chore]).map(\.identifier))
    }

    @Test(arguments: [
        ([String](), ""),
        (["WC"], "WC"),
        (["WC", "Doccia"], "WC e Doccia"),
        (["WC", "Doccia", "Specchio"], "WC, Doccia e Specchio"),
    ])
    func bodyNamesUpToThreeChores(names: [String], expected: String) {
        #expect(ReminderText.body(for: names, locale: Locale(identifier: "it_IT")) == expected)
    }

    @Test func bodyCountsTheOthersBeyondThree() {
        let body = ReminderText.body(for: ["WC", "Doccia", "Specchio", "Pavimento", "Asciugamani"], locale: Locale(identifier: "it_IT"))
        #expect(body.hasPrefix("WC e Doccia"))
        #expect(body.contains("3"))
        #expect(!body.contains("Specchio"))
    }
}
