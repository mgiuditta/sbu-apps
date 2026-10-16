import Foundation
import SwiftData

/// One exam of the libretto: taken with a grade, passed as an idoneità, or still to take.
///
/// Without a grade it is still to take, and its date is the planned sitting.
@Model
final class Exam {
    var id = UUID()
    var name = ""
    /// CFU, decimals allowed: 7.5 is a real exam.
    var credits = 6.0
    /// Year of the course it belongs to, from 1.
    var courseYear = 1
    var kindRaw = ExamKind.graded.rawValue
    /// 18 to 30; 0 while it is still to take.
    var mark = 0
    var cumLaude = false
    /// For an idoneità: whether it is passed.
    var isPassed = false
    /// When it was taken, or the planned sitting while it is still to take.
    var date: Date?
    var createdAt = Date.now

    init(name: String, credits: Double, courseYear: Int, kind: ExamKind, grade: Grade? = nil, isPassed: Bool = false, date: Date?) {
        self.name = name
        self.credits = credits
        self.courseYear = courseYear
        kindRaw = kind.rawValue
        mark = grade?.mark ?? 0
        cumLaude = grade?.isCumLaude ?? false
        self.isPassed = isPassed
        self.date = date
    }

    var kind: ExamKind {
        get { ExamKind(rawValue: kindRaw) ?? .graded }
        set { kindRaw = newValue.rawValue }
    }

    var grade: Grade? {
        get { Grade(mark: mark, cumLaude: cumLaude) }
        set {
            mark = newValue?.mark ?? 0
            cumLaude = newValue?.isCumLaude ?? false
        }
    }

    var result: ExamResult {
        switch kind {
        case .passFail: isPassed ? .passed : .pending
        case .graded: grade.map(ExamResult.graded) ?? .pending
        }
    }

    var record: ExamRecord {
        ExamRecord(id: id, credits: credits, result: result, date: date)
    }
}
