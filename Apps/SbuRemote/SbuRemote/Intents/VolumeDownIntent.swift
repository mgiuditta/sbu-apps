import AppIntents

struct VolumeDownIntent: AppIntent {
    static let title: LocalizedStringResource = "Abbassa il volume"
    static let description = IntentDescription("Abbassa il volume dell'ultima TV usata.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: await RemoteKeyIntent.press(.volumeDown))
    }
}
