import Foundation

/// The container the app shares with its widgets: the Noise file and what is playing.
nonisolated enum AppGroup {
    static let id = "group.dev.sbu.noise"

    /// The App Group container, or Application Support if the group is missing.
    static var folder: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id) ?? .applicationSupportDirectory
    }
}
