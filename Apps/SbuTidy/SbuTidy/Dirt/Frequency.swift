import Foundation

/// How often a chore needs doing: every `value` days, weeks or months.
///
/// The value is clamped to the unit's range, so a stored or typed value of 0, a negative number
/// or ten thousand still gives a cycle that ends.
nonisolated struct Frequency: Hashable, Sendable {
    let value: Int
    let unit: FrequencyUnit

    init(_ value: Int, _ unit: FrequencyUnit) {
        self.unit = unit
        self.value = min(max(value, unit.range.lowerBound), unit.range.upperBound)
    }

    /// When a cycle that starts at `start` ends: the chore is due again.
    func dueDate(after start: Date, calendar: Calendar) -> Date {
        calendar.date(byAdding: unit.component, value: value, to: start)
            ?? start.addingTimeInterval(Double(value) * unit.fallbackSeconds)
    }

    /// The cycle's length in seconds when it starts at `start`; months vary with the calendar.
    func length(from start: Date, calendar: Calendar) -> TimeInterval {
        max(dueDate(after: start, calendar: calendar).timeIntervalSince(start), 1)
    }
}

private extension FrequencyUnit {
    /// Only for a calendar that cannot add the component, which Gregorian always can.
    nonisolated var fallbackSeconds: TimeInterval {
        switch self {
        case .day: 86_400
        case .week: 7 * 86_400
        case .month: 30 * 86_400
        }
    }
}
