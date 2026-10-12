import AppIntents
import Foundation
import WidgetKit

/// Marks a habit done once today, from the widget; for an Abitudine da evitare, one more time
/// given in, past the Limite too. It only adds: taking a mark back stays in the app, where a slip
/// of the finger is easy to see.
struct MarkHabitIntent: AppIntent {
    static let title: LocalizedStringResource = "Segna come fatta"
    // Backs the widget's buttons only; it does not belong in the Shortcuts library.
    static let isDiscoverable = false

    @Parameter(title: "Abitudine")
    var habitID: String

    init() {}

    init(habitID: UUID) {
        self.habitID = habitID.uuidString
    }

    func perform() async throws -> some IntentResult {
        let file = try Self.mark(habitID, in: .shared, now: .now)
        // Done today: its reminders for today go.
        await ReminderScheduler.replace(with: ReminderPlan.reminders(for: file.habits, now: .now, startHour: file.startHour, calendar: .current))
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }

    /// Marks the habit once on the logical day `now` falls in, and returns the saved file.
    static func mark(_ habitID: String, in store: HabitsStore, now: Date, calendar: Calendar = .current) throws -> HabitsFile {
        var saved = HabitsFile()
        try store.update { file in
            let today = LogicalDay(now, startHour: file.startHour, calendar: calendar)
            if let index = file.habits.firstIndex(where: { $0.id.uuidString == habitID }) {
                file.habits[index].mark(on: today)
            }
            saved = file
        }
        return saved
    }
}
