import CoreLocation

/// Whether the app may read the position, in the terms the speedometer cares about.
nonisolated enum LocationAccess: Equatable, Sendable {
    /// Not asked yet.
    case notDetermined
    /// Refused, restricted, or location services are off.
    case denied
    /// Allowed, but only the approximate position: it carries no speed.
    case approximate
    /// Allowed with the precise position, while the app is in use.
    case granted

    init(status: CLAuthorizationStatus, accuracy: CLAccuracyAuthorization) {
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .authorizedWhenInUse, .authorizedAlways:
            self = accuracy == .fullAccuracy ? .granted : .approximate
        default:
            self = .denied
        }
    }
}
