import Foundation
@testable import SbuMeds

/// A fixed calendar and dates, so tests never depend on the device's time zone or today.
nonisolated enum Fixtures {
    static let calendar = calendar(in: "Europe/Rome")

    static func calendar(in zone: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: zone) ?? .gmt
        calendar.locale = Locale(identifier: "it_IT")
        return calendar
    }

    static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0, calendar: Calendar = calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) ?? .distantPast
    }

    /// Friday 16 October 2026.
    static let today = Day(year: 2026, month: 10, day: 16)

    /// Friday 16 October 2026, 12:00 in Rome.
    static let now = date(2026, 10, 16)

    static func day(_ offset: Int) -> Day {
        today.adding(days: offset, in: calendar)
    }

    static func medicine(
        _ name: String = "Ramipril",
        id: UUID = UUID(),
        times: [DoseTime] = [DoseTime(hour: 8)],
        frequency: Frequency = .daily,
        start: Day = today,
        records: [DoseRecordSnapshot] = [],
        stock: Double? = nil,
        threshold: Double? = nil,
        person: UUID = UUID(),
        personName: String = "Io"
    ) -> MedicineSnapshot {
        MedicineSnapshot(
            id: id, personID: person, personName: personName, name: name,
            schedule: Schedule(frequency: frequency, times: times, start: start),
            stock: stock, refillThreshold: threshold, records: records
        )
    }
}
