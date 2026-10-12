import Foundation

/// What Sbu Habits asks of Salute: only reads, never writes. `HealthKitReader` is the real one;
/// tests pass a fake with their own data.
protocol HealthReading: AnyObject {
    /// Whether this device has Salute at all.
    var isAvailable: Bool { get }

    /// Asks to read `measures`; iOS shows its sheet only for the ones never asked before.
    /// iOS never says whether reading was denied: a denied measure reads as zero.
    func requestAccess(toRead measures: Set<HealthMeasure>) async

    /// The total of `measure` within `interval`, in the measure's unit.
    func total(of measure: HealthMeasure, in interval: DateInterval) async throws -> Double
}
