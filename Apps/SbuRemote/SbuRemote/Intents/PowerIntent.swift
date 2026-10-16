import AppIntents

struct PowerIntent: AppIntent {
    static let title: LocalizedStringResource = "Accendi o spegni la TV"
    static let description = IntentDescription("Spegne l'ultima TV usata, o prova ad accenderla se è spenta.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: await RemoteKeyIntent.press(.power))
    }
}
