import Testing
@testable import SbuLibretto

struct GradeRoundingTests {
    nonisolated struct Case: CustomTestStringConvertible, Sendable {
        let value: Double
        let rounding: GradeRounding
        let expected: Double
        var testDescription: String { "\(value) \(rounding.rawValue) → \(expected)" }
    }

    nonisolated static let cases: [Case] = [
        Case(value: 100.5, rounding: .nearest, expected: 101),
        Case(value: 100.49, rounding: .nearest, expected: 100),
        Case(value: 100.51, rounding: .nearest, expected: 101),
        // Float noise from the arithmetic: the student computes 100.5 by hand.
        Case(value: 100.499_999_999, rounding: .nearest, expected: 101),
        Case(value: 99.0, rounding: .nearest, expected: 99),
        Case(value: 100.01, rounding: .up, expected: 101),
        Case(value: 100, rounding: .up, expected: 100),
        Case(value: 100.000_000_01, rounding: .up, expected: 100),
        Case(value: 100.99, rounding: .down, expected: 100),
        Case(value: 109.999_999_99, rounding: .down, expected: 110),
        Case(value: 102.666_666, rounding: .none, expected: 102.666_666),
        Case(value: 0, rounding: .nearest, expected: 0),
        Case(value: -0.5, rounding: .nearest, expected: -1),
    ]

    @Test(arguments: cases)
    func rounds(_ example: Case) {
        #expect(abs(example.rounding.apply(to: example.value) - example.expected) < 1e-9)
    }

    @Test(arguments: GradeRounding.allCases)
    func notANumberStaysNotANumber(_ rounding: GradeRounding) {
        #expect(rounding.apply(to: .nan).isNaN)
        #expect(rounding.apply(to: .infinity) == .infinity)
    }
}
