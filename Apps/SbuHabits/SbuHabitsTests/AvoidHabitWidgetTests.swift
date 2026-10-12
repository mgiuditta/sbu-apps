import Foundation
import Testing
@testable import SbuHabits

/// The widgets show the Abitudini da evitare too, after the habits still to do, and a tap counts
/// one more time given in on the same file as the app.
struct AvoidHabitWidgetTests {
    private let today = LogicalDay(ordinal: 1_004) // a Sunday
    private let store = HabitsStore(url: .temporaryDirectory.appending(path: "AvoidHabitWidgetTests-\(UUID().uuidString).json"))

    private func habit(_ title: String, limit: Int? = nil, times: Int = 0) -> Habit {
        var habit = Habit(title: title, symbol: "book", limit: limit, createdOn: today - 5)
        habit.log[today] = times
        return habit
    }

    private func progress(_ habits: [Habit]) -> [Habit.ID: HabitProgress] {
        Dictionary(uniqueKeysWithValues: habits.map { ($0.id, HabitProgress(of: $0, today: today, firstWeekday: 2)) })
    }

    @Test func theGridShowsAvoidedHabits() {
        let habits = [habit("Caffè", limit: 2), habit("Leggere")]

        #expect(WidgetChoice.grid(habits, chosen: [], today: today, firstWeekday: 2).map(\.title) == ["Caffè", "Leggere"])
    }

    @Test(arguments: [
        (nil as Int?, 0, true), // to do, not done
        (nil, 1, false), // done
        (2, 1, false), // within the Limite: nothing to do
        (2, 3, false), // over the Limite: missed, nothing left to do either
    ])
    func onlyHabitsToDoAreStillToDo(limit: Int?, times: Int, isStillToDo: Bool) {
        #expect(HabitProgress(of: habit("A", limit: limit, times: times), today: today, firstWeekday: 2).isStillToDo == isStillToDo)
    }

    @Test func avoidedHabitsComeAfterTheOnesStillToDo() {
        let habits = [habit("Caffè", limit: 2, times: 1), habit("Fumare", limit: 0, times: 1), habit("Letto", times: 1), habit("Leggere")]

        let slots = WidgetSlots(habits, progress: progress(habits), capacity: 8)

        // The rest keeps the grid's order.
        #expect(slots.shown.map(\.title) == ["Leggere", "Caffè", "Fumare", "Letto"])
    }

    @Test func theSingleWidgetPrefersAHabitToDo() {
        let habits = [habit("Caffè", limit: 2), habit("Leggere")]

        #expect(WidgetChoice.single(habits, chosen: nil, today: today, firstWeekday: 2)?.title == "Leggere")
    }

    @Test func withOnlyAvoidedHabitsTheSingleWidgetShowsTheFirst() {
        let habits = [habit("Caffè", limit: 2, times: 3), habit("Fumare", limit: 0)]

        #expect(WidgetChoice.single(habits, chosen: nil, today: today, firstWeekday: 2)?.title == "Caffè")
    }

    @Test func anAvoidedHabitCanBeChosen() {
        let habits = [habit("Leggere"), habit("Caffè", limit: 2)]

        #expect(WidgetChoice.single(habits, chosen: habits[1].id, today: today, firstWeekday: 2)?.title == "Caffè")
    }

    @Test func aTapCountsPastTheLimiteInTheSharedFile() throws {
        let model = HabitsModel(store: store, scheduleReminders: { _ in })
        model.add(title: "Caffè", symbol: "cup.and.saucer", limit: 1)
        let id = model.habits[0].id.uuidString

        _ = try MarkHabitIntent.mark(id, in: store, now: .now)
        let file = try MarkHabitIntent.mark(id, in: store, now: .now)

        #expect(file.habits[0].count(on: model.today) == 2)
        model.reload()
        #expect(model.progress(of: model.habits[0]).isOverLimit)
    }
}
