/// Where an exam stands: still to take, taken with a grade, or passed without one.
nonisolated enum ExamResult: Hashable, Sendable {
    /// Not taken yet: planned, it counts nowhere but in the planned exams.
    case pending
    /// Taken with a grade: it counts in the averages and in the credits.
    case graded(Grade)
    /// An idoneità passed: its credits count, it stays out of the averages.
    case passed

    var grade: Grade? {
        if case let .graded(grade) = self { grade } else { nil }
    }

    /// Whether its credits are earned.
    var isDone: Bool {
        self != .pending
    }
}
