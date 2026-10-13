import AppIntents

/// Pauses the sound that is playing.
struct PauseSoundIntent: AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Metti in pausa il suono"

    @MainActor
    func perform() async throws -> some IntentResult {
        PlaybackCommands.send(.pause)
        return .result()
    }
}
