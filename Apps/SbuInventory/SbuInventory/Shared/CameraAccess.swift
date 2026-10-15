import AVFoundation

/// Whether the app may use the camera, asked only when you tap a camera button.
enum CameraAccess {
    /// `true` when allowed, asking iOS the first time; `false` when you said no or it is restricted.
    static func request() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: true
        case .notDetermined: await AVCaptureDevice.requestAccess(for: .video)
        default: false
        }
    }
}
