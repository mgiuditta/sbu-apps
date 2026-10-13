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
    /// In metres, shown in kilometres.
    case cyclingDistance
    /// In metres.
    case swimmingDistance
    /// In floors.
    case flightsClimbed
    /// In minutes: the Exercise ring's minutes.
    case exerciseMinutes
    /// In minutes.
    case standMinutes
    /// In minutes, measured by the Apple Watch.
    case timeInDaylight
    /// In minutes asleep, counted on the day you wake up (`SleepTotal`).
    case sleep
    /// The Activity rings closed in the day, 0 to 3 (`ActivityRings`).
    case activityRings

    var id: Self { self }

    /// The name Salute uses.
    var title: LocalizedStringResource {
        switch self {
        case .steps: "Passi"
        case .water: "Acqua"
        case .mindfulMinutes: "Minuti di consapevolezza"
        case .walkingRunningDistance: "Distanza camminata + corsa"
        case .activeEnergy: "Energia attiva"
        case .cyclingDistance: "Distanza in bicicletta"
        case .swimmingDistance: "Distanza a nuoto"
        case .flightsClimbed: "Piani saliti"
        case .exerciseMinutes: "Minuti di esercizio fisico"
        case .standMinutes: "Minuti in piedi"
        case .timeInDaylight: "Tempo alla luce del giorno"
        case .sleep: "Sonno"
        case .activityRings: "Anelli Attività"
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
        case .cyclingDistance: 1_000...200_000
        case .swimmingDistance: 100...10_000
        case .flightsClimbed: 1...100
        case .exerciseMinutes: 5...240
        case .standMinutes: 5...600
        case .timeInDaylight: 5...480
        case .sleep: 240...720
        case .activityRings: 1...3
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
        case .cyclingDistance: 1_000
        case .swimmingDistance: 100
        case .flightsClimbed: 1
        case .exerciseMinutes: 5
        case .standMinutes: 5
        case .timeInDaylight: 5
        case .sleep: 30
        case .activityRings: 1
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
        case .cyclingDistance: 10_000
        case .swimmingDistance: 1_000
        case .flightsClimbed: 10
        case .exerciseMinutes: 30
        case .standMinutes: 60
        case .timeInDaylight: 30
        case .sleep: 480
        case .activityRings: 3
        }
    }

    /// `amount`, in this measure's unit, for the user's locale: "8.000 passi", "2000 ml", "5,5 km",
    /// "7 h e 30 min", "3 anelli".
    func formatted(_ amount: Double, locale: Locale = .current) -> String {
        switch self {
        case .steps:
            let steps = Int(amount.rounded()).formatted(.number.locale(locale))
            // In the locale's language too, as the units of the other measures are.
            return Self.resolve(LocalizedStringResource("\(steps) passi", comment: "A goal in steps, the number already formatted: 8.000 passi."), locale)
        case .water:
            return Self.format(Measurement(value: amount, unit: UnitVolume.milliliters), locale: locale)
        case .mindfulMinutes, .exerciseMinutes, .standMinutes, .timeInDaylight:
            return Self.format(Measurement(value: amount, unit: UnitDuration.minutes), locale: locale)
        case .walkingRunningDistance, .cyclingDistance:
            return Self.format(Measurement(value: amount, unit: UnitLength.meters).converted(to: .kilometers), locale: locale)
        case .swimmingDistance:
            return Self.format(Measurement(value: amount, unit: UnitLength.meters), locale: locale)
        case .activeEnergy:
            return Self.format(Measurement(value: amount, unit: UnitEnergy.kilocalories), locale: locale)
        case .flightsClimbed:
            let flights = Int(amount.rounded())
            return Self.resolve(LocalizedStringResource("\(flights) piani", comment: "A goal in flights of stairs climbed: 10 piani."), locale)
        case .sleep:
            return Duration.seconds(amount.rounded() * 60).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated).locale(locale))
        case .activityRings:
            let rings = Int(amount.rounded())
            return Self.resolve(LocalizedStringResource("\(rings) anelli", comment: "A goal in Activity rings closed: 3 anelli."), locale)
        }
    }

    /// In the unit given, never converted: a goal moves in round steps of it.
    private static func format<UnitType: Dimension>(_ measurement: Measurement<UnitType>, locale: Locale) -> String {
        measurement.formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0...1))).locale(locale))
    }

    private static func resolve(_ resource: LocalizedStringResource, _ locale: Locale) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }
}
