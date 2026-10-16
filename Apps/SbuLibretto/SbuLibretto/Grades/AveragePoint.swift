import Foundation

/// The weighted average right after one graded exam, for the chart of how it went.
nonisolated struct AveragePoint: Hashable, Identifiable, Sendable {
    /// The exam that moved the average here.
    let id: ExamRecord.ID
    let date: Date?
    let average: Double
}
