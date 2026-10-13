import Foundation
import Testing
@testable import SbuHabits

struct WatchSnapshotTests {
    private let today = LogicalDay(ordinal: 1_004) // Sunday 1 October 1972: the week started 6 days before
    private let firstWeekday = 2

    /// A habit created 60 days ago and done on the given days ago (0 is today).
    private func habit(_ title: String = "Leggere", timesPerDay: Int = 1, doneDaysAgo: [Int]) -> Habit {
        var habit = Habit(title: title, symbol: "book", timesPerDay: timesPerDay, createdOn: today - 60)
        for daysAgo in doneDaysAgo {
            habit.log[today - daysAgo] = timesPerDay
        }
        return habit
    }

    private func coffee(given: [Int: Int]) -> Habit {
        var coffee = Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 1, createdOn: today - 60)
        for (daysAgo, times) in given {
            coffee.log[today - daysAgo] = times
        }
        return coffee
    }

    private func snapshot(_ habits: [Habit], applied: [UUID] = []) -> WatchSnapshot {
        WatchSnapshot(habits: habits, today: today, startHour: 0, firstWeekday: firstWeekday, nextDayStart: .distantFuture, applied: applied)
    }

    @Test(arguments: [
        [[0, 1, 2], [0, 1, 2]], // all done
        [[1, 2], [1, 2]], // today not complete yet
        [[0, 1, 2], [1, 2]], // one done today, the other not yet
        [[0, 1, 2], [0, 2]], // one missed yesterday
        [[Int](), []],
        [Array(0...40), Array(0...40)], // a Serie longer than the days the watch gets
    ])
    func theWatchCountsTheSeriePienaAsTheIPhone(doneDaysAgo: [[Int]]) {
        let habits = doneDaysAgo.enumerated().map { habit("Abitudine \($0.offset)", doneDaysAgo: $0.element) }

        #expect(snapshot(habits).fullStreak == Streak.full(of: habits, today: today))
    }

    @Test(arguments: [[Int: Int](), [0: 1], [0: 2], [1: 2]])
    func aLimiteGoneOverTodayBreaksTheSeriePienaOnTheWatchToo(given: [Int: Int]) {
        let habits = [habit(doneDaysAgo: Array(0...20)), coffee(given: given)]

        #expect(snapshot(habits).fullStreak == Streak.full(of: habits, today: today))
    }

    @Test(arguments: [WatchAction.Kind.mark, .undo])
    func aTapOnTheWatchMovesTheSeriePienaAsOnTheIPhone(kind: WatchAction.Kind) {
        var habits = [habit("Leggere", doneDaysAgo: Array(1...9)), habit("Camminare", doneDaysAgo: Array(0...9))]
        if kind == .undo {
            habits[0].log[today] = 1
        }
        let action = WatchAction(habitID: habits[0].id, day: today, hour: 8, kind: kind)

        let watch = snapshot(habits).applying(action)
        _ = WatchMarking.apply(action, to: &habits, today: today)

        #expect(watch.fullStreak == Streak.full(of: habits, today: today))
        #expect(watch.fullStreak == (kind == .mark ? 10 : 9))
    }

    @Test func onlyTodaysGridTravelsInItsOrder() {
        let reading = habit("Leggere", doneDaysAgo: [])
        let tomorrowOnly = Habit(title: "Dentista", symbol: "calendar", schedule: .oneDay(today + 1), createdOn: today - 1)
        let walking = habit("Camminare", doneDaysAgo: [])

        #expect(snapshot([reading, tomorrowOnly, walking]).habits.map(\.id) == [reading.id, walking.id])
    }

    @Test func onlyThisWeekAndMonthTravelWithoutNotes() {
        var reading = habit(doneDaysAgo: Array(0...45))
        reading.setNote("Bello", on: today)

        let sent = snapshot([reading]).habits[0]

        // 1 October: the week started on Monday, 6 days ago, before the month did.
        #expect(sent.log.keys.min() == today - 6)
        #expect(sent.log.count == 7)
        #expect(sent.note(on: today) == nil)
    }

    @Test func aWeeklyRingCountsTheWeekAsOnTheIPhone() {
        var gym = Habit(title: "Palestra", symbol: "dumbbell", schedule: .timesPerWeek(3), createdOn: today - 60)
        for daysAgo in [0, 2, 4, 9] {
            gym.log[today - daysAgo] = 1
        }
        let sent = snapshot([gym])

        #expect(sent.progress(of: sent.habits[0]) == HabitProgress(of: gym, today: today, firstWeekday: firstWeekday))
    }

    @Test func theGridIsCurrentUntilTheNextDayStarts() {
        let start = Date(timeIntervalSince1970: 1_000_000)
        let sent = WatchSnapshot(habits: [], today: today, startHour: 0, firstWeekday: firstWeekday, nextDayStart: start, applied: [])

        #expect(sent.isCurrent(at: start - 1))
        #expect(sent.isCurrent(at: start) == false)
    }

    @Test(arguments: [[Int](), [0], [1, 2, 3], [0, 2, 3, 4]])
    func theSeriePienaUpToYesterdayAndTodayMakeTheWholeOne(doneDaysAgo: [Int]) {
        let habits = [habit(doneDaysAgo: doneDaysAgo), coffee(given: [0: 1])]

        #expect(Streak.full(of: habits, today: today, before: Streak.fullBeforeToday(of: habits, today: today)) == Streak.full(of: habits, today: today))
    }
}
