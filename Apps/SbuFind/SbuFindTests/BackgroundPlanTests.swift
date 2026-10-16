import Foundation
import Testing
@testable import SbuFind

struct BackgroundPlanTests {
    private func saved(_ number: Int, services: Set<String> = []) -> SavedDevice {
        SavedDevice(name: "Mio \(number)", device: NearbyDevice(
            id: Advertisement.testID(number), name: "Device \(number)", kind: .watch, signal: -60,
            lastSeen: Advertisement.start, serviceUUIDs: services
        ))
    }

    @Test func inFrontTheScanHearsEverything() {
        let mode = BackgroundPlan.scanMode(isForeground: true, saved: [saved(1, services: ["180D"])], watchedDeviceID: nil, placesInBackground: true)
        #expect(mode == .foreground)
    }

    @Test func inTheBackgroundWithNothingToFollowTheScanPauses() {
        #expect(BackgroundPlan.scanMode(isForeground: false, saved: [], watchedDeviceID: nil, placesInBackground: true) == .paused)
        // Saved, with services, but neither watched nor places in the background: nothing needs it.
        #expect(BackgroundPlan.scanMode(isForeground: false, saved: [saved(1, services: ["180D"])], watchedDeviceID: nil, placesInBackground: false) == .paused)
    }

    @Test func aWatchedSavedDeviceWithServicesIsFollowed() {
        let mode = BackgroundPlan.scanMode(
            isForeground: false,
            saved: [saved(1, services: ["180D", "180F"]), saved(2, services: ["FE2C"])],
            watchedDeviceID: Advertisement.testID(1),
            placesInBackground: false
        )
        #expect(mode == .background(services: ["180D", "180F"]))
    }

    @Test func rememberingPlacesFollowsEverySavedDeviceWithServicesOnce() {
        let mode = BackgroundPlan.scanMode(
            isForeground: false,
            saved: [saved(1, services: ["180D"]), saved(2, services: ["180D", "FE2C"]), saved(3)],
            watchedDeviceID: nil,
            placesInBackground: true
        )
        #expect(mode == .background(services: ["180D", "FE2C"]))
    }

    @Test func onlyDevicesWithServicesArePlacedInTheBackground() {
        let mine = [saved(1, services: ["180D"]), saved(2)]
        #expect(BackgroundPlan.placedInBackground(saved: mine, placesInBackground: true).map(\.deviceID) == [Advertisement.testID(1)])
        #expect(BackgroundPlan.placedInBackground(saved: mine, placesInBackground: false).isEmpty)
    }

    /// AirPods and most earbuds advertise no service: iOS cannot listen for them in the background.
    @Test func aWatchedDeviceWithoutServicesCannotBeFollowed() {
        let mode = BackgroundPlan.scanMode(isForeground: false, saved: [saved(1)], watchedDeviceID: Advertisement.testID(1), placesInBackground: true)
        #expect(mode == .paused)
        #expect(!BackgroundPlan.canWatchInBackground(deviceID: Advertisement.testID(1), saved: [saved(1)]))
    }

    @Test func onlyASavedDeviceWithServicesCanBeWatchedInTheBackground() {
        let mine = [saved(1, services: ["180D"])]
        #expect(BackgroundPlan.canWatchInBackground(deviceID: Advertisement.testID(1), saved: mine))
        #expect(!BackgroundPlan.canWatchInBackground(deviceID: Advertisement.testID(2), saved: mine))
    }

    @Test(arguments: [
        (nil as TimeInterval?, 0.0, 60.0),
        (-50, 0, 60),
        (10, 0, 70),
        (5, 5, 65),
    ])
    func theDeadlineCountsFromTheLaterOfLastHeardAndLeaving(lastSeen: TimeInterval?, entered: TimeInterval, deadline: TimeInterval) {
        let start = Advertisement.start
        let result = BackgroundPlan.lostDeadline(
            lastSeen: lastSeen.map { start.addingTimeInterval($0) },
            enteredBackground: start.addingTimeInterval(entered),
            silence: 60
        )
        #expect(result == start.addingTimeInterval(deadline))
    }
}
