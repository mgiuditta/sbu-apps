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

    @Test func dialStartsAtTheSmallestScale() {
        #expect(model(locale: "it_IT").dialFullScale == 60)
    }

    @Test func dialHoldsTheTripTopSpeedAfterSlowingDown() async {
        // 25 m/s is 90 km/h, then 5 m/s is 18 km/h.
        let model = model([.access(.granted), .sample(.fix(at: 0, speed: 25)), .sample(.fix(at: 1, speed: 5))])

        await model.run()

        #expect(model.dialFullScale == 120)
    }

    @Test(arguments: [
        // 5 m/s is 18 km/h on the 60 scale; 100 m/s is 360 km/h, past the 300 scale.
        (Optional(5.0), 0.3),
        (100, 1),
        (nil, 0),
    ])
    func dialFractionIsTheSpeedOverTheScale(metersPerSecond: Double?, expected: Double) async {
        let events: [SpeedEvent] = metersPerSecond.map { [.access(.granted), .sample(.fix(at: 0, speed: $0))] } ?? []
        let model = model(events)

        await model.run()

        #expect(abs(model.dialFraction - expected) < 0.001)
    }

    @Test func dialHoldsTheLimit() {
        let model = model(locale: "it_IT")

        model.speedLimit = SpeedLimit(value: 130, unit: .kilometersPerHour)

        #expect(model.dialFullScale == 200)
    }

    @Test func dialFollowsTheUnit() async {
        // 25 m/s is 90 km/h or 56 mph.
        let model = model([.access(.granted), .sample(.fix(at: 0, speed: 25))])
        await model.run()

        model.unit = .milesPerHour

        #expect(model.dialFullScale == 80)
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

    @Test func knotsAreSavedWithTheLimitInKnots() {
        let first = model(locale: "it_IT")
        first.speedLimit = SpeedLimit(value: 50, unit: .kilometersPerHour)

        first.unit = .knots

        let second = model(locale: "it_IT")
        #expect(second.unit == .knots)
        #expect(second.speedLimit == SpeedLimit(value: 25, unit: .knots))
    }

    @Test func dialAndLimitAlertWorkInKnots() async {
        // 10 knots is 5.14 m/s: 6 m/s reads 12 kn, over the limit.
        let model = model([.access(.granted), .sample(.fix(at: 0, speed: 6))])
        model.unit = .knots
        model.speedLimit = SpeedLimit(value: 10, unit: .knots)

        await model.run()

        #expect(model.isOverLimit)
        #expect(model.limitAlerts == 1)
        #expect(model.dialFullScale == 30)
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
