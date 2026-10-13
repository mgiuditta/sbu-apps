import Foundation
import Testing
@testable import SbuHabits

struct WatchMarkingTests {
    private let today = LogicalDay(ordinal: 1_004) // a Sunday

    private func action(_ habit: Habit, _ kind: WatchAction.Kind, daysAgo: Int = 0, hour: Int = 9) -> WatchAction {
        WatchAction(habitID: habit.id, day: today - daysAgo, hour: hour, kind: kind)
    }

    @Test(arguments: [
        // times a day, marked before, the tap, marks after
        (1, 0, WatchAction.Kind.mark, 1),
        (1, 1, .mark, 1), // done today stays done, as a tap on the iPhone
        (3, 1, .mark, 2),
        (3, 2, .undo, 1),
        (1, 0, .undo, 0),
    ])
    func appliesATapAsTheIPhoneDoes(timesPerDay: Int, before: Int, kind: WatchAction.Kind, after: Int) {
        var habit = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: timesPerDay, createdOn: today - 5)
        habit.log[today] = before > 0 ? before : nil
        var habits = [habit]

        let changed = WatchMarking.apply(action(habit, kind), to: &habits, today: today)

        #expect(habits[0].count(on: today) == after)
        #expect(changed == (before != after))
    }

    @Test(arguments: [0, 1, 2])
    func anAbitudineDaEvitareCountsEveryTimeGivenInPastTheLimite(before: Int) {
        var coffee = Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 1, createdOn: today - 5)
        coffee.log[today] = before > 0 ? before : nil
        var habits = [coffee]

        #expect(WatchMarking.apply(action(coffee, .mark), to: &habits, today: today))
        #expect(habits[0].count(on: today) == before + 1)
    }

    @Test func aMarkKeepsTheWatchHourAndTakesTheSkipBack() {
        var habit = Habit(title: "Leggere", symbol: "book", createdOn: today - 5)
        habit.toggleSkip(on: today)
        var habits = [habit]

        _ = WatchMarking.apply(action(habit, .mark, hour: 22), to: &habits, today: today)

        #expect(habits[0].markHours[today] == [22])
        #expect(habits[0].isSkipped(on: today) == false)
    }

    @Test func aTapOfYesterdayLandsOnYesterday() {
        let habit = Habit(title: "Leggere", symbol: "book", createdOn: today - 5)
        var habits = [habit]

        _ = WatchMarking.apply(action(habit, .mark, daysAgo: 1), to: &habits, today: today)

        #expect(habits[0].isDone(on: today - 1))
        #expect(habits[0].isDone(on: today) == false)
    }

    @Test func neverADayStillToComeNorAHabitThatIsGone() {
        let habit = Habit(title: "Leggere", symbol: "book", createdOn: today - 5)
        let gone = Habit(title: "Camminare", symbol: "figure.walk", createdOn: today - 5)
        var habits = [habit]

        #expect(WatchMarking.apply(action(habit, .mark, daysAgo: -1), to: &habits, today: today) == false)
        #expect(WatchMarking.apply(action(gone, .mark), to: &habits, today: today) == false)
        #expect(habits == [habit])
    }
}
