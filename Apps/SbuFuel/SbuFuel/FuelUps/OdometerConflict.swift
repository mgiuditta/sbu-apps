import Foundation

/// Why a reading does not sit between its neighbours, naming the entry it clashes with.
nonisolated enum OdometerConflict: Equatable, Sendable {
    /// An earlier entry already has a higher reading.
    case earlierIsHigher(OdometerReading)
    /// A later entry has a lower reading.
    case laterIsLower(OdometerReading)
    /// Another fuel-up has the same reading.
    case sameReading(OdometerReading)

    var reading: OdometerReading {
        switch self {
        case let .earlierIsHigher(reading), let .laterIsLower(reading), let .sameReading(reading): reading
        }
    }

    /// Finds the clash nearest in time, if any. Entries of the same day can be in any order,
    /// and the entry being edited (`id`) is left out.
    static func check(id: UUID?, date: Date, km: Double, among readings: [OdometerReading], calendar: Calendar) -> OdometerConflict? {
        let day = calendar.startOfDay(for: date)
        let conflicts = readings.filter { $0.id != id }.compactMap { other -> OdometerConflict? in
            let otherDay = calendar.startOfDay(for: other.date)
            if other.source == .fuelUp, abs(other.km - km) < 0.5 { return .sameReading(other) }
            if otherDay < day, other.km > km { return .earlierIsHigher(other) }
            if otherDay > day, other.km < km { return .laterIsLower(other) }
            return nil
        }
        return conflicts.min { abs($0.reading.date.timeIntervalSince(date)) < abs($1.reading.date.timeIntervalSince(date)) }
    }
}
