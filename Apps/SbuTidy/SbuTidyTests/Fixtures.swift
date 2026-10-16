import Foundation
@testable import SbuTidy

/// A fixed calendar and dates, so tests never depend on the device's time zone or today.
nonisolated enum Fixtures {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome") ?? .gmt
        calendar.locale = Locale(identifier: "it_IT")
        return calendar
    }()

    static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) ?? .distantPast
    }

    /// Wednesday 14 October 2026, noon in Rome.
    static let now = date(2026, 10, 14)

    static func daysAgo(_ days: Double, from now: Date = now) -> Date {
        now.addingTimeInterval(-days * 86_400)
    }

    static func chore(
        _ name: String = "Pavimenti",
        room: String = "Cucina",
        roomID: UUID = UUID(),
        roomOrder: Int = 0,
        every value: Int = 7,
        _ unit: FrequencyUnit = .day,
        lastDone: Date,
        pausedAt: Date? = nil
    ) -> ChoreSnapshot {
        ChoreSnapshot(
            id: UUID(), name: name, roomID: roomID, roomName: room, roomOrder: roomOrder, effort: .medium,
            frequency: Frequency(value, unit), clock: ChoreClock(lastDone: lastDone, pausedAt: pausedAt)
        )
    }
}
