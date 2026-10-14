import SwiftUI

/// The period the home figure totals over: the year by default, as most people compare subscriptions.
nonisolated enum TotalPeriod: String, CaseIterable, Sendable {
    case year
    case month

    static let storageKey = "totalPeriod"

    var other: TotalPeriod { self == .year ? .month : .year }
}
