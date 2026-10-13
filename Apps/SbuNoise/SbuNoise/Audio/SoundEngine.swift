import AVFAudio

/// Plays sounds as layers on one `AVAudioEngine`: one node per layer, each with its own volume and
/// pan, mixed by the engine's main mixer.
///
/// Recordings loop from a buffer held in memory (`.loops`), so the jump back to the start happens
/// inside the engine with no I/O; the seam itself is crossfaded when the file is made. Noises are
/// generated forever by an `AVAudioSourceNode` and never loop.
final class SoundEngine {
    private let engine = AVAudioEngine()
    private var layers: [String: AVAudioNode & AVAudioMixing] = [:]

    /// The ids of the layers playing now.
    var layerIDs: Set<String> { Set(layers.keys) }

    /// Adds a generated noise layer, replacing any layer with the same id.
    func addNoise(_ color: NoiseColor, id: String) throws {
        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        let node = Self.makeNoiseNode(color, sampleRate: sampleRate > 0 ? sampleRate : 44_100)
        try add(node, id: id, format: node.outputFormat(forBus: 0))
    }

    /// Adds a recording that loops without a gap, replacing any layer with the same id.
    func addLoop(_ buffer: AVAudioPCMBuffer, id: String) throws {
        let player = AVAudioPlayerNode()
        try add(player, id: id, format: buffer.format)
        player.scheduleBuffer(buffer, at: nil, options: .loops)
        player.play()
    }

    func setVolume(_ volume: Float, for id: String) {
        layers[id]?.volume = volume
    }

    /// - Parameter pan: -1 is full left, 1 full right.
    func setPan(_ pan: Float, for id: String) {
        layers[id]?.pan = pan
    }

    func volume(for id: String) -> Float? {
        layers[id]?.volume
    }

    /// Moves a layer's volume to `target` over `duration`, in small steps; returns when done or cancelled.
    func fade(_ id: String, to target: Float, over duration: Duration) async {
        guard let node = layers[id] else { return }
        let ramp = VolumeRamp(from: node.volume, to: target, duration: duration)
        let clock = ContinuousClock()
        let start = clock.now
        while !Task.isCancelled {
            let elapsed = clock.now - start
            node.volume = ramp.volume(after: elapsed)
            if elapsed >= duration { return }
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    func remove(_ id: String) {
        guard let node = layers.removeValue(forKey: id) else { return }
        (node as? AVAudioPlayerNode)?.stop()
        engine.detach(node)
        if layers.isEmpty {
            engine.stop()
            // Lets the music or podcast this sound interrupted carry on.
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    /// Starts the engine again after the hardware stopped it (`AVAudioEngineConfigurationChange`);
    /// the layers keep their nodes and connections.
    func restart() {
        guard !layers.isEmpty, !engine.isRunning else { return }
        try? engine.start()
    }

    /// Reads a whole audio file into memory, ready for `addLoop`. `AVAudioFile` drops the AAC
    /// priming and remainder frames, so the buffer holds exactly the encoded samples.
    nonisolated static func loadLoop(_ url: URL) throws -> AVAudioPCMBuffer {
        let file = try AVAudioFile(forReading: url)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        try file.read(into: buffer)
        return buffer
    }

    private func add(_ node: AVAudioNode & AVAudioMixing, id: String, format: AVAudioFormat) throws {
        remove(id)
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        layers[id] = node
        if !engine.isRunning {
            // `.playback` keeps playing locked and in the background, and is not mixable, so the
            // lock screen and Control Center show this app as the one playing.
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
        }
    }

    /// A mono source node rendering `color` on the audio thread: the generator is captured by value
    /// and never shared, so the render block takes no locks and allocates nothing.
    private nonisolated static func makeNoiseNode(_ color: NoiseColor, sampleRate: Double) -> AVAudioSourceNode {
        var generator = NoiseGenerator(color: color, seed: UInt64.random(in: 1...UInt64.max))
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        return AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList in
            for buffer in UnsafeMutableAudioBufferListPointer(audioBufferList) {
                let samples = UnsafeMutableBufferPointer<Float>(buffer)
                for frame in 0..<Int(frameCount) {
                    samples[frame] = generator.next()
                }
            }
            return noErr
        }
    }
}
