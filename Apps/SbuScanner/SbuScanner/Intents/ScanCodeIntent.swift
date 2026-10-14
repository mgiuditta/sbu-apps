import AppIntents

/// Opens Sbu Scanner on the camera, from Shortcuts, Siri, Spotlight or the Action button.
struct ScanCodeIntent: AppIntent {
    static let title: LocalizedStringResource = "Scansiona un codice"
    static let description = IntentDescription("Apre Sbu Scanner con la fotocamera pronta a leggere.")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}
