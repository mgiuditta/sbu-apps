import Foundation
import SwiftData

/// One dose in the history: taken, skipped, missed or moved. Kept for good: no 30-day limit.
@Model
final class DoseRecord {
    var id = UUID()
    /// The day the dose was due, `yyyymmdd`, local.
    var dayKey = 0
    /// The time it was due, minutes after midnight, local; for an extra dose, when you took it.
    var minutes = 0
    var markRaw = DoseMark.taken.rawValue
    /// When you marked it: the time you took it, for a taken dose.
    var markedAt: Date?
    /// For a moved dose: when it is due now.
    var movedTo: Date?
    /// How much: taken doses come off the stock by this.
    var amount: Double = 1
    /// Taken outside the schedule, from the medicine's screen or as needed.
    var isExtra = false

    var medicine: Medicine?

    init(key: DoseKey, mark: DoseMark, amount: Double, isExtra: Bool = false) {
        dayKey = key.day.key
        minutes = key.minutes
        markRaw = mark.rawValue
        self.amount = amount
        self.isExtra = isExtra
    }

    var mark: DoseMark {
        get { DoseMark(rawValue: markRaw) ?? .taken }
        set { markRaw = newValue.rawValue }
    }

    var day: Day { Day(key: dayKey) }

    var snapshot: DoseRecordSnapshot {
        DoseRecordSnapshot(
            key: DoseKey(medicineID: medicine?.id ?? id, day: day, minutes: minutes),
            mark: mark, markedAt: markedAt, movedTo: movedTo, amount: amount, isExtra: isExtra
        )
    }
}
