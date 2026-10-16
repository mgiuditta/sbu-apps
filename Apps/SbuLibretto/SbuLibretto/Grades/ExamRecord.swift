import Foundation

/// The part of an exam the calculations need, as a value: credits, result and date.
nonisolated struct ExamRecord: Hashable, Identifiable, Sendable {
    var id = UUID()
    /// CFU, decimals allowed. A record with credits that are not a positive finite number counts nowhere.
    var credits: Double
    var result: ExamResult
    /// When it was taken, or the planned sitting; `nil` when unknown.
    var date: Date?

    /// Whether the credits are a number the calculations can use.
    var hasValidCredits: Bool {
        credits.isFinite && credits > 0
    }
}
