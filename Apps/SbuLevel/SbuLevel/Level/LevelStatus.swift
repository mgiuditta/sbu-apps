import Foundation

/// The one line under the figure: what the figure means right now.
nonisolated enum LevelStatus: Equatable, Sendable {
    case locked(isRelative: Bool)
    case relative(atZero: Bool)
    case level
    case flat
    case edge
    case aboveHorizon
    case belowHorizon
    case onHorizon
    case cameraUnavailable
    case cameraDenied

    init(readout: Readout, isLocked: Bool, camera: CameraAccess? = nil) {
        let isSight = readout.reading.mode == .sight
        if isSight, camera == .unavailable {
            self = .cameraUnavailable
        } else if isSight, camera == .denied {
            self = .cameraDenied
        } else if isLocked {
            self = .locked(isRelative: readout.isRelative)
        } else if readout.isRelative {
            self = .relative(atZero: readout.isLevel)
        } else if isSight {
            self = readout.isLevel ? .onHorizon : readout.angle > 0 ? .aboveHorizon : .belowHorizon
        } else if readout.isLevel {
            self = .level
        } else {
            self = readout.reading.mode == .flat ? .flat : .edge
        }
    }

    /// The SF Symbol before the words, if any.
    var systemImage: String? {
        switch self {
        case .locked: "lock.fill"
        case .cameraUnavailable, .cameraDenied: "camera"
        default: nil
        }
    }
}
