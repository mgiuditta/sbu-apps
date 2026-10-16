import AVFoundation
import Foundation

/// Whether tracing can show the rear camera.
nonisolated enum CameraAccess: Equatable, Sendable {
    /// Not asked yet: the trace screen explains first, then the system asks.
    case notDetermined
    /// Allowed: the paper shows under the photo.
    case allowed
    /// Refused, or restricted by Screen Time: only Settings can change it.
    case denied
    /// No rear camera, as in the simulator.
    case unavailable

    /// The access UI tests ask for with `-CAMERA_ACCESS notDetermined|denied|unavailable`, which
    /// the simulator, without a camera, cannot show; `nil` reads the real one.
    static func forced(by defaults: UserDefaults) -> CameraAccess? {
        switch defaults.string(forKey: "CAMERA_ACCESS") {
        case "notDetermined": .notDetermined
        case "denied": .denied
        case "unavailable": .unavailable
        default: nil
        }
    }

    /// The access for a camera authorization, on a device with or without a rear camera.
    static func from(_ status: AVAuthorizationStatus, hasCamera: Bool) -> CameraAccess {
        guard hasCamera else { return .unavailable }
        switch status {
        case .authorized: return .allowed
        case .notDetermined: return .notDetermined
        case .denied, .restricted: return .denied
        @unknown default: return .denied
        }
    }
}
