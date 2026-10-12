import Foundation
import Testing
@testable import SbuHabits

struct WidgetSlotsTests {
    private let today = LogicalDay(ordinal: 1_004)

    private func habits(_ count: Int, doneIndices: Set<Int> = []) -> ([Habit], [Habit.ID: HabitProgress]) {
        let habits = (0..<count).map { index in
            var habit = Habit(title: "\(index)", symbol: "book", createdOn: today)
            if doneIndices.contains(index) {
                habit.log[today] = 1
            }
            return habit
        }
        let progress = Dictionary(uniqueKeysWithValues: habits.map { ($0.id, HabitProgress(of: $0, today: today, firstWeekday: 2)) })
        return (habits, progress)
    }

    @Test(arguments: [(0, 0, 0), (3, 3, 0), (8, 8, 0), (9, 7, 2), (40, 7, 33)])
    func whenTheyDoNotFitTheLastCellCountsTheRest(count: Int, shown: Int, overflow: Int) {
        let (habits, progress) = habits(count)

        let slots = WidgetSlots(habits, progress: progress, capacity: 8)

        #expect(slots.shown.count == shown)
        #expect(slots.overflow == overflow)
    }

    @Test func habitsStillToDoComeFirst() {
        let (habits, progress) = habits(5, doneIndices: [0, 2])

        let slots = WidgetSlots(habits, progress: progress, capacity: 4)

        #expect(slots.shown.map(\.title) == ["1", "3", "4"])
        #expect(slots.overflow == 2)
    }
}
