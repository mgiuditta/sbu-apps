import Foundation
@testable import SbuLibretto

extension ExamRecord {
    nonisolated static func day(_ n: Int) -> Date {
        Date(timeIntervalSince1970: 1_767_225_600 + Double(n) * 86_400)
    }

    /// A graded exam: `mark` 18...30, or 31 for 30 cum laude.
    nonisolated static func graded(_ mark: Int, _ credits: Double, day: Int? = nil) -> ExamRecord {
        let grade: Grade = mark == 31 ? .cumLaude : .mark(mark)
        return ExamRecord(credits: credits, result: .graded(grade), date: day.map(Self.day))
    }

    nonisolated static func passed(_ credits: Double) -> ExamRecord {
        ExamRecord(credits: credits, result: .passed, date: nil)
    }

    nonisolated static func pending(_ credits: Double) -> ExamRecord {
        ExamRecord(credits: credits, result: .pending, date: nil)
    }
}

extension GradeRules {
    nonisolated static func with(_ change: (inout GradeRules) -> Void) -> GradeRules {
        var rules = GradeRules.standard
        change(&rules)
        return rules
    }
}
