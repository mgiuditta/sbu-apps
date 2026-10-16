import AppIntents

struct MuteIntent: AppIntent {
    static let title: LocalizedStringResource = "Silenzia la TV"
    static let description = IntentDescription("Toglie o rimette l'audio dell'ultima TV usata.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: await RemoteKeyIntent.press(.mute))
    }
}
