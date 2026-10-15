import AVFoundation

/// Whether the sight can show the rear camera.
nonisolated enum CameraAccess: Equatable, Sendable {
    /// Not asked yet: the system asks when the sight opens.
    case notDetermined
    /// Allowed: the picture shows in the dial.
    case allowed
    /// Refused, or restricted by Screen Time: only Settings can change it.
    case denied
    /// No rear camera, as in the simulator.
    case unavailable

    /// The access for a camera authorization, on an iPhone with or without a rear camera.
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
