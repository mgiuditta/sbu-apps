import Foundation

extension UserDefaults {
    /// Shared with the widget: only the snapshot the app writes for it.
    static let appGroup = UserDefaults(suiteName: "group.dev.sbu.libretto") ?? .standard
}
