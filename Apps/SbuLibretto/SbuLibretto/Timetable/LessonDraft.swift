import Foundation

/// What the lesson form edits, until it can be saved.
nonisolated struct LessonDraft: Equatable, Sendable {
    enum Problem: Equatable, Sendable {
        case missingTitle
        /// The end is not after the start: a lesson over midnight is two lessons.
        case endNotAfterStart
    }

    var title = ""
    var room = ""
    var weekday: Int
    var start: ClockTime
    var end: ClockTime

    init(weekday: Int, start: ClockTime = ClockTime(hour: 9, minute: 0), end: ClockTime = ClockTime(hour: 11, minute: 0)) {
        self.weekday = min(max(weekday, 1), 7)
        self.start = start
        self.end = end
    }

    @MainActor
    init(lesson: Lesson) {
        self.init(weekday: lesson.weekday, start: ClockTime(minutes: lesson.startMinutes), end: ClockTime(minutes: lesson.endMinutes))
        title = lesson.title
        room = lesson.room
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var problem: Problem? {
        if trimmedTitle.isEmpty { return .missingTitle }
        if end <= start { return .endNotAfterStart }
        return nil
    }

    func slot(id: UUID) -> LessonSlot {
        LessonSlot(id: id, title: trimmedTitle, room: room.trimmingCharacters(in: .whitespacesAndNewlines), weekday: weekday, start: start, end: end)
    }

    /// The other lessons this one would overlap: a hint, as two courses can share a slot.
    func overlaps(id: UUID, among slots: [LessonSlot]) -> [LessonSlot] {
        let mine = slot(id: id)
        return slots.filter { $0.id != id && $0.overlaps(mine) }
    }

    @MainActor
    func apply(to lesson: Lesson) {
        lesson.title = trimmedTitle
        lesson.room = room.trimmingCharacters(in: .whitespacesAndNewlines)
        lesson.weekday = weekday
        lesson.startMinutes = start.minutes
        lesson.endMinutes = end.minutes
    }
}
