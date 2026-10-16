import Testing
@testable import SbuLibretto

/// The base of the degree grade with the real rules of four universities, from
/// `research/apps/libretto.md`. The same libretto throughout: 30 cum laude in 12 CFU, 28 in 9, 24 in 6,
/// an idoneità of 3 CFU and an exam still to take.
struct UniversityFormulaTests {
    nonisolated static let libretto: [ExamRecord] = [.graded(31, 12), .graded(28, 9), .graded(24, 6), .passed(3), .pending(9)]

    nonisolated struct Case: CustomTestStringConvertible, Sendable {
        let name: String
        var exams = UniversityFormulaTests.libretto
        let rules: GradeRules
        let average: Double
        let unrounded: Double
        let base: Double
        let isAboveMaximum: Bool
        var testDescription: String { name }
    }

    nonisolated static let cases: [Case] = [
        // UniMi, SPES: Σ(voto × CFU) / CFU × 110/30, lode = 33.
        Case(name: "UniMi, lode 33", rules: .with { $0.cumLaudeValue = 33 },
             average: 792.0 / 27, unrounded: 792.0 / 27 * 110 / 30, base: 792.0 / 27 * 110 / 30, isAboveMaximum: false),
        // +1 for Erasmus or a thesis abroad.
        Case(name: "UniMi, lode 33, +1 Erasmus", rules: .with { $0.cumLaudeValue = 33; $0.bonusPoints = 1 },
             average: 792.0 / 27, unrounded: 792.0 / 27 * 110 / 30 + 1, base: 792.0 / 27 * 110 / 30 + 1, isAboveMaximum: false),
        // +3 for graduating on time in the summer or autumn session: past 110, capped.
        Case(name: "UniMi, lode 33, +3 in corso", rules: .with { $0.cumLaudeValue = 33; $0.bonusPoints = 3 },
             average: 792.0 / 27, unrounded: 792.0 / 27 * 110 / 30 + 3, base: 110, isAboveMaximum: true),
        // PoliMi: no cum laude, rounded to the whole number with .50 up, plus the committee's points.
        Case(name: "PoliMi, lode 30, arrotondato", rules: .with { $0.rounding = .nearest },
             average: 28, unrounded: 28 * 110 / 30.0, base: 103, isAboveMaximum: false),
        Case(name: "PoliMi, lode 30, +4 commissione", rules: .with { $0.rounding = .nearest; $0.bonusPoints = 4 },
             average: 28, unrounded: 28 * 110 / 30.0 + 4, base: 107, isAboveMaximum: false),
        // 597/22 × 110/30 is exactly 99.5: PoliMi rounds it up.
        Case(name: "PoliMi, 99,50 per eccesso", exams: [.graded(27, 10), .graded(27, 9), .graded(28, 3)], rules: .with { $0.rounding = .nearest },
             average: 597.0 / 22, unrounded: 99.5, base: 100, isAboveMaximum: false),
        Case(name: "99,50 per difetto", exams: [.graded(27, 10), .graded(27, 9), .graded(28, 3)], rules: .with { $0.rounding = .down },
             average: 597.0 / 22, unrounded: 99.5, base: 99, isAboveMaximum: false),
        Case(name: "99,50 senza arrotondamento", exams: [.graded(27, 10), .graded(27, 9), .graded(28, 3)], rules: .standard,
             average: 597.0 / 22, unrounded: 99.5, base: 99.5, isAboveMaximum: false),
        // UniBo, Ingegneria Elettronica: lode = 30, × 110/30, then × 1.0325 if on time.
        Case(name: "UniBo, in corso", rules: .with { $0.multiplier = 1.0325 },
             average: 28, unrounded: 28 * 110 / 30.0 * 1.0325, base: 28 * 110 / 30.0 * 1.0325, isAboveMaximum: false),
        Case(name: "UniBo, primo anno fuori corso", rules: .with { $0.multiplier = 1.016 },
             average: 28, unrounded: 28 * 110 / 30.0 * 1.016, base: 28 * 110 / 30.0 * 1.016, isAboveMaximum: false),
        // Sapienza, Ingegneria Civile: × 4, lode = 31; 110 cum laude only from 115.
        Case(name: "Sapienza, × 4, lode 31", rules: .with { $0.conversionFactor = 4; $0.cumLaudeValue = 31 },
             average: 768.0 / 27, unrounded: 768.0 / 27 * 4, base: 110, isAboveMaximum: true),
        Case(name: "Sapienza, tutto 30 e lode", exams: [.graded(31, 12), .graded(31, 6)], rules: .with { $0.conversionFactor = 4; $0.cumLaudeValue = 31 },
             average: 31, unrounded: 124, base: 110, isAboveMaximum: true),
        Case(name: "Sapienza, sotto il tetto", exams: [.graded(24, 12), .graded(25, 6)], rules: .with { $0.conversionFactor = 4; $0.cumLaudeValue = 31 },
             average: 146.0 / 6, unrounded: 146.0 / 6 * 4, base: 146.0 / 6 * 4, isAboveMaximum: false),
        // MyLibretto's own example: lode 31 and 10 CFU eliminabili.
        Case(name: "lode 31 e 10 CFU eliminabili", exams: [.graded(18, 6), .graded(31, 12), .graded(27, 6)],
             rules: .with { $0.cumLaudeValue = 31; $0.exclusion = .credits(10) },
             average: (31.0 * 12 + 27 * 6) / 18, unrounded: (31.0 * 12 + 27 * 6) / 18 * 110 / 30, base: (31.0 * 12 + 27 * 6) / 18 * 110 / 30, isAboveMaximum: false),
        // Exactly 110: not above.
        Case(name: "esattamente 110", exams: [.graded(30, 6)], rules: .standard, average: 30, unrounded: 110, base: 110, isAboveMaximum: false),
        Case(name: "il minimo, 18", exams: [.graded(18, 180)], rules: .with { $0.rounding = .nearest }, average: 18, unrounded: 66, base: 66, isAboveMaximum: false),
    ]

    @Test(arguments: cases)
    func base(_ example: Case) throws {
        let transcript = Transcript(example.exams, rules: example.rules)
        let average = try #require(transcript.weightedAverage)
        let base = try #require(transcript.base)
        #expect(abs(average - example.average) < 1e-9)
        #expect(abs(base.unrounded - example.unrounded) < 1e-9)
        #expect(abs(base.value - example.base) < 1e-6, "\(base.value) ≠ \(example.base)")
        #expect(base.isAboveMaximum == example.isAboveMaximum)
        #expect(base.value <= GradeRules.maximum)
    }

    @Test(arguments: [GradeRounding.none, .nearest, .up, .down], [-20.0, 0, 20])
    func theBaseNeverPassesOneHundredTen(_ rounding: GradeRounding, _ bonus: Double) throws {
        for grade in Grade.ascending {
            let rules = GradeRules.with { $0.rounding = rounding; $0.bonusPoints = bonus; $0.cumLaudeValue = 35; $0.multiplier = 2; $0.conversionFactor = 10 }
            let base = try #require(Transcript([ExamRecord(credits: 6, result: .graded(grade))], rules: rules).base)
            #expect(base.value <= 110)
        }
    }
}
