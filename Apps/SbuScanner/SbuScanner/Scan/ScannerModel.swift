import AVFoundation
import Observation

/// The camera on the tool screen: permission, start and stop, torch, zoom, and the next code read.
@Observable
final class ScannerModel {
    private(set) var state: CameraState = .idle
    private(set) var info: CameraInfo?
    private(set) var isTorchOn = false
    private(set) var position: CameraPosition = .back
    private(set) var zoom: CGFloat = 1
    /// The last code read, until the screen shows it; new readings wait while it is set.
    var reading: CodeReading?

    @ObservationIgnored private lazy var engine = CaptureEngine { [weak self] reading in
        Task { @MainActor in self?.receive(reading) }
    }
    @ObservationIgnored private var isVisible = false
    @ObservationIgnored let isDemo: Bool

    init(isDemo: Bool = LaunchMode.isDemo) {
        self.isDemo = isDemo
    }

    /// Takes a reading only while the screen is visible and the last one has been shown.
    private func receive(_ next: CodeReading) {
        guard isVisible, reading == nil else { return }
        reading = next
    }

    /// The screen is in front: ask for the camera if needed, then start it.
    func appear() async {
        isVisible = true
        guard !isDemo else {
            state = .unavailable
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: break
        case .notDetermined:
            guard await AVCaptureDevice.requestAccess(for: .video) else {
                state = .denied
                return
            }
        default:
            state = .denied
            return
        }
        guard isVisible else { return }
        await startCamera()
    }

    /// The screen is covered (a result, the history, the background): the camera and its light go off.
    func disappear() {
        isVisible = false
        isTorchOn = false
        engine.setTorch(false)
        engine.stop()
    }

    func toggleTorch() {
        isTorchOn.toggle()
        engine.setTorch(isTorchOn)
    }

    func switchCamera() async {
        position = position == .back ? .front : .back
        isTorchOn = false
        zoom = 1
        await startCamera()
    }

    func setZoom(_ value: CGFloat) {
        zoom = min(max(value, 1), info?.maxZoom ?? 1)
        engine.setZoom(zoom)
    }

    /// The demo camera "reads" its sample code on a tap, for screenshots and UI tests.
    func readDemoCode() {
        guard isDemo, reading == nil else { return }
        reading = CodeReading(raw: DemoContent.scannedLink, symbology: .qr)
    }

    var session: AVCaptureSession { engine.session }

    private func startCamera() async {
        info = await engine.start(position: position)
        state = info == nil ? .unavailable : .running
        // A screen that left while the camera was starting turns it off again.
        if !isVisible { engine.stop() }
    }
}
