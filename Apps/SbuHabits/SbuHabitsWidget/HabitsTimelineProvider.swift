import Foundation
import WidgetKit

/// Reads the shared habits file and shows today's grid until the next day starts.
struct HabitsTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitsWidgetEntry {
        .sample
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitsWidgetEntry) -> Void) {
        let entry = Self.entry(for: Self.load(), now: .now)
        // The gallery shows real habits when there are some, sample ones otherwise.
        completion(entry.habits.isEmpty && context.isPreview ? .sample : entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitsWidgetEntry>) -> Void) {
        let now = Date.now
        let file = Self.load()
        // Each new day's timeline also tops up the reminders, for people who never open the app.
        ReminderScheduler.replace(with: ReminderPlan.reminders(for: file.habits, now: now, startHour: file.startHour, calendar: .current))
        // The app and the intent reload the widget on every change; this covers the new day.
        completion(Timeline(entries: [Self.entry(for: file, now: now)], policy: .after(Self.nextDayStart(for: file, after: now))))
    }

    private static func load() -> HabitsFile {
        (try? HabitsStore.shared.load()) ?? HabitsFile()
    }

    private static func entry(for file: HabitsFile, now: Date) -> HabitsWidgetEntry {
        let calendar = Calendar.current
        let today = LogicalDay(now, startHour: file.startHour, calendar: calendar)
        // All of today's habits: the view picks what fits its size.
        let habits = TodayGrid.habits(file.habits, on: today, firstWeekday: calendar.firstWeekday)
        return HabitsWidgetEntry(
            date: now,
            habits: habits,
            progress: Dictionary(uniqueKeysWithValues: habits.map { ($0.id, HabitProgress(of: $0, today: today, firstWeekday: calendar.firstWeekday)) })
        )
    }

    private static func nextDayStart(for file: HabitsFile, after now: Date) -> Date {
        let calendar = Calendar.current
        let tomorrow = LogicalDay(now, startHour: file.startHour, calendar: calendar) + 1
        let noon = tomorrow.noon(in: calendar)
        return calendar.date(bySettingHour: file.startHour, minute: 0, second: 0, of: noon) ?? noon
    }
}
