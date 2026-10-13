/// The guided two-step calibration of one side: measure, turn the iPhone 180° on the same spot, measure again.
nonisolated struct CalibrationSession: Equatable, Sendable {
    enum Step: Equatable, Sendable {
        /// Waiting for, or capturing, the first reading.
        case first
        /// Waiting for, or capturing, the reading after turning the iPhone.
        case second
        /// Both readings taken and the offset computed.
        case done
    }

    /// Why a capture did not go through.
    enum Notice: Equatable, Sendable {
        /// The iPhone moved while measuring: the capture started over.
        case moved
        /// The second reading is on a different side than the first.
        case wrongSide
        /// The two readings give an implausible result: the surface is too steep or the iPhone
        /// moved. Nothing is saved and the calibration starts again from the first step.
        case implausible
    }

    private(set) var step = Step.first
    /// The side being calibrated, fixed by the first reading.
    private(set) var target: CalibrationTarget?
    private(set) var notice: Notice?
    private(set) var isCapturing = false
    /// Progress of the current capture, 0...1.
    private(set) var progress = 0.0
    /// The calibration to save, once `step` is `.done`.
    private(set) var result: Calibration?

    private var sampler = StableSampler()
    private var captureTarget: CalibrationTarget?
    private var first: Gravity?

    /// Starts measuring the current step; it completes after a second of steady samples.
    mutating func startCapture() {
        guard step != .done else { return }
        isCapturing = true
        progress = 0
        notice = nil
        sampler = StableSampler()
        captureTarget = nil
    }

    /// Feeds one sample.
    /// - Parameters:
    ///   - sample: Raw gravity, before any calibration.
    ///   - current: The side the iPhone rests on for this sample.
    ///   - base: The saved calibration; the result changes only `target` in it.
    mutating func add(_ sample: Gravity, on current: CalibrationTarget, base: Calibration) {
        guard isCapturing else { return }

        if step == .second, current != target {
            notice = .wrongSide
            restartCapture()
            return
        }
        // Rolling onto another side during a capture counts as moving.
        if let captureTarget, captureTarget != current {
            notice = .moved
            restartCapture()
            return
        }
        captureTarget = current

        switch sampler.add(sample) {
        case .collecting(let value):
            progress = value
            if step == .second, notice == .wrongSide { notice = nil }
        case .moved:
            notice = .moved
            progress = 0
        case .stable(let mean):
            finishCapture(with: mean, on: current, base: base)
        }
    }

    private mutating func restartCapture() {
        sampler = StableSampler()
        captureTarget = nil
        progress = 0
    }

    private mutating func finishCapture(with mean: Gravity, on current: CalibrationTarget, base: Calibration) {
        isCapturing = false
        progress = 0
        notice = nil
        switch step {
        case .first:
            first = mean
            target = current
            step = .second
        case .second:
            if let first, let target, let calibrated = base.calibrating(target, first: first, second: mean) {
                result = calibrated
                step = .done
            } else {
                notice = .implausible
                first = nil
                target = nil
                step = .first
            }
        case .done:
            break
        }
    }
}
