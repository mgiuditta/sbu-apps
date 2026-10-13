import AppIntents

/// Plays a sound or a mix without opening the app; with none chosen, the one played last.
struct PlaySoundIntent: AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Riproduci un suono"
    static let description = IntentDescription("Riproduce un suono o un mix, o l'ultimo che hai ascoltato.")

    @Parameter(title: "Suono")
    var sound: NoiseItemEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Riproduci \(\.$sound)")
    }

    init() {}

    init(sound: NoiseItemEntity) {
        self.sound = sound
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        PlaybackCommands.send(.play(itemID: sound?.id))
        return .result()
    }
}
