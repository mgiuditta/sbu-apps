import Foundation

/// A reminder as the notification plan sees it: who, what, when, and the reading in the vehicle's unit.
nonisolated struct ReminderInput: Equatable, Sendable {
    let id: UUID
    let vehicleName: String
    let title: String
    let due: ReminderDue
    /// The due reading already formatted, such as "60.000 km".
    let dueReading: String?
}
