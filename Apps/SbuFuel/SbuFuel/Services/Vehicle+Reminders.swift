import Foundation

extension Vehicle {
    /// Every odometer reading logged, fuel-ups and services, for the pace and the neighbour check.
    var odometerReadings: [OdometerReading] {
        (fuelUps ?? []).map { OdometerReading(id: $0.id, date: $0.date, km: $0.odometerKm, source: .fuelUp) }
            + (services ?? []).compactMap { service in
                service.odometerKm.map { OdometerReading(id: service.id, date: service.date, km: $0, source: .service) }
            }
    }

    /// Where the odometer is and how fast it moves, from the readings logged.
    var odometerEstimate: OdometerEstimate? {
        OdometerEstimate(readings: odometerReadings.map { (date: $0.date, km: $0.km) })
    }

    func due(_ reminder: ServiceReminder, now: Date = .now, calendar: Calendar = .current) -> ReminderDue {
        ReminderSchedule.due(reminder.rule, estimate: odometerEstimate, now: now, calendar: calendar)
    }

    /// The reminders, the most urgent first.
    func sortedReminders(now: Date = .now, calendar: Calendar = .current) -> [(reminder: ServiceReminder, due: ReminderDue)] {
        (reminders ?? []).map { ($0, due($0, now: now, calendar: calendar)) }.sorted { lhs, rhs in
            if lhs.1.status != rhs.1.status { return lhs.1.status < rhs.1.status }
            return (lhs.1.firstDate ?? .distantFuture, lhs.0.title) < (rhs.1.firstDate ?? .distantFuture, rhs.0.title)
        }
    }

    /// The reminders as the notification plan sees them.
    func reminderInputs(now: Date = .now, calendar: Calendar = .current) -> [ReminderInput] {
        (reminders ?? []).map { reminder in
            let due = due(reminder, now: now, calendar: calendar)
            return ReminderInput(id: reminder.id, vehicleName: name, title: reminder.title, due: due,
                                 dueReading: due.dueKm.map { odometerUnit.formatted(km: $0) })
        }
    }

    /// Moves forward the reminders a logged service answers: same kind (same name for "Altro"),
    /// done on or after the last time.
    func rollReminders(for service: ServiceEntry) {
        for reminder in reminders ?? [] where reminder.kind == service.kind && service.date >= reminder.lastDoneDate {
            if service.kind == .custom, reminder.title.localizedCaseInsensitiveCompare(service.title) != .orderedSame { continue }
            reminder.lastDoneDate = service.date
            if let km = service.odometerKm ?? odometerEstimate?.lastKm {
                reminder.lastDoneOdometerKm = km
            }
        }
    }
}
