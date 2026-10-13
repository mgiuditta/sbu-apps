import AppIntents

/// Plays or pauses the sound on screen, from the widget's button and the Control Center control.
/// An audio playback intent, so iOS runs it in the app, which can start the sound in the background.
struct SetPlayingIntent: SetValueIntent, AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Riproduci o metti in pausa"
    // Backs the widget's button and the control only; Riproduci and Metti in pausa are in Comandi rapidi.
    static let isDiscoverable = false

    @Parameter(title: "In riproduzione")
    var value: Bool

    init() {}

    init(isPlaying: Bool) {
        value = isPlaying
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        PlaybackCommands.send(value ? .play(itemID: nil) : .pause)
        return .result()
    }
}
