import Foundation

/// A rate you typed yourself: one unit of a currency is worth `value` in `currencyCode`, as on your bank statement.
nonisolated struct OwnRate: Codable, Hashable, Sendable {
    var value: Decimal
    var currencyCode: String
    var date: Date
}
