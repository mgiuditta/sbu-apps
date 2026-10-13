import AppIntents
import Foundation
import WidgetKit

/// Reads the shared habits file for the chosen habit, or the first one still to do today, and
/// works out what `insight` draws, until the next day starts.
struct HabitInsightProvider: AppIntentTimelineProvider {
    let insight: HabitInsight

    func placeholder(in context: Context) -> HabitInsightEntry {
        .sample(insight)
    }

    func snapshot(for configuration: ChooseHabitIntent, in context: Context) async -> HabitInsightEntry {
        let entry = entry(for: WidgetFile.load(), chosen: configuration.habit, now: .now)
        // The gallery shows a real habit when there is one, a sample otherwise.
        return entry.content == nil && context.isPreview ? .sample(insight) : entry
    }

    func timeline(for configuration: ChooseHabitIntent, in context: Context) async -> Timeline<HabitInsightEntry> {
        let now = Date.now
        let file = WidgetFile.load()
        // The app and the intent reload the widgets on every change; this covers the new day.
        return Timeline(entries: [entry(for: file, chosen: configuration.habit, now: now)], policy: .after(WidgetFile.nextDayStart(for: file, after: now)))
    }

    private func entry(for file: HabitsFile, chosen: HabitEntity?, now: Date) -> HabitInsightEntry {
        let calendar = Calendar.current
        let today = LogicalDay(now, startHour: file.startHour, calendar: calendar)
        return HabitInsightEntry(date: now, content: HabitInsightContent(habits: file.habits, chosen: chosen?.id, insight: insight, today: today, firstWeekday: calendar.firstWeekday))
    }
}
