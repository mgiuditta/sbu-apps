import AppIntents
import Foundation
import WidgetKit

/// Reads the shared habits file and shows the chosen part of today's grid until the next day starts.
struct HabitsTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> HabitsWidgetEntry {
        .sample
    }

    func snapshot(for configuration: ChooseHabitsIntent, in context: Context) async -> HabitsWidgetEntry {
        let entry = Self.entry(for: WidgetFile.load(), chosen: configuration.habits, now: .now)
        // The gallery shows real habits when there are some, sample ones otherwise.
        return entry.habits.isEmpty && context.isPreview ? .sample : entry
    }

    func timeline(for configuration: ChooseHabitsIntent, in context: Context) async -> Timeline<HabitsWidgetEntry> {
        let now = Date.now
        let file = WidgetFile.load()
        // Each new day's timeline also tops up the reminders, for people who never open the app.
        await ReminderScheduler.replace(with: ReminderPlan.reminders(for: file.habits, now: now, startHour: file.startHour, calendar: .current))
        // The app and the intent reload the widget on every change; this covers the new day.
        return Timeline(entries: [Self.entry(for: file, chosen: configuration.habits, now: now)], policy: .after(WidgetFile.nextDayStart(for: file, after: now)))
    }

    private static func entry(for file: HabitsFile, chosen: [HabitEntity], now: Date) -> HabitsWidgetEntry {
        let calendar = Calendar.current
        let today = LogicalDay(now, startHour: file.startHour, calendar: calendar)
        // The view picks what fits its size.
        let habits = WidgetChoice.grid(file.habits, chosen: chosen.map(\.id), today: today, firstWeekday: calendar.firstWeekday)
        return HabitsWidgetEntry(
            date: now,
            habits: habits,
            progress: Dictionary(uniqueKeysWithValues: habits.map { ($0.id, HabitProgress(of: $0, today: today, firstWeekday: calendar.firstWeekday)) })
        )
    }
}
