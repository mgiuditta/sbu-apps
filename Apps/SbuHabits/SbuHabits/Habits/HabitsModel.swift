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
    @ObservationIgnored private let health: any HealthReading

    var fullStreak: Int { Streak.full(of: habits, today: today) }

    var firstWeekday: Int { calendar.firstWeekday }

    /// The habits expected today, in the grid's order.
    var todayHabits: [Habit] { TodayGrid.habits(habits, on: today, firstWeekday: calendar.firstWeekday) }

    /// Whether the form can offer Collega a Salute.
    var isHealthAvailable: Bool { health.isAvailable }

    /// The measures some habit to do is linked to.
    var linkedMeasures: Set<HealthMeasure> {
        Set(habits.compactMap { $0.limit == nil ? $0.health?.measure : nil })
    }

    /// - Parameters:
    ///   - scheduleReminders: Receives the full reminder plan after every change; tests pass their own.
    ///   - health: Where linked habits read their totals; tests pass a fake.
    init(
        store: HabitsStore = .shared,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current,
        scheduleReminders: @escaping @MainActor ([PlannedReminder]) -> Void = ReminderScheduler.replace,
        health: any HealthReading = HealthKitReader()
    ) {
        self.store = store
        self.now = now
        self.calendar = calendar
        self.scheduleReminders = scheduleReminders
        self.health = health
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

    /// - Parameters:
    ///   - limit: The Limite of an Abitudine da evitare, `nil` for a habit to do.
    ///   - health: The Salute measure and goal that mark it done; call `connectHealth(_:)` after.
    func add(title: String, symbol: String, timesPerDay: Int = 1, schedule: Schedule = .everyDay, limit: Int? = nil, reminders: [ReminderTime] = [], health: HealthLink? = nil) {
        var habit = Habit(title: "", symbol: symbol, limit: limit, createdOn: today)
        guard habit.update(title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule, limit: limit, reminders: reminders, health: health, from: today) else { return }
        habits.append(habit)
        save()
    }

    func edit(_ habit: Habit, title: String, symbol: String, timesPerDay: Int, schedule: Schedule, limit: Int? = nil, reminders: [ReminderTime] = [], health: HealthLink? = nil) {
        update(habit) { _ = $0.update(title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule, limit: limit, reminders: reminders, health: health, from: today) }
    }

    /// Asks to read `measure` from Salute, the first time a habit is linked to it, then marks
    /// what today's data already reaches.
    func connectHealth(_ measure: HealthMeasure) async {
        await health.requestAccess(toRead: [measure])
        await refreshFromHealth()
    }

    /// Reads the file again, then today's totals from Salute, and marks the linked habits whose
    /// goal is reached. Today is the logical day: with a start at 4, steps at 02:00 count for the
    /// day before.
    func refreshFromHealth() async {
        reload()
        let measures = linkedMeasures
        guard isUnreadable == false, measures.isEmpty == false else { return }
        let day = today
        let interval = day.interval(startHour: startHour, in: calendar)
        var totals: [HealthMeasure: Double] = [:]
        for measure in measures {
            // A measure that cannot be read leaves its habits to be marked by hand.
            totals[measure] = try? await health.total(of: measure, in: interval)
        }
        // The habits may have changed while Salute answered: mark the ones there are now.
        if HealthMarking.mark(&habits, totals: totals, on: day) {
            save()
        }
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

    /// Adds one time today; a habit already done today stays as it is. For an Abitudine da
    /// evitare, one more time given in.
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
