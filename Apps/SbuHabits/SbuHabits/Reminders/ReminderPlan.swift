import Foundation

/// Which reminders to schedule: only on days a habit is expected, never for a habit already
/// done or skipped today, soonest first, within the limit iOS keeps pending. A running countdown
/// comes first, at its end, and takes one place of the limit. Orari automatici are read again
/// from the marks every time the plan is made, so they follow the habit as it moves.
nonisolated enum ReminderPlan {
    /// iOS keeps at most 64 pending local notifications per app.
    static let limit = 64
    /// Days ahead to plan, within `limit`. The app plans again on every change and when it comes
    /// back, and the widget on every timeline, so reminders keep coming without opening the app.
    static let days = 30

    /// The id of the notification at the end of the countdown: one timer at a time, so one id.
    static let timerID = "timer"

    /// - Parameter timer: The countdown saved, if any; only a running one, still ahead, is planned.
    ///   Its end is always Time Sensitive: the user started it and waits for it. It plays its
    ///   habit's sound.
    static func reminders(for habits: [Habit], timer: HabitTimer? = nil, now: Date, startHour: Int, calendar: Calendar) -> [PlannedReminder] {
        var timerEnd: [PlannedReminder] = []
        if let timer, let end = timer.endDate, end > now {
            let sound = habits.first { $0.id == timer.habitID }?.notificationStyle.sound ?? .standard
            timerEnd = [PlannedReminder(id: timerID, habitID: timer.habitID, title: timer.title, date: end, endsTimer: true, isTimeSensitive: true, sound: sound)]
        }
        let today = LogicalDay(now, startHour: startHour, calendar: calendar)
        var planned: [PlannedReminder] = []
        for habit in habits {
            let times = habit.reminderTimes(through: today, startHour: startHour)
            guard times.isEmpty == false else { continue }
            let style = habit.notificationStyle
            for offset in 0..<days {
                let day = today + offset
                guard isExpected(habit, on: day, today: today, calendar: calendar) else { continue }
                for time in times {
                    let date = moment(of: time, on: day, startHour: startHour, calendar: calendar)
                    guard date > now else { continue }
                    planned.append(PlannedReminder(id: "\(habit.id)-\(day.ordinal)-\(time.hour)-\(time.minute)", habitID: habit.id, title: habit.title, date: date, isTimeSensitive: style.isTimeSensitive, sound: style.sound))
                }
            }
        }
        // Equal dates keep the habits' order, so the same plan always keeps the same 64.
        return timerEnd + planned.enumerated().sorted { ($0.element.date, $0.offset) < ($1.element.date, $1.offset) }.map(\.element).prefix(limit - timerEnd.count)
    }

    private static func isExpected(_ habit: Habit, on day: LogicalDay, today: LogicalDay, calendar: Calendar) -> Bool {
        guard day >= habit.createdOn, habit.isSkipped(on: day) == false, habit.isDone(on: day) == false else { return false }
        guard let period = habit.schedule.period else { return habit.schedule.includes(day) }
        // Any day can be one of the week's or month's days. This one, only until the goal is reached.
        let firstWeekday = calendar.firstWeekday
        let isThisPeriod = period.start(of: day, firstWeekday: firstWeekday) == period.start(of: today, firstWeekday: firstWeekday)
        return isThisPeriod == false || HabitProgress(of: habit, today: today, firstWeekday: firstWeekday).isComplete == false
    }

    /// The moment `time` falls on in `day`: an hour before the start of the day belongs to the
    /// next calendar morning.
    private static func moment(of time: ReminderTime, on day: LogicalDay, startHour: Int, calendar: Calendar) -> Date {
        let noon = day.noon(in: calendar)
        let date = calendar.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: noon) ?? noon
        return time.hour < startHour ? calendar.date(byAdding: .day, value: 1, to: date) ?? date : date
    }
}
