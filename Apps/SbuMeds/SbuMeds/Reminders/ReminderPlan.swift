import Foundation

/// Which notifications to keep with iOS, made again from scratch after every change, at launch
/// and each time the app comes back: no ghost reminder survives a new plan.
///
/// One notification per person and time with all the doses of that time. If they stay unmarked,
/// it comes back every `repeatMinutes`, a few times; marking them drops the rest. When a dose
/// brings the stock to its threshold, a refill reminder comes with it.
nonisolated enum ReminderPlan {
    /// Days planned ahead.
    static let days = 7
    /// iOS keeps 64 pending notifications per app; a few stay free for tests and snoozes.
    static let limit = 60
    /// Times a reminder comes back at most.
    static let repeats = 3
    /// Repeats are planned for the next hours only, so they never crowd out the next days' doses.
    static let repeatWindow: TimeInterval = 24 * 3_600

    static func reminders(
        for medicines: [MedicineSnapshot],
        now: Date,
        calendar: Calendar,
        repeatMinutes: Int,
        days: Int = days,
        limit: Int = limit,
        locale: Locale = .current
    ) -> [PlannedReminder] {
        let today = Day(now, calendar: calendar)
        var items: [DoseItem] = []
        for offset in 0..<max(days, 0) {
            let day = today.adding(days: offset, in: calendar)
            items += DayPlan(medicines, day: day, now: now, calendar: calendar).items.filter { !$0.isExtra && $0.state.isToTake }
        }
        var planned: [PlannedReminder] = []

        let groups = Dictionary(grouping: items) { GroupKey(personID: $0.medicine.personID, dueDate: $0.dueDate) }
        for (key, doses) in groups {
            let sorted = doses.sorted { $0.medicine.name < $1.medicine.name }
            let lines = sorted.map { PlannedReminder.Line(name: $0.medicine.name, amount: $0.medicine.form.amountText($0.amount, locale: locale)) }
            let base = PlannedReminder.groupIdentifier(personID: key.personID, dueDate: key.dueDate)
            let repeats = repeatMinutes > 0 ? Self.repeats : 0
            for index in 0...repeats {
                let fire = key.dueDate.addingTimeInterval(Double(index * repeatMinutes * 60))
                guard fire > now else { continue }
                if index > 0, fire.timeIntervalSince(now) > repeatWindow { break }
                planned.append(PlannedReminder(
                    kind: .doses(repeat: index), fireDate: fire, personID: key.personID,
                    personName: sorted.first?.medicine.personName ?? "", dueDate: key.dueDate, lines: lines,
                    doseKeys: sorted.map(\.key.string), identifier: index == 0 ? base : "\(base)-r\(index)"
                ))
            }
        }

        planned += refills(for: medicines, doses: items.sorted { $0.dueDate < $1.dueDate }, now: now)
        return Array(planned.sorted { ($0.fireDate, $0.identifier) < ($1.fireDate, $1.identifier) }.prefix(max(limit, 0)))
    }

    /// For each counted medicine, the first coming dose after which the stock is at or under the
    /// threshold, counting the doses before it as taken. Already low: with its next dose.
    static func refills(for medicines: [MedicineSnapshot], doses: [DoseItem], now: Date) -> [PlannedReminder] {
        medicines.compactMap { medicine -> PlannedReminder? in
            guard var stock = medicine.stock, let threshold = medicine.refillThreshold else { return nil }
            for dose in doses where dose.medicine.id == medicine.id && dose.dueDate > now {
                stock -= dose.amount
                guard stock <= threshold else { continue }
                return PlannedReminder(
                    kind: .refill(medicineName: medicine.name, left: max(stock, 0), form: medicine.form), fireDate: dose.dueDate,
                    personID: medicine.personID, personName: medicine.personName, dueDate: dose.dueDate, lines: [],
                    doseKeys: [], identifier: "refill-\(medicine.id.uuidString)"
                )
            }
            return nil
        }
    }

    private nonisolated struct GroupKey: Hashable {
        let personID: UUID
        let dueDate: Date
    }
}
