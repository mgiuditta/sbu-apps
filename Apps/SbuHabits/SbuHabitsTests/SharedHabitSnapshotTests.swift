import Foundation
import Testing
@testable import SbuHabits

/// What travels of an Abitudine condivisa, and what never does.
struct SharedHabitSnapshotTests {
    private let today = LogicalDay(ordinal: 20_010)

    /// A habit with everything set: reminders, notification style, Salute, notes, an edit, marks and a skip.
    private func fullHabit() -> Habit {
        var habit = Habit(title: "Camminare", symbol: "figure.walk", timesPerDay: 2, createdOn: today - 30)
        habit.mark(on: today - 2, hour: 7)
        habit.mark(on: today - 2, hour: 19)
        habit.toggleSkip(on: today - 1)
        habit.setNote("Pioggia", on: today - 2, at: .now)
        _ = habit.update(title: "Camminare", symbol: "figure.walk", timesPerDay: 3, schedule: .everyDay, reminders: [ReminderTime(hour: 8, minute: 0)], notificationStyle: NotificationStyle(), from: today)
        habit.modifiedAt = .now
        return habit
    }

    @Test func itKeepsWhatTheDecisionLetsTravel() {
        let habit = fullHabit()
        let shared = SharedHabitSnapshot(habit: habit, startHour: 4).habit

        #expect(shared.id == habit.id)
        #expect(shared.title == habit.title)
        #expect(shared.symbol == habit.symbol)
        #expect(shared.createdOn == habit.createdOn)
        #expect(shared.log == habit.log)
        #expect(shared.skipped == habit.skipped)
        #expect(shared.timesPerDay(on: today) == 3)
        // The goal of the days before the edit travels too: the history reads the same.
        #expect(shared.timesPerDay(on: today - 2) == 2)
        #expect(shared.isDone(on: today - 2) == habit.isDone(on: today - 2))
    }

    @Test(arguments: [
        "reminders", "notes", "health", "timer", "modifiedAt",
    ])
    func itNeverCarries(_ field: String) throws {
        var habit = fullHabit()
        if field == "health" {
            _ = habit.update(title: "Passi", symbol: "figure.walk", timesPerDay: 1, schedule: .everyDay, health: HealthLink(measure: .steps, goal: 8000), from: today)
        }
        if field == "timer" {
            _ = habit.update(title: "Meditare", symbol: "brain.head.profile", timesPerDay: 1, schedule: .everyDay, timerMinutes: 10, from: today)
        }
        let shared = SharedHabitSnapshot(habit: habit, startHour: 0).habit

        switch field {
        case "reminders":
            #expect(shared.reminders.isEmpty)
            #expect(shared.reminderMode == .off)
            #expect(shared.notificationStyle == NotificationStyle())
        case "notes":
            #expect(shared.note(on: today - 2) == nil)
            #expect(shared.settingsOnly.notes.isEmpty)
        case "health":
            #expect(habit.health != nil)
            #expect(shared.health == nil)
        case "timer":
            #expect(habit.timerMinutes != nil)
            #expect(shared.timerMinutes == nil)
        default:
            #expect(shared.modifiedAt == nil)
        }
        // Nor in the bytes that go to iCloud.
        let json = try #require(String(data: try SharedHabitSnapshot(habit: habit, startHour: 0).encoded(), encoding: .utf8))
        #expect(json.contains("Pioggia") == false)
    }

    @Test(arguments: [(-1, 0), (0, 0), (4, 4), (9, 6)])
    func theStartOfTheDayStaysInRange(given: Int, kept: Int) {
        #expect(SharedHabitSnapshot(habit: fullHabit(), startHour: given).startHour == kept)
    }

    @Test func itReadsBackWhatItWrote() throws {
        let snapshot = SharedHabitSnapshot(habit: fullHabit(), startHour: 3)

        #expect(try SharedHabitSnapshot.decode(snapshot.encoded()) == snapshot)
    }

    @Test func aSnapshotFromANewerAppIsRefused() throws {
        var snapshot = SharedHabitSnapshot(habit: fullHabit(), startHour: 0)
        snapshot.version = SharedHabitSnapshot.currentVersion + 1

        #expect(throws: SharedHabitSnapshot.Failure.newerVersion(SharedHabitSnapshot.currentVersion + 1)) {
            try SharedHabitSnapshot.decode(snapshot.encoded())
        }
    }

    @Test func readingStripsWhateverTheDataCarries() throws {
        // A snapshot written with the reminders and notes left in, as a careless writer could.
        struct Raw: Encodable {
            let version: Int
            let habit: Habit
            let startHour: Int
        }
        let data = try JSONEncoder().encode(Raw(version: 1, habit: fullHabit(), startHour: 0))

        let habit = try SharedHabitSnapshot.decode(data).habit

        #expect(habit.reminders.isEmpty)
        #expect(habit.note(on: today - 2) == nil)
    }
}
