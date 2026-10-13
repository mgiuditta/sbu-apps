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
    /// The countdown of an Abitudine a tempo, while one runs or is paused: one at a time.
    private(set) var timer: HabitTimer?
    /// Countdowns that ran to their end with the app open, for the success haptic.
    private(set) var timersEnded = 0
    /// Habits deleted and when, so Sincronizza con iCloud never brings them back.
    private(set) var deleted: [UUID: Date] = [:]
    /// When the order and the start of the day last changed, for Sincronizza con iCloud.
    private(set) var orderModifiedAt: Date?
    private(set) var startHourModifiedAt: Date?

    /// Called after every change this iPhone saves, so Sincronizza con iCloud can send it.
    @ObservationIgnored var didSave: (@MainActor () -> Void)?
    /// Called after every change this iPhone saves, so the Abitudini condivise can send it.
    @ObservationIgnored var didSaveForSharing: (@MainActor () -> Void)?

    @ObservationIgnored private let store: HabitsStore
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let scheduleReminders: @MainActor ([PlannedReminder]) -> Void
    @ObservationIgnored private let health: any HealthReading
    @ObservationIgnored private let timerStore: HabitTimerStore
    @ObservationIgnored private let announceHealthMarks: @MainActor ([Habit]) -> Void
    @ObservationIgnored private let followTimer: @MainActor (TimerActivityUpdate) -> Void
    /// The measures Salute is followed for, `nil` until `observeHealth()`.
    @ObservationIgnored private var observedMeasures: Set<HealthMeasure>?

    var fullStreak: Int { Streak.full(of: habits, today: today) }

    /// Everything saved, as Esporta writes it.
    var file: HabitsFile {
        HabitsFile(habits: habits, startHour: startHour, deleted: deleted, orderModifiedAt: orderModifiedAt, startHourModifiedAt: startHourModifiedAt)
    }

    var firstWeekday: Int { calendar.firstWeekday }

    /// The habits expected today, in the grid's order.
    var todayHabits: [Habit] { TodayGrid.habits(habits, on: today, firstWeekday: calendar.firstWeekday) }

    /// Today's grid in pages of six, with Aggiungi last while a habit can still be added.
    var homePages: HomePages {
        homePages(shared: [])
    }

    /// Today's grid with the Abitudini condivise received after the user's own habits.
    func homePages(shared: [ReceivedHabit]) -> HomePages {
        HomePages(todayHabits: todayHabits, habitCount: habits.count, isAddEnabled: isUnreadable == false, shared: shared)
    }

    /// Below the limit of `HomePages.habitLimit` habits, and the file is readable.
    var canAdd: Bool {
        isUnreadable == false && habits.count < HomePages.habitLimit
    }

    /// Whether the form can offer Collega a Salute.
    var isHealthAvailable: Bool { health.isAvailable }

    /// The measures some habit to do is linked to.
    var linkedMeasures: Set<HealthMeasure> {
        Set(habits.compactMap { $0.limit == nil ? $0.health?.measure : nil })
    }

    /// - Parameters:
    ///   - scheduleReminders: Receives the full reminder plan after every change; tests pass their own.
    ///   - health: Where linked habits read their totals; tests pass a fake.
    ///   - timerStore: Where the running countdown is kept; tests pass their own.
    ///   - announceHealthMarks: Receives the habits Salute just marked done that ask to say so.
    ///   - followTimer: Receives every change of the countdown, for its Live Activity.
    init(
        store: HabitsStore = .shared,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current,
        scheduleReminders: @escaping @MainActor ([PlannedReminder]) -> Void = ReminderScheduler.replace,
        health: any HealthReading = HealthKitReader(),
        timerStore: HabitTimerStore = .shared,
        announceHealthMarks: @escaping @MainActor ([Habit]) -> Void = ReminderScheduler.announceHealthMarks,
        followTimer: @escaping @MainActor (TimerActivityUpdate) -> Void = TimerActivity.apply
    ) {
        self.store = store
        self.now = now
        self.calendar = calendar
        self.scheduleReminders = scheduleReminders
        self.health = health
        self.timerStore = timerStore
        self.announceHealthMarks = announceHealthMarks
        self.followTimer = followTimer
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
    /// or a new day starts. A countdown that ended meanwhile marks its habit done.
    func reload() {
        do {
            show(try store.load())
            isUnreadable = false
        } catch {
            habits = []
            isUnreadable = true
        }
        today = LogicalDay(now(), startHour: startHour, calendar: calendar)
        timer = timerStore.load()
        if let timer, timer.isFinished(at: now()) {
            finish(timer)
        } else {
            // At launch too: the Live Activity left from before follows the saved countdown, or goes.
            followTimer(timer.map { .follow($0) } ?? .end(isDone: false))
            planReminders()
        }
    }

    /// Replaces every habit, its history and the start of the day with an imported file, then
    /// plans the reminders and refreshes the widgets.
    /// - Throws: When the file cannot be written; nothing changes then, on disk or here.
    /// With Sincronizza con iCloud the import wins on every iPhone: the habits it lacks count as
    /// deleted now, and its habits, order and start of the day as edited now.
    func replace(with file: HabitsFile) throws {
        let date = now()
        var replacement = file
        replacement.startHour = Habit.clamp(file.startHour, to: HabitsFile.startHourRange)
        for index in replacement.habits.indices {
            replacement.habits[index].modifiedAt = date
        }
        let kept = Set(replacement.habits.map(\.id))
        for habit in habits where kept.contains(habit.id) == false {
            replacement.deleted[habit.id] = date
        }
        replacement.orderModifiedAt = date
        replacement.startHourModifiedAt = date
        replacement.forgetOldDeletions(now: date)
        try store.save(replacement)
        show(replacement)
        isUnreadable = false
        dropTimerOfDeletedHabit()
        didChange()
        didSave?()
        didSaveForSharing?()
    }

    /// Takes the habits as Sincronizza con iCloud merged them: saves them for the widget, then
    /// plans the reminders and refreshes the widgets. Never called while the file is unreadable.
    func applySynced(_ file: HabitsFile) {
        guard isUnreadable == false else { return }
        // ponytail: a failed write keeps the merge in memory only; the next sync merges again.
        try? store.save(file)
        show(file)
        dropTimerOfDeletedHabit()
        didChange()
    }

    private func show(_ file: HabitsFile) {
        habits = file.habits
        startHour = file.startHour
        deleted = file.deleted
        orderModifiedAt = file.orderModifiedAt
        startHourModifiedAt = file.startHourModifiedAt
        today = LogicalDay(now(), startHour: startHour, calendar: calendar)
    }

    /// A countdown whose habit another iPhone deleted.
    private func dropTimerOfDeletedHabit() {
        if let timer, habits.contains(where: { $0.id == timer.habitID }) == false {
            setTimer(nil, .end(isDone: false))
        }
    }

    /// Moves the start of the day, for people who live past midnight.
    func setStartHour(_ hour: Int) {
        startHour = Habit.clamp(hour, to: HabitsFile.startHourRange)
        startHourModifiedAt = now()
        today = LogicalDay(now(), startHour: startHour, calendar: calendar)
        save()
    }

    /// - Parameters:
    ///   - limit: The Limite of an Abitudine da evitare, `nil` for a habit to do.
    ///   - health: The Salute measure and goal that mark it done; call `connectHealth(_:)` after.
    ///   - timerMinutes: The countdown of an Abitudine a tempo, `nil` for one that is not timed.
    /// Past `HomePages.habitLimit` habits nothing is added.
    func add(title: String, symbol: String, timesPerDay: Int = 1, schedule: Schedule = .everyDay, limit: Int? = nil, reminders: [ReminderTime] = [], remindsAutomatically: Bool = false, notificationStyle: NotificationStyle = NotificationStyle(), health: HealthLink? = nil, timerMinutes: Int? = nil) {
        guard habits.count < HomePages.habitLimit else { return }
        var habit = Habit(title: "", symbol: symbol, limit: limit, createdOn: today)
        guard habit.update(title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule, limit: limit, reminders: reminders, remindsAutomatically: remindsAutomatically, notificationStyle: notificationStyle, health: health, timerMinutes: timerMinutes, from: today) else { return }
        habit.modifiedAt = now()
        habits.append(habit)
        save()
    }

    func edit(_ habit: Habit, title: String, symbol: String, timesPerDay: Int, schedule: Schedule, limit: Int? = nil, reminders: [ReminderTime] = [], remindsAutomatically: Bool = false, notificationStyle: NotificationStyle = NotificationStyle(), health: HealthLink? = nil, timerMinutes: Int? = nil) {
        let date = now()
        update(habit) { habit in
            if habit.update(title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule, limit: limit, reminders: reminders, remindsAutomatically: remindsAutomatically, notificationStyle: notificationStyle, health: health, timerMinutes: timerMinutes, from: today) {
                habit.modifiedAt = date
            }
        }
    }

    /// Asks to read `measure` from Salute, the first time a habit is linked to it, then marks
    /// what today's data already reaches.
    func connectHealth(_ measure: HealthMeasure) async {
        await health.requestAccess(toRead: [measure])
        await refreshFromHealth()
    }

    /// Follows the linked measures in Salute, in the background too, and marks habits whenever
    /// new data comes; with no habit linked, nothing runs in the background. Called at launch, the
    /// background ones included, then again whenever the linked measures change.
    func observeHealth() {
        let measures = linkedMeasures
        observedMeasures = measures
        health.observe(measures) { [weak self] in
            await self?.refreshFromHealth()
        }
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
        let before = habits
        if HealthMarking.mark(&habits, totals: totals, on: day, hour: calendar.component(.hour, from: now())) {
            save()
            let marked = habits.filter { habit in
                habit.notificationStyle.announcesHealthMark && habit.isDone(on: day)
                    && before.first { $0.id == habit.id }?.isDone(on: day) == false
            }
            if marked.isEmpty == false {
                announceHealthMarks(marked)
            }
        }
    }

    /// Moves habits in Ordine delle abitudini; the grid and the Statistiche follow the same order.
    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        let moving = source.map { habits[$0] }
        var rest = habits.indices.filter { source.contains($0) == false }.map { habits[$0] }
        rest.insert(contentsOf: moving, at: destination - source.count { $0 < destination })
        habits = rest
        orderModifiedAt = now()
        save()
    }

    func bestStreak(of habit: Habit) -> Int {
        Streak.best(of: habit, today: today, firstWeekday: calendar.firstWeekday)
    }

    /// Removes the habit with its whole log and its notes, and its countdown.
    func delete(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        // Remembered a year, so Sincronizza con iCloud never brings it back.
        deleted[habit.id] = now()
        var file = file
        file.forgetOldDeletions(now: now())
        deleted = file.deleted
        if timer?.habitID == habit.id {
            setTimer(nil, .end(isDone: false))
        }
        save()
    }

    // MARK: - Timer

    /// Starts the countdown of an Abitudine a tempo, for today. It replaces any other countdown:
    /// one at a time.
    func startTimer(for habit: Habit) {
        today = LogicalDay(now(), startHour: startHour, calendar: calendar)
        guard let started = HabitTimer(habit: habit, day: today, now: now()) else { return }
        setTimer(started, .start(started, symbol: habit.symbol))
        planReminders()
    }

    /// Pauses a running countdown, or resumes a paused one; the notification at the end follows.
    func toggleTimerPause() {
        guard var timer else { return }
        if timer.isRunning {
            timer.pause(at: now())
        } else {
            timer.resume(at: now())
        }
        setTimer(timer, .follow(timer))
        planReminders()
    }

    /// Throws the countdown away, leaving the habit as it is.
    func cancelTimer() {
        setTimer(nil, .end(isDone: false))
        planReminders()
    }

    /// Ends the countdown now and marks its habit done, as Segna come fatta does.
    func markTimerDone() {
        guard let timer else { return }
        finish(timer, at: now())
    }

    /// Marks the habit done if the countdown has run to its end, as it does on screen. Returns
    /// whether it ended.
    @discardableResult
    func finishTimerIfEnded() -> Bool {
        guard let timer, timer.isFinished(at: now()) else { return false }
        finish(timer)
        timersEnded += 1
        return true
    }

    /// Marks the timer's habit done on the day it was started, with the hour it ended at (by
    /// default its end date), then forgets the timer.
    private func finish(_ timer: HabitTimer, at end: Date? = nil) {
        setTimer(nil, .end(isDone: true))
        let hour = calendar.component(.hour, from: end ?? timer.endDate ?? now())
        if let index = habits.firstIndex(where: { $0.id == timer.habitID }) {
            habits[index].mark(on: timer.day, hour: hour)
        }
        save()
    }

    /// Keeps `timer` and saves it, and tells its Live Activity with `update`.
    private func setTimer(_ timer: HabitTimer?, _ update: TimerActivityUpdate) {
        self.timer = timer
        timerStore.save(timer)
        followTimer(update)
    }

    /// Adds one time today; a habit already done today stays as it is. For an Abitudine da
    /// evitare, one more time given in.
    func markDone(_ habit: Habit) {
        let hour = calendar.component(.hour, from: now())
        update(habit) { $0.mark(on: today, hour: hour) }
    }

    /// Takes back today's last mark.
    func undoLast(_ habit: Habit) {
        update(habit) { $0.undoLast(on: today) }
    }

    /// Skips today, or takes the skip back.
    func toggleSkip(_ habit: Habit) {
        update(habit) { $0.toggleSkip(on: today) }
    }

    /// Writes the Nota del giorno of `day`, today or a day gone by; a blank text removes it.
    func setNote(_ text: String, for habit: Habit, on day: LogicalDay) {
        let date = now()
        update(habit) { habit in
            // Never a day still to come: the editor opens only on today and the past.
            guard day <= today else { return }
            habit.setNote(text, on: day, at: date)
        }
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
        try? store.save(file)
        didChange()
        didSave?()
        didSaveForSharing?()
    }

    /// After every change, saved here or merged from iCloud: the widgets, the reminders, and
    /// Salute for the measures linked now.
    private func didChange() {
        WidgetCenter.shared.reloadAllTimelines()
        planReminders()
        if let observedMeasures, observedMeasures != linkedMeasures {
            observeHealth()
        }
    }

    /// Plans every reminder again: marking a habit done drops today's.
    private func planReminders() {
        scheduleReminders(ReminderPlan.reminders(for: habits, timer: timer, now: now(), startHour: startHour, calendar: calendar))
    }
}
