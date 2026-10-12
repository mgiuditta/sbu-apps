import Foundation
import Testing
@testable import SbuSpeed

struct SpeedModelTests {
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "SpeedModelTests-\(UUID().uuidString)"))
    }

    private func model(_ events: [SpeedEvent] = [], locale: String = "it_IT") -> SpeedModel {
        SpeedModel(source: FakeSpeedSource(events), defaults: defaults, locale: Locale(identifier: locale))
    }

    @Test func runShowsTheLatestSpeedAndRecordsTheTrip() async {
        let source = FakeSpeedSource([
            .access(.granted),
            .sample(.fix(at: 0, metersNorth: 0, speed: 10)),
            .sample(.fix(at: 1, metersNorth: 14, speed: 14)),
        ])
        let model = SpeedModel(source: source, defaults: defaults, locale: Locale(identifier: "it_IT"))

        await model.run()

        #expect(model.speed == 14)
        #expect(model.status == .moving)
        #expect(model.trip.maxSpeed == 14)
        #expect(abs(model.trip.distance - 14) < 0.5)
        #expect(source.isStopped)
    }

    @Test func fixWithoutSpeedEmptiesTheFigure() async {
        let model = model([
            .access(.granted),
            .sample(.fix(at: 0, speed: 10)),
            .sample(.fix(at: 1, speed: -1, speedAccuracy: -1)),
        ])

        await model.run()

        #expect(model.speed == nil)
        #expect(model.status == .searching)
    }

    @Test(arguments: [LocationAccess.denied, .approximate, .notDetermined])
    func losingAccessEmptiesTheFigureButKeepsTheTrip(access: LocationAccess) async {
        let model = model([
            .access(.granted),
            .sample(.fix(at: 0, speed: 10)),
            .access(access),
        ])

        await model.run()

        #expect(model.speed == nil)
        #expect(model.trip.maxSpeed == 10)
    }

    @Test func resetStartsANewTrip() async {
        let model = model([.access(.granted), .sample(.fix(at: 0, speed: 10))])
        await model.run()

        model.resetTrip()

        #expect(model.trip.isEmpty)
        #expect(model.speed == 10)
    }

    @Test func tripGoesOnAfterARelaunch() async {
        let first = model([
            .access(.granted),
            .sample(.fix(at: 0, metersNorth: 0, speed: 10)),
            .sample(.fix(at: 1, metersNorth: 14, speed: 14)),
        ])
        await first.run()

        let second = model()

        #expect(second.trip.maxSpeed == 14)
        #expect(second.trip.distance == first.trip.distance)
        #expect(second.trip.movingTime == first.trip.movingTime)
    }

    @Test func resetClearsTheSavedTrip() async {
        let first = model([.access(.granted), .sample(.fix(at: 0, speed: 10))])
        await first.run()

        first.resetTrip()

        #expect(model().trip.isEmpty)
    }

    @Test func speedLimitIsOffByDefault() {
        #expect(model().speedLimit == nil)
    }

    @Test func goingOverTheLimitAlertsOnceAndShowsIt() async {
        // 50 km/h is 13.9 m/s.
        let model = model([
            .access(.granted),
            .sample(.fix(at: 0, speed: 12)),
            .sample(.fix(at: 1, speed: 15)),
            .sample(.fix(at: 2, speed: 16)),
        ])
        model.speedLimit = SpeedLimit(value: 50, unit: .kilometersPerHour)

        await model.run()

        #expect(model.limitAlerts == 1)
        #expect(model.isOverLimit)
    }

    @Test func belowTheLimitNothingIsShown() async {
        let model = model([.access(.granted), .sample(.fix(at: 0, speed: 12))])
        model.speedLimit = SpeedLimit(value: 50, unit: .kilometersPerHour)

        await model.run()

        #expect(model.limitAlerts == 0)
        #expect(model.isOverLimit == false)
    }

    @Test func speedLimitIsSavedAndFollowsTheUnit() {
        let first = model(locale: "it_IT")
        first.speedLimit = SpeedLimit(value: 50, unit: .kilometersPerHour)

        first.unit = .milesPerHour

        #expect(first.speedLimit == SpeedLimit(value: 30, unit: .milesPerHour))
        #expect(model(locale: "it_IT").speedLimit == SpeedLimit(value: 30, unit: .milesPerHour))
    }

    @Test func turningTheLimitOffIsSaved() {
        let first = model()
        first.speedLimit = SpeedLimit(value: 50, unit: .kilometersPerHour)

        first.speedLimit = nil

        #expect(model().speedLimit == nil)
    }

    @Test(arguments: [("it_IT", SpeedUnit.kilometersPerHour), ("en_US", .milesPerHour)])
    func unitDefaultsToTheRegion(locale: String, expected: SpeedUnit) {
        #expect(model(locale: locale).unit == expected)
    }

    @Test func chosenUnitIsSavedOnTheDevice() {
        let first = model(locale: "it_IT")
        first.unit = .milesPerHour

        let second = model(locale: "it_IT")

        #expect(second.unit == .milesPerHour)
    }

    @Test func snapshotModeShowsAFixedDriveWithoutReadingTheSource() async {
        defaults.set(true, forKey: "FASTLANE_SNAPSHOT")
        let source = FakeSpeedSource([.access(.denied)])
        let model = SpeedModel(source: source, defaults: defaults, locale: Locale(identifier: "it_IT"))

        await model.run()

        #expect(model.status == .moving)
        #expect(SpeedFigureStyle(unit: .kilometersPerHour).locale(Locale(identifier: "it_IT")).format(model.speed) == "52")
        #expect(source.isStopped == false)
        defaults.removeObject(forKey: "FASTLANE_SNAPSHOT")
        #expect(SpeedModel(source: FakeSpeedSource([]), defaults: defaults).trip.isEmpty)
    }
}
