import Foundation
import Testing
@testable import SbuHabits

/// The one-habit widgets of Streaks: the Serie, the line, the weekday bars and the calendar.
struct HabitInsightContentTests {
    /// Tuesday 13 October 2026.
    private let today = LogicalDay(ordinal: 20_739)

    private func habits() -> [Habit] {
        var reading = Habit(title: "Leggere", symbol: "book", createdOn: today - 20)
        for daysAgo in 0...4 {
            reading.log[today - daysAgo] = 1
        }
        let walking = Habit(title: "Camminare", symbol: "figure.walk", createdOn: today - 20)
        return [reading, walking]
    }

    @Test(arguments: HabitInsight.allCases)
    func eachInsightWorksOutOnlyWhatItDraws(insight: HabitInsight) throws {
        let content = try #require(HabitInsightContent(habits: habits(), chosen: nil, insight: insight, today: today, firstWeekday: 2))

        #expect((content.statistics != nil) == (insight == .rate || insight == .weekdays))
        #expect(content.calendar.isEmpty == (insight != .calendar))
        #expect(content.insight == insight)
    }

    @Test(arguments: HabitInsight.allCases)
    func withoutHabitsThereIsNothingToDraw(insight: HabitInsight) {
        #expect(HabitInsightContent(habits: [], chosen: nil, insight: insight, today: today, firstWeekday: 2) == nil)
    }

    @Test func withoutAChoiceItShowsTheFirstStillToDo() throws {
        let content = try #require(HabitInsightContent(habits: habits(), chosen: nil, insight: .streak, today: today, firstWeekday: 2))

        #expect(content.habit.title == "Camminare")
        #expect(content.streak == 0)
    }

    @Test func theChosenHabitBringsItsSerie() throws {
        let habits = habits()

        let content = try #require(HabitInsightContent(habits: habits, chosen: habits[0].id, insight: .streak, today: today, firstWeekday: 2))

        #expect(content.habit.title == "Leggere")
        #expect(content.streak == 5)
        #expect(content.progress.isComplete)
    }

    @Test func theLineAndTheBarsCountFromTheHabitsFirstDay() throws {
        let habits = habits()

        let content = try #require(HabitInsightContent(habits: habits, chosen: habits[0].id, insight: .rate, today: today, firstWeekday: 2))
        let statistics = try #require(content.statistics)

        #expect(statistics.firstDay == today - 20)
        #expect(statistics.completions == 5)
        #expect(statistics.line.isEmpty == false)
    }
}
