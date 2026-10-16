import Foundation

/// A medicine's history as shown: marked doses only (a moved one is still to take), latest first.
nonisolated enum MedicineHistory {
    static func entries(of medicine: MedicineSnapshot) -> [DoseRecordSnapshot] {
        medicine.records
            .filter { $0.mark != .moved }
            .sorted { ($0.key.day, $0.key.minutes) > ($1.key.day, $1.key.minutes) }
    }

    /// The entries by month, latest first, for the full history.
    static func months(of medicine: MedicineSnapshot) -> [(month: Day, entries: [DoseRecordSnapshot])] {
        let grouped = Dictionary(grouping: entries(of: medicine)) { Day(year: $0.key.day.year, month: $0.key.day.month, day: 1) }
        return grouped.keys.sorted(by: >).map { ($0, grouped[$0] ?? []) }
    }
}
