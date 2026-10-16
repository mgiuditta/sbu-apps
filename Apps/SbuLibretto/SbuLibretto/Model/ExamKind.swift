/// Whether an exam ends with a grade or with an idoneità.
nonisolated enum ExamKind: String, CaseIterable, Codable, Sendable {
    /// A grade from 18 to 30 cum laude, in the averages.
    case graded
    /// Passed or not: its credits count, it stays out of the averages.
    case passFail
}
