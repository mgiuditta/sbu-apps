import Foundation
@testable import SbuHabits

/// Salute with made-up samples: each total sums the samples that start inside the interval, as
/// HealthKit does. A denied measure reads as zero, as iOS hides a denial.
final class FakeHealth: HealthReading {
    struct Sample {
        let measure: HealthMeasure
        let date: Date
        let amount: Double
    }

    var isAvailable = true
    var samples: [Sample] = []
    var denied: Set<HealthMeasure> = []
    private(set) var requested: [Set<HealthMeasure>] = []
    private(set) var intervals: [DateInterval] = []
    /// Every set of measures followed, in order; the last one is followed now.
    private(set) var observed: [Set<HealthMeasure>] = []
    private var onChange: (@MainActor () async -> Void)?

    func requestAccess(toRead measures: Set<HealthMeasure>) async {
        requested.append(measures)
    }

    func total(of measure: HealthMeasure, in interval: DateInterval) async throws -> Double {
        intervals.append(interval)
        guard denied.contains(measure) == false else { return 0 }
        return samples
            .filter { $0.measure == measure && $0.date >= interval.start && $0.date < interval.end }
            .reduce(0) { $0 + $1.amount }
    }

    func observe(_ measures: Set<HealthMeasure>, onChange: @escaping @MainActor @Sendable () async -> Void) {
        observed.append(measures)
        self.onChange = measures.isEmpty ? nil : onChange
    }

    /// New data in Salute, as background delivery brings it.
    func deliver(_ sample: Sample) async {
        samples.append(sample)
        await onChange?()
    }
}
