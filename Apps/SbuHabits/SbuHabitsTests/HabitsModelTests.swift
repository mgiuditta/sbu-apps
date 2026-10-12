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

    @Test func eachMarkAddsOneTimeUpToTheGoal() {
        let model = HabitsModel(store: store)
        model.add(title: "Bere acqua", symbol: "drop", timesPerDay: 3)

        for _ in 1...5 {
            model.markDone(model.habits[0])
        }

        #expect(model.habits[0].count(on: model.today) == 3)
        #expect(model.fullStreak == 1)
    }

    @Test func undoTakesBackOneTime() {
        let model = HabitsModel(store: store)
        model.add(title: "Bere acqua", symbol: "drop", timesPerDay: 3)
        for _ in 1...3 {
            model.markDone(model.habits[0])
        }

        model.undoLast(model.habits[0])

        #expect(model.habits[0].count(on: model.today) == 2)
        #expect(model.fullStreak == 0)
    }

    @Test(arguments: [(0, 1), (8, 8), (99, 20)])
    func timesPerDayStayInRange(requested: Int, saved: Int) {
        let model = HabitsModel(store: store)

        model.add(title: "Bere acqua", symbol: "drop", timesPerDay: requested)

        #expect(model.habits[0].timesPerDay == saved)
    }

    @Test func aScheduleWithoutDaysAddsNothing() {
        let model = HabitsModel(store: store)

        model.add(title: "Palestra", symbol: "dumbbell", schedule: .weekdays([]))

        #expect(model.habits.isEmpty)
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

    @Test func withADayStartingAtFourMarksAtTwoCountForTheDayBefore() throws {
        var rome = Calendar(identifier: .gregorian)
        rome.timeZone = try #require(TimeZone(identifier: "Europe/Rome"))
        let twoAM = try #require(rome.date(from: DateComponents(year: 2026, month: 10, day: 13, hour: 2)))
        let noonBefore = try #require(rome.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 12)))
        let model = HabitsModel(store: store, now: { twoAM }, calendar: rome)

        model.setStartHour(4)

        #expect(model.today == LogicalDay(noonBefore, calendar: rome))
        #expect(HabitsModel(store: store, now: { twoAM }, calendar: rome).startHour == 4)
    }

    @Test(arguments: [-1, 7, 99])
    func theStartHourStaysBetweenMidnightAndSix(hour: Int) {
        let model = HabitsModel(store: store)

        model.setStartHour(hour)

        #expect(HabitsFile.startHourRange.contains(model.startHour))
    }

    @Test func editingKeepsTheLog() throws {
        let model = HabitsModel(store: store)
        model.add(title: "Leggere", symbol: "book")
        model.markDone(model.habits[0])

        model.edit(model.habits[0], title: "Leggere 20 pagine", symbol: "books.vertical", timesPerDay: 1, schedule: .weekdays([2, 4]))

        let habit = try #require(HabitsModel(store: store).habits.first)
        #expect(habit.title == "Leggere 20 pagine")
        #expect(habit.schedule == .weekdays([2, 4]))
        #expect(habit.count(on: model.today) == 1)
    }

    @Test func aBlankEditChangesNothing() {
        let model = HabitsModel(store: store)
        model.add(title: "Leggere", symbol: "book")

        model.edit(model.habits[0], title: "  ", symbol: "drop", timesPerDay: 3, schedule: .everyDay)

        #expect(model.habits[0].title == "Leggere")
        #expect(model.habits[0].symbol == "book")
    }

    @Test func deletingRemovesTheHabitAndItsLog() {
        let model = HabitsModel(store: store)
        model.add(title: "Leggere", symbol: "book")
        model.add(title: "Camminare", symbol: "figure.walk")
        model.markDone(model.habits[0])

        model.delete(model.habits[0])

        #expect(model.habits.map(\.title) == ["Camminare"])
        #expect(HabitsModel(store: store).habits.allSatisfy { $0.log.isEmpty })
    }
}
