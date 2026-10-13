import Foundation

/// Where to work out moonrise and moonset: a bundled city, or the iPhone's position once.
nonisolated struct MoonPlace: Codable, Equatable, Sendable {
    /// The bundled city, or `nil` for the position the iPhone gave.
    var cityID: String?
    var coordinates: Coordinates

    init(city: City) {
        cityID = city.id
        coordinates = city.coordinates
    }

    init(currentLocation coordinates: Coordinates) {
        cityID = nil
        self.coordinates = coordinates
    }

    var isCurrentLocation: Bool { cityID == nil }
}
