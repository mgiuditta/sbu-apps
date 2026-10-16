import CoreLocation

/// Follows the iPhone's position with Core Location while the app is in use, at ten-metre
/// accuracy: enough to know which room or which street, and gentle on the battery.
final class CoreLocationProvider: NSObject, LocationProvider, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var accessContinuation: CheckedContinuation<Bool, Never>?

    private(set) var current: Coordinate?

    override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 5
        manager.delegate = self
    }

    func requestAccess() async -> Bool {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .notDetermined:
            // Only one question at a time: a second tap while the alert is up waits for it.
            if accessContinuation != nil { return false }
            return await withCheckedContinuation { continuation in
                accessContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }
        default:
            return false
        }
    }

    func start() {
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
    }

    // The manager is created on the main thread, so it calls its delegate there.

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        MainActor.assumeIsolated {
            guard status != .notDetermined, let continuation = accessContinuation else { return }
            accessContinuation = nil
            continuation.resume(returning: status == .authorizedWhenInUse || status == .authorizedAlways)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0 else { return }
        let coordinate = Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            accuracy: location.horizontalAccuracy,
            date: location.timestamp
        )
        MainActor.assumeIsolated {
            current = coordinate
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        // No fix yet is temporary and Core Location keeps trying; the sighting waits for one.
    }
}
