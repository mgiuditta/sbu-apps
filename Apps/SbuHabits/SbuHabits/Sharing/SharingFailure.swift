import Foundation

/// Why sharing a habit, or reading one shared, did not go through.
nonisolated enum SharingFailure: Error, Equatable {
    /// The habit's zone is gone: its owner stopped sharing it, maybe from another device.
    case notShared
    /// No iCloud, or no CloudKit here (UI tests, previews).
    case unavailable
}
