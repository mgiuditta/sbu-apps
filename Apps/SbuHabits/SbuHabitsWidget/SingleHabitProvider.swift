import AppIntents
import Foundation
import WidgetKit

/// Reads the shared habits file for the chosen habit, or the first one still to do today.
struct SingleHabitProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SingleHabitEntry {
        .sample
    }

    func snapshot(for configuration: ChooseHabitIntent, in context: Context) async -> SingleHabitEntry {
        let entry = Self.entry(for: WidgetFile.load(), chosen: configuration.habit, now: .now)
        return entry.habit == nil && context.isPreview ? .sample : entry
    }

    func timeline(for configuration: ChooseHabitIntent, in context: Context) async -> Timeline<SingleHabitEntry> {
        let now = Date.now
        let file = WidgetFile.load()
        return Timeline(entries: [Self.entry(for: file, chosen: configuration.habit, now: now)], policy: .after(WidgetFile.nextDayStart(for: file, after: now)))
    }

    private static func entry(for file: HabitsFile, chosen: HabitEntity?, now: Date) -> SingleHabitEntry {
        let calendar = Calendar.current
        let today = LogicalDay(now, startHour: file.startHour, calendar: calendar)
        guard let habit = WidgetChoice.single(file.habits, chosen: chosen?.id, today: today, firstWeekday: calendar.firstWeekday) else {
            return SingleHabitEntry(date: now, habit: nil, progress: nil, streak: 0)
        }
        return SingleHabitEntry(
            date: now,
            habit: habit,
            progress: HabitProgress(of: habit, today: today, firstWeekday: calendar.firstWeekday),
            streak: Streak.current(of: habit, today: today, firstWeekday: calendar.firstWeekday)
        )
    }
}
