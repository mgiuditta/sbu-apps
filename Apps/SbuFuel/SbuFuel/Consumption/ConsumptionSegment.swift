import Foundation

/// The road between two full tanks, with all the fuel put in after the first one.
nonisolated struct ConsumptionSegment: Equatable, Sendable {
    let startKm: Double
    let endKm: Double
    /// Fuel of the full tank that closes the segment plus every partial fill inside it.
    let litres: Double
    /// When the closing full tank was made.
    let endDate: Date
    /// The fuel-up that closes the segment.
    let endID: UUID

    var distanceKm: Double { endKm - startKm }
    var kmPerLitre: Double { distanceKm / litres }
}
