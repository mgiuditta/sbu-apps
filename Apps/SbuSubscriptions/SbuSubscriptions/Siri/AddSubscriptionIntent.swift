import AppIntents

/// Opens the app on the add sheet.
struct AddSubscriptionIntent: AppIntent {
    static let title: LocalizedStringResource = "Aggiungi un abbonamento"
    static let openAppWhenRun = true

    @Dependency private var router: AppRouter

    @MainActor
    func perform() async throws -> some IntentResult {
        router.open(.add)
        return .result()
    }
}
