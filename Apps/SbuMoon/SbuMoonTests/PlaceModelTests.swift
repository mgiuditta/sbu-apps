import Foundation
import Testing
@testable import SbuMoon

/// Gives a fixed position, or fails as told.
private struct StubLocation: LocationProviding {
    var result: Result<Coordinates, LocationError>

    func currentCoordinates() async throws -> Coordinates {
        try result.get()
    }
}

struct PlaceModelTests {
    private let defaults: UserDefaults
    private let here = Coordinates(latitude: 45.07, longitude: 7.69)

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "PlaceModelTests-\(UUID().uuidString)"))
    }

    @Test func startsWithoutAPlace() {
        let places = PlaceModel(defaults: defaults, location: StubLocation(result: .success(here)))

        #expect(places.place == nil)
        #expect(places.locationState == .idle)
    }

    @Test func aChosenCityIsKeptAcrossLaunches() throws {
        let rome = try #require(CityCatalog.city(id: "rome"))
        PlaceModel(defaults: defaults, location: StubLocation(result: .success(here))).choose(rome)

        let relaunched = PlaceModel(defaults: defaults, location: StubLocation(result: .success(here)))

        #expect(relaunched.city == rome)
        #expect(relaunched.place?.coordinates == rome.coordinates)
    }

    @Test func theCurrentLocationBecomesThePlace() async {
        let places = PlaceModel(defaults: defaults, location: StubLocation(result: .success(here)))

        let worked = await places.useCurrentLocation()

        #expect(worked)
        #expect(places.place == MoonPlace(currentLocation: here))
        #expect(places.place?.isCurrentLocation == true)
        #expect(places.city == nil)
    }

    @Test(arguments: [
        (LocationError.denied, PlaceModel.LocationState.denied),
        (.unavailable, .unavailable),
    ])
    func aFailureKeepsThePreviousPlace(error: LocationError, state: PlaceModel.LocationState) async throws {
        let paris = try #require(CityCatalog.city(id: "paris"))
        let places = PlaceModel(defaults: defaults, location: StubLocation(result: .failure(error)))
        places.choose(paris)

        let worked = await places.useCurrentLocation()

        #expect(worked == false)
        #expect(places.locationState == state)
        #expect(places.city == paris)
    }
}
