import Foundation

extension GradeRules {
    /// The rule in one line, as the footer shows it: "media × 110/30 + 3, arrotondata all'intero, massimo 110".
    nonisolated var formula: String {
        var text = String(localized: "media")
        switch FactorChoice(factor: conversionFactor) {
        case .standard: text += " × 110/30"
        case .four, .custom: text += " × " + conversionFactor.formatted(.number.precision(.fractionLength(0...4)))
        }
        if multiplier != 1 {
            text += " × " + multiplier.formatted(.number.precision(.fractionLength(0...4)))
        }
        if bonusPoints != 0 {
            text += (bonusPoints > 0 ? " + " : " − ") + abs(bonusPoints).formatted(.number.precision(.fractionLength(0...2)))
        }
        switch rounding {
        case .none: break
        case .nearest: text += ", " + String(localized: "arrotondata all'intero (0,50 per eccesso)")
        case .up: text += ", " + String(localized: "arrotondata per eccesso")
        case .down: text += ", " + String(localized: "arrotondata per difetto")
        }
        return text + ", " + String(localized: "massimo 110")
    }
}
