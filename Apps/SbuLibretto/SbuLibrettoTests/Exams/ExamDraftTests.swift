import Foundation
import SwiftData
import Testing
@testable import SbuLibretto

struct ExamDraftTests {
    nonisolated static let italian = Locale(identifier: "it_IT")
    nonisolated static let english = Locale(identifier: "en_US")
    nonisolated static let now = Date(timeIntervalSince1970: 1_790_000_000)
    nonisolated static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome") ?? .gmt
        return calendar
    }()

    /// Models are made with a container loaded, as in the app.
    let container: ModelContainer

    init() throws {
        container = try ModelContainer.libretto(inMemory: true)
    }

    nonisolated static func draft(name: String = "Analisi I", credits: String = "6", taken: Bool = true,
                                  date: Date = now, kind: ExamKind = .graded) -> ExamDraft {
        var draft = ExamDraft(isTaken: taken, now: now)
        draft.name = name
        draft.creditsText = credits
        draft.date = date
        draft.kind = kind
        return draft
    }

    nonisolated struct Case: CustomTestStringConvertible, Sendable {
        let name: String
        let draft: ExamDraft
        var locale = ExamDraftTests.italian
        let problem: ExamDraft.Problem?
        var testDescription: String { name }
    }

    nonisolated static let cases: [Case] = [
        Case(name: "valido", draft: draft(), problem: nil),
        Case(name: "nome vuoto", draft: draft(name: ""), problem: .missingName),
        Case(name: "nome di soli spazi", draft: draft(name: "  \n "), problem: .missingName),
        Case(name: "CFU vuoti", draft: draft(credits: ""), problem: .missingCredits),
        Case(name: "CFU di soli spazi", draft: draft(credits: "   "), problem: .missingCredits),
        Case(name: "CFU non numero", draft: draft(credits: "sei"), problem: .invalidCredits),
        Case(name: "CFU con due virgole", draft: draft(credits: "7,,5"), problem: .invalidCredits),
        Case(name: "CFU decimali con virgola", draft: draft(credits: "7,5"), problem: nil),
        Case(name: "CFU decimali col punto in italiano", draft: draft(credits: "7.5"), problem: nil),
        Case(name: "CFU decimali in inglese", draft: draft(credits: "7.5"), locale: english, problem: nil),
        Case(name: "CFU a zero", draft: draft(credits: "0"), problem: .creditsOutOfRange),
        Case(name: "CFU negativi", draft: draft(credits: "-6"), problem: .creditsOutOfRange),
        Case(name: "CFU sotto il mezzo", draft: draft(credits: "0,4"), problem: .creditsOutOfRange),
        Case(name: "mezzo CFU", draft: draft(credits: "0,5"), problem: nil),
        Case(name: "un CFU", draft: draft(credits: "1"), problem: nil),
        Case(name: "60 CFU", draft: draft(credits: "60"), problem: nil),
        Case(name: "61 CFU", draft: draft(credits: "61"), problem: .creditsOutOfRange),
        Case(name: "CFU assurdi", draft: draft(credits: "1000000"), problem: .creditsOutOfRange),
        Case(name: "voto con data di domani", draft: draft(date: now.addingTimeInterval(86_400 * 2)), problem: .futureDate),
        Case(name: "voto di stasera", draft: draft(date: calendar.date(bySettingHour: 23, minute: 59, second: 0, of: now) ?? now), problem: nil),
        Case(name: "da sostenere con data futura", draft: draft(taken: false, date: now.addingTimeInterval(86_400 * 30)), problem: nil),
        Case(name: "idoneità futura superata", draft: draft(taken: true, date: now.addingTimeInterval(86_400 * 3), kind: .passFail), problem: .futureDate),
        Case(name: "voto di anni fa", draft: draft(date: now.addingTimeInterval(-86_400 * 3_000)), problem: nil),
    ]

    @Test(arguments: cases)
    func problems(_ example: Case) {
        #expect(example.draft.problem(locale: example.locale, now: Self.now, calendar: Self.calendar) == example.problem)
    }

    @Test func aNewTakenExamIsDatedTodayAndAPlannedOneHasNoDate() {
        let taken = ExamDraft(isTaken: true, now: Self.now)
        #expect(taken.hasDate)
        #expect(taken.date == Self.now)
        let planned = ExamDraft(isTaken: false, now: Self.now)
        #expect(!planned.hasDate)
    }

    @Test(arguments: [(30, true, Grade.cumLaude), (30, false, .mark(30)), (29, true, .mark(29)), (18, false, .mark(18))])
    func cumLaudeOnlyCountsOnThirty(_ mark: Int, _ cumLaude: Bool, _ expected: Grade) {
        var draft = Self.draft()
        draft.mark = mark
        draft.cumLaude = cumLaude
        #expect(draft.grade == expected)
    }

    @Test func notTakenOrIdoneitàHasNoGrade() {
        var draft = Self.draft(taken: false)
        #expect(draft.grade == nil)
        draft = Self.draft(kind: .passFail)
        #expect(draft.grade == nil)
    }

    @Test func savingAGradeWritesTheExam() {
        var draft = Self.draft(name: "  Basi di dati  ", credits: "7,5")
        draft.mark = 30
        draft.cumLaude = true
        draft.courseYear = 2
        let exam = Exam(name: "", credits: 0, courseYear: 1, kind: .graded, date: nil)
        draft.apply(to: exam, locale: Self.italian)
        #expect(exam.name == "Basi di dati")
        #expect(exam.credits == 7.5)
        #expect(exam.courseYear == 2)
        #expect(exam.result == .graded(.cumLaude))
        #expect(exam.date == Self.now)
    }

    @Test func aPlannedExamWithoutDateLosesItsDate() {
        var draft = Self.draft(taken: false)
        draft.hasDate = false
        let exam = Exam(name: "", credits: 0, courseYear: 1, kind: .graded, grade: .mark(27), date: Self.now)
        draft.apply(to: exam, locale: Self.italian)
        #expect(exam.result == .pending)
        #expect(exam.date == nil)
        #expect(exam.mark == 0)
    }

    @Test func switchingToIdoneitàClearsTheGrade() {
        var draft = Self.draft(kind: .passFail)
        draft.mark = 28
        let exam = Exam(name: "", credits: 0, courseYear: 1, kind: .graded, grade: .mark(28), date: Self.now)
        draft.apply(to: exam, locale: Self.italian)
        #expect(exam.kind == .passFail)
        #expect(exam.result == .passed)
        #expect(exam.mark == 0)
    }

    @Test func editingRoundTripsTheExam() {
        let exam = Exam(name: "Fisica", credits: 7.5, courseYear: 9, kind: .graded, grade: .cumLaude, date: Self.now)
        let draft = ExamDraft(exam: exam, now: Self.now, locale: Self.italian)
        #expect(draft.name == "Fisica")
        #expect(draft.creditsText == "7,5")
        // A year out of the stepper's range comes back into it.
        #expect(draft.courseYear == 6)
        #expect(draft.grade == .cumLaude)
        #expect(draft.isTaken)
        #expect(draft.hasDate)
        #expect(draft.problem(locale: Self.italian, now: Self.now, calendar: Self.calendar) == nil)
    }

    @Test func editingAPlannedExamWithoutDateKeepsItUndated() {
        let exam = Exam(name: "Reti", credits: 6, courseYear: 2, kind: .graded, date: nil)
        let draft = ExamDraft(exam: exam, now: Self.now, locale: Self.english)
        #expect(!draft.isTaken)
        #expect(!draft.hasDate)
        #expect(draft.creditsText == "6")
    }
}
