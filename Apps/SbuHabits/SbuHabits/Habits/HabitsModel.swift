import Foundation
import Observation

/// The habits on this iPhone: today's grid, the Serie piena, and the actions that change them.
@Observable
final class HabitsModel {
    private(set) var habits: [Habit] = []
    /// Today's logical day; `reload()` moves it forward.
    private(set) var today: LogicalDay

    @ObservationIgnored private let store: HabitsStore
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let calendar: Calendar

    var fullStreak: Int { Streak.full(of: habits, today: today) }

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
        today = LogicalDay(now(), calendar: calendar)
        // ponytail: an unreadable file shows as no habits; save() still refuses to overwrite a newer version.
        habits = (try? store.load().habits) ?? []
    }

    func add(title: String, symbol: String, timesPerDay: Int = 1, schedule: Schedule = .everyDay) {
        let title = String(title.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Habit.maxTitleLength))
        guard title.isEmpty == false else { return }
        var schedule = schedule
        switch schedule {
        case .weekdays(let weekdays) where weekdays.isEmpty: return
        case .timesPerWeek(let times): schedule = .timesPerWeek(Self.clamp(times, to: Schedule.timesPerWeekRange))
        default: break
        }
        // A weekly habit counts days, so it is done once a day.
        let times = schedule.isWeekly ? 1 : Self.clamp(timesPerDay, to: Habit.timesPerDayRange)
        habits.append(Habit(title: title, symbol: symbol, timesPerDay: times, schedule: schedule, createdOn: today))
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

    private static func clamp(_ value: Int, to range: ClosedRange<Int>) -> Int {
        min(max(value, range.lowerBound), range.upperBound)
    }

    private func update(_ habit: Habit, _ change: (inout Habit) -> Void) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        change(&habits[index])
        save()
    }

    private func save() {
        // ponytail: a failed write keeps the change in memory only; add an alert if it shows up in practice.
        try? store.save(HabitsFile(habits: habits))
    }
}
