import Foundation
import HealthKit

/// Reads daily totals from Salute through HealthKit. Read only: the app never asks to write, and
/// nothing it reads leaves the iPhone or is kept, only the done marks it leads to.
final class HealthKitReader: HealthReading {
    private let store = HKHealthStore()
    private var queries: [HKObserverQuery] = []

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAccess(toRead measures: Set<HealthMeasure>) async {
        guard isAvailable, measures.isEmpty == false else { return }
        // ponytail: a failed request leaves the habit marked by hand, as a denial does.
        try? await store.requestAuthorization(toShare: [], read: Set<HKObjectType>(measures.map(Self.sampleType)))
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

    func observe(_ measures: Set<HealthMeasure>, onChange: @escaping @MainActor @Sendable () async -> Void) {
        queries.forEach(store.stop)
        queries = []
        guard isAvailable else { return }
        let followed = measures.map(Self.sampleType)
        // With no linked habit, nothing wakes the app.
        Self.deliverInBackground(followed, stopping: HealthMeasure.allCases.filter { measures.contains($0) == false }.map(Self.sampleType), in: store)
        for type in followed {
            let query = Self.observerQuery(for: type, onChange: onChange)
            store.execute(query)
            queries.append(query)
        }
    }

    /// Outside the main actor, so HealthKit can call the empty completions on its own queue.
    private nonisolated static func deliverInBackground(_ types: [HKSampleType], stopping others: [HKSampleType], in store: HKHealthStore) {
        guard types.isEmpty == false else {
            store.disableAllBackgroundDelivery { _, _ in }
            return
        }
        for type in others {
            store.disableBackgroundDelivery(for: type) { _, _ in }
        }
        for type in types {
            // Hourly is the most HealthKit grants for steps; enough to mark a habit and spare the battery.
            store.enableBackgroundDelivery(for: type, frequency: .hourly) { _, _ in }
        }
    }

    /// Built outside the main actor: HealthKit calls the handler on its own queue.
    private nonisolated static func observerQuery(for type: HKSampleType, onChange: @escaping @MainActor @Sendable () async -> Void) -> HKObserverQuery {
        HKObserverQuery(sampleType: type, predicate: nil) { _, completionHandler, error in
            guard error == nil else {
                completionHandler()
                return
            }
            // HealthKit's handler is not marked Sendable but may be called from any thread.
            nonisolated(unsafe) let done = completionHandler
            Task { @MainActor in
                await onChange()
                // Tells HealthKit the update is handled, so it keeps waking the app.
                done()
            }
        }
    }

    private static func sampleType(of measure: HealthMeasure) -> HKSampleType {
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
