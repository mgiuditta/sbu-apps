/// How one day of the month looks in the calendar widget, as Streaks draws it: a full dot for a
/// day done, a cross for a miss, a ring for today still open, a faint dot for the rest.
nonisolated enum CalendarDotState: Equatable, Sendable {
    case done
    /// Expected and not done, or an Abitudine da evitare over its Limite, today too.
    case missed
    case skipped
    /// Today, still open: not done yet, within the Limite, or not expected. It says where today
    /// is in the month.
    case today
    /// Not expected, before the habit began, or still to come.
    case rest
}
