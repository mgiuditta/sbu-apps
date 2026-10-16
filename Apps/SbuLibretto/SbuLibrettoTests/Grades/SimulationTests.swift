import Foundation
import Testing
@testable import SbuLibretto

struct SimulationTests {
    @Test func oneRowPerGradeFromCumLaudeDown() throws {
        let simulation = Simulation([.graded(28, 12, day: 0)], rules: .standard, credits: 12)
        let rows = simulation.rows
        #expect(rows.map(\.grade) == Grade.descending)
        let top = try #require(rows.first)
        #expect(top.average == 29)
        #expect(top.change == 1)
        let bottom = try #require(rows.last)
        #expect(bottom.average == 23)
        #expect(bottom.change == -5)
        #expect(abs(bottom.base.value - 23 * 110 / 30.0) < 1e-6)
    }

    @Test func theSimulatedExamFollowsTheRulesOfTheCourse() throws {
        let rules = GradeRules.with { $0.cumLaudeValue = 33; $0.bonusPoints = 3; $0.rounding = .nearest }
        let row = try #require(Simulation([.graded(27, 6)], rules: rules, credits: 6).rows.first)
        #expect(row.grade == .cumLaude)
        #expect(row.average == 30)
        #expect(row.base.value == 110)
        #expect(row.base.isAboveMaximum)
    }

    @Test func onAnEmptyLibrettoTheAverageIsTheGrade() {
        let rows = Simulation([.pending(9), .passed(3)], rules: .standard, credits: 9).rows
        #expect(rows.map(\.average) == Grade.descending.map { $0.value(cumLaudeValue: 30) })
        #expect(rows.allSatisfy { $0.change == nil })
    }

    @Test func theNextExamCanPushTheWorstOut() throws {
        // 6 CFU eliminabili: today the 18 is out; an 18 in the next exam takes its place out, and the old one comes back.
        let simulation = Simulation([.graded(18, 6, day: 0), .graded(28, 12, day: 1)], rules: .with { $0.exclusion = .credits(6) }, credits: 6)
        #expect(simulation.currentAverage == 28)
        let eighteen = try #require(simulation.rows.last)
        #expect(eighteen.grade == .mark(18))
        #expect(abs(eighteen.average - (28.0 * 12 + 18 * 6) / 18) < 1e-9)
    }

    @Test(arguments: [0.0, -6, 0.4, 60.5, 1_000, .nan, .infinity, -.infinity])
    func creditsAnExamCannotHaveGiveNoRows(_ credits: Double) {
        let simulation = Simulation([.graded(28, 12)], rules: .standard, credits: credits)
        #expect(!simulation.hasValidCredits)
        #expect(simulation.rows.isEmpty)
        #expect(simulation.requiredGrade(forAverage: 28) == nil)
    }

    @Test(arguments: [0.5, 1, 7.5, 60])
    func creditsAtTheEdgesAreValid(_ credits: Double) {
        let simulation = Simulation([.graded(28, 12)], rules: .standard, credits: credits)
        #expect(simulation.rows.count == 14)
    }

    nonisolated struct TargetCase: CustomTestStringConvertible, Sendable {
        let name: String
        let exams: [ExamRecord]
        var rules = GradeRules.standard
        let credits: Double
        let target: Double
        let expected: RequiredGrade?
        var testDescription: String { name }
    }

    nonisolated static let targets: [TargetCase] = [
        TargetCase(name: "serve almeno 29", exams: [.graded(28, 12)], credits: 12, target: 28.5, expected: .atLeast(.mark(29))),
        TargetCase(name: "serve 30 esatto", exams: [.graded(28, 12)], credits: 12, target: 29, expected: .atLeast(.mark(30))),
        TargetCase(name: "basta la lode a 31", exams: [.graded(28, 12)], rules: .with { $0.cumLaudeValue = 31 }, credits: 12, target: 29.5,
                   expected: .atLeast(.cumLaude)),
        TargetCase(name: "irraggiungibile con lode a 30", exams: [.graded(28, 12)], credits: 12, target: 29.5, expected: .unreachable),
        TargetCase(name: "qualsiasi voto", exams: [.graded(28, 12)], credits: 12, target: 23, expected: .anyGrade),
        TargetCase(name: "obiettivo già sotto il minimo", exams: [.graded(28, 12)], credits: 3, target: 0, expected: .anyGrade),
        TargetCase(name: "obiettivo oltre la lode", exams: [], credits: 6, target: 40, expected: .unreachable),
        TargetCase(name: "libretto vuoto: il voto è la media", exams: [], credits: 6, target: 25, expected: .atLeast(.mark(25))),
        TargetCase(name: "obiettivo decimale", exams: [], credits: 6, target: 24.01, expected: .atLeast(.mark(25))),
        TargetCase(name: "pochi CFU spostano poco", exams: [.graded(25, 150)], credits: 6, target: 26, expected: .unreachable),
        TargetCase(name: "obiettivo non numero", exams: [.graded(28, 12)], credits: 6, target: .nan, expected: nil),
        TargetCase(name: "obiettivo infinito", exams: [.graded(28, 12)], credits: 6, target: .infinity, expected: nil),
    ]

    @Test(arguments: targets)
    func requiredGrade(_ example: TargetCase) {
        let simulation = Simulation(example.exams, rules: example.rules, credits: example.credits)
        #expect(simulation.requiredGrade(forAverage: example.target) == example.expected)
    }

    @Test func requiredGradeAgreesWithTheTable() {
        let simulation = Simulation([.graded(26, 9, day: 0), .graded(30, 6, day: 3), .passed(3)], rules: .with { $0.cumLaudeValue = 33 }, credits: 9)
        for target in stride(from: 20.0, through: 30.0, by: 0.25) {
            let reaching = simulation.rows.filter { $0.average >= target - 1e-6 }.map(\.grade)
            switch simulation.requiredGrade(forAverage: target) {
            case .anyGrade: #expect(reaching.count == 14)
            case let .atLeast(grade): #expect(reaching.min() == grade)
            case .unreachable: #expect(reaching.isEmpty)
            case nil: Issue.record("No answer for \(target)")
            }
        }
    }
}
