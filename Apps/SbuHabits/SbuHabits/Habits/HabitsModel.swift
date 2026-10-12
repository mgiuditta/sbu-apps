import Foundation
import Observation

/// The habits on this iPhone: today's grid, the Serie piena, and the actions that change them.
@Observable
final class HabitsModel {
    private(set) var habits: [Habit] = []
    /// Today's logical day; `reload()` moves it forward.
    private(set) var today: LogicalDay
    /// Hour the day starts, from Impostazioni.
    private(set) var startHour = 0

    @ObservationIgnored private let store: HabitsStore
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let calendar: Calendar

    var fullStreak: Int { Streak.full(of: habits, today: today) }

    var firstWeekday: Int { calendar.firstWeekday }

    /// The habits expected today, in the grid's order.
    var todayHabits: [Habit] { TodayGrid.habits(habits, on: today, firstWeekday: calendar.firstWeekday) }

    init(store: HabitsStore = .shared, now: @escaping () -> Date = Date.init, calendar: Calendar = .current) {
        self.store = store
        self.now = now
        self.calendar = calendar
        today = LogicalDay(now(), calendar: calendar)
        reload()
    }

    func streak(of habit: Habit) -> Int {
        Streak.current(of: habit, today: today, firstWeekday: calendar.firstWeekday)
    }

    func progress(of habit: Habit) -> HabitProgress {
        HabitProgress(of: habit, today: today, firstWeekday: calendar.firstWeekday)
    }

    /// Reads the file again and recomputes today, for when the app comes back to the foreground.
    func reload() {
        // ponytail: an unreadable file shows as no habits; save() still refuses to overwrite a newer version.
        let file = (try? store.load()) ?? HabitsFile()
        habits = file.habits
        startHour = file.startHour
        today = LogicalDay(now(), startHour: startHour, calendar: calendar)
    }

    /// Moves the start of the day, for people who live past midnight.
    func setStartHour(_ hour: Int) {
        startHour = min(max(hour, HabitsFile.startHourRange.lowerBound), HabitsFile.startHourRange.upperBound)
        today = LogicalDay(now(), startHour: startHour, calendar: calendar)
        save()
    }

    func add(title: String, symbol: String, timesPerDay: Int = 1, schedule: Schedule = .everyDay) {
        var habit = Habit(title: "", symbol: symbol, createdOn: today)
        guard habit.update(title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule) else { return }
        habits.append(habit)
        save()
    }

    func edit(_ habit: Habit, title: String, symbol: String, timesPerDay: Int, schedule: Schedule) {
        update(habit) { _ = $0.update(title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule) }
    }

    /// Moves habits in the Statistiche list; the grid follows the same order.
    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        let moving = source.map { habits[$0] }
        var rest = habits.indices.filter { source.contains($0) == false }.map { habits[$0] }
        rest.insert(contentsOf: moving, at: destination - source.count { $0 < destination })
        habits = rest
        save()
    }

    func bestStreak(of habit: Habit) -> Int {
        Streak.best(of: habit, today: today, firstWeekday: calendar.firstWeekday)
    }

    /// Removes the habit and its whole log.
    func delete(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        save()
    }

    /// Adds one time today; a habit already done today stays as it is.
    func markDone(_ habit: Habit) {
        update(habit) { $0.mark(on: today) }
    }

    /// Takes back today's last mark.
    func undoLast(_ habit: Habit) {
        update(habit) { $0.undoLast(on: today) }
    }

    /// Skips today, or takes the skip back.
    func toggleSkip(_ habit: Habit) {
        update(habit) { $0.toggleSkip(on: today) }
    }

    private func update(_ habit: Habit, _ change: (inout Habit) -> Void) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        change(&habits[index])
        save()
    }

    private func save() {
        // ponytail: a failed write keeps the change in memory only; add an alert if it shows up in practice.
        try? store.save(HabitsFile(habits: habits, startHour: startHour))
    }
}
