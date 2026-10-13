import Foundation
import Testing
@testable import SbuHabits

struct ComplicationTodayTests {
    private let today = LogicalDay(ordinal: 1_004)

    @Test(arguments: [(0, 0, 0), (2, 1, 2), (3, 3, 3)])
    func theComplicationCountsTodaysHabitsDone(habitCount: Int, doneCount: Int, total: Int) {
        let habits = (0..<habitCount).map { index in
            var habit = Habit(title: "Abitudine \(index)", symbol: "book", createdOn: today - 3)
            if index < doneCount {
                habit.mark(on: today, hour: 9)
            }
            return habit
        }
        let snapshot = WatchSnapshot(habits: habits, today: today, startHour: 0, firstWeekday: 2, nextDayStart: .distantFuture, applied: [])

        let complication = ComplicationToday(snapshot)

        #expect(complication.done == doneCount)
        #expect(complication.total == total)
        #expect(complication.fullStreak == snapshot.fullStreak)
    }
}
