import Foundation

/// Which notifications to keep with iOS, made again from scratch after every change, at launch,
/// each time the app comes back, after each action taken from a notification, at a background
/// refresh and when the clock or the time zone changes: no ghost reminder survives a new plan.
///
/// iOS keeps 64 pending notifications per app, so the slots go nearest first: every dose time of
/// every person gets its first notification, in date order; the slots left over go to the
/// repeats of the nearest doses; one slot stays for the refill reminder when one is due. When the
/// first notifications alone fill the slots, the plan says until when doses are covered, so the
/// app can ask to be opened in time.
nonisolated enum ReminderPlan {
    /// Days looked ahead for first notifications.
    static let days = 30
    /// iOS keeps 64 pending notifications per app.
    static let limit = 64
    /// Times a reminder comes back at most.
    static let repeats = 3
    /// Below this many days covered, Today asks you to open the app.
    static let warningDays = 3

    nonisolated struct Result: Hashable, Sendable {
        let reminders: [PlannedReminder]
        /// The due date of the last dose with a first notification, when the slots ran out
        /// before the end of the days looked at; `nil` when every coming dose is covered.
        let coveredUntil: Date?
    }

    static func plan(
        for medicines: [MedicineSnapshot],
        now: Date,
        calendar: Calendar,
        repeatMinutes: Int,
        days: Int = days,
        limit: Int = limit,
        locale: Locale = .current
    ) -> Result {
        let today = Day(now, calendar: calendar)
        var items: [DoseItem] = []
        for offset in 0..<max(days, 0) {
            let day = today.adding(days: offset, in: calendar)
            items += DayPlan(medicines, day: day, now: now, calendar: calendar).items.filter { !$0.isExtra && $0.state.isToTake }
        }
        let groups = Dictionary(grouping: items) { GroupKey(personID: $0.medicine.personID, dueDate: $0.dueDate) }
            .map { key, doses in Group(key: key, doses: doses.sorted { $0.medicine.name < $1.medicine.name }) }
            .sorted { ($0.key.dueDate, $0.key.personID.uuidString) < ($1.key.dueDate, $1.key.personID.uuidString) }

        let refill = refills(for: medicines, doses: items.sorted { $0.dueDate < $1.dueDate }, now: now).min { $0.fireDate < $1.fireDate }
        let budget = max(limit - (refill == nil ? 0 : 1), 0)

        // First notifications, nearest first.
        let firsts = groups.filter { $0.key.dueDate > now }
        let planned = firsts.prefix(budget).map { reminder(for: $0, repeat: 0, repeatMinutes: repeatMinutes, locale: locale) }
        let coveredUntil = firsts.count > budget ? planned.last?.dueDate ?? now : nil

        // Repeats, for the nearest doses only: a late dose's repeats still to come come first.
        var repeats: [PlannedReminder] = []
        if repeatMinutes > 0 {
            let covered = Set(planned.map(\.identifier))
            let eligible = groups.filter { $0.key.dueDate <= now || covered.contains($0.identifier) }
            outer: for group in eligible {
                for index in 1...Self.repeats {
                    guard planned.count + repeats.count < budget else { break outer }
                    let reminder = reminder(for: group, repeat: index, repeatMinutes: repeatMinutes, locale: locale)
                    if reminder.fireDate > now { repeats.append(reminder) }
                }
            }
        }

        let all = planned + repeats + (refill.map { [$0] } ?? [])
        return Result(reminders: all.sorted { ($0.fireDate, $0.identifier) < ($1.fireDate, $1.identifier) }, coveredUntil: coveredUntil)
    }

    /// The reminders alone, for callers that don't need the coverage.
    static func reminders(
        for medicines: [MedicineSnapshot],
        now: Date,
        calendar: Calendar,
        repeatMinutes: Int,
        days: Int = days,
        limit: Int = limit,
        locale: Locale = .current
    ) -> [PlannedReminder] {
        plan(for: medicines, now: now, calendar: calendar, repeatMinutes: repeatMinutes, days: days, limit: limit, locale: locale).reminders
    }

    /// "Apri Sbu Meds almeno una volta ogni N giorni": whole days covered by the plan, at least 1,
    /// when the slots run out within `warningDays`; `nil` when reminders are covered for longer.
    static func openEveryDays(_ result: Result, now: Date) -> Int? {
        guard let coveredUntil = result.coveredUntil else { return nil }
        let days = coveredUntil.timeIntervalSince(now) / 86_400
        guard days < Double(warningDays) else { return nil }
        return max(Int(days), 1)
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

    private static func reminder(for group: Group, repeat index: Int, repeatMinutes: Int, locale: Locale) -> PlannedReminder {
        let lines = group.doses.map { PlannedReminder.Line(name: $0.medicine.name, amount: $0.medicine.form.amountText($0.amount, locale: locale)) }
        return PlannedReminder(
            kind: .doses(repeat: index), fireDate: group.key.dueDate.addingTimeInterval(Double(index * repeatMinutes * 60)),
            personID: group.key.personID, personName: group.doses.first?.medicine.personName ?? "", dueDate: group.key.dueDate,
            lines: lines, doseKeys: group.doses.map(\.key.string),
            identifier: index == 0 ? group.identifier : "\(group.identifier)-r\(index)"
        )
    }

    private nonisolated struct GroupKey: Hashable {
        let personID: UUID
        let dueDate: Date
    }

    private nonisolated struct Group {
        let key: GroupKey
        let doses: [DoseItem]

        var identifier: String { PlannedReminder.groupIdentifier(personID: key.personID, dueDate: key.dueDate) }
    }
}
