import Foundation

/// How the form's Misura list groups the measures, in the order it shows them.
nonisolated enum HealthMeasureGroup: CaseIterable, Identifiable, Sendable {
    case activity
    case sleep
    case mind
    case eating

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .activity: "Attività"
        case .sleep: "Sonno"
        case .mind: "Mente"
        case .eating: "Alimentazione"
        }
    }

    /// Each measure is in exactly one group.
    var measures: [HealthMeasure] {
        switch self {
        case .activity:
            [.steps, .walkingRunningDistance, .cyclingDistance, .swimmingDistance, .flightsClimbed,
             .exerciseMinutes, .standMinutes, .activeEnergy, .activityRings]
        case .sleep: [.sleep]
        case .mind: [.mindfulMinutes, .timeInDaylight]
        case .eating: [.water]
        }
    }
}
