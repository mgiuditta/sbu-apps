import Foundation

/// How well the latest fix knows where the iPhone is, in one word for the cartiglio.
nonisolated enum GPSAccuracy: Equatable, Sendable {
    /// Within this many metres the fix is precise: a lane on the road.
    static let preciseMeters = 10.0
    /// Within this many metres it is still good: the speed holds, the course may wander.
    static let goodMeters = 30.0

    /// No fix, or no access to the position.
    case none
    case weak
    case good
    case precise

    /// From a fix's horizontal accuracy in metres; negative when the position is not valid.
    init(horizontalAccuracy: Double) {
        switch horizontalAccuracy {
        case ..<0: self = .none
        case ...Self.preciseMeters: self = .precise
        case ...Self.goodMeters: self = .good
        default: self = .weak
        }
    }

    /// The cartiglio's last part: "GPS preciso".
    var text: LocalizedStringResource {
        switch self {
        case .none: "GPS assente"
        case .weak: "GPS debole"
        case .good: "GPS buono"
        case .precise: "GPS preciso"
        }
    }
}
