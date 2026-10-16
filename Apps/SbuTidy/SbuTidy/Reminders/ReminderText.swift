import Foundation

/// The words of a reminder: the chores by name, three at most, then how many more.
nonisolated enum ReminderText {
    static let namesShown = 3

    static func body(for names: [String], locale: Locale = .current) -> String {
        if names.count <= namesShown {
            return names.formatted(.list(type: .and).locale(locale))
        }
        let shown = names.prefix(namesShown - 1).formatted(.list(type: .and).locale(locale))
        let others = names.count - (namesShown - 1)
        return String(localized: "\(shown) e altre \(others)", locale: locale)
    }
}
