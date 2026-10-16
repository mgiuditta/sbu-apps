import Foundation

/// The unit of a chore's frequency, as Tody offers it: days, weeks or months.
nonisolated enum FrequencyUnit: String, Codable, CaseIterable, Sendable {
    case day
    case week
    case month

    /// The calendar component a cycle is counted in, so months follow the calendar.
    var component: Calendar.Component {
        switch self {
        case .day: .day
        case .week: .weekOfYear
        case .month: .month
        }
    }

    /// The values a picker offers: from once a day to once a year or two, never zero.
    var range: ClosedRange<Int> {
        switch self {
        case .day: 1...365
        case .week: 1...52
        case .month: 1...24
        }
    }
}
