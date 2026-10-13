import Foundation
import Testing
@testable import SbuHabits

struct TodayTallyTests {
    private let today = LogicalDay(ordinal: 1_004)

    @Test(arguments: [(0, 0, 0), (2, 1, 2), (3, 3, 3)])
    func countsTodaysHabitsDone(habitCount: Int, doneCount: Int, total: Int) {
        let habits = (0..<habitCount).map { index in
            var habit = Habit(title: "Abitudine \(index)", symbol: "book", createdOn: today - 3)
            if index < doneCount {
                habit.mark(on: today, hour: 9)
            }
            return habit
        }
        let snapshot = WatchSnapshot(habits: habits, today: today, startHour: 0, firstWeekday: 2, nextDayStart: .distantFuture, applied: [])

        let complication = TodayTally(snapshot)

        #expect(complication.done == doneCount)
        #expect(complication.total == total)
        #expect(complication.fullStreak == snapshot.fullStreak)
    }

    @Test(arguments: [0, 1, 3])
    func anAbitudineDaEvitareStaysOutOfTodaysCount(timesGivenIn: Int) {
        var reading = Habit(title: "Leggere", symbol: "book", createdOn: today - 3)
        reading.mark(on: today, hour: 9)
        var coffee = Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 1, createdOn: today - 3)
        coffee.log[today] = timesGivenIn > 0 ? timesGivenIn : nil
        let snapshot = WatchSnapshot(habits: [reading, coffee], today: today, startHour: 0, firstWeekday: 2, nextDayStart: .distantFuture, applied: [])

        let tally = TodayTally(snapshot)

        #expect(tally.done == 1)
        #expect(tally.total == 1)
    }
}
