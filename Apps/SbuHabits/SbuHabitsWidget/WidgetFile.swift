import Foundation

/// The shared habits file as the widgets read it.
enum WidgetFile {
    static func load() -> HabitsFile {
        (try? HabitsStore.shared.load()) ?? HabitsFile()
    }

    /// When the next logical day starts: the moment a widget's grid has to move on.
    static func nextDayStart(for file: HabitsFile, after now: Date) -> Date {
        let calendar = Calendar.current
        let tomorrow = LogicalDay(now, startHour: file.startHour, calendar: calendar) + 1
        let noon = tomorrow.noon(in: calendar)
        return calendar.date(bySettingHour: file.startHour, minute: 0, second: 0, of: noon) ?? noon
    }
}
