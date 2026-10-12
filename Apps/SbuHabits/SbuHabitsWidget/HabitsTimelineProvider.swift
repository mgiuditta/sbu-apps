import Foundation
import WidgetKit

/// Reads the shared habits file and shows today's grid until the next day starts.
struct HabitsTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitsWidgetEntry {
        .sample
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitsWidgetEntry) -> Void) {
        let entry = Self.entry(now: .now)
        // The gallery shows real habits when there are some, sample ones otherwise.
        completion(entry.habits.isEmpty && context.isPreview ? .sample : entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitsWidgetEntry>) -> Void) {
        let now = Date.now
        // The app and the intent reload the widget on every change; this covers the new day.
        completion(Timeline(entries: [Self.entry(now: now)], policy: .after(Self.nextDayStart(after: now))))
    }

    private static func entry(now: Date) -> HabitsWidgetEntry {
        let file = (try? HabitsStore.shared.load()) ?? HabitsFile()
        let calendar = Calendar.current
        let today = LogicalDay(now, startHour: file.startHour, calendar: calendar)
        let habits = Array(TodayGrid.habits(file.habits, on: today, firstWeekday: calendar.firstWeekday).prefix(8))
        return HabitsWidgetEntry(
            date: now,
            habits: habits,
            progress: Dictionary(uniqueKeysWithValues: habits.map { ($0.id, HabitProgress(of: $0, today: today, firstWeekday: calendar.firstWeekday)) })
        )
    }

    private static func nextDayStart(after now: Date) -> Date {
        let file = (try? HabitsStore.shared.load()) ?? HabitsFile()
        let calendar = Calendar.current
        let tomorrow = LogicalDay(now, startHour: file.startHour, calendar: calendar) + 1
        let noon = tomorrow.noon(in: calendar)
        return calendar.date(bySettingHour: file.startHour, minute: 0, second: 0, of: noon) ?? noon
    }
}
