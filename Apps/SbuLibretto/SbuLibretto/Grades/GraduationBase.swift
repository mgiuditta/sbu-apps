/// The base of the degree grade: the starting points the exams bring to graduation, out of 110.
nonisolated struct GraduationBase: Hashable, Sendable {
    /// Before rounding and before the cap: Sapienza's 110 cum laude needs 115 here.
    let unrounded: Double
    /// Rounded by the course's rule and capped at 110.
    let value: Double

    init(weightedAverage: Double, rules: GradeRules) {
        let rules = rules.sanitized
        unrounded = weightedAverage * rules.conversionFactor * rules.multiplier + rules.bonusPoints
        value = min(rules.rounding.apply(to: unrounded), GradeRules.maximum)
    }

    /// Whether the exams alone reach past 110.
    var isAboveMaximum: Bool {
        GradeRounding.none.apply(to: unrounded) > GradeRules.maximum
    }
}
