/// Why a change to the photo library did not happen.
nonisolated enum LibraryError: Error, Equatable, Sendable {
    /// No permission to write to Photos.
    case denied
    /// The system could not save the copy.
    case saveFailed
    /// The user said no in the system dialog.
    case cancelled
}
