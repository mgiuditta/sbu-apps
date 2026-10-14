import Foundation
import Testing
@testable import SbuSubscriptions

struct CurrencySettingsTests {
    let defaults: UserDefaults

    init() {
        let suite = "CurrencySettingsTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
    }

    @Test(arguments: [("it_IT", "EUR"), ("en_US", "USD"), ("en_GB", "GBP")])
    func mainCurrencyStartsFromTheRegion(locale: String, expected: String) {
        let settings = CurrencySettings(defaults: defaults, locale: Locale(identifier: locale))
        #expect(settings.mainCurrency == expected)
    }

    @Test func choicesSurviveARelaunch() {
        let settings = CurrencySettings(defaults: defaults, locale: Locale(identifier: "it_IT"))
        settings.mainCurrency = "CHF"
        settings.ownRates["USD"] = OwnRate(value: Decimal(string: "0.88")!, currencyCode: "CHF", date: .now)

        let relaunched = CurrencySettings(defaults: defaults, locale: Locale(identifier: "it_IT"))
        #expect(relaunched.mainCurrency == "CHF")
        #expect(relaunched.ownRates["USD"]?.value == Decimal(string: "0.88"))
    }
}
