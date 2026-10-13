import AVFAudio

/// Sums the energy of each output channel on the audio thread, to check where a sound is heard.
nonisolated final class ChannelMeter: @unchecked Sendable {
    private let lock = NSLock()
    private var sums: [Double] = []
    private var frames = 0

    /// Square root of the summed energy per channel so far: compares channels.
    var levels: [Float] {
        lock.withLock { sums.map { Float($0.squareRoot()) } }
    }

    /// Root mean square per channel so far: compares sounds.
    var rms: [Float] {
        lock.withLock { sums.map { Float(($0 / Double(max(frames, 1))).squareRoot()) } }
    }

    /// Installs the tap from a non-isolated context: its closure runs on the realtime thread.
    static func install(on node: AVAudioNode) -> ChannelMeter {
        let meter = ChannelMeter()
        node.installTap(onBus: 0, bufferSize: 4096, format: nil) { buffer, _ in
            meter.add(buffer)
        }
        return meter
    }

    private func add(_ buffer: AVAudioPCMBuffer) {
        guard let data = buffer.floatChannelData else { return }
        let frames = Int(buffer.frameLength)
        let channels = Int(buffer.format.channelCount)
        var energy = [Double](repeating: 0, count: channels)
        for channel in 0..<channels {
            for frame in 0..<frames {
                let sample = Double(data[channel][frame])
                energy[channel] += sample * sample
            }
        }
        lock.withLock {
            self.frames += frames
            if sums.isEmpty { sums = energy } else { for channel in energy.indices { sums[channel] += energy[channel] } }
        }
    }
}
