import AVFoundation

/// Plays the ring tone with AVAudioEngine in the playback category, so it sounds in the
/// headphones even with the silent switch on: you asked for it.
final class EngineTonePlayer: TonePlayer {
    private let engine = AVAudioEngine()
    private let node = AVAudioPlayerNode()

    init() {
        engine.attach(node)
    }

    func play(_ samples: [Float], sampleRate: Double, finished: @escaping @MainActor () -> Void) throws {
        stop()
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)),
              let channel = buffer.floatChannelData?[0] else { return }
        buffer.frameLength = AVAudioFrameCount(samples.count)
        samples.withUnsafeBufferPointer { source in
            if let base = source.baseAddress {
                channel.update(from: base, count: samples.count)
            }
        }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        try engine.start()
        node.scheduleBuffer(buffer, at: nil, options: [], completionCallbackType: .dataPlayedBack) { _ in
            Task { @MainActor in
                finished()
            }
        }
        node.play()
    }

    func stop() {
        node.stop()
        engine.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
