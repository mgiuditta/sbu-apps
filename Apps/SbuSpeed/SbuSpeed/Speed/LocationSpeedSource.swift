import CoreLocation

/// Reads GPS fixes from Core Location while the app is in use. Asks for when-in-use access the
/// first time; the position never leaves the iPhone.
final class LocationSpeedSource: NSObject, SpeedSource, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: AsyncStream<SpeedEvent>.Continuation?

    func events() -> AsyncStream<SpeedEvent> {
        let (stream, continuation) = AsyncStream.makeStream(of: SpeedEvent.self, bufferingPolicy: .bufferingNewest(16))
        self.continuation = continuation
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .otherNavigation
        // Setting the delegate reports the current access, which starts the updates.
        manager.delegate = self
        return stream
    }

    func stop() {
        manager.stopUpdatingLocation()
        manager.delegate = nil
        continuation?.finish()
        continuation = nil
    }

    private func accessChanged() {
        let access = LocationAccess(status: manager.authorizationStatus, accuracy: manager.accuracyAuthorization)
        continuation?.yield(.access(access))
        switch access {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .granted:
            manager.startUpdatingLocation()
        case .denied, .approximate:
            manager.stopUpdatingLocation()
        }
    }

    // The manager is created on the main thread, so it calls its delegate there.

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated {
            accessChanged()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let samples = locations.map(SpeedSample.init(location:))
        MainActor.assumeIsolated {
            for sample in samples {
                continuation?.yield(.sample(sample))
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        // No fix yet (kCLErrorLocationUnknown) is temporary and Core Location keeps trying;
        // a refusal arrives as an access change. The screen already says it is searching.
    }
}
