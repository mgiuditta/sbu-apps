import Foundation

/// A lesson as the timetable needs it: which weekday, from when to when.
nonisolated struct LessonSlot: Hashable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let room: String
    /// `Calendar` weekday: 1 is Sunday, 2 Monday, up to 7 Saturday.
    let weekday: Int
    let start: ClockTime
    let end: ClockTime

    /// Whether the two lessons share at least a minute on the same day; touching ends do not overlap.
    func overlaps(_ other: LessonSlot) -> Bool {
        weekday == other.weekday && start < other.end && other.start < end
    }

    /// The lessons of one weekday, earliest first.
    static func day(_ weekday: Int, in slots: [LessonSlot]) -> [LessonSlot] {
        slots.filter { $0.weekday == weekday }.sorted { ($0.start, $0.title) < ($1.start, $1.title) }
    }

    /// The weekdays in the order of the calendar's week: Monday first in Italy, Sunday first in the US.
    static func weekdays(calendar: Calendar) -> [Int] {
        (0..<7).map { (calendar.firstWeekday - 1 + $0) % 7 + 1 }
    }
}
