import Foundation

/// Where the odometer is, and how fast it moves, from the readings you logged.
nonisolated struct OdometerEstimate: Equatable, Sendable {
    /// The highest reading logged, in kilometres.
    let lastKm: Double
    /// When that reading was logged.
    let lastDate: Date
    /// Average kilometres a day between the first and the last reading, if they are at least a week apart.
    let kmPerDay: Double?

    /// The shortest span that gives a usable pace: a single trip would over-estimate it.
    static let minimumDays = 7.0

    init?(readings: [(date: Date, km: Double)]) {
        let ordered = readings.sorted { $0.km < $1.km }
        guard let first = ordered.first, let last = ordered.last else { return nil }
        lastKm = last.km
        lastDate = last.date
        let days = last.date.timeIntervalSince(first.date) / 86_400
        kmPerDay = days >= Self.minimumDays && last.km > first.km ? (last.km - first.km) / days : nil
    }

    /// The day the odometer should reach `km` at the current pace; `lastDate` if it already has.
    func date(reaching km: Double) -> Date? {
        if km <= lastKm { return lastDate }
        guard let kmPerDay, kmPerDay > 0 else { return nil }
        return lastDate.addingTimeInterval((km - lastKm) / kmPerDay * 86_400)
    }
}
