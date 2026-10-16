import Foundation

/// What the next exam does to the average: one row per grade, and the grade a target needs.
///
/// The next exam is added as the newest graded one under the same rules, worst-grade exclusion
/// included, so the table shows exactly what the libretto will show after it.
nonisolated struct Simulation: Sendable {
    /// The credits a simulated exam may have.
    static let creditsRange = 0.5...60.0

    let records: [ExamRecord]
    let rules: GradeRules
    /// CFU of the next exam.
    let credits: Double
    /// The newest moment among the records, so the simulated exam always comes last.
    private let after: Date

    init(_ records: [ExamRecord], rules: GradeRules, credits: Double) {
        self.records = records
        self.rules = rules
        self.credits = credits
        after = records.compactMap(\.date).max() ?? .distantPast
    }

    /// Whether `credits` is a number of CFU an exam can have.
    var hasValidCredits: Bool {
        credits.isFinite && Self.creditsRange.contains(credits)
    }

    /// The current weighted average, before the next exam.
    var currentAverage: Double? {
        Transcript(records, rules: rules).weightedAverage
    }

    /// From 30 cum laude down to 18; empty when the credits are not valid.
    var rows: [SimulationRow] {
        guard hasValidCredits else { return [] }
        let current = currentAverage
        return Grade.descending.compactMap { grade in
            let transcript = transcript(with: grade)
            guard let average = transcript.weightedAverage, let base = transcript.base else { return nil }
            return SimulationRow(grade: grade, average: average, change: current.map { average - $0 }, base: base)
        }
    }

    /// The lowest grade that brings the weighted average to `target` or above, or `nil` when the
    /// credits or the target are not numbers.
    func requiredGrade(forAverage target: Double) -> RequiredGrade? {
        guard hasValidCredits, target.isFinite else { return nil }
        // Within a millionth: 27.999999 from the arithmetic reaches a target of 28.
        let reaching = Grade.ascending.first { grade in
            (transcript(with: grade).weightedAverage ?? -.infinity) >= target - 1e-6
        }
        switch reaching {
        case nil: return .unreachable
        case Grade.ascending.first: return .anyGrade
        case let grade?: return .atLeast(grade)
        }
    }

    private func transcript(with grade: Grade) -> Transcript {
        let next = ExamRecord(credits: credits, result: .graded(grade), date: after == .distantPast ? nil : after.addingTimeInterval(1))
        return Transcript(records + [next], rules: rules)
    }
}
