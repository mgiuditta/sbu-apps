import Photos

/// Whether the app may write to the photo library.
nonisolated enum LibraryAccess: Equatable, Sendable {
    /// Not asked yet.
    case notDetermined
    /// Refused or restricted: only Settings can change it.
    case denied
    /// Only the photos the user picked: copies can be saved, originals deleted only if picked.
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

    /// Whether compressed copies can go to Photos.
    var canSave: Bool {
        self == .limited || self == .full
    }
}
