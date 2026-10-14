import Foundation

/// The ECB euro reference rates bundled with the app, refreshed by `Tools/ecb_rates.py` before each release.
nonisolated struct ExchangeRates: Decodable, Hashable, Sendable {
    /// The ECB publication day, `yyyy-MM-dd`.
    let day: String
    /// Units of each currency one euro buys, by ISO 4217 code; the euro itself is 1.
    let perEuro: [String: Decimal]

    init(day: String, perEuro: [String: Decimal]) {
        self.day = day
        self.perEuro = perEuro
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        day = try container.decode(String.self, forKey: .day)
        // Strings in the file, so no rate passes through Double on the way in.
        let strings = try container.decode([String: String].self, forKey: .perEuro)
        perEuro = try strings.mapValues { string in
            guard let rate = Decimal(string: string, locale: Locale(identifier: "en_US_POSIX")), rate > 0 else {
                throw DecodingError.dataCorruptedError(forKey: .perEuro, in: container, debugDescription: "Bad rate \(string)")
            }
            return rate
        }
    }

    var date: Date? {
        try? Date(day, strategy: Date.ISO8601FormatStyle().year().month().day())
    }

    static let bundled: ExchangeRates = {
        // ponytail: a broken bundled file is a build bug, caught by the tests; fall back to no rates rather than crash.
        guard let url = Bundle.main.url(forResource: "ExchangeRates", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let rates = try? JSONDecoder().decode(ExchangeRates.self, from: data) else {
            return ExchangeRates(day: "", perEuro: ["EUR": 1])
        }
        return rates
    }()

    private enum CodingKeys: String, CodingKey {
        case day, perEuro
    }
}
