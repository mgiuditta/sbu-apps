import Photos

/// Whether the app may read the photo library, in the terms the cleaner cares about.
nonisolated enum LibraryAccess: Equatable, Sendable {
    /// Not asked yet.
    case notDetermined
    /// Refused or restricted: only Settings can change it.
    case denied
    /// Only the photos the user picked.
    case limited
    /// The whole library.
    case full

    init(status: PHAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .limited: self = .limited
        case .authorized: self = .full
        default: self = .denied
        }
    }

    /// Whether the library can be read at all.
    var canRead: Bool {
        self == .limited || self == .full
    }
}
