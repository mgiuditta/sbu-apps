/// The grade the next exam needs for an average you aim at.
nonisolated enum RequiredGrade: Hashable, Sendable {
    /// Any passing grade keeps you at or above the target.
    case anyGrade
    /// At least this grade.
    case atLeast(Grade)
    /// Not even 30 cum laude gets there with this exam alone.
    case unreachable
}
