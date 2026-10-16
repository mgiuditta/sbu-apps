import Foundation
import Testing
@testable import SbuFind

struct ScanModelTests {
    let defaults: UserDefaults
    let scanner = FakeScanner()
    let notifier = FakeLostNotifier()
    let clock = TestClock()

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "ScanModelTests-\(UUID().uuidString)"))
    }

    private func makeModel() -> ScanModel {
        ScanModel(scanner: scanner, notifier: notifier, defaults: defaults, clock: clock.read)
    }

    @Test func startsWaitingForBluetoothWithAnEmptyList() {
        let model = makeModel()
        #expect(model.state == .starting)
        #expect(model.devices.isEmpty)
        #expect(model.hiddenUnnamedCount == 0)
        #expect(model.showsUnnamed == false)
    }

    @Test func theScanCardShowsWhenBluetoothBecomesReady() {
        let model = makeModel()
        #expect(!model.scanCard.isVisible)
        model.handle(.state(.ready))
        #expect(model.scanCard.isVisible)
        model.closeScanCard()
        model.handle(.state(.ready))
        #expect(!model.scanCard.isVisible)
        model.handle(.state(.poweredOff))
        model.handle(.state(.ready))
        #expect(model.scanCard.isVisible)
    }

    @Test func searchAgainShowsTheScanCardAgain() {
        let model = makeModel()
        model.handle(.state(.ready))
        model.closeScanCard()
        model.rescan()
        #expect(model.scanCard.isVisible)
    }

    @Test func watchingAsksForNotificationsAndAlertsOnceWhenTheDeviceFallsSilent() async {
        let model = makeModel()
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture(name: "Buds")))
        await model.watch(Advertisement.testID(1))
        #expect(notifier.requests == 1)
        #expect(model.watchedID == Advertisement.testID(1))

        model.refresh(at: Advertisement.start.addingTimeInterval(10))
        #expect(notifier.alerts.isEmpty)

        model.refresh(at: Advertisement.start.addingTimeInterval(16))
        #expect(notifier.alerts == ["Buds"])
        #expect(model.lostAlerts == 1)

        model.refresh(at: Advertisement.start.addingTimeInterval(60))
        #expect(notifier.alerts.count == 1)
    }

    @Test func aWatchedDeviceStillTalkingRaisesNoAlert() async {
        let model = makeModel()
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture()))
        await model.watch(Advertisement.testID(1))
        for second in stride(from: 5.0, through: 60, by: 5) {
            model.handle(.advertisement(.fixture(after: second)))
            model.refresh(at: Advertisement.start.addingTimeInterval(second))
        }
        #expect(notifier.alerts.isEmpty)
    }

    @Test func refusedNotificationsLeaveTheDeviceUnwatched() async {
        notifier.allows = false
        let model = makeModel()
        model.handle(.advertisement(.fixture()))
        await model.watch(Advertisement.testID(1))
        #expect(model.watchedID == nil)
        #expect(model.notificationsDenied)
        model.refresh(at: Advertisement.start.addingTimeInterval(60))
        #expect(notifier.alerts.isEmpty)
    }

    @Test func stopWatchingSilencesTheAlert() async {
        let model = makeModel()
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture()))
        await model.watch(Advertisement.testID(1))
        model.stopWatching()
        #expect(model.watchedID == nil)
        model.refresh(at: Advertisement.start.addingTimeInterval(60))
        #expect(notifier.alerts.isEmpty)
    }

    @Test func bluetoothOffPausesTheWatchAndOnRestartsItsClock() async {
        let model = makeModel()
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture(name: "Buds")))
        await model.watch(Advertisement.testID(1))

        model.handle(.state(.poweredOff))
        model.refresh(at: Advertisement.start.addingTimeInterval(120))
        #expect(notifier.alerts.isEmpty)

        clock.now = Advertisement.start.addingTimeInterval(120)
        model.handle(.state(.ready))
        model.refresh(at: Advertisement.start.addingTimeInterval(130))
        #expect(notifier.alerts.isEmpty)
        model.refresh(at: Advertisement.start.addingTimeInterval(136))
        #expect(notifier.alerts == ["Buds"])
    }

    @Test func theWatchKeepsTheNameAfterTheDeviceLeavesTheList() async {
        let model = makeModel()
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture(name: "Forerunner")))
        await model.watch(Advertisement.testID(1))
        model.refresh(at: Advertisement.start.addingTimeInterval(30))
        #expect(model.devices.isEmpty)
        #expect(notifier.alerts == ["Forerunner"])
    }

    @Test func comingCloseCelebratesOnce() {
        let model = makeModel()
        model.handle(.advertisement(.fixture(rssi: -70)))
        model.track(Advertisement.testID(1))
        #expect(model.foundMoments == 0)

        var second = 0.0
        for _ in 0..<20 {
            second += 0.1
            model.handle(.advertisement(.fixture(rssi: -42, after: second)))
            model.refresh(at: Advertisement.start.addingTimeInterval(second))
        }
        #expect(model.foundMoments == 1)
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
        let reopened = ScanModel(scanner: FakeScanner(), notifier: FakeLostNotifier(), defaults: defaults)
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
        #expect(ScanModel(scanner: FakeScanner(), notifier: FakeLostNotifier(), defaults: defaults).showsUnnamed)
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
        clock.now = Advertisement.start.addingTimeInterval(1)
        model.track(Advertisement.testID(1))

        let tracked = try #require(model.tracked)
        #expect(tracked.device.name == "Buds")
        #expect(tracked.warmth == .hot)
        #expect(tracked.silence == 1)
        #expect(!tracked.isLost)
    }

    @Test func trackingAnUnknownDeviceShowsNothing() {
        let model = makeModel()
        clock.now = Advertisement.start
        model.track(Advertisement.testID(9))
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
        clock.now = Advertisement.start.addingTimeInterval(second)
        model.track(Advertisement.testID(1))
        #expect(model.tracked?.warmth == .hot)

        hear(-66) // Proximity 57: below Caldo, inside the margin.
        #expect(model.tracked?.warmth == .hot)

        hear(-75) // Proximity 42.
        #expect(model.tracked?.warmth == .warm)
    }

    @Test func aSilentTrackedDeviceIsKeptAndSaysForHowLong() throws {
        let model = makeModel()
        model.handle(.advertisement(.fixture(rssi: -50)))
        clock.now = Advertisement.start
        model.track(Advertisement.testID(1))

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
        clock.now = Advertisement.start
        model.track(Advertisement.testID(1))
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
        clock.now = Advertisement.start
        model.track(Advertisement.testID(1))
        model.handle(.state(.poweredOff))
        model.refresh(at: Advertisement.start.addingTimeInterval(5))
        #expect(model.tracked?.isLost == true)
    }

    @Test func stopTrackingForgetsIt() {
        let model = makeModel()
        model.handle(.advertisement(.fixture()))
        clock.now = Advertisement.start
        model.track(Advertisement.testID(1))
        model.stopTracking()
        #expect(model.tracked == nil)
        model.refresh(at: Advertisement.start)
        #expect(model.tracked == nil)
    }

    @Test func trackingAnotherDeviceStartsItsWordAfresh() {
        let model = makeModel()
        model.handle(.advertisement(.fixture(device: 1, rssi: -45)))
        model.handle(.advertisement(.fixture(device: 2, rssi: -66)))
        clock.now = Advertisement.start
        model.track(Advertisement.testID(1))
        #expect(model.tracked?.warmth == .veryClose)

        clock.now = Advertisement.start
        model.track(Advertisement.testID(2))
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
