import Foundation

extension TripLogFile {
    /// Three trips for screenshots and previews: a drive, a ride and a sail, the last days before `now`.
    nonisolated static func demo(now: Date) -> TripLogFile {
        func trip(daysAgo: Double, kilometers: Double, minutes: Double, topKilometersPerHour: Double) -> TripRecord {
            let end = now.addingTimeInterval(-daysAgo * 86_400)
            return TripRecord(
                startedAt: end.addingTimeInterval(-minutes * 60 - 300),
                endedAt: end,
                distance: kilometers * 1000,
                movingTime: minutes * 60,
                maxSpeed: topKilometersPerHour / 3.6
            )
        }
        return TripLogFile(trips: [
            trip(daysAgo: 1, kilometers: 42.7, minutes: 38, topKilometersPerHour: 118),
            trip(daysAgo: 3, kilometers: 18.2, minutes: 54, topKilometersPerHour: 34),
            trip(daysAgo: 6, kilometers: 9.6, minutes: 41, topKilometersPerHour: 22),
        ])
    }
}
