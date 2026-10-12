import Foundation
import Observation
import WidgetKit

/// The habits on this iPhone: today's grid, the Serie piena, and the actions that change them.
@Observable
final class HabitsModel {
    private(set) var habits: [Habit] = []
    /// Today's logical day; `reload()` moves it forward.
    private(set) var today: LogicalDay
    /// Hour the day starts, from Impostazioni.
    private(set) var startHour = 0
    /// The saved file could not be read: nothing is written, so it is never lost.
    private(set) var isUnreadable = false

    @ObservationIgnored private let store: HabitsStore
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let scheduleReminders: @MainActor ([PlannedReminder]) -> Void

    var fullStreak: Int { Streak.full(of: habits, today: today) }

    var firstWeekday: Int { calendar.firstWeekday }

    /// The habits expected today, in the grid's order.
    var todayHabits: [Habit] { TodayGrid.habits(habits, on: today, firstWeekday: calendar.firstWeekday) }

    /// - Parameter scheduleReminders: Receives the full reminder plan after every change; tests pass their own.
    init(
        store: HabitsStore = .shared,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current,
        scheduleReminders: @escaping @MainActor ([PlannedReminder]) -> Void = ReminderScheduler.replace
    ) {
        self.store = store
        self.now = now
        self.calendar = calendar
        self.scheduleReminders = scheduleReminders
        today = LogicalDay(now(), calendar: calendar)
        reload()
    }

    func streak(of habit: Habit) -> Int {
        Streak.current(of: habit, today: today, firstWeekday: calendar.firstWeekday)
    }

    func progress(of habit: Habit) -> HabitProgress {
        HabitProgress(of: habit, today: today, firstWeekday: calendar.firstWeekday)
    }

    /// The moment the next logical day starts, when the grid has to move on.
    var nextDayStart: Date {
        let noon = (today + 1).noon(in: calendar)
        return calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: noon) ?? noon
    }

    /// Reads the file again and recomputes today, for when the app comes back to the foreground
    /// or a new day starts.
    func reload() {
        do {
            let file = try store.load()
            habits = file.habits
            startHour = file.startHour
            isUnreadable = false
        } catch {
            habits = []
            isUnreadable = true
        }
        today = LogicalDay(now(), startHour: startHour, calendar: calendar)
        planReminders()
    }

    /// Moves the start of the day, for people who live past midnight.
    func setStartHour(_ hour: Int) {
        startHour = Habit.clamp(hour, to: HabitsFile.startHourRange)
        today = LogicalDay(now(), startHour: startHour, calendar: calendar)
        save()
    }

    func add(title: String, symbol: String, timesPerDay: Int = 1, schedule: Schedule = .everyDay, reminders: [ReminderTime] = []) {
        var habit = Habit(title: "", symbol: symbol, createdOn: today)
        guard habit.update(title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule, reminders: reminders, from: today) else { return }
        habits.append(habit)
        save()
    }

    func edit(_ habit: Habit, title: String, symbol: String, timesPerDay: Int, schedule: Schedule, reminders: [ReminderTime] = []) {
        update(habit) { _ = $0.update(title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule, reminders: reminders, from: today) }
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
        // The app may have stayed open past the start of the day: marks go on the real today.
        today = LogicalDay(now(), startHour: startHour, calendar: calendar)
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        change(&habits[index])
        save()
    }

    private func save() {
        guard isUnreadable == false else { return }
        // ponytail: a failed write keeps the change in memory only; add an alert if it shows up in practice.
        try? store.save(HabitsFile(habits: habits, startHour: startHour))
        WidgetCenter.shared.reloadAllTimelines()
        planReminders()
    }

    /// Plans every reminder again: marking a habit done drops today's.
    private func planReminders() {
        scheduleReminders(ReminderPlan.reminders(for: habits, now: now(), startHour: startHour, calendar: calendar))
    }
}
