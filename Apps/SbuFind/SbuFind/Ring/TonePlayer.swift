/// Plays the ring tone: AVAudioEngine on an iPhone, nothing in UI tests.
protocol TonePlayer {
    /// Starts the tone; calls `finished` when it ends by itself.
    func play(_ samples: [Float], sampleRate: Double, finished: @escaping @MainActor () -> Void) throws

    func stop()
}
