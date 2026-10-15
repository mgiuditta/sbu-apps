import Foundation

/// Full-to-full consumption.
///
/// A segment runs from one full tank to the next. Partial fills in between add their fuel to the
/// segment; the fuel of the opening full tank does not count, it was burned before. A fuel-up
/// marked "missed previous" breaks the chain: the fuel of the missed fill is unknown, so no segment
/// closes there, and a new chain starts if that fuel-up is itself a full tank. Fuel-ups are taken
/// in odometer order, whatever order they were entered in. The average is the distance of all closed
/// segments over their fuel, never an average of the segments' averages.
nonisolated struct ConsumptionCalculator: Sendable {
    let segments: [ConsumptionSegment]

    init(_ fills: [FillRecord]) {
        segments = Self.segments(fills)
    }

    /// Kilometres per litre over every closed segment, or `nil` until the second full tank.
    var averageKmPerLitre: Double? {
        let litres = segments.reduce(0) { $0 + $1.litres }
        guard litres > 0 else { return nil }
        return segments.reduce(0) { $0 + $1.distanceKm } / litres
    }

    /// The most recent segment by odometer.
    var last: ConsumptionSegment? { segments.last }
    /// The segment with the most kilometres per litre.
    var best: ConsumptionSegment? { segments.max { $0.kmPerLitre < $1.kmPerLitre } }
    /// The segment with the fewest kilometres per litre.
    var worst: ConsumptionSegment? { segments.min { $0.kmPerLitre < $1.kmPerLitre } }

    /// The segment a fuel-up closes, if it closes one.
    func segment(closedBy id: UUID) -> ConsumptionSegment? {
        segments.first { $0.endID == id }
    }

    static func segments(_ fills: [FillRecord]) -> [ConsumptionSegment] {
        let ordered = fills.sorted { ($0.odometerKm, $0.date) < ($1.odometerKm, $1.date) }
        var segments: [ConsumptionSegment] = []
        var openingKm: Double?
        var litres = 0.0
        for fill in ordered {
            if fill.missedPrevious {
                openingKm = fill.isFull ? fill.odometerKm : nil
                litres = 0
                continue
            }
            guard let start = openingKm else {
                if fill.isFull { openingKm = fill.odometerKm }
                continue
            }
            litres += fill.litres
            guard fill.isFull else { continue }
            if fill.odometerKm > start, litres > 0 {
                segments.append(ConsumptionSegment(startKm: start, endKm: fill.odometerKm, litres: litres, endDate: fill.date, endID: fill.id))
            }
            openingKm = fill.odometerKm
            litres = 0
        }
        return segments
    }
}
