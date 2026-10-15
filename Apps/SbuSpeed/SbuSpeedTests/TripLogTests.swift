import Foundation
import Testing
@testable import SbuSpeed

struct TripLogTests {
    private let store = TripLogStore(url: .temporaryDirectory.appending(path: "TripLogTests-\(UUID().uuidString).json"))
    private let start = Date(timeIntervalSinceReferenceDate: 800_000_000)

    private func record(kilometers: Double = 12.4, minutes: Double = 20) -> TripRecord {
        TripRecord(
            startedAt: start,
            endedAt: start.addingTimeInterval(minutes * 60 + 120),
            distance: kilometers * 1000,
            movingTime: minutes * 60,
            maxSpeed: 25
        )
    }

    @Test func recordNeedsDistance() {
        #expect(TripRecord(trip: Trip(maxSpeed: 10, distance: 0, movingTime: 0), now: start) == nil)
    }

    @Test func recordFromATripWithoutTimesEndsNow() throws {
        let saved = try #require(TripRecord(trip: Trip(maxSpeed: 10, distance: 1000, movingTime: 100), now: start))

        #expect(saved.endedAt == start)
        #expect(saved.startedAt == start.addingTimeInterval(-100))
        #expect(saved.averageSpeed == 10)
    }

    @Test func addedTripsComeFirstAndSurviveARelaunch() {
        let older = record(kilometers: 5)
        let newer = record(kilometers: 9)
        let log = TripLog(store: store)

        log.add(older)
        log.add(newer)

        #expect(log.trips == [newer, older])
        #expect(TripLog(store: store).trips == [newer, older])
    }

    @Test func deletedTripIsGoneAfterARelaunch() {
        let kept = record(kilometers: 5)
        let deleted = record(kilometers: 9)
        let log = TripLog(store: store)
        log.add(kept)
        log.add(deleted)

        log.delete(deleted)

        #expect(TripLog(store: store).trips == [kept])
    }

    @Test func missingFileIsAnEmptyLog() throws {
        #expect(try store.load() == TripLogFile())
    }

    @Test func fileFromANewerVersionIsNeitherReadNorOverwritten() throws {
        let newer = Data(#"{"version":99,"trips":[],"routes":["something new"]}"#.utf8)
        try newer.write(to: store.url)

        let log = TripLog(store: store)
        log.add(record())

        #expect(log.isReadOnly)
        #expect(log.trips.isEmpty)
        #expect(throws: TripLogStore.Failure.unknownVersion(99)) { try store.load() }
        #expect(try Data(contentsOf: store.url) == newer)
    }

    @Test func fileHoldsNoPosition() throws {
        try store.save(TripLogFile(trips: [record()]))

        let text = try String(contentsOf: store.url, encoding: .utf8)

        #expect(text.contains("latitude") == false)
        #expect(text.contains("longitude") == false)
        #expect(text.contains(#""version":1"#))
    }

    @Test func csvHasAHeaderAndOneRowPerTripInTheUnit() {
        // 12.4 km in 20 minutes is 37.2 km/h on average; 25 m/s is 90 km/h.
        let csv = TripLogCSV(trips: [record()], unit: .kilometersPerHour, date: start)

        let lines = csv.text.components(separatedBy: "\r\n")
        let fields = lines[1].components(separatedBy: ",")

        #expect(lines.count == 3)
        #expect(lines[2].isEmpty)
        #expect(csv.header.count == 6)
        #expect(lines[0].contains("(km/h)"))
        #expect(Array(fields[2...]) == ["1200", "12.40", "90.0", "37.2"])
        #expect(fields[0].hasPrefix("2026-") || fields[0].hasPrefix("2025-"))
    }

    @Test func csvFollowsTheUnit() {
        let csv = TripLogCSV(trips: [record()], unit: .knots, date: start)

        let fields = csv.text.components(separatedBy: "\r\n")[1].components(separatedBy: ",")

        // 12.4 km is 6.70 nmi; 25 m/s is 48.6 kn.
        #expect(fields[3] == "6.70")
        #expect(fields[4] == "48.6")
        #expect(csv.header[3].contains("(NM)"))
    }

    @Test func csvFileNameCarriesTheDay() {
        let csv = TripLogCSV(trips: [], unit: .kilometersPerHour, date: start)

        #expect(csv.fileName.hasPrefix("Sbu Speed "))
        #expect(csv.fileName.hasSuffix(".csv"))
    }

    @Test func demoHasThreeTripsNewestFirst() {
        let trips = TripLogFile.demo(now: start).trips

        #expect(trips.count == 3)
        #expect(trips.map(\.startedAt) == trips.map(\.startedAt).sorted(by: >))
    }
}
