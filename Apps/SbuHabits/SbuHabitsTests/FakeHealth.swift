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
}
