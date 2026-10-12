import Foundation
import WidgetKit

/// One habit for the small widget: its ring and its Serie.
struct SingleHabitEntry: TimelineEntry {
    let date: Date
    let habit: Habit?
    let progress: HabitProgress?
    let streak: Int

    static var sample: SingleHabitEntry {
        let today = LogicalDay(.now)
        var reading = Habit(title: String(localized: "Leggere"), symbol: "book", createdOn: today - 30)
        for daysAgo in 1...12 {
            reading.log[today - daysAgo] = 1
        }
        return SingleHabitEntry(date: .now, habit: reading, progress: HabitProgress(of: reading, today: today, firstWeekday: 2), streak: 12)
    }

    /// An Abitudine da evitare gone over its Limite today, for previews.
    static var overLimitSample: SingleHabitEntry {
        let today = LogicalDay(.now)
        var coffee = Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: today - 30)
        coffee.log[today] = 3
        return SingleHabitEntry(date: .now, habit: coffee, progress: HabitProgress(of: coffee, today: today, firstWeekday: 2), streak: 0)
    }
}
