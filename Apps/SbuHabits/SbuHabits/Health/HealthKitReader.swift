import Foundation
import HealthKit

/// Reads daily totals from Salute through HealthKit. Read only: the app never asks to write, and
/// nothing it reads leaves the iPhone or is kept, only the done marks it leads to.
final class HealthKitReader: HealthReading {
    private let store = HKHealthStore()

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAccess(toRead measures: Set<HealthMeasure>) async {
        guard isAvailable, measures.isEmpty == false else { return }
        // ponytail: a failed request leaves the habit marked by hand, as a denial does.
        try? await store.requestAuthorization(toShare: [], read: Set(measures.map(Self.sampleType)))
    }

    func total(of measure: HealthMeasure, in interval: DateInterval) async throws -> Double {
        let predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: .strictStartDate)
        let type = Self.quantityType(of: measure)
        // Statistics merge iPhone and Watch without counting the same steps twice.
        let descriptor = HKStatisticsQueryDescriptor(predicate: .quantitySample(type: type, predicate: predicate), options: .cumulativeSum)
        do {
            let statistics = try await descriptor.result(for: store)
            return statistics?.sumQuantity()?.doubleValue(for: Self.unit(of: measure)) ?? 0
        } catch let error as HKError where error.code == .errorNoData {
            return 0
        }
    }

    private static func sampleType(of measure: HealthMeasure) -> HKObjectType {
        quantityType(of: measure)
    }

    private static func quantityType(of measure: HealthMeasure) -> HKQuantityType {
        switch measure {
        case .steps: HKQuantityType(.stepCount)
        }
    }

    /// The unit `HealthMeasure` keeps goals in.
    private static func unit(of measure: HealthMeasure) -> HKUnit {
        switch measure {
        case .steps: .count()
        }
    }
}
