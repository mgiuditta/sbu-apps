import Foundation

/// How a place on the Mix Pad sounds, and how a sound with variance wanders over time.
///
/// ponytail: stereo pan plus a quieter sound further away; front and back only change the distance.
/// `AVAudioEnvironmentNode` (HRTF) if front and back must be heard in headphones.
nonisolated enum MixSpace {
    /// Left -1 to right 1.
    static func pan(at point: MixPoint) -> Float {
        Float(min(1, max(-1, point.x)))
    }

    /// Full at the listener, a third at the edge of the pad and beyond.
    static func gain(at point: MixPoint) -> Float {
        Float(1 - 2.0 / 3.0 * min(1, point.distance))
    }

    /// Where `layer` is after `time` seconds: on a slow closed path around its position, within
    /// its variance radius; still when the variance is 0. `phase` keeps layers out of step.
    static func position(of layer: MixLayer, at time: TimeInterval, phase: Double = 0) -> MixPoint {
        guard layer.variance > 0 else { return layer.position }
        let frequency = 0.02 + 0.2 * layer.speed
        let angle = 2 * Double.pi * frequency * time + phase
        return MixPoint(
            x: layer.position.x + layer.variance * sin(angle),
            y: layer.position.y + layer.variance * sin(1.3 * angle + phase)
        )
    }
}
