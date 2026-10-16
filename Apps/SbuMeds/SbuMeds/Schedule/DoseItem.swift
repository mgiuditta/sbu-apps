import Foundation

/// One dose on a day: a scheduled one, or an extra one you took.
nonisolated struct DoseItem: Hashable, Sendable, Identifiable {
    let key: DoseKey
    let medicine: MedicineSnapshot
    let amount: Double
    let isExtra: Bool
    /// When it is due: the scheduled time, or where you moved it.
    let dueDate: Date
    let isMoved: Bool
    let state: DoseState

    var id: String { isExtra ? "extra-\(key.string)" : key.string }

    /// Builds the dose `key` from the schedule and its record, if any.
    init(key: DoseKey, medicine: MedicineSnapshot, amount: Double, record: DoseRecordSnapshot?, now: Date, calendar: Calendar) {
        self.key = key
        self.medicine = medicine
        isExtra = record?.isExtra ?? false
        self.amount = record?.amount ?? amount
        let scheduled = key.date(in: calendar)
        let moved = record?.mark == .moved ? record?.movedTo : nil
        dueDate = moved ?? scheduled
        isMoved = moved != nil
        state = switch record?.mark {
        case .taken: .taken(at: record?.markedAt ?? scheduled)
        case .skipped: .skipped
        case .missed: .missed
        case .moved, nil:
            if key.day < Day(now, calendar: calendar) {
                .missed
            } else {
                dueDate <= now ? .late : .upcoming
            }
        }
    }
}
