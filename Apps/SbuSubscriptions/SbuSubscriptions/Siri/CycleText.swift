import Foundation

/// A cycle as plain text: "Mensile", "Ogni 3 mesi", "Una tantum".
nonisolated enum CycleText {
    static func text(_ cycle: BillingCycle) -> String {
        switch cycle {
        case .once: String(localized: "Una tantum")
        case .every(1, .day): String(localized: "Ogni giorno")
        case .every(1, .week): String(localized: "Settimanale")
        case .every(1, .month): String(localized: "Mensile")
        case .every(1, .year): String(localized: "Annuale")
        case let .every(interval, .day): String(localized: "Ogni \(interval) giorni")
        case let .every(interval, .week): String(localized: "Ogni \(interval) settimane")
        case let .every(interval, .month): String(localized: "Ogni \(interval) mesi")
        case let .every(interval, .year): String(localized: "Ogni \(interval) anni")
        }
    }
}
