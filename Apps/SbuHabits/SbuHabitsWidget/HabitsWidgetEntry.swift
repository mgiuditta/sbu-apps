import Foundation
import WidgetKit

/// What the widget shows at one moment: today's habits, already resolved.
struct HabitsWidgetEntry: TimelineEntry {
    let date: Date
    let habits: [Habit]
    let progress: [UUID: HabitProgress]
    /// Each habit's Serie, which VoiceOver reads with its ring.
    let streaks: [UUID: Int]

    /// Stand-in habits for the gallery and the placeholder.
    static var sample: HabitsWidgetEntry {
        let today = LogicalDay(.now)
        var water = Habit(title: String(localized: "Bere acqua"), symbol: "drop", timesPerDay: 8, createdOn: today)
        water.log[today] = 3
        var reading = Habit(title: String(localized: "Leggere"), symbol: "book", createdOn: today)
        reading.log[today] = 1
        let walking = Habit(title: String(localized: "Camminare"), symbol: "figure.walk", createdOn: today)
        let habits = [water, reading, walking]
        return HabitsWidgetEntry(
            date: .now,
            habits: habits,
            progress: Dictionary(uniqueKeysWithValues: habits.map { ($0.id, HabitProgress(of: $0, today: today, firstWeekday: 2)) }),
            streaks: [water.id: 4, reading.id: 12]
        )
    }
}
