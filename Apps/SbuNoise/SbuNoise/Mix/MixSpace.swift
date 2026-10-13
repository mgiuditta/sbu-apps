import AVFAudio

/// How a place on the Mix Pad sounds, and how a sound with variance wanders over time.
///
/// A place is a direction around the listener, rendered in 3D in headphones and as a stereo pan on
/// a speaker, plus a quieter sound further away.
nonisolated enum MixSpace {
    /// The point in the environment's space: x to the right, z behind (the listener faces -z, the
    /// top of the pad), at ear height.
    static func position3D(at point: MixPoint) -> AVAudio3DPoint {
        AVAudio3DPoint(x: Float(point.x), y: 0, z: Float(point.y))
    }

    /// Left -1 to right 1, for a speaker.
    static func pan(at point: MixPoint) -> Float {
        Float(min(1, max(-1, point.x)))
    }

    /// Headphones, where each ear has its own driver and HRTF places a sound in front or behind;
    /// not a speaker, where HRTF only colors the sound.
    static func hearsFrontAndBack(on outputs: [AVAudioSession.Port]) -> Bool {
        outputs.contains(where: headphones.contains)
    }

    private static let headphones: Set<AVAudioSession.Port> = [.headphones, .bluetoothA2DP, .bluetoothLE, .bluetoothHFP]

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
