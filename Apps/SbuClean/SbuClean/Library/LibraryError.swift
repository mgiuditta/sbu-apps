/// Why a change to the library did not happen.
nonisolated enum LibraryError: Error, Equatable, Sendable {
    /// The item is gone, or only in iCloud and not on the iPhone.
    case unavailable
    /// The system could not save the new copy.
    case saveFailed
    /// The user said no in the system dialog.
    case cancelled
}
