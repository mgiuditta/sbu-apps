import Foundation
import Testing
@testable import SbuHabits

struct HabitsModelTests {
    private let store = HabitsStore(url: .temporaryDirectory.appending(path: "HabitsModelTests-\(UUID().uuidString).json"))

    @Test func markingEveryHabitRaisesTheFullStreak() throws {
        let model = HabitsModel(store: store)
        model.add(title: "Leggere", symbol: "book")
        model.add(title: "Camminare", symbol: "figure.walk")

        model.markDone(model.habits[0])
        #expect(model.fullStreak == 0)

        model.markDone(model.habits[1])
        #expect(model.fullStreak == 1)
        #expect(model.streak(of: model.habits[1]) == 1)
    }

    @Test func undoTakesBackTodaysMark() {
        let model = HabitsModel(store: store)
        model.add(title: "Leggere", symbol: "book")
        model.markDone(model.habits[0])

        model.undoLast(model.habits[0])

        #expect(model.habits[0].isDone(on: model.today) == false)
        #expect(model.fullStreak == 0)
    }

    @Test func markingTwiceCountsOnce() {
        let model = HabitsModel(store: store)
        model.add(title: "Leggere", symbol: "book")

        model.markDone(model.habits[0])
        model.markDone(model.habits[0])

        #expect(model.habits[0].log[model.today] == 1)
    }

    @Test func habitsAreSavedBetweenLaunches() {
        let first = HabitsModel(store: store)
        first.add(title: "Leggere", symbol: "book")
        first.markDone(first.habits[0])

        let second = HabitsModel(store: store)

        #expect(second.habits == first.habits)
        #expect(second.fullStreak == 1)
    }

    @Test(arguments: ["", "   ", "\n"])
    func aBlankTitleAddsNothing(title: String) {
        let model = HabitsModel(store: store)

        model.add(title: title, symbol: "book")

        #expect(model.habits.isEmpty)
    }

    @Test func longTitlesAreCut() {
        let model = HabitsModel(store: store)

        model.add(title: String(repeating: "a", count: 50), symbol: "book")

        #expect(model.habits[0].title.count == Habit.maxTitleLength)
    }
}
