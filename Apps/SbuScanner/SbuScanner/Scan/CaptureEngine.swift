import AVFoundation

/// The camera session that reads codes. Everything it changes happens on its own serial queue, as
/// AVFoundation asks; each reading goes to `onReading`, at most twice a second.
// ponytail: @unchecked Sendable because every mutable property is touched only on `queue`.
nonisolated final class CaptureEngine: NSObject, AVCaptureMetadataOutputObjectsDelegate, @unchecked Sendable {
    let session = AVCaptureSession()
    private let onReading: @Sendable (CodeReading) -> Void
    private var lastReading = ContinuousClock.now - .seconds(1)
    private let queue = DispatchQueue(label: "dev.sbu.scanner.capture")
    private let output = AVCaptureMetadataOutput()
    private var input: AVCaptureDeviceInput?
    /// The zoom factor that the user's 1× maps to: virtual cameras start on the ultra wide.
    private var baseZoom: CGFloat = 1

    /// - Parameter onReading: Called on the capture queue.
    init(onReading: @escaping @Sendable (CodeReading) -> Void) {
        self.onReading = onReading
        super.init()
    }

    /// Starts reading with the camera at `position`; `nil` when there is none.
    func start(position: CameraPosition) async -> CameraInfo? {
        await withCheckedContinuation { done in
            queue.async {
                let info = self.configure(position: position)
                if info != nil, !self.session.isRunning { self.session.startRunning() }
                done.resume(returning: info)
            }
        }
    }

    func stop() {
        queue.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    func setTorch(_ isOn: Bool) {
        queue.async {
            guard let device = self.input?.device, device.hasTorch, (try? device.lockForConfiguration()) != nil else { return }
            device.torchMode = isOn ? .on : .off
            device.unlockForConfiguration()
        }
    }

    /// - Parameter zoom: As the user counts it, 1× being the main lens.
    func setZoom(_ zoom: CGFloat) {
        queue.async {
            guard let device = self.input?.device, (try? device.lockForConfiguration()) != nil else { return }
            let factor = zoom * self.baseZoom
            device.videoZoomFactor = min(max(factor, device.minAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor)
            device.unlockForConfiguration()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // The camera reports every frame: one reading per half second is plenty.
        guard ContinuousClock.now - lastReading > .milliseconds(500) else { return }
        for case let code as AVMetadataMachineReadableCodeObject in metadataObjects {
            guard let raw = code.stringValue, !raw.isEmpty, let symbology = Symbology(metadataType: code.type) else { continue }
            lastReading = .now
            onReading(CodeReading(raw: raw, symbology: symbology))
            return
        }
    }

    private func configure(position: CameraPosition) -> CameraInfo? {
        guard let device = Self.device(at: position), let newInput = try? AVCaptureDeviceInput(device: device) else { return nil }
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        if let input { session.removeInput(input) }
        guard session.canAddInput(newInput) else { return nil }
        session.addInput(newInput)
        input = newInput
        if !session.outputs.contains(output) {
            guard session.canAddOutput(output) else { return nil }
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: queue)
        }
        output.metadataObjectTypes = Symbology.allCases.map(\.metadataType).filter(output.availableMetadataObjectTypes.contains)

        // On a virtual camera, start on the main lens: iOS switches to the ultra wide by itself for close-up codes.
        baseZoom = device.virtualDeviceSwitchOverVideoZoomFactors.first.map { CGFloat(truncating: $0) } ?? 1
        if (try? device.lockForConfiguration()) != nil {
            device.videoZoomFactor = baseZoom
            if device.isFocusModeSupported(.continuousAutoFocus) { device.focusMode = .continuousAutoFocus }
            if device.isAutoFocusRangeRestrictionSupported { device.autoFocusRangeRestriction = .near }
            device.unlockForConfiguration()
        }
        return CameraInfo(hasTorch: device.hasTorch, maxZoom: max(1, min(device.maxAvailableVideoZoomFactor / baseZoom, 8)))
    }

    private static func device(at position: CameraPosition) -> AVCaptureDevice? {
        switch position {
        case .back:
            AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInTripleCamera, .builtInDualWideCamera, .builtInWideAngleCamera],
                mediaType: .video,
                position: .back
            ).devices.first
        case .front:
            AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        }
    }
}
