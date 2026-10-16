extension Lesson {
    var slot: LessonSlot {
        LessonSlot(id: id, title: title, room: room, weekday: weekday, start: ClockTime(minutes: startMinutes), end: ClockTime(minutes: endMinutes))
    }
}
