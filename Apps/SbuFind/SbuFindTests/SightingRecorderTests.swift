import Foundation
import Testing
@testable import SbuFind

struct SightingRecorderTests {
    private func device(_ number: Int, name: String? = "Buds", heardAt seconds: TimeInterval = 0) -> NearbyDevice {
        NearbyDevice(id: Advertisement.testID(number), name: name, kind: .earbuds, signal: -60, lastSeen: Advertisement.start.addingTimeInterval(seconds))
    }

    private func place(_ latitude: Double) -> Coordinate {
        Coordinate(latitude: latitude, longitude: 9, accuracy: 10, date: Advertisement.start)
    }

    @Test func aGoneDeviceIsPlacedWhereItWasLastHeard() {
        var recorder = SightingRecorder()
        recorder.note([device(1)], at: Advertisement.start, place: place(1))
        let sightings = recorder.sightings(for: [device(1)], fallback: place(2))
        #expect(sightings.map(\.place) == [place(1)])
        #expect(sightings.first?.date == Advertisement.start)
        #expect(sightings.first?.name == "Buds")
    }

    @Test func aDeviceNotHeardAtTheNoteKeepsItsEarlierPlace() {
        var recorder = SightingRecorder()
        recorder.note([device(1, heardAt: 0)], at: Advertisement.start, place: place(1))
        // Five seconds later the device is silent: walking on does not move its place.
        recorder.note([device(1, heardAt: 0)], at: Advertisement.start.addingTimeInterval(5), place: place(3))
        #expect(recorder.sightings(for: [device(1)], fallback: nil).map(\.place) == [place(1)])
    }

    @Test(arguments: [(0.0, true), (2.0, true), (2.5, false)])
    func onlyDevicesJustHeardAreNoted(age: TimeInterval, isNoted: Bool) {
        var recorder = SightingRecorder()
        recorder.note([device(1, heardAt: 0)], at: Advertisement.start.addingTimeInterval(age), place: place(1))
        #expect(recorder.sightings(for: [device(1)], fallback: nil).isEmpty != isNoted)
    }

    @Test func withoutANoteTheFallbackPlaceIsUsed() {
        var recorder = SightingRecorder()
        #expect(recorder.sightings(for: [device(1)], fallback: place(7)).map(\.place) == [place(7)])
    }

    @Test func noPlaceNoSighting() {
        var recorder = SightingRecorder()
        recorder.note([device(1)], at: Advertisement.start, place: nil)
        #expect(recorder.sightings(for: [device(1)], fallback: nil).isEmpty)
    }

    @Test func devicesWithoutANameAreNotRecorded() {
        var recorder = SightingRecorder()
        recorder.note([device(1, name: nil)], at: Advertisement.start, place: place(1))
        #expect(recorder.sightings(for: [device(1, name: nil)], fallback: place(1)).isEmpty)
    }

    @Test func aPlaceIsUsedOnce() {
        var recorder = SightingRecorder()
        recorder.note([device(1)], at: Advertisement.start, place: place(1))
        _ = recorder.sightings(for: [device(1)], fallback: nil)
        #expect(recorder.sightings(for: [device(1)], fallback: nil).isEmpty)
    }

    @Test func resetForgetsThePlaces() {
        var recorder = SightingRecorder()
        recorder.note([device(1)], at: Advertisement.start, place: place(1))
        recorder.reset()
        #expect(recorder.sightings(for: [device(1)], fallback: nil).isEmpty)
    }
}
