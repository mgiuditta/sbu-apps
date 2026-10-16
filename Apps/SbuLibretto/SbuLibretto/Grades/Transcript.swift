import Foundation

/// The figures of a libretto under a course's rules: averages, credits, base, and how the average moved.
///
/// Only graded exams with valid credits count in the averages; a passed idoneità counts only in
/// the credits; an exam still to take counts only among the planned ones. Exams with credits that
/// are not a positive finite number count nowhere.
nonisolated struct Transcript: Sendable {
    let rules: GradeRules
    /// The graded exams that count, in the order they were taken.
    let gradedExams: [ExamRecord]
    /// The worst grades left out of the averages under `rules.exclusion`.
    let excludedIDs: Set<ExamRecord.ID>
    /// Credits of graded and passed exams, excluded grades included: they are still earned.
    let earnedCredits: Double
    let plannedCount: Int
    let plannedCredits: Double

    init(_ records: [ExamRecord], rules: GradeRules) {
        let rules = rules.sanitized
        self.rules = rules
        let valid = records.filter(\.hasValidCredits)
        gradedExams = Self.chronological(valid.filter { $0.result.grade != nil })
        excludedIDs = Self.excluded(from: gradedExams, rules: rules)
        earnedCredits = valid.filter(\.result.isDone).reduce(0) { $0 + $1.credits }
        let planned = valid.filter { $0.result == .pending }
        plannedCount = planned.count
        plannedCredits = planned.reduce(0) { $0 + $1.credits }
    }

    /// The graded exams that count in the averages.
    var countedExams: [ExamRecord] {
        gradedExams.filter { !excludedIDs.contains($0.id) }
    }

    /// Σ(grade × credits) / Σ credits, or `nil` before the first grade.
    var weightedAverage: Double? {
        Self.weightedAverage(of: countedExams, rules: rules)
    }

    /// The plain mean of the grades, or `nil` before the first grade.
    var arithmeticAverage: Double? {
        let values = countedExams.compactMap { $0.result.grade?.value(cumLaudeValue: rules.cumLaudeValue) }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    /// The base of the degree grade from the weighted average, or `nil` before the first grade.
    var base: GraduationBase? {
        weightedAverage.map { GraduationBase(weightedAverage: $0, rules: rules) }
    }

    /// Earned credits over the degree's total, from 0 to 1.
    var progress: Double {
        min(max(earnedCredits / rules.totalCredits, 0), 1)
    }

    /// The weighted average after each graded exam, oldest first, under the same rules.
    var trend: [AveragePoint] {
        gradedExams.indices.compactMap { index in
            let taken = Array(gradedExams[...index])
            let excluded = Self.excluded(from: taken, rules: rules)
            guard let average = Self.weightedAverage(of: taken.filter { !excluded.contains($0.id) }, rules: rules) else { return nil }
            return AveragePoint(id: taken[index].id, date: taken[index].date, average: average)
        }
    }

    /// How much the last graded exam moved the weighted average, or `nil` with fewer than two grades.
    var lastChange: Double? {
        let points = trend
        guard points.count >= 2 else { return nil }
        return points[points.count - 1].average - points[points.count - 2].average
    }

    // MARK: - Calculations

    private static func weightedAverage(of exams: [ExamRecord], rules: GradeRules) -> Double? {
        var weighted = 0.0
        var credits = 0.0
        for exam in exams {
            guard let grade = exam.result.grade else { continue }
            weighted += grade.value(cumLaudeValue: rules.cumLaudeValue) * exam.credits
            credits += exam.credits
        }
        return credits > 0 ? weighted / credits : nil
    }

    /// Oldest first; exams without a date first, then in the order given.
    private static func chronological(_ exams: [ExamRecord]) -> [ExamRecord] {
        exams.enumerated().sorted { left, right in
            let leftDate = left.element.date ?? .distantPast
            let rightDate = right.element.date ?? .distantPast
            return leftDate == rightDate ? left.offset < right.offset : leftDate < rightDate
        }
        .map(\.element)
    }

    /// The worst grades first, the larger exam first between equal grades; whole exams only, and
    /// never the last one left. An exam that overruns the credits still allowed is skipped.
    private static func excluded(from exams: [ExamRecord], rules: GradeRules) -> Set<ExamRecord.ID> {
        let worstFirst = exams.enumerated().sorted { left, right in
            let leftValue = left.element.result.grade?.value(cumLaudeValue: rules.cumLaudeValue) ?? 0
            let rightValue = right.element.result.grade?.value(cumLaudeValue: rules.cumLaudeValue) ?? 0
            if leftValue != rightValue { return leftValue < rightValue }
            if left.element.credits != right.element.credits { return left.element.credits > right.element.credits }
            return left.offset < right.offset
        }
        .map(\.element)
        var excluded = Set<ExamRecord.ID>()
        switch rules.exclusion {
        case .none:
            break
        case let .credits(limit):
            var left = limit
            for exam in worstFirst where excluded.count < exams.count - 1 && exam.credits <= left + 1e-9 {
                excluded.insert(exam.id)
                left -= exam.credits
            }
        case let .exams(count):
            for exam in worstFirst.prefix(max(0, min(count, exams.count - 1))) {
                excluded.insert(exam.id)
            }
        }
        return excluded
    }
}
