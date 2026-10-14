import AppIntents

/// Opens one subscription's detail; also what a tap on it in Spotlight does.
struct OpenSubscriptionIntent: OpenIntent {
    static let title: LocalizedStringResource = "Apri un abbonamento"

    @Parameter(title: "Abbonamento")
    var target: SubscriptionEntity

    @Dependency private var router: AppRouter

    @MainActor
    func perform() async throws -> some IntentResult {
        router.open(.subscription(target.id))
        return .result()
    }
}
