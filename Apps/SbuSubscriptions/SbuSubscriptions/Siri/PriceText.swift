import Foundation

/// A price with its cycle, as a sentence says it: "10,99 € al mese", "5 € ogni 2 settimane", "50 € una tantum".
nonisolated enum PriceText {
    static func text(_ price: Decimal, currencyCode: String, cycle: BillingCycle) -> String {
        let amount = price.formatted(.currency(code: currencyCode))
        switch cycle {
        case .once: return String(localized: "\(amount) una tantum")
        case .every(1, .day): return String(localized: "\(amount) al giorno")
        case .every(1, .week): return String(localized: "\(amount) a settimana")
        case .every(1, .month): return String(localized: "\(amount) al mese")
        case .every(1, .year): return String(localized: "\(amount) all'anno")
        case let .every(interval, .day): return String(localized: "\(amount) ogni \(interval) giorni")
        case let .every(interval, .week): return String(localized: "\(amount) ogni \(interval) settimane")
        case let .every(interval, .month): return String(localized: "\(amount) ogni \(interval) mesi")
        case let .every(interval, .year): return String(localized: "\(amount) ogni \(interval) anni")
        }
    }
}
