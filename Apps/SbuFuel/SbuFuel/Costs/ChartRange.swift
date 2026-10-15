import Foundation

/// How far back the costs screen looks.
nonisolated enum ChartRange: String, CaseIterable, Identifiable, Sendable {
    case threeMonths
    case twelveMonths
    case all

    var id: Self { self }

    var name: LocalizedStringResource {
        switch self {
        case .threeMonths: "3 mesi"
        case .twelveMonths: "12 mesi"
        case .all: "Tutto"
        }
    }

    /// The first day included: the start of the month two or eleven months back, so the current month counts as one.
    func start(now: Date, calendar: Calendar) -> Date? {
        let months: Int
        switch self {
        case .threeMonths: months = 3
        case .twelveMonths: months = 12
        case .all: return nil
        }
        guard let thisMonth = calendar.dateInterval(of: .month, for: now)?.start else { return nil }
        return calendar.date(byAdding: .month, value: -(months - 1), to: thisMonth)
    }

    func contains(_ date: Date, now: Date, calendar: Calendar) -> Bool {
        guard let start = start(now: now, calendar: calendar) else { return true }
        return date >= start
    }
}
