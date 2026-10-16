import Foundation
import Testing
@testable import SbuFind

struct SignalTuningTests {
    let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "SignalTuningTests-\(UUID().uuidString)"))
    }

    /// The documented estimates, until Matteo's values replace them.
    @Test func theStandardValuesAreTheDocumentedEstimates() {
        let tuning = SignalTuning.standard
        #expect(tuning.farthestRSSI == -100)
        #expect(tuning.nearestRSSI == -40)
        #expect(tuning.smoothing == 0.3)
        let bands: [Int] = [tuning.warmFrom, tuning.hotFrom, tuning.veryCloseFrom]
        #expect(bands == [35, 60, 80])
        #expect(tuning.hysteresis == 5)
        let found: [Int] = [tuning.foundAt, tuning.foundRearmBelow]
        #expect(found == [90, 75])
        let silences: [TimeInterval] = [tuning.lostAfter, tuning.lostAlertForeground, tuning.lostAlertBackground]
        #expect(silences == [3, 15, 60])
        #expect(tuning.isConsistent)
    }

    @Test func theTypesReadTheCurrentTuning() {
        let tuning = SignalTuning.current
        #expect(Proximity.farthestRSSI == tuning.farthestRSSI)
        #expect(Warmth.lowerBound(of: .hot) == tuning.hotFrom)
        #expect(WarmthTracker.margin == tuning.hysteresis)
        #expect(FoundMoment.threshold == tuning.foundAt)
        #expect(TrackedDevice.lostAfter == tuning.lostAfter)
        #expect(LostAlert.silenceBeforeAlert == tuning.lostAlertForeground)
        #expect(SignalFilter.smoothing == tuning.smoothing)
    }

    @Test func nothingSavedIsStandard() {
        #expect(SignalTuning.load(from: defaults) == .standard)
    }

    @Test func savedValuesComeBack() {
        var tuning = SignalTuning.standard
        tuning.hotFrom = 55
        tuning.lostAlertBackground = 120
        tuning.save(to: defaults)
        #expect(SignalTuning.load(from: defaults) == tuning)
    }

    @Test func savingTheStandardValuesForgetsTheTuned() {
        var tuning = SignalTuning.standard
        tuning.hotFrom = 55
        tuning.save(to: defaults)
        SignalTuning.standard.save(to: defaults)
        #expect(defaults.data(forKey: "signalTuning") == nil)
    }

    @Test(arguments: [
        { (t: inout SignalTuning) in t.hotFrom = 30 },
        { (t: inout SignalTuning) in t.veryCloseFrom = 101 },
        { (t: inout SignalTuning) in t.farthestRSSI = -30 },
        { (t: inout SignalTuning) in t.foundRearmBelow = 95 },
        { (t: inout SignalTuning) in t.smoothing = 0 },
        { (t: inout SignalTuning) in t.lostAlertForeground = 2 },
        { (t: inout SignalTuning) in t.lostAlertBackground = 10 },
        { (t: inout SignalTuning) in t.hysteresis = -1 },
    ] as [@Sendable (inout SignalTuning) -> Void])
    func inconsistentValuesFallBackToStandard(change: @Sendable (inout SignalTuning) -> Void) {
        var tuning = SignalTuning.standard
        change(&tuning)
        #expect(!tuning.isConsistent)
        tuning.save(to: defaults)
        #expect(SignalTuning.load(from: defaults) == .standard)
    }

    @Test func aDamagedValueIsStandard() {
        defaults.set(Data("nope".utf8), forKey: "signalTuning")
        #expect(SignalTuning.load(from: defaults) == .standard)
    }
}
