import Foundation

/// The sound played in lost headphones: short beeps that grow from soft to full volume, so an
/// earbud under a cushion is heard without hurting the ears of someone wearing it.
nonisolated enum RingTone {
    static let sampleRate = 44_100.0
    static let duration = 15.0
    /// Seconds to grow from the softest to full volume.
    static let rampDuration = 10.0
    static let softest = 0.1
    static let frequency = 2_000.0
    /// One beep and its pause.
    static let beepLength = 0.15
    static let period = 0.4

    /// Volume at a moment: from `softest` to 1 over `rampDuration`, then full.
    static func volume(at time: Double) -> Double {
        guard time > 0 else { return softest }
        return min(1, softest + (1 - softest) * time / rampDuration)
    }

    /// Whether a moment falls inside a beep or in its pause.
    static func isBeeping(at time: Double) -> Bool {
        guard time >= 0 else { return false }
        return time.truncatingRemainder(dividingBy: period) < beepLength
    }

    /// The whole tone as mono samples from -1 to 1.
    static func samples() -> [Float] {
        let count = Int(duration * sampleRate)
        return (0..<count).map { index in
            let time = Double(index) / sampleRate
            guard isBeeping(at: time) else { return 0 }
            return Float(volume(at: time) * sin(2 * .pi * frequency * time))
        }
    }
}
