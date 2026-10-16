import Foundation
import Testing
@testable import SbuFind

struct ScanModelTests {
    let defaults: UserDefaults
    let scanner = FakeScanner()
    let notifier = FakeLostNotifier()
    let clock = TestClock()
    let location = FixedLocationProvider()
    let store = SightingStore.temporary()

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "ScanModelTests-\(UUID().uuidString)"))
    }

    let activity = FakeSearchActivity()

    let mineStore = MyDevicesStore(url: URL.temporaryDirectory.appending(path: "mine-\(UUID().uuidString).json"))

    private func makeModel() -> ScanModel {
        ScanModel(scanner: scanner, notifier: notifier, location: location, sightingStore: store, activity: activity, myDevicesStore: mineStore, defaults: defaults, clock: clock.read)
    }

    private func reopen() -> ScanModel {
        ScanModel(scanner: FakeScanner(), notifier: FakeLostNotifier(), location: FixedLocationProvider(), sightingStore: store, activity: NoSearchActivity(), myDevicesStore: mineStore, defaults: defaults)
    }

    @Test func aSavedDeviceMovesToTheTopWithYourNameAndIsKept() throws {
        let model = makeModel()
        model.handle(.advertisement(.fixture(device: 1, name: "Buds Pro")))
        model.handle(.advertisement(.fixture(device: 2, name: "Altro")))
        model.refresh(at: Advertisement.start)
        let buds = try #require(model.devices.first { $0.name == "Buds Pro" })

        model.saveDevice(buds, name: "Le mie cuffie")

        #expect(model.myDevices.map(\.name) == ["Le mie cuffie"])
        #expect(model.myMatches[model.myDevices[0].id]?.id == buds.id)
        #expect(model.devices.map(\.name) == ["Altro"])
        #expect(reopen().myDevices.map(\.name) == ["Le mie cuffie"])
    }

    @Test func savingTheSameDeviceTwiceKeepsOne() throws {
        let model = makeModel()
        model.handle(.advertisement(.fixture()))
        model.refresh(at: Advertisement.start)
        let device = try #require(model.devices.first)
        model.saveDevice(device, name: "A")
        model.saveDevice(device, name: "B")
        #expect(model.myDevices.map(\.name) == ["A"])
    }

    @Test func aSavedDeviceUnderANewIdentifierIsFoundAndRemembered() throws {
        let model = makeModel()
        model.handle(.advertisement(.fixture(device: 1, name: "Buds Pro")))
        model.refresh(at: Advertisement.start)
        try model.saveDevice(#require(model.devices.first), name: "Mie")

        // iOS rotates the identifier: the old one goes silent, a new one says the same name.
        model.handle(.advertisement(.fixture(device: 7, name: "Buds Pro", after: 20)))
        model.refresh(at: Advertisement.start.addingTimeInterval(20))

        #expect(model.myMatches[model.myDevices[0].id]?.id == Advertisement.testID(7))
        #expect(model.myDevices[0].deviceID == Advertisement.testID(7))
        #expect(reopen().myDevices[0].deviceID == Advertisement.testID(7))
        #expect(model.devices.isEmpty)
    }

    @Test func aSavedDeviceNotHeardStaysListedAndOpensAsNotNear() throws {
        let model = makeModel()
        model.handle(.advertisement(.fixture(device: 1, name: "Buds Pro")))
        model.refresh(at: Advertisement.start)
        try model.saveDevice(#require(model.devices.first), name: "Mie")
        model.refresh(at: Advertisement.start.addingTimeInterval(30))

        #expect(model.myDevices.count == 1)
        #expect(model.myMatches.isEmpty)

        let fresh = reopen()
        fresh.track(Advertisement.testID(1))
        let tracked = try #require(fresh.tracked)
        #expect(tracked.silence > TrackedDevice.longAgo)
        #expect(fresh.savedDevice(forDeviceID: Advertisement.testID(1))?.name == "Mie")
    }

    @Test func renameAndForget() throws {
        let model = makeModel()
        model.handle(.advertisement(.fixture()))
        model.refresh(at: Advertisement.start)
        try model.saveDevice(#require(model.devices.first), name: "A")
        let id = model.myDevices[0].id

        model.renameDevice(id, to: "  B  ")
        #expect(model.myDevices[0].name == "B")

        model.forgetDevice(id)
        #expect(model.myDevices.isEmpty)
        #expect(model.devices.count == 1)
        #expect(reopen().myDevices.isEmpty)
    }

    @Test func theFinderFollowsASavedDeviceToItsNewIdentifier() throws {
        let model = makeModel()
        model.handle(.advertisement(.fixture(device: 1, name: "Buds Pro", rssi: -80)))
        model.refresh(at: Advertisement.start)
        try model.saveDevice(#require(model.devices.first), name: "Mie")
        model.track(Advertisement.testID(1))

        model.handle(.advertisement(.fixture(device: 7, name: "Buds Pro", rssi: -45, after: 20)))
        model.refresh(at: Advertisement.start.addingTimeInterval(20))

        let tracked = try #require(model.tracked)
        #expect(tracked.device.id == Advertisement.testID(7))
        #expect(!tracked.isLost)
    }

    @Test func openingTheFinderStartsTheLiveActivityAndLeavingEndsIt() {
        let model = makeModel()
        model.handle(.advertisement(.fixture(name: "Buds Pro", rssi: -64)))
        model.track(Advertisement.testID(1))
        let attributes = SearchActivityAttributes(deviceName: "Buds Pro", systemImage: "airpods")
        #expect(activity.steps == [.start(attributes, .init(percent: 60, warmth: .hot))])

        model.stopTracking()
        #expect(activity.steps.last == .end(nil))
    }

    @Test func theLiveActivityFollowsTheSignalAndEndsWhenFound() {
        let model = makeModel()
        model.handle(.advertisement(.fixture(rssi: -70)))
        model.track(Advertisement.testID(1))
        var second = 0.0
        for _ in 0..<30 {
            second += 0.25
            model.handle(.advertisement(.fixture(rssi: -42, after: second)))
            model.refresh(at: Advertisement.start.addingTimeInterval(second))
        }
        let updates = activity.steps.filter { if case .update = $0 { true } else { false } }
        #expect(!updates.isEmpty)
        guard case .end(let final?) = activity.steps.last else {
            Issue.record("The activity did not end with a final state: \(activity.steps)")
            return
        }
        #expect(final.isFound)
        #expect(final.percent >= FoundMoment.threshold)
    }

    @Test func aDeviceNeverHeardStartsNoActivity() {
        let model = makeModel()
        model.track(Advertisement.testID(9))
        #expect(activity.steps.isEmpty)
    }

    @Test func placesAreOffUntilTurnedOn() {
        let model = makeModel()
        #expect(!model.remembersPlaces)
        model.handle(.advertisement(.fixture()))
        model.refresh(at: Advertisement.start.addingTimeInterval(30))
        #expect(model.sightings.sightings.isEmpty)
    }

    @Test func turningPlacesOnAsksForLocationAndIsSaved() async {
        let model = makeModel()
        await model.setRemembersPlaces(true)
        #expect(model.remembersPlaces)
        #expect(!model.locationDenied)
        #expect(reopen().remembersPlaces)
    }

    @Test func refusedLocationLeavesPlacesOff() async {
        location.allowsAccess = false
        let model = makeModel()
        await model.setRemembersPlaces(true)
        #expect(!model.remembersPlaces)
        #expect(model.locationDenied)
    }

    @Test func aDeviceThatFallsSilentIsSightedWhereItWasHeardAndSaved() async throws {
        let model = makeModel()
        await model.setRemembersPlaces(true)
        model.handle(.advertisement(.fixture(name: "Buds Pro")))
        model.refresh(at: Advertisement.start)
        let heardThere = try #require(location.current)
        location.current = Coordinate(latitude: 0, longitude: 0, accuracy: 10, date: Advertisement.start)

        model.refresh(at: Advertisement.start.addingTimeInterval(11))

        let sighting = try #require(model.sightings.sightings.first)
        #expect(sighting.name == "Buds Pro")
        #expect(sighting.place == heardThere)
        #expect(sighting.date == Advertisement.start)
        #expect(reopen().sightings == model.sightings)
    }

    @Test func unnamedDevicesAreNeverSighted() async {
        let model = makeModel()
        await model.setRemembersPlaces(true)
        model.handle(.advertisement(.fixture(name: nil)))
        model.refresh(at: Advertisement.start)
        model.refresh(at: Advertisement.start.addingTimeInterval(11))
        #expect(model.sightings.sightings.isEmpty)
    }

    @Test func bluetoothOffSightsEveryDeviceHeard() async {
        let model = makeModel()
        await model.setRemembersPlaces(true)
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture(device: 1, name: "A")))
        model.handle(.advertisement(.fixture(device: 2, name: "B")))
        model.refresh(at: Advertisement.start)
        model.handle(.state(.poweredOff))
        #expect(Set(model.sightings.sightings.map(\.name)) == ["A", "B"])
    }

    @Test func recentSightingsLeaveOutDevicesHeardNowAndOldOnes() async {
        let model = makeModel()
        await model.setRemembersPlaces(true)
        model.handle(.advertisement(.fixture(device: 1, name: "Gone")))
        model.handle(.advertisement(.fixture(device: 2, name: "Here")))
        model.refresh(at: Advertisement.start)
        model.handle(.advertisement(.fixture(device: 2, name: "Here", after: 11)))
        model.refresh(at: Advertisement.start.addingTimeInterval(11))

        clock.now = Advertisement.start.addingTimeInterval(60)
        #expect(model.recentSightings.map(\.name) == ["Gone"])

        clock.now = Advertisement.start.addingTimeInterval(ScanModel.recentWindow + 60)
        #expect(model.recentSightings.isEmpty)
    }

    @Test func aDeviceHeardAgainUnderANewIdentifierIsNotRecent() async {
        let model = makeModel()
        await model.setRemembersPlaces(true)
        model.handle(.advertisement(.fixture(device: 1, name: "Buds Pro")))
        model.refresh(at: Advertisement.start)
        model.refresh(at: Advertisement.start.addingTimeInterval(11))
        model.handle(.advertisement(.fixture(device: 5, name: "Buds Pro", after: 12)))
        model.refresh(at: Advertisement.start.addingTimeInterval(12))
        clock.now = Advertisement.start.addingTimeInterval(20)
        #expect(model.recentSightings.isEmpty)
    }

    @Test func aSightedDeviceOpensOnTheFinderAsNotHeard() async throws {
        let model = makeModel()
        await model.setRemembersPlaces(true)
        model.handle(.advertisement(.fixture(name: "Buds Pro")))
        model.refresh(at: Advertisement.start)
        model.refresh(at: Advertisement.start.addingTimeInterval(11))

        clock.now = Advertisement.start.addingTimeInterval(600)
        model.track(Advertisement.testID(1))

        let tracked = try #require(model.tracked)
        #expect(tracked.device.name == "Buds Pro")
        #expect(tracked.isLost)
        #expect(model.sighting(for: tracked.device) != nil)
    }

    @Test func forgetPlacesEmptiesTheLogAndTheFile() async {
        let model = makeModel()
        await model.setRemembersPlaces(true)
        model.handle(.advertisement(.fixture()))
        model.refresh(at: Advertisement.start)
        model.refresh(at: Advertisement.start.addingTimeInterval(11))
        model.forgetPlaces()
        #expect(model.sightings.sightings.isEmpty)
        #expect(reopen().sightings.sightings.isEmpty)
    }

    @Test func turningPlacesOffStopsSighting() async {
        let model = makeModel()
        await model.setRemembersPlaces(true)
        await model.setRemembersPlaces(false)
        model.handle(.advertisement(.fixture()))
        model.refresh(at: Advertisement.start)
        model.refresh(at: Advertisement.start.addingTimeInterval(11))
        #expect(model.sightings.sightings.isEmpty)
        #expect(!location.isRunning)
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
        let reopened = reopen()
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
        #expect(reopen().showsUnnamed)
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
