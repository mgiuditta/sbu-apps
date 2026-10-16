import Foundation
import SwiftData

/// What a notification's buttons do to the doses it is about. A dose already marked in the app
/// is left as it is: the notification was older than the mark.
enum NotificationActions {
    @discardableResult
    static func apply(
        _ action: String,
        to keyStrings: [String],
        in context: ModelContext,
        now: Date = .now,
        snoozeMinutes: Int,
        calendar: Calendar = .current
    ) -> Int {
        let keys = keyStrings.compactMap(DoseKey.init(string:))
        guard !keys.isEmpty else { return 0 }
        let ids = Set(keys.map(\.medicineID))
        let medicines = ((try? context.fetch(FetchDescriptor<Medicine>())) ?? []).filter { ids.contains($0.id) }
        let byID = Dictionary(medicines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var changed = 0
        for key in keys {
            guard let medicine = byID[key.medicineID] else { continue }
            let record = medicine.record(for: key)
            guard record == nil || record?.mark == .moved else { continue }
            let amount = record?.amount ?? medicine.schedule.effectiveTimes.first { $0.minutes == key.minutes }?.amount ?? 1
            switch action {
            case SystemReminderCenter.takenAction:
                Cabinet.mark(key, of: medicine, as: .taken, amount: amount, at: now, in: context)
            case SystemReminderCenter.skippedAction:
                Cabinet.mark(key, of: medicine, as: .skipped, amount: amount, at: now, in: context)
            case SystemReminderCenter.snoozeAction:
                Cabinet.move(key, of: medicine, to: now.addingTimeInterval(Double(snoozeMinutes * 60)), amount: amount, in: context)
            default:
                continue
            }
            changed += 1
        }
        return changed
    }
}
