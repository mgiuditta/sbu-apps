import Foundation

extension UserDefaults {
    /// Preferences the widget reads too: main currency, own rates, the period of the total.
    static let appGroup = UserDefaults(suiteName: "group.dev.sbu.subscriptions") ?? .standard
}
