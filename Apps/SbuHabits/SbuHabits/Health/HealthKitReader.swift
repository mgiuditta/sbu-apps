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
        try? await store.requestAuthorization(toShare: [], read: Set(measures.flatMap(Self.readTypes)))
    }

    func total(of measure: HealthMeasure, in interval: DateInterval) async throws -> Double {
        do {
            switch measure {
            case .mindfulMinutes:
                // Mindful sessions are periods, not amounts: any that overlaps the day counts in part.
                let sessions = try await periods(of: HKCategoryType(.mindfulSession), in: interval)
                return MindfulMinutes.total(of: sessions.map(\.interval), within: interval)
            case .sleep:
                // A night started the day before: read back far enough to see all of it.
                let read = DateInterval(start: interval.start.addingTimeInterval(-SleepTotal.lookBack), end: interval.end)
                let asleep = HKCategoryValueSleepAnalysis.allAsleepValues.map(\.rawValue)
                let periods = try await periods(of: HKCategoryType(.sleepAnalysis), in: read)
                return SleepTotal.total(of: periods.filter { asleep.contains($0.value) }.map(\.interval), wakingWithin: interval)
            case .activityRings:
                return Double(try await rings(on: interval.start)?.closed ?? 0)
            default:
                return try await sum(of: measure, in: interval)
            }
        } catch let error as HKError where error.code == .errorNoData {
            return 0
        }
    }

    /// Statistics merge iPhone and Watch without counting the same steps twice.
    private func sum(of measure: HealthMeasure, in interval: DateInterval) async throws -> Double {
        guard let type = Self.quantityType(of: measure), let unit = Self.unit(of: measure) else { return 0 }
        let predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: .strictStartDate)
        let descriptor = HKStatisticsQueryDescriptor(predicate: .quantitySample(type: type, predicate: predicate), options: .cumulativeSum)
        let statistics = try await descriptor.result(for: store)
        return statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0
    }

    /// The category samples overlapping `interval`, as periods with their value.
    private func periods(of type: HKCategoryType, in interval: DateInterval) async throws -> [(interval: DateInterval, value: Int)] {
        let predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let descriptor = HKSampleQueryDescriptor(predicates: [.categorySample(type: type, predicate: predicate)], sortDescriptors: [])
        return try await descriptor.result(for: store).map {
            (DateInterval(start: $0.startDate, end: max($0.startDate, $0.endDate)), $0.value)
        }
    }

    /// The rings of the calendar day the logical day starts on: the Watch keeps them by calendar day.
    private func rings(on day: Date) async throws -> ActivityRings? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.era, .year, .month, .day], from: day)
        components.calendar = calendar
        let descriptor = HKActivitySummaryQueryDescriptor(predicate: HKQuery.predicateForActivitySummary(with: components))
        guard let summary = try await descriptor.result(for: store).first else { return nil }
        let inMinutes = summary.activityMoveMode == .appleMoveTime
        return ActivityRings(
            move: inMinutes ? summary.appleMoveTime.doubleValue(for: .minute()) : summary.activeEnergyBurned.doubleValue(for: .kilocalorie()),
            moveGoal: inMinutes ? summary.appleMoveTimeGoal.doubleValue(for: .minute()) : summary.activeEnergyBurnedGoal.doubleValue(for: .kilocalorie()),
            exercise: summary.appleExerciseTime.doubleValue(for: .minute()),
            exerciseGoal: summary.exerciseTimeGoal?.doubleValue(for: .minute()) ?? 0,
            stand: summary.appleStandHours.doubleValue(for: .count()),
            standGoal: summary.standHoursGoal?.doubleValue(for: .count()) ?? 0
        )
    }

    func observe(_ measures: Set<HealthMeasure>, onChange: @escaping @MainActor @Sendable () async -> Void) {
        queries.forEach(store.stop)
        queries = []
        guard isAvailable else { return }
        let followed = Set(measures.flatMap(Self.sampleTypes))
        let others = Set(HealthMeasure.allCases.flatMap(Self.sampleTypes)).subtracting(followed)
        // With no linked habit, nothing wakes the app.
        Self.deliverInBackground(Array(followed), stopping: Array(others), in: store)
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

    /// The samples whose changes can reach the measure's total: what the app follows.
    /// The rings are a summary, not samples: their Move, Exercise and Stand data stand in.
    private static func sampleTypes(of measure: HealthMeasure) -> [HKSampleType] {
        switch measure {
        case .mindfulMinutes: [HKCategoryType(.mindfulSession)]
        case .sleep: [HKCategoryType(.sleepAnalysis)]
        case .activityRings: [HKQuantityType(.activeEnergyBurned), HKQuantityType(.appleExerciseTime), HKCategoryType(.appleStandHour)]
        default: quantityType(of: measure).map { [$0] } ?? []
        }
    }

    /// What reading the measure asks for: its samples, and the rings' summary.
    private static func readTypes(of measure: HealthMeasure) -> [HKObjectType] {
        measure == .activityRings ? sampleTypes(of: measure) + [HKObjectType.activitySummaryType()] : sampleTypes(of: measure)
    }

    /// `nil` for the measures Salute keeps as periods or as a summary.
    private static func quantityType(of measure: HealthMeasure) -> HKQuantityType? {
        switch measure {
        case .steps: HKQuantityType(.stepCount)
        case .water: HKQuantityType(.dietaryWater)
        case .walkingRunningDistance: HKQuantityType(.distanceWalkingRunning)
        case .activeEnergy: HKQuantityType(.activeEnergyBurned)
        case .cyclingDistance: HKQuantityType(.distanceCycling)
        case .swimmingDistance: HKQuantityType(.distanceSwimming)
        case .flightsClimbed: HKQuantityType(.flightsClimbed)
        case .exerciseMinutes: HKQuantityType(.appleExerciseTime)
        case .standMinutes: HKQuantityType(.appleStandTime)
        case .timeInDaylight: HKQuantityType(.timeInDaylight)
        case .mindfulMinutes, .sleep, .activityRings: nil
        }
    }

    /// The unit `HealthMeasure` keeps goals in, for the measures summed from quantities.
    private static func unit(of measure: HealthMeasure) -> HKUnit? {
        switch measure {
        case .steps, .flightsClimbed: .count()
        case .water: .literUnit(with: .milli)
        case .walkingRunningDistance, .cyclingDistance, .swimmingDistance: .meter()
        case .activeEnergy: .kilocalorie()
        case .exerciseMinutes, .standMinutes, .timeInDaylight: .minute()
        case .mindfulMinutes, .sleep, .activityRings: nil
        }
    }
}
