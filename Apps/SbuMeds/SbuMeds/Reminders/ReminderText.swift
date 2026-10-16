import Foundation

/// The words of a notification: who and when in the title, what and how much in the body.
nonisolated enum ReminderText {
    static func title(for reminder: PlannedReminder, showsPerson: Bool, calendar: Calendar = .current) -> String {
        var style = Date.FormatStyle.dateTime.hour().minute().locale(calendar.locale ?? .current)
        style.timeZone = calendar.timeZone
        let time = reminder.dueDate.formatted(style)
        switch reminder.kind {
        case .doses(let index):
            let when = index == 0 ? String(localized: "Ore \(time)") : String(localized: "Ancora da prendere, ore \(time)")
            return showsPerson ? "\(reminder.personName) · \(when)" : when
        case .refill:
            return String(localized: "Scorte basse")
        }
    }

    static func body(for reminder: PlannedReminder, showsPerson: Bool, locale: Locale = .current) -> String {
        switch reminder.kind {
        case .doses:
            return reminder.lines.map { "\($0.name), \($0.amount)" }.formatted(.list(type: .and).locale(locale))
        case .refill(let name, let left, let form):
            let amount = form.amountText(left, locale: locale)
            return showsPerson
                ? String(localized: "\(name) di \(reminder.personName): ne restano \(amount). Ricompralo.")
                : String(localized: "\(name): ne restano \(amount). Ricompralo.")
        }
    }
}
