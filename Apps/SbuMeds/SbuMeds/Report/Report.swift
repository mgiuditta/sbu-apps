import Foundation

/// The report for the doctor, as Medisafe's: adherence over the period, each medicine's counts,
/// then day by day every dose with its time and what happened. Doses still to come are left out.
nonisolated struct Report: Hashable, Sendable {
    nonisolated struct MedicineLine: Hashable, Sendable {
        let name: String
        let strength: String
        let schedule: String
        let adherence: Adherence
    }

    nonisolated struct Entry: Hashable, Sendable {
        let dueDate: Date
        let name: String
        let amount: String
        let state: DoseState
        let isExtra: Bool
    }

    nonisolated struct ReportDay: Hashable, Sendable {
        let day: Day
        let entries: [Entry]
    }

    let personName: String
    let first: Day
    let last: Day
    let adherence: Adherence
    let medicines: [MedicineLine]
    /// Days with at least one dose, earliest first.
    let days: [ReportDay]

    init(personName: String, medicines: [MedicineSnapshot], from first: Day, through last: Day, now: Date, calendar: Calendar, locale: Locale = .current) {
        self.personName = personName
        self.first = min(first, last)
        self.last = max(first, last)
        let sorted = medicines.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        adherence = Adherence(sorted, from: self.first, through: self.last, now: now, calendar: calendar)
        self.medicines = sorted.map {
            MedicineLine(
                name: $0.name, strength: $0.strength, schedule: ScheduleText.summary(of: $0.schedule, calendar: calendar),
                adherence: Adherence([$0], from: first, through: last, now: now, calendar: calendar)
            )
        }
        var days: [ReportDay] = []
        var day = self.first
        let today = Day(now, calendar: calendar)
        while day <= min(self.last, today) {
            let entries = DayPlan(sorted, day: day, now: now, calendar: calendar).items
                .filter { !$0.state.isToTake }
                .map { Entry(dueDate: $0.dueDate, name: $0.medicine.name, amount: $0.medicine.form.amountText($0.amount, locale: locale), state: $0.state, isExtra: $0.isExtra) }
            if !entries.isEmpty { days.append(ReportDay(day: day, entries: entries)) }
            day = day.adding(days: 1, in: calendar)
        }
        self.days = days
    }

    /// "Rapporto Nonna Rita 20260917-20261016.pdf": safe for any file system.
    var fileName: String {
        let name = personName.components(separatedBy: CharacterSet(charactersIn: "/\\:?%*|\"<>")).joined()
        return "\(String(localized: "Rapporto")) \(name) \(String(first.key))-\(String(last.key)).pdf"
    }
}
