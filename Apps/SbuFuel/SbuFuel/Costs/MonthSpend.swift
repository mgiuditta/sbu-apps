import Foundation

/// What a vehicle cost in one calendar month.
nonisolated struct MonthSpend: Equatable, Identifiable, Sendable {
    /// The first instant of the month.
    let month: Date
    var fuel: Decimal = 0
    var service: Decimal = 0

    var id: Date { month }
    var total: Decimal { fuel + service }
}
