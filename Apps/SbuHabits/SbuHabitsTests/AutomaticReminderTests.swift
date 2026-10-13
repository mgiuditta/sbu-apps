import Testing
@testable import SbuHabits

struct AutomaticReminderTests {
    private let today = LogicalDay(ordinal: 20_100)

    /// The first marks of the days before today, the newest last: `[18, 19]` is 19 yesterday.
    private func history(_ hours: [[Int]]) -> [LogicalDay: [Int]] {
        Dictionary(uniqueKeysWithValues: hours.reversed().enumerated().map { (today - 1 - $0.offset, $0.element) })
    }

    @Test(arguments: [
        ([[Int]](), 0, AutomaticReminder.fallback.hour), // nothing to read
        ([[18], [18]], 0, AutomaticReminder.fallback.hour), // two days are not a habit yet
        ([[18], [18], [19]], 0, 18),
        ([[7], [21], [8], [9], [22]], 0, 9), // the median, not the mean
        ([[7], [9], [21], [22]], 0, 9), // even: the earlier middle
        ([[9, 13, 20], [9, 14], [10, 21]], 0, 9), // the first mark of each day
        ([[23], [1], [0]], 4, 0), // across midnight within one logical day: 23, 0, 1
        ([[3], [5], [5]], 4, 5), // 03:00 before a start at 4 is the night before, late
    ])
    func theReminderComesAtTheUsualHour(hours: [[Int]], startHour: Int, expected: Int) {
        let time = AutomaticReminder.time(from: history(hours), through: today, startHour: startHour)

        #expect(time == ReminderTime(hour: expected, minute: 0))
    }

    @Test func onlyTheRecentDaysCount() {
        // Three weeks of mornings, then two weeks of evenings: the evenings win.
        let hours = Array(repeating: [7], count: 21) + Array(repeating: [19], count: AutomaticReminder.recentDays)

        #expect(AutomaticReminder.time(from: history(hours), through: today, startHour: 0).hour == 19)
    }

    @Test func daysAfterTodayAndDaysWithoutHoursAreLeftOut() {
        var hours = history([[18], [18], [18]])
        hours[today + 1] = [6]
        hours[today + 2] = [6]
        hours[today - 10] = []

        #expect(AutomaticReminder.time(from: hours, through: today, startHour: 0).hour == 18)
    }

    @Test func aHabitRemindingAutomaticallyFollowsItsMarks() {
        var habit = Habit(title: "Leggere", symbol: "book", createdOn: today - 10)
        _ = habit.update(title: "Leggere", symbol: "book", timesPerDay: 1, schedule: .everyDay, reminders: [ReminderTime(hour: 8, minute: 0)], remindsAutomatically: true, from: today - 10)
        #expect(habit.reminders.isEmpty)
        #expect(habit.reminderTimes(through: today, startHour: 0) == [AutomaticReminder.fallback])

        for day in 1...3 {
            habit.mark(on: today - day, hour: 21)
        }

        #expect(habit.reminderTimes(through: today, startHour: 0) == [ReminderTime(hour: 21, minute: 0)])
    }
}
