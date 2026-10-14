import Foundation
import Testing
@testable import SbuSubscriptions

struct SpendingTotalTests {
    let converter = CurrencyConverter(table: ExchangeRates(day: "2026-10-13", perEuro: ["EUR": 1, "USD": 2]))

    @Test(arguments: [
        (BillingCycle.monthly, TotalPeriod.year, "120"),
        (.monthly, .month, "10"),
        (.yearly, .month, "0.8333333333333333333333333333333333333"),
        (.weekly, .year, "520"),
        (.every(3, .month), .year, "40"),
        (.every(2, .year), .year, "5"),
        (.every(5, .day), .year, "730"),
    ])
    func everyCycleBecomesThePeriod(cycle: BillingCycle, period: TotalPeriod, expected: String) throws {
        let amount = try #require(Charge(price: 10, currencyCode: "EUR", cycle: cycle).amount(per: period))
        #expect(amount == Decimal(string: expected))
    }

    @Test func oneOffHasNoRecurringCost() {
        #expect(Charge(price: 10, currencyCode: "EUR", cycle: .once).amount(per: .year) == nil)
    }

    @Test func mixedCurrenciesAreConvertedNotAdded() {
        let charges = [
            Charge(price: 10, currencyCode: "EUR", cycle: .monthly),
            Charge(price: 10, currencyCode: "USD", cycle: .monthly),
        ]
        let total = SpendingTotal(charges, per: .month, in: "EUR", converter: converter)
        #expect(total.amount == 15)
        #expect(total.count == 2)
        #expect(total.isConverted)
    }

    @Test func currencyWithoutRateIsLeftOutAndCounted() {
        let charges = [
            Charge(price: 10, currencyCode: "EUR", cycle: .monthly),
            Charge(price: 5000, currencyCode: "ARS", cycle: .monthly),
            Charge(price: 9000, currencyCode: "ARS", cycle: .monthly),
        ]
        let total = SpendingTotal(charges, per: .month, in: "EUR", converter: converter)
        #expect(total.amount == 10)
        #expect(total.count == 1)
        #expect(total.missingRates == ["ARS": 2])
        #expect(!total.isConverted)
    }
}
