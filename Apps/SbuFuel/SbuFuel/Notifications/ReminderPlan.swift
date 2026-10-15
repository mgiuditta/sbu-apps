import Foundation

/// Which notifications to keep with iOS for the service reminders.
///
/// Each reminder gets one notification at `hour` on the first day it is due, by time or by the
/// day your pace says the odometer gets there. A reminder whose reading you have already passed,
/// logged with a fuel-up, is announced right away, once per due reading.
nonisolated enum ReminderPlan {
    /// iOS keeps at most 64 pending notifications per app and drops the rest.
    static let limit = 64
    static let hour = 9

    struct Plan: Equatable, Sendable {
        var scheduled: [PlannedNotification] = []
        /// To deliver now, keyed so each is sent once.
        var immediate: [(key: String, notification: PlannedNotification)] = []

        static func == (lhs: Plan, rhs: Plan) -> Bool {
            lhs.scheduled == rhs.scheduled && lhs.immediate.map(\.key) == rhs.immediate.map(\.key)
        }
    }

    static func plan(_ reminders: [ReminderInput], now: Date, calendar: Calendar) -> Plan {
        var plan = Plan()
        for reminder in reminders {
            let title = "\(reminder.vehicleName): \(reminder.title)"
            if reminder.due.isPastByDistance, let dueKm = reminder.due.dueKm {
                let body = reminder.dueReading.map { String(localized: "Hai superato \($0): è ora di farlo.") }
                    ?? String(localized: "È ora di farlo.")
                plan.immediate.append((key: "\(reminder.id.uuidString)-\(Int(dueKm.rounded()))",
                                       notification: PlannedNotification(identifier: "\(reminder.id.uuidString)-km", title: title, body: body, fireDate: nil)))
                continue
            }
            guard let first = reminder.due.firstDate,
                  let fire = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: first),
                  fire > now else { continue }
            let byTime = reminder.due.dueDate.map { calendar.isDate($0, inSameDayAs: first) } ?? false
            let body: String
            if byTime {
                body = String(localized: "Scade oggi.")
            } else if let reading = reminder.dueReading {
                body = String(localized: "Dai tuoi rifornimenti, oggi arrivi a \(reading).")
            } else {
                body = String(localized: "È ora di farlo.")
            }
            plan.scheduled.append(PlannedNotification(identifier: reminder.id.uuidString, title: title, body: body, fireDate: fire))
        }
        plan.scheduled = Array(plan.scheduled.sorted { ($0.fireDate ?? now) < ($1.fireDate ?? now) }.prefix(limit))
        return plan
    }
}
