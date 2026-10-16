import Foundation
@testable import SbuFind

extension Sighting {
    static func fixture(
        device: Int = 1,
        name: String = "Buds Pro",
        kind: DeviceKind = .earbuds,
        after seconds: TimeInterval = 0,
        accuracy: Double = 10
    ) -> Sighting {
        Sighting(
            id: Advertisement.testID(device),
            name: name,
            kind: kind,
            date: Advertisement.start.addingTimeInterval(seconds),
            place: Coordinate(latitude: 45.46, longitude: 9.19, accuracy: accuracy, date: Advertisement.start.addingTimeInterval(seconds))
        )
    }
}

extension SightingStore {
    /// A store in a fresh temporary file, gone with the test.
    static func temporary() -> SightingStore {
        SightingStore(url: URL.temporaryDirectory.appending(path: "sightings-\(UUID().uuidString).json"))
    }
}
