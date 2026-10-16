import Foundation

/// The rules of a degree course for its averages and the base of the degree grade.
///
/// The base is the weighted average × `conversionFactor` × `multiplier` + `bonusPoints`, rounded,
/// and never above 110. The default is the most common rule: × 110/30, cum laude worth 30,
/// nothing excluded, no bonus, two decimals. Every value is clamped to a sane range, so a typo in
/// Settings can never turn into an absurd base.
nonisolated struct GradeRules: Hashable, Codable, Sendable {
    /// The highest base: the degree grade is out of 110.
    static let maximum = 110.0
    /// The usual conversion from thirtieths to hundred-and-tenths.
    static let standardFactor = 110.0 / 30.0

    static let totalCreditsRange = 1.0...1_000.0
    static let factorRange = 0.1...10.0
    static let cumLaudeRange = 30.0...35.0
    static let excludedExamsRange = 0...100
    static let bonusRange = -20.0...20.0
    static let multiplierRange = 0.5...2.0

    /// The credits of the whole degree: 180 for a bachelor's, 120 for a master's, 300 or 360 single-cycle.
    var totalCredits: Double = 180
    var conversionFactor: Double = standardFactor
    /// What 30 cum laude counts as in the averages.
    var cumLaudeValue: Double = 30
    var exclusion: WorstExclusion = .none
    /// Points added to the base, such as UniMi's +3 for graduating on time.
    var bonusPoints: Double = 0
    /// A factor on the base, such as UniBo's × 1.0325 for graduating on time.
    var multiplier: Double = 1
    var rounding: GradeRounding = .none

    static let standard = GradeRules()

    /// The rules with every value brought back into its range; a value that is not a number takes its default.
    var sanitized: GradeRules {
        let standard = GradeRules.standard
        var rules = self
        rules.totalCredits = Self.clamp(totalCredits, to: Self.totalCreditsRange, otherwise: standard.totalCredits)
        rules.conversionFactor = Self.clamp(conversionFactor, to: Self.factorRange, otherwise: standard.conversionFactor)
        rules.cumLaudeValue = Self.clamp(cumLaudeValue, to: Self.cumLaudeRange, otherwise: standard.cumLaudeValue)
        rules.bonusPoints = Self.clamp(bonusPoints, to: Self.bonusRange, otherwise: standard.bonusPoints)
        rules.multiplier = Self.clamp(multiplier, to: Self.multiplierRange, otherwise: standard.multiplier)
        switch exclusion {
        case .none:
            break
        case let .credits(credits):
            let limit = Self.clamp(credits, to: 0...rules.totalCredits, otherwise: 0)
            rules.exclusion = limit > 0 ? .credits(limit) : .none
        case let .exams(count):
            let limit = min(max(count, Self.excludedExamsRange.lowerBound), Self.excludedExamsRange.upperBound)
            rules.exclusion = limit > 0 ? .exams(limit) : .none
        }
        return rules
    }

    private static func clamp(_ value: Double, to range: ClosedRange<Double>, otherwise fallback: Double) -> Double {
        guard value.isFinite else { return fallback }
        return min(max(value, range.lowerBound), range.upperBound)
    }
}
