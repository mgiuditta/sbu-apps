import Foundation

extension UserDefaults {
    /// Shared by the app, its widget and its Screen Time extensions.
    static let appGroup = UserDefaults(suiteName: "group.dev.sbu.social") ?? .standard
}
