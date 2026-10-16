import Foundation

/// Which reminders to keep with iOS. Unlike a fixed morning alarm, a day gets a notification only
/// when at least one chore turns due on it: nothing due, nothing sent; a late chore is not
/// repeated every morning. Paused chores never remind.
nonisolated enum ReminderPlan {
    /// Days looked at; the plan is made again after every change and each time the app opens.
    static let days = 14

    static func reminders(
        for chores: [ChoreSnapshot],
        hour: Int,
        minute: Int,
        now: Date,
        calendar: Calendar,
        days: Int = days
    ) -> [PlannedReminder] {
        let hour = min(max(hour, 0), 23)
        let minute = min(max(minute, 0), 59)
        let today = calendar.startOfDay(for: now)
        let active = Urgency.sorted(chores.filter { !$0.clock.isPaused }, at: now, calendar: calendar)
        let dueDays = active.map { (name: $0.chore.name, day: calendar.startOfDay(for: $0.state.dueDate)) }

        return (0..<max(days, 0)).compactMap { offset -> PlannedReminder? in
            guard let day = calendar.date(byAdding: .day, value: offset, to: today),
                  let fire = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day),
                  fire > now else { return nil }
            let names = dueDays.filter { $0.day == day }.map(\.name)
            return names.isEmpty ? nil : PlannedReminder(fireDate: fire, choreNames: names)
        }
    }
}
