import Foundation

/// A daily total in Salute that a habit to do can be linked to. Goals are kept in the unit
/// the form shows; the HealthKit side lives in the app only, never in the widget.
nonisolated enum HealthMeasure: String, CaseIterable, Identifiable, Codable, Sendable {
    case steps

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .steps: "Passi"
        }
    }

    /// The goals the form offers.
    var goalRange: ClosedRange<Double> {
        switch self {
        case .steps: 500...50_000
        }
    }

    /// How much one tap on the form's stepper moves the goal.
    var goalStep: Double {
        switch self {
        case .steps: 500
        }
    }

    /// The goal the form starts from.
    var defaultGoal: Double {
        switch self {
        case .steps: 8_000
        }
    }

    /// `amount`, in this measure's unit, for the user's locale: "8.000 passi".
    func formatted(_ amount: Double, locale: Locale = .current) -> String {
        switch self {
        case .steps:
            let steps = Int(amount.rounded()).formatted(.number.locale(locale))
            return String(localized: "\(steps) passi", comment: "A goal in steps, the number already formatted: 8.000 passi.")
        }
    }
}
