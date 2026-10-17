import Foundation
import Testing
@testable import SbuHabits

struct HabitCheckTests {
    private let today = LogicalDay(ordinal: 1_004)
    private let store = HabitsStore(url: .temporaryDirectory.appending(path: "HabitCheckTests-\(UUID().uuidString).json"))

    private func check(_ habit: Habit) -> HabitCheck {
        HabitCheck(habit: habit, progress: HabitProgress(of: habit, today: today, firstWeekday: 2), today: today)
    }

    @Test(arguments: [(0, false), (2, false), (3, true)])
    func theBoxIsTickedOnceEveryTimeOfTheDayIsDone(marks: Int, isChecked: Bool) {
        var water = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 3, createdOn: today)
        water.log[today] = marks > 0 ? marks : nil

        let check = check(water)

        #expect(check.isChecked == isChecked)
        #expect(check.isDone == isChecked)
        #expect(check.countsTimes)
        #expect(check.counts)
    }

    @Test func anAbitudineDaEvitareHasNoBoxAndStaysOutOfTheTally() {
        var coffee = Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: today)
        coffee.log[today] = 1

        let check = check(coffee)

        #expect(check.hasCheckbox == false)
        #expect(check.isChecked == false)
        #expect(check.counts == false)
    }

    @Test func aHabitSkippedTodayStaysOutOfTheTally() {
        var reading = Habit(title: "Leggere", symbol: "book", createdOn: today)
        reading.toggleSkip(on: today)

        let check = check(reading)

        #expect(check.hasCheckbox)
        #expect(check.counts == false)
    }

    @Test func tickingTheBoxMarksEveryTimeLeftAndTakesBackASkip() throws {
        let model = HabitsModel(store: store)
        model.add(title: "Bere acqua", symbol: "drop", timesPerDay: 3)
        model.markDone(model.habits[0])
        model.toggleSkip(model.habits[0])

        model.fill(model.habits[0])

        let water = try #require(model.habits.first)
        #expect(water.count(on: model.today) == 3)
        #expect(water.isSkipped(on: model.today) == false)
        #expect(model.check(of: water).isChecked)
    }

    @Test func theTallyIsCompleteOnceEveryHabitToDoIsDone() {
        let model = HabitsModel(store: store)
        model.add(title: "Leggere", symbol: "book")
        model.add(title: "Bere acqua", symbol: "drop", timesPerDay: 2)
        model.add(title: "Caffè", symbol: "cup.and.saucer", limit: 1)
        #expect(model.todayTally.isComplete == false)
        #expect(model.todayTally.total == 2)

        model.fill(model.habits[0])
        model.fill(model.habits[1])

        #expect(model.todayTally.done == 2)
        #expect(model.todayTally.isComplete)
        #expect(model.todayTally.fullStreak == 1)
    }

    @Test func nothingToDoIsNeverAComplete() {
        #expect(TodayTally(fullStreak: 4, done: 0, total: 0).isComplete == false)
    }
}
