import Foundation
import Testing
@testable import SbuHabits

struct WidgetChoiceTests {
    private let today = LogicalDay(ordinal: 1_004) // a Sunday

    private func habits() -> [Habit] {
        var reading = Habit(title: "Leggere", symbol: "book", createdOn: today - 5)
        reading.log[today] = 1
        let walking = Habit(title: "Camminare", symbol: "figure.walk", createdOn: today - 5)
        let mondays = Habit(title: "Piante", symbol: "leaf", schedule: .weekdays([2]), createdOn: today - 5)
        return [reading, walking, mondays]
    }

    @Test func noChoiceShowsAllOfToday() {
        #expect(WidgetChoice.grid(habits(), chosen: [], today: today, firstWeekday: 2).map(\.title) == ["Leggere", "Camminare"])
    }

    @Test func aChoiceNarrowsTodaysGrid() {
        let habits = habits()

        let shown = WidgetChoice.grid(habits, chosen: [habits[1].id, habits[2].id], today: today, firstWeekday: 2)

        // Piante is chosen but not expected on Sundays.
        #expect(shown.map(\.title) == ["Camminare"])
    }

    @Test func withoutAChoiceTheSingleWidgetShowsTheFirstStillToDo() {
        #expect(WidgetChoice.single(habits(), chosen: nil, today: today, firstWeekday: 2)?.title == "Camminare")
    }

    @Test func aChosenHabitShowsEvenOnAnUnexpectedDay() {
        let habits = habits()

        #expect(WidgetChoice.single(habits, chosen: habits[2].id, today: today, firstWeekday: 2)?.title == "Piante")
    }

    @Test func aDeletedChoiceShowsNothing() {
        #expect(WidgetChoice.single(habits(), chosen: UUID(), today: today, firstWeekday: 2) == nil)
    }
}
