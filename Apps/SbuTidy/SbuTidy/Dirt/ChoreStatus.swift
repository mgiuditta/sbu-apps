/// Where a chore stands today, always said with a word next to any color.
nonisolated enum ChoreStatus: Equatable, Sendable {
    /// Not due yet.
    case clean
    /// Due today.
    case due
    /// Past its day.
    case overdue
    /// Paused: dirt does not grow and it never shows up as to do.
    case paused

    /// Due today or late: it belongs in the to-do list.
    var isToDo: Bool { self == .due || self == .overdue }
}
