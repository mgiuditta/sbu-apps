import Foundation

/// Which reminders to schedule: only on days a habit is expected, never for a habit already
/// done or skipped today, soonest first, within the limit iOS keeps pending. A running countdown
/// comes first, at its end, and takes one place of the limit.
nonisolated enum ReminderPlan {
    /// iOS keeps at most 64 pending local notifications per app.
    static let limit = 64
    /// Days ahead to plan, within `limit`. The app plans again on every change and when it comes
    /// back, and the widget on every timeline, so reminders keep coming without opening the app.
    static let days = 30

    /// The id of the notification at the end of the countdown: one timer at a time, so one id.
    static let timerID = "timer"

    /// - Parameter timer: The countdown saved, if any; only a running one, still ahead, is planned.
    static func reminders(for habits: [Habit], timer: HabitTimer? = nil, now: Date, startHour: Int, calendar: Calendar) -> [PlannedReminder] {
        var timerEnd: [PlannedReminder] = []
        if let timer, let end = timer.endDate, end > now {
            timerEnd = [PlannedReminder(id: timerID, habitID: timer.habitID, title: timer.title, date: end, endsTimer: true)]
        }
        let today = LogicalDay(now, startHour: startHour, calendar: calendar)
        var planned: [PlannedReminder] = []
        for offset in 0..<days {
            let day = today + offset
            for habit in habits where habit.reminders.isEmpty == false && isExpected(habit, on: day, today: today, calendar: calendar) {
                for time in habit.reminders {
                    let date = moment(of: time, on: day, startHour: startHour, calendar: calendar)
                    guard date > now else { continue }
                    planned.append(PlannedReminder(id: "\(habit.id)-\(day.ordinal)-\(time.hour)-\(time.minute)", habitID: habit.id, title: habit.title, date: date))
                }
            }
        }
        return timerEnd + planned.sorted { $0.date < $1.date }.prefix(limit - timerEnd.count)
    }

    private static func isExpected(_ habit: Habit, on day: LogicalDay, today: LogicalDay, calendar: Calendar) -> Bool {
        guard day >= habit.createdOn, habit.isSkipped(on: day) == false, habit.isDone(on: day) == false else { return false }
        guard habit.schedule.isWeekly else { return habit.schedule.includes(day) }
        // Any day can be one of the week's days. This week, only until the goal is reached.
        let firstWeekday = calendar.firstWeekday
        let isThisWeek = day.weekStart(firstWeekday: firstWeekday) == today.weekStart(firstWeekday: firstWeekday)
        return isThisWeek == false || HabitProgress(of: habit, today: today, firstWeekday: firstWeekday).isComplete == false
    }

    /// The moment `time` falls on in `day`: an hour before the start of the day belongs to the
    /// next calendar morning.
    private static func moment(of time: ReminderTime, on day: LogicalDay, startHour: Int, calendar: Calendar) -> Date {
        let noon = day.noon(in: calendar)
        let date = calendar.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: noon) ?? noon
        return time.hour < startHour ? calendar.date(byAdding: .day, value: 1, to: date) ?? date : date
    }
}
