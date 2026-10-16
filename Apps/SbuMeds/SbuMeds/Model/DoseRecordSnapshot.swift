import Foundation

/// A history entry as plain values, for the pure day plan, reminders, report and widget.
nonisolated struct DoseRecordSnapshot: Hashable, Sendable {
    let key: DoseKey
    let mark: DoseMark
    let markedAt: Date?
    let movedTo: Date?
    let amount: Double
    let isExtra: Bool

    init(key: DoseKey, mark: DoseMark, markedAt: Date? = nil, movedTo: Date? = nil, amount: Double = 1, isExtra: Bool = false) {
        self.key = key
        self.mark = mark
        self.markedAt = markedAt
        self.movedTo = movedTo
        self.amount = amount
        self.isExtra = isExtra
    }
}
