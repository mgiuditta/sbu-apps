import Foundation
import SwiftData
import Testing
@testable import SbuLibretto

struct ExamModelTests {
    /// Models are made with a container loaded, as in the app.
    let container: ModelContainer

    init() throws {
        container = try ModelContainer.libretto(inMemory: true)
    }

    @Test func aGradedExamWithoutAGradeIsStillToTake() {
        let exam = Exam(name: "Fisica", credits: 9, courseYear: 1, kind: .graded, date: nil)
        #expect(exam.result == .pending)
        exam.grade = .mark(27)
        #expect(exam.result == .graded(.mark(27)))
        exam.grade = .cumLaude
        #expect(exam.mark == 30)
        #expect(exam.cumLaude)
        exam.grade = nil
        #expect(exam.mark == 0)
        #expect(!exam.cumLaude)
        #expect(exam.result == .pending)
    }

    @Test func anIdoneitàIsPassedOrStillToTake() {
        let exam = Exam(name: "Inglese", credits: 3, courseYear: 1, kind: .passFail, date: nil)
        #expect(exam.result == .pending)
        exam.isPassed = true
        #expect(exam.result == .passed)
        // A grade left over from before the switch to idoneità never counts.
        exam.mark = 28
        #expect(exam.result == .passed)
    }

    @Test(arguments: [(0, false), (17, false), (31, false), (29, true), (-1, false)])
    func aStoredMarkOutsideTheRangeIsNoGrade(_ mark: Int, _ cumLaude: Bool) {
        let exam = Exam(name: "Corrotto", credits: 6, courseYear: 1, kind: .graded, date: nil)
        exam.mark = mark
        exam.cumLaude = cumLaude
        #expect(exam.grade == nil)
        #expect(exam.result == .pending)
    }

    @Test func anUnknownKindReadsAsGraded() {
        let exam = Exam(name: "X", credits: 6, courseYear: 1, kind: .passFail, date: nil)
        exam.kindRaw = "laboratorio"
        #expect(exam.kind == .graded)
    }

    @Test func theRecordCarriesWhatTheCalculationsNeed() {
        let date = Date(timeIntervalSince1970: 1_000)
        let exam = Exam(name: "Analisi", credits: 7.5, courseYear: 2, kind: .graded, grade: .mark(25), date: date)
        let record = exam.record
        #expect(record.id == exam.id)
        #expect(record.credits == 7.5)
        #expect(record.result == .graded(.mark(25)))
        #expect(record.date == date)
    }

    @Test func theSampleLibrettoAddsUp() throws {
        SampleLibretto.insert(into: container.mainContext, now: Date(timeIntervalSince1970: 1_790_000_000))
        let exams = try container.mainContext.fetch(FetchDescriptor<Exam>())
        #expect(exams.count == 11)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<Lesson>()) == 5)
        let transcript = Transcript(exams.map(\.record), rules: .standard)
        let average = try #require(transcript.weightedAverage)
        #expect(abs(average - 1_833.0 / 66) < 1e-9)
        #expect(transcript.earnedCredits == 69)
        #expect(transcript.plannedCount == 3)
        #expect(transcript.plannedCredits == 24)
    }
}
