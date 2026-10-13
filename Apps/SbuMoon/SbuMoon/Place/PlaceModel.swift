import Foundation
import Observation

/// The place for moonrise and moonset, saved on this iPhone: a city from the list, or the
/// iPhone's position read once when the user asks.
@Observable
final class PlaceModel {
    /// What happened to the last request for the iPhone's position.
    enum LocationState: Equatable {
        case idle
        case locating
        case denied
        case unavailable
    }

    private static let key = "moonPlace"

    private(set) var place: MoonPlace?
    private(set) var locationState = LocationState.idle

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let location: any LocationProviding

    init(defaults: UserDefaults = .standard, location: any LocationProviding = DeviceLocation()) {
        self.defaults = defaults
        self.location = location
        place = defaults.data(forKey: Self.key).flatMap { try? JSONDecoder().decode(MoonPlace.self, from: $0) }
    }

    /// The bundled city the place is, or `nil` for the iPhone's position.
    var city: City? {
        place?.cityID.flatMap(CityCatalog.city(id:))
    }

    func choose(_ city: City) {
        save(MoonPlace(city: city))
        locationState = .idle
    }

    /// Reads the iPhone's position and makes it the place. Returns whether it worked.
    @discardableResult
    func useCurrentLocation() async -> Bool {
        locationState = .locating
        do {
            let coordinates = try await location.currentCoordinates()
            save(MoonPlace(currentLocation: coordinates))
            locationState = .idle
            return true
        } catch LocationError.denied {
            locationState = .denied
        } catch {
            locationState = .unavailable
        }
        return false
    }

    private func save(_ place: MoonPlace) {
        self.place = place
        defaults.set(try? JSONEncoder().encode(place), forKey: Self.key)
    }
}
