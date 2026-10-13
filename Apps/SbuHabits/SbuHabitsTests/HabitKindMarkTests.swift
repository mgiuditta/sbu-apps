import Testing
@testable import SbuHabits

/// The heart and the ⊘ before a title, on the grid and in the widgets.
struct HabitKindMarkTests {
    private let today = LogicalDay(ordinal: 20_739)

    private var linkedToHealth: Habit {
        var habit = Habit(title: "Camminare", symbol: "figure.walk", createdOn: today)
        _ = habit.update(title: habit.title, symbol: habit.symbol, timesPerDay: 1, schedule: .everyDay, health: HealthLink(measure: .steps, goal: 8_000), from: today)
        return habit
    }

    private var timed: Habit {
        var habit = Habit(title: "Meditare", symbol: "brain.head.profile", createdOn: today)
        _ = habit.update(title: habit.title, symbol: habit.symbol, timesPerDay: 1, schedule: .everyDay, timerMinutes: 10, from: today)
        return habit
    }

    @Test func eachKindHasItsMark() {
        #expect(HabitKindMark.symbol(of: linkedToHealth) == "heart.fill")
        #expect(HabitKindMark.symbol(of: Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: today)) == "nosign")
        #expect(HabitKindMark.symbol(of: Habit(title: "Leggere", symbol: "book", createdOn: today)) == nil)
        #expect(HabitKindMark.symbol(of: timed) == nil)
        #expect(HabitKindMark.symbol(of: Habit(title: "Visita", symbol: "stethoscope", schedule: .oneDay(today), createdOn: today)) == nil)
    }
}
