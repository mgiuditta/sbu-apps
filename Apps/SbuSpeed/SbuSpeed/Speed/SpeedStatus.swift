/// What the line under the figure says.
nonisolated enum SpeedStatus: Equatable, Sendable {
    /// Below this speed (m/s, about 1 km/h) the iPhone counts as still.
    static let stillSpeed = 0.3

    case needsAccess
    case denied
    case approximate
    case searching
    case still
    case moving

    init(access: LocationAccess, speed: Double?) {
        switch access {
        case .notDetermined: self = .needsAccess
        case .denied: self = .denied
        case .approximate: self = .approximate
        case .granted:
            if let speed {
                self = speed < Self.stillSpeed ? .still : .moving
            } else {
                self = .searching
            }
        }
    }

    /// The access is missing and only the Settings app can give it.
    var needsSettings: Bool { self == .denied || self == .approximate }
}
