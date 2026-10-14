import Foundation

/// The calendar unit a billing cycle repeats in.
nonisolated enum BillingUnit: String, Codable, CaseIterable, Hashable, Sendable {
    case day
    case week
    case month
    case year

    var component: Calendar.Component {
        switch self {
        case .day: .day
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }
    }
}
