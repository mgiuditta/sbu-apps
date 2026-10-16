import Foundation
import Testing
@testable import SbuFind

/// The model with the app in the background: what the scan listens for, the lost alert as a
/// notification set for a deadline, and the place read when a saved device is heard.
struct ScanModelBackgroundTests {
    let defaults: UserDefaults
    let scanner = FakeScanner()
    let notifier = FakeLostNotifier()
    let clock = TestClock()
    let location = FixedLocationProvider(allowsBackground: true)
    let activity = FakeSearchActivity()
    let store = SightingStore.temporary()
    let mineStore = MyDevicesStore(url: URL.temporaryDirectory.appending(path: "mine-\(UUID().uuidString).json"))

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "ScanModelBackgroundTests-\(UUID().uuidString)"))
    }

    private func makeModel() -> ScanModel {
        ScanModel(scanner: scanner, notifier: notifier, location: location, sightingStore: store, activity: activity, myDevicesStore: mineStore, defaults: defaults, clock: clock.read)
    }

    /// A model with one saved watch that advertises the Heart Rate service, heard at the start.
    private func modelWithSavedWatch(services: [String] = ["180D"]) throws -> ScanModel {
        let model = makeModel()
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture(device: 1, name: "Forerunner", serviceUUIDs: services)))
        model.refresh(at: Advertisement.start)
        try model.saveDevice(#require(model.devices.first), name: "Il mio orologio")
        return model
    }

    @Test func withNothingToFollowTheBackgroundScanPausesAndResumesInFront() {
        let model = makeModel()
        model.setForeground(false)
        #expect(scanner.modes.last == .paused)
        #expect(activity.isBackground)
        model.setForeground(true)
        #expect(scanner.modes.last == .foreground)
        #expect(!activity.isBackground)
    }

    @Test func aSavedDeviceKeepsItsServices() throws {
        let model = try modelWithSavedWatch(services: ["180f", "180D"])
        #expect(model.myDevices.first?.serviceUUIDs == ["180D", "180F"])
        #expect(model.canWatchInBackground(Advertisement.testID(1)))
    }

    @Test func watchingASavedDeviceWithServicesListensForThemAndSetsTheDeadline() async throws {
        let model = try modelWithSavedWatch()
        await model.watch(Advertisement.testID(1))
        clock.now = Advertisement.start.addingTimeInterval(5)

        model.setForeground(false)

        #expect(scanner.modes.last == .background(services: ["180D"]))
        let scheduled = try #require(notifier.scheduled)
        #expect(scheduled.name == "Il mio orologio")
        #expect(scheduled.date == Advertisement.start.addingTimeInterval(5 + SignalTuning.current.lostAlertBackground))
    }

    @Test func hearingTheWatchedDeviceInTheBackgroundMovesTheDeadlineOn() async throws {
        let model = try modelWithSavedWatch()
        await model.watch(Advertisement.testID(1))
        model.setForeground(false)

        model.handle(.advertisement(.fixture(device: 1, name: "Forerunner", serviceUUIDs: ["180D"], after: 40)))

        let scheduled = try #require(notifier.scheduled)
        #expect(scheduled.date == Advertisement.start.addingTimeInterval(40 + SignalTuning.current.lostAlertBackground))
        #expect(notifier.alerts.isEmpty)
    }

    @Test func backInFrontTheDeadlineIsCancelled() async throws {
        let model = try modelWithSavedWatch()
        await model.watch(Advertisement.testID(1))
        model.setForeground(false)
        clock.now = Advertisement.start.addingTimeInterval(10)

        model.setForeground(true)

        #expect(notifier.scheduled == nil)
        #expect(scanner.modes.last == .foreground)
    }

    /// The notification went off in the background: back in front the same loss is not
    /// announced a second time.
    @Test func anAlertShownInTheBackgroundIsNotRepeatedInFront() async throws {
        let model = try modelWithSavedWatch()
        await model.watch(Advertisement.testID(1))
        model.setForeground(false)
        clock.now = Advertisement.start.addingTimeInterval(SignalTuning.current.lostAlertBackground + 30)

        model.setForeground(true)
        model.refresh(at: Advertisement.start.addingTimeInterval(SignalTuning.current.lostAlertBackground + 60))

        #expect(notifier.alerts.isEmpty)
    }

    @Test func aWatchedDeviceThatCannotBeFollowedIsNotAlertedInTheBackground() async throws {
        let model = try modelWithSavedWatch(services: [])
        await model.watch(Advertisement.testID(1))
        #expect(!model.canWatchInBackground(Advertisement.testID(1)))

        model.setForeground(false)
        model.refresh(at: Advertisement.start.addingTimeInterval(600))

        #expect(scanner.modes.last == .paused)
        #expect(notifier.scheduled == nil)
        #expect(notifier.alerts.isEmpty)
    }

    @Test func anUnsavedWatchedDeviceIsNotFollowedInTheBackground() async {
        let model = makeModel()
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture(device: 3, name: "Altro", serviceUUIDs: ["180D"])))
        await model.watch(Advertisement.testID(3))

        model.setForeground(false)

        #expect(scanner.modes.last == .paused)
        #expect(notifier.scheduled == nil)
    }

    @Test func stopWatchingCancelsTheDeadline() async throws {
        let model = try modelWithSavedWatch()
        await model.watch(Advertisement.testID(1))
        model.setForeground(false)
        model.stopWatching()
        #expect(notifier.scheduled == nil)
    }

    @Test func aSavedDeviceHeardInTheBackgroundIsPlacedWhereTheIPhoneIs() async throws {
        let model = try modelWithSavedWatch()
        await model.setRemembersPlaces(true)
        model.setForeground(false)
        #expect(scanner.modes.last == .background(services: ["180D"]))

        model.handle(.advertisement(.fixture(device: 1, name: "Forerunner", serviceUUIDs: ["180D"], after: 90)))
        await model.pendingPlace?.value

        let sighting = try #require(model.sightings.latest(id: Advertisement.testID(1)))
        #expect(sighting.date == Advertisement.start.addingTimeInterval(90))
        #expect(sighting.place == FixedLocationProvider.demo)
        #expect(location.oneShots == 1)
    }

    @Test func placesInTheBackgroundAreReadAtMostOnceAMinute() async throws {
        let model = try modelWithSavedWatch()
        await model.setRemembersPlaces(true)
        model.setForeground(false)
        for second in [90.0, 100, 120, 155] {
            model.handle(.advertisement(.fixture(device: 1, name: "Forerunner", serviceUUIDs: ["180D"], after: second)))
            await model.pendingPlace?.value
        }
        #expect(location.oneShots == 2)
    }

    /// Without location "Sempre" no place can be read: remembering places alone follows nothing,
    /// and the saved device gets its sighting as the app leaves.
    @Test func withoutLocationAlwaysRememberingPlacesFollowsNothing() async throws {
        location.allowsBackground = false
        let model = try modelWithSavedWatch()
        await model.setRemembersPlaces(true)
        model.setForeground(false)
        #expect(scanner.modes.last == .paused)
        #expect(model.sightings.latest(id: Advertisement.testID(1)) != nil)
    }

    @Test func withoutLocationAlwaysNoPlaceIsReadInTheBackground() async throws {
        location.allowsBackground = false
        let model = try modelWithSavedWatch()
        await model.setRemembersPlaces(true)
        model.setForeground(false)
        model.handle(.advertisement(.fixture(device: 1, name: "Forerunner", serviceUUIDs: ["180D"], after: 90)))
        await model.pendingPlace?.value
        #expect(location.oneShots == 0)
    }

    /// Only a device heard under the saved identifier is placed: a device nearby saying the same
    /// name under another one is not.
    @Test func aProbableDeviceHeardInTheBackgroundIsNotPlaced() async throws {
        let model = try modelWithSavedWatch()
        await model.setRemembersPlaces(true)
        model.setForeground(false)
        model.handle(.advertisement(.fixture(device: 7, name: "Forerunner", serviceUUIDs: ["180D"], after: 90)))
        await model.pendingPlace?.value
        #expect(location.oneShots == 0)
        #expect(model.sightings.latest(id: Advertisement.testID(7)) == nil)
    }

    @Test func allowingPlacesInTheBackgroundAsksForAlways() async {
        location.allowsBackground = false
        let model = makeModel()
        #expect(!model.placesInBackground)
        await model.allowPlacesInBackground()
        #expect(model.placesInBackground)
        #expect(!model.locationDenied)
    }

    @Test func refusingAlwaysSaysSo() async {
        location.allowsBackground = false
        location.allowsAccess = false
        let model = makeModel()
        await model.allowPlacesInBackground()
        #expect(!model.placesInBackground)
        #expect(model.locationDenied)
    }

    @Test func theLiveActivityFollowsAReportInTheBackground() throws {
        let model = try modelWithSavedWatch()
        model.track(Advertisement.testID(1))
        model.setForeground(false)
        clock.now = Advertisement.start.addingTimeInterval(30)
        model.handle(.advertisement(.fixture(device: 1, name: "Forerunner", rssi: -45, serviceUUIDs: ["180D"], after: 30)))
        let updates = activity.steps.filter { if case .update = $0 { true } else { false } }
        #expect(!updates.isEmpty)
    }
}
