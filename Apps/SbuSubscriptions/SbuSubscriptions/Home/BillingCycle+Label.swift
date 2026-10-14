import SwiftUI

extension BillingCycle {
    /// "Mensile", "Ogni 3 mesi", "Una tantum".
    var label: LocalizedStringKey {
        switch self {
        case .once: "Una tantum"
        case .every(1, .day): "Ogni giorno"
        case .every(1, .week): "Settimanale"
        case .every(1, .month): "Mensile"
        case .every(1, .year): "Annuale"
        case let .every(interval, .day): "Ogni \(interval) giorni"
        case let .every(interval, .week): "Ogni \(interval) settimane"
        case let .every(interval, .month): "Ogni \(interval) mesi"
        case let .every(interval, .year): "Ogni \(interval) anni"
        }
    }
}
