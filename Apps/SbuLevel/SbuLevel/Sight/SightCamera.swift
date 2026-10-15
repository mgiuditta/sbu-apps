import AVFoundation
import Observation

/// The rear camera behind the sight. It feeds a preview and nothing else: there is no photo or
/// video output, so no picture is ever saved or leaves the screen.
@Observable
final class SightCamera {
    private(set) var access: CameraAccess
    /// Whether the picture is live.
    private(set) var isRunning = false

    /// Read by the preview layer only.
    @ObservationIgnored let session = AVCaptureSession()
    /// Starting and stopping a capture session blocks: Apple asks for a serial queue off the main thread.
    @ObservationIgnored private let queue = DispatchQueue(label: "dev.sbu.level.sight")
    @ObservationIgnored private var isConfigured = false

    init() {
        access = Self.currentAccess()
    }

    private static func currentAccess() -> CameraAccess {
        CameraAccess.from(AVCaptureDevice.authorizationStatus(for: .video), hasCamera: rearCamera() != nil)
    }

    nonisolated private static func rearCamera() -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }

    /// Asks for the camera the first time, then shows it until the calling task is cancelled.
    func run() async {
        access = Self.currentAccess()
        if access == .notDetermined {
            access = await AVCaptureDevice.requestAccess(for: .video) ? .allowed : .denied
        }
        guard access == .allowed, Task.isCancelled == false else { return }

        await perform(configure: isConfigured == false) { $0.startRunning() }
        isConfigured = true
        isRunning = true
        while Task.isCancelled == false {
            try? await Task.sleep(for: .seconds(3600))
        }
        isRunning = false
        await perform(configure: false) { $0.stopRunning() }
    }

    /// Runs `work` on the session queue, after adding the rear camera the first time.
    private func perform(configure: Bool, _ work: @escaping @Sendable (AVCaptureSession) -> Void) async {
        // The session is only touched on `queue`, one call at a time, as AVFoundation documents;
        // the preview layer reads it on its own.
        nonisolated(unsafe) let session = session
        await withCheckedContinuation { continuation in
            queue.async {
                if configure {
                    Self.addRearCamera(to: session)
                }
                work(session)
                continuation.resume()
            }
        }
    }

    nonisolated private static func addRearCamera(to session: AVCaptureSession) {
        guard let camera = rearCamera(), let input = try? AVCaptureDeviceInput(device: camera) else { return }
        session.beginConfiguration()
        session.sessionPreset = .high
        if session.canAddInput(input) {
            session.addInput(input)
        }
        session.commitConfiguration()
    }
}
