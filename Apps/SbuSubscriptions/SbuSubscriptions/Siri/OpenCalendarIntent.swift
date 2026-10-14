import AppIntents

/// Opens the payments calendar.
struct OpenCalendarIntent: AppIntent {
    static let title: LocalizedStringResource = "Apri il calendario dei pagamenti"
    static let openAppWhenRun = true

    @Dependency private var router: AppRouter

    @MainActor
    func perform() async throws -> some IntentResult {
        router.open(.calendar)
        return .result()
    }
}
