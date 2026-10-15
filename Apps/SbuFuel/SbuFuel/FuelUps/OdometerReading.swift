import Foundation

/// An odometer reading already logged, fuel-up or service, for the neighbour check.
nonisolated struct OdometerReading: Equatable, Sendable {
    enum Source: Sendable {
        case fuelUp
        case service
    }

    var id: UUID
    var date: Date
    var km: Double
    var source: Source
}
