import Testing
@testable import SbuLibretto

struct GradeRulesTests {
    @Test func theDefaultIsTheMostCommonRule() {
        let rules = GradeRules.standard
        #expect(rules.totalCredits == 180)
        #expect(rules.conversionFactor == 110.0 / 30.0)
        #expect(rules.cumLaudeValue == 30)
        #expect(rules.exclusion == .none)
        #expect(rules.bonusPoints == 0)
        #expect(rules.multiplier == 1)
        #expect(rules.rounding == .none)
        #expect(rules.sanitized == rules)
    }

    nonisolated struct Case: CustomTestStringConvertible, Sendable {
        let name: String
        let rules: GradeRules
        let expected: GradeRules
        var testDescription: String { name }
    }

    nonisolated static let cases: [Case] = {
        func rules(_ change: (inout GradeRules) -> Void) -> GradeRules {
            var rules = GradeRules.standard
            change(&rules)
            return rules
        }
        return [
            Case(name: "CFU totali a zero", rules: rules { $0.totalCredits = 0 }, expected: rules { $0.totalCredits = 1 }),
            Case(name: "CFU totali negativi", rules: rules { $0.totalCredits = -180 }, expected: rules { $0.totalCredits = 1 }),
            Case(name: "CFU totali assurdi", rules: rules { $0.totalCredits = 1e12 }, expected: rules { $0.totalCredits = 1_000 }),
            Case(name: "CFU totali non numero", rules: rules { $0.totalCredits = .nan }, expected: .standard),
            Case(name: "fattore zero", rules: rules { $0.conversionFactor = 0 }, expected: rules { $0.conversionFactor = 0.1 }),
            Case(name: "fattore infinito", rules: rules { $0.conversionFactor = .infinity }, expected: .standard),
            Case(name: "fattore enorme", rules: rules { $0.conversionFactor = 110 }, expected: rules { $0.conversionFactor = 10 }),
            Case(name: "lode sotto il 30", rules: rules { $0.cumLaudeValue = 18 }, expected: .standard),
            Case(name: "lode a 100", rules: rules { $0.cumLaudeValue = 100 }, expected: rules { $0.cumLaudeValue = 35 }),
            Case(name: "lode non numero", rules: rules { $0.cumLaudeValue = .nan }, expected: .standard),
            Case(name: "bonus enorme", rules: rules { $0.bonusPoints = 1_000 }, expected: rules { $0.bonusPoints = 20 }),
            Case(name: "malus enorme", rules: rules { $0.bonusPoints = -1_000 }, expected: rules { $0.bonusPoints = -20 }),
            Case(name: "moltiplicatore zero", rules: rules { $0.multiplier = 0 }, expected: rules { $0.multiplier = 0.5 }),
            Case(name: "moltiplicatore negativo infinito", rules: rules { $0.multiplier = -.infinity }, expected: .standard),
            Case(name: "CFU esclusi negativi", rules: rules { $0.exclusion = .credits(-6) }, expected: .standard),
            Case(name: "CFU esclusi a zero", rules: rules { $0.exclusion = .credits(0) }, expected: .standard),
            Case(name: "CFU esclusi oltre i totali", rules: rules { $0.exclusion = .credits(500) }, expected: rules { $0.exclusion = .credits(180) }),
            Case(name: "CFU esclusi non numero", rules: rules { $0.exclusion = .credits(.nan) }, expected: .standard),
            Case(name: "esami esclusi negativi", rules: rules { $0.exclusion = .exams(-2) }, expected: .standard),
            Case(name: "esami esclusi assurdi", rules: rules { $0.exclusion = .exams(5_000) }, expected: rules { $0.exclusion = .exams(100) }),
            Case(name: "CFU esclusi decimali", rules: rules { $0.exclusion = .credits(7.5) }, expected: rules { $0.exclusion = .credits(7.5) }),
        ]
    }()

    @Test(arguments: cases)
    func absurdValuesComeBackIntoRange(_ example: Case) {
        #expect(example.rules.sanitized == example.expected)
    }

    @Test func excludedCreditsNeverPassTheTotalAfterItIsClamped() {
        var rules = GradeRules.standard
        rules.totalCredits = -5
        rules.exclusion = .credits(30)
        #expect(rules.sanitized.exclusion == .credits(1))
    }
}
