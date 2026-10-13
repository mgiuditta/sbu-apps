import Foundation

/// How a habit reminds: never, at the hour it is usually done, or at times the user picks.
nonisolated enum ReminderMode: CaseIterable, Sendable {
    case off
    /// Once a day at the hour it is usually done, from its marks: `AutomaticReminder`.
    case automatic
    /// At the habit's own `reminders` times.
    case custom

    var title: LocalizedStringResource {
        switch self {
        case .off: "Nessun promemoria"
        case .automatic: "Orari automatici"
        case .custom: "Orari personalizzati"
        }
    }
}
