import Foundation
@testable import SbuFind

/// Records the lost alerts instead of showing them; `allows` answers the permission request.
final class FakeLostNotifier: LostNotifier {
    var allows = true
    private(set) var requests = 0
    private(set) var alerts: [String] = []
    /// The pending background alert, if any.
    private(set) var scheduled: (name: String, date: Date)?
    private(set) var cancels = 0

    func requestPermission() async -> Bool {
        requests += 1
        return allows
    }

    func notifyLost(deviceName: String) {
        alerts.append(deviceName)
    }

    func scheduleLost(deviceName: String, at date: Date) {
        scheduled = (deviceName, date)
    }

    func cancelScheduledLost() {
        scheduled = nil
        cancels += 1
    }
}
