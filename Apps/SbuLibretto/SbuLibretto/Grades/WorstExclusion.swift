/// Which of the worst grades leave the averages, as some degree courses allow.
///
/// MyLibretto calls it "CFU eliminabili". Grades leave whole, lowest first; an exam that would
/// overrun the credits still left is skipped and the next one is tried. The last graded exam never leaves.
nonisolated enum WorstExclusion: Hashable, Codable, Sendable {
    /// Every grade counts.
    case none
    /// The worst grades, up to this many credits in all.
    case credits(Double)
    /// This many worst grades.
    case exams(Int)
}
