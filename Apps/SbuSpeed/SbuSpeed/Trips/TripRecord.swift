import Foundation

/// A saved trip: only numbers and times, never a position.
nonisolated struct TripRecord: Codable, Hashable, Identifiable, Sendable {
    var id: UUID
    var startedAt: Date
    var endedAt: Date
    /// Metres.
    var distance: Double
    /// Seconds spent moving.
    var movingTime: TimeInterval
    /// Metres per second.
    var maxSpeed: Double

    /// Metres per second over the time spent moving, as on the tool screen.
    var averageSpeed: Double { movingTime > 0 ? distance / movingTime : 0 }

    /// The time spent moving, in whole seconds.
    var movingDuration: Duration { .seconds(Int(movingTime)) }

    init(id: UUID = UUID(), startedAt: Date, endedAt: Date, distance: Double, movingTime: TimeInterval, maxSpeed: Double) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.distance = distance
        self.movingTime = movingTime
        self.maxSpeed = maxSpeed
    }

    /// The trip to save at Salva e azzera, or `nil` when it went nowhere: nothing to keep.
    /// A trip from 1.0 has no times: it ends now and starts its moving time earlier.
    init?(trip: Trip, now: Date) {
        guard trip.distance > 0 else { return nil }
        let endedAt = trip.endedAt ?? now
        self.init(
            startedAt: trip.startedAt ?? endedAt.addingTimeInterval(-trip.movingTime),
            endedAt: endedAt,
            distance: trip.distance,
            movingTime: trip.movingTime,
            maxSpeed: trip.maxSpeed
        )
    }
}
