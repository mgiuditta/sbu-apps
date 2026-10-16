import Foundation

/// A fixed place, allowed without asking: for the simulator's fixed scanner, UI tests and previews.
final class FixedLocationProvider: LocationProvider {
    /// A courtyard in Milan, for the screenshots.
    static let demo = Coordinate(latitude: 45.4642, longitude: 9.1900, accuracy: 10, date: .distantPast)

    var current: Coordinate?
    var allowsAccess: Bool
    private(set) var isRunning = false

    init(current: Coordinate? = FixedLocationProvider.demo, allowsAccess: Bool = true) {
        self.current = current
        self.allowsAccess = allowsAccess
    }

    func requestAccess() async -> Bool {
        allowsAccess
    }

    func start() {
        isRunning = true
    }

    func stop() {
        isRunning = false
    }
}
