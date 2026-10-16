import AVFoundation
import Speech

/// The microphone into the on-device recognizer. Off the main actor: the audio tap runs on the
/// audio thread and the recognizer calls back on its own queue.
///
/// `requiresOnDeviceRecognition` keeps every sample on the iPhone: no audio leaves it.
nonisolated enum SpeechPipeline {
    /// Starts listening; `onText` gets the transcript so far and whether it is final.
    static func start(
        recognizer: SFSpeechRecognizer,
        engine: AVAudioEngine,
        onText: @escaping @Sendable (String, Bool) -> Void,
        onFailure: @escaping @Sendable () -> Void
    ) throws -> SFSpeechRecognitionTask {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = true
        request.taskHint = .search

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let input = engine.inputNode
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: input.outputFormat(forBus: 0)) { buffer, _ in
            request.append(buffer)
        }
        engine.prepare()
        try engine.start()

        return recognizer.recognitionTask(with: request) { result, error in
            if let result {
                onText(result.bestTranscription.formattedString, result.isFinal)
            } else if error != nil {
                onFailure()
            }
        }
    }

    static func stop(engine: AVAudioEngine, task: SFSpeechRecognitionTask?) {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        task?.finish()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
