import Foundation
import Testing
@testable import SbuLibretto

struct TranscriptTests {
    nonisolated struct Case: CustomTestStringConvertible, Sendable {
        let name: String
        let exams: [ExamRecord]
        var rules = GradeRules.standard
        let weighted: Double?
        let arithmetic: Double?
        var testDescription: String { name }
    }

    nonisolated static let cases: [Case] = [
        Case(name: "libretto vuoto", exams: [], weighted: nil, arithmetic: nil),
        Case(name: "solo esami da sostenere", exams: [.pending(9), .pending(6)], weighted: nil, arithmetic: nil),
        Case(name: "solo idoneità", exams: [.passed(3), .passed(6)], weighted: nil, arithmetic: nil),
        Case(name: "un esame", exams: [.graded(27, 6)], weighted: 27, arithmetic: 27),
        Case(name: "ponderata e aritmetica divergono", exams: [.graded(30, 12), .graded(18, 3)], weighted: 27.6, arithmetic: 24),
        Case(name: "CFU decimali", exams: [.graded(30, 7.5), .graded(24, 2.5)], weighted: 28.5, arithmetic: 27),
        Case(name: "CFU fuori dal 3-12", exams: [.graded(28, 1), .graded(22, 30)], weighted: 688.0 / 31.0, arithmetic: 25),
        Case(name: "idoneità e da sostenere fuori dalla media", exams: [.graded(26, 6), .passed(3), .pending(12)], weighted: 26, arithmetic: 26),
        Case(name: "lode a 30", exams: [.graded(31, 6), .graded(24, 6)], weighted: 27, arithmetic: 27),
        Case(name: "lode a 33", exams: [.graded(31, 6), .graded(24, 6)], rules: .with { $0.cumLaudeValue = 33 }, weighted: 28.5, arithmetic: 28.5),
        Case(name: "CFU negativi, zero, infiniti e non numeri ignorati",
             exams: [.graded(28, 6), .graded(18, -6), .graded(18, 0), .graded(18, .infinity), .graded(18, .nan)], weighted: 28, arithmetic: 28),
        Case(name: "CFU eliminabili: il peggiore esce intero", exams: [.graded(18, 6), .graded(20, 6), .graded(28, 12), .graded(30, 12)],
             rules: .with { $0.exclusion = .credits(10) }, weighted: 27.2, arithmetic: 26),
        Case(name: "CFU eliminabili: due peggiori", exams: [.graded(18, 6), .graded(20, 6), .graded(28, 12), .graded(30, 12)],
             rules: .with { $0.exclusion = .credits(12) }, weighted: 29, arithmetic: 29),
        Case(name: "CFU eliminabili: chi non entra si salta", exams: [.graded(18, 12), .graded(19, 6), .graded(28, 6)],
             rules: .with { $0.exclusion = .credits(10) }, weighted: (18.0 * 12 + 28 * 6) / 18, arithmetic: 23),
        Case(name: "CFU eliminabili: a parità di voto esce il più grande", exams: [.graded(18, 6), .graded(18, 9), .graded(30, 9)],
             rules: .with { $0.exclusion = .credits(9) }, weighted: (18.0 * 6 + 30 * 9) / 15, arithmetic: 24),
        Case(name: "esami eliminabili", exams: [.graded(18, 6), .graded(20, 6), .graded(28, 12), .graded(30, 12)],
             rules: .with { $0.exclusion = .exams(1) }, weighted: 27.2, arithmetic: 26),
        Case(name: "l'ultimo esame non esce mai", exams: [.graded(18, 6)], rules: .with { $0.exclusion = .credits(60) }, weighted: 18, arithmetic: 18),
        Case(name: "tutti esclusi tranne il migliore", exams: [.graded(18, 6), .graded(25, 6), .graded(22, 6)],
             rules: .with { $0.exclusion = .exams(50) }, weighted: 25, arithmetic: 25),
        Case(name: "le idoneità non si eliminano", exams: [.passed(3), .graded(28, 6), .graded(26, 6)],
             rules: .with { $0.exclusion = .credits(3) }, weighted: 27, arithmetic: 27),
    ]

    @Test(arguments: cases)
    func averages(_ example: Case) throws {
        let transcript = Transcript(example.exams, rules: example.rules)
        try Self.expect(transcript.weightedAverage, example.weighted)
        try Self.expect(transcript.arithmeticAverage, example.arithmetic)
        #expect((transcript.base == nil) == (example.weighted == nil))
    }

    @Test func earnedCreditsCountIdoneitàAndExcludedGrades() {
        let transcript = Transcript([.graded(18, 6), .graded(30, 7.5), .passed(3), .pending(9), .pending(6), .graded(25, -3)],
                                    rules: .with { $0.exclusion = .credits(6); $0.totalCredits = 180 })
        #expect(transcript.excludedIDs.count == 1)
        #expect(transcript.earnedCredits == 16.5)
        #expect(transcript.plannedCount == 2)
        #expect(transcript.plannedCredits == 15)
        #expect(abs(transcript.progress - 16.5 / 180) < 1e-12)
    }

    @Test func progressNeverPassesTheWhole() {
        let transcript = Transcript([.graded(28, 200)], rules: .with { $0.totalCredits = 180 })
        #expect(transcript.progress == 1)
        #expect(Transcript([], rules: .standard).progress == 0)
    }

    @Test func theTrendFollowsTheDatesNotTheOrderOfEntry() throws {
        let transcript = Transcript([.graded(30, 6, day: 20), .graded(24, 6, day: 10), .pending(6), .graded(27, 12, day: 30)], rules: .standard)
        #expect(transcript.trend.map(\.average) == [24, 27, 27])
        let change = try #require(transcript.lastChange)
        #expect(change == 0)
    }

    @Test func undatedGradesComeFirstInTheOrderGiven() {
        let transcript = Transcript([.graded(30, 6, day: 5), .graded(20, 6), .graded(26, 6)], rules: .standard)
        #expect(transcript.trend.map(\.average) == [20, 23, 76.0 / 3.0])
    }

    @Test func theLastChangeIsWhatTheNewestGradeDid() throws {
        let transcript = Transcript([.graded(28, 12, day: 0), .graded(30, 6, day: 1)], rules: .standard)
        let change = try #require(transcript.lastChange)
        #expect(abs(change - (28 * 12 + 30 * 6) / 18.0 + 28) < 1e-12)
        #expect(Transcript([.graded(28, 12)], rules: .standard).lastChange == nil)
        #expect(Transcript([], rules: .standard).lastChange == nil)
    }

    @Test func theTrendAppliesTheExclusionAtEveryStep() {
        let transcript = Transcript([.graded(18, 6, day: 0), .graded(30, 6, day: 1), .graded(28, 6, day: 2)],
                                    rules: .with { $0.exclusion = .exams(1) })
        // First: the only exam stays. Then the 18 leaves. Then still only the 18.
        #expect(transcript.trend.map(\.average) == [18, 30, 29])
    }

    @Test func rulesAreSanitizedBeforeUse() throws {
        let transcript = Transcript([.graded(31, 6)], rules: .with { $0.cumLaudeValue = .nan; $0.conversionFactor = -1 })
        #expect(transcript.weightedAverage == 30)
        let base = try #require(transcript.base)
        #expect(base.value == 3)
    }

    private static func expect(_ actual: Double?, _ expected: Double?, sourceLocation: SourceLocation = #_sourceLocation) throws {
        if let expected {
            let actual = try #require(actual, sourceLocation: sourceLocation)
            #expect(abs(actual - expected) < 1e-9, "\(actual) ≠ \(expected)", sourceLocation: sourceLocation)
        } else {
            #expect(actual == nil, sourceLocation: sourceLocation)
        }
    }
}
