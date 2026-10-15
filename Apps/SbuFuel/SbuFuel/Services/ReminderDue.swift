import Foundation

/// When a service is due, by distance, by time, or both, whichever comes first.
nonisolated struct ReminderDue: Equatable, Sendable {
    /// The odometer reading it is due at.
    let dueKm: Double?
    /// The day it is due by time.
    let dueDate: Date?
    /// Kilometres left from the last reading logged; negative once passed.
    let remainingKm: Double?
    /// The day the odometer should reach `dueKm`, from your pace.
    let estimatedDateForKm: Date?
    let status: ReminderStatus

    /// The earliest day it is due, by time or by the estimated distance.
    var firstDate: Date? {
        [dueDate, estimatedDateForKm].compactMap { $0 }.min()
    }

    /// Whether the odometer you logged has already reached the due reading.
    var isPastByDistance: Bool {
        (remainingKm ?? 1) <= 0
    }
}
