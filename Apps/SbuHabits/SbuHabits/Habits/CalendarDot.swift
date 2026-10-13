/// One day of the calendar widget.
nonisolated struct CalendarDot: Identifiable, Equatable, Sendable {
    let day: LogicalDay
    let state: CalendarDotState

    var id: LogicalDay { day }
}
