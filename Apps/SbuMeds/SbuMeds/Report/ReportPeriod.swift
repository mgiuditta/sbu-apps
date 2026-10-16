import Foundation

/// The period of the report: the last week, month or three months, or two days you pick.
nonisolated enum ReportPeriod: String, CaseIterable, Identifiable, Sendable {
    case week
    case month
    case quarter
    case custom

    var id: String { rawValue }

    var name: LocalizedStringResource {
        switch self {
        case .week: "7 giorni"
        case .month: "30 giorni"
        case .quarter: "90 giorni"
        case .custom: "Scegli"
        }
    }

    /// The first and last day, today included; `custom` uses the days given.
    func range(today: Day, customFirst: Day, customLast: Day, calendar: Calendar) -> (first: Day, last: Day) {
        switch self {
        case .week: (today.adding(days: -6, in: calendar), today)
        case .month: (today.adding(days: -29, in: calendar), today)
        case .quarter: (today.adding(days: -89, in: calendar), today)
        case .custom: (min(customFirst, customLast), max(customFirst, customLast))
        }
    }
}
