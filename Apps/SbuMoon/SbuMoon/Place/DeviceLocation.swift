import CoreLocation

/// Reads the iPhone's position once, to the kilometre, with when-in-use access asked only the
/// first time the user taps "Usa la mia posizione". Nothing is tracked and nothing leaves the
/// iPhone: the position becomes the place for moonrise and moonset.
final class DeviceLocation: NSObject, LocationProviding, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var accessContinuation: CheckedContinuation<Void, Never>?
    private var locationContinuation: CheckedContinuation<Coordinates, any Error>?

    override init() {
        super.init()
        // A kilometre moves moonrise by a few seconds; approximate location is plenty.
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.delegate = self
    }

    func currentCoordinates() async throws -> Coordinates {
        // One reading at a time: a second tap waits for nothing and gets nothing.
        guard locationContinuation == nil, accessContinuation == nil else { throw CancellationError() }

        if manager.authorizationStatus == .notDetermined {
            await withCheckedContinuation { continuation in
                accessContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }
        }
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            break
        default:
            throw LocationError.denied
        }
        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    // The manager is created on the main thread, so it calls its delegate there.

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        MainActor.assumeIsolated {
            // The delegate also hears the current status as soon as it is set: wait for an answer.
            guard status != .notDetermined else { return }
            accessContinuation?.resume()
            accessContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinates = Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        MainActor.assumeIsolated {
            locationContinuation?.resume(returning: coordinates)
            locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        let isDenied = (error as? CLError)?.code == .denied
        MainActor.assumeIsolated {
            locationContinuation?.resume(throwing: isDenied ? LocationError.denied : LocationError.unavailable)
            locationContinuation = nil
        }
    }
}
