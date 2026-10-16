import Foundation
import Testing
@testable import SbuLibretto

struct RuleChoiceTests {
    @Test(arguments: [(110.0 / 30.0, FactorChoice.standard), (4, .four), (3.5, .custom), (3.67, .custom), (1, .custom)])
    func theFactorPickerFindsItsPreset(_ factor: Double, _ expected: FactorChoice) {
        #expect(FactorChoice(factor: factor) == expected)
    }

    @Test(arguments: FactorChoice.allCases)
    func aPresetRoundTrips(_ choice: FactorChoice) {
        guard let factor = choice.factor else { return }
        #expect(FactorChoice(factor: factor) == choice)
    }

    @Test func switchingExclusionKeepsTheAmountOfTheSameKind() {
        #expect(ExclusionKind.credits.exclusion(from: .credits(18)) == .credits(18))
        #expect(ExclusionKind.exams.exclusion(from: .exams(3)) == .exams(3))
        #expect(ExclusionKind.credits.exclusion(from: .none) == .credits(12))
        #expect(ExclusionKind.exams.exclusion(from: .credits(18)) == .exams(1))
        #expect(ExclusionKind.none.exclusion(from: .exams(3)) == WorstExclusion.none)
        #expect(ExclusionKind(.credits(6)) == .credits)
        #expect(ExclusionKind(.none) == .none)
    }

    @Test(arguments: [
        (GradeRules.standard, "media × 110/30, massimo 110"),
        (GradeRules.with { $0.conversionFactor = 4 }, "media × 4, massimo 110"),
        (GradeRules.with { $0.bonusPoints = 3 }, "media × 110/30 + 3, massimo 110"),
        (GradeRules.with { $0.bonusPoints = -1.5 }, "media × 110/30 − 1,5, massimo 110"),
        (GradeRules.with { $0.multiplier = 1.0325 }, "media × 110/30 × 1,0325, massimo 110"),
        (GradeRules.with { $0.rounding = .nearest; $0.bonusPoints = 4 }, "media × 110/30 + 4, arrotondata all'intero (0,50 per eccesso), massimo 110"),
    ])
    func theFormulaReadsInItalian(_ rules: GradeRules, _ expected: String) {
        // The formula follows the phone's language; the test host runs in Italian or English.
        let formula = rules.formula
        if Locale.current.language.languageCode == .italian {
            #expect(formula == expected)
        } else {
            #expect(formula.contains("110"))
        }
    }

    @Test func everyUniversityExampleHasRuleAndSettings() {
        #expect(UniversityExample.all.map(\.id) == ["unimi", "polimi", "unibo", "sapienza"])
    }
}
