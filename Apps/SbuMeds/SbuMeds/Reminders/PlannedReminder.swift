import Foundation

/// One notification to hand to iOS: the doses one person takes at one time, a repeat of them,
/// or a refill reminder.
nonisolated struct PlannedReminder: Hashable, Sendable {
    nonisolated enum Kind: Hashable, Sendable {
        /// The doses at their time; `repeat` 0 is the first, then 1, 2… while they are not marked.
        case doses(repeat: Int)
        /// The stock of one medicine reaches its threshold with this dose.
        case refill(medicineName: String, left: Double, form: MedicineForm)
    }

    nonisolated struct Line: Hashable, Sendable {
        let name: String
        let amount: String
    }

    let kind: Kind
    let fireDate: Date
    let personID: UUID
    let personName: String
    /// When the doses are due: the time in the title.
    let dueDate: Date
    let lines: [Line]
    /// The doses it is about, as `DoseKey.string`: the actions mark these.
    let doseKeys: [String]
    /// Stable for the same doses, so a new plan replaces rather than duplicates.
    let identifier: String

    /// The identifier of the first notification of a group, and its repeats after it.
    static func groupIdentifier(personID: UUID, dueDate: Date) -> String {
        "dose-\(personID.uuidString)-\(Int(dueDate.timeIntervalSince1970))"
    }
}
