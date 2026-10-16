@testable import SbuFind

/// Records the lost alerts instead of showing them; `allows` answers the permission request.
final class FakeLostNotifier: LostNotifier {
    var allows = true
    private(set) var requests = 0
    private(set) var alerts: [String] = []

    func requestPermission() async -> Bool {
        requests += 1
        return allows
    }

    func notifyLost(deviceName: String) {
        alerts.append(deviceName)
    }
}
