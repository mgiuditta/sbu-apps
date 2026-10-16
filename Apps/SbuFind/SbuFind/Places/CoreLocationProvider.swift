import CoreLocation

/// Follows the iPhone's position with Core Location while the app is in use, at ten-metre
/// accuracy: enough to know which room or which street, and gentle on the battery. With location
/// "Sempre", it also reads one position when a saved device is heard in the background.
final class CoreLocationProvider: NSObject, LocationProvider, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var accessContinuation: CheckedContinuation<Bool, Never>?
    private var wantsAlways = false
    private var fixContinuations: [CheckedContinuation<Coordinate?, Never>] = []

    private(set) var current: Coordinate?

    var allowsBackground: Bool {
        manager.authorizationStatus == .authorizedAlways
    }

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
            return await ask(always: false)
        default:
            return false
        }
    }

    func requestBackgroundAccess() async -> Bool {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            return true
        case .notDetermined, .authorizedWhenInUse:
            return await ask(always: true)
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

    func oneShot() async -> Coordinate? {
        guard allowsBackground || manager.authorizationStatus == .authorizedWhenInUse else { return current }
        return await withCheckedContinuation { continuation in
            fixContinuations.append(continuation)
            if fixContinuations.count == 1 {
                manager.requestLocation()
            }
        }
    }

    /// One question at a time: a second tap while the alert is up gets `false`.
    private func ask(always: Bool) async -> Bool {
        if accessContinuation != nil { return false }
        return await withCheckedContinuation { continuation in
            accessContinuation = continuation
            wantsAlways = always
            if always {
                manager.requestAlwaysAuthorization()
            } else {
                manager.requestWhenInUseAuthorization()
            }
        }
    }

    private func finishFix(_ coordinate: Coordinate?) {
        let waiting = fixContinuations
        fixContinuations.removeAll()
        for continuation in waiting {
            continuation.resume(returning: coordinate)
        }
    }

    // The manager is created on the main thread, so it calls its delegate there.

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        MainActor.assumeIsolated {
            guard status != .notDetermined, let continuation = accessContinuation else { return }
            // Asked for "Sempre", "Mentre usi l'app" alone is not enough for the background.
            accessContinuation = nil
            let granted = wantsAlways ? status == .authorizedAlways : (status == .authorizedWhenInUse || status == .authorizedAlways)
            continuation.resume(returning: granted)
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
            finishFix(coordinate)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        // No fix: a one-shot request gets nothing; following the position keeps trying.
        MainActor.assumeIsolated {
            finishFix(nil)
        }
    }
}
