import Foundation
import WidgetKit

/// What a one-habit widget of Streaks shows at one moment, already worked out.
struct HabitInsightEntry: TimelineEntry {
    let date: Date
    /// `nil` when there is no habit to show.
    let content: HabitInsightContent?

    /// A habit two months old, done most days, for the gallery and the placeholder.
    static func sample(_ insight: HabitInsight) -> HabitInsightEntry {
        let today = LogicalDay(.now)
        var reading = Habit(title: String(localized: "Leggere"), symbol: "book", createdOn: today - 60)
        for daysAgo in 0..<60 where daysAgo % 7 != 4 && daysAgo % 11 != 9 {
            reading.log[today - daysAgo] = 1
        }
        return HabitInsightEntry(date: .now, content: HabitInsightContent(habits: [reading], chosen: reading.id, insight: insight, today: today, firstWeekday: Calendar.current.firstWeekday))
    }
}
