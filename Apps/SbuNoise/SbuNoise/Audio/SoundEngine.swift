import AVFAudio

/// Plays sounds as layers on one `AVAudioEngine`: one source per layer through its own pitch unit,
/// with its own volume and place around the listener. In headphones the layers go through one
/// environment node that renders the place with HRTF, so behind is heard behind; on a speaker they
/// go straight to the main mixer with a stereo pan. Fades move the whole output.
///
/// Recordings loop from a buffer held in memory (`.loops`), so the jump back to the start happens
/// inside the engine with no I/O; the seam itself is crossfaded when the file is made. Noises are
/// generated forever by an `AVAudioSourceNode` and never loop.
final class SoundEngine {
    private let engine = AVAudioEngine()
    /// Each layer's chain: source → pitch unit → its own mixer, which carries volume, pan and
    /// position into the environment or the main mixer (an `AVAudioUnit` is not `AVAudioMixing`).
    private var layers: [String: (source: AVAudioNode, pitch: AVAudioUnitTimePitch, mixer: AVAudioMixerNode)] = [:]
    private let environment = AVAudioEnvironmentNode()
    /// Whether the layers go through the environment (HRTF); follows the output in use (`followRoute`).
    private(set) var isSpatial = false

    init() {
        engine.attach(environment)
        // ponytail: distance is the layer's volume (`MixSpace.gain`), so the environment never
        // attenuates: every point of the pad is well inside the reference distance.
        environment.distanceAttenuationParameters.referenceDistance = 100
        environment.distanceAttenuationParameters.maximumDistance = 1_000
    }

    /// The ids of the layers playing now.
    var layerIDs: Set<String> { Set(layers.keys) }

    /// Adds a generated noise layer, replacing any layer with the same id.
    func addNoise(_ color: NoiseColor, id: String) throws {
        try activateSession()
        // The session's rate, not `outputNode`'s: reading the output node before the session is
        // set up left wired EarPods with sound in the left ear only.
        let sampleRate = AVAudioSession.sharedInstance().sampleRate
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
        layers[id]?.mixer.volume = volume
    }

    /// Where the layer sits around the listener.
    func setPosition(_ point: MixPoint, for id: String) {
        guard let mixer = layers[id]?.mixer else { return }
        // Both are kept: only the one of the current connection is heard.
        mixer.position = MixSpace.position3D(at: point)
        mixer.pan = MixSpace.pan(at: point)
    }

    /// Moves every layer into the environment (HRTF) or straight to the main mixer (stereo pan).
    func setSpatial(_ spatial: Bool) {
        guard spatial != isSpatial else { return }
        isSpatial = spatial
        for layer in layers.values { connectOutput(of: layer.mixer) }
    }

    /// HRTF only in headphones: on a speaker it colors the sound and front and back are not heard.
    func followRoute() {
        setSpatial(MixSpace.hearsFrontAndBack(on: AVAudioSession.sharedInstance().currentRoute.outputs.map(\.portType)))
    }

    /// - Parameter cents: -1200...1200; 0 bypasses the pitch unit.
    func setPitch(_ cents: Float, for id: String) {
        guard let unit = layers[id]?.pitch else { return }
        unit.pitch = cents
        unit.bypass = cents == 0
    }

    func volume(for id: String) -> Float? {
        layers[id]?.mixer.volume
    }

    /// The volume of everything together, which fades move.
    var outputVolume: Float {
        get { engine.mainMixerNode.outputVolume }
        set { engine.mainMixerNode.outputVolume = newValue }
    }

    /// Moves the output volume to `target` over `duration`, in small steps; returns when done or cancelled.
    func fadeOutput(to target: Float, over duration: Duration) async {
        let ramp = VolumeRamp(from: outputVolume, to: target, duration: duration)
        let clock = ContinuousClock()
        let start = clock.now
        while !Task.isCancelled {
            let elapsed = clock.now - start
            outputVolume = ramp.volume(after: elapsed)
            if elapsed >= duration { return }
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    /// Removes every layer, stops the engine and releases the audio session.
    /// Left and right loudness of the output over `duration`: tells whether a sound is heard in both ears.
    func outputLevels(over duration: Duration) async -> [Float] {
        let mixer = engine.mainMixerNode
        let meter = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: ChannelMeter.install(on: mixer))
            }
        }
        try? await Task.sleep(for: duration)
        mixer.removeTap(onBus: 0)
        return meter.levels
    }

    func removeAll() {
        replaceAll()
        stop()
    }

    /// Removes every layer but keeps the engine and the session running, before adding new layers.
    func replaceAll() {
        for id in layers.keys { detach(id) }
    }

    /// Removes a layer; the last one out stops the engine and releases the session.
    func remove(_ id: String) {
        detach(id)
        if layers.isEmpty { stop() }
    }

    /// Follows a new output and starts the engine again if the hardware stopped it
    /// (`AVAudioEngineConfigurationChange`); the layers keep their nodes and connections.
    func restart() {
        guard !layers.isEmpty else { return }
        followRoute()
        if !engine.isRunning { try? engine.start() }
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

    private func detach(_ id: String) {
        guard let layer = layers.removeValue(forKey: id) else { return }
        (layer.source as? AVAudioPlayerNode)?.stop()
        engine.detach(layer.source)
        engine.detach(layer.pitch)
        engine.detach(layer.mixer)
    }

    private func stop() {
        engine.stop()
        // Lets the music or podcast this sound interrupted carry on.
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func add(_ node: AVAudioNode, id: String, format: AVAudioFormat) throws {
        detach(id)
        let pitch = AVAudioUnitTimePitch()
        pitch.bypass = true
        let mixer = AVAudioMixerNode()
        for unit in [node, pitch, mixer] { engine.attach(unit) }
        engine.connect(node, to: pitch, format: format)
        engine.connect(pitch, to: mixer, format: format)
        layers[id] = (node, pitch, mixer)
        if !engine.isRunning {
            try activateSession()
            // Stereo out of the environment: a mono connection into the main mixer reached only
            // the left ear on wired EarPods.
            let stereo = AVAudioFormat(standardFormatWithSampleRate: format.sampleRate, channels: 2)
            engine.connect(environment, to: engine.mainMixerNode, format: stereo)
            isSpatial = MixSpace.hearsFrontAndBack(on: AVAudioSession.sharedInstance().currentRoute.outputs.map(\.portType))
            connectOutput(of: mixer)
            try engine.start()
        } else {
            connectOutput(of: mixer)
        }
    }

    /// Mono into the environment, which only places mono sources (a stereo recording is mixed down
    /// by the layer's mixer); stereo into the main mixer, where a mono connection reached only the
    /// left ear on wired EarPods and the layer's pan is a balance.
    private func connectOutput(of mixer: AVAudioMixerNode) {
        let sampleRate = mixer.inputFormat(forBus: 0).sampleRate
        if isSpatial {
            engine.connect(mixer, to: environment, format: AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1))
            mixer.renderingAlgorithm = .HRTFHQ
        } else {
            engine.connect(mixer, to: engine.mainMixerNode, format: AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2))
        }
    }

    /// `.playback` keeps playing locked and in the background, and is not mixable, so the lock
    /// screen and Control Center show this app as the one playing. Set up before the graph is built.
    private func activateSession() throws {
        guard !engine.isRunning else { return }
        try AVAudioSession.sharedInstance().setCategory(.playback)
        try AVAudioSession.sharedInstance().setActive(true)
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
