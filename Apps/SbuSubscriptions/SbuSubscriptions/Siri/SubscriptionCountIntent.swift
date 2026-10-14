import AppIntents
import SwiftData

/// "Quanti abbonamenti ho?": the ones you're paying, not paused, cancelled or paid off.
struct SubscriptionCountIntent: AppIntent {
    static let title: LocalizedStringResource = "Numero di abbonamenti"
    static let description = IntentDescription("Dice quanti abbonamenti stai pagando.")
    /// What you pay is private: from a locked iPhone, Siri asks to unlock before it answers.
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Dependency private var container: ModelContainer

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Int> & ProvidesDialog {
        let count = SubscriptionAnswers.count(try ModelContext(container).fetch(FetchDescriptor<Subscription>()))
        return .result(value: count, dialog: "Stai pagando ^[\(count) abbonamento](inflect: true).")
    }
}
