import Foundation

/// The doses of one day, grouped by time as on Medisafe's home: everything scheduled that day,
/// plus what the history holds for it (an extra dose, or a time the schedule no longer has).
nonisolated struct DayPlan: Hashable, Sendable {
    /// The doses due at one time, all marked together by "Prendi tutto".
    nonisolated struct Group: Hashable, Sendable, Identifiable {
        let dueDate: Date
        let items: [DoseItem]

        var id: Date { dueDate }

        var toTake: [DoseItem] { items.filter(\.state.isToTake) }
    }

    let day: Day
    let groups: [Group]

    init(_ medicines: [MedicineSnapshot], day: Day, now: Date, calendar: Calendar) {
        self.day = day
        var items: [DoseItem] = []
        for medicine in medicines {
            let records = medicine.records.filter { $0.key.day == day }
            let scheduled = medicine.schedule.times(on: day, calendar: calendar)
            for time in scheduled {
                let key = DoseKey(medicineID: medicine.id, day: day, minutes: time.minutes)
                let record = records.first { !$0.isExtra && $0.key.minutes == time.minutes }
                items.append(DoseItem(key: key, medicine: medicine, amount: time.amount, record: record, now: now, calendar: calendar))
            }
            let scheduledMinutes = Set(scheduled.map(\.minutes))
            // Extras, and doses marked at a time the schedule has since dropped: the history keeps them.
            for record in records where record.isExtra || (!scheduledMinutes.contains(record.key.minutes) && record.mark != .moved) {
                items.append(DoseItem(key: record.key, medicine: medicine, amount: record.amount, record: record, now: now, calendar: calendar))
            }
        }
        let byTime = Dictionary(grouping: items, by: \.dueDate)
        groups = byTime.keys.sorted().map { date in
            Group(dueDate: date, items: (byTime[date] ?? []).sorted { ($0.medicine.name, $0.id) < ($1.medicine.name, $1.id) })
        }
    }

    var items: [DoseItem] { groups.flatMap(\.items) }

    /// Scheduled doses only: extras are not part of the day's plan.
    private var scheduled: [DoseItem] { items.filter { !$0.isExtra } }

    /// Still to take, late included: the figure of the day.
    var toTakeCount: Int { scheduled.filter(\.state.isToTake).count }
    var takenCount: Int { scheduled.filter(\.state.isTaken).count }
    var scheduledCount: Int { scheduled.count }
    var lateCount: Int { scheduled.filter { $0.state == .late }.count }
    var isEmpty: Bool { groups.isEmpty }
}
