import Foundation

/// When a service comes back: every so many kilometres, months, or both, counted from the last time.
nonisolated struct ReminderRule: Equatable, Sendable {
    var everyKm: Double?
    var everyMonths: Int?
    var lastDoneDate: Date
    var lastDoneOdometerKm: Double?

    /// The odometer reading it is due at, if it goes by distance.
    var dueKm: Double? {
        guard let everyKm, everyKm > 0, let lastDoneOdometerKm else { return nil }
        return lastDoneOdometerKm + everyKm
    }

    /// The day it is due, if it goes by time.
    func dueDate(calendar: Calendar) -> Date? {
        guard let everyMonths, everyMonths > 0 else { return nil }
        return calendar.date(byAdding: .month, value: everyMonths, to: calendar.startOfDay(for: lastDoneDate))
    }
}
