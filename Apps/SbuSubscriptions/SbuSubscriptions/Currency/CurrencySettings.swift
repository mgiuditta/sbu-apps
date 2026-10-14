import Foundation
import Observation

/// Your main currency and your own rates, in the App Group defaults so the widget totals the same way.
@Observable
final class CurrencySettings {
    private let defaults: UserDefaults

    var mainCurrency: String {
        didSet { defaults.set(mainCurrency, forKey: Keys.mainCurrency) }
    }

    var ownRates: [String: OwnRate] {
        didSet { defaults.set(try? JSONEncoder().encode(ownRates), forKey: Keys.ownRates) }
    }

    init(defaults: UserDefaults = .appGroup, locale: Locale = .current) {
        self.defaults = defaults
        mainCurrency = defaults.string(forKey: Keys.mainCurrency) ?? locale.currency?.identifier ?? "EUR"
        ownRates = defaults.data(forKey: Keys.ownRates).flatMap { try? JSONDecoder().decode([String: OwnRate].self, from: $0) } ?? [:]
    }

    var converter: CurrencyConverter {
        CurrencyConverter(table: .bundled, ownRates: ownRates)
    }

    private enum Keys {
        static let mainCurrency = "mainCurrency"
        static let ownRates = "ownRates"
    }
}
