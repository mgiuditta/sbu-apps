import Foundation

/// The App Group the app shares with its widget: saved TVs and, as a Keychain access group, their credentials.
nonisolated enum AppGroup {
    static let identifier = "group.dev.sbu.remote"

    /// `nil` until the widget exists and both targets carry the App Group entitlement (#347).
    static let keychainAccessGroup: String? = nil
}
