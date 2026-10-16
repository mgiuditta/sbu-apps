import AppIntents

struct PlayPauseIntent: AppIntent {
    static let title: LocalizedStringResource = "Riproduci o metti in pausa"
    static let description = IntentDescription("Mette in pausa o fa ripartire quello che guardi sull'ultima TV usata.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: await RemoteKeyIntent.press(.playPause))
    }
}
