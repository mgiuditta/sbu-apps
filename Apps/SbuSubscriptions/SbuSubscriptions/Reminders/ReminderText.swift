import Foundation

/// The body of a reminder: when the payment comes and how much it is.
nonisolated enum ReminderText {
    static func body(for reminder: PlannedReminder, locale: Locale = .current) -> String {
        let amount = reminder.price.formatted(.currency(code: reminder.currencyCode).locale(locale))
        let date = reminder.paymentDate.formatted(.dateTime.day().month(.wide).locale(locale))
        switch (reminder.kind, reminder.daysBefore) {
        case (.renewal, 0): return String(localized: "Si rinnova oggi: \(amount).")
        case (.renewal, 1): return String(localized: "Si rinnova domani: \(amount).")
        case (.renewal, _): return String(localized: "Si rinnova il \(date): \(amount).")
        case (.trialEnds, 0): return String(localized: "La prova gratuita finisce oggi. Poi paghi \(amount).")
        case (.trialEnds, 1): return String(localized: "La prova gratuita finisce domani. Poi paghi \(amount).")
        case (.trialEnds, _): return String(localized: "La prova gratuita finisce il \(date). Poi paghi \(amount).")
        }
    }
}
