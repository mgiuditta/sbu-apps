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
        do {
            if let type = Self.quantityType(of: measure) {
                let predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: .strictStartDate)
                // Statistics merge iPhone and Watch without counting the same steps twice.
                let descriptor = HKStatisticsQueryDescriptor(predicate: .quantitySample(type: type, predicate: predicate), options: .cumulativeSum)
                let statistics = try await descriptor.result(for: store)
                return statistics?.sumQuantity()?.doubleValue(for: Self.unit(of: measure)) ?? 0
            }
            // Mindful sessions are periods, not amounts: any that overlaps the day counts in part.
            let predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
            let descriptor = HKSampleQueryDescriptor(predicates: [.categorySample(type: HKCategoryType(.mindfulSession), predicate: predicate)], sortDescriptors: [])
            let sessions = try await descriptor.result(for: store)
            return MindfulMinutes.total(of: sessions.map { DateInterval(start: $0.startDate, end: max($0.startDate, $0.endDate)) }, within: interval)
        } catch let error as HKError where error.code == .errorNoData {
            return 0
        }
    }

    private static func sampleType(of measure: HealthMeasure) -> HKObjectType {
        quantityType(of: measure) ?? HKCategoryType(.mindfulSession)
    }

    /// `nil` for mindful minutes, which Salute keeps as sessions.
    private static func quantityType(of measure: HealthMeasure) -> HKQuantityType? {
        switch measure {
        case .steps: HKQuantityType(.stepCount)
        case .water: HKQuantityType(.dietaryWater)
        case .mindfulMinutes: nil
        case .walkingRunningDistance: HKQuantityType(.distanceWalkingRunning)
        case .activeEnergy: HKQuantityType(.activeEnergyBurned)
        }
    }

    /// The unit `HealthMeasure` keeps goals in.
    private static func unit(of measure: HealthMeasure) -> HKUnit {
        switch measure {
        case .steps: .count()
        case .water: .literUnit(with: .milli)
        case .mindfulMinutes: .minute()
        case .walkingRunningDistance: .meter()
        case .activeEnergy: .kilocalorie()
        }
    }
}
