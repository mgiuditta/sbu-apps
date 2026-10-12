import Foundation
import Testing
@testable import SbuHabits

/// The widget's button: the same file, one mark per tap, never past the goal.
struct MarkHabitIntentTests {
    private let store = HabitsStore(url: .temporaryDirectory.appending(path: "MarkHabitIntentTests-\(UUID().uuidString).json"))

    @Test func aTapMarksOnceInTheSharedFile() throws {
        let model = HabitsModel(store: store, scheduleReminders: { _ in })
        model.add(title: "Bere acqua", symbol: "drop", timesPerDay: 2)
        let id = model.habits[0].id.uuidString

        _ = try MarkHabitIntent.mark(id, in: store, now: .now)
        _ = try MarkHabitIntent.mark(id, in: store, now: .now)
        let file = try MarkHabitIntent.mark(id, in: store, now: .now)

        #expect(file.habits[0].count(on: model.today) == 2)
        model.reload()
        #expect(model.fullStreak == 1)
    }

    @Test func anUnknownHabitChangesNothing() throws {
        let model = HabitsModel(store: store, scheduleReminders: { _ in })
        model.add(title: "Leggere", symbol: "book")

        let file = try MarkHabitIntent.mark(UUID().uuidString, in: store, now: .now)

        #expect(file.habits == model.habits)
    }
}
