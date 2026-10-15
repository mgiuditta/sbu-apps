import Foundation

/// Every saved trip: one JSON file in the app's container, newest first.
nonisolated struct TripLogFile: Codable, Equatable, Sendable {
    /// Bump when the format changes in a way this version cannot read back: an older app then
    /// refuses the file as newer instead of calling it damaged, and never overwrites it.
    static let currentVersion = 1

    var version = currentVersion
    var trips: [TripRecord] = []

    init(trips: [TripRecord] = []) {
        self.trips = trips
    }
}
