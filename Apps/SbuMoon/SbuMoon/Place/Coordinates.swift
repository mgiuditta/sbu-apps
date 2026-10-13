import Foundation

/// A point on the Earth in degrees: latitude north positive, longitude east positive.
nonisolated struct Coordinates: Codable, Equatable, Hashable, Sendable {
    var latitude: Double
    var longitude: Double
}
