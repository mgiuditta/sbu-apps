import Foundation

/// A daily total in Salute that a habit to do can be linked to. Goals are kept in the unit
/// the form shows; the HealthKit side lives in the app only, never in the widget.
nonisolated enum HealthMeasure: String, CaseIterable, Identifiable, Codable, Sendable {
    case steps
    /// In millilitres.
    case water
    /// In minutes.
    case mindfulMinutes
    /// In metres, shown in kilometres.
    case walkingRunningDistance
    /// In kilocalories.
    case activeEnergy

    var id: Self { self }

    /// The name Salute uses.
    var title: LocalizedStringResource {
        switch self {
        case .steps: "Passi"
        case .water: "Acqua"
        case .mindfulMinutes: "Minuti di consapevolezza"
        case .walkingRunningDistance: "Distanza camminata + corsa"
        case .activeEnergy: "Energia attiva"
        }
    }

    /// The goals the form offers.
    var goalRange: ClosedRange<Double> {
        switch self {
        case .steps: 500...50_000
        case .water: 250...5_000
        case .mindfulMinutes: 5...120
        case .walkingRunningDistance: 500...50_000
        case .activeEnergy: 50...2_000
        }
    }

    /// How much one tap on the form's stepper moves the goal.
    var goalStep: Double {
        switch self {
        case .steps: 500
        case .water: 250
        case .mindfulMinutes: 5
        case .walkingRunningDistance: 500
        case .activeEnergy: 50
        }
    }

    /// The goal the form starts from.
    var defaultGoal: Double {
        switch self {
        case .steps: 8_000
        case .water: 2_000
        case .mindfulMinutes: 10
        case .walkingRunningDistance: 5_000
        case .activeEnergy: 400
        }
    }

    /// `amount`, in this measure's unit, for the user's locale: "8.000 passi", "2000 ml", "5,5 km".
    func formatted(_ amount: Double, locale: Locale = .current) -> String {
        switch self {
        case .steps:
            let steps = Int(amount.rounded()).formatted(.number.locale(locale))
            // In the locale's language too, as the units of the other measures are.
            var goal = LocalizedStringResource("\(steps) passi", comment: "A goal in steps, the number already formatted: 8.000 passi.")
            goal.locale = locale
            return String(localized: goal)
        case .water:
            return Self.format(Measurement(value: amount, unit: UnitVolume.milliliters), locale: locale)
        case .mindfulMinutes:
            return Self.format(Measurement(value: amount, unit: UnitDuration.minutes), locale: locale)
        case .walkingRunningDistance:
            return Self.format(Measurement(value: amount, unit: UnitLength.meters).converted(to: .kilometers), locale: locale)
        case .activeEnergy:
            return Self.format(Measurement(value: amount, unit: UnitEnergy.kilocalories), locale: locale)
        }
    }

    /// In the unit given, never converted: a goal moves in round steps of it.
    private static func format<UnitType: Dimension>(_ measurement: Measurement<UnitType>, locale: Locale) -> String {
        measurement.formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0...1))).locale(locale))
    }
}
