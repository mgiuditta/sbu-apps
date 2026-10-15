import AVFoundation

/// Reads the figure aloud with the iPhone's own voice, in the app's language. Speech is
/// synthesized on the device: nothing goes on the network.
final class ReadingSpeaker {
    private let synthesizer = AVSpeechSynthesizer()
    private let clock = ContinuousClock()
    private let start: ContinuousClock.Instant
    private var schedule = SpeechSchedule(mode: .off)

    init() {
        start = clock.now
        // The system's speech session: it ducks other audio and leaves the app's alone.
        synthesizer.usesApplicationAudioSession = false
    }

    /// Feeds the shown reading; speaks when the schedule says so.
    func update(mode: SpeechMode, degrees: Double, text: String) {
        if schedule.mode != mode {
            schedule = SpeechSchedule(mode: mode)
            if mode == .off { synthesizer.stopSpeaking(at: .immediate) }
        }
        let seconds = start.duration(to: clock.now) / .seconds(1)
        if let words = schedule.next(degrees: degrees, text: text, at: seconds) {
            speak(words)
        }
    }

    /// Says `text` now, cutting off anything still being said.
    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: Bundle.main.preferredLocalizations.first)
        synthesizer.speak(utterance)
    }
}
