import Foundation

/// One fuel-up as the calculators see it: canonical units, no SwiftData.
nonisolated struct FillRecord: Equatable, Sendable, Identifiable {
    var id = UUID()
    var date: Date
    /// The odometer reading, always in kilometres.
    var odometerKm: Double
    /// The fuel put in, always in litres.
    var litres: Double
    /// Whether the tank was filled to the brim: only full tanks close a segment.
    var isFull = true
    /// Whether one or more fuel-ups before this one were never logged: the chain breaks here.
    var missedPrevious = false
    /// What the fuel-up cost; 0 for a free or rewards fill.
    var totalPrice: Decimal = 0
}
