import Foundation
import Testing
@testable import SbuSubscriptions

struct CurrencyConverterTests {
    let table = ExchangeRates(day: "2026-10-13", perEuro: ["EUR": 1, "USD": Decimal(string: "1.25")!, "GBP": Decimal(string: "0.8")!])
    let today = Date(timeIntervalSince1970: 1_790_000_000)

    @Test(arguments: [
        ("EUR", "EUR", "10", "10"),
        ("EUR", "USD", "10", "12.5"),
        ("USD", "EUR", "12.5", "10"),
        // Cross rate through the euro.
        ("GBP", "USD", "8", "12.5"),
    ])
    func tableRates(from: String, to: String, amount: String, expected: String) throws {
        let converter = CurrencyConverter(table: table)
        let result = try #require(converter.convert(Decimal(string: amount)!, from: from, to: to))
        #expect(result == Decimal(string: expected))
    }

    @Test func currencyWithoutRateIsNeverAdded() {
        let converter = CurrencyConverter(table: table)
        #expect(converter.convert(10, from: "ARS", to: "EUR") == nil)
        #expect(converter.convert(10, from: "EUR", to: "ARS") == nil)
    }

    @Test func ownRateBeatsTheTable() throws {
        let own = OwnRate(value: Decimal(string: "0.9")!, currencyCode: "EUR", date: today)
        let converter = CurrencyConverter(table: table, ownRates: ["USD": own])
        #expect(converter.convert(10, from: "USD", to: "EUR") == 9)
        // And it carries on through the euro.
        let pounds = try #require(converter.convert(10, from: "USD", to: "GBP"))
        #expect(pounds == Decimal(string: "7.2"))
    }

    @Test func ownRatePricesACurrencyTheECBDoesNotList() {
        let own = OwnRate(value: 1000, currencyCode: "ARS", date: today)
        let converter = CurrencyConverter(table: table, ownRates: ["USD": own])
        // Main currency ARS: both directions use your rate directly.
        #expect(converter.convert(5, from: "USD", to: "ARS") == 5000)
        #expect(converter.convert(5000, from: "ARS", to: "USD") == 5)
    }

    @Test func bundledTableReadsEveryRate() throws {
        let rates = ExchangeRates.bundled
        #expect(rates.perEuro["EUR"] == 1)
        #expect(rates.perEuro.count >= 20)
        #expect(rates.date != nil)
    }

    @Test func badRateFailsToDecode() {
        let json = Data(#"{"day":"2026-10-13","perEuro":{"USD":"zero"}}"#.utf8)
        #expect(throws: DecodingError.self) { try JSONDecoder().decode(ExchangeRates.self, from: json) }
    }
}
