import AppIntents
import Foundation

/// Pauses the countdown of an Abitudine a tempo from its Live Activity. Runs in the app's
/// process, which keeps the countdown, its notification and its activity.
struct PauseTimerIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Metti in pausa il timer"
    // Backs the Live Activity's button only; it does not belong in the Shortcuts library.
    static let isDiscoverable = false

    @Parameter(title: "Abitudine")
    var habitID: String

    init() {}

    init(habitID: UUID) {
        self.habitID = habitID.uuidString
    }

    func perform() async throws -> some IntentResult {
        await TimerControl.setPaused(true, habitID: habitID)
        return .result()
    }
}
