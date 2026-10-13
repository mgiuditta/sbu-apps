import Foundation

/// Today's grid as the iPhone sends it to the Apple Watch: the habits expected today, with only
/// the days of this week and month that their rings need, and the Serie piena up to yesterday.
///
/// The watch counts today itself, so a tap shows at once, before the iPhone answers. Notes and
/// the history before this month never leave the iPhone.
nonisolated struct WatchSnapshot: Codable, Equatable, Sendable {
    let today: LogicalDay
    let startHour: Int
    let firstWeekday: Int
    /// When the next logical day starts: past it the grid is yesterday's.
    let nextDayStart: Date
    /// The Serie piena up to yesterday, from the whole history on the iPhone.
    let fullStreakBeforeToday: Int
    /// Each habit's Serie, from the whole history on the iPhone, for VoiceOver.
    let streaks: [UUID: Int]
    /// Today's grid, in its order.
    private(set) var habits: [Habit]
    /// The watch actions the iPhone has applied, newest last.
    let applied: [UUID]

    /// - Parameters:
    ///   - habits: Every habit on the iPhone, with its whole history.
    ///   - applied: The `WatchAction`s already saved, so the watch stops showing them as pending.
    init(habits: [Habit], today: LogicalDay, startHour: Int, firstWeekday: Int, nextDayStart: Date, applied: [UUID]) {
        self.today = today
        self.startHour = startHour
        self.firstWeekday = firstWeekday
        self.nextDayStart = nextDayStart
        self.applied = applied
        fullStreakBeforeToday = Streak.fullBeforeToday(of: habits, today: today)
        let grid = TodayGrid.habits(habits, on: today, firstWeekday: firstWeekday)
        streaks = Dictionary(uniqueKeysWithValues: grid.map { ($0.id, Streak.current(of: $0, today: today, firstWeekday: firstWeekday)) })
        // A weekly ring counts this week, a monthly one this month: older days stay on the iPhone.
        let first = min(today.monthStart, today.weekStart(firstWeekday: firstWeekday))
        self.habits = grid.map { Self.trimmed($0, from: first, through: today) }
    }

    /// Days in a row on which every habit expected was done, today included as the watch sees it.
    var fullStreak: Int {
        Streak.full(of: habits, today: today, before: fullStreakBeforeToday)
    }

    func progress(of habit: Habit) -> HabitProgress {
        HabitProgress(of: habit, today: today, firstWeekday: firstWeekday)
    }

    /// Whether `date` still falls in the snapshot's day.
    func isCurrent(at date: Date) -> Bool {
        date < nextDayStart
    }

    /// The grid with a tap on the watch already counted, as the iPhone will count it.
    func applying(_ action: WatchAction) -> WatchSnapshot {
        var copy = self
        _ = WatchMarking.apply(action, to: &copy.habits, today: today)
        return copy
    }

    /// The habit with its settings and only the days from `first` to `last`.
    private static func trimmed(_ habit: Habit, from first: LogicalDay, through last: LogicalDay) -> Habit {
        var copy = habit.settingsOnly
        var day = first
        while day <= last {
            copy.setDay(count: habit.count(on: day), hours: habit.markHours[day] ?? [], isSkipped: habit.isSkipped(on: day), on: day)
            day = day + 1
        }
        return copy
    }
}
