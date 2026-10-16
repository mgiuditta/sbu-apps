import Foundation

extension Frequency {
    /// "Ogni giorno", "Ogni 2 settimane", "Ogni 3 mesi".
    nonisolated var text: LocalizedStringResource {
        switch unit {
        case .day: "Ogni \(value) giorni"
        case .week: "Ogni \(value) settimane"
        case .month: "Ogni \(value) mesi"
        }
    }
}

extension FrequencyUnit {
    /// The unit in the frequency picker.
    nonisolated var name: LocalizedStringResource {
        switch self {
        case .day: "Giorni"
        case .week: "Settimane"
        case .month: "Mesi"
        }
    }
}
