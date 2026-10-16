import AppIntents

struct VolumeUpIntent: AppIntent {
    static let title: LocalizedStringResource = "Alza il volume"
    static let description = IntentDescription("Alza il volume dell'ultima TV usata.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: await RemoteKeyIntent.press(.volumeUp))
    }
}
