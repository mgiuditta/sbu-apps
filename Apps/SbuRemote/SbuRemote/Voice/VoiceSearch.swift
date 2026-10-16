import AVFoundation
import Observation
import Speech

/// Voice search for the TV, recognized on the iPhone only. Where the language has no
/// on-device model, `isAvailable` is false and the microphone button is not there.
@Observable
final class VoiceSearch {
    enum Phase: Equatable {
        case idle
        case listening
        /// The user said no to the microphone or to speech recognition.
        case denied
        case failed
    }

    private(set) var phase = Phase.idle
    private(set) var transcript = ""

    @ObservationIgnored private let recognizer = SFSpeechRecognizer(locale: .current)
    @ObservationIgnored private let engine = AVAudioEngine()
    @ObservationIgnored private var task: SFSpeechRecognitionTask?

    /// Only when this language can be recognized without the network.
    var isAvailable: Bool {
        recognizer?.supportsOnDeviceRecognition == true
    }

    func start() async {
        guard let recognizer, isAvailable, phase != .listening else { return }
        guard await Self.authorize() else {
            phase = .denied
            return
        }
        transcript = ""
        do {
            task = try SpeechPipeline.start(recognizer: recognizer, engine: engine) { [weak self] text, isFinal in
                Task { @MainActor in self?.heard(text, isFinal: isFinal) }
            } onFailure: { [weak self] in
                Task { @MainActor in self?.failed() }
            }
            phase = .listening
        } catch {
            stop()
            phase = .failed
        }
    }

    /// Stops listening and returns what was heard.
    @discardableResult
    func stop() -> String {
        SpeechPipeline.stop(engine: engine, task: task)
        task = nil
        if phase == .listening { phase = .idle }
        return transcript.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func heard(_ text: String, isFinal: Bool) {
        transcript = text
        if isFinal { stop() }
    }

    private func failed() {
        guard phase == .listening else { return }
        stop()
        // Silence ends a task with an error; with something heard it is just the end.
        phase = transcript.isEmpty ? .failed : .idle
    }

    private static func authorize() async -> Bool {
        let speech = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
        guard speech else { return false }
        return await AVAudioApplication.requestRecordPermission()
    }
}
