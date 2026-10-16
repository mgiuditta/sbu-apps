import Foundation

/// A fixed place, allowed without asking: for the simulator's fixed scanner, UI tests and previews.
final class FixedLocationProvider: LocationProvider {
    /// A courtyard in Milan, for the screenshots.
    static let demo = Coordinate(latitude: 45.4642, longitude: 9.1900, accuracy: 10, date: .distantPast)

    var current: Coordinate?
    var allowsAccess: Bool
    var allowsBackground: Bool
    private(set) var isRunning = false
    private(set) var oneShots = 0

    init(current: Coordinate? = FixedLocationProvider.demo, allowsAccess: Bool = true, allowsBackground: Bool = false) {
        self.current = current
        self.allowsAccess = allowsAccess
        self.allowsBackground = allowsBackground
    }

    func requestAccess() async -> Bool {
        allowsAccess
    }

    func requestBackgroundAccess() async -> Bool {
        allowsBackground = allowsAccess
        return allowsBackground
    }

    func start() {
        isRunning = true
    }

    func stop() {
        isRunning = false
    }

    func oneShot() async -> Coordinate? {
        oneShots += 1
        return current
    }
}
