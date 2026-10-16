import Foundation
import Testing
@testable import SbuFind

struct ScanModelTests {
    let defaults: UserDefaults
    let scanner = FakeScanner()

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "ScanModelTests-\(UUID().uuidString)"))
    }

    private func makeModel() -> ScanModel {
        ScanModel(scanner: scanner, defaults: defaults)
    }

    @Test func startsWaitingForBluetoothWithAnEmptyList() {
        let model = makeModel()
        #expect(model.state == .starting)
        #expect(model.devices.isEmpty)
        #expect(model.hiddenUnnamedCount == 0)
        #expect(model.showsUnnamed == false)
    }

    @Test func soundStartsOffAndVibrationOn() {
        let model = makeModel()
        #expect(model.playsSound == false)
        #expect(model.vibrates == true)
    }

    @Test func soundAndVibrationAreSaved() {
        let model = makeModel()
        model.playsSound = true
        model.vibrates = false
        let reopened = ScanModel(scanner: FakeScanner(), defaults: defaults)
        #expect(reopened.playsSound)
        #expect(!reopened.vibrates)
    }

    @Test(arguments: [("NO", false), ("YES", true), ("0", false), ("1", true)])
    func aLaunchArgumentStringSetsVibration(raw: String, vibrates: Bool) {
        defaults.set(raw, forKey: "vibrates")
        #expect(makeModel().vibrates == vibrates)
    }

    @Test func advertisementsReachTheScreenAtTheNextRefresh() {
        let model = makeModel()
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture(device: 1, name: "Buds", rssi: -70)))
        #expect(model.devices.isEmpty)

        model.refresh(at: Advertisement.start)
        #expect(model.devices.map(\.name) == ["Buds"])
    }

    @Test func theListIsSortedAndHidesTheUnnamed() {
        let model = makeModel()
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture(device: 1, name: "Lontano", rssi: -90)))
        model.handle(.advertisement(.fixture(device: 2, name: "Vicino", rssi: -45)))
        model.handle(.advertisement(.fixture(device: 3, name: nil, rssi: -40)))
        model.refresh(at: Advertisement.start)

        #expect(model.devices.map(\.name) == ["Vicino", "Lontano"])
        #expect(model.hiddenUnnamedCount == 1)
    }

    @Test func showingTheUnnamedListsThemAtOnceAndIsSaved() {
        let model = makeModel()
        model.handle(.advertisement(.fixture(device: 1, name: nil, rssi: -40)))
        model.refresh(at: Advertisement.start)
        #expect(model.devices.isEmpty)

        model.showsUnnamed = true

        #expect(model.devices.count == 1)
        #expect(model.hiddenUnnamedCount == 0)
        #expect(defaults.bool(forKey: "showsUnnamed"))
        #expect(ScanModel(scanner: FakeScanner(), defaults: defaults).showsUnnamed)
    }

    @Test(arguments: BluetoothState.allCases.filter { $0 != .ready })
    func losingBluetoothEmptiesTheList(state: BluetoothState) {
        let model = makeModel()
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture()))
        model.refresh(at: Advertisement.start)
        #expect(model.devices.count == 1)

        model.handle(.state(state))

        #expect(model.state == state)
        #expect(model.devices.isEmpty)
        model.refresh(at: Advertisement.start)
        #expect(model.devices.isEmpty)
    }

    @Test func aSilentDeviceLeavesAtARefresh() {
        let model = makeModel()
        model.handle(.advertisement(.fixture(device: 1, name: "Muto")))
        model.handle(.advertisement(.fixture(device: 2, name: "Parla", after: 12)))
        model.refresh(at: Advertisement.start.addingTimeInterval(12))
        #expect(model.devices.map(\.name) == ["Parla"])
    }

    @Test func rescanForgetsEveryDeviceAndRestartsTheScanner() {
        let model = makeModel()
        model.handle(.advertisement(.fixture()))
        model.refresh(at: Advertisement.start)

        model.rescan()

        #expect(model.devices.isEmpty)
        #expect(scanner.restarts == 1)
        model.refresh(at: Advertisement.start)
        #expect(model.devices.isEmpty)
    }

    @Test func trackingStartsFromWhatWasHeard() throws {
        let model = makeModel()
        model.handle(.advertisement(.fixture(device: 1, name: "Buds", rssi: -55)))
        model.track(Advertisement.testID(1), at: Advertisement.start.addingTimeInterval(1))

        let tracked = try #require(model.tracked)
        #expect(tracked.device.name == "Buds")
        #expect(tracked.warmth == .hot)
        #expect(tracked.silence == 1)
        #expect(!tracked.isLost)
    }

    @Test func trackingAnUnknownDeviceShowsNothing() {
        let model = makeModel()
        model.track(Advertisement.testID(9), at: Advertisement.start)
        #expect(model.tracked == nil)
    }

    @Test func theTrackedWordHoldsOnAThresholdAndFollowsBigMoves() throws {
        let model = makeModel()
        var second = 0.0
        func hear(_ rssi: Int) {
            // A full window of the same reading, so the filtered signal settles on it.
            for _ in 0..<SignalFilter.window * 4 {
                second += 0.1
                model.handle(.advertisement(.fixture(rssi: rssi, after: second)))
            }
            model.refresh(at: Advertisement.start.addingTimeInterval(second))
        }
        hear(-64)
        model.track(Advertisement.testID(1), at: Advertisement.start.addingTimeInterval(second))
        #expect(model.tracked?.warmth == .hot)

        hear(-66) // Proximity 57: below Caldo, inside the margin.
        #expect(model.tracked?.warmth == .hot)

        hear(-75) // Proximity 42.
        #expect(model.tracked?.warmth == .warm)
    }

    @Test func aSilentTrackedDeviceIsKeptAndSaysForHowLong() throws {
        let model = makeModel()
        model.handle(.advertisement(.fixture(rssi: -50)))
        model.track(Advertisement.testID(1), at: Advertisement.start)

        model.refresh(at: Advertisement.start.addingTimeInterval(2))
        #expect(model.tracked?.isLost == false)

        model.refresh(at: Advertisement.start.addingTimeInterval(4))
        #expect(model.tracked?.isLost == true)

        // Gone from the list after ten seconds, still on the finder.
        model.refresh(at: Advertisement.start.addingTimeInterval(30))
        #expect(model.devices.isEmpty)
        let tracked = try #require(model.tracked)
        #expect(tracked.silence == 30)
        #expect(tracked.warmth == .veryClose)
        #expect(tracked.device.signal == -50)
    }

    @Test func aTrackedDeviceHeardAgainIsFoundAgain() throws {
        let model = makeModel()
        model.handle(.advertisement(.fixture(rssi: -50)))
        model.track(Advertisement.testID(1), at: Advertisement.start)
        model.refresh(at: Advertisement.start.addingTimeInterval(20))
        #expect(model.tracked?.isLost == true)

        model.handle(.advertisement(.fixture(rssi: -90, after: 21)))
        model.refresh(at: Advertisement.start.addingTimeInterval(21))

        let tracked = try #require(model.tracked)
        #expect(!tracked.isLost)
        #expect(tracked.device.signal == -90)
        #expect(tracked.warmth == .cold)
    }

    @Test func losingBluetoothKeepsTheTrackedDeviceSilent() {
        let model = makeModel()
        model.handle(.advertisement(.fixture(rssi: -50)))
        model.track(Advertisement.testID(1), at: Advertisement.start)
        model.handle(.state(.poweredOff))
        model.refresh(at: Advertisement.start.addingTimeInterval(5))
        #expect(model.tracked?.isLost == true)
    }

    @Test func stopTrackingForgetsIt() {
        let model = makeModel()
        model.handle(.advertisement(.fixture()))
        model.track(Advertisement.testID(1), at: Advertisement.start)
        model.stopTracking()
        #expect(model.tracked == nil)
        model.refresh(at: Advertisement.start)
        #expect(model.tracked == nil)
    }

    @Test func trackingAnotherDeviceStartsItsWordAfresh() {
        let model = makeModel()
        model.handle(.advertisement(.fixture(device: 1, rssi: -45)))
        model.handle(.advertisement(.fixture(device: 2, rssi: -66)))
        model.track(Advertisement.testID(1), at: Advertisement.start)
        #expect(model.tracked?.warmth == .veryClose)

        model.track(Advertisement.testID(2), at: Advertisement.start)
        #expect(model.tracked?.warmth == .warm)
    }

    @Test func runReadsTheScannerUntilItFinishesThenStopsIt() async {
        let model = makeModel()
        let running = Task {
            await model.run()
        }
        await Task.yield()
        scanner.send(.state(.ready))
        scanner.send(.advertisement(.fixture()))
        scanner.finish()
        await running.value

        #expect(model.state == .ready)
        #expect(scanner.stops == 1)
        model.refresh(at: Advertisement.start)
        #expect(model.devices.count == 1)
    }

    @Test func cancellingRunStopsTheScanner() async {
        let model = makeModel()
        let running = Task {
            await model.run()
        }
        await Task.yield()
        running.cancel()
        await running.value
        #expect(scanner.stops == 1)
    }
}
